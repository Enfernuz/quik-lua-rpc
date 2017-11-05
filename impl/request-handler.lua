package.path = "../?.lua;" .. package.path

local qlua_rpc = require("messages.qlua_rpc_pb")

local qlua = { 
  rpc = {} 
}

qlua.rpc.message = require("messages.message_pb")
qlua.rpc.isConnected = require("messages.isConnected_pb")
qlua.rpc.getScriptPath = require("messages.getScriptPath_pb")
qlua.rpc.getInfoParam = require("messages.getInfoParam_pb")
qlua.rpc.sleep = require("messages.sleep_pb")
qlua.rpc.getWorkingFolder = require("messages.getWorkingFolder_pb")
qlua.rpc.PrintDbgStr = require("messages.PrintDbgStr_pb")
qlua.rpc.getItem = require("messages.getItem_pb")
qlua.rpc.getOrderByNumber = require("messages.getOrderByNumber_pb")
qlua.rpc.getNumberOf = require("messages.getNumberOf_pb")
qlua.rpc.SearchItems = require("messages.SearchItems_pb")
qlua.rpc.getClassesList = require("messages.getClassesList_pb")
qlua.rpc.getClassInfo = require("messages.getClassInfo_pb")
qlua.rpc.getClassSecurities = require("messages.getClassSecurities_pb")

local struct_factory = require("utils.struct_factory")
local utils = require("utils.utils")
local table = require('table')
local bit = require('bit')

local unpack = assert(unpack, "unpack function is missing.")
local error = assert(error, "error function is missing.")
local type = assert(type, "type function is missing.")
local pcall = assert(pcall, "pcall function is missing.")
local ipairs = assert(ipairs, "ipairs function is missing.")
local loadstring = assert(loadstring, "loadstring function is missing.")
local tostring = assert(tostring, "tostring function is missing.")
local tonumber = assert(tonumber, "tonumber function is missing.")

local value_to_string_or_empty_string = assert(utils.value_to_string_or_empty_string)
local value_or_empty_string = assert(utils.value_or_empty_string)

local function parse_request_args(request_args, request_ctr)
  
  if request_args == nil then error("Запрос не содержит аргументов.", 0) end
  if request_ctr == nil then error("Отсутствует конструктор запроса.", 0) end
  -- we can go all defensive and check for the arguments' types as well (table for args, function for ctr), but let's just assume we'll never pass incorrect types :)
  
  local args = request_ctr()
  args:ParseFromString(request_args)
  
  return args
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
  
  local response = qlua_rpc.Envelope.Response()
  response.type = request.type
  
  if ok then 
    if result then
      response.result = result:SerializeToString()
    end
  else
    response.is_error = true
    if result then
      response.result = result
    end
  end
  
  return response
end
  
request_handlers[qlua_rpc.ProcedureType.IS_CONNECTED] = function() 
  local result = qlua.rpc.isConnected.Result()
  result.is_connected = isConnected()
  return result
end

request_handlers[qlua_rpc.ProcedureType.GET_SCRIPT_PATH] = function() 
  local result = qlua.rpc.getScriptPath.Result()
  result.script_path = getScriptPath()
end

request_handlers[qlua_rpc.ProcedureType.GET_INFO_PARAM] = function(request_args)
  local args = parse_request_args(request_args, qlua.rpc.getInfoParam.Request)
  local result = qlua.rpc.getInfoParam.Result()
  result.info_param = getInfoParam(args.param_name)
  return result
end

request_handlers[qlua_rpc.ProcedureType.MESSAGE] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.rpc.message.Request)

  local ret = (args.icon_type == qlua.rpc.message.IconType.UNDEFINED and message(args.message) or message(args.message, args.icon_type))
  if ret == nil then
    if args.icon_type == qlua.rpc.message.IconType.UNDEFINED then 
      error(string.format("Процедура message(%s) возвратила nil.", args.message), 0)
    else
      error(string.format("Процедура message(%s, %d) возвратила nil.", args.message, args.icon_type), 0)
    end
  else
    local result = qlua.rpc.message.Result()
    result.result = ret
    return result
  end
end

request_handlers[qlua_rpc.ProcedureType.SLEEP] = function(request_args) 
  local args = parse_request_args(request_args, qlua.rpc.sleep.Request)
  local ret = sleep(args.time) -- TO-DO: pcall
  if ret == nil then
    error(string.format("Процедура sleep(%d) возвратила nil.", args.time), 0)
  else
    local result = qlua.rpc.sleep.Result()
    result.result = ret
    return result
  end
end

request_handlers[qlua_rpc.ProcedureType.GET_WORKING_FOLDER] = function() 
  local result = qlua.rpc.getWorkingFolder.Result()
  result.working_folder = getWorkingFolder()
  return result
end

request_handlers[qlua_rpc.ProcedureType.PRINT_DBG_STR] = function(request_args) 
  local args = parse_request_args(request_args, qlua.rpc.PrintDbgStr.Request)
  PrintDbgStr(args.s)
  return nil
end

request_handlers[qlua_rpc.ProcedureType.GET_ITEM] = function(request_args) 
  local args = parse_request_args(request_args, qlua.rpc.getItem.Request)
  local result = qlua.rpc.getItem.Result()
  local t = getItem(args.table_name, args.index)
  if t then
    utils.put_to_string_string_pb_map(t, result.table_row, qlua.rpc.getItem.Result.TableRowEntry)
  end
  return result
end

request_handlers[qlua_rpc.ProcedureType.GET_ORDER_BY_NUMBER] = function(request_args) 
  local args = parse_request_args(request_args, qlua.rpc.getOrderByNumber.Request)
  local t, i = getOrderByNumber(args.class_code, args.order_id)
  if t == nil then
    error(string.format("Процедура getOrderByNumber(%s, %d) вернула (nil, nil).", args.class_code, args.order_id), 0)
  else
    local result = qlua.rpc.getOrderByNumber.Result()
    result.order = struct_factory.create_Order(t)
    result.indx = i
    return result
  end
end

request_handlers[qlua_rpc.ProcedureType.GET_NUMBER_OF] = function(request_args) 
  local args = parse_request_args(request_args, qlua.rpc.getNumberOf.Request)
  local result = qlua.rpc.getNumberOf.Result()
  result.result = getNumberOf(args.table_name) -- returns -1 in case of error
  return result
end

