local qlua_msg = require("quik-lua-rpc.messages.qlua_msg_pb")
assert(qlua_msg ~= nil, "quik-lua-rpc.messages.qlua_msg_pb lib is missing")

local utils = require("quik-lua-rpc.utils.utils")
assert(utils ~= nil, "quik-lua-rpc.utils.utils lib is missing.")

local inspect = require("inspect")
assert(inspect ~= nil, "inspect lib is missing.")

local bit = bit
assert(bit ~= nil, "bit lib is missing.")

local unpack = unpack
assert(unpack ~= nil, "unpack function is missing.")

local function require_request_args_not_nil(request_args) 
  if request_args == nil then error("Запрос не содержит аргументов.", 0) end
end

local RequestHandler = {
  datasources = {}
}

local request_handlers = {}

function RequestHandler:get_datasource(datasource_uuid) 
  local ds = self.datasources[datasource_uuid]
  if ds == nil then error(string.format("Не найдено data source с uuid '%s'.", datasource_uuid), 0) end
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
  result.is_connected = isConnected()
  return result
end

request_handlers[qlua_msg.ProcedureType.GET_SCRIPT_PATH] = function() 
  local result = qlua_msg.GetScriptPath_Result()
  result.script_path = getScriptPath()
end

request_handlers[qlua_msg.ProcedureType.GET_INFO_PARAM] = function(request_args)
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetInfoParam_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.GetInfoParam_Result()
  result.info_param = getInfoParam(args.param_name)
  return result
end

request_handlers[qlua_msg.ProcedureType.MESSAGE] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.Message_Request()
  args:ParseFromString(request_args)
  
  local ret = (args.icon_type == qlua_msg.MessageIconType.ICON_TYPE_UNDEFINED and message(args.message) or message(args.message, args.icon_type))
  if ret == nil then
    if args.icon_type == qlua_msg.MessageIconType.ICON_TYPE_UNDEFINED then 
      error(string.format("Процедура message(%s) возвратила nil.", args.message), 0)
    else
      error(string.format("Процедура message(%s, %d) возвратила nil.", args.message, args.icon_type), 0)
    end
  else
    local result = qlua_msg.Message_Result()
    result.result = ret
    return result
  end
end

request_handlers[qlua_msg.ProcedureType.SLEEP] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.Sleep_Request()
  args:ParseFromString(request_args)
  
  local ret = sleep(args.time) -- TO-DO: pcall
  if ret == nil then
    error(string.format("Процедура sleep(%d) возвратила nil.", args.time), 0)
  else
    local result = qlua_msg.Sleep_Result()
    result.result = ret
    return result
  end
end

request_handlers[qlua_msg.ProcedureType.GET_WORKING_FOLDER] = function() 
  local result = qlua_msg.GetWorkingFolder_Result()
  result.working_folder = getWorkingFolder()
  return result
end

request_handlers[qlua_msg.ProcedureType.PRINT_DBG_STR] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.PrintDbgStr_Request()
  args:ParseFromString(request_args)
  PrintDbgStr(args.s)
  return nil
end

request_handlers[qlua_msg.ProcedureType.GET_ITEM] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetItem_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.GetItem_Result()
  local t = getItem(args.table_name, args.index)
  if t ~= nil then
    utils.put_to_string_string_pb_map(t, result.table_row, qlua_msg.GetItem_Result.TableRowEntry)
  end
  return result
end

request_handlers[qlua_msg.ProcedureType.GET_ORDER_BY_NUMBER] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetOrderByNumber_Request()
  args:ParseFromString(request_args)
  
  local t, i = getOrderByNumber(args.class_code, args.order_id)
  if t == nil then
    error(string.format("Процедура getOrderByNumber(%s, %d) вернула (nil, nil).", args.class_code, args.order_id), 0)
  else
    local result = qlua_msg.GetOrderByNumber_Result()
    utils.insert_table(result.order, t)
    result.indx = i
    return result
  end
end

request_handlers[qlua_msg.ProcedureType.GET_NUMBER_OF] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetNumberOf_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.GetNumberOf_Result()
  result.result = getNumberOf(args.table_name) -- returns -1 in case of error
  return result
