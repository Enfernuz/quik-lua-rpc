package.path = getScriptPath() .. '/?.lua;' .. package.path

local qlua = require("qlua.api")

local qlua_events = require("qlua.rpc.qlua_events_pb")
local zmq = require("lzmq")
local zloop = require("lzmq.loop")
local zmq_poller = require("lzmq.poller")
local utils = require("utils.utils")
local json = require("utils.json")
local uuid = require("utils.uuid")
local request_handler = require("impl.request-handler")
local event_handler = require("impl.event-handler")

local pcall = assert(pcall, "pcall function is missing.")
local tostring = assert(tostring, "tostring function is missing.")

local config

local auth_registry
local authenticate

local client_key = zmq.z85_decode("Yne@$w-vo<fVvi]a<NY6T1ed:M$fCG*[IaLV{hID")

local function parse_zap_request(zap_sock)

  local msg, err = zap_sock:recv_all()
  
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

local function send_zap(sok, req, status, text, user, meta)
  return sok:sendx(req.version, req.sequence, status, text, user or "", meta or "")
end

local function init_config()
  
  local config_file = io.open("config.json")
  local content = config_file:read("a")
  config_file:close()
  
  --[[
  if config.auth.curve and config.auth.curve.clients then
    local entries = {}
    for client_key, client_alias in registry.curve.clients do
      entries[zmq.z85_decode(client_key)] = client_alias
    end
    registry.curve.clients = entries
  end
  --]]
  
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

local function authenticate_plain(zap_request)
  
  local entry = auth_registry[zap_request.username]
  
  return (entry and entry.password == zap_request.password)
    
  
  if req.client_key == client_key then 
    send_zap(self.zap_socket, req, "200", "welcome")
  else
    send_zap(self.zap_socket, req, "400", "not-welcome")
  end
end

local function authenticate_curve(zap_request)
  
  local entry = auth_registry[zap_request.username]
  return (entry and entry.password == zap_request.password)
end

-----

local QluaService = {
  
  ctx = nil, 
  zap_socket = nil,
  rep_socket = nil, 
  pub_socket = nil,
  poller = nil, 
  is_running = false
}

QluaService._VERSION = '1.0.0'

OnClose = service.callbacks.OnClose
OnStop = service.callbacks.OnStop
OnInit = service.callbacks.OnInit
OnFirm = service.callbacks.OnFirm
OnAllTrade = service.callbacks.OnAllTrade
OnTrade = service.callbacks.OnTrade
OnOrder = service.callbacks.OnOrder
OnAccountBalance = 
OnFuturesLimitChange = 
OnFuturesLimitDelete = 
OnFuturesClientHolding = 
OnMoneyLimit = 
OnMoneyLimitDelete = 
OnDepoLimit = 
OnDepoLimitDelete = 
OnAccountPosition = 
OnNegDeal = 
OnNegTrade = 
OnStopOrder = 
OnTransReply = 
OnParam = 
OnQuote = 
OnDisconnected = 
OnConnected = 
OnCleanUp = 

-----

function OnClose()
  QluaService:publish(qlua_events.EventType.ON_CLOSE)
  QluaService:terminate()
end

function OnStop(signal)
  QluaService:publish(qlua_events.EventType.PUBLISHER_OFFLINE)
  QluaService:terminate()
end

function OnInit()
  config = init_config()
  QluaService:start(AuthenticationMechanism.PLAIN, "tcp://127.0.0.1:5560", "tcp://127.0.0.1:5561")
  QluaService:publish(qlua_events.EventType.PUBLISHER_ONLINE)
end

function OnFirm(firm)
  QluaService:publish(qlua_events.EventType.ON_FIRM, firm)
end

function OnAllTrade(alltrade)
  QluaService:publish(qlua_events.EventType.ON_ALL_TRADE, alltrade)
end

function OnTrade(trade)
  QluaService:publish(qlua_events.EventType.ON_TRADE, trade)
end

function OnOrder(order)
  QluaService:publish(qlua_events.EventType.ON_ORDER, order)
end

function OnAccountBalance(acc_bal)
  QluaService:publish(qlua_events.EventType.ON_ACCOUNT_BALANCE, acc_bal)
end

function OnFuturesLimitChange(fut_limit)
  QluaService:publish(qlua_events.EventType.ON_FUTURES_LIMIT_CHANGE, fut_limit)
end

function OnFuturesLimitDelete(lim_del)
  QluaService:publish(qlua_events.EventType.ON_FUTURES_LIMIT_DELETE, lim_del)
end

function OnFuturesClientHolding(fut_pos)
  QluaService:publish(qlua_events.EventType.ON_FUTURES_CLIENT_HOLDING, fut_pos)
end

function OnMoneyLimit(mlimit)
  QluaService:publish(qlua_events.EventType.ON_MONEY_LIMIT, mlimit)
end

function OnMoneyLimitDelete(mlimit_del)
  QluaService:publish(qlua_events.EventType.ON_MONEY_LIMIT_DELETE, mlimit_del)
end

function OnDepoLimit(dlimit)
  QluaService:publish(qlua_events.EventType.ON_DEPO_LIMIT, dlimit)
end

function OnDepoLimitDelete(dlimit_del)
  QluaService:publish(qlua_events.EventType.ON_DEPO_LIMIT_DELETE, dlimit_del)
end

function OnAccountPosition(acc_pos)
  QluaService:publish(qlua_events.EventType.ON_ACCOUNT_POSITION, acc_pos)
end

function OnNegDeal(neg_deal)
  QluaService:publish(qlua_events.EventType.ON_NEG_DEAL, neg_deal)
