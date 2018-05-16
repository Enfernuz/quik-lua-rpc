local scriptPath = getScriptPath()

package.path = scriptPath .. '/?.lua;' .. package.path

local string = string

local zmq = require("lzmq")
local zmq_poller = require("lzmq.poller")
local zap = require("auth.zap")
local qlua = require("qlua.api")
local qlua_events = require("qlua.rpc.qlua_events_pb")
local config_parser = require("utils.config_parser")
local request_handler = require("impl.request-handler")
local event_handler = require("impl.event-handler")
local utils = require("utils.utils")
local uuid = require("utils.uuid")

local service = {}
service._VERSION = '1.0.0'
service.event_callbacks = {}

local zmq_ctx = nil
local rpc_sockets = {}
local pub_sockets = {}
local poller = nil
local is_running = false
local initialized = false

local function pub_poll_out_callback()
end

local function send_response(response, socket)
  local ok, err = pcall(function()
      local msg = zmq.msg_init_data( response:SerializeToString() )
      msg:send(socket)
  end)
  -- if not ok then (log the error somehow, maybe to a file...) end
end

local function create_rpc_poll_in_callback(socket)
  
  return function()
  
    local ok, err = pcall(function()
      local msg_request = zmq.msg_init()
      local recv = msg_request:recv(socket)
      if not (recv == nil or recv == -1) then
        local request = qlua.RPC.Request()
        request:ParseFromString( recv:data() )
        send_response(request_handler:handle(request), socket)
      end
    end)
    
    if not ok then
      local response = qlua.RPC.Response()
      -- TODO: set the response type to ERROR or something like that
      response.is_error = true
      response.result = utils.Cp1251ToUtf8( string.format("Ошибка при обработке входящего запроса: '%s'.", err) )
      send_response(response, socket)
    end
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
      publish(qlua_events.EventType.ON_CONNECTED, flag)
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
    error( string.format("Указан неподдерживаемый тип '%s' для точки подключения. Поддерживаемые типы: RPC и PUB.", endpoint.type) )
  end
  
  if zap.has_auth(endpoint) then
    if not zap.is_initialized() then zap.init(zmq_ctx, poller) end
    zap.setup_auth(socket, endpoint)
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
  
  return socket
end

local function reg_endpoint(endpoint)
  create_socket(endpoint)
end

local function check_if_initialized()
  if not initialized then error("The service is not initialized.") end
end

function service.init()
  
  if initialized then return end
  
  local config = config_parser.parse(scriptPath.."/config.json")
  
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
  
  -- Does nothing useful at the moment, because the polling has not yet been started at the time it executes.
  -- Issue #13.
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
  
  zap.destroy()
  
  zmq_ctx:term(1)
  zmq_ctx = nil
  
  initialized = false
end

return service
