local qlua_msg = require("qlua/proto/qlua_msg_pb")
assert(qlua_msg ~= nil, "qlua/proto/qlua_msg_pb lib is missing")

local zmq = require("lzmq")
assert(zmq ~= nil, "lzmq lib is missing.")

local txt = require("text_format")
assert(txt ~= nil, "text_format lib is missing.")

local inspect = require("inspect")
assert(inspect ~= nil, "inspect lib is missing.")

local function insert_table(src, dst)
  
  for k,v in pairs(src) do
      local table_entry = qlua_msg.TableEntry() 
      table_entry.k = tostring(k)
      table_entry.v = tostring(v)
      table.sinsert(dst, table_entry)
  end
end

local function insert_quote_table(src, dst)
  
  for i,v in ipairs(src) do
      local quote = qlua_msg.GetQuoteLevel2_Result.QuoteEntry() 
      quote.price = tostring(v.price)
      quote.quantity = tostring(v.quantity)
      table.sinsert(dst, quote)
  end
end

local function copy_datetime(dst, src)
  
  dst.mcs = tostring(src.mcs)
  dst.ms = tostring(src.ms)
  dst.sec = src.sec
  dst.min = src.min
  dst.hour = src.hour
  dst.day = src.day
  dst.week_day = src.week_day
  dst.month = src.month
  dst.year = src.year
end

local function create_table(pb_map)
  
  local t = {}
  for i,e in ipairs(pb_map) do
    t[e.key] = e.value
  end
  
  return t
end

local function put_to_string_string_pb_map(t, pb_map, pb_map_entry_ctr)
  
  for k,v in pairs(t) do
    local entry = pb_map_entry_ctr()
    entry.key = tostring(k)
    entry.value = tostring(v)
    table.sinsert(pb_map, entry)
  end
end

