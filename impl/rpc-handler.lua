package.path = "../?.lua;" .. package.path

local qlua = require("qlua.api")

local struct_factory = require("utils.struct_factory")
local struct_converter = require("utils.struct_converter")
local utils = require("utils.utils")
local table = require('table')
local string = require('string')
local bit = require('bit')

local value_to_string_or_empty_string = assert(utils.value_to_string_or_empty_string)
local value_or_empty_string = assert(utils.value_or_empty_string)

local error = assert(error, "error function is missing.")

local module = {
  
  _VERSION = '0.2.0'
}

local datasources = {}

function module.get_datasource(datasource_uid)
  return assert(datasources[datasource_uid], string.format("DataSource c uuid='%s' не найден.", datasource_uid))
end

local function parse_request_args(request_args, request_ctr)
  
  if request_args == nil then error("The request has no arguments.") end
  if request_ctr == nil then error("There's no request constructor function passed in.") end
  -- we can go all defensive and check for the arguments' types as well (table for args, function for ctr), but let's just assume we'll never pass incorrect types :)
  
  local args = request_ctr()
  args:ParseFromString(request_args)
  
  return args
end

local handlers = {}

handlers[qlua.RPC.ProcedureType.IS_CONNECTED] = function()
  
  local proc_result = isConnected()
  
  local result = qlua.isConnected.Result()
  result.is_connected = proc_result
  
  return result
end

handlers[qlua.RPC.ProcedureType.GET_SCRIPT_PATH] = function()
  
  local proc_result = getScriptPath()
  
  local result = qlua.getScriptPath.Result()
  result.script_path = proc_result
  
  return result
end

handlers[qlua.RPC.ProcedureType.GET_INFO_PARAM] = function(request_args)
  
  local args = parse_request_args(request_args, qlua.getInfoParam.Request)
  
  local proc_result = getInfoParam(args.param_name)
  
  local result = qlua.getInfoParam.Result()
  result.info_param = proc_result
  
  return result
end

handlers[qlua.RPC.ProcedureType.MESSAGE] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.message.Request)

  local proc_result = (args.icon_type == qlua.message.IconType.UNDEFINED and message(args.message) or message(args.message, args.icon_type))
  
  if proc_result == nil then
    if args.icon_type == qlua.message.IconType.UNDEFINED then 
      error(string.format("Процедура message(%s) возвратила nil.", args.message))
    else
      error(string.format("Процедура message(%s, %d) возвратила nil.", args.message, args.icon_type))
    end
  else
    local result = qlua.message.Result()
    result.result = proc_result
    return result
  end
end

handlers[qlua.RPC.ProcedureType.SLEEP] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.sleep.Request)
  
  local proc_result = sleep(args.time)
  
  if proc_result == nil then
    error(string.format("Процедура sleep(%d) возвратила nil.", args.time))
  else
    local result = qlua.sleep.Result()
    result.result = proc_result
    return result
  end
end

handlers[qlua.RPC.ProcedureType.GET_WORKING_FOLDER] = function() 
  
  local proc_result = getWorkingFolder()
  
  local result = qlua.getWorkingFolder.Result()
  result.working_folder = proc_result
  
  return result
end

handlers[qlua.RPC.ProcedureType.PRINT_DBG_STR] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.PrintDbgStr.Request)
  
  PrintDbgStr(args.s)
  
  return nil
end

handlers[qlua.RPC.ProcedureType.GET_ITEM] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.getItem.Request)
  
  local proc_result = getItem(args.table_name, args.index)
  
  local result = qlua.getItem.Result()
  if proc_result then
    utils.put_to_string_string_pb_map(proc_result, result.table_row, qlua.getItem.Result.TableRowEntry)
  end
  
  return result
end

handlers[qlua.RPC.ProcedureType.GET_ORDER_BY_NUMBER] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.getOrderByNumber.Request)
  
  local t, i = getOrderByNumber(args.class_code, args.order_id)
  
  if t == nil then
    error(string.format("Процедура getOrderByNumber(%s, %d) вернула (nil, nil).", args.class_code, args.order_id))
  else
    
    local result = qlua.getOrderByNumber.Result()
    struct_factory.create_Order(t, result.order)
    result.indx = i
    
    return result
  end
end