request_handlers[qlua_rpc.ProcedureType.SEARCH_ITEMS] = function(request_args) 
  local args = parse_request_args(request_args, qlua.rpc.SearchItems.Request)
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
  
  local result = qlua.rpc.SearchItems.Result()
  if items then 
    for i, item_index in ipairs(items) do
      table.sinsert(result.items_indices, item_index)
    end
  end
  
  return result
end

request_handlers[qlua_rpc.ProcedureType.GET_CLASSES_LIST] = function() 
  local result = qlua.rpc.getClassesList.Result()
  result.classes_list = getClassesList()
  return result
end

request_handlers[qlua_rpc.ProcedureType.GET_CLASS_INFO] = function(request_args) 
  local args = parse_request_args(request_args, qlua.rpc.getClassInfo.Request)

  local t = getClassInfo(args.class_code)
  if t == nil then
    error(string.format("Процедура getClassInfo(%s) вернула nil.", args.class_code), 0)
  else
    local result = qlua.rpc.getClassInfo.Result()
    
    result.class_info.firmid = utils.value_or_empty_string(t.firmid)
    result.class_info.name = utils.value_or_empty_string(t.name)
    result.class_info.code = utils.value_or_empty_string(t.code)
    result.class_info.npars = t.npars
    result.class_info.nsecs = t.nsecs

    return result
  end
end

request_handlers[qlua_rpc.ProcedureType.GET_CLASS_SECURITIES] = function(request_args) 
  local args = parse_request_args(request_args, qlua.rpc.getClassSecurities.Request)
  local result = qlua.rpc.getClassSecurities.Result()
  local ret = getClassSecurities(args.class_code) -- returns an empty string if no securities found for the given class_code
  if ret then result.class_securities = ret end
  return result
end

request_handlers[qlua_rpc.ProcedureType.GET_MONEY] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.GetMoney_Request)
  local result = qlua_rpc.GetMoney_Result()
  local t = getMoney(args.client_code, args.firmid, args.tag, args.currcode) -- returns a table with zero'ed values if no info found or in case of an error
  if t ~= nil then
    result.money.money_open_limit = value_to_string_or_empty_string(t.money_open_limit)
    result.money.money_limit_locked_nonmarginal_value = value_to_string_or_empty_string(t.money_limit_locked_nonmarginal_value)
    result.money.money_limit_locked = value_to_string_or_empty_string(t.money_limit_locked)
    result.money.money_open_balance = value_to_string_or_empty_string(t.money_open_balance)
    result.money.money_current_limit = value_to_string_or_empty_string(t.money_current_limit)
    result.money.money_current_balance = value_to_string_or_empty_string(t.money_current_balance)
    result.money.money_limit_available = value_to_string_or_empty_string(t.money_limit_available)
  end
  return result
end

request_handlers[qlua_rpc.ProcedureType.GET_MONEY_EX] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.GetMoneyEx_Request)
  local t = getMoneyEx(args.firmid, args.client_code, args.tag, args.currcode, args.limit_kind) -- returns nil if no info found or in case of an error
  if t == nil then 
    error(string.format("Процедура getMoneyEx(%s, %s, %s, %s, %d) возвратила nil.", args.firmid, args.client_code, args.tag, args.currcode, args.limit_kind), 0)
  else
    local result = qlua_rpc.GetMoneyEx_Result()
    struct_factory.create_MoneyLimit(t, result.money_ex)
    return result
  end
end

request_handlers[qlua_rpc.ProcedureType.GET_DEPO] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.GetDepo_Request)
  local result = qlua_rpc.GetDepo_Result()
  local t = getDepo(args.client_code, args.firmid, args.sec_code, args.trdaccid) -- returns a table with zero'ed values if no info found or in case of an error
  if t ~= nil then
    result.depo.depo_limit_locked_buy_value = value_to_string_or_empty_string(t.depo_limit_locked_buy_value)
    result.depo.depo_current_balance = value_to_string_or_empty_string(t.depo_current_balance)
    result.depo.depo_limit_locked_buy = value_to_string_or_empty_string(t.depo_limit_locked_buy)
    result.depo.depo_limit_locked = value_to_string_or_empty_string(t.depo_limit_locked)
    result.depo.depo_limit_available = value_to_string_or_empty_string(t.depo_limit_available)
    result.depo.depo_current_limit = value_to_string_or_empty_string(t.depo_current_limit)
    result.depo.depo_open_balance = value_to_string_or_empty_string(t.depo_open_balance)
    result.depo.depo_open_limit = value_to_string_or_empty_string(t.depo_open_limit)
  end
  return result
end

request_handlers[qlua_rpc.ProcedureType.GET_DEPO_EX] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.GetDepoEx_Request)
  local t = getDepoEx(args.firmid, args.client_code, args.sec_code, args.trdaccid, args.limit_kind) -- returns nil if no info found or in case of an error
  if t == nil then
    error(string.format("Процедура getDepoEx(%s, %s, %s, %s, %d) возвратила nil.", args.firmid, args.client_code, args.sec_code, args.trdaccid, args.limit_kind), 0)
  else
    local result = qlua_rpc.GetDepoEx_Result()
    struct_factory.create_DepoLimit(t, result.depo_ex)
    return result
  end
end

request_handlers[qlua_rpc.ProcedureType.GET_FUTURES_LIMIT] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.GetFuturesLimit_Request)
  local t = getFuturesLimit(args.firmid, args.trdaccid, args.limit_type, args.currcode) -- returns nil if no info found or in case of an error
  if t == nil then
    error(string.format("Процедура getFuturesLimit(%s, %s, %d, %s) возвратила nil.", args.firmid, args.trdaccid, args.limit_type, args.currcode), 0)
  else
    local result = qlua_rpc.GetFuturesLimit_Result()
    struct_factory.create_FuturesLimit(t, result.futures_limit)
    return result
  end
end

request_handlers[qlua_rpc.ProcedureType.GET_FUTURES_HOLDING] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.GetFuturesHolding_Request)
  local t = getFuturesHolding(args.firmid, args.trdaccid, args.sec_code, args.type) -- returns nil if no info found or in case of an error
  if t == nil then
    error(string.format("Процедура getFuturesLHolding(%s, %s, %d, %d) возвратила nil.", args.firmid, args.trdaccid, args.sec_code, args.type), 0)
  else
    local result = qlua_rpc.GetFuturesHolding_Result()
    struct_factory.create_FuturesClientHolding(t, result.futures_holding)
    return result
  end
