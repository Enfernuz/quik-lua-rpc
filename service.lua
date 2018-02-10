local json = require("utils.json")

local module = {}

local zap_socket = nil
local rep_sockets = {}
local pub_sockets = {}
local poller = nil
local is_running = false
local event_callbacks = {}

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

local function reg_endpoint_rpc(endpoint_id, endpoint)
  
  
  -- if endpoint.auth
  -- local zap_domain = tostring(endpoint_id)
  -- socket.set_zap_domain(zap_domain)
  -- authenticators[zap_domain] = function() ... end
end

local function reg_endpoint_pub(endpoint_id, endpoint)
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
  return function(username, password)
    return plain_registry[username] == password
  end
end

local function create_curve_auth_handler(curve_registry)
  return function(client_key)
    return curve_registry[client_key]
  end
end
  

local function init()
  
  local config = parse_config("config.json")
  
  for i, endpoint in config.endpoints do
    
    if endpoint.active then
      if endpoint.type == "RPC" then
        reg_endpoint_rpc(i, endpoint)
      elseif endpoint.type == "PUB" then
        reg_endpoint_pub(i, endpoint)
      else 
        error("TODO")
      end
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