handlers[qlua.RPC.ProcedureType.GET_NUMBER_OF] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.getNumberOf.Request)
  
  local proc_result = getNumberOf(args.table_name) -- returns -1 in case of error
  
  local result = qlua.getNumberOf.Result()
  result.result = proc_result
  
  return result
end

handlers[qlua.RPC.ProcedureType.SEARCH_ITEMS] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.SearchItems.Request)
  
  local fn_ctr, error_msg = loadstring("return "..args.fn_def)
  local items
  if fn_ctr == nil then 
    error(string.format("Не удалось распарсить определение функции из переданной строки. Описание ошибки: %s.", error_msg))
  else
    if args.params == "" then
      items = SearchItems(args.table_name, args.start_index, args.end_index == 0 and (getNumberOf(args.table_name) - 1) or args.end_index, fn_ctr()) -- returns nil in case of empty list found or error
    else 
      items = SearchItems(args.table_name, args.start_index, args.end_index == 0 and (getNumberOf(args.table_name) - 1) or args.end_index, fn_ctr(), args.params) -- returns nil in case of empty list found or error
    end
  end
  
  local result = qlua.SearchItems.Result()
  if items then 
    for i, item_index in ipairs(items) do
      table.sinsert(result.items_indices, item_index)
    end
  end
  
  return result
end

handlers[qlua.RPC.ProcedureType.GET_CLASSES_LIST] = function() 
  
  local proc_result = getClassesList()
  
  local result = qlua.getClassesList.Result()
  result.classes_list = proc_result
  
  return result
end

handlers[qlua.RPC.ProcedureType.GET_CLASS_INFO] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.getClassInfo.Request)

  local proc_result = getClassInfo(args.class_code)
  
  if proc_result == nil then
    error(string.format("Процедура getClassInfo(%s) вернула nil.", args.class_code))
  else
    local result = qlua.getClassInfo.Result()
    struct_factory.create_Klass(proc_result, result.class_info)

    return result
  end
end

handlers[qlua.RPC.ProcedureType.GET_CLASS_SECURITIES] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.getClassSecurities.Request)
  
  local proc_result = getClassSecurities(args.class_code) -- returns an empty string if no securities found for the given class_code
  
  local result = qlua.getClassSecurities.Result()
  result.class_securities = proc_result

  return result
end

handlers[qlua.RPC.ProcedureType.GET_MONEY] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.getMoney.Request)
  
  local proc_result = getMoney(args.client_code, args.firmid, args.tag, args.currcode) -- returns a table with zero'ed values if no info found or in case of error
  
  local result = qlua.getMoney.Result()
  struct_converter.getMoney.Money(proc_result, result.money)
    
  return result
end

handlers[qlua.RPC.ProcedureType.GET_MONEY_EX] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.getMoneyEx.Request)
  
  local proc_result = getMoneyEx(args.firmid, args.client_code, args.tag, args.currcode, args.limit_kind) -- returns nil if no info found or in case of an error
  
  if proc_result == nil then 
    error(string.format("Процедура getMoneyEx(%s, %s, %s, %s, %d) возвратила nil.", args.firmid, args.client_code, args.tag, args.currcode, args.limit_kind))
  else
    local result = qlua.getMoneyEx.Result()
    struct_factory.create_MoneyLimit(proc_result, result.money_ex)
    
    return result
  end
end

handlers[qlua.RPC.ProcedureType.GET_DEPO] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.getDepo.Request)
  
  local proc_result = getDepo(args.client_code, args.firmid, args.sec_code, args.trdaccid) -- returns a table with zero'ed values if no info found or in case of an error

  local result = qlua.getDepo.Result()
  struct_converter.getDepo.Depo(proc_result, result.depo)
  
  return result
end

handlers[qlua.RPC.ProcedureType.GET_DEPO_EX] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.getDepoEx.Request)
  
  local proc_result = getDepoEx(args.firmid, args.client_code, args.sec_code, args.trdaccid, args.limit_kind) -- returns nil if no info found or in case of an error
  
  if proc_result == nil then
    error(string.format("Процедура getDepoEx(%s, %s, %s, %s, %d) возвратила nil.", args.firmid, args.client_code, args.sec_code, args.trdaccid, args.limit_kind))
  else
    local result = qlua.getDepoEx.Result()
    struct_factory.create_DepoLimit(proc_result, result.depo_ex)
    
    return result
  end
end