end

request_handlers[qlua_rpc.ProcedureType.GET_SECURITY_INFO] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.GetSecurityInfo_Request)
  local t = getSecurityInfo(args.class_code, args.sec_code) -- returns nil if no info found or in case of an error
  if t == nil then
    error(string.format("Процедура getSecurityInfo(%s, %s) возвратила nil.", args.class_code, args.sec_code), 0)
  else
    local result = qlua_rpc.GetSecurityInfo_Result()
    struct_factory.create_Security(t, result.security_info)
    return result
  end
end

request_handlers[qlua_rpc.ProcedureType.GET_TRADE_DATE] = function() 
  local result = qlua_rpc.GetTradeDate_Result()
  local t = getTradeDate()
  
  result.trade_date.date = value_or_empty_string(t.date)
  result.trade_date.year = t.year
  result.trade_date.month = t.month
  result.trade_date.day = t.day
  
  return result
end

request_handlers[qlua_rpc.ProcedureType.GET_QUOTE_LEVEL2] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.GetQuoteLevel2_Request)
  local result = qlua_rpc.GetQuoteLevel2_Result()
  local t = getQuoteLevel2(args.class_code, args.sec_code)
  result.bid_count = t.bid_count
  result.offer_count = t.offer_count
  if t.bid ~= nil then utils.insert_quote_table(result.bids, t.bid) end
  if t.offer ~= nil then utils.insert_quote_table(result.offers, t.offer) end
  return result
end

request_handlers[qlua_rpc.ProcedureType.GET_LINES_COUNT] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.GetLinesCount_Request)
  local result = qlua_rpc.GetLinesCount_Result()
  result.lines_count = getLinesCount(args.tag) -- returns 0 if no chart with this tag found
  return result
end

request_handlers[qlua_rpc.ProcedureType.GET_NUM_CANDLES] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.GetNumCandles_Request)
  local result = qlua_rpc.GetNumCandles_Result()
  result.num_candles = getNumCandles(args.tag) -- returns 0 if no chart with this tag found
  return result
end

request_handlers[qlua_rpc.ProcedureType.GET_CANDLES_BY_INDEX] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.GetCandlesByIndex_Request)
  local result = qlua_rpc.GetCandlesByIndex_Result()
  local t, n, l = getCandlesByIndex(args.tag, args.line, args.first_candle, args.count) -- returns ({}, 0, "") if no info found or in case of error
  result.n = n
  result.l = l
  if t ~= nil then 
    utils.insert_candles_table(result.t, t)
  end
  return result
end

request_handlers[qlua_rpc.ProcedureType.CREATE_DATA_SOURCE] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.CreateDataSource_Request)
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
    local result = qlua_rpc.CreateDataSource_Result()
    result.datasource_uuid = uuid()
    RequestHandler.datasources[result.datasource_uuid] = ds
    return result
  end
end

request_handlers[qlua_rpc.ProcedureType.DS_SET_UPDATE_CALLBACK] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.DataSourceSetUpdateCallback_Request)
  
  local ds = RequestHandler:get_datasource(args.datasource_uuid)
  
  local f_cb_ctr, error_msg = loadstring("return "..args.f_cb_def)
  if f_cb_ctr == nil then 
    error( string.format("Не удалось распарсить определение функции из переданной строки. Описание ошибки: [%s].", error_msg) )
  else
    local f_cb = f_cb_ctr()
    local callback = function (index) f_cb(index, ds) end
    local result = qlua_rpc.DataSourceSetUpdateCallback_Result()
    result.result = ds:SetUpdateCallback(callback)
    return result
  end
end

request_handlers[qlua_rpc.ProcedureType.DS_O] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.DataSourceO_Request)
 
  local ds = RequestHandler:get_datasource(args.datasource_uuid)
  
  local result = qlua_rpc.DataSourceO_Result()
  result.value = tostring( ds:O(args.candle_index) )
  return result
end

request_handlers[qlua_rpc.ProcedureType.DS_H] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.DataSourceH_Request)
 
  local ds = RequestHandler:get_datasource(args.datasource_uuid)
  
  local result = qlua_rpc.DataSourceH_Result()
  result.value = tostring( ds:H(args.candle_index) )
  return result
end

request_handlers[qlua_rpc.ProcedureType.DS_L] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.DataSourceL_Request)
 
  local ds = RequestHandler:get_datasource(args.datasource_uuid)
  
  local result = qlua_rpc.DataSourceL_Result()
  result.value = tostring( ds:L(args.candle_index) )
  return result
end

request_handlers[qlua_rpc.ProcedureType.DS_C] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.DataSourceC_Request)
 
  local ds = RequestHandler:get_datasource(args.datasource_uuid)
  
  local result = qlua_rpc.DataSourceC_Result()
  result.value = tostring( ds:C(args.candle_index) )
  return result
end

request_handlers[qlua_rpc.ProcedureType.DS_V] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.DataSourceV_Request)
 
  local ds = RequestHandler:get_datasource(args.datasource_uuid)
  
  local result = qlua_rpc.DataSourceV_Result()
  result.value = tostring( ds:V(args.candle_index) )
  return result
end

request_handlers[qlua_rpc.ProcedureType.DS_T] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.DataSourceT_Request)
  
  local ds = RequestHandler:get_datasource(args.datasource_uuid)
  
  local result = qlua_rpc.DataSourceT_Result()
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

request_handlers[qlua_rpc.ProcedureType.DS_SIZE] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.DataSourceSize_Request)
  
  local ds = RequestHandler:get_datasource(args.datasource_uuid)

  local result = qlua_rpc.DataSourceSize_Result()
  result.value = ds:Size(args.candle_index)
  return result
end

request_handlers[qlua_rpc.ProcedureType.DS_CLOSE] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.DataSourceClose_Request)
  
  local ds = RequestHandler:get_datasource(args.datasource_uuid)
  
  local result = qlua_rpc.DataSourceClose_Result()
  result.result = ds:Close()
  return result
end

request_handlers[qlua_rpc.ProcedureType.DS_SET_EMPTY_CALLBACK] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.DataSourceSetEmptyCallback_Request)
  
  local ds = RequestHandler:get_datasource(args.datasource_uuid)
  
  local result = qlua_rpc.DataSourceSetEmptyCallback_Result()
  result.result = ds:SetEmptyCallback()
  return result
end

