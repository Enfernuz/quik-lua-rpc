local qlua_msg = require("qlua/proto/qlua_msg_pb")
assert(qlua_msg ~= nil, "qlua/proto/qlua_msg_pb lib is missing")

local utils = require("qlua_msg_utils")
assert(utils ~= nil, "utils lib is missing.")

local function require_request_args_not_nil(request_args) 
  if request_args == nil then error("The request has no args.") end
end

local RequestHandler = {
  datasources = {}
}

local request_handlers = {}

function RequestHandler:get_datasource(datasource_uuid) 
  local ds = self.datasources[datasource_uuid]
  if ds == nil then error( string.format("There is no datasource with uuid '%s'.", datasource_uuid) ) end
  return ds
end

function RequestHandler:handle(request)
  
  if request == nil then error("No request provided", 2) end
  if request.type == nil then error("The request has no type.", 2) end
  if type(request.type) ~= 'number' then error("The type of request must be an integer number.", 2) end

  local f_handler = request_handlers[request.type]
  local ok, result
  if f_handler == nil then 
    ok = false 
    result = string.format("Unknown procedure type: %d.", request.type)
  else
    ok, result = pcall( function() return f_handler(request.args) end )
  end
  
  local response = qlua_msg.Qlua_Response()
  response.type = request.type
  
  if ok then 
    if result ~= nil then
      response.result = result:SerializeToString()
    end
  else
    response.is_error = true
    if result ~= nil then
      response.result = result
    end
  end
  
  return response
end
  
request_handlers[qlua_msg.ProcedureType.IS_CONNECTED] = function() 
  local result = qlua_msg.IsConnected_Result()
  result.is_connected = isConnected() -- TO-DO: pcall
  return result
end

request_handlers[qlua_msg.ProcedureType.GET_SCRIPT_PATH] = function() 
  local result = qlua_msg.GetScriptPath_Result()
  result.script_path = getScriptPath() -- TO-DO: pcall
end

request_handlers[qlua_msg.ProcedureType.GET_INFO_PARAM] = function(request_args)
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetInfoParam_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.GetInfoParam_Result()
  result.info_param = getInfoParam(args.param_name) -- TO-DO: pcall
  return result
end

request_handlers[qlua_msg.ProcedureType.MESSAGE] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.Message_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.Message_Result()
  result.result = (args.icon_type == nil and message(args.message) or message(args.message, args.icon_type)) -- TO-DO: pcall
  return result
end

request_handlers[qlua_msg.ProcedureType.SLEEP] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.Sleep_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.Sleep_Result()
  result.result = sleep(args.time) -- TO-DO: pcall
  return result
end

request_handlers[qlua_msg.ProcedureType.GET_WORKING_FOLDER] = function() 
  local result = qlua_msg.GetWorkingFolder_Result()
  result.working_folder = getWorkingFolder() -- TO-DO: pcall
  return result
end

request_handlers[qlua_msg.ProcedureType.PRINT_DBG_STR] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.PrintDbgStr_Request()
  args:ParseFromString(request_args)
  PrintDbgStr(args.s) -- TO-DO: pcall
  return nil
end

request_handlers[qlua_msg.ProcedureType.GET_ITEM] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetItem_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.GetItem_Result()
  local t = getItem(args.table_name, args.index) -- TO-DO: pcall
  utils.put_to_string_string_pb_map(t, result.table_row, qlua_msg.GetItem_Result.TableRowEntry)
  return result
end

request_handlers[qlua_msg.ProcedureType.GET_ORDER_BY_NUMBER] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetOrderByNumber_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.GetOrderByNumber_Result()
  local t, i = getOrderByNumber(args.class_code, args.order_id)
  utils.insert_table(result.order, t)
  result.indx = i
  return result
end

request_handlers[qlua_msg.ProcedureType.GET_NUMBER_OF] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetNumberOf_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.GetNumberOf_Result()
  result.result = getNumberOf(args.table_name) -- TO-DO: pcall
  return result
end