handlers[qlua.RPC.ProcedureType.GET_FUTURES_LIMIT] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.getFuturesLimit.Request)
  
  local proc_result = getFuturesLimit(args.firmid, args.trdaccid, args.limit_type, args.currcode) -- returns nil if no info found or in case of an error
  
  if proc_result == nil then
    error(string.format("Процедура getFuturesLimit(%s, %s, %d, %s) возвратила nil.", args.firmid, args.trdaccid, args.limit_type, args.currcode))
  else
    local result = qlua.getFuturesLimit.Result()
    struct_factory.create_FuturesLimit(proc_result, result.futures_limit)
    
    return result
  end
end

handlers[qlua.RPC.ProcedureType.GET_FUTURES_HOLDING] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.getFuturesHolding.Request)
  
  local proc_result = getFuturesHolding(args.firmid, args.trdaccid, args.sec_code, args.type) -- returns nil if no info found or in case of an error
   
  if proc_result == nil then
    error(string.format("Процедура getFuturesHolding(%s, %s, %s, %d) возвратила nil.", args.firmid, args.trdaccid, args.sec_code, args.type))
  else
    local result = qlua.getFuturesHolding.Result()
    struct_factory.create_FuturesClientHolding(proc_result, result.futures_holding)
    
    return result
  end
end

handlers[qlua.RPC.ProcedureType.GET_SECURITY_INFO] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.getSecurityInfo.Request)
  
  local proc_result = getSecurityInfo(args.class_code, args.sec_code) -- returns nil if no info found or in case of an error
  
  if proc_result == nil then
    error(string.format("Процедура getSecurityInfo(%s, %s) возвратила nil.", args.class_code, args.sec_code))
  else
    local result = qlua.getSecurityInfo.Result()
    struct_factory.create_Security(proc_result, result.security_info)
    
    return result
  end
end

handlers[qlua.RPC.ProcedureType.GET_TRADE_DATE] = function() 
  
  local result = qlua.getTradeDate.Result()
  
  local proc_result = getTradeDate()
  struct_converter.getTradeDate.TradeDate(proc_result, result.trade_date)
  
  return result
end

handlers[qlua.RPC.ProcedureType.GET_QUOTE_LEVEL2] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.getQuoteLevel2.Request)
  
  local proc_result = getQuoteLevel2(args.class_code, args.sec_code)

  return struct_converter.getQuoteLevel2.Result(proc_result)
end

handlers[qlua.RPC.ProcedureType.GET_LINES_COUNT] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.getLinesCount.Request)
  
  local proc_result = getLinesCount(args.tag) -- returns 0 if no chart with this tag found
  
  local result = qlua.getLinesCount.Result()
  result.lines_count = proc_result
  
  return result
end

handlers[qlua.RPC.ProcedureType.GET_NUM_CANDLES] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.getNumCandles.Request)
  
  local proc_result = getNumCandles(args.tag) -- returns 0 if no chart with this tag found
  
  local result = qlua.getNumCandles.Result()
  result.num_candles = proc_result
  
  return result
end

handlers[qlua.RPC.ProcedureType.GET_CANDLES_BY_INDEX] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.getCandlesByIndex.Request)
  
  local t, n, l = getCandlesByIndex(args.tag, args.line, args.first_candle, args.count) -- returns ({}, 0, "") if no info found or in case of error
  
  return struct_converter.getCandlesByIndex.Result(t, n, l)
end

handlers[qlua.RPC.ProcedureType.CREATE_DATA_SOURCE] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.datasource.CreateDataSource.Request)
  
  local interval = utils.to_interval(args.interval)
  
  local ds, error_desc
  if args.param == nil or args.param == "" then
    ds, error_desc = CreateDataSource(args.class_code, args.sec_code, interval)
    if ds == nil then
      error(string.format("Процедура CreateDataSource(%s, %s, %d) возвратила nil и сообщение об ошибке: [%s].", args.class_code, args.sec_code, interval, error_desc))
    end
  else 
    ds, error_desc = CreateDataSource(args.class_code, args.sec_code, interval, args.param)
    if ds == nil then
      error(string.format("Процедура CreateDataSource(%s, %s, %d, %s) возвратила nil и сообщение об ошибке: [%s].", args.class_code, args.sec_code, interval, args.param, error_desc))
    end
  end
  
  local result = qlua.datasource.CreateDataSource.Result()
  result.datasource_uuid = uuid()
  datasources[result.datasource_uuid] = ds
  
  return result
