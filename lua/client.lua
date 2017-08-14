local qlua_rpc = require("qlua/proto/qlua_rpc_pb")

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
  request.type = qlua_rpc.MESSAGE
  
  local args = qlua_rpc.Message_Request()
  args.message = "HELLO"
  
  local ser_args = args:SerializeToString()
  
  request.args = ser_args
  local ser_request = request:SerializeToString()

  --print("Raw request data: "..ser_request.."\n")

  self.socket:send(ser_request)

  local msg = self.socket:recv()

  local response = qlua_rpc.Qlua_Response()
  response:ParseFromString(msg)
  if response.type == qlua_rpc.IS_CONNECTED then
    local result = qlua_rpc.IsConnected_Result()
    result:ParseFromString(response.result)
    print( string.format("Received a reply [isConnected: %s]\n", result.is_connected) )
  elseif response.type == qlua_rpc.GET_SCRIPT_PATH then
    local result = qlua_rpc.GetScriptPath_Result()
    result:ParseFromString(response.result)
    print( string.format("Received a reply [scriptPath: %s]\n", result.script_path) )
  elseif response.type == qlua_rpc.GET_INFO_PARAM then
    local result = qlua_rpc.GetInfoParam_Result()
    result:ParseFromString(response.result)
    print( string.format("Received a reply [infoParam: %s]\n", result.info_param) )
  elseif response.type == qlua_rpc.MESSAGE then
    local result = qlua_rpc.Message_Result()
    result:ParseFromString(response.result)
    print( string.format("Received a reply [result: %s]\n", result.result) )
  end

  print ("closing...\n")
  self.socket:close()
  ctx:term()
end

local instance = Client;
instance:init("tcp://127.0.0.1:5559")
instance:start()