end

function OnNegTrade(neg_trade)
  QluaService:publish(qlua_events.EventType.ON_NEG_TRADE, neg_trade)
end

function OnStopOrder(stop_order)
  QluaService:publish(qlua_events.EventType.ON_STOP_ORDER, stop_order)
end

function OnTransReply(trans_reply)
  QluaService:publish(qlua_events.EventType.ON_TRANS_REPLY, trans_reply)
end

function OnParam(class_code, sec_code)
  local t = {}
  t.class_code = class_code
  t.sec_code = sec_code
  QluaService:publish(qlua_events.EventType.ON_PARAM, t)
end

function OnQuote(class_code, sec_code)
  local t = {}
  t.class_code = class_code
  t.sec_code = sec_code
  QluaService:publish(qlua_events.EventType.ON_QUOTE, t)
end

function OnDisconnected()
  QluaService:publish(qlua_events.EventType.ON_DISCONNECTED)
end

function OnConnected()
  QluaService:publish(qlua_events.EventType.ON_CONNECTED)
end

function OnCleanUp()
  QluaService:publish(qlua_events.EventType.ON_CLEAN_UP)
end

function QluaService:publish(event_type, event_data) 
  
  if self.pub_socket ~= nil and self.is_running then 
    
    local pub_data = event_handler:handle(event_type, event_data)

    local ok, err
    if pub_data == nil then
      ok, err = pcall(function() self.pub_socket:send(event_type) end) -- send the subscription key
      -- if not ok then (log error somehow...) end
    else
      ok, err = pcall(function() self.pub_socket:send_more(event_type) end) -- send the subscription key
      
      if ok then
        local msg = zmq.msg_init_data( pub_data:SerializeToString() )
        ok, err = pcall(function() msg:send(self.pub_socket) end)
        -- if not ok then (log error somehow...) end
      else
        -- (log error somehow...)
      end
    end
  end
end

function QluaService:start(rep_socket_addr, pub_socket_addr)
  
  -- TODO: разобраться с инициализацией сервиса согласно конфигу: сокеты, аутентификатор.
  
  assert(self.is_running == false, "The QluaService is already running.")

  if rep_socket_addr == nil and pub_socket_addr == nil then
    error("The service cannot be started: nor REP neither PUB socket address is specified.")
  elseif pub_socket_addr == rep_socket_addr then 
    error("REP socket addr equals to PUB socket addr.")
  elseif rep_socket_addr ~= nil and pub_socket_addr ~= nil then
    self.poller = zmq_poller.new(3)
  else 
    self.poller = zmq_poller.new(2)
  end
  
  self.ctx = zmq.context()
  
  local auth_mechanism = config.auth.mechanism
  
  if auth_mechanism ~= "NULL" then
    
    self.zap_socket = self.ctx:socket(zmq.REP)
    self.zap_socket:bind("inproc://zeromq.zap.01")

    if auth_mechanism == "PLAIN" then
      authenticate = authenticate_plain
    else if auth_mechanism == "CURVE" then
      authenticate = authenticate_curve
    end
    
    local zap_handler_func = function()
      local zap_request = zmq.assert(parse_zap_request(self.zap_socket))
      local is_authenticated = authenticate(zap_request)
      if is_authenticated then
        send_zap(self.zap_socket, zap_request, "200")
      else
        send_zap(self.zap_socket, zap_request, "400")
      end
    end
    
    self.poller:add(self.zap_socket, zmq.POLLIN, zap_handler_func)
  end

  if rep_socket_addr then
    
    self.rep_socket = self.ctx:socket(zmq.REP)
    if auth_mechanism == "CURVE" then
    end
    
    self.rep_socket:set_curve_server(1)
	self.rep_socket:set_curve_secretkey("JTKVSB%%)wK0E.X)V>+}o?pNmC{O&4W4b!Ni{Lh6")
	self.rep_socket:set_curve_publickey("rq:rM>}U?@Lns47E1%kR.o@n%FcmmsL/@{H8]yf7")
    self.rep_socket:bind(rep_socket_addr)

    self.poller:add(self.rep_socket, zmq.POLLIN, function() 

      local msg_request = zmq.msg_init()

      local ok, ret = pcall( function() return msg_request:recv(self.rep_socket) end)
      if ok and not (ret == nil or ret == -1) then
        local request = qlua.RPC.Request()
        request:ParseFromString( ret:data() )
        
        local response = request_handler:handle(request)
        
        local msg_response = zmq.msg_init_data( response:SerializeToString() )
        ok = pcall(function() msg_response:send(QluaService.rep_socket) end)
        -- if not ok then (log error somehow...) end
      end
    end)
  end

  if pub_socket_addr then
    self.pub_socket = self.ctx:socket(zmq.PUB)
    self.pub_socket:bind(pub_socket_addr)
    
    -- Как координировать PUB и SUB правильно (сложно): http://zguide.zeromq.org/lua:all#Node-Coordination
    -- Как не совсем правильно (просто): использовать sleep
    utils.sleep(0.5) -- in seconds
  end
  
  uuid.seed()

  self.is_running = true
end

function QluaService:terminate()
  
  if self.is_running then 
    self.is_running = false
  else
    return
  end
  
  self.poller:stop()
    
  -- Set non-negative linger to prevent termination hanging in case if there's a message pending for a disconnected subscriber
  
  if self.rep_socket then self.rep_socket:close(0) end
  if self.pub_socket then self.pub_socket:close(0) end
  if self.zap_socket then self.zap_socket:close(0) end
  self.ctx:term(1)
end

function main()
  QluaService.poller:start()
end