end

handlers[qlua.RPC.ProcedureType.DS_SET_UPDATE_CALLBACK] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.datasource.SetUpdateCallback.Request)
  
  local ds = module.get_datasource(args.datasource_uuid)
  
  local f_cb_ctr, error_msg = loadstring("return "..args.f_cb_def)
  if f_cb_ctr == nil then 
    error( string.format("Не удалось распарсить определение функции из переданной строки. Описание ошибки: %s.", error_msg) )
  else
    local f_cb = f_cb_ctr()
    local callback = function(index) f_cb(index, ds) end
    
    local result = qlua.datasource.SetUpdateCallback.Result()
    result.result = ds:SetUpdateCallback(callback)
    
    return result
  end
end

handlers[qlua.RPC.ProcedureType.DS_O] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.datasource.O.Request)
 
  local ds = module.get_datasource(args.datasource_uuid)
  
  local result = qlua.datasource.O.Result()
  result.value = tostring( ds:O(args.candle_index) )
  
  return result
end

handlers[qlua.RPC.ProcedureType.DS_H] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.datasource.H.Request)
 
  local ds = module.get_datasource(args.datasource_uuid)
  
  local result = qlua.datasource.H.Result()
  result.value = tostring( ds:H(args.candle_index) )
  
  return result
end

handlers[qlua.RPC.ProcedureType.DS_L] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.datasource.L.Request)
 
  local ds = module.get_datasource(args.datasource_uuid)
  
  local result = qlua.datasource.L.Result()
  result.value = tostring( ds:L(args.candle_index) )
  
  return result
end

handlers[qlua.RPC.ProcedureType.DS_C] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.datasource.C.Request)
 
  local ds = module.get_datasource(args.datasource_uuid)
  
  local result = qlua.datasource.C.Result()
  result.value = tostring( ds:C(args.candle_index) )
  
  return result
end

handlers[qlua.RPC.ProcedureType.DS_V] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.datasource.V.Request)
 
  local ds = module.get_datasource(args.datasource_uuid)
  
  local result = qlua.datasource.V.Result()
  result.value = tostring( ds:V(args.candle_index) )
  
  return result
end

handlers[qlua.RPC.ProcedureType.DS_T] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.datasource.T.Request)
  
  local ds = module.get_datasource(args.datasource_uuid)
  
  local result = qlua.datasource.T.Result()
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

handlers[qlua.RPC.ProcedureType.DS_SIZE] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.datasource.Size.Request)
  
  local ds = module.get_datasource(args.datasource_uuid)

  local result = qlua.datasource.Size.Result()
  result.value = ds:Size()
  
  return result
end

handlers[qlua.RPC.ProcedureType.DS_CLOSE] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.datasource.Close.Request)
  
  local ds = module.get_datasource(args.datasource_uuid)
  
  local result = qlua.datasource.Close.Result()
  result.result = ds:Close()
  
  return result
end

handlers[qlua.RPC.ProcedureType.DS_SET_EMPTY_CALLBACK] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.datasource.SetEmptyCallback.Request)
  
  local ds = module.get_datasource(args.datasource_uuid)
  
  local result = qlua.datasource.SetEmptyCallback.Result()
  result.result = ds:SetEmptyCallback()
  
  return result
end

handlers[qlua.RPC.ProcedureType.SEND_TRANSACTION] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.sendTransaction.Request)
  
  local t = utils.create_table(args.transaction)
  
  local res = sendTransaction(t) -- returns an empty string (seems to be always)
  
  local result = qlua.sendTransaction.Result()
  result.result = res
  
  return result
end

handlers[qlua.RPC.ProcedureType.CALC_BUY_SELL] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.CalcBuySell.Request)

  local price = tonumber(args.price)
  if price == nil then
    error(string.format("Не удалось преобразовать в число значение '%s' параметра price", args.price), 0) 
  end
  
  local qty, comission = CalcBuySell(args.class_code, args.sec_code, args.client_code, args.account, price, args.is_buy, args.is_market) -- returns (0; 0) in case of error
  
  local result = qlua.CalcBuySell.Result()
  result.qty = qty
  result.comission = tostring(comission)
  
  return result
end

