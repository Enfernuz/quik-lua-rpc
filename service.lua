local scriptPath = getScriptPath()

package.path = scriptPath .. '/?.lua;' .. package.path

local zmq = require("lzmq")
local zmq_poller = require("lzmq.poller")
local qlua = require("qlua.api")
local qlua_events = require("qlua.rpc.qlua_events_pb")
local json = require("utils.json")
local request_handler = require("impl.request-handler")
local event_handler = require("impl.event-handler")
local utils = require("utils.utils")
local uuid = require("utils.uuid")

local service = {}
service._VERSION = '1.0.0'
service.event_callbacks = {}

local zmq_ctx = nil
local zap_socket = nil
local rpc_sockets = {}
local pub_sockets = {}
local poller = nil
local is_running = false
local initialized = false
local auth_handlers = {}

local function parse_zap_request()

  local msg, err = zap_socket:recv_all()
  
  if not msg then error("ZAP-handler error. Errno: "..tostring(err)) end
  
  local req = {
    version    = msg[1]; -- Version number, must be "1.0"
    sequence   = msg[2]; -- Sequence number of request
    domain     = msg[3]; -- Server socket domain
    address    = msg[4]; -- Client IP address
    identity   = msg[5]; -- Server socket idenntity
    mechanism  = msg[6]; -- Security mechansim
  }
  
  if req.mechanism == "PLAIN" then
    req.username = msg[7];   -- PLAIN user name
    req.password = msg[8];   -- PLAIN password, in clear text
  elseif req.mechanism == "CURVE" then
    req.client_key = msg[7]; -- CURVE client public key
  end
  
  return req
end

local function parse_config(filepath)
  
  local cfg_file, err = io.open(scriptPath.."/config.json")
  if err then 
    error( string.format("Не удалось открыть файл конфигурации. Подробности: '%s'.", err) ) 
  end
  
  local content = cfg_file:read("*all")
  cfg_file:close()
  
  local config = json.decode(content)
  
  -- fill in lacking sections
  if not config.auth then 
    config.auth = {mechanism = "NULL", plain = {}, curve = {server = {}, clients = {}}} 
  else
    
    local auth_mechanism = config.auth.mechanism
    if not auth_mechanism then 
      error("Не указан механизм аутентификации (секция auth.mechanism). Доступные механизмы: 'NULL', 'PLAIN', 'CURVE'.")
    else
      if auth_mechanism ~= "NULL" or auth_mechanism ~= "PLAIN" or auth_mechanism ~= "CURVE" then
        error(string.format("Указан неподдерживаемый механизм аутентификации '%s' (секция auth.mechanism). Доступные механизмы: 'NULL', 'PLAIN', 'CURVE'."), auth_mechanism)
      end
    end
    
    if not config.auth.plain then config.auth.plain = {} end
    if not config.auth.curve then 
      config.auth.curve = {server = {}, clients = {}}
    else
      if not config.auth.curve.server then config.auth.curve.server = {} end
      if not config.auth.curve.clients then config.auth.curve.clients = {} end
    end
  end
  
  return config
end

local function init_zap()
  
  -- if already initialized
  if zap_socket then return end
  
  zap_socket = zmq_ctx:socket(zmq.REP)
  zap_socket:bind("inproc://zeromq.zap.01")

  local zap_reply = function(zap_request, status, text)
    return zap_socket:sendx(zap_request.version, zap_request.sequence, status, text)
  end
    
  local zap_handler_func = function()
    
    local zap_request = zmq.assert( parse_zap_request() )
    local zap_domain = zap_request.domain
    local f_authenticate = auth_handlers[zap_domain]
    if f_authenticate then
      if f_authenticate() then
        zap_reply(zap_request, "200")
      else
        zap_reply(zap_request, "400")
      end
    else
      zap_reply(zap_request, "500", string.format("Cannot find authentication handler for ZAP domain '%s'.", zap_domain))
    end
  end
    
  poller:add(zap_socket, zmq.POLLIN, zap_handler_func)
end

local function pub_poll_out_callback()
end

local function create_rpc_poll_in_callback(socket)
  
  return function()
    
    local msg_request = zmq.msg_init()

    local ok, ret = pcall( function() return msg_request:recv(socket) end)
    if ok and not (ret == nil or ret == -1) then
      local request = qlua.RPC.Request()
      request:ParseFromString( ret:data() )
        
      local response = request_handler:handle(request)
        
      local msg_response = zmq.msg_init_data( response:SerializeToString() )
      ok = pcall(function() msg_response:send(socket) end)
        -- if not ok then (log error somehow...) end
      end
  end