request_handlers[qlua_msg.ProcedureType.SEARCH_ITEMS] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.SearchItems_Request()
  args:ParseFromString(request_args)

  local fn_ctr, error_msg = loadstring("return "..args.fn_def)
  local items
  if fn_ctr == nil then 
    error( string.format("Could not parse a function definition from the given string. Error message: \n%s", error_msg) )
  else
    if args.params == nil or args.params == "" then
      items = SearchItems(args.table_name, args.start_index, args.end_index == 0 and (getNumberOf(args.table_name) - 1) or args.end_index, fn_ctr()) -- TO-DO: pcall
    else 
      items = SearchItems(args.table_name, args.start_index, args.end_index == 0 and (getNumberOf(args.table_name) - 1) or args.end_index, fn_ctr(), args.params) -- TO-DO: pcall
    end
  end
  
  local result = qlua_msg.SearchItems_Result()
  if items ~= nil then 
    for i, item_index in ipairs(items) do
      table.sinsert(result.items_indices, item_index)
    end
  end
  
  return result
end

request_handlers[qlua_msg.ProcedureType.GET_CLASSES_LIST] = function() 
  local result = qlua_msg.GetClassesList_Result()
  result.classes_list = getClassesList() -- TO-DO: pcall
  return result
end

request_handlers[qlua_msg.ProcedureType.GET_CLASS_INFO] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetClassInfo_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.GetClassInfo_Result()
  local t = getClassInfo(args.class_code) -- TO-DO: pcall
  utils.put_to_string_string_pb_map(t, result.class_info, qlua_msg.GetClassInfo_Result.ClassInfoEntry)
  return result
end

request_handlers[qlua_msg.ProcedureType.GET_CLASS_SECURITIES] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetClassSecurities_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.GetClassSecurities_Result()
  result.class_securities = getClassSecurities(args.class_code) -- TO-DO: pcall
  return result
end

request_handlers[qlua_msg.ProcedureType.GET_MONEY] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetMoney_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.GetMoney_Result()
  local t = getMoney(args.client_code, args.firmid, args.tag, args.currcode) -- TO-DO: pcall
  utils.put_to_string_string_pb_map(t, result.money, qlua_msg.GetMoney_Result.MoneyEntry)
  return result
end

request_handlers[qlua_msg.ProcedureType.GET_MONEY_EX] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetMoneyEx_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.GetMoneyEx_Result()
  local t = getMoneyEx(args.firmid, args.client_code, args.tag, args.currcode, args.limit_kind) -- TO-DO: pcall
  utils.put_to_string_string_pb_map(t, result.money_ex, qlua_msg.GetMoneyEx_Result.MoneyExEntry)
  return result
end

request_handlers[qlua_msg.ProcedureType.GET_DEPO] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetDepo_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.GetDepo_Result()
  local t = getDepo(args.client_code, args.firmid, args.sec_code, args.trdaccid) -- TO-DO: pcall
  utils.put_to_string_string_pb_map(t, result.depo, qlua_msg.GetDepo_Result.DepoEntry)
  return result
end

request_handlers[qlua_msg.ProcedureType.GET_DEPO_EX] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetDepoEx_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.GetDepoEx_Result()
  local t = getDepoEx(args.firmid, args.client_code, args.sec_code, args.trdaccid, args.limit_kind) -- TO-DO: pcall
  utils.put_to_string_string_pb_map(t, result.depo_ex, qlua_msg.GetDepoEx_Result.DepoExEntry)
  return result
end

request_handlers[qlua_msg.ProcedureType.GET_FUTURES_LIMIT] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetFuturesLimit_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.GetFuturesLimit_Result()
  local t = getFuturesLimit(args.firmid, args.trdaccid, args.limit_type, args.currcode) -- TO-DO: pcall
  utils.put_to_string_string_pb_map(t, result.futures_limit, qlua_msg.GetFuturesLimit_Result.FuturesLimitEntry)
  return result
end

