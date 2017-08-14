local qlua_rpc = require("qlua/qlua_rpc_pb")
assert(qlua_rpc ~= nil, "qlua/qlua_rpc_pb lib is missing")

local zmq = require("lzmq")
assert(zmq ~= nil, "lzmq lib is missing.")

local Worker = {
  
  ctx = zmq.context(),
  socket = nil,
  is_running = false
}

function Worker:init(socket_addr)
  
  self.socket = self.ctx:socket(zmq.REP)
  self.socket:bind(socket_addr)
end

function Worker:start()
	
	local data, more;
	local result, ser_result;
	local request;
	local response, ser_response;
	
	self.is_running = true

	while self.is_running do

		data, more = self.socket:recv()
		if data == nil then
			print( string.format("Error while receiving data: [%s]\n", more:msg()) )
		else
			request = qlua_rpc.Qlua_Request()
			request:ParseFromString(data)
	  
			response = qlua_rpc.Qlua_Response()

			if request.type == qlua_rpc.IS_CONNECTED then
				result = qlua_rpc.IsConnected_Result()
				result.isConnected = isConnected()
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

end

function Worker:terminate()

	self.is_running = false
	if self.socket ~= nil then self.socket:close() end
	self.ctx:term()
end

return Worker