request_handlers[qlua_rpc.ProcedureType.SEND_TRANSACTION] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.SendTransaction_Request)
  local t = utils.create_table(args.transaction)
  local result = qlua_rpc.SendTransaction_Result()
  result.result = sendTransaction(t) -- returns an empty string (seems to be always)
  return result
end

request_handlers[qlua_rpc.ProcedureType.CALC_BUY_SELL] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.CalcBuySell_Request)
  local result = qlua_rpc.CalcBuySell_Result()
  local price = tonumber(args.price)
  if price == nil then
    error(string.format("Не удалось преобразовать в число значение '%s' параметра price", args.price), 0) 
  end
  local comission
  result.qty, comission = CalcBuySell(args.class_code, args.sec_code, args.client_code, args.account, price, args.is_buy, args.is_market) -- returns (0; 0) in case of error
  result.comission = tostring(comission)
  return result
end

request_handlers[qlua_rpc.ProcedureType.GET_PARAM_EX] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.GetParamEx_Request)
  local t = getParamEx(args.class_code, args.sec_code, args.param_name) -- always returns a table
  if t == nil then
    error(string.format("Процедура getParamEx(%s, %s, %s) возвратила nil.", args.class_code, args.sec_code, args.param_name), 0)
  else
    local result = qlua_rpc.GetParamEx_Result()
    result.param_ex.param_type = value_or_empty_string(t.param_type)
    result.param_ex.param_value = value_or_empty_string(t.param_value)
    result.param_ex.param_image = value_or_empty_string(t.param_image)
    result.param_ex.result = value_or_empty_string(t.result)
    return result
  end
end

request_handlers[qlua_rpc.ProcedureType.GET_PARAM_EX_2] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.GetParamEx_Request)
  local t = getParamEx2(args.class_code, args.sec_code, args.param_name) -- always returns a table
  if t == nil then
    error(string.format("Процедура getParamEx2(%s, %s, %s) возвратила nil.", args.class_code, args.sec_code, args.param_name), 0)
  else
    local result = qlua_rpc.GetParamEx_Result()
    result.param_ex.param_type = value_or_empty_string(t.param_type)
    result.param_ex.param_value = value_or_empty_string(t.param_value)
    result.param_ex.param_image = value_or_empty_string(t.param_image)
    result.param_ex.result = value_or_empty_string(t.result)
    return result
  end
end

request_handlers[qlua_rpc.ProcedureType.GET_PORTFOLIO_INFO] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.GetPortfolioInfo_Request)
  local t = getPortfolioInfo(args.firm_id, args.client_code) -- returns {} in case of error
  if t == nil then
    error(string.format("Процедура getPortfolioInfo(%s, %s) возвратила nil.", args.firm_id, args.client_code), 0)
  else
    local result = qlua_rpc.GetPortfolioInfo_Result()
    
    result.portfolio_info.is_leverage = value_or_empty_string(t.is_leverage)
    result.portfolio_info.in_assets = value_or_empty_string(t.in_assets)
    result.portfolio_info.leverage = value_or_empty_string(t.leverage)
    result.portfolio_info.open_limit = value_or_empty_string(t.open_limit)
    result.portfolio_info.val_short = value_or_empty_string(t.val_short)
    result.portfolio_info.val_long = value_or_empty_string(t.val_long)
    result.portfolio_info.val_long_margin = value_or_empty_string(t.val_long_margin)
    result.portfolio_info.val_long_asset = value_or_empty_string(t.val_long_asset)
    result.portfolio_info.assets = value_or_empty_string(t.assets)
    result.portfolio_info.cur_leverage = value_or_empty_string(t.cur_leverage)
    result.portfolio_info.margin = value_or_empty_string(t.margin)
    result.portfolio_info.lim_all = value_or_empty_string(t.lim_all)
    result.portfolio_info.av_lim_all = value_or_empty_string(t.av_lim_all)
    result.portfolio_info.locked_buy = value_or_empty_string(t.locked_buy)
    result.portfolio_info.locked_buy_margin = value_or_empty_string(t.locked_buy_margin)
    result.portfolio_info.locked_buy_asset = value_or_empty_string(t.locked_buy_asset)
    result.portfolio_info.locked_sell = value_or_empty_string(t.locked_sell)
    result.portfolio_info.locked_value_coef = value_or_empty_string(t.locked_value_coef)
    result.portfolio_info.in_all_assets = value_or_empty_string(t.in_all_assets)
    result.portfolio_info.all_assets = value_or_empty_string(t.all_assets)
    result.portfolio_info.profit_loss = value_or_empty_string(t.profit_loss)
    result.portfolio_info.rate_change = value_or_empty_string(t.rate_change)
    result.portfolio_info.lim_buy = value_or_empty_string(t.lim_buy)
    result.portfolio_info.lim_sell = value_or_empty_string(t.lim_sell)
    result.portfolio_info.lim_non_margin = value_or_empty_string(t.lim_non_margin)
    result.portfolio_info.lim_buy_asset = value_or_empty_string(t.lim_buy_asset)
    result.portfolio_info.val_short_net = value_or_empty_string(t.val_short_net)
    result.portfolio_info.val_long_net = value_or_empty_string(t.val_long_net)
    result.portfolio_info.total_money_bal = value_or_empty_string(t.total_money_bal)
    result.portfolio_info.total_locked_money = value_or_empty_string(t.total_locked_money)
    result.portfolio_info.haircuts = value_or_empty_string(t.haircuts)
    result.portfolio_info.assets_without_hc = value_or_empty_string(t.assets_without_hc)
    result.portfolio_info.status_coef = value_or_empty_string(t.status_coef)
    result.portfolio_info.varmargin = value_or_empty_string(t.varmargin)
    result.portfolio_info.go_for_positions = value_or_empty_string(t.go_for_positions)
    result.portfolio_info.go_for_orders = value_or_empty_string(t.go_for_orders)
    result.portfolio_info.rate_futures = value_or_empty_string(t.rate_futures)
    result.portfolio_info.is_qual_client = value_or_empty_string(t.is_qual_client)
    result.portfolio_info.is_futures = value_or_empty_string(t.is_futures)
    result.portfolio_info.curr_tag = value_or_empty_string(t.curr_tag)
    
    return result
  end
end