handlers[qlua.RPC.ProcedureType.GET_PARAM_EX] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.getParamEx.Request)
  
  local res = getParamEx(args.class_code, args.sec_code, args.param_name) -- always returns a table
  
  if res == nil then
    error(string.format("Процедура getParamEx(%s, %s, %s) возвратила nil.", args.class_code, args.sec_code, args.param_name), 0)
  end
  
  local result = qlua.getParamEx.Result()
  struct_converter.getParamEx.ParamEx(res, result.param_ex)
    
  return result
end

handlers[qlua.RPC.ProcedureType.GET_PARAM_EX_2] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.getParamEx2.Request)
  
  local res = getParamEx2(args.class_code, args.sec_code, args.param_name) -- always returns a table
  
  if res == nil then
    error(string.format("Процедура getParamEx2(%s, %s, %s) возвратила nil.", args.class_code, args.sec_code, args.param_name), 0)
  end
  
  local result = qlua.getParamEx2.Result()
  struct_converter.getParamEx2.ParamEx2(res, result.param_ex)
  
  return result
end

handlers[qlua.RPC.ProcedureType.GET_PORTFOLIO_INFO] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.getPortfolioInfo.Request)
  
  local res = getPortfolioInfo(args.firm_id, args.client_code) -- returns {} in case of error
  
  if res == nil then
    error(string.format("Процедура getPortfolioInfo(%s, %s) возвратила nil.", args.firm_id, args.client_code), 0)
  end
  
  local result = qlua.getPortfolioInfo.Result()
  struct_converter.getPortfolioInfo.PortfolioInfo(res, result.portfolio_info)
  
  return result
end

handlers[qlua.RPC.ProcedureType.GET_PORTFOLIO_INFO_EX] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.getPortfolioInfoEx.Request)
  
  local res = getPortfolioInfoEx(args.firm_id, args.client_code, args.limit_kind) -- returns {} in case of error
  
  if res == nil then
    error(string.format("Процедура getPortfolioInfoEx(%s, %s, %d) возвратила nil.", args.firm_id, args.client_code, args.limit_kind), 0)
  end
  
  local result = qlua.getPortfolioInfoEx.Result()
  struct_converter.getPortfolioInfoEx.PortfolioInfoEx(res, result.portfolio_info_ex)
  
  return result
end

handlers[qlua.RPC.ProcedureType.GET_BUY_SELL_INFO] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.getBuySellInfo.Request)
  
  local price = tonumber(args.price)
  if price == nil then 
    error(string.format("Не удалось преобразовать в число значение '%s' параметра price", args.price), 0)
  end
  
  local res = getBuySellInfo(args.firm_id, args.client_code, args.class_code, args.sec_code, price) -- returns {} in case of error
  if res == nil then
    error(string.format("Процедура getBuySellInfo(%s, %s, %s, %s, %s) возвратила nil.", args.firm_id, args.client_code, args.class_code, args.sec_code, args.price), 0)
  end
  
  local result = qlua.getBuySellInfo.Result()
  struct_converter.getBuySellInfo.BuySellInfo(res, result.buy_sell_info)
  
  return result
end

handlers[qlua.RPC.ProcedureType.GET_BUY_SELL_INFO_EX] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.getBuySellInfoEx.Request)
  
  local price = tonumber(args.price)
  if price == nil then 
    error(string.format("Не удалось преобразовать в число значение '%s' параметра price", args.price), 0)
  end
  
  local res = getBuySellInfoEx(args.firm_id, args.client_code, args.class_code, args.sec_code, price) -- returns {} in case of error
  if res == nil then
    error(string.format("Процедура getBuySellInfoEx(%s, %s, %s, %s, %s) возвратила nil.", args.firm_id, args.client_code, args.class_code, args.sec_code, args.price), 0)
  end
  
  local result = qlua.getBuySellInfoEx.Result()
  struct_converter.getBuySellInfoEx.BuySellInfoEx(res, result.buy_sell_info_ex)
  
  return result
end

handlers[qlua.RPC.ProcedureType.ADD_COLUMN] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.AddColumn.Request)
  
  local res = AddColumn(args.t_id, args.icode, args.name, args.is_default, utils.to_qtable_parameter_type(args.par_type), args.width) -- returns 0 or 1
  
  local result = qlua.AddColumn.Result()
  result.result = res
  
  return result
end