end

request_handlers[qlua_msg.ProcedureType.SEARCH_ITEMS] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.SearchItems_Request()
  args:ParseFromString(request_args)

  local fn_ctr, error_msg = loadstring("return "..args.fn_def)
  local items
  if fn_ctr == nil then 
    error(string.format("Не удалось распарсить определение функции из переданной строки. Описание ошибки: [%s].", error_msg), 0)
  else
    if args.params == nil or args.params == "" then
      items = SearchItems(args.table_name, args.start_index, args.end_index == 0 and (getNumberOf(args.table_name) - 1) or args.end_index, fn_ctr()) -- returns nil in case of empty list found or error
    else 
      items = SearchItems(args.table_name, args.start_index, args.end_index == 0 and (getNumberOf(args.table_name) - 1) or args.end_index, fn_ctr(), args.params) -- returns nil in case of empty list found or error
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
  result.classes_list = getClassesList()
  return result
end

request_handlers[qlua_msg.ProcedureType.GET_CLASS_INFO] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetClassInfo_Request()
  args:ParseFromString(request_args)
  
  local t = getClassInfo(args.class_code)
  if t == nil then
    error(string.format("Процедура getClassInfo(%s) вернула nil.", args.class_code), 0)
  else
    local result = qlua_msg.GetClassInfo_Result()
    utils.put_to_string_string_pb_map(t, result.class_info, qlua_msg.GetClassInfo_Result.ClassInfoEntry)
    return result
  end
end

request_handlers[qlua_msg.ProcedureType.GET_CLASS_SECURITIES] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetClassSecurities_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.GetClassSecurities_Result()
  local ret = getClassSecurities(args.class_code) -- returns an empty string if no securities found for the given class_code
  if ret ~= nil then result.class_securities = ret end
  return result
end

request_handlers[qlua_msg.ProcedureType.GET_MONEY] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetMoney_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.GetMoney_Result()
  local t = getMoney(args.client_code, args.firmid, args.tag, args.currcode) -- returns a table with zero'ed values if no info found or in case of an error
  if t ~= nil then
    utils.put_to_string_string_pb_map(t, result.money, qlua_msg.GetMoney_Result.MoneyEntry)
  end
  return result
end

request_handlers[qlua_msg.ProcedureType.GET_MONEY_EX] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetMoneyEx_Request()
  args:ParseFromString(request_args)
  
  local t = getMoneyEx(args.firmid, args.client_code, args.tag, args.currcode, args.limit_kind) -- returns nil if no info found or in case of an error
  if t == nil then 
    error(string.format("Процедура getMoneyEx(%s, %s, %s, %s, %d) возвратила nil.", args.firmid, args.client_code, args.tag, args.currcode, args.limit_kind), 0)
  else
    local result = qlua_msg.GetMoneyEx_Result()
    utils.put_to_string_string_pb_map(t, result.money_ex, qlua_msg.GetMoneyEx_Result.MoneyExEntry)
    return result
  end
end

request_handlers[qlua_msg.ProcedureType.GET_DEPO] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetDepo_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.GetDepo_Result()
  local t = getDepo(args.client_code, args.firmid, args.sec_code, args.trdaccid) -- returns a table with zero'ed values if no info found or in case of an error
  if t ~= nil then
    utils.put_to_string_string_pb_map(t, result.depo, qlua_msg.GetDepo_Result.DepoEntry)
  end
  return result
end

request_handlers[qlua_msg.ProcedureType.GET_DEPO_EX] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetDepoEx_Request()
  args:ParseFromString(request_args)
  
  local t = getDepoEx(args.firmid, args.client_code, args.sec_code, args.trdaccid, args.limit_kind) -- returns nil if no info found or in case of an error
  if t == nil then
    error(string.format("Процедура getDepoEx(%s, %s, %s, %s, %d) возвратила nil.", args.firmid, args.client_code, args.sec_code, args.trdaccid, args.limit_kind), 0)
  else
    local result = qlua_msg.GetDepoEx_Result()
    utils.put_to_string_string_pb_map(t, result.depo_ex, qlua_msg.GetDepoEx_Result.DepoExEntry)
    return result
  end