request_handlers[qlua_rpc.ProcedureType.GET_PORTFOLIO_INFO_EX] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.GetPortfolioInfoEx_Request)
  local t = getPortfolioInfoEx(args.firm_id, args.client_code, args.limit_kind) -- returns {} in case of error
  if t == nil then
    error(string.format("Процедура getPortfolioInfoEx(%s, %s, %d) возвратила nil.", args.firm_id, args.client_code, args.limit_kind), 0)
  else
    local result = qlua_rpc.GetPortfolioInfoEx_Result()
    
    result.portfolio_info_ex.portfolio_info.is_leverage = value_or_empty_string(t.is_leverage)
    result.portfolio_info_ex.portfolio_info.in_assets = value_or_empty_string(t.in_assets)
    result.portfolio_info_ex.portfolio_info.leverage = value_or_empty_string(t.leverage)
    result.portfolio_info_ex.portfolio_info.open_limit = value_or_empty_string(t.open_limit)
    result.portfolio_info_ex.portfolio_info.val_short = value_or_empty_string(t.val_short)
    result.portfolio_info_ex.portfolio_info.val_long = value_or_empty_string(t.val_long)
    result.portfolio_info_ex.portfolio_info.val_long_margin = value_or_empty_string(t.val_long_margin)
    result.portfolio_info_ex.portfolio_info.val_long_asset = value_or_empty_string(t.val_long_asset)
    result.portfolio_info_ex.portfolio_info.assets = value_or_empty_string(t.assets)
    result.portfolio_info_ex.portfolio_info.cur_leverage = value_or_empty_string(t.cur_leverage)
    result.portfolio_info_ex.portfolio_info.margin = value_or_empty_string(t.margin)
    result.portfolio_info_ex.portfolio_info.lim_all = value_or_empty_string(t.lim_all)
    result.portfolio_info_ex.portfolio_info.av_lim_all = value_or_empty_string(t.av_lim_all)
    result.portfolio_info_ex.portfolio_info.locked_buy = value_or_empty_string(t.locked_buy)
    result.portfolio_info_ex.portfolio_info.locked_buy_margin = value_or_empty_string(t.locked_buy_margin)
    result.portfolio_info_ex.portfolio_info.locked_buy_asset = value_or_empty_string(t.locked_buy_asset)
    result.portfolio_info_ex.portfolio_info.locked_sell = value_or_empty_string(t.locked_sell)
    result.portfolio_info_ex.portfolio_info.locked_value_coef = value_or_empty_string(t.locked_value_coef)
    result.portfolio_info_ex.portfolio_info.in_all_assets = value_or_empty_string(t.in_all_assets)
    result.portfolio_info_ex.portfolio_info.all_assets = value_or_empty_string(t.all_assets)
    result.portfolio_info_ex.portfolio_info.profit_loss = value_or_empty_string(t.profit_loss)
    result.portfolio_info_ex.portfolio_info.rate_change = value_or_empty_string(t.rate_change)
    result.portfolio_info_ex.portfolio_info.lim_buy = value_or_empty_string(t.lim_buy)
    result.portfolio_info_ex.portfolio_info.lim_sell = value_or_empty_string(t.lim_sell)
    result.portfolio_info_ex.portfolio_info.lim_non_margin = value_or_empty_string(t.lim_non_margin)
    result.portfolio_info_ex.portfolio_info.lim_buy_asset = value_or_empty_string(t.lim_buy_asset)
    result.portfolio_info_ex.portfolio_info.val_short_net = value_or_empty_string(t.val_short_net)
    result.portfolio_info_ex.portfolio_info.val_long_net = value_or_empty_string(t.val_long_net)
    result.portfolio_info_ex.portfolio_info.total_money_bal = value_or_empty_string(t.total_money_bal)
    result.portfolio_info_ex.portfolio_info.total_locked_money = value_or_empty_string(t.total_locked_money)
    result.portfolio_info_ex.portfolio_info.haircuts = value_or_empty_string(t.haircuts)
    result.portfolio_info_ex.portfolio_info.assets_without_hc = value_or_empty_string(t.assets_without_hc)
    result.portfolio_info_ex.portfolio_info.status_coef = value_or_empty_string(t.status_coef)
    result.portfolio_info_ex.portfolio_info.varmargin = value_or_empty_string(t.varmargin)
    result.portfolio_info_ex.portfolio_info.go_for_positions = value_or_empty_string(t.go_for_positions)
    result.portfolio_info_ex.portfolio_info.go_for_orders = value_or_empty_string(t.go_for_orders)
    result.portfolio_info_ex.portfolio_info.rate_futures = value_or_empty_string(t.rate_futures)
    result.portfolio_info_ex.portfolio_info.is_qual_client = value_or_empty_string(t.is_qual_client)
    result.portfolio_info_ex.portfolio_info.is_futures = value_or_empty_string(t.is_futures)
    result.portfolio_info_ex.portfolio_info.curr_tag = value_or_empty_string(t.curr_tag)
    
    result.portfolio_info_ex.init_margin = value_or_empty_string(t.init_margin)
    result.portfolio_info_ex.min_margin = value_or_empty_string(t.min_margin)
    result.portfolio_info_ex.corrected_margin = value_or_empty_string(t.corrected_margin)
    result.portfolio_info_ex.client_type = value_or_empty_string(t.client_type)
    result.portfolio_info_ex.portfolio_value = value_or_empty_string(t.portfolio_value)
    result.portfolio_info_ex.start_limit_open_pos = value_or_empty_string(t.start_limit_open_pos)
    result.portfolio_info_ex.total_limit_open_pos = value_or_empty_string(t.total_limit_open_pos)
    result.portfolio_info_ex.limit_open_pos = value_or_empty_string(t.limit_open_pos)
    result.portfolio_info_ex.used_lim_open_pos = value_or_empty_string(t.used_lim_open_pos)
    result.portfolio_info_ex.acc_var_margin = value_or_empty_string(t.acc_var_margin)
    result.portfolio_info_ex.cl_var_margin = value_or_empty_string(t.cl_var_margin)
    result.portfolio_info_ex.opt_liquid_cost = value_or_empty_string(t.opt_liquid_cost)
    result.portfolio_info_ex.fut_asset = value_or_empty_string(t.fut_asset)
    result.portfolio_info_ex.fut_total_asset = value_or_empty_string(t.fut_total_asset)
    result.portfolio_info_ex.fut_debt = value_or_empty_string(t.fut_debt)
    result.portfolio_info_ex.fut_rate_asset = value_or_empty_string(t.fut_rate_asset)
    result.portfolio_info_ex.fut_rate_asset_open = value_or_empty_string(t.fut_rate_asset_open)
    result.portfolio_info_ex.fut_rate_go = value_or_empty_string(t.fut_rate_go)
    result.portfolio_info_ex.planed_rate_go = value_or_empty_string(t.planed_rate_go)
    result.portfolio_info_ex.cash_leverage = value_or_empty_string(t.cash_leverage)
    result.portfolio_info_ex.fut_position_type = value_or_empty_string(t.fut_position_type)
    result.portfolio_info_ex.fut_accured_int = value_or_empty_string(t.fut_accured_int)
    
    return result
  end
