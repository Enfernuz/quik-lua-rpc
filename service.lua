local scriptPath = getScriptPath()

package.path = scriptPath .. '/?.lua;' .. package.path

local string = string

local zmq = require("lzmq")
local zmq_poller = require("lzmq.poller")
local zap = require("auth.zap")
local config_parser = require("utils.config_parser")
local event_data_converter = require("impl.event_data_converter")
local procedure_wrappers = require("impl.procedure_wrappers")
local utils = require("utils.utils")
local json = require("utils.json")
local uuid = require("utils.uuid")

local service = {}
service._VERSION = "1.0.0"
service.QUIK_VERSION = "7.16.1.36"
service.event_callbacks = {}

local zmq_ctx = nil
local rpc_sockets = {}
local pub_sockets = {}
local poller = nil
local is_running = false
local initialized = false

local request_response_serde = {
  -- initialized on demand
  json = nil,
  protobuf = nil
}

local publishers = {
  json = nil,
  protobuf = nil
}

local protobuf_context = {
  is_initialized = false
}

function protobuf_context:init (context_path)
  require("qlua.qlua_pb_init")(context_path)
  self.is_initialized = true
end

local function pub_poll_out_callback ()
  -- TODO: add reading from a message queue
  -- Polling out is not implemented at the moment: messages are being sent regardless of the POLLOUT event.
end

local function send_data (data, socket)
  local ok, err = pcall(function ()
      local msg = zmq.msg_init_data(data)
      msg:send(socket)
      msg:close()
  end)
  -- if not ok then (log the error somehow, maybe to a file...) end
end

local function gen_error_obj (code, msg)
  
  local err = {code = code}
  if msg then 
    err.message = msg
  end
  
  return err
end

local function create_rpc_poll_in_callback (socket, serde_protocol)
  
  local sd_proto = string.lower(serde_protocol)
  local handler
  if "json" == sd_proto then
    -- TODO: remove this message
    message("DEBUG: JSON message protocol detected")
    if not request_response_serde.json then
      request_response_serde.json = require("impl.json_request_response_serde"):new()
    end
    handler = request_response_serde.json
  elseif "protobuf" == sd_proto then -- TODO: make explicit check on protobuf
    -- TODO: remove this message
    message("DEBUG: PROTOBUF message protocol detected")
    if not request_response_serde.protobuf then
      if not protobuf_context.is_initialized then
        protobuf_context:init(scriptPath)
      end
      request_response_serde.protobuf = require("impl.protobuf_request_response_serde"):new()
    end
    handler = request_response_serde.protobuf
  else
    error( string.format("Неподдерживаемый протокол сериализации/десериализации: %s. Поддерживаемые протоколы: json, protobuf.", serde_protocol) )
  end
  
  local callback = function ()
    
    local ok, res = pcall(function()
        local recv = zmq.msg_init():recv(socket)
        local result
        if recv and recv ~= -1 then
          
          -- request deserialization
          local method, args = handler:deserialize_request( recv:data() )
          recv:close()

          local response = {
            method = method
          }
          local proc_wrapper = procedure_wrappers[method]
          if not proc_wrapper then
            response.error = gen_error_obj(404, string.format("QLua-функция с именем '%s' не найдена.", method))
          else
            -- procedure call
            local ok, proc_result = pcall(function() return proc_wrapper(args) end)
            if ok then
              response.proc_result = proc_result
            else
              response.error = gen_error_obj(1, res) -- the err code 1 is for errors inside the QLua functions' wrappers
            end
          end
          
          result = response
        end
          
        return result
    end)
  
    local response
    if ok then
      if res then response = res end
    else
      response = {}
      response.error = gen_error_obj(500, string.format("Ошибка при обработке входящего запроса: '%s'.", res))
    end
    
    if response then
      -- response serialization
      local serialized_response = handler:serialize_response(response)
      -- response sending
      send_data(serialized_response, socket)
    end
  end

  return callback
end

local function publish (event_type, event_data)

  if not is_running then return end
  
  local converted_event_data = event_data_converter.convert(event_type, event_data)
  
  for _, publisher in pairs(publishers) do
    publisher:publish(event_type, converted_event_data)
  end
end