handlers[qlua.RPC.ProcedureType.ALLOC_TABLE] = function() 
  
  local t_id = AllocTable() -- returns a number
  
  local result = qlua.AllocTable.Result()
  result.t_id = t_id
  
  return result
end

handlers[qlua.RPC.ProcedureType.CLEAR] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.Clear.Request)
  
  local res = Clear(args.t_id) -- returns true or false
  
  local result = qlua.Clear.Result()
  result.result = res
  
  return result
end

handlers[qlua.RPC.ProcedureType.CREATE_WINDOW] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.CreateWindow.Request)
  
  local res = CreateWindow(args.t_id) -- returns 0 or 1
  
  local result = qlua.CreateWindow.Result()
  result.result = res
  
  return result
end

handlers[qlua.RPC.ProcedureType.DELETE_ROW] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.DeleteRow.Request)
  
  local res = DeleteRow(args.t_id, args.key) -- returns true or false
  
  local result = qlua.DeleteRow.Result()
  result.result = res
  
  return result
end

handlers[qlua.RPC.ProcedureType.DESTROY_TABLE] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.DestroyTable.Request)
  
  local res = DestroyTable(args.t_id) -- returns true or false
  
  local result = qlua.DestroyTable.Result()
  result.result = res
  
  return result
end

handlers[qlua.RPC.ProcedureType.INSERT_ROW] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.InsertRow.Request)
  
  local res = InsertRow(args.t_id, args.key) -- returns a number
  
  local result = qlua.InsertRow.Result()
  result.result = res
  
  return result
end

handlers[qlua.RPC.ProcedureType.IS_WINDOW_CLOSED] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.IsWindowClosed.Request)
  
  local ret = IsWindowClosed(args.t_id) -- returns nil in case of error
  
  if ret == nil then
    error( string.format("Процедура IsWindowClosed(%s) вернула nil.", args.t_id) )
  else
    local result = qlua.IsWindowClosed.Result()
    result.result = ret
    return result
  end
end

handlers[qlua.RPC.ProcedureType.GET_CELL] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.GetCell.Request)
  
  local res = GetCell(args.t_id, args.key, args.code) -- returns nil in case of error
  
  if res == nil then
    error(string.format("Процедура GetCell(%s, %s, %s) вернула nil.", args.t_id, args.key, args.code), 0)
  end
  
  local result = qlua.GetCell.Result()
  result.image = res.image
  if res.value then result.value = tostring(res.value) end
  
  return result
end

handlers[qlua.RPC.ProcedureType.SET_CELL] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.SetCell.Request)
  
  local res
  if args.value == 0 then
    res = SetCell(args.t_id, args.key, args.code, args.text) -- returns true or false
  else
    res = SetCell(args.t_id, args.key, args.code, args.text, args.value) -- returns true or false
  end
  
  local result = qlua.SetCell.Result()
  result.result = res
  
  return result
end

handlers[qlua.RPC.ProcedureType.SET_WINDOW_CAPTION] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.SetWindowCaption.Request)
  
  local res = SetWindowCaption(args.t_id, args.str) -- returns true or false
  
  local result = qlua.SetWindowCaption.Result()
  result.result = res
  
  return result
end

handlers[qlua.RPC.ProcedureType.SET_WINDOW_POS] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.SetWindowPos.Request)
  
  local res = SetWindowPos(args.t_id, args.x, args.y, args.dx, args.dy) -- returns true or false
  
  local result = qlua.SetWindowPos.Result()
  result.result = res
  
  return result
end

handlers[qlua.RPC.ProcedureType.SET_TABLE_NOTIFICATION_CALLBACK] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.SetTableNotificationCallback.Request)  
  
  local f_cb_ctr, error_msg = loadstring("return "..args.f_cb_def)
  
  if f_cb_ctr == nil then 
   error( string.format("Не удалось распарсить определение функции из переданной строки. Описание ошибки: [%s].", error_msg) )
  end
  
  local res = SetTableNotificationCallback(args.t_id, f_cb_ctr()) -- returns 0 or 1
  
  local result = qlua.SetTableNotificationCallback.Result()
  result.result = res
  
  return result
end

handlers[qlua.RPC.ProcedureType.GET_TABLE_SIZE] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.GetTableSize.Request)
  
  local rows, col = GetTableSize(args.t_id) -- returns nil in case of error
  
  if rows == nil or col == nil then
    error(string.format("Процедура GetTableSize(%s) возвратила nil.", args.t_id), 0)
  end
  
  local result = qlua.GetTableSize.Result()
  result.rows = rows
  result.col = col
  
  return result