end

request_handlers[qlua_rpc.ProcedureType.GET_BUY_SELL_INFO] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.GetBuySellInfo_Request)
  local price = tonumber(args.price)
  if price == nil then 
    error(string.format("Не удалось преобразовать в число значение '%s' параметра price", args.price), 0)
  end
  local t = getBuySellInfo(args.firm_id, args.client_code, args.class_code, args.sec_code, price) -- returns {} in case of error
  if t == nil then
    error(string.format("Процедура getBuySellInfo(%s, %s, %s, %s, %s) возвратила nil.", args.firm_id, args.client_code, args.class_code, args.sec_code, price), 0)
  else
    local result = qlua_rpc.GetBuySellInfo_Result()
    
    result.buy_sell_info.is_margin_sec = value_or_empty_string(t.is_margin_sec)
    result.buy_sell_info.is_asset_sec = value_or_empty_string(t.is_asset_sec)
    result.buy_sell_info.balance = value_or_empty_string(t.balance)
    result.buy_sell_info.can_buy = value_or_empty_string(t.can_buy)
    result.buy_sell_info.can_sell = value_or_empty_string(t.can_sell)
    result.buy_sell_info.position_valuation = value_or_empty_string(t.position_valuation)
    result.buy_sell_info.value = value_or_empty_string(t.value)
    result.buy_sell_info.open_value = value_or_empty_string(t.open_value)
    result.buy_sell_info.lim_long = value_or_empty_string(t.lim_long)
    result.buy_sell_info.long_coef = value_or_empty_string(t.long_coef)
    result.buy_sell_info.lim_short = value_or_empty_string(t.lim_short)
    result.buy_sell_info.short_coef = value_or_empty_string(t.short_coef)
    result.buy_sell_info.value_coef = value_or_empty_string(t.value_coef)
    result.buy_sell_info.open_value_coef = value_or_empty_string(t.open_value_coef)
    result.buy_sell_info.share = value_or_empty_string(t.share)
    result.buy_sell_info.short_wa_price = value_or_empty_string(t.short_wa_price)
    result.buy_sell_info.long_wa_price = value_or_empty_string(t.long_wa_price)
    result.buy_sell_info.profit_loss = value_or_empty_string(t.profit_loss)
    result.buy_sell_info.spread_hc = value_or_empty_string(t.spread_hc)
    result.buy_sell_info.can_buy_own = value_or_empty_string(t.can_buy_own)
    result.buy_sell_info.can_sell_own = value_or_empty_string(t.can_sell_own)
    
    return result
  end
end

request_handlers[qlua_rpc.ProcedureType.GET_BUY_SELL_INFO_EX] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.GetBuySellInfo_Request)
  local t = getBuySellInfoEx(args.firm_id, args.client_code, args.class_code, args.sec_code, args.price) -- returns {} in case of error
  if t == nil then
    error(string.format("Процедура getBuySellInfoEx(%s, %s, %s, %s, %d) возвратила nil.", args.firm_id, args.client_code, args.class_code, args.sec_code, args.price), 0)
  else
    local result = qlua_rpc.GetBuySellInfo_Result()
    
    result.buy_sell_info_ex.buy_sell_info.is_margin_sec = value_or_empty_string(t.is_margin_sec)
    result.buy_sell_info_ex.buy_sell_info.is_asset_sec = value_or_empty_string(t.is_asset_sec)
    result.buy_sell_info_ex.buy_sell_info.balance = value_or_empty_string(t.balance)
    result.buy_sell_info_ex.buy_sell_info.can_buy = value_or_empty_string(t.can_buy)
    result.buy_sell_info_ex.buy_sell_info.can_sell = value_or_empty_string(t.can_sell)
    result.buy_sell_info_ex.buy_sell_info.position_valuation = value_or_empty_string(t.position_valuation)
    result.buy_sell_info_ex.buy_sell_info.value = value_or_empty_string(t.value)
    result.buy_sell_info_ex.buy_sell_info.open_value = value_or_empty_string(t.open_value)
    result.buy_sell_info_ex.buy_sell_info.lim_long = value_or_empty_string(t.lim_long)
    result.buy_sell_info_ex.buy_sell_info.long_coef = value_or_empty_string(t.long_coef)
    result.buy_sell_info_ex.buy_sell_info.lim_short = value_or_empty_string(t.lim_short)
    result.buy_sell_info_ex.buy_sell_info.short_coef = value_or_empty_string(t.short_coef)
    result.buy_sell_info_ex.buy_sell_info.value_coef = value_or_empty_string(t.value_coef)
    result.buy_sell_info_ex.buy_sell_info.open_value_coef = value_or_empty_string(t.open_value_coef)
    result.buy_sell_info_ex.buy_sell_info.share = value_or_empty_string(t.share)
    result.buy_sell_info_ex.buy_sell_info.short_wa_price = value_or_empty_string(t.short_wa_price)
    result.buy_sell_info_ex.buy_sell_info.long_wa_price = value_or_empty_string(t.long_wa_price)
    result.buy_sell_info_ex.buy_sell_info.profit_loss = value_or_empty_string(t.profit_loss)
    result.buy_sell_info_ex.buy_sell_info.spread_hc = value_or_empty_string(t.spread_hc)
    result.buy_sell_info_ex.buy_sell_info.can_buy_own = value_or_empty_string(t.can_buy_own)
    result.buy_sell_info_ex.buy_sell_info.can_sell_own = value_or_empty_string(t.can_sell_own)
    
    result.buy_sell_info_ex.limit_kind = value_to_string_or_empty_string(t.limit_kind)
    result.buy_sell_info_ex.d_long = value_or_empty_string(t.d_long)
    result.buy_sell_info_ex.d_min_long = value_or_empty_string(t.d_min_long)
    result.buy_sell_info_ex.d_short = value_or_empty_string(t.d_short)
    result.buy_sell_info_ex.d_min_short = value_or_empty_string(t.d_min_short)
    result.buy_sell_info_ex.client_type = value_or_empty_string(t.client_type)
    result.buy_sell_info_ex.is_long_allowed = value_or_empty_string(t.is_long_allowed)
    result.buy_sell_info_ex.is_short_allowed = value_or_empty_string(t.is_short_allowed)
    
    return result
  end
