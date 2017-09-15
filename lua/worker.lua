local qlua_msg = require("qlua/proto/qlua_msg_pb")
assert(qlua_msg ~= nil, "qlua/proto/qlua_msg_pb lib is missing")

local zmq = require("lzmq")
assert(zmq ~= nil, "lzmq lib is missing.")

local uuid = require("uuid")
assert(uuid ~= nil, "uuid lib is missing.")

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

local qtable_parameter_types = {}
qtable_parameter_types[qlua_msg.ColumnParameterType.QTABLE_INT_TYPE] = QTABLE_INT_TYPE
qtable_parameter_types[qlua_msg.ColumnParameterType.QTABLE_DOUBLE_TYPE] = QTABLE_DOUBLE_TYPE
qtable_parameter_types[qlua_msg.ColumnParameterType.QTABLE_INT64_TYPE] = QTABLE_INT64_TYPE
qtable_parameter_types[qlua_msg.ColumnParameterType.QTABLE_CACHED_STRING_TYPE] = QTABLE_CACHED_STRING_TYPE
qtable_parameter_types[qlua_msg.ColumnParameterType.QTABLE_TIME_TYPE] = QTABLE_TIME_TYPE
qtable_parameter_types[qlua_msg.ColumnParameterType.QTABLE_DATE_TYPE] = QTABLE_DATE_TYPE
qtable_parameter_types[qlua_msg.ColumnParameterType.QTABLE_STRING_TYPE] = QTABLE_STRING_TYPE

local interval_types = {}
interval_types[qlua_msg.Interval.INTERVAL_TICK] = INTERVAL_TICK
interval_types[qlua_msg.Interval.INTERVAL_M1] = INTERVAL_M1
interval_types[qlua_msg.Interval.INTERVAL_M2] = INTERVAL_M2
interval_types[qlua_msg.Interval.INTERVAL_M3] = INTERVAL_M3
interval_types[qlua_msg.Interval.INTERVAL_M4] = INTERVAL_M4
interval_types[qlua_msg.Interval.INTERVAL_M5] = INTERVAL_M5
interval_types[qlua_msg.Interval.INTERVAL_M6] = INTERVAL_M6
interval_types[qlua_msg.Interval.INTERVAL_M10] = INTERVAL_M10
interval_types[qlua_msg.Interval.INTERVAL_M15] = INTERVAL_M15
interval_types[qlua_msg.Interval.INTERVAL_M20] = INTERVAL_M20
interval_types[qlua_msg.Interval.INTERVAL_M30] = INTERVAL_M30
interval_types[qlua_msg.Interval.INTERVAL_H1] = INTERVAL_H1
interval_types[qlua_msg.Interval.INTERVAL_H2] = INTERVAL_H2
interval_types[qlua_msg.Interval.INTERVAL_H4] = INTERVAL_H4
interval_types[qlua_msg.Interval.INTERVAL_D1] = INTERVAL_D1
interval_types[qlua_msg.Interval.INTERVAL_W1] = INTERVAL_W1
interval_types[qlua_msg.Interval.INTERVAL_MN1] = INTERVAL_MN1

local function to_qtable_parameter_type(pb_column_parameter_type)
  
  local par_type = qtable_parameter_types[pb_column_parameter_type]
  if par_type == nil then error("Unknown column parameter type.") end
  
  return par_type
end

local function to_interval(pb_interval)

  local interval = interval_types[pb_interval]
  if interval == nil then error("Unknown interval type.") end

  return interval
end

local Worker = {
  
  ctx = zmq.context(),
  socket = nil,
  is_running = false,
  datasources = {}
}