end

handlers[qlua.RPC.ProcedureType.GET_WINDOW_CAPTION] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.GetWindowCaption.Request)
  
  local res = GetWindowCaption(args.t_id) -- returns nil in case of error
  
  if res == nil then 
    error(string.format("Процедура GetWindowCaption(%s) возвратила nil.", args.t_id), 0)
  end
  
  local result = qlua.GetWindowCaption.Result()
  result.caption = utils.Cp1251ToUtf8(res)
    
    return result
end

handlers[qlua.RPC.ProcedureType.GET_WINDOW_RECT] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.GetWindowRect.Request)
  
  local top, left, bottom, right = GetWindowRect(args.t_id) -- returns nil in case of error
  
  if top == nil or left == nil or bottom == nil or right == nil then
    error(string.format("Процедура GetWindowRect(%s) возвратила nil.", args.t_id), 0)
  end
  
  local result = qlua.GetWindowRect.Result()
  result.top = top
  result.left = left
  result.bottom = bottom
  result.right = right
  
  return result
end

handlers[qlua.RPC.ProcedureType.RGB] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.RGB.Request)
  
  -- NB: на самом деле, библиотечная функция RGB должна называться BGR, ибо она выдаёт числа именно в этом формате. В SetColor, однако, тоже ожидается цвет в формате BGR, так что это не баг, а фича.
  local res = RGB(args.red, args.green, args.blue) -- returns a number
  
  local result = qlua.RGB.Result()
  result.result = res
  
  return result
end

handlers[qlua.RPC.ProcedureType.SET_COLOR] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.SetColor.Request)
  
  local res =  SetColor(args.t_id, args.row, args.col, args.b_color, args.f_color, args.sel_b_color, args.sel_f_color) -- what does it return in case of error ?
  
  local result = qlua.SetColor.Result()
  result.result = res
  
  return result
end

handlers[qlua.RPC.ProcedureType.HIGHLIGHT] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.Highlight.Request)
  
  local res = Highlight(args.t_id, args.row, args.col, args.b_color, args.f_color, args.timeout) -- what does it return in case of error ?
  
  local result = qlua.Highlight.Result()
  result.result = res
  
  return result
end

handlers[qlua.RPC.ProcedureType.SET_SELECTED_ROW] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.SetSelectedRow.Request)
  
  local res = SetSelectedRow(args.table_id, args.row) -- returns -1 in case of error
  
  if res == -1 then 
    error(string.format("Процедура SetSelectedRow(%d, %d) возвратила -1.", args.table_id, args.row), 0)
  end
  
  local result = qlua.SetSelectedRow.Result()
  result.result = res
  
  return result
end

handlers[qlua.RPC.ProcedureType.ADD_LABEL] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.AddLabel.Request)
  
  local label_params = utils.create_table(args.label_params)
  local res = AddLabel(args.chart_tag, label_params) -- returns nil in case of error
  
  if res == nil then
    error(string.format("Процедура AddLabel(%s, %s) возвратила nil.", args.chart_tag, utils.table.tostring(label_params)), 0)
  end
  
  local result = qlua.AddLabel.Result()
  result.label_id = res
    
  return result
end

handlers[qlua.RPC.ProcedureType.DEL_LABEL] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.DelLabel.Request)
  
  local res = DelLabel(args.chart_tag, args.label_id) -- returns true or false
  
  local result = qlua.DelLabel.Result()
  result.result = res
  
  return result
end

handlers[qlua.RPC.ProcedureType.DEL_ALL_LABELS] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.DelAllLabels.Request)
  
  local res = DelAllLabels(args.chart_tag) -- returns true or false
  
  local result = qlua.DelAllLabels.Result()
  result.result = res
  
  return result
end

handlers[qlua.RPC.ProcedureType.GET_LABEL_PARAMS] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.GetLabelParams.Request)
  
  local res = GetLabelParams(args.chart_tag, args.label_id) -- returns nil in case of error
  if res == nil then
    error(string.format("Процедура GetLabelParams(%s, %d) возвратила nil.", args.chart_tag, args.label_id), 0)
  end
  
  local result = qlua.GetLabelParams.Result()
  utils.put_to_string_string_pb_map(res, result.label_params, qlua.GetLabelParams.Result.LabelParamsEntry)
  
  return result