end

request_handlers[qlua_msg.ProcedureType.GET_FUTURES_LIMIT] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetFuturesLimit_Request()
  args:ParseFromString(request_args)
  
  local t = getFuturesLimit(args.firmid, args.trdaccid, args.limit_type, args.currcode) -- returns nil if no info found or in case of an error
  if t == nil then
    error(string.format("Процедура getFuturesLimit(%s, %s, %d, %s) возвратила nil.", args.firmid, args.trdaccid, args.limit_type, args.currcode), 0)
  else
    local result = qlua_msg.GetFuturesLimit_Result()
    utils.put_to_string_string_pb_map(t, result.futures_limit, qlua_msg.GetFuturesLimit_Result.FuturesLimitEntry)
    return result
  end
end

request_handlers[qlua_msg.ProcedureType.GET_FUTURES_HOLDING] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetFuturesHolding_Request()
  args:ParseFromString(request_args)
  
  local t = getFuturesHolding(args.firmid, args.trdaccid, args.sec_code, args.type) -- returns nil if no info found or in case of an error
  if t == nil then
    error(string.format("Процедура getFuturesLHolding(%s, %s, %d, %d) возвратила nil.", args.firmid, args.trdaccid, args.sec_code, args.type), 0)
  else
    local result = qlua_msg.GetFuturesHolding_Result()
    utils.put_to_string_string_pb_map(t, result.futures_holding, qlua_msg.GetFuturesHolding_Result.FuturesHoldingEntry)
    return result
  end
end

request_handlers[qlua_msg.ProcedureType.GET_SECURITY_INFO] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetSecurityInfo_Request()
  args:ParseFromString(request_args)
  
  local t = getSecurityInfo(args.class_code, args.sec_code) -- returns nil if no info found or in case of an error
  if t == nil then
    error(string.format("Процедура getSecurityInfo(%s, %s) возвратила nil.", args.class_code, args.sec_code), 0)
  else
    local result = qlua_msg.GetSecurityInfo_Result()
    utils.put_to_string_string_pb_map(t, result.security_info, qlua_msg.GetSecurityInfo_Result.SecurityInfoEntry)
    return result
  end
end

request_handlers[qlua_msg.ProcedureType.GET_TRADE_DATE] = function() 
  local result = qlua_msg.GetTradeDate_Result()
  local t = getTradeDate()
  utils.put_to_string_string_pb_map(t, result.trade_date, qlua_msg.GetTradeDate_Result.TradeDateEntry)
  return result
end

request_handlers[qlua_msg.ProcedureType.GET_QUOTE_LEVEL2] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetQuoteLevel2_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.GetQuoteLevel2_Result()
  local t = getQuoteLevel2(args.class_code, args.sec_code)
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
  result.lines_count = getLinesCount(args.tag) -- returns 0 if no chart with this tag found
  return result
end

request_handlers[qlua_msg.ProcedureType.GET_NUM_CANDLES] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetNumCandles_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.GetNumCandles_Result()
  result.num_candles = getNumCandles(args.tag) -- returns 0 if no chart with this tag found
  return result
end

request_handlers[qlua_msg.ProcedureType.GET_CANDLES_BY_INDEX] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetCandlesByIndex_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.GetCandlesByIndex_Result()
  local t, n, l = getCandlesByIndex(args.tag, args.line, args.first_candle, args.count) -- returns ({}, 0, "") if no info found or in case of error
  result.n = n
  result.l = l
  if t ~= nil then 
    utils.insert_candles_table(result.t, t)
  end
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
    if args.param == nil or args.param == "" then
      error(string.format("Процедура CreateDataSource(%s, %s, %d) возвратила nil и сообщение об ошибке: [%s].", args.class_code, args.sec_code, interval, error_desc), 0)
    else
      error(string.format("Процедура CreateDataSource(%s, %s, %d, %s) возвратила nil и сообщение об ошибке: [%s].", args.class_code, args.sec_code, interval, args.param, error_desc), 0)
    end
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
    error( string.format("Не удалось распарсить определение функции из переданной строки. Описание ошибки: [%s].", error_msg) )
  else
    local f_cb = f_cb_ctr()
    local callback = function (index) f_cb(index, ds) end
    local result = qlua_msg.DataSourceSetUpdateCallback_Result()
    result.result = ds:SetUpdateCallback(callback)
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
  result.result = sendTransaction(t) -- returns an empty string (seems to be always)
  return result
