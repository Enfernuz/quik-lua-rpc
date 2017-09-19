local qlua_msg = require("quik-lua-rpc.messages.qlua_msg_pb")
assert(qlua_msg ~= nil, "quik-lua-rpc.messages.qlua_msg_pb lib is missing")

local zmq = require("lzmq")
assert(zmq ~= nil, "lzmq lib is missing.")

local zmq_poller = require("lzmq.poller")
assert(zmq_poller ~= nil, "lzmq.poller lib is missing.")

local inspect = require("inspect")
assert(inspect ~= nil, "inspect lib is missing.")

local utils = require("quik-lua-rpc.utils.utils")
assert(utils ~= nil, "quik-lua-rpc.utils.utils lib is missing.")

local uuid = require("quik-lua-rpc.utils.uuid")
assert(uuid ~= nil, "quik-lua-rpc.utils.uuid lib is missing.")

local request_handler = require("quik-lua-rpc.impl.request-handler")
assert(request_handler ~= nil, "quik-lua-rpc.impl.request-handler lib is missing.")

local pcall = pcall
assert(pcall ~= nil, "pcall function is missing.")

local tostring = tostring
assert(tostring ~= nil, "tostring function is missing.")

local QluaService = {
  
  ctx = nil, 
  rep_socket = nil, 
  pub_socket = nil,
  poller = nil, 
  is_running = false
}

function OnClose()
  QluaService:publish(qlua_msg.EventType.ON_CLOSE)
  QluaService:terminate()
end

function OnStop(signal)
  QluaService:publish(qlua_msg.EventType.PUBLISHER_OFFLINE)
  QluaService:terminate()
end

function OnInit()
  QluaService:start("tcp://127.0.0.1:5560", "tcp://127.0.0.1:5561")
  QluaService:publish(qlua_msg.EventType.PUBLISHER_ONLINE)
end

function OnFirm(firm)
  QluaService:publish(qlua_msg.EventType.ON_FIRM, firm)
end

function OnAllTrade(alltrade)
  QluaService:publish(qlua_msg.EventType.ON_ALL_TRADE, alltrade)
end

function OnTrade(trade)
  QluaService:publish(qlua_msg.EventType.ON_TRADE, trade)
end

function OnOrder(order)
  QluaService:publish(qlua_msg.EventType.ON_ORDER, order)
end

function OnAccountBalance(acc_bal)
  QluaService:publish(qlua_msg.EventType.ON_ACCOUNT_BALANCE, acc_bal)
end

function OnFuturesLimitChange(fut_limit)
  QluaService:publish(qlua_msg.EventType.ON_FUTURES_LIMIT_CHANGE, fut_limit)
end

function OnFuturesLimitDelete(lim_del)
  QluaService:publish(qlua_msg.EventType.ON_FUTURES_LIMIT_DELETE, lim_del)
end

function OnFuturesClientHolding(fut_pos)
  QluaService:publish(qlua_msg.EventType.ON_FUTURES_CLIENT_HOLDING, fut_pos)
end

function OnMoneyLimit(mlimit)
  QluaService:publish(qlua_msg.EventType.ON_MONEY_LIMIT, mlimit)
end

function OnMoneyLimitDelete(mlimit_del)
  QluaService:publish(qlua_msg.EventType.ON_MONEY_LIMIT_DELETE, mlimit_del)
end

function OnDepoLimit(dlimit)
  QluaService:publish(qlua_msg.EventType.ON_DEPO_LIMIT, dlimit)
end

function OnDepoLimitDelete(dlimit_del)
  QluaService:publish(qlua_msg.EventType.ON_DEPO_LIMIT_DELETE, dlimit_del)
end

function OnAccountPosition(acc_pos)
  QluaService:publish(qlua_msg.EventType.ON_ACCOUNT_POSITION, acc_pos)
end

function OnNegDeal(neg_deals)
  QluaService:publish(qlua_msg.EventType.ON_NEG_DEAL, neg_deals)
end