-- TODO: make the publishing depending on the serde protocol being used
local function create_event_callbacks()
  
  return {
    
    OnClose = function ()
      publish("OnClose")
      service.terminate()
    end,
    
    OnStop = function (signal)
      publish("OnStop", {signal = signal})
      service.terminate()
    end,
    
    OnFirm = function (firm)
      publish("OnFirm", firm)
    end,
    
    OnAllTrade = function (alltrade)
      publish("OnAllTrade", alltrade)
    end,
    
    OnTrade = function (trade)
      publish("OnTrade", trade)
    end,
    
    OnOrder = function (order)
      publish("OnOrder", order)
    end,
    
    OnAccountBalance = function (acc_bal)
      publish("OnAccountBalance", acc_bal)
    end, 
    
    OnFuturesLimitChange = function (fut_limit)
      publish("OnFuturesLimitChange", fut_limit)
    end, 
    
    OnFuturesLimitDelete = function (lim_del)
      publish("OnFuturesLimitDelete", lim_del)
    end,
    
    OnFuturesClientHolding = function (fut_pos)
      publish("OnFuturesClientHolding", fut_pos)
    end, 
    
    OnMoneyLimit = function (mlimit)
      publish("OnMoneyLimit", mlimit)
    end, 
    
    OnMoneyLimitDelete = function (mlimit_del)
      publish("OnMoneyLimitDelete", mlimit_del)
    end, 
    
    OnDepoLimit = function (dlimit)
      publish("OnDepoLimit", dlimit)
    end,
    
    OnDepoLimitDelete = function (dlimit_del)
      publish("OnDepoLimitDelete", dlimit_del)
    end, 
    
    OnAccountPosition = function (acc_pos)
      publish("OnAccountPosition", acc_pos)
    end, 
    
    OnNegDeal = function (neg_deal)
      publish("OnNegDeal", neg_deal)
    end, 
    
    OnNegTrade = function (neg_trade)
      publish("OnNegTrade", neg_trade)
    end,
    
    OnStopOrder = function (stop_order)
      publish("OnStopOrder", stop_order)
    end, 
    
    OnTransReply = function (trans_reply)
      publish("OnTransReply", trans_reply)
    end, 
    
    OnParam = function (class_code, sec_code)
      publish("OnParam", {class_code = class_code, sec_code = sec_code})
    end,
    
    OnQuote = function (class_code, sec_code)
      publish("OnQuote", {class_code = class_code, sec_code = sec_code})
    end, 
    
    OnDisconnected = function ()
      publish("OnDisconnected")
    end, 
    
    OnConnected = function (flag)
      publish("OnConnected", {flag = flag})
    end,
    
    OnCleanUp = function ()
      publish("OnCleanUp")
    end,
    
    OnDataSourceUpdate = function (update_info)
      publish("OnDataSourceUpdate", update_info)
    end
  }
end

local function create_socket (endpoint)
  
  local socket
  local sockets
  if endpoint.type == "RPC" then
    socket = zmq_ctx:socket(zmq.REP)
    poller:add(socket, zmq.POLLIN, create_rpc_poll_in_callback(socket, endpoint.serde_protocol))
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
    
    local serde_protocol = string.lower(endpoint.serde_protocol)
    local publisher
    if "protobuf" == serde_protocol then
      if not publishers.protobuf then
        publishers.protobuf = require("impl.protobuf_event_publisher"):new()
      end
      publisher = publishers.protobuf
    elseif "json" == serde_protocol then
      if not publishers.json then
        publishers.json = require("impl.json_event_publisher"):new()
      end
      publisher = publishers.json
    end
    
    publisher:add_pub_socket(socket)
    
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

local function reg_endpoint (endpoint)
  create_socket(endpoint)
end

local function check_if_initialized ()
  if not initialized then error("The service is not initialized.") end
end

function service.init ()
  
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

function service.start ()
  
  check_if_initialized()
  
  if is_running then 
    return
  else
    is_running = true
  end
  
  -- Does nothing useful at the moment, because the polling has not yet been started at the time it executes.
  -- Issue #13.
  publish("PublisherOnline")
    
  xpcall(
    function() 
      return poller:start() 
    end,
    function()
      message("Ошибка в poller:start. Стек вызовов:\n"..debug.traceback())
    end
  )
end

function service.stop ()
  
  check_if_initialized()

  if is_running then
    poller:stop()
    is_running = false
  end
end

function service.terminate ()

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