end

request_handlers[qlua_msg.ProcedureType.CALC_BUY_SELL] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.CalcBuySell_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.CalcBuySell_Result()
  result.qty, result.comission = CalcBuySell(args.class_code, args.sec_code, args.client_code, args.account, args.price, args.is_buy, args.is_market) -- returns (0; 0) in case of error
  return result
end

request_handlers[qlua_msg.ProcedureType.GET_PARAM_EX] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetParamEx_Request()
  args:ParseFromString(request_args)
  
  local t = getParamEx(args.class_code, args.sec_code, args.param_name) -- always returns a table
  if t == nil then
    error(string.format("Процедура getParamEx(%s, %s, %s) возвратила nil.", args.class_code, args.sec_code, args.param_name), 0)
  else
    local result = qlua_msg.GetParamEx_Result()
    utils.put_to_string_string_pb_map(t, result.param_ex, qlua_msg.GetParamEx_Result.ParamExEntry)
    return result
  end
end

request_handlers[qlua_msg.ProcedureType.GET_PARAM_EX_2] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetParamEx_Request()
  args:ParseFromString(request_args)
  
  local t = getParamEx2(args.class_code, args.sec_code, args.param_name) -- always returns a table
  if t == nil then
    error(string.format("Процедура getParamEx2(%s, %s, %s) возвратила nil.", args.class_code, args.sec_code, args.param_name), 0)
  else
    local result = qlua_msg.GetParamEx_Result()
    utils.put_to_string_string_pb_map(t, result.param_ex, qlua_msg.GetParamEx_Result.ParamExEntry)
    return result
  end
end

request_handlers[qlua_msg.ProcedureType.GET_PORTFOLIO_INFO] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetPortfolioInfo_Request()
  args:ParseFromString(request_args)
  
  local t = getPortfolioInfo(args.firm_id, args.client_code) -- returns {} in case of error
  if t == nil then
    error(string.format("Процедура getPortfolioInfo(%s, %s) возвратила nil.", args.firm_id, args.client_code), 0)
  else
    local result = qlua_msg.GetPortfolioInfo_Result()
    utils.put_to_string_string_pb_map(t, result.portfolio_info, qlua_msg.GetPortfolioInfo_Result.PortfolioInfoEntry)
    return result
  end
end

request_handlers[qlua_msg.ProcedureType.GET_PORTFOLIO_INFO_EX] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetPortfolioInfoEx_Request()
  args:ParseFromString(request_args)
  
  local t = getPortfolioInfoEx(args.firm_id, args.client_code, args.limit_kind) -- returns {} in case of error
  if t == nil then
    error(string.format("Процедура getPortfolioInfoEx(%s, %s, %d) возвратила nil.", args.firm_id, args.client_code, args.limit_kind), 0)
  else
    local result = qlua_msg.GetPortfolioInfoEx_Result()
    utils.put_to_string_string_pb_map(t, result.portfolio_info_ex, qlua_msg.GetPortfolioInfoEx_Result.PortfolioInfoExEntry)
    return result
  end
end

request_handlers[qlua_msg.ProcedureType.GET_BUY_SELL_INFO] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetBuySellInfo_Request()
  args:ParseFromString(request_args)
  
  local t = getBuySellInfo(args.firm_id, args.client_code, args.class_code, args.sec_code, args.price) -- returns {} in case of error
  if t == nil then
    error(string.format("Процедура getBuySellInfo(%s, %s, %s, %s, %d) возвратила nil.", args.firm_id, args.client_code, args.class_code, args.sec_code, args.price), 0)
  else
    local result = qlua_msg.GetBuySellInfo_Result()
    utils.put_to_string_string_pb_map(t, result.buy_sell_info, qlua_msg.GetBuySellInfo_Result.BuySellInfoEntry)
    return result
  end
