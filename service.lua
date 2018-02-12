local json = require("utils.json")

local module = {}

local zmq_ctx = nil
local zap_socket = nil
local rep_sockets = {}
local pub_sockets = {}
local poller = nil
local is_running = false
local event_callbacks = {}
local auth_handlers = {}

local function parse_config(filepath)
  
  local cfg_file = io.open("config.json")
  local content = cfg_file:read("a")
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
  for _i, user in users do
    registry[user.username] = user.password
  end
  
  return registry
end

local function create_curve_registry(client_keys)
  
  local registry = {}
  for _i, client_key in client_keys do
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
    
    local zap_domain = "rpc"..tostring(endpoint.id)
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

local function create_socket(endpoint)
  
  local socket
  if endpoint.type == "RPC" then
    socket = zmq_ctx:socket(zmq.REP)
    poller:add(socket, zmq.POLLIN, create_rpc_poll_in_callback(socket))
  elseif endpoint.type == "PUB" then
    socket = zmq_ctx:socket(zmq.PUB)
  else
    error("TODO")
  end
  
  socket:bind( string.format("tcp://%s:%d", endpoint.address.host, endpoint.address.port) )
  if endpoint.type == "PUB" then
    -- Как координировать PUB и SUB правильно (сложно): http://zguide.zeromq.org/lua:all#Node-Coordination
    -- Как не совсем правильно (просто): использовать sleep
    utils.sleep(0.25) -- in seconds
  end
end

local function reg_endpoint(endpoint)
  
  local socket = create_socket(endpoint)
  setup_endpoint_auth(socket, endpoint)
end

local function init()
  
  local config = parse_config("config.json")
  
  for i, endpoint in config.endpoints do
    
    if endpoint.active then
      endpoint.id = i
      reg_endpoint(endpoint)
    end
  end
  
  -- if PUB then init callbacks
end



function module.start()
end

function module.stop()
end

local function publish(event_type, event_data)
end

return module