request_handlers[qlua_msg.ProcedureType.GET_FUTURES_HOLDING] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetFuturesHolding_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.GetFuturesHolding_Result()
  local t = getFuturesLHolding(args.firmid, args.trdaccid, args.sec_code, args.type) -- TO-DO: pcall
  utils.put_to_string_string_pb_map(t, result.futures_holding, qlua_msg.GetFuturesHolding_Result.FuturesHoldingEntry)
  return result
end

request_handlers[qlua_msg.ProcedureType.GET_SECURITY_INFO] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetSecurityInfo_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.GetSecurityInfo_Result()
  local t = getSecurityInfo(args.class_code, args.sec_code) -- TO-DO: pcall
  utils.put_to_string_string_pb_map(t, result.security_info, qlua_msg.GetSecurityInfo_Result.SecurityInfoEntry)
  return result
end

request_handlers[qlua_msg.ProcedureType.GET_TRADE_DATE] = function() 
  local result = qlua_msg.GetTradeDate_Result()
  local t = getTradeDate() -- TO-DO: pcall
  utils.put_to_string_string_pb_map(t, result.trade_date, qlua_msg.GetTradeDate_Result.TradeDateEntry)
  return result
end

request_handlers[qlua_msg.ProcedureType.GET_QUOTE_LEVEL2] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetQuoteLevel2_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.GetQuoteLevel2_Result()
  local t = getQuoteLevel2(args.class_code, args.sec_code) -- TO-DO: pcall
  result.bid_count = t.bid_count
  result.offer_count = t.offer_count
  if t.bid ~= nil then utils.insert_quote_table(result.bid, t.bid) end
  if t.offer ~= nil then utils.insert_quote_table(result.offer, t.offer) end
  return result
end

request_handlers[qlua_msg.ProcedureType.GET_LINES_COUNT] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetLinesCount_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.GetLinesCount_Result()
  result.lines_count = getLinesCount(args.tag) -- TO-DO: pcall
  return result
end

request_handlers[qlua_msg.ProcedureType.GET_NUM_CANDLES] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetNumCandles_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.GetNumCandles_Result()
  result.num_candles = getNumCandles(args.tag) -- TO-DO: pcall
  return result
end

request_handlers[qlua_msg.ProcedureType.GET_CANDLES_BY_INDEX] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetCandlesByIndex_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.GetCandlesByIndex_Result()
  local t, n, l = getCandlesByIndex(args.tag, args.line, args.first_candle, args.count) -- TO-DO: pcall
  result.n = n
  result.l = l
  utils.insert_candles_table(result.t, t)
  return result
end

request_handlers[qlua_msg.ProcedureType.CREATE_DATA_SOURCE] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.CreateDataSource_Request()
  args:ParseFromString(request_args)
  local interval = utils.to_interval(args.interval) -- TO-DO: pcall
  
  local ds, error_desc
  if args.param == nil or args.param == "" then
    ds, error_desc = CreateDataSource(args.class_code, args.sec_code, interval)
  else 
    ds, error_desc = CreateDataSource(args.class_code, args.sec_code, interval, args.param)
  end
  
  if ds == nil then
    error(error_desc)
  else
    local result = qlua_msg.CreateDataSource_Result()
    result.datasource_uuid = uuid()
    RequestHandler.datasources[result.datasource_uuid] = ds
    return result
  end
end

request_handlers[qlua_msg.ProcedureType.DS_SET_UPDATE_CALLBACK] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.DataSourceSetUpdateCallback_Request()
  args:ParseFromString(request_args)
  
  local ds = RequestHandler:get_datasource(args.datasource_uuid)
  
  local f_cb_ctr, error_msg = loadstring("return "..args.f_cb_def)
  if f_cb_ctr == nil then 
    error( string.format("Could not parse a function definition from the given string. Error message: '%s'.", error_msg) )
  else
    local f_cb = f_cb_ctr()
    local callback = function (index) f_cb(index, ds) end
    local result = qlua_msg.DataSourceSetUpdateCallback_Result()
    result.result = ds:SetUpdateCallback(callback) -- TO-DO: pcall
    return result
  end
end