end

request_handlers[qlua_msg.ProcedureType.GET_BUY_SELL_INFO_EX] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetBuySellInfo_Request()
  args:ParseFromString(request_args)
  
  local t = getBuySellInfoEx(args.firm_id, args.client_code, args.class_code, args.sec_code, args.price) -- returns {} in case of error
  if t == nil then
    error(string.format("Процедура getBuySellInfoEx(%s, %s, %s, %s, %d) возвратила nil.", args.firm_id, args.client_code, args.class_code, args.sec_code, args.price), 0)
  else
    local result = qlua_msg.GetBuySellInfo_Result()
    utils.put_to_string_string_pb_map(t, result.buy_sell_info, qlua_msg.GetBuySellInfo_Result.BuySellInfoEntry)
    return result
  end
end

request_handlers[qlua_msg.ProcedureType.ADD_COLUMN] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.AddColumn_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.AddColumn_Result()
  result.result = AddColumn(args.t_id, args.icode, args.name, args.is_default, utils.to_qtable_parameter_type(args.par_type), args.width) -- returns 0 or 1
  return result
end

request_handlers[qlua_msg.ProcedureType.ALLOC_TABLE] = function() 
  local result = qlua_msg.AllocTable_Result()
  result.t_id = AllocTable() -- returns a number
  return result
end

request_handlers[qlua_msg.ProcedureType.CLEAR] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.Clear_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.Clear_Result()
  result.result = Clear(args.t_id) -- returns true or false
  return result
end

request_handlers[qlua_msg.ProcedureType.CREATE_WINDOW] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.CreateWindow_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.CreateWindow_Result()
  result.result = CreateWindow(args.t_id) -- returns 0 or 1
  return result
end

request_handlers[qlua_msg.ProcedureType.DELETE_ROW] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.DeleteRow_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.DeleteRow_Result()
  result.result = DeleteRow(args.t_id, args.key) -- returns true or false
  return result
end

request_handlers[qlua_msg.ProcedureType.DESTROY_TABLE] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.DestroyTable_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.DestroyTable_Result()
  result.result = DestroyTable(args.t_id) -- returns true or false
  return result
end

request_handlers[qlua_msg.ProcedureType.INSERT_ROW] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.InsertRow_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.InsertRow_Result()
  result.result = InsertRow(args.t_id, args.key) -- returns a number
  return result
end

request_handlers[qlua_msg.ProcedureType.IS_WINDOW_CLOSED] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.IsWindowClosed_Request()
  args:ParseFromString(request_args)
  
  local ret = IsWindowClosed(args.t_id) -- returns nil in case of error
  if ret == nil then
    error(string.format("Процедура IsWindowClosed(%s) вернула nil.", args.t_id), 0)
  else
    local result = qlua_msg.IsWindowClosed_Result()
    result.result = ret
    return result
  end
end

request_handlers[qlua_msg.ProcedureType.GET_CELL] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetCell_Request()
  args:ParseFromString(request_args)
  
  local t_cell = GetCell(args.t_id, args.key, args.code) -- returns nil in case of error
  if t_cell == nil then
    error(string.format("Процедура GetCell(%s, %s, %s) вернула nil.", args.t_id, args.key, args.code), 0)
  else
    local result = qlua_msg.GetCell_Result()
    result.image = t_cell.image
    if t_cell.value ~= nil then result.value = tostring(t_cell.value) end
    return result
  end
end

request_handlers[qlua_msg.ProcedureType.SET_CELL] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.SetCell_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.SetCell_Result()
  if args.value == "" or args.value == nil then
    result.result = SetCell(args.t_id, args.key, args.code, args.text) -- returns true or false
  else
    local ok, value = pcall(function() return tonumber(args.value) end)
    if ok then
      result.result = SetCell(args.t_id, args.key, args.code, args.text, value) -- returns true or false
    else
      error(string.format("Не удалось преобразовать value='%s' в число.", args.value), 0)
    end
  end
  return result
