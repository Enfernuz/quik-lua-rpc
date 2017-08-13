local qlua_rpc = require("qlua/qlua_rpc_pb")

local zmq = require("lzmq.ffi")

local ctx = zmq.context()

local Client = {
  
  socket = ctx:socket(zmq.REQ)
}

function Client:init(socket_addr)
  
  self.socket:connect(socket_addr)
end

function Client:start()
    
  local request = qlua_rpc.Qlua_Request()
  request.type = qlua_rpc.GET_SCRIPT_PATH
  local ser_request = request:SerializeToString()

  --print("Raw request data: "..ser_request.."\n")

  self.socket:send(ser_request)

  local msg = self.socket:recv()

  local response = qlua_rpc.Qlua_Response()
  response:ParseFromString(msg)
  if response.type == qlua_rpc.IS_CONNECTED then
    local result = qlua_rpc.IsConnected_Result()
    result:ParseFromString(response.result)
    print( string.format("Received a reply [isConnected: %s]\n", result.isConnected) )
  elseif response.type == qlua_rpc.GET_SCRIPT_PATH then
    local result = qlua_rpc.GetScriptPath_Result()
    result:ParseFromString(response.result)
    print( string.format("Received a reply [isConnected: %s]\n", result.scriptPath) )
  end

  print ("closing...\n")
  self.socket:close()
  ctx:term()
end

local instance = Client;
instance:init("tcp://127.0.0.1:5559")
instance:start()