request_handlers[qlua_msg.ProcedureType.DS_O] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.DataSourceO_Request()
  args:ParseFromString(request_args)
 
  local ds = RequestHandler:get_datasource(args.datasource_uuid)
  
  local result = qlua_msg.DataSourceO_Result()
  result.value = ds:O(args.candle_index)
  return result
end

request_handlers[qlua_msg.ProcedureType.DS_H] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.DataSourceH_Request()
  args:ParseFromString(request_args)
 
  local ds = RequestHandler:get_datasource(args.datasource_uuid)
  
  local result = qlua_msg.DataSourceH_Result()
  result.value = ds:H(args.candle_index)
  return result
end

request_handlers[qlua_msg.ProcedureType.DS_L] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.DataSourceL_Request()
  args:ParseFromString(request_args)
 
  local ds = RequestHandler:get_datasource(args.datasource_uuid)
  
  local result = qlua_msg.DataSourceL_Result()
  result.value = ds:L(args.candle_index)
  return result
end

request_handlers[qlua_msg.ProcedureType.DS_C] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.DataSourceC_Request()
  args:ParseFromString(request_args)
 
  local ds = RequestHandler:get_datasource(args.datasource_uuid)
  
  local result = qlua_msg.DataSourceC_Result()
  result.value = ds:C(args.candle_index)
  return result
end

request_handlers[qlua_msg.ProcedureType.DS_V] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.DataSourceV_Request()
  args:ParseFromString(request_args)
 
  local ds = RequestHandler:get_datasource(args.datasource_uuid)
  
  local result = qlua_msg.DataSourceV_Result()
  result.value = ds:V(args.candle_index)
  return result
end

request_handlers[qlua_msg.ProcedureType.DS_T] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.DataSourceT_Request()
  args:ParseFromString(request_args)
  
  local ds = RequestHandler:get_datasource(args.datasource_uuid)
  
  local result = qlua_msg.DataSourceT_Result()
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
  return result
end

request_handlers[qlua_msg.ProcedureType.DS_SIZE] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.DataSourceSize_Request()
  args:ParseFromString(request_args)
  
  local ds = RequestHandler:get_datasource(args.datasource_uuid)

  local result = qlua_msg.DataSourceSize_Result()
  result.value = ds:Size(args.candle_index)
  return result
end

request_handlers[qlua_msg.ProcedureType.DS_CLOSE] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.DataSourceClose_Request()
  args:ParseFromString(request_args)
  
  local ds = RequestHandler:get_datasource(args.datasource_uuid)
  
  local result = qlua_msg.DataSourceClose_Result()
  result.result = ds:Close()
  return result
end

request_handlers[qlua_msg.ProcedureType.DS_SET_EMPTY_CALLBACK] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.DataSourceSetEmptyCallback_Request()
  args:ParseFromString(request_args)
  
  local ds = RequestHandler:get_datasource(args.datasource_uuid)
  
  local result = qlua_msg.DataSourceSetEmptyCallback_Result()
  result.result = ds:SetEmptyCallback()
  return result
end

request_handlers[qlua_msg.ProcedureType.SEND_TRANSACTION] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.SendTransaction_Request()
  args:ParseFromString(request_args)
  local t = utils.create_table(args.transaction)
  local result = qlua_msg.SendTransaction_Result()
  result.result = sendTransaction(t) -- TO-DO: pcall
  return result
end

request_handlers[qlua_msg.ProcedureType.CALC_BUY_SELL] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.CalcBuySell_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.CalcBuySell_Result()
  result.qty, result.comission = CalcBuySell(args.class_code, args.sec_code, args.client_code, args.account, args.price, args.is_buy, args.is_market)
  return result
end

request_handlers[qlua_msg.ProcedureType.GET_PARAM_EX] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetParamEx_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.GetParamEx_Result()
  local t = getParamEx(args.class_code, args.sec_code, args.param_name) -- TO-DO: pcall
  utils.put_to_string_string_pb_map(t, result.param_ex, qlua_msg.GetParamEx_Result.ParamExEntry)
  return result
end