end

request_handlers[qlua_msg.ProcedureType.SET_WINDOW_CAPTION] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.SetWindowCaption_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.SetWindowCaption_Result()
  result.result = SetWindowCaption(args.t_id, args.str) -- returns true or false
  return result
end

request_handlers[qlua_msg.ProcedureType.SET_WINDOW_POS] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.SetWindowPos_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.SetWindowPos_Result()
  result.result = SetWindowPos(args.t_id, args.x, args.y, args.dx, args.dy) -- returns true or false
  return result
end

request_handlers[qlua_msg.ProcedureType.SET_TABLE_NOTIFICATION_CALLBACK] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.SetTableNotificationCallback_Request()
  args:ParseFromString(request_args)
        
  local f_cb_ctr, error_msg = loadstring("return "..args.f_cb_def)
  if f_cb_ctr == nil then 
   error(string.format("Не удалось распарсить определение функции из переданной строки. Описание ошибки: [%s].", error_msg), 0)
  else
    local result = qlua_msg.SetTableNotificationCallback_Result()
    result.result = SetTableNotificationCallback(args.t_id, f_cb_ctr()) -- returns 0 or 1
    return result
  end
end

request_handlers[qlua_msg.ProcedureType.GET_TABLE_SIZE] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetTableSize_Request()
  args:ParseFromString(request_args)
  
  local rows, col = GetTableSize(args.t_id) -- returns nil in case of error
  if rows == nil or col == nil then
    error(string.format("Процедура GetTableSize(%s) вернула nil.", args.t_id), 0)
  else
    local result = qlua_msg.GetTableSize_Result()
    result.rows = rows
    result.col = col
    return result
  end
end

request_handlers[qlua_msg.ProcedureType.GET_WINDOW_CAPTION] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetWindowCaption_Request()
  args:ParseFromString(request_args)
  
  local caption = GetWindowCaption(args.t_id) -- returns nil in case of error
  if caption == nil then 
    error(string.format("Процедура GetWindowCaption(%s) возвратила nil.", args.t_id), 0)
  else
    local result = qlua_msg.GetWindowCaption_Result()
    result.caption = caption
    return result
  end
end

request_handlers[qlua_msg.ProcedureType.GET_WINDOW_RECT] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetWindowRect_Request()
  args:ParseFromString(request_args)
  
  local top, left, bottom, right = GetWindowRect(args.t_id) -- returns nil in case of error
  if top == nil or left == nil or bottom == nil or right == nil then
    error(string.format("Процедура GetWindowRect(%s) возвратила nil.", args.t_id), 0)
  else
    local result = qlua_msg.GetWindowRect_Result()
    result.top = top
    result.left = left
    result.bottom = bottom
    result.right = right
    return result
  end
end

request_handlers[qlua_msg.ProcedureType.RGB] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.RGB_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.RGB_Result()
  -- NB: на самом деле, библиотечная функция RGB должна называться BGR, ибо она выдаёт числа именно в этом формате. В SetColor, однако, тоже ожидается цвет в формате BGR, так что это не баг, а фича.
  result.result = RGB(args.red, args.green, args.blue) -- returns a number
  return result
end

request_handlers[qlua_msg.ProcedureType.SET_COLOR] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.SetColor_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.SetColor_Result()
  result.result = SetColor(args.t_id, args.row, args.col, args.b_color, args.f_color, args.sel_b_color, args.sel_f_color) -- what does it return in case of error ?
  return result
end

request_handlers[qlua_msg.ProcedureType.HIGHLIGHT] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.Highlight_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.Highlight_Result()
  result.result = Highlight(args.t_id, args.row, args.col, args.b_color, args.f_color, args.timeout) -- what does it return in case of error ?
  return result
end

request_handlers[qlua_msg.ProcedureType.SET_SELECTED_ROW] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.SetSelectedRow_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.SetSelectedRow_Result()
  result.result = SetSelectedRow(args.table_id, args.row) -- returns -1 in case of error
  return result