local function insert_candles_table(src, dst)
  
  for i,v in ipairs(src) do
      local candle = qlua_msg.CandleEntry() 
      candle.open = tostring(v.open)
      candle.close = tostring(v.close)
      candle.high = tostring(v.high)
      candle.low = tostring(v.low)
      candle.volume = tostring(v.volume)
      candle.does_exist = v.doesExist
      copy_datetime(candle.datetime, v.datetime)
      table.sinsert(dst, candle)
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
			request = qlua_msg.Qlua_Request()
			request:ParseFromString(data)
	  
			response = qlua_msg.Qlua_Response()

			if request.type == qlua_msg.ProcedureType.IS_CONNECTED then
				result = qlua_msg.IsConnected_Result()
				result.is_connected = isConnected() -- TO-DO: pcall
			elseif request.type == qlua_msg.ProcedureType.GET_SCRIPT_PATH then
				result = qlua_msg.GetScriptPath_Result()
				result.script_path = getScriptPath() -- TO-DO: pcall
      elseif request.type == qlua_msg.ProcedureType.GET_INFO_PARAM then
        args = qlua_msg.GetInfoParam_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.GetInfoParam_Result()
        result.info_param = getInfoParam(args.param_name) -- TO-DO: pcall
      elseif request.type == qlua_msg.ProcedureType.MESSAGE then
        args = qlua_msg.Message_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.Message_Result()
        result.result = (args.icon_type == nil and message(args.message) or message(args.message, args.icon_type)) -- TO-DO: pcall
      elseif request.type == qlua_msg.ProcedureType.SLEEP then
        args = qlua_msg.Sleep_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.Sleep_Result()
        result.result = sleep(args.time) -- TO-DO: pcall
      elseif request.type == qlua_msg.ProcedureType.GET_WORKING_FOLDER then
        result = qlua_msg.GetWorkingFolder_Result()
        result.working_folder = getWorkingFolder() -- TO-DO: pcall
      elseif request.type == qlua_msg.ProcedureType.PRINT_DBG_STR then
        args = qlua_msg.PrintDbgStr_Request()
        args:ParseFromString(request.args)
        result = nil
        PrintDbgStr(args.s)
      elseif request.type == qlua_msg.ProcedureType.GET_ITEM then
        args = qlua_msg.GetItem_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.GetItem_Result()
        local t = getItem(args.table_name, args.index) -- TO-DO: pcall
        put_to_string_string_pb_map(t, result.table_row, qlua_msg.GetItem_Result.TableRowEntry)
      elseif request.type == qlua_msg.ProcedureType.GET_ORDER_BY_NUMBER then
        args = qlua_msg.GetOrderByNumber_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.GetOrderByNumber_Result()
        local t, i = getOrderByNumber(args.class_code, args.order_id)
        insert_table(t, result.order)
        result.indx = i
      elseif request.type == qlua_msg.ProcedureType.GET_NUMBER_OF then
        args = qlua_msg.GetNumberOf_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.GetNumberOf_Result()
        result.result = getNumberOf(args.table_name) -- TO-DO: pcall
      elseif request.type == qlua_msg.ProcedureType.GET_CLASSES_LIST then
        result = qlua_msg.GetClassesList_Result()
				result.classes_list = getClassesList() -- TO-DO: pcall
      elseif request.type == qlua_msg.ProcedureType.GET_CLASS_INFO then
        args = qlua_msg.GetClassInfo_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.GetClassInfo_Result()
        local t = getClassInfo(args.class_code) -- TO-DO: pcall
        put_to_string_string_pb_map(t, result.class_info, qlua_msg.GetClassInfo_Result.ClassInfoEntry)
      elseif request.type == qlua_msg.ProcedureType.GET_CLASS_SECURITIES then
        args = qlua_msg.GetClassSecurities_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.GetClassSecurities_Result()
        result.class_securities = getClassSecurities(args.class_code) -- TO-DO: pcall
      elseif request.type == qlua_msg.ProcedureType.GET_MONEY then
        args = qlua_msg.GetMoney_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.GetMoney_Result()
        local t = getMoney(args.client_code, args.firmid, args.tag, args.currcode) -- TO-DO: pcall
        put_to_string_string_pb_map(t, result.money, qlua_msg.GetMoney_Result.MoneyEntry)
      elseif request.type == qlua_msg.ProcedureType.GET_MONEY_EX then
        args = qlua_msg.GetMoneyEx_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.GetMoneyEx_Result()
        local t = getMoneyEx(args.firmid, args.client_code, args.tag, args.currcode, args.limit_kind) -- TO-DO: pcall
        put_to_string_string_pb_map(t, result.money_ex, qlua_msg.GetMoneyEx_Result.MoneyExEntry)
      elseif request.type == qlua_msg.ProcedureType.GET_DEPO then
        args = qlua_msg.GetDepo_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.GetDepo_Result()
        local t = getDepo(args.client_code, args.firmid, args.sec_code, args.trdaccid) -- TO-DO: pcall
        put_to_string_string_pb_map(t, result.depo, qlua_msg.GetDepo_Result.DepoEntry)
      elseif request.type == qlua_msg.ProcedureType.GET_DEPO_EX then
        args = qlua_msg.GetDepoEx_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.GetDepoEx_Result()
        local t = getDepoEx(args.firmid, args.client_code, args.sec_code, args.trdaccid, args.limit_kind) -- TO-DO: pcall
        put_to_string_string_pb_map(t, result.depo_ex, qlua_msg.GetDepoEx_Result.DepoExEntry)
      elseif request.type == qlua_msg.ProcedureType.GET_FUTURES_LIMIT then
        args = qlua_msg.GetFuturesLimit_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.GetFuturesLimit_Result()
        local t = getFuturesLimit(args.firmid, args.trdaccid, args.limit_type, args.currcode) -- TO-DO: pcall
        put_to_string_string_pb_map(t, result.futures_limit, qlua_msg.GetFuturesLimit_Result.FuturesLimitEntry)
      elseif request.type == qlua_msg.ProcedureType.GET_FUTURES_HOLDING then
        args = qlua_msg.GetFuturesHolding_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.GetFuturesHolding_Result()
        local t = getFuturesLHolding(args.firmid, args.trdaccid, args.sec_code, args.type) -- TO-DO: pcall
        put_to_string_string_pb_map(t, result.futures_holding, qlua_msg.GetFuturesHolding_Result.FuturesHoldingEntry)
      elseif request.type == qlua_msg.ProcedureType.GET_SECURITY_INFO then
        args = qlua_msg.GetSecurityInfo_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.GetSecurityInfo_Result()
        local t = getSecurityInfo(args.class_code, args.sec_code) -- TO-DO: pcall
        put_to_string_string_pb_map(t, result.security_info, qlua_msg.GetSecurityInfo_Result.SecurityInfoEntry)
      elseif request.type == qlua_msg.ProcedureType.GET_TRADE_DATE then
        result = qlua_msg.GetTradeDate_Result()
        local t = getTradeDate() -- TO-DO: pcall
        put_to_string_string_pb_map(t, result.trade_date, qlua_msg.GetTradeDate_Result.TradeDateEntry)
      elseif request.type == qlua_msg.ProcedureType.GET_QUOTE_LEVEL2 then
        args = qlua_msg.GetQuoteLevel2_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.GetQuoteLevel2_Result()
        local t = getQuoteLevel2(args.class_code, args.sec_code) -- TO-DO: pcall
        result.bid_count = t.bid_count
        result.offer_count = t.offer_count
        if t.bid ~= nil then insert_quote_table(t.bid, result.bid) end
        if t.offer ~= nil then insert_quote_table(t.offer, result.offer) end
      elseif request.type == qlua_msg.ProcedureType.GET_LINES_COUNT then
        args = qlua_msg.GetLinesCount_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.GetLinesCount_Result()
        result.lines_count = getLinesCount(args.tag) -- TO-DO: pcall
      elseif request.type == qlua_msg.ProcedureType.GET_NUM_CANDLES then
        args = qlua_msg.GetNumCandles_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.GetNumCandles_Result()
        result.num_candles = getNumCandles(args.tag) -- TO-DO: pcall
      elseif request.type == qlua_msg.ProcedureType.GET_CANDLES_BY_INDEX then
        args = qlua_msg.GetCandlesByIndex_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.GetCandlesByIndex_Result()
        local t, n, l = getCandlesByIndex(args.tag, args.line, args.first_candle, args.count) -- TO-DO: pcall
        result.n = n
        result.l = l
        insert_candles_table(t, result.t)
      elseif request.type == qlua_msg.ProcedureType.SEND_TRANSACTION then
        args = qlua_msg.SendTransaction_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.SendTransaction_Result()
        local t = create_table(args.transaction)
        result.result = sendTransaction(t) -- TO-DO: pcall
      elseif request.type == qlua_msg.ProcedureType.CALC_BUY_SELL then
        args = qlua_msg.CalcBuySell_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.CalcBuySell_Result()
        result.qty, result.comission = CalcBuySell(args.class_code, args.sec_code, args.client_code, args.account, args.price, args.is_buy, args.is_market)
      elseif request.type == qlua_msg.ProcedureType.GET_PARAM_EX then
        args = qlua_msg.GetParamEx_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.GetParamEx_Result()
        local t = getParamEx(args.class_code, args.sec_code, args.param_name) -- TO-DO: pcall
        put_to_string_string_pb_map(t, result.param_ex, qlua_msg.GetParamEx_Result.ParamExEntry)
      elseif request.type == qlua_msg.ProcedureType.GET_PARAM_EX_2 then
        args = qlua_msg.GetParamEx_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.GetParamEx_Result()
        local t = getParamEx2(args.class_code, args.sec_code, args.param_name) -- TO-DO: pcall
        put_to_string_string_pb_map(t, result.param_ex, qlua_msg.GetParamEx_Result.ParamExEntry)
      elseif request.type == qlua_msg.ProcedureType.GET_PORTFOLIO_INFO then
        args = qlua_msg.GetPortfolioInfo_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.GetPortfolioInfo_Result()
        local t = getPortfolioInfo(args.firm_id, args.client_code) -- TO-DO: pcall
        put_to_string_string_pb_map(t, result.portfolio_info, qlua_msg.GetPortfolioInfo_Result.PortfolioInfoEntry)
      elseif request.type == qlua_msg.ProcedureType.GET_PORTFOLIO_INFO_EX then
        args = qlua_msg.GetPortfolioInfoEx_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.GetPortfolioInfoEx_Result()
        local t = getPortfolioInfoEx(args.firm_id, args.client_code, args.limit_kind) -- TO-DO: pcall
        put_to_string_string_pb_map(t, result.portfolio_info_ex, qlua_msg.GetPortfolioInfoEx_Result.PortfolioInfoExEntry)
			else
				assert(false, "Unknown request\n") -- TO-DO
			end
	  
      response.token = request.token
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