function Worker:init(socket_addr)
  
  self.socket = self.ctx:socket(zmq.REP)
  self.socket:bind(socket_addr)
  uuid.seed()
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
      elseif request.type == qlua_msg.ProcedureType.CREATE_DATA_SOURCE then
        args = qlua_msg.CreateDataSource_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.CreateDataSource_Result()
        local interval = to_interval(args.interval) -- TO-DO: pcall
        local ds, error_desc
        if args.param == nil or args.param == "" then
          ds, error_desc = CreateDataSource(args.class_code, args.sec_code, interval)
        else 
          ds, error_desc = CreateDataSource(args.class_code, args.sec_code, interval, args.param)
        end
        if ds == nil then
          result.is_error = true
          result.error_desc = error_desc or ""
        else
          result.datasource_uuid = uuid()
          self.datasources[result.datasource_uuid] = ds
        end
      elseif request.type == qlua_msg.ProcedureType.DS_SET_UPDATE_CALLBACK then -- TO-DO: revise the error handling
        args = qlua_msg.DataSourceSetUpdateCallback_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.DataSourceSetUpdateCallback_Result()
        local ds = self.datasources[args.datasource_uuid]
        if ds == nil then error("There is no datasource with the given uuid") end
        local f_cb_ctr, error_msg = loadstring("return "..args.f_cb_def)
        if f_cb_ctr == nil then 
          response.is_error = true
          response.result = string.format("Could not parse a function definition from the given string. Error message: \n%s", error_msg)
        else
          local f_cb = f_cb_ctr()
          local callback = function (index) f_cb(index, ds) end
          result.result = ds:SetUpdateCallback(callback) -- TO-DO: pcall
        end
      elseif request.type == qlua_msg.ProcedureType.DS_O then
        args = qlua_msg.DataSourceO_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.DataSourceO_Result()
        local ds = self.datasources[args.datasource_uuid]
        if ds == nil then error("There is no datasource with the given uuid") end
        result.value = ds:O(args.candle_index)
      elseif request.type == qlua_msg.ProcedureType.DS_H then
        args = qlua_msg.DataSourceH_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.DataSourceH_Result()
        local ds = self.datasources[args.datasource_uuid]
        if ds == nil then error("There is no datasource with the given uuid") end
        result.value = ds:H(args.candle_index)
      elseif request.type == qlua_msg.ProcedureType.DS_L then
        args = qlua_msg.DataSourceL_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.DataSourceL_Result()
        local ds = self.datasources[args.datasource_uuid]
        if ds == nil then error("There is no datasource with the given uuid") end
        result.value = ds:L(args.candle_index)
      elseif request.type == qlua_msg.ProcedureType.DS_C then
        args = qlua_msg.DataSourceC_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.DataSourceC_Result()
        local ds = self.datasources[args.datasource_uuid]
        if ds == nil then error("There is no datasource with the given uuid") end
        result.value = ds:C(args.candle_index)
      elseif request.type == qlua_msg.ProcedureType.DS_V then
        args = qlua_msg.DataSourceV_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.DataSourceV_Result()
        local ds = self.datasources[args.datasource_uuid]
        if ds == nil then error("There is no datasource with the given uuid") end
        result.value = ds:V(args.candle_index)
      elseif request.type == qlua_msg.ProcedureType.DS_T then
        args = qlua_msg.DataSourceT_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.DataSourceT_Result()
        local ds = self.datasources[args.datasource_uuid]
        if ds == nil then error("There is no datasource with the given uuid") end
        local t = ds:T(args.candle_index)
        result.year = t.year
        result.month = t.month
        result.day = t.day
        result.week_day = t.week_day
        result.hour = t.hour
        result.min = t.min
        result.sec = t.sec
        result.ms = t.ms
        result.count = t.count
      elseif request.type == qlua_msg.ProcedureType.DS_SIZE then
        args = qlua_msg.DataSourceSize_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.DataSourceSize_Result()
        local ds = self.datasources[args.datasource_uuid]
        if ds == nil then error("There is no datasource with the given uuid") end
        result.value = ds:Size(args.candle_index)
      elseif request.type == qlua_msg.ProcedureType.DS_CLOSE then
        args = qlua_msg.DataSourceClose_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.DataSourceClose_Result()
        local ds = self.datasources[args.datasource_uuid]
        if ds == nil then error("There is no datasource with the given uuid") end
        result.result = ds:Close()
      elseif request.type == qlua_msg.ProcedureType.DS_SET_EMPTY_CALLBACK then
        args = qlua_msg.DataSourceSetEmptyCallback_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.DataSourceSetEmptyCallback_Result()
        local ds = self.datasources[args.datasource_uuid]
        if ds == nil then error("There is no datasource with the given uuid") end
        result.result = ds:SetEmptyCallback()
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
      elseif request.type == qlua_msg.ProcedureType.GET_BUY_SELL_INFO then
        args = qlua_msg.GetBuySellInfo_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.GetBuySellInfo_Result()
        local t = getBuySellInfo(args.firm_id, args.client_code, args.class_code, args.sec_code, args.price) -- TO-DO: pcall
        put_to_string_string_pb_map(t, result.buy_sell_info, qlua_msg.GetBuySellInfo_Result.BuySellInfoEntry)
      elseif request.type == qlua_msg.ProcedureType.GET_BUY_SELL_INFO then
        args = qlua_msg.GetBuySellInfo_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.GetBuySellInfo_Result()
        local t = getBuySellInfo(args.firm_id, args.client_code, args.class_code, args.sec_code, args.price) -- TO-DO: pcall
        put_to_string_string_pb_map(t, result.buy_sell_info, qlua_msg.GetBuySellInfo_Result.BuySellInfoEntry)
      elseif request.type == qlua_msg.ProcedureType.GET_BUY_SELL_INFO_EX then
        args = qlua_msg.GetBuySellInfo_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.GetBuySellInfo_Result()
        local t = getBuySellInfoEx(args.firm_id, args.client_code, args.class_code, args.sec_code, args.price) -- TO-DO: pcall
        put_to_string_string_pb_map(t, result.buy_sell_info, qlua_msg.GetBuySellInfo_Result.BuySellInfoEntry)
      elseif request.type == qlua_msg.ProcedureType.ADD_COLUMN then
        args = qlua_msg.AddColumn_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.AddColumn_Result()
        result.result = AddColumn(args.t_id, args.icode, args.name, args.is_default, to_qtable_parameter_type(args.par_type), args.width) -- TO-DO: pcall
      elseif request.type == qlua_msg.ProcedureType.ALLOC_TABLE then
        result = qlua_msg.AllocTable_Result()
        result.t_id = AllocTable() -- TO-DO: pcall
      elseif request.type == qlua_msg.ProcedureType.CLEAR then
        args = qlua_msg.Clear_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.Clear_Result()
        result.result = Clear(args.t_id) -- TO-DO: pcall
      elseif request.type == qlua_msg.ProcedureType.CREATE_WINDOW then
        args = qlua_msg.CreateWindow_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.CreateWindow_Result()
        result.result = CreateWindow(args.t_id) -- TO-DO: pcall
      elseif request.type == qlua_msg.ProcedureType.DELETE_ROW then
        args = qlua_msg.DeleteRow_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.DeleteRow_Result()
        result.result = DeleteRow(args.t_id, args.key) -- TO-DO: pcall
      elseif request.type == qlua_msg.ProcedureType.DESTROY_TABLE then
        args = qlua_msg.DestroyTable_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.DestroyTable_Result()
        result.result = DestroyTable(args.t_id) -- TO-DO: pcall
      elseif request.type == qlua_msg.ProcedureType.INSERT_ROW then
        args = qlua_msg.InsertRow_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.InsertRow_Result()
        result.result = InsertRow(args.t_id, args.key) -- TO-DO: pcall
      elseif request.type == qlua_msg.ProcedureType.IS_WINDOW_CLOSED then
        args = qlua_msg.IsWindowClosed_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.IsWindowClosed_Result()
        result.result = IsWindowClosed(args.t_id) -- TO-DO: pcall
      elseif request.type == qlua_msg.ProcedureType.GET_CELL then
        args = qlua_msg.GetCell_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.GetCell_Result()
        local t_cell = GetCell(args.t_id, args.key, args.code) -- TO-DO: pcall
        result.image = t_cell.image
        if t_cell.value ~= nil then result.value = tostring(t_cell.value) end
      elseif request.type == qlua_msg.ProcedureType.SET_CELL then
        args = qlua_msg.SetCell_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.SetCell_Result()
        if args.value == "" or args.value == nil then
          result.result = SetCell(args.t_id, args.key, args.code, args.text)
        else
          local value = tonumber(args.value) -- TO-DO: error check
          result.result = SetCell(args.t_id, args.key, args.code, args.text, value) -- TO-DO: pcall
        end
      elseif request.type == qlua_msg.ProcedureType.SET_WINDOW_CAPTION then
        args = qlua_msg.SetWindowCaption_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.SetWindowCaption_Result()
        result.result = SetWindowCaption(args.t_id, args.str) -- TO-DO: pcall
      elseif request.type == qlua_msg.ProcedureType.SET_WINDOW_POS then
        args = qlua_msg.SetWindowPos_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.SetWindowPos_Result()
        result.result = SetWindowPos(args.t_id, args.x, args.y, args.dx, args.dy) -- TO-DO: pcall
      elseif request.type == qlua_msg.ProcedureType.SET_TABLE_NOTIFICATION_CALLBACK then -- TO-DO: revise the error handling
        args = qlua_msg.SetTableNotificationCallback_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.SetTableNotificationCallback_Result()
        local f_cb_ctr, error_msg = loadstring("return "..args.f_cb_def)
        if f_cb_ctr == nil then 
          response.is_error = true
          response.result = string.format("Could not parse a function definition from the given string. Error message: \n%s", error_msg)
        else
          result.result = SetTableNotificationCallback(args.t_id, f_cb_ctr()) -- TO-DO: pcall
        end
      elseif request.type == qlua_msg.ProcedureType.GET_TABLE_SIZE then
        args = qlua_msg.GetTableSize_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.GetTableSize_Result()
        result.rows, result.col = GetTableSize(args.t_id) -- TO-DO: pcall
      elseif request.type == qlua_msg.ProcedureType.GET_WINDOW_CAPTION then
        args = qlua_msg.GetWindowCaption_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.GetWindowCaption_Result()
        local caption = GetWindowCaption(args.t_id) -- TO-DO: pcall
        if caption ~= nil then result.caption = caption end
      elseif request.type == qlua_msg.ProcedureType.GET_WINDOW_RECT then
        args = qlua_msg.GetWindowRect_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.GetWindowRect_Result()
        result.top, result.left, result.bottom, result.right = GetWindowRect(args.t_id) -- TO-DO: pcall
        local top, left, bottom, right = GetWindowRect(args.t_id)
        message(top.."; "..left.."; "..bottom.."; "..right)
      elseif request.type == qlua_msg.ProcedureType.RGB then
        args = qlua_msg.RGB_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.RGB_Result()
        -- NB: на самом деле, библиотечная функция RGB должна называться BGR, ибо она выдаёт числа именно в этом формате. В SetColor, однако, тоже ожидается цвет в формате BGR, так что это не баг, а фича.
        result.result = RGB(args.red, args.green, args.blue) -- TO-DO: pcall
      elseif request.type == qlua_msg.ProcedureType.SET_COLOR then
        args = qlua_msg.SetColor_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.SetColor_Result()
        result.result = SetColor(args.t_id, args.row, args.col, args.b_color, args.f_color, args.sel_b_color, args.sel_f_color) -- TO-DO: pcall
      elseif request.type == qlua_msg.ProcedureType.HIGHLIGHT then
        args = qlua_msg.Highlight_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.Highlight_Result()
        result.result = Highlight(args.t_id, args.row, args.col, args.b_color, args.f_color, args.timeout) -- TO-DO: pcall
      elseif request.type == qlua_msg.ProcedureType.SET_SELECTED_ROW then
        args = qlua_msg.SetSelectedRow_Request()
        args:ParseFromString(request.args)
        result = qlua_msg.SetSelectedRow_Result()
        result.result = SetSelectedRow(args.table_id, args.row) -- TO-DO: pcall
			else
				assert(false, "Unknown request\n") -- TO-DO
			end
	  
      response.token = request.token
      response.type = request.type
      if result ~= nil and not response.is_error then
        
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
  
  for uuid, ds in pairs(self.datasources) do
    ds:Close()
  end
end

return Worker
