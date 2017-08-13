local qlua_rpc = require("qlua/qlua_rpc_pb")

local zmq = require("lzmq")
local ctx = zmq.context()

local Worker = {
  
  socket = ctx:socket(zmq.REP)
}

function Worker:init(socket_addr)
  
  self.socket:connect(socket_addr)
end

function Worker:start()
	
	local data, more;
	local result, ser_result;
	local request;
	local response, ser_response;

	while true do

		data, more = self.socket:recv()
		if data == nil then
			print( string.format("Error while receiving data: [%s]\n", more:msg()) )
		else
			request = qlua_rpc.Qlua_Request()
			request:ParseFromString(data)
	  
			response = qlua_rpc.Qlua_Response()

			if request.type == qlua_rpc.IS_CONNECTED then
				result = qlua_rpc.IsConnected_Result()
				result.isConnected = 42
			elseif request.type == qlua_rpc.GET_SCRIPT_PATH then
				result = qlua_rpc.GetScriptPath_Result()
				result.scriptPath = getScriptPath()
			else
				assert(false, "Unknown request\n") -- TO-DO
			end
	  
			ser_result = result:SerializeToString()
			response.type = request.type
			response.result = ser_result
			ser_response = response:SerializeToString()
			self.socket:send(ser_response)
		end
	end

	self.socket:close()
	ctx:term()
end

function main()
	local instance = Worker;
	instance:init("tcp://127.0.0.1:5560")
	instance:start()
end