request_handlers[qlua_msg.ProcedureType.GET_PARAM_EX_2] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetParamEx_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.GetParamEx_Result()
  local t = getParamEx2(args.class_code, args.sec_code, args.param_name) -- TO-DO: pcall
  utils.put_to_string_string_pb_map(t, result.param_ex, qlua_msg.GetParamEx_Result.ParamExEntry)
  return result
end

request_handlers[qlua_msg.ProcedureType.GET_PORTFOLIO_INFO] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetPortfolioInfo_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.GetPortfolioInfo_Result()
  local t = getPortfolioInfo(args.firm_id, args.client_code) -- TO-DO: pcall
  utils.put_to_string_string_pb_map(t, result.portfolio_info, qlua_msg.GetPortfolioInfo_Result.PortfolioInfoEntry)
  return result
end

request_handlers[qlua_msg.ProcedureType.GET_PORTFOLIO_INFO] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetPortfolioInfoEx_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.GetPortfolioInfoEx_Result()
  local t = getPortfolioInfoEx(args.firm_id, args.client_code, args.limit_kind) -- TO-DO: pcall
  utils.put_to_string_string_pb_map(t, result.portfolio_info_ex, qlua_msg.GetPortfolioInfoEx_Result.PortfolioInfoExEntry)
  return result
end

request_handlers[qlua_msg.ProcedureType.GET_BUY_SELL_INFO] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetBuySellInfo_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.GetBuySellInfo_Result()
  local t = getBuySellInfo(args.firm_id, args.client_code, args.class_code, args.sec_code, args.price) -- TO-DO: pcall
  utils.put_to_string_string_pb_map(t, result.buy_sell_info, qlua_msg.GetBuySellInfo_Result.BuySellInfoEntry)
  return result
end

request_handlers[qlua_msg.ProcedureType.GET_BUY_SELL_INFO_EX] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetBuySellInfo_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.GetBuySellInfo_Result()
  local t = getBuySellInfoEx(args.firm_id, args.client_code, args.class_code, args.sec_code, args.price) -- TO-DO: pcall
  utils.put_to_string_string_pb_map(t, result.buy_sell_info, qlua_msg.GetBuySellInfo_Result.BuySellInfoEntry)
  return result
end

request_handlers[qlua_msg.ProcedureType.ADD_COLUMN] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.AddColumn_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.AddColumn_Result()
  result.result = AddColumn(args.t_id, args.icode, args.name, args.is_default, utils.to_qtable_parameter_type(args.par_type), args.width) -- TO-DO: pcall
  return result
end

request_handlers[qlua_msg.ProcedureType.ALLOC_TABLE] = function() 
  local result = qlua_msg.AllocTable_Result()
  result.t_id = AllocTable() -- TO-DO: pcall
  return result
end

request_handlers[qlua_msg.ProcedureType.CLEAR] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.Clear_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.Clear_Result()
  result.result = Clear(args.t_id) -- TO-DO: pcall
  return result
end

request_handlers[qlua_msg.ProcedureType.CREATE_WINDOW] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.CreateWindow_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.CreateWindow_Result()
  result.result = CreateWindow(args.t_id) -- TO-DO: pcall
  return result
end

request_handlers[qlua_msg.ProcedureType.DELETE_ROW] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.DeleteRow_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.DeleteRow_Result()
  result.result = DeleteRow(args.t_id, args.key) -- TO-DO: pcall
  return result
end

request_handlers[qlua_msg.ProcedureType.DESTROY_TABLE] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.DestroyTable_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.DestroyTable_Result()
  result.result = DestroyTable(args.t_id) -- TO-DO: pcall
  return result
end

request_handlers[qlua_msg.ProcedureType.INSERT_ROW] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.InsertRow_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.InsertRow_Result()
  result.result = InsertRow(args.t_id, args.key) -- TO-DO: pcall
  return result
end

request_handlers[qlua_msg.ProcedureType.IS_WINDOW_CLOSED] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.IsWindowClosed_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.IsWindowClosed_Result()
  result.result = IsWindowClosed(args.t_id) -- TO-DO: pcall
  return result