end

request_handlers[qlua_rpc.ProcedureType.ADD_COLUMN] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.AddColumn_Request)
  local result = qlua_rpc.AddColumn_Result()
  result.result = AddColumn(args.t_id, args.icode, args.name, args.is_default, utils.to_qtable_parameter_type(args.par_type), args.width) -- returns 0 or 1
  return result
end

request_handlers[qlua_rpc.ProcedureType.ALLOC_TABLE] = function() 
  local result = qlua_rpc.AllocTable_Result()
  result.t_id = AllocTable() -- returns a number
  return result
end

request_handlers[qlua_rpc.ProcedureType.CLEAR] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.Clear_Request)
  local result = qlua_rpc.Clear_Result()
  result.result = Clear(args.t_id) -- returns true or false
  return result
end

request_handlers[qlua_rpc.ProcedureType.CREATE_WINDOW] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.CreateWindow_Request)
  local result = qlua_rpc.CreateWindow_Result()
  result.result = CreateWindow(args.t_id) -- returns 0 or 1
  return result
end

request_handlers[qlua_rpc.ProcedureType.DELETE_ROW] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.DeleteRow_Request)
  local result = qlua_rpc.DeleteRow_Result()
  result.result = DeleteRow(args.t_id, args.key) -- returns true or false
  return result
end

request_handlers[qlua_rpc.ProcedureType.DESTROY_TABLE] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.DestroyTable_Request)
  local result = qlua_rpc.DestroyTable_Result()
  result.result = DestroyTable(args.t_id) -- returns true or false
  return result
end

request_handlers[qlua_rpc.ProcedureType.INSERT_ROW] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.InsertRow_Request)
  local result = qlua_rpc.InsertRow_Result()
  result.result = InsertRow(args.t_id, args.key) -- returns a number
  return result
end

request_handlers[qlua_rpc.ProcedureType.IS_WINDOW_CLOSED] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.IsWindowClosed_Request)
  local ret = IsWindowClosed(args.t_id) -- returns nil in case of error
  if ret == nil then
    error(string.format("Процедура IsWindowClosed(%s) вернула nil.", args.t_id), 0)
  else
    local result = qlua_rpc.IsWindowClosed_Result()
    result.result = ret
    return result
  end
end

request_handlers[qlua_rpc.ProcedureType.GET_CELL] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.GetCell_Request)
  local t_cell = GetCell(args.t_id, args.key, args.code) -- returns nil in case of error
  if t_cell == nil then
    error(string.format("Процедура GetCell(%s, %s, %s) вернула nil.", args.t_id, args.key, args.code), 0)
  else
    local result = qlua_rpc.GetCell_Result()
    result.image = t_cell.image
    if t_cell.value ~= nil then result.value = tostring(t_cell.value) end
    return result
  end
end

request_handlers[qlua_rpc.ProcedureType.SET_CELL] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.SetCell_Request)
  local result = qlua_rpc.SetCell_Result()
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

request_handlers[qlua_rpc.ProcedureType.SET_WINDOW_CAPTION] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.SetWindowCaption_Request)
  local result = qlua_rpc.SetWindowCaption_Result()
  result.result = SetWindowCaption(args.t_id, args.str) -- returns true or false
  return result
end

request_handlers[qlua_rpc.ProcedureType.SET_WINDOW_POS] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.SetWindowPos_Request)
  local result = qlua_rpc.SetWindowPos_Result()
  result.result = SetWindowPos(args.t_id, args.x, args.y, args.dx, args.dy) -- returns true or false
  return result
end

request_handlers[qlua_rpc.ProcedureType.SET_TABLE_NOTIFICATION_CALLBACK] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.SetTableNotificationCallback_Request)  
  local f_cb_ctr, error_msg = loadstring("return "..args.f_cb_def)
  if f_cb_ctr == nil then 
   error(string.format("Не удалось распарсить определение функции из переданной строки. Описание ошибки: [%s].", error_msg), 0)
  else
    local result = qlua_rpc.SetTableNotificationCallback_Result()
    result.result = SetTableNotificationCallback(args.t_id, f_cb_ctr()) -- returns 0 or 1
    return result
  end
end

request_handlers[qlua_rpc.ProcedureType.GET_TABLE_SIZE] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.GetTableSize_Request)
  local rows, col = GetTableSize(args.t_id) -- returns nil in case of error
  if rows == nil or col == nil then
    error(string.format("Процедура GetTableSize(%s) вернула nil.", args.t_id), 0)
  else
    local result = qlua_rpc.GetTableSize_Result()
    result.rows = rows
    result.col = col
    return result
  end
end

request_handlers[qlua_rpc.ProcedureType.GET_WINDOW_CAPTION] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.GetWindowCaption_Request)
  local caption = GetWindowCaption(args.t_id) -- returns nil in case of error
  if caption == nil then 
    error(string.format("Процедура GetWindowCaption(%s) возвратила nil.", args.t_id), 0)
  else
    local result = qlua_rpc.GetWindowCaption_Result()
    result.caption = caption
    return result
  end
end

request_handlers[qlua_rpc.ProcedureType.GET_WINDOW_RECT] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.GetWindowRect_Request)
  local top, left, bottom, right = GetWindowRect(args.t_id) -- returns nil in case of error
  if top == nil or left == nil or bottom == nil or right == nil then
    error(string.format("Процедура GetWindowRect(%s) возвратила nil.", args.t_id), 0)
  else
    local result = qlua_rpc.GetWindowRect_Result()
    result.top = top
    result.left = left
    result.bottom = bottom
    result.right = right
    return result
  end
end

request_handlers[qlua_rpc.ProcedureType.RGB] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.RGB_Request)
  local result = qlua_rpc.RGB_Result()
  -- NB: на самом деле, библиотечная функция RGB должна называться BGR, ибо она выдаёт числа именно в этом формате. В SetColor, однако, тоже ожидается цвет в формате BGR, так что это не баг, а фича.
  result.result = RGB(args.red, args.green, args.blue) -- returns a number
  return result
