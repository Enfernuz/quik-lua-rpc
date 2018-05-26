package.path = "../?.lua;" .. package.path

local qlua = require("qlua.api")
local utils = require("utils.utils")
local struct_factory = require("utils.struct_factory")

local pb = require("pb")
local qlua_pb_types = require("qlua.qlua_pb_types")

local module = {}

local method_names = {}
local procedure_types = {}
local args_prototypes = {}
local result_object_mappers = {}

-- unknown
method_names["PROCEDURE_TYPE_UNKNOWN"] = "unknown" -- TODO: maybe set it to nil?
procedure_types[method_names["PROCEDURE_TYPE_UNKNOWN"]] = "PROCEDURE_TYPE_UNKNOWN"

-- isConnected
method_names["IS_CONNECTED"] = "isConnected"
procedure_types[method_names["IS_CONNECTED"]] = "IS_CONNECTED"
args_prototypes["IS_CONNECTED"] = nil
result_object_mappers[method_names["IS_CONNECTED"]] = function (proc_result)
  
  local result = pb.defaults(qlua_pb_types.isConnected.Result)
  result.is_connected = proc_result
  return qlua_pb_types.isConnected.Result, result
end

-- getScriptPath
method_names["GET_SCRIPT_PATH"] = "getScriptPath"
procedure_types[method_names["GET_SCRIPT_PATH"]] = "GET_SCRIPT_PATH"
args_prototypes["GET_SCRIPT_PATH"] = nil
result_object_mappers[method_names["GET_SCRIPT_PATH"]] = function (proc_result)
  
  local result = pb.defaults(qlua_pb_types.getScriptPath.Result)
  result.script_path = proc_result
  return qlua_pb_types.getScriptPath.Result, result
end