end

request_handlers[qlua_msg.ProcedureType.GET_CELL] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetCell_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.GetCell_Result()
  local t_cell = GetCell(args.t_id, args.key, args.code) -- TO-DO: pcall
  result.image = t_cell.image
  if t_cell.value ~= nil then result.value = tostring(t_cell.value) end
  return result
end

request_handlers[qlua_msg.ProcedureType.SET_CELL] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.SetCell_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.SetCell_Result()
  if args.value == "" or args.value == nil then
    result.result = SetCell(args.t_id, args.key, args.code, args.text)
  else
    local value = tonumber(args.value) -- TO-DO: error check
    result.result = SetCell(args.t_id, args.key, args.code, args.text, value) -- TO-DO: pcall
  end
  return result
end

request_handlers[qlua_msg.ProcedureType.SET_WINDOW_CAPTION] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.SetWindowCaption_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.SetWindowCaption_Result()
  result.result = SetWindowCaption(args.t_id, args.str) -- TO-DO: pcall
  return result
end

request_handlers[qlua_msg.ProcedureType.SET_WINDOW_POS] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.SetWindowPos_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.SetWindowPos_Result()
  result.result = SetWindowPos(args.t_id, args.x, args.y, args.dx, args.dy) -- TO-DO: pcall
  return result
end

request_handlers[qlua_msg.ProcedureType.SET_TABLE_NOTIFICATION_CALLBACK] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.SetTableNotificationCallback_Request()
  args:ParseFromString(request_args)
        
  local f_cb_ctr, error_msg = loadstring("return "..args.f_cb_def)
  if f_cb_ctr == nil then 
   error( string.format("Could not parse a function definition from the given string. Error message: '%s'.", error_msg) )
  else
    local result = qlua_msg.SetTableNotificationCallback_Result()
    result.result = SetTableNotificationCallback(args.t_id, f_cb_ctr()) -- TO-DO: pcall
    return result
  end
end

request_handlers[qlua_msg.ProcedureType.GET_TABLE_SIZE] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetTableSize_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.GetTableSize_Result()
  result.rows, result.col = GetTableSize(args.t_id) -- TO-DO: pcall
  return result
end

request_handlers[qlua_msg.ProcedureType.GET_WINDOW_CAPTION] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetWindowCaption_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.GetWindowCaption_Result()
  local caption = GetWindowCaption(args.t_id) -- TO-DO: pcall
  if caption ~= nil then result.caption = caption end
  return result
end

request_handlers[qlua_msg.ProcedureType.GET_WINDOW_RECT] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetWindowRect_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.GetWindowRect_Result()
  result.top, result.left, result.bottom, result.right = GetWindowRect(args.t_id) -- TO-DO: pcall
  return result
end

request_handlers[qlua_msg.ProcedureType.RGB] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.RGB_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.RGB_Result()
  -- NB: на самом деле, библиотечная функция RGB должна называться BGR, ибо она выдаёт числа именно в этом формате. В SetColor, однако, тоже ожидается цвет в формате BGR, так что это не баг, а фича.
  result.result = RGB(args.red, args.green, args.blue) -- TO-DO: pcall
  return result
end

request_handlers[qlua_msg.ProcedureType.SET_COLOR] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.SetColor_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.SetColor_Result()
  result.result = SetColor(args.t_id, args.row, args.col, args.b_color, args.f_color, args.sel_b_color, args.sel_f_color) -- TO-DO: pcall
  return result
end

request_handlers[qlua_msg.ProcedureType.HIGHLIGHT] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.Highlight_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.Highlight_Result()
  result.result = Highlight(args.t_id, args.row, args.col, args.b_color, args.f_color, args.timeout) -- TO-DO: pcall
  return result
end

request_handlers[qlua_msg.ProcedureType.SET_SELECTED_ROW] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.SetSelectedRow_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.SetSelectedRow_Result()
  result.result = SetSelectedRow(args.table_id, args.row) -- TO-DO: pcall
  return result
end

return RequestHandler