function OnNegTrade(neg_trade)
  QluaService:publish(qlua_msg.EventType.ON_NEG_TRADE, neg_trade)
end

function OnStopOrder(stop_order)
  QluaService:publish(qlua_msg.EventType.ON_STOP_ORDER, stop_order)
end

function OnTransReply(trans_reply)
  QluaService:publish(qlua_msg.EventType.ON_TRANS_REPLY, trans_reply)
end

function OnParam(class_code, sec_code)
  local t = {}
  t["class_code"] = class_code
  t["sec_code"] = sec_code
  QluaService:publish(qlua_msg.EventType.ON_PARAM, t)
end

function OnQuote(class_code, sec_code)
  local t = {}
  t["class_code"] = class_code
  t["sec_code"] = sec_code
  QluaService:publish(qlua_msg.EventType.ON_QUOTE, t)
end

function OnDisconnected()
  QluaService:publish(qlua_msg.EventType.ON_DISCONNECTED)
end

function OnConnected()
  QluaService:publish(qlua_msg.EventType.ON_CONNECTED)
end

function OnCleanUp()
  QluaService:publish(qlua_msg.EventType.ON_CLEAN_UP)
end

function QluaService:publish(event_type, event_data) 
  
  if self.pub_socket ~= nil and self.is_running then 
    
    local response = qlua_msg.Qlua_Event()
    response.type = event_type
    
    if event_data ~= nil then
      local data_wrapper = qlua_msg.StringStringTable()
      utils.put_to_string_string_pb_map(event_data, data_wrapper.kv, qlua_msg.StringStringTable.KvEntry)
      response.data = data_wrapper:SerializeToString()
    end

    local ser_response = response:SerializeToString()
    local ok, err = pcall(function() self.pub_socket:send_more( tostring(event_type) ) end) -- send the subscription key
    if ok then
      local msg = zmq.msg_init_data(ser_response)
      ok, err = pcall(function() msg:send(self.pub_socket) end)
    end
  end
end

function QluaService:start(rep_socket_addr, pub_socket_addr)
  
  assert(self.is_running == false, "The QluaService is already running.")

  if rep_socket_addr == nil and pub_socket_addr == nil then
    error("The service cannot be started: nor REP neither PUB socket address is specified.")
  elseif pub_socket_addr == rep_socket_addr then 
    error("REP socket addr equals to PUB socket addr.")
  elseif rep_socket_addr ~= nil and pub_socket_addr ~= nil then
    self.poller = zmq_poller.new(2)
  else 
    self.poller = zmq_poller.new(1)
  end
  
  self.ctx = zmq.context()
  
  if rep_socket_addr ~= nil then
    self.rep_socket = self.ctx:socket(zmq.REP)
    self.rep_socket:bind(rep_socket_addr)
    uuid.seed()

    self.poller:add(self.rep_socket, zmq.POLLIN, function() 

      local msg_request = zmq.msg_init()

      local ok, ret = pcall( function() return msg_request:recv(self.rep_socket) end)
      if ok and ret ~= nil and ret ~= -1 then
        local request = qlua_msg.Qlua_Request()
        request:ParseFromString( ret:data() )
        
        local response = request_handler:handle(request)
        
        local msg_response = zmq.msg_init_data( response:SerializeToString() )
        ok = pcall(function() msg_response:send(QluaService.rep_socket) end)
      end
    end)
  end

  if pub_socket_addr ~= nil then
    self.pub_socket = self.ctx:socket(zmq.PUB)
    self.pub_socket:bind(pub_socket_addr)
    
    -- Как координировать PUB и SUB правильно (сложно): http://zguide.zeromq.org/lua:all#Node-Coordination
    -- Как не совсем правильно (просто): использовать sleep
    utils.sleep(0.5) -- in seconds
  end

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
  
  if self.rep_socket ~= nil then self.rep_socket:close(1) end
  if self.pub_socket ~= nil then self.pub_socket:close(1) end
  self.ctx:term(1)
end

function main()
  QluaService.poller:start()
end