end

handlers[qlua.RPC.ProcedureType.SET_LABEL_PARAMS] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.SetLabelParams.Request)
  
  local label_params = utils.create_table(args.label_params)
  
  local res = SetLabelParams(args.chart_tag, args.label_id, label_params) -- returns true or false
  
  local result = qlua.SetLabelParams.Result()
  result.result = res
  
  return result
end

handlers[qlua.RPC.ProcedureType.SUBSCRIBE_LEVEL_II_QUOTES] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.Subscribe_Level_II_Quotes.Request)
  
  local res = Subscribe_Level_II_Quotes(args.class_code, args.sec_code) -- returns true or false
  
  local result = qlua.Subscribe_Level_II_Quotes.Result()
  result.result = res
  
  return result
end

handlers[qlua.RPC.ProcedureType.UNSUBSCRIBE_LEVEL_II_QUOTES] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.Unsubscribe_Level_II_Quotes.Request)
  
  local res = Unsubscribe_Level_II_Quotes(args.class_code, args.sec_code) -- returns true or false
  
  local result = qlua.Unsubscribe_Level_II_Quotes.Result()
  result.result = res
  
  return result
end

handlers[qlua.RPC.ProcedureType.IS_SUBSCRIBED_LEVEL_II_QUOTES] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.IsSubscribed_Level_II_Quotes.Request)
  
  local res = IsSubscribed_Level_II_Quotes(args.class_code, args.sec_code) -- returns true or false
  
  local result = qlua.IsSubscribed_Level_II_Quotes.Result()
  result.result = res
  
  return result
end

handlers[qlua.RPC.ProcedureType.PARAM_REQUEST] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.ParamRequest.Request)
  
  local res = ParamRequest(args.class_code, args.sec_code, args.db_name) -- returns true or false
  
  local result = qlua.ParamRequest.Result()
  result.result = res
  
  return result
end

handlers[qlua.RPC.ProcedureType.CANCEL_PARAM_REQUEST] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.CancelParamRequest.Request)
  
  local res = CancelParamRequest(args.class_code, args.sec_code, args.db_name) -- returns true or false
  
  local result = qlua.CancelParamRequest.Result()
  result.result = res
  
  return result
end

handlers[qlua.RPC.ProcedureType.BIT_TOHEX] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.bit.tohex.Request)

  local res
  if args.n == 0 then
    res = bit.tohex(args.x)
  else
    res = bit.tohex(args.x, args.n)
  end
  
  local result = qlua.bit.tohex.Result()
  result.result = res

  return result
end

handlers[qlua.RPC.ProcedureType.BIT_BNOT] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.bit.bnot.Request)
  
  local res = bit.bnot(args.x)
  
  local result = qlua.bit.bnot.Result()
  result.result = res
  
  return result
end

handlers[qlua.RPC.ProcedureType.BIT_BAND] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.bit.band.Request)
  
  local xs = {args.x1, args.x2}
  for i, e in ipairs(args.xi) do
    table.sinsert(xs, e)
  end

  local result = qlua.bit.band.Result()
  result.result = bit.band( unpack(xs) )
  
  return result
end

handlers[qlua.RPC.ProcedureType.BIT_BOR] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.bit.bor.Request)
  
  local xs = {args.x1, args.x2}
  for i, e in ipairs(args.xi) do
    table.sinsert(xs, e)
  end
  
  local result = qlua.bit.bor.Result()
  result.result = bit.bor( unpack(xs) )
  
  return result
end

handlers[qlua.RPC.ProcedureType.BIT_BXOR] = function(request_args) 
  
  local args = parse_request_args(request_args, qlua.bit.bxor.Request)
  
  local xs = {args.x1, args.x2}
  for i, e in ipairs(args.xi) do
    table.sinsert(xs, e)
  end

  local result = qlua.bit.bxor.Result()
  result.result = bit.bxor( unpack(xs) )
  
  return result
end

function module.call_procedure(procedure_type, procedure_args)
  
  local handler = handlers[procedure_type]

  if handler == nil then 
    error(string.format("Unknown procedure type: %d.", procedure_type), 0)
  else
    return handler(procedure_args)
  end
end

return module