end

request_handlers[qlua_rpc.ProcedureType.SET_COLOR] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.SetColor_Request)
  local result = qlua_rpc.SetColor_Result()
  result.result = SetColor(args.t_id, args.row, args.col, args.b_color, args.f_color, args.sel_b_color, args.sel_f_color) -- what does it return in case of error ?
  return result
end

request_handlers[qlua_rpc.ProcedureType.HIGHLIGHT] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.Highlight_Request)
  local result = qlua_rpc.Highlight_Result()
  result.result = Highlight(args.t_id, args.row, args.col, args.b_color, args.f_color, args.timeout) -- what does it return in case of error ?
  return result
end

request_handlers[qlua_rpc.ProcedureType.SET_SELECTED_ROW] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.SetSelectedRow_Request)
  local result = qlua_rpc.SetSelectedRow_Result()
  result.result = SetSelectedRow(args.table_id, args.row) -- returns -1 in case of error
  return result
end

request_handlers[qlua_rpc.ProcedureType.ADD_LABEL] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.AddLabel_Request)
  local label_params = utils.create_table(args.label_params)
  local ret = AddLabel(args.chart_tag, label_params) -- returns nil in case of error
  if ret == nil then
    error(string.format("Процедура AddLabel(%s, %s) возвратила nil.", args.chart_tag, utils.table.tostring(label_params)), 0)
  else
    local result = qlua_rpc.AddLabel_Result()
    result.label_id = ret
    return result
  end
end

request_handlers[qlua_rpc.ProcedureType.DEL_LABEL] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.DelLabel_Request)
  local result = qlua_rpc.DelLabel_Result()
  result.result = DelLabel(args.chart_tag, args.label_id) -- returns true or false
  return result
end

request_handlers[qlua_rpc.ProcedureType.DEL_ALL_LABELS] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.DelAllLabels_Request)
  local result = qlua_rpc.DelAllLabels_Result()
  result.result = DelAllLabels(args.chart_tag) -- returns true or false
  return result
end

request_handlers[qlua_rpc.ProcedureType.GET_LABEL_PARAMS] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.GetLabelParams_Request)
  local t = GetLabelParams(args.chart_tag, args.label_id) -- returns nil in case of error
  if t == nil then
    error(string.format("Процедура GetLabelParams(%s, %d) возвратила nil.", args.chart_tag, args.label_id), 0)
  else
    local result = qlua_rpc.GetLabelParams_Result()
    utils.put_to_string_string_pb_map(t, result.label_params, qlua_rpc.GetLabelParams_Result.LabelParamsEntry)
    return result
  end
end

request_handlers[qlua_rpc.ProcedureType.SET_LABEL_PARAMS] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.SetLabelParams_Request)
  local label_params = utils.create_table(args.label_params)
  local result = qlua_rpc.SetLabelParams_Result()
  result.result = SetLabelParams(args.chart_tag, args.label_id, label_params) -- returns true or false
  return result
end

request_handlers[qlua_rpc.ProcedureType.SUBSCRIBE_LEVEL_II_QUOTES] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.SubscribeLevel2Quotes_Request)
  local result = qlua_rpc.SubscribeLevel2Quotes_Result()
  result.result = Subscribe_Level_II_Quotes(args.class_code, args.sec_code) -- returns true or false
  return result
end

request_handlers[qlua_rpc.ProcedureType.UNSUBSCRIBE_LEVEL_II_QUOTES] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.UnsubscribeLevel2Quotes_Request)
  local result = qlua_rpc.UnsubscribeLevel2Quotes_Result()
  result.result = Unsubscribe_Level_II_Quotes(args.class_code, args.sec_code) -- returns true or false
  return result
end

request_handlers[qlua_rpc.ProcedureType.IS_SUBSCRIBED_LEVEL_II_QUOTES] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.IsSubscribedLevel2Quotes_Request)
  local result = qlua_rpc.IsSubscribedLevel2Quotes_Result()
  result.result = IsSubscribed_Level_II_Quotes(args.class_code, args.sec_code) -- returns true or false
  return result
end

request_handlers[qlua_rpc.ProcedureType.PARAM_REQUEST] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.ParamRequest_Request)
  local result = qlua_rpc.ParamRequest_Result()
  result.result = ParamRequest(args.class_code, args.sec_code, args.db_name) -- returns true or false
  return result
end

request_handlers[qlua_rpc.ProcedureType.CANCEL_PARAM_REQUEST] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.CancelParamRequest_Request)
  local result = qlua_rpc.CancelParamRequest_Result()
  result.result = CancelParamRequest(args.class_code, args.sec_code, args.db_name) -- returns true or false
  return result
end

request_handlers[qlua_rpc.ProcedureType.BIT_TOHEX] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.BitToHex_Request)
  local result = qlua_rpc.BitToHex_Result()
  if args.n == 0 then
    result.result = bit.tohex(args.x)
  else
    result.result = bit.tohex(args.x, args.n)
  end
  return result
end

request_handlers[qlua_rpc.ProcedureType.BIT_BNOT] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.BitBNot_Request)
  local result = qlua_rpc.BitBNot_Result()
  result.result = bit.bnot(args.x)
  return result
end

request_handlers[qlua_rpc.ProcedureType.BIT_BAND] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.BitBAnd_Request)
  local result = qlua_rpc.BitBAnd_Result()
  local xs = {args.x1, args.x2}
  for i, e in ipairs(args.xi) do
    table.sinsert(xs, e)
  end

  result.result = bit.band( unpack(xs) )
  return result
end

request_handlers[qlua_rpc.ProcedureType.BIT_BOR] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.BitBOr_Request)
  local result = qlua_rpc.BitBOr_Result()
  local xs = {args.x1, args.x2}
  for i, e in ipairs(args.xi) do
    table.sinsert(xs, e)
  end

  result.result = bit.bor( unpack(xs) )
  return result
end

request_handlers[qlua_rpc.ProcedureType.BIT_BXOR] = function(request_args) 
  local args = parse_request_args(request_args, qlua_rpc.BitBXor_Request)
  local result = qlua_rpc.BitBXor_Result()
  local xs = {args.x1, args.x2}
  for i, e in ipairs(args.xi) do
    table.sinsert(xs, e)
  end

  result.result = bit.bxor( unpack(xs) )
  return result
end

return RequestHandler
