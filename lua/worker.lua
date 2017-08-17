local qlua_rpc = require("qlua/proto/qlua_rpc_pb")
assert(qlua_rpc ~= nil, "qlua/proto/qlua_rpc_pb lib is missing")

local zmq = require("lzmq")
assert(zmq ~= nil, "lzmq lib is missing.")

local txt = require("text_format")
assert(txt ~= nil, "text_format lib is missing.")

local inspect = require("inspect")
assert(inspect ~= nil, "inspect lib is missing.")

local function insert_table(src, dst)
  
  for k,v in pairs(src) do
      local table_entry = qlua_rpc.TableEntry() 
      table_entry.k = tostring(k)
      table_entry.v = tostring(v)
      table.insert(dst, table_entry)
  end
end

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
  local args;
	
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
				result.is_connected = isConnected() -- TO-DO: pcall
			elseif request.type == qlua_rpc.GET_SCRIPT_PATH then
				result = qlua_rpc.GetScriptPath_Result()
				result.script_path = getScriptPath() -- TO-DO: pcall
      elseif request.type == qlua_rpc.GET_INFO_PARAM then
        args = qlua_rpc.GetInfoParam_Request()
        args:ParseFromString(request.args)
        result = qlua_rpc.GetInfoParam_Result()
        result.info_param = getInfoParam(args.param_name) -- TO-DO: pcall
      elseif request.type == qlua_rpc.MESSAGE then
        args = qlua_rpc.Message_Request()
        args:ParseFromString(request.args)
        result = qlua_rpc.Message_Result()
        result.result = (args.icon_type == nil and message(args.message) or message(args.message, args.icon_type)) -- TO-DO: pcall
      elseif request.type == qlua_rpc.SLEEP then
        args = qlua_rpc.Sleep_Request()
        args:ParseFromString(request.args)
        result = qlua_rpc.Sleep_Result()
        result.result = sleep(args.time) -- TO-DO: pcall
      elseif request.type == qlua_rpc.GET_WORKING_FOLDER then
        result = qlua_rpc.GetWorkingFolder_Result()
        result.working_folder = getWorkingFolder() -- TO-DO: pcall
      elseif request.type == qlua_rpc.PRINT_DBG_STR then
        args = qlua_rpc.PrintDbgStr_Request()
        args:ParseFromString(request.args)
        result = nil
        PrintDbgStr(args.s)
      elseif request.type == qlua_rpc.GET_ITEM then
        args = qlua_rpc.GetItem_Request()
        args:ParseFromString(request.args)
        result = qlua_rpc.GetItem_Result()
        local t = getItem(args.table_name, args.index) -- TO-DO: pcall
        insert_table(t, result.table_row)
      elseif request.type == qlua_rpc.GET_ORDER_BY_NUMBER then
        args = qlua_rpc.GetOrderByNumber_Request()
        args:ParseFromString(request.args)
        result = qlua_rpc.GetOrderByNumber_Result()
        local t, i = getOrderByNumber(args.class_code, args.order_id)
        insert_table(t, result.order)
        result.indx = i
      elseif request.type == qlua_rpc.GET_NUMBER_OF then
        args = qlua_rpc.GetNumberOf_Request()
        args:ParseFromString(request.args)
        result = qlua_rpc.GetNumberOf_Result()
        result.result = getNumberOf(args.table_name) -- TO-DO: pcall
      elseif request.type == qlua_rpc.GET_CLASSES_LIST then
        result = qlua_rpc.GetClassesList_Result()
				result.classes_list = getClassesList() -- TO-DO: pcall
      elseif request.type == qlua_rpc.GET_CLASS_INFO then
        args = qlua_rpc.GetClassInfo_Request()
        args:ParseFromString(request.args)
        result = qlua_rpc.GetClassInfo_Result()
        local t = getClassInfo(args.class_code) -- TO-DO: pcall
        insert_table(t, result.class_info)
      elseif request.type == qlua_rpc.GET_CLASS_SECURITIES then
        args = qlua_rpc.GetClassSecurities_Request()
        args:ParseFromString(request.args)
        result = qlua_rpc.GetClassSecurities_Result()
        result.class_securities = getClassSecurities(args.class_code) -- TO-DO: pcall
      elseif request.type == qlua_rpc.GET_MONEY then
        args = qlua_rpc.GetMoney_Request()
        args:ParseFromString(request.args)
        result = qlua_rpc.GetMoney_Result()
        local t = getMoney(args.client_code, args.firmid, args.tag, args.currcode) -- TO-DO: pcall
        insert_table(t, result.money)
      elseif request.type == qlua_rpc.GET_MONEY_EX then
        args = qlua_rpc.GetMoneyEx_Request()
        args:ParseFromString(request.args)
        result = qlua_rpc.GetMoneyEx_Result()
        local t = getMoneyEx(args.firmid, args.client_code, args.tag, args.currcode, args.limit_kind) -- TO-DO: pcall
        insert_table(t, result.money_ex)
      elseif request.type == qlua_rpc.GET_DEPO then
        args = qlua_rpc.GetDepo_Request()
        args:ParseFromString(request.args)
        result = qlua_rpc.GetDepo_Result()
        local t = getDepo(args.client_code, args.firmid, args.sec_code, args.trdaccid) -- TO-DO: pcall
        insert_table(t, result.depo)
      elseif request.type == qlua_rpc.GET_DEPO_EX then
        args = qlua_rpc.GetDepoEx_Request()
        args:ParseFromString(request.args)
        result = qlua_rpc.GetDepoEx_Result()
        local t = getDepoEx(args.firmid, args.client_code, args.sec_code, args.trdaccid, args.limit_kind) -- TO-DO: pcall
        insert_table(t, result.depo_ex)
			else
				assert(false, "Unknown request\n") -- TO-DO
			end
	  
      response.type = request.type
      if result ~= nil then
        ser_result = result:SerializeToString()
        --response.isError = false
        response.result = ser_result
      end
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