end

request_handlers[qlua_msg.ProcedureType.ADD_LABEL] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.AddLabel_Request()
  args:ParseFromString(request_args)
  
  local label_params = utils.create_table(args.label_params)
  local ret = AddLabel(args.chart_tag, label_params) -- returns nil in case of error
  if ret == nil then
    error(string.format("Процедура AddLabel(%s, %s) возвратила nil.", args.chart_tag, utils.table.tostring(label_params)), 0)
  else
    local result = qlua_msg.AddLabel_Result()
    result.label_id = ret
    return result
  end
end

request_handlers[qlua_msg.ProcedureType.DEL_LABEL] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.DelLabel_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.DelLabel_Result()
  result.result = DelLabel(args.chart_tag, args.label_id) -- returns true or false
  return result
end

request_handlers[qlua_msg.ProcedureType.DEL_ALL_LABELS] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.DelAllLabels_Request()
  args:ParseFromString(request_args)
  local result = qlua_msg.DelAllLabels_Result()
  result.result = DelAllLabels(args.chart_tag) -- returns true or false
  return result
end

request_handlers[qlua_msg.ProcedureType.GET_LABEL_PARAMS] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.GetLabelParams_Request()
  args:ParseFromString(request_args)
  
  local t = GetLabelParams(args.chart_tag, args.label_id) -- returns nil in case of error
  if t == nil then
    error(string.format("Процедура GetLabelParams(%s, %d) возвратила nil.", args.chart_tag, args.label_id), 0)
  else
    local result = qlua_msg.GetLabelParams_Result()
    utils.put_to_string_string_pb_map(t, result.label_params, qlua_msg.GetLabelParams_Result.LabelParamsEntry)
    return result
  end
end

request_handlers[qlua_msg.ProcedureType.SET_LABEL_PARAMS] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.SetLabelParams_Request()
  args:ParseFromString(request_args)
  
  local label_params = utils.create_table(args.label_params)
  local result = qlua_msg.SetLabelParams_Result()
  result.result = SetLabelParams(args.chart_tag, args.label_id, label_params) -- returns true or false
  return result
end

request_handlers[qlua_msg.ProcedureType.BIT_TOHEX] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.BitToHex_Request()
  args:ParseFromString(request_args)
  
  local result = qlua_msg.BitToHex_Result()
  if args.n == 0 then
    result.result = bit.tohex(args.x)
  else
    result.result = bit.tohex(args.x, args.n)
  end
  return result
end

request_handlers[qlua_msg.ProcedureType.BIT_BNOT] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.BitBNot_Request()
  args:ParseFromString(request_args)
  
  local result = qlua_msg.BitBNot_Result()
  result.result = bit.bnot(args.x)
  return result
end

request_handlers[qlua_msg.ProcedureType.BIT_BAND] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.BitBAnd_Request()
  args:ParseFromString(request_args)
  
  local result = qlua_msg.BitBAnd_Result()
  local xs = {args.x1, args.x2}
  for i, e in ipairs(args.xi) do
    table.sinsert(xs, e)
  end

  result.result = bit.band( unpack(xs) )
  return result
end

request_handlers[qlua_msg.ProcedureType.BIT_BOR] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.BitBOr_Request()
  args:ParseFromString(request_args)
  
  local result = qlua_msg.BitBOr_Result()
  local xs = {args.x1, args.x2}
  for i, e in ipairs(args.xi) do
    table.sinsert(xs, e)
  end

  result.result = bit.bor( unpack(xs) )
  return result
end

request_handlers[qlua_msg.ProcedureType.BIT_BXOR] = function(request_args) 
  require_request_args_not_nil(request_args)
  local args = qlua_msg.BitBXor_Request()
  args:ParseFromString(request_args)
  
  local result = qlua_msg.BitBXor_Result()
  local xs = {args.x1, args.x2}
  for i, e in ipairs(args.xi) do
    table.sinsert(xs, e)
  end

  result.result = bit.bxor( unpack(xs) )
  return result
end

return RequestHandler