end

local function create_plain_registry(users)
  
  local registry = {}
  for _i, user in ipairs(users) do
    registry[user.username] = user.password
  end
  
  return registry
end

local function create_curve_registry(client_keys)
  
  local registry = {}
  for _i, client_key in ipairs(client_keys) do
    registry[client_key] = true
  end
  
  return registry
end

local function create_plain_auth_handler(plain_registry)
  return function(zap_request)
    return plain_registry[zap_request.username] == zap_request.password
  end
end

local function create_curve_auth_handler(curve_registry)
  return function(zap_request)
    return curve_registry[zap_request.client_key]
  end
end

local function setup_endpoint_auth(socket, endpoint)
  
  local auth = endpoint.auth
  if auth.mechanism == "PLAIN" or auth.mechanism == "CURVE" then
    
    init_zap()
    
    local zap_domain = endpoint.type..tostring(endpoint.id)
    socket:set_zap_domain(zap_domain)
    
    local auth_handler
    if auth.mechanism == "PLAIN" then
      socket:set_plain_server(1)
      local plain_registry = create_plain_registry(auth.plain.users)
      auth_handler = create_plain_auth_handler(plain_registry)
    else
      socket:set_curve_server(1)
      socket:set_curve_secretkey(auth.curve.server.secret)
      socket:set_curve_publickey(auth.curve.server.public)
      local curve_registry = create_curve_registry(auth.curve.clients)
      auth_handler = create_plain_auth_handler(curve_registry)
    end
    
    auth_handlers[zap_domain] = auth_handler
  end
end

local function publish(event_type, event_data)

  if not is_running then return end
  
  local pub_data = event_handler:handle(event_type, event_data)
  
  for _i, pub_socket in ipairs(pub_sockets) do
    
    local ok, err
    if pub_data == nil then
      ok, err = pcall(function() pub_socket:send(event_type) end) -- send the subscription key
      -- if not ok then (log error somehow...) end
    else
      ok, err = pcall(function() pub_socket:send_more(event_type) end) -- send the subscription key
      if ok then
        local msg = zmq.msg_init_data( pub_data:SerializeToString() )
        ok, err = pcall(function() msg:send(pub_socket) end)
        -- if not ok then (log error somehow...) end
      else
        -- (log error somehow...)
      end
    end
    
  end
  
  
end

local function create_event_callbacks()
  
  return {
    
    OnClose = function()
      publish(qlua_events.EventType.ON_CLOSE)
      service.terminate()
    end,
    
    OnStop = function(signal)
      service.terminate()
    end,
    
    OnFirm = function(firm)
      publish(qlua_events.EventType.ON_FIRM, firm)
    end,
    
    OnAllTrade = function(alltrade)
      publish(qlua_events.EventType.ON_ALL_TRADE, alltrade)
    end,
    
    OnTrade = function(trade)
      publish(qlua_events.EventType.ON_TRADE, trade)
    end,
    
    OnOrder = function(order)
      publish(qlua_events.EventType.ON_ORDER, order)
    end,
    
    OnAccountBalance = function(acc_bal)
      publish(qlua_events.EventType.ON_ACCOUNT_BALANCE, acc_bal)
    end, 
    
    OnFuturesLimitChange = function(fut_limit)
      publish(qlua_events.EventType.ON_FUTURES_LIMIT_CHANGE, fut_limit)
    end, 
    
    OnFuturesLimitDelete = function(lim_del)
      publish(qlua_events.EventType.ON_FUTURES_LIMIT_DELETE, lim_del)
    end,
    
    OnFuturesClientHolding = function(fut_pos)
      publish(qlua_events.EventType.ON_FUTURES_CLIENT_HOLDING, fut_pos)
    end, 
    
    OnMoneyLimit = function(mlimit)
      publish(qlua_events.EventType.ON_MONEY_LIMIT, mlimit)
    end, 
    
    OnMoneyLimitDelete = function(mlimit_del)
      publish(qlua_events.EventType.ON_MONEY_LIMIT_DELETE, mlimit_del)
    end, 
    
    OnDepoLimit = function(dlimit)
      publish(qlua_events.EventType.ON_DEPO_LIMIT, dlimit)
    end,
    
    OnDepoLimitDelete = function(dlimit_del)
      publish(qlua_events.EventType.ON_DEPO_LIMIT_DELETE, dlimit_del)
    end, 
    
    OnAccountPosition = function(acc_pos)
      publish(qlua_events.EventType.ON_ACCOUNT_POSITION, acc_pos)
    end, 
    
    OnNegDeal = function(neg_deal)
      publish(qlua_events.EventType.ON_NEG_DEAL, neg_deal)
    end, 
    
    OnNegTrade = function(neg_trade)
      publish(qlua_events.EventType.ON_NEG_TRADE, neg_trade)
    end,
    
    OnStopOrder = function(stop_order)
      publish(qlua_events.EventType.ON_STOP_ORDER, stop_order)
    end, 
    
    OnTransReply = function(trans_reply)
      publish(qlua_events.EventType.ON_TRANS_REPLY, trans_reply)
    end, 
    
    OnParam = function(class_code, sec_code)
      publish(qlua_events.EventType.ON_PARAM, {class_code = class_code, sec_code = sec_code})
    end,
    
    OnQuote = function(class_code, sec_code)
      publish(qlua_events.EventType.ON_QUOTE, {class_code = class_code, sec_code = sec_code})
    end, 
    
    OnDisconnected = function()
      publish(qlua_events.EventType.ON_DISCONNECTED)
    end, 
    
    OnConnected = function(flag)
      -- TODO: add flag to the ON_CONNECTED event 
      publish(qlua_events.EventType.ON_CONNECTED)
    end,
    
    OnCleanUp = function()
      publish(qlua_events.EventType.ON_CLEAN_UP)
    end
  }