-- getInfoParam
method_names["GET_INFO_PARAM"] = "getInfoParam"
procedure_types[method_names["GET_INFO_PARAM"]] = "GET_INFO_PARAM"
args_prototypes["GET_INFO_PARAM"] = qlua_pb_types.getInfoParam.Request
result_object_mappers[method_names["GET_INFO_PARAM"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getInfoParam.Result)
  result.info_param = proc_result
  return qlua_pb_types.getInfoParam.Result, result
end

-- message
method_names["MESSAGE"] = "message"
procedure_types[method_names["MESSAGE"]] = "MESSAGE"
args_prototypes["MESSAGE"] = qlua_pb_types.message.Request
result_object_mappers[method_names["MESSAGE"]] = function (proc_result)
  
  local result = pb.defaults(qlua_pb_types.message.Result)
  result.result = proc_result
  return qlua_pb_types.message.Result, result
end

-- sleep
method_names["SLEEP"] = "sleep"
procedure_types[method_names["SLEEP"]] = "SLEEP"
args_prototypes["SLEEP"] = qlua_pb_types.sleep.Request
result_object_mappers[method_names["SLEEP"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.sleep.Result)
  result.result = proc_result
  return qlua_pb_types.sleep.Result, result
end

-- getWorkingFolder
method_names["GET_WORKING_FOLDER"] = "getWorkingFolder"
procedure_types[method_names["GET_WORKING_FOLDER"]] = "GET_WORKING_FOLDER"
args_prototypes["GET_WORKING_FOLDER"] = nil
result_object_mappers[method_names["GET_WORKING_FOLDER"]] = function (proc_result)
  
  local result = pb.defaults(qlua_pb_types.getWorkingFolder.Result)
  result.working_folder = proc_result
  return qlua_pb_types.getWorkingFolder.Result, result
end

-- PrintDbgStr
method_names["PRINT_DBG_STR"] = "PrintDbgStr"
procedure_types[method_names["PRINT_DBG_STR"]] = "PRINT_DBG_STR"
args_prototypes["PRINT_DBG_STR"] = qlua_pb_types.PrintDbgStr.Request
result_object_mappers[method_names["PRINT_DBG_STR"]] = nil

-- getItem
method_names["GET_ITEM"] = "getItem"
procedure_types[method_names["GET_ITEM"]] = "GET_ITEM"
args_prototypes["GET_ITEM"] = qlua_pb_types.getItem.Request
result_object_mappers[method_names["GET_ITEM"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getItem.Result)
  for k, v in pairs(proc_result) do
    result.table_row[k] = v
  end

  return result
end

-- getOrderByNumber
method_names["GET_ORDER_BY_NUMBER"] = "getOrderByNumber"
procedure_types[method_names["GET_ORDER_BY_NUMBER"]] = "GET_ORDER_BY_NUMBER"
args_prototypes["GET_ORDER_BY_NUMBER"] = qlua_pb_types.getOrderByNumber.Request
result_object_mappers[method_names["GET_ORDER_BY_NUMBER"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getOrderByNumber.Result)
  
  local order = proc_result.order
  if order then
    result.order = pb.defaults(qlua_pb_types.qlua_structures.Order)
    for k, v in pairs(order) do
      result.order[k] = v
    end
  end
  
  local indx = proc_result.indx
  if indx then 
    result.indx = indx
  end
  
  return qlua_pb_types.getOrderByNumber.Result, result
end

-- getNumberOf
method_names["GET_NUMBER_OF"] = "getNumberOf"
procedure_types[method_names["GET_NUMBER_OF"]] = "GET_NUMBER_OF"
args_prototypes["GET_NUMBER_OF"] = qlua_pb_types.getNumberOf.Request
result_object_mappers[method_names["GET_NUMBER_OF"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getNumberOf.Result)
  result.result = proc_result
  return qlua_pb_types.getNumberOf.Result, result
end

-- SearchItems
method_names["SEARCH_ITEMS"] = "SearchItems"
procedure_types[method_names["SEARCH_ITEMS"]] = "SEARCH_ITEMS"
args_prototypes["SEARCH_ITEMS"] = qlua_pb_types.SearchItems.Request
result_object_mappers[method_names["SEARCH_ITEMS"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.SearchItems.Result)
  if proc_result then 
    result.items_indices = proc_result
  end
  return qlua_pb_types.SearchItems.Result, result
end

-- getClassesList
method_names["GET_CLASSES_LIST"] = "getClassesList"
procedure_types[method_names["GET_CLASSES_LIST"]] = "GET_CLASSES_LIST"
args_prototypes["GET_CLASSES_LIST"] = qlua_pb_types.getClassesList.Request
result_object_mappers[method_names["GET_CLASSES_LIST"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getClassesList.Result)
  if proc_result then 
    result.classes_list = proc_result
  end
  return qlua_pb_types.getClassesList.Result, result
end

-- getClassInfo
method_names["GET_CLASS_INFO"] = "getClassInfo"
procedure_types[method_names["GET_CLASS_INFO"]] = "GET_CLASS_INFO"
args_prototypes["GET_CLASS_INFO"] = qlua_pb_types.getClassInfo.Request
result_object_mappers[method_names["GET_CLASS_INFO"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getClassInfo.Result)
  result.class_info = pb.defaults(qlua_pb_types.qlua_structures.Klass)
  for k, v in pairs(proc_result) do
    result.class_info[k] = v
  end
  
  return qlua_pb_types.getClassInfo.Result, result
end

-- getClassSecurities
method_names["GET_CLASS_SECURITIES"] = "getClassSecurities"
procedure_types[method_names["GET_CLASS_SECURITIES"]] = "GET_CLASS_SECURITIES"
args_prototypes["GET_CLASS_SECURITIES"] = qlua_pb_types.getClassSecurities.Request
result_object_mappers[method_names["GET_CLASS_SECURITIES"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getClassSecurities.Result)
  if proc_result then 
    result.class_securities = proc_result
  end
  return qlua_pb_types.getClassSecurities.Result, result
end

-- getMoney
method_names["GET_MONEY"] = "getMoney"
procedure_types[method_names["GET_MONEY"]] = "GET_MONEY"
args_prototypes["GET_MONEY"] = qlua_pb_types.getMoney.Request
result_object_mappers[method_names["GET_MONEY"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getMoney.Result)
  result.money = pb.defaults(qlua_pb_types.getMoney.Money)
  for k, v in pairs(proc_result) do
    result.money[k] = v
  end
  
  return qlua_pb_types.getMoney.Result, result
end

-- getMoneyEx
method_names["GET_MONEY_EX"] = "getMoneyEx"
procedure_types[method_names["GET_MONEY_EX"]] = "GET_MONEY_EX"
args_prototypes["GET_MONEY_EX"] = qlua_pb_types.getMoneyEx.Request
result_object_mappers[method_names["GET_MONEY_EX"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getMoneyEx.Result)
  result.money_ex = pb.defaults(qlua_pb_types.qlua_structures.MoneyLimit)
  for k, v in pairs(proc_result) do
    result.money_ex[k] = v
  end
  
  return qlua_pb_types.getMoneyEx.Result, result
end

-- getDepo
method_names["GET_DEPO"] = "getDepo"
procedure_types[method_names["GET_DEPO"]] = "GET_DEPO"
args_prototypes["GET_DEPO"] = qlua_pb_types.getDepo.Request
result_object_mappers[method_names["GET_DEPO"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getDepo.Result)
  result.depo = pb.defaults(qlua_pb_types.getDepo.Depo)
  for k, v in pairs(proc_result) do
    result.depo[k] = v
  end
  
  return qlua_pb_types.getDepo.Result, result
end

-- getDepoEx
method_names["GET_DEPO_EX"] = "getDepoEx"
procedure_types[method_names["GET_DEPO_EX"]] = "GET_DEPO_EX"
args_prototypes["GET_DEPO_EX"] = qlua_pb_types.getDepoEx.Request
result_object_mappers[method_names["GET_DEPO_EX"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getDepoEx.Result)
  result.depo_ex = pb.defaults(qlua_pb_types.qlua_structures.DepoLimit)
  for k, v in pairs(proc_result) do
    result.depo_ex[k] = v
  end
  
  return qlua_pb_types.getDepoEx.Result, result
end

-- getFuturesLimit
method_names["GET_FUTURES_LIMIT"] = "getFuturesLimit"
procedure_types[method_names["GET_FUTURES_LIMIT"]] = "GET_FUTURES_LIMIT"
args_prototypes["GET_FUTURES_LIMIT"] = qlua_pb_types.getFuturesLimit.Request
result_object_mappers[method_names["GET_FUTURES_LIMIT"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getFuturesLimit.Result)
  result.futures_limit = pb.defaults(qlua_pb_types.qlua_structures.FuturesLimit)
  for k, v in pairs(proc_result) do
    result.futures_limit[k] = v
  end
  
  return qlua_pb_types.getFuturesLimit.Result, result
end

-- getFuturesHolding
method_names["GET_FUTURES_HOLDING"] = "getFuturesHolding"
procedure_types[method_names["GET_FUTURES_HOLDING"]] = "GET_FUTURES_HOLDING"
args_prototypes["GET_FUTURES_HOLDING"] = qlua_pb_types.getFuturesHolding.Request
result_object_mappers[method_names["GET_FUTURES_HOLDING"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getFuturesHolding.Result)
  result.futures_holding = pb.defaults(qlua_pb_types.qlua_structures.FuturesClientHolding)
  for k, v in pairs(proc_result) do
    result.futures_holding[k] = v
  end
  
  return qlua_pb_types.getFuturesHolding.Result, result
end

-- getSecurityInfo
method_names["GET_SECURITY_INFO"] = "getSecurityInfo"
procedure_types[method_names["GET_SECURITY_INFO"]] = "GET_SECURITY_INFO"
args_prototypes["GET_SECURITY_INFO"] = qlua_pb_types.getSecurityInfo.Request
result_object_mappers[method_names["GET_SECURITY_INFO"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getSecurityInfo.Result)
  result.security_info = pb.defaults(qlua_pb_types.qlua_structures.Security)
  for k, v in pairs(proc_result) do
    result.security_info[k] = v
  end
  
  return qlua_pb_types.getSecurityInfo.Result, result
end

-- getTradeDate
method_names["GET_TRADE_DATE"] = "getTradeDate"
procedure_types[method_names["GET_TRADE_DATE"]] = "GET_TRADE_DATE"
args_prototypes["GET_TRADE_DATE"] = qlua_pb_types.getTradeDate.Request
result_object_mappers[method_names["GET_TRADE_DATE"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getTradeDate.Result)
  result.trade_date = pb.defaults(qlua_pb_types.getTradeDate.TradeDate)
  for k, v in pairs(proc_result) do
    result.trade_date[k] = v
  end
  
  return qlua_pb_types.getTradeDate.Result, result
end

-- getQuoteLevel2
method_names["GET_QUOTE_LEVEL2"] = "getQuoteLevel2"
procedure_types[method_names["GET_QUOTE_LEVEL2"]] = "GET_QUOTE_LEVEL2"
args_prototypes["GET_QUOTE_LEVEL2"] = qlua_pb_types.getQuoteLevel2.Request
result_object_mappers[method_names["GET_QUOTE_LEVEL2"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getQuoteLevel2.Result)
  
  result.bid_count = proc_result.bid_count
  result.offer_count = proc_result.offer_count
  
  local bids = proc_result.bid
  if bids then
    for _, v in ipairs(bids) do
      local bid = pb.defaults(qlua_pb_types.getQuoteLevel2.QuoteEntry)
      bid.price = v.price
      bid.quantity = v.quantity
      table.sinsert(result.bids, bid)
  end
  
  local offers = proc_result.offer
  if offers then
    for _, v in ipairs(offers) do
      local offer = pb.defaults(qlua_pb_types.getQuoteLevel2.QuoteEntry)
      offer.price = v.price
      offer.quantity = v.quantity
      table.sinsert(result.offers, offer)
  end
  
  return qlua_pb_types.getQuoteLevel2.Result, result
end

-- getLinesCount
method_names["GET_LINES_COUNT"] = "getLinesCount"
procedure_types[method_names["GET_LINES_COUNT"]] = "GET_LINES_COUNT"
args_prototypes["GET_LINES_COUNT"] = qlua_pb_types.getLinesCount.Request
result_object_mappers[method_names["GET_LINES_COUNT"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getLinesCount.Result)
  if proc_result then 
    result.lines_count = proc_result
  end
  return qlua_pb_types.getLinesCount.Result, result
end

-- getNumCandles
method_names["GET_NUM_CANDLES"] = "getNumCandles"
procedure_types[method_names["GET_NUM_CANDLES"]] = "GET_NUM_CANDLES"
args_prototypes["GET_NUM_CANDLES"] = qlua_pb_types.getNumCandles.Request
result_object_mappers[method_names["GET_NUM_CANDLES"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getNumCandles.Result)
  if proc_result then 
    result.num_candles = proc_result
  end
  return qlua_pb_types.getNumCandles.Result, result
end

-- getCandlesByIndex
method_names["GET_CANDLES_BY_INDEX"] = "getCandlesByIndex"
procedure_types[method_names["GET_CANDLES_BY_INDEX"]] = "GET_CANDLES_BY_INDEX"
args_prototypes["GET_CANDLES_BY_INDEX"] = qlua_pb_types.getCandlesByIndex.Request
result_object_mappers[method_names["GET_CANDLES_BY_INDEX"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getCandlesByIndex.Result)

  for _, v in ipairs(proc_result.t) do
    local candle = pb.defaults(qlua_pb_types.qlua_structures.CandleEntry)
    candle.open = v.open
    candle.close = v.close
    candle.high = v.high
    candle.low = v.low
    candle.volume = v.volume
    candle.does_exist = v.doesExist
    table.sinsert(result.t, candle)
  end
  
  result.n = proc_result.n
  result.l = proc_result.l
  
  return qlua_pb_types.getCandlesByIndex.Result, result
end

-- datasource.CreateDataSource
method_names["CREATE_DATA_SOURCE"] = "datasource.CreateDataSource"
procedure_types[method_names["CREATE_DATA_SOURCE"]] = "CREATE_DATA_SOURCE"
args_prototypes["CREATE_DATA_SOURCE"] = qlua_pb_types.datasource.CreateDataSource.Request
result_object_mappers[method_names["CREATE_DATA_SOURCE"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.datasource.CreateDataSource.Result)
  
  if proc_result.is_error then
    result.is_error = true
    result.error_desc = proc_result.error_desc
  else
    result.is_error = false
    result.datasource_uuid = proc_result.datasource_uuid
  end

  return qlua_pb_types.datasource.CreateDataSource.Result, result
end

-- datasource.SetUpdateCallback
method_names["DS_SET_UPDATE_CALLBACK"] = "datasource.SetUpdateCallback"
procedure_types[method_names["DS_SET_UPDATE_CALLBACK"]] = "DS_SET_UPDATE_CALLBACK"
args_prototypes["DS_SET_UPDATE_CALLBACK"] = qlua_pb_types.datasource.SetUpdateCallback.Request
result_object_mappers[method_names["DS_SET_UPDATE_CALLBACK"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.datasource.SetUpdateCallback.Result)
  result.result = proc_result
  
  return qlua_pb_types.datasource.SetUpdateCallback.Result, result
end

-- datasource.O
method_names["DS_O"] = "datasource.O"
procedure_types[method_names["DS_O"]] = "DS_O"
args_prototypes["DS_O"] = qlua_pb_types.datasource.O.Request
result_object_mappers[method_names["DS_O"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.datasource.O.Result)
  result.value = proc_result
  
  return qlua_pb_types.datasource.O.Result, result
end

-- datasource.H
method_names["DS_H"] = "datasource.H"
procedure_types[method_names["DS_H"]] = "DS_H"
args_prototypes["DS_H"] = qlua_pb_types.datasource.H.Request
result_object_mappers[method_names["DS_H"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.datasource.H.Result)
  result.value = proc_result
  
  return qlua_pb_types.datasource.H.Result, result
end

-- datasource.L
method_names["DS_L"] = "datasource.L"
procedure_types[method_names["DS_L"]] = "DS_L"
args_prototypes["DS_L"] = qlua_pb_types.datasource.L.Request
result_object_mappers[method_names["DS_L"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.datasource.L.Result)
  result.value = proc_result
  
  return qlua_pb_types.datasource.L.Result, result
end

-- datasource.C
method_names["DS_C"] = "datasource.C"
procedure_types[method_names["DS_C"]] = "DS_C"
args_prototypes["DS_C"] = qlua_pb_types.datasource.C.Request
result_object_mappers[method_names["DS_C"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.datasource.C.Result)
  result.value = proc_result
  
  return qlua_pb_types.datasource.C.Result, result
end

-- datasource.V
method_names["DS_V"] = "datasource.V"
procedure_types[method_names["DS_V"]] = "DS_V"
args_prototypes["DS_V"] = qlua_pb_types.datasource.V.Request
result_object_mappers[method_names["DS_V"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.datasource.V.Result)
  result.value = proc_result
  
  return qlua_pb_types.datasource.V.Result, result
end

-- datasource.T
method_names["DS_T"] = "datasource.T"
procedure_types[method_names["DS_T"]] = "DS_T"
args_prototypes["DS_T"] = qlua_pb_types.datasource.T.Request
result_object_mappers[method_names["DS_T"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.datasource.T.Result)
  
  for k, v in pairs(proc_result) do
    result[k] = v
  end
  
  return qlua_pb_types.datasource.T.Result, result
end

-- datasource.Size
method_names["DS_SIZE"] = "datasource.Size"
procedure_types[method_names["DS_SIZE"]] = "DS_SIZE"
args_prototypes["DS_SIZE"] = qlua_pb_types.datasource.Size.Request
result_object_mappers[method_names["DS_SIZE"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.datasource.Size.Result)
  result.value = proc_result
  
  return qlua_pb_types.datasource.Size.Result, result
end

-- datasource.Close
method_names["DS_CLOSE"] = "datasource.Close"
procedure_types[method_names["DS_CLOSE"]] = "DS_CLOSE"
args_prototypes["DS_CLOSE"] = qlua_pb_types.datasource.Close.Request
result_object_mappers[method_names["DS_CLOSE"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.datasource.Close.Result)
  result.result = proc_result
  
  return qlua_pb_types.datasource.Close.Result, result
end

-- datasource.Close
method_names["DS_SET_EMPTY_CALLBACK"] = "datasource.SetEmptyCallback"
procedure_types[method_names["DS_SET_EMPTY_CALLBACK"]] = "DS_SET_EMPTY_CALLBACK"
args_prototypes["DS_SET_EMPTY_CALLBACK"] = qlua_pb_types.datasource.SetEmptyCallback.Request
result_object_mappers[method_names["DS_SET_EMPTY_CALLBACK"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.datasource.SetEmptyCallback.Result)
  result.result = proc_result
  
  return qlua_pb_types.datasource.SetEmptyCallback.Result, result
end

-- sendTransaction
method_names["SEND_TRANSACTION"] = "sendTransaction"
procedure_types[method_names["SEND_TRANSACTION"]] = "SEND_TRANSACTION"
args_prototypes["SEND_TRANSACTION"] = qlua_pb_types.sendTransaction.Request
result_object_mappers[method_names["SEND_TRANSACTION"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.sendTransaction.Result)
  result.result = proc_result
  
  return qlua_pb_types.sendTransaction.Result, result
end

-- CalcBuySell
method_names["CALC_BUY_SELL"] = "CalcBuySell"
procedure_types[method_names["CALC_BUY_SELL"]] = "CALC_BUY_SELL"
args_prototypes["CALC_BUY_SELL"] = qlua_pb_types.CalcBuySell.Request
result_object_mappers[method_names["CALC_BUY_SELL"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.CalcBuySell.Result)
  result.qty = proc_result.qty
  result.comission = proc_result.comission
  
  return qlua_pb_types.sendTransaction.Result, result
end

-- getParamEx
method_names["GET_PARAM_EX"] = "getParamEx"
procedure_types[method_names["GET_PARAM_EX"]] = "GET_PARAM_EX"
args_prototypes["GET_PARAM_EX"] = qlua_pb_types.getParamEx.Request
result_object_mappers[method_names["GET_PARAM_EX"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getParamEx.Result)
  result.param_ex = pb.defaults(qlua_pb_types.getParamEx.ParamEx)
  for k, v in pairs(proc_result) do
    result.param_ex[k] = v
  end
  
  return qlua_pb_types.getParamEx.Result, result
end

-- getParamEx2
method_names["GET_PARAM_EX_2"] = "getParamEx2"
procedure_types[method_names["GET_PARAM_EX_2"]] = "GET_PARAM_EX_2"
args_prototypes["GET_PARAM_EX_2"] = qlua_pb_types.getParamEx2.Request
result_object_mappers[method_names["GET_PARAM_EX_2"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getParamEx2.Result)
  result.param_ex = pb.defaults(qlua_pb_types.getParamEx2.ParamEx2)
  for k, v in pairs(proc_result) do
    result.param_ex[k] = v
  end
  
  return qlua_pb_types.getParamEx2.Result, result
end

-----

function module.get_method_name (pb_procedure_type)
  return method_names[pb_procedure_type]
end

function module.get_protobuf_procedure_type (method_name)
  return procedure_types[method_name]
end

function module.get_protobuf_args_prototype (pb_procedure_type)
  return args_prototypes[pb_procedure_type]
end

function module.get_protobuf_result_object_mapper (method_name)
  return result_object_mappers[method_name]
end

return module
