local zmq = require("lzmq")

local zap = {}

local zap_socket = nil
local auth_handlers = {}
local initialized = false

local function parse_zap_request(socket)

  local msg, err = socket:recv_all()
  
  if err then error("Ошибка при получении ZAP-запроса. Errno: "..tostring(err)) end
  
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

local function reply(socket, request, status, text)
  return socket:sendx(request.version, request.sequence, status, text or "", "", "")
end

local function handle_zap_request()
  
  local zap_request = zmq.assert( parse_zap_request(zap_socket) )
  if not zap_request then return end
  
  local zap_domain = zap_request.domain
  local f_authenticate = auth_handlers[zap_domain]
  if f_authenticate then
    if f_authenticate(zap_request) then
      reply(zap_socket, zap_request, "200")
    else
      reply(zap_socket, zap_request, "400")
    end
  else
    reply(zap_socket, zap_request, "500", string.format("Не удалось найти обработчик запроса для ZAP-домена '%s'.", zap_domain))
  end
end

local function create_plain_registry(users)
  
  local registry = {}
  for _i, user in ipairs(users) do
    registry[user.username] = user.password
  end
  
  return registry
end

local function create_plain_auth_handler(plain_registry)
  return function(zap_request)
    return (plain_registry[zap_request.username] == zap_request.password)
  end
end

local function create_curve_registry(client_keys)
  
  local registry = {}
  for _i, client_key in ipairs(client_keys) do
    registry[zmq.z85_decode(client_key)] = true
  end
  
  return registry
end

local function create_curve_auth_handler(curve_registry)
  return function(zap_request)
    return curve_registry[zap_request.client_key]
  end
end

function zap.init(zmq_ctx, poller)
  
  -- if already initialized
  if initialized then return end
  
  zap_socket = zmq_ctx:socket(zmq.REP)
  zap_socket:bind("inproc://zeromq.zap.01")
    
  poller:add(zap_socket, zmq.POLLIN, handle_zap_request)
  
  initialized = true
end

function zap.destroy()
  
  if zap_socket then
    zap_socket:close(0)
    zap_socket = nil
  end
  
  auth_handlers = {}
  initialized = false
end

function zap.setup_auth(socket, endpoint)
  
  if not initialized then error("Модуль ZAP не инициализирован. Сперва вызовите функцию 'init'.") end
  if not socket then error("Аргумент #0 'socket' не должен быть nil.") end
  if not endpoint then error("Аргумент #1 'endpoint' не должен быть nil.") end
  
  local auth = endpoint.auth
  if auth.mechanism == "PLAIN" or auth.mechanism == "CURVE" then
    
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
      auth_handler = create_curve_auth_handler(curve_registry)
    end
    
    auth_handlers[zap_domain] = auth_handler
  end
end

function zap.is_initialized()
  return initialized
end

function zap.has_auth(endpoint)
  local mechanism = endpoint.auth.mechanism
  return (mechanism == "PLAIN" or mechanism == "CURVE")
end

return zap