end

local function create_socket(endpoint)
  
  local socket
  local sockets
  if endpoint.type == "RPC" then
    socket = zmq_ctx:socket(zmq.REP)
    poller:add(socket, zmq.POLLIN, create_rpc_poll_in_callback(socket))
    sockets = rpc_sockets
  elseif endpoint.type == "PUB" then
    socket = zmq_ctx:socket(zmq.PUB)
    poller:add(socket, zmq.POLLOUT, pub_poll_out_callback)
    sockets = pub_sockets
  else
    error("TODO")
  end
  
  socket:bind( string.format("tcp://%s:%d", endpoint.address.host, endpoint.address.port) )
  if endpoint.type == "PUB" then
    
    -- Как координировать PUB и SUB правильно (сложно): http://zguide.zeromq.org/lua:all#Node-Coordination
    -- Как не совсем правильно (просто): использовать sleep
    utils.sleep(0.25) -- in seconds
    
    local next = next
    if not next(service.event_callbacks) then
      service.event_callbacks = create_event_callbacks()
    end
  end

  table.sinsert(sockets, socket)
end

local function reg_endpoint(endpoint)
  
  local socket = create_socket(endpoint)
  setup_endpoint_auth(socket, endpoint)
end

local function check_if_initialized()
  if not initialized then error("The service is not initialized.") end
end

function service.init()
  
  if initialized then return end
  
  local config = parse_config("config.json")
  
  zmq_ctx = zmq.context()
  poller = zmq_poller.new()
  
  for i, endpoint in ipairs(config.endpoints) do
    
    if endpoint.active then
      endpoint.id = i
      reg_endpoint(endpoint)
    end
  end
  
  uuid.seed()
  
  initialized = true
end

function service.start()
  
  check_if_initialized()
  
  if is_running then 
    return
  else
    is_running = true
  end
  
  publish(qlua_events.EventType.PUBLISHER_ONLINE)
    
  poller:start()
end

function service.stop()
  
  check_if_initialized()
  
  publish(qlua_events.EventType.PUBLISHER_OFFLINE)
  
  if is_running then
    poller:stop()
    is_running = false
  end
end

function service.terminate()

  check_if_initialized()
  
  if is_running then 
    service.stop()
  end

  poller = nil
    
  -- Set non-negative linger to prevent termination hanging in case if there's a message pending for a disconnected subscriber
  for _i, socket in ipairs(rpc_sockets) do
    socket:close(0)
  end
  rpc_sockets = {}
  
  for _i, socket in ipairs(pub_sockets) do
    socket:close(0)
  end
  pub_sockets = {}
  
  if zap_socket then
    zap_socket:close(0)
    zap_socket = nil
  end
  
  zmq_ctx:term(1)
  zmq_ctx = nil
  
  auth_handlers = {}
  
  initialized = false
end

return service
