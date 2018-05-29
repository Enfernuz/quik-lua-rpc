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
  
  return qlua_pb_types.CalcBuySell.Result, result
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

-- getPortfolioInfo
method_names["GET_PORTFOLIO_INFO"] = "getPortfolioInfo"
procedure_types[method_names["GET_PORTFOLIO_INFO"]] = "GET_PORTFOLIO_INFO"
args_prototypes["GET_PORTFOLIO_INFO"] = qlua_pb_types.getPortfolioInfo.Request
result_object_mappers[method_names["GET_PORTFOLIO_INFO"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getPortfolioInfo.Result)
  result.portfolio_info = pb.defaults(qlua_pb_types.getPortfolioInfo.PortfolioInfo)
  for k, v in pairs(proc_result) do
    result.portfolio_info[k] = v
  end
  
  return qlua_pb_types.getPortfolioInfo.Result, result
end

-- getPortfolioInfoEx
method_names["GET_PORTFOLIO_INFO_EX"] = "getPortfolioInfoEx"
procedure_types[method_names["GET_PORTFOLIO_INFO_EX"]] = "GET_PORTFOLIO_INFO_EX"
args_prototypes["GET_PORTFOLIO_INFO_EX"] = qlua_pb_types.getPortfolioInfoEx.Request
result_object_mappers[method_names["GET_PORTFOLIO_INFO_EX"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getPortfolioInfoEx.Result)
  result.portfolio_info_ex = pb.defaults(qlua_pb_types.getPortfolioInfoEx.PortfolioInfoEx)
  result.portfolio_info_ex.portfolio_info = pb.defaults(qlua_pb_types.getPortfolioInfo.PortfolioInfo)
  
  local portfolio_info = result.portfolio_info_ex.portfolio_info
  portfolio_info.is_leverage = proc_result.is_leverage
  portfolio_info.in_assets = proc_result.in_assets
  portfolio_info.leverage = proc_result.leverage
  portfolio_info.open_limit = proc_result.open_limit
  portfolio_info.val_short = proc_result.val_short
  portfolio_info.val_long = proc_result.val_long
  portfolio_info.val_long_margin = proc_result.val_long_margin
  portfolio_info.val_long_asset = proc_result.val_long_asset
  portfolio_info.assets = proc_result.assets
  portfolio_info.cur_leverage = proc_result.cur_leverage
  portfolio_info.margin = proc_result.margin
  portfolio_info.lim_all = proc_result.lim_all
  portfolio_info.av_lim_all = proc_result.av_lim_all
  portfolio_info.locked_buy = proc_result.locked_buy
  portfolio_info.locked_buy_margin = proc_result.locked_buy_margin
  portfolio_info.locked_buy_asset = proc_result.locked_buy_asset
  portfolio_info.locked_sell = proc_result.locked_sell
  portfolio_info.locked_value_coef = proc_result.locked_value_coef
  portfolio_info.in_all_assets = proc_result.in_all_assets
  portfolio_info.all_assets = proc_result.all_assets
  portfolio_info.profit_loss = proc_result.profit_loss
  portfolio_info.rate_change = proc_result.rate_change
  portfolio_info.lim_buy = proc_result.lim_buy
  portfolio_info.lim_sell = proc_result.lim_sell
  portfolio_info.lim_non_margin = proc_result.lim_non_margin
  portfolio_info.lim_buy_asset = proc_result.lim_buy_asset
  portfolio_info.val_short_net = proc_result.val_short_net
  portfolio_info.val_long_net = proc_result.val_long_net
  portfolio_info.total_money_bal = proc_result.total_money_bal
  portfolio_info.total_locked_money = proc_result.total_locked_money
  portfolio_info.haircuts = proc_result.haircuts
  portfolio_info.assets_without_hc = proc_result.assets_without_hc
  portfolio_info.status_coef = proc_result.status_coef
  portfolio_info.varmargin = proc_result.varmargin
  portfolio_info.go_for_positions = proc_result.go_for_positions
  portfolio_info.go_for_orders = proc_result.go_for_orders
  portfolio_info.rate_futures = proc_result.rate_futures
  portfolio_info.is_qual_client = proc_result.is_qual_client
  portfolio_info.is_futures = proc_result.is_futures
  portfolio_info.curr_tag = proc_result.curr_tag
  
  result.portfolio_info_ex.init_margin = proc_result.init_margin
  result.portfolio_info_ex.min_margin = proc_result.min_margin
  result.portfolio_info_ex.corrected_margin = proc_result.corrected_margin
  result.portfolio_info_ex.client_type = proc_result.client_type
  result.portfolio_info_ex.portfolio_value = proc_result.portfolio_value
  result.portfolio_info_ex.start_limit_open_pos = proc_result.start_limit_open_pos
  result.portfolio_info_ex.total_limit_open_pos = proc_result.total_limit_open_pos
  result.portfolio_info_ex.limit_open_pos = proc_result.limit_open_pos
  result.portfolio_info_ex.used_lim_open_pos = proc_result.used_lim_open_pos
  result.portfolio_info_ex.acc_var_margin = proc_result.acc_var_margin
  result.portfolio_info_ex.cl_var_margin = proc_result.cl_var_margin
  result.portfolio_info_ex.opt_liquid_cost = proc_result.opt_liquid_cost
  result.portfolio_info_ex.fut_asset = proc_result.fut_asset
  result.portfolio_info_ex.fut_total_asset = proc_result.fut_total_asset
  result.portfolio_info_ex.fut_debt = proc_result.fut_debt
  result.portfolio_info_ex.fut_rate_asset = proc_result.fut_rate_asset
  result.portfolio_info_ex.fut_rate_asset_open = proc_result.fut_rate_asset_open
  result.portfolio_info_ex.fut_rate_go = proc_result.fut_rate_go
  result.portfolio_info_ex.planed_rate_go = proc_result.planed_rate_go
  result.portfolio_info_ex.cash_leverage = proc_result.cash_leverage
  result.portfolio_info_ex.fut_position_type = proc_result.fut_position_type
  result.portfolio_info_ex.fut_accured_int = proc_result.fut_accured_int
  
  return qlua_pb_types.getPortfolioInfoEx.Result, result
end

-- getBuySellInfo
method_names["GET_BUY_SELL_INFO"] = "getBuySellInfo"
procedure_types[method_names["GET_BUY_SELL_INFO"]] = "GET_BUY_SELL_INFO"
args_prototypes["GET_BUY_SELL_INFO"] = qlua_pb_types.getBuySellInfo.Request
result_object_mappers[method_names["GET_BUY_SELL_INFO"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getBuySellInfo.Result)
  result.buy_sell_info = pb.defaults(qlua_pb_types.getBuySellInfo.BuySellInfo)
  for k, v in pairs(proc_result) do
    result.buy_sell_info[k] = v
  end
  
  return qlua_pb_types.getBuySellInfo.Result, result
end

-- getBuySellInfoEx
method_names["GET_BUY_SELL_INFO_EX"] = "getBuySellInfoEx"
procedure_types[method_names["GET_BUY_SELL_INFO_EX"]] = "GET_BUY_SELL_INFO_EX"
args_prototypes["GET_BUY_SELL_INFO_EX"] = qlua_pb_types.getBuySellInfoEx.Request
result_object_mappers[method_names["GET_BUY_SELL_INFO_EX"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getBuySellInfoEx.Result)
  result.buy_sell_info_ex = pb.defaults(qlua_pb_types.getBuySellInfoEx.BuySellInfoEx)
  result.buy_sell_info_ex.buy_sell_info = pb.defaults(qlua_pb_types.getBuySellInfoEx.BuySellInfo)
  
  local buy_sell_info = result.buy_sell_info_ex.buy_sell_info
  buy_sell_info.is_margin_sec = proc_result.is_margin_sec
  buy_sell_info.is_asset_sec = proc_result.is_asset_sec
  buy_sell_info.balance = proc_result.balance
  buy_sell_info.can_buy = proc_result.can_buy
  buy_sell_info.can_sell = proc_result.can_sell
  buy_sell_info.position_valuation = proc_result.position_valuation
  buy_sell_info.value = proc_result.value
  buy_sell_info.open_value = proc_result.open_value
  buy_sell_info.lim_long = proc_result.lim_long
  buy_sell_info.long_coef = proc_result.long_coef
  buy_sell_info.lim_short = proc_result.lim_short
  buy_sell_info.short_coef = proc_result.short_coef
  buy_sell_info.value_coef = proc_result.value_coef
  buy_sell_info.open_value_coef = proc_result.open_value_coef
  buy_sell_info.share = proc_result.share
  buy_sell_info.short_wa_price = proc_result.short_wa_price
  buy_sell_info.long_wa_price = proc_result.long_wa_price
  buy_sell_info.profit_loss = proc_result.profit_loss
  buy_sell_info.spread_hc = proc_result.spread_hc
  buy_sell_info.can_buy_own = proc_result.can_buy_own
  buy_sell_info.can_sell_own = proc_result.can_sell_own
  
  result.buy_sell_info_ex.limit_kind = proc_result.limit_kind
  result.buy_sell_info_ex.d_long = proc_result.d_long
  result.buy_sell_info_ex.d_min_long = proc_result.d_min_long
  result.buy_sell_info_ex.d_short = proc_result.d_short
  result.buy_sell_info_ex.d_min_short = proc_result.d_min_short
  result.buy_sell_info_ex.client_type = proc_result.client_type
  result.buy_sell_info_ex.is_long_allowed = proc_result.is_long_allowed
  result.buy_sell_info_ex.is_short_allowed = proc_result.is_short_allowed

  return qlua_pb_types.getBuySellInfoEx.Result, result
end

-- AddColumn
method_names["ADD_COLUMN"] = "AddColumn"
procedure_types[method_names["ADD_COLUMN"]] = "ADD_COLUMN"
args_prototypes["ADD_COLUMN"] = qlua_pb_types.AddColumn.Request
result_object_mappers[method_names["ADD_COLUMN"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.AddColumn.Result)
  result.result = proc_result
  
  return qlua_pb_types.AddColumn.Result, result
end

-- AllocTable
method_names["ALLOC_TABLE"] = "AllocTable"
procedure_types[method_names["ALLOC_TABLE"]] = "ALLOC_TABLE"
args_prototypes["ALLOC_TABLE"] = qlua_pb_types.AllocTable.Request
result_object_mappers[method_names["ALLOC_TABLE"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.AllocTable.Result)
  result.t_id = proc_result
  
  return qlua_pb_types.AllocTable.Result, result
end

-- Clear
method_names["CLEAR"] = "Clear"
procedure_types[method_names["CLEAR"]] = "CLEAR"
args_prototypes["CLEAR"] = qlua_pb_types.Clear.Request
result_object_mappers[method_names["CLEAR"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.Clear.Result)
  result.result = proc_result
  
  return qlua_pb_types.Clear.Result, result
end

-- CreateWindow
method_names["CREATE_WINDOW"] = "CreateWindow"
procedure_types[method_names["CREATE_WINDOW"]] = "CREATE_WINDOW"
args_prototypes["CREATE_WINDOW"] = qlua_pb_types.CreateWindow.Request
result_object_mappers[method_names["CREATE_WINDOW"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.CreateWindow.Result)
  result.result = proc_result
  
  return qlua_pb_types.CreateWindow.Result, result
end

-- DeleteRow
method_names["DELETE_ROW"] = "DeleteRow"
procedure_types[method_names["DELETE_ROW"]] = "DELETE_ROW"
args_prototypes["DELETE_ROW"] = qlua_pb_types.DeleteRow.Request
result_object_mappers[method_names["DELETE_ROW"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.DeleteRow.Result)
  result.result = proc_result
  
  return qlua_pb_types.DeleteRow.Result, result
end

-- DestroyTable
method_names["DESTROY_TABLE"] = "DestroyTable"
procedure_types[method_names["DESTROY_TABLE"]] = "DESTROY_TABLE"
args_prototypes["DESTROY_TABLE"] = qlua_pb_types.DestroyTable.Request
result_object_mappers[method_names["DESTROY_TABLE"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.DestroyTable.Result)
  result.result = proc_result
  
  return qlua_pb_types.DestroyTable.Result, result
end

-- InsertRow
method_names["INSERT_ROW"] = "InsertRow"
procedure_types[method_names["INSERT_ROW"]] = "INSERT_ROW"
args_prototypes["INSERT_ROW"] = qlua_pb_types.InsertRow.Request
result_object_mappers[method_names["INSERT_ROW"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.InsertRow.Result)
  result.result = proc_result
  
  return qlua_pb_types.InsertRow.Result, result
end

-- IsWindowClosed
method_names["IS_WINDOW_CLOSED"] = "IsWindowClosed"
procedure_types[method_names["IS_WINDOW_CLOSED"]] = "IS_WINDOW_CLOSED"
args_prototypes["IS_WINDOW_CLOSED"] = qlua_pb_types.IsWindowClosed.Request
result_object_mappers[method_names["IS_WINDOW_CLOSED"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.IsWindowClosed.Result)
  result.result = proc_result
  
  return qlua_pb_types.IsWindowClosed.Result, result
end

-- GetCell
method_names["GET_CELL"] = "GetCell"
procedure_types[method_names["GET_CELL"]] = "GET_CELL"
args_prototypes["GET_CELL"] = qlua_pb_types.GetCell.Request
result_object_mappers[method_names["GET_CELL"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.GetCell.Result)
  result.image = proc_result.image
  result.value = proc_result.value
  
  return qlua_pb_types.GetCell.Result, result
end

-- GetTableSize
method_names["GET_TABLE_SIZE"] = "GetTableSize"
procedure_types[method_names["GET_TABLE_SIZE"]] = "GET_TABLE_SIZE"
args_prototypes["GET_TABLE_SIZE"] = qlua_pb_types.GetTableSize.Request
result_object_mappers[method_names["GET_TABLE_SIZE"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.GetTableSize.Result)
  result.rows = proc_result.rows
  result.col = proc_result.col
  
  return qlua_pb_types.GetTableSize.Result, result
end

-- GetWindowCaption
method_names["GET_WINDOW_CAPTION"] = "GetWindowCaption"
procedure_types[method_names["GET_WINDOW_CAPTION"]] = "GET_WINDOW_CAPTION"
args_prototypes["GET_WINDOW_CAPTION"] = qlua_pb_types.GetWindowCaption.Request
result_object_mappers[method_names["GET_WINDOW_CAPTION"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.GetWindowCaption.Result)
  result.caption = proc_result
  
  return qlua_pb_types.GetWindowCaption.Result, result
end

-- GetWindowRect
method_names["GET_WINDOW_RECT"] = "GetWindowRect"
procedure_types[method_names["GET_WINDOW_RECT"]] = "GET_WINDOW_RECT"
args_prototypes["GET_WINDOW_RECT"] = qlua_pb_types.GetWindowRect.Request
result_object_mappers[method_names["GET_WINDOW_RECT"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.GetWindowRect.Result)
  result.top = proc_result.top
  result.left = proc_result.left
  result.bottom = proc_result.bottom
  result.right = proc_result.right
  
  return qlua_pb_types.GetWindowRect.Result, result
end

-- SetCell
method_names["SET_CELL"] = "SetCell"
procedure_types[method_names["SET_CELL"]] = "SET_CELL"
args_prototypes["SET_CELL"] = qlua_pb_types.SetCell.Request
result_object_mappers[method_names["SET_CELL"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.SetCell.Result)
  result.result = proc_result
  
  return qlua_pb_types.SetCell.Result, result
end

-- SetWindowCaption
method_names["SET_WINDOW_CAPTION"] = "SetWindowCaption"
procedure_types[method_names["SET_WINDOW_CAPTION"]] = "SET_WINDOW_CAPTION"
args_prototypes["SET_WINDOW_CAPTION"] = qlua_pb_types.SetWindowCaption.Request
result_object_mappers[method_names["SET_WINDOW_CAPTION"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.SetWindowCaption.Result)
  result.result = proc_result
  
  return qlua_pb_types.SetWindowCaption.Result, result
end

-- SetWindowPos
method_names["SET_WINDOW_POS"] = "SetWindowPos"
procedure_types[method_names["SET_WINDOW_POS"]] = "SET_WINDOW_POS"
args_prototypes["SET_WINDOW_POS"] = qlua_pb_types.SetWindowPos.Request
result_object_mappers[method_names["SET_WINDOW_POS"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.SetWindowPos.Result)
  result.result = proc_result
  
  return qlua_pb_types.SetWindowPos.Result, result
end

-- SetTableNotificationCallback
method_names["SET_TABLE_NOTIFICATION_CALLBACK"] = "SetTableNotificationCallback"
procedure_types[method_names["SET_TABLE_NOTIFICATION_CALLBACK"]] = "SET_TABLE_NOTIFICATION_CALLBACK"
args_prototypes["SET_TABLE_NOTIFICATION_CALLBACK"] = qlua_pb_types.SetTableNotificationCallback.Request
result_object_mappers[method_names["SET_TABLE_NOTIFICATION_CALLBACK"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.SetTableNotificationCallback.Result)
  result.result = proc_result
  
  return qlua_pb_types.SetTableNotificationCallback.Result, result
end

-- RGB
method_names["RGB"] = "RGB"
procedure_types[method_names["RGB"]] = "RGB"
args_prototypes["RGB"] = qlua_pb_types.RGB.Request
result_object_mappers[method_names["RGB"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.RGB.Result)
  result.result = proc_result
  
  return qlua_pb_types.RGB.Result, result
end

-- SetColor
method_names["SET_COLOR"] = "SetColor"
procedure_types[method_names["SET_COLOR"]] = "SET_COLOR"
args_prototypes["SET_COLOR"] = qlua_pb_types.SetColor.Request
result_object_mappers[method_names["SET_COLOR"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.SetColor.Result)
  result.result = proc_result
  
  return qlua_pb_types.SetColor.Result, result
end

-- Highlight
method_names["HIGHLIGHT"] = "Highlight"
procedure_types[method_names["HIGHLIGHT"]] = "HIGHLIGHT"
args_prototypes["HIGHLIGHT"] = qlua_pb_types.Highlight.Request
result_object_mappers[method_names["HIGHLIGHT"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.Highlight.Result)
  result.result = proc_result
  
  return qlua_pb_types.Highlight.Result, result
end

-- SetSelectedRow
method_names["SET_SELECTED_ROW"] = "SetSelectedRow"
procedure_types[method_names["SET_SELECTED_ROW"]] = "SET_SELECTED_ROW"
args_prototypes["SET_SELECTED_ROW"] = qlua_pb_types.SetSelectedRow.Request
result_object_mappers[method_names["SET_SELECTED_ROW"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.SetSelectedRow.Result)
  result.result = proc_result
  
  return qlua_pb_types.SetSelectedRow.Result, result
end

-- AddLabel
method_names["ADD_LABEL"] = "AddLabel"
procedure_types[method_names["ADD_LABEL"]] = "ADD_LABEL"
args_prototypes["ADD_LABEL"] = qlua_pb_types.AddLabel.Request
result_object_mappers[method_names["ADD_LABEL"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.AddLabel.Result)
  result.label_id = proc_result
  
  return qlua_pb_types.AddLabel.Result, result
end

-- DelLabel
method_names["DEL_LABEL"] = "DelLabel"
procedure_types[method_names["DEL_LABEL"]] = "DEL_LABEL"
args_prototypes["DEL_LABEL"] = qlua_pb_types.DelLabel.Request
result_object_mappers[method_names["DEL_LABEL"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.DelLabel.Result)
  result.result = proc_result
  
  return qlua_pb_types.DelLabel.Result, result
end

-- DelAllLabels
method_names["DEL_ALL_LABELS"] = "DelAllLabels"
procedure_types[method_names["DEL_ALL_LABELS"]] = "DEL_ALL_LABELS"
args_prototypes["DEL_ALL_LABELS"] = qlua_pb_types.DelAllLabels.Request
result_object_mappers[method_names["DEL_ALL_LABELS"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.DelAllLabels.Result)
  result.result = proc_result
  
  return qlua_pb_types.DelAllLabels.Result, result
end

-- GetLabelParams
method_names["GET_LABEL_PARAMS"] = "GetLabelParams"
procedure_types[method_names["GET_LABEL_PARAMS"]] = "GET_LABEL_PARAMS"
args_prototypes["GET_LABEL_PARAMS"] = qlua_pb_types.GetLabelParams.Request
result_object_mappers[method_names["GET_LABEL_PARAMS"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.GetLabelParams.Result)
  result.label_params = proc_result
  
  return qlua_pb_types.GetLabelParams.Result, result
end

-- SetLabelParams
method_names["SET_LABEL_PARAMS"] = "SetLabelParams"
procedure_types[method_names["SET_LABEL_PARAMS"]] = "SET_LABEL_PARAMS"
args_prototypes["SET_LABEL_PARAMS"] = qlua_pb_types.SetLabelParams.Request
result_object_mappers[method_names["SET_LABEL_PARAMS"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.SetLabelParams.Result)
  result.result = proc_result
  
  return qlua_pb_types.SetLabelParams.Result, result
end

-- Subscribe_Level_II_Quotes
method_names["SUBSCRIBE_LEVEL_II_QUOTES"] = "Subscribe_Level_II_Quotes"
procedure_types[method_names["SUBSCRIBE_LEVEL_II_QUOTES"]] = "SUBSCRIBE_LEVEL_II_QUOTES"
args_prototypes["SUBSCRIBE_LEVEL_II_QUOTES"] = qlua_pb_types.Subscribe_Level_II_Quotes.Request
result_object_mappers[method_names["SUBSCRIBE_LEVEL_II_QUOTES"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.Subscribe_Level_II_Quotes.Result)
  result.result = proc_result
  
  return qlua_pb_types.Subscribe_Level_II_Quotes.Result, result
end

-- Unsubscribe_Level_II_Quotes
method_names["UNSUBSCRIBE_LEVEL_II_QUOTES"] = "Unsubscribe_Level_II_Quotes"
procedure_types[method_names["UNSUBSCRIBE_LEVEL_II_QUOTES"]] = "UNSUBSCRIBE_LEVEL_II_QUOTES"
args_prototypes["UNSUBSCRIBE_LEVEL_II_QUOTES"] = qlua_pb_types.Unsubscribe_Level_II_Quotes.Request
result_object_mappers[method_names["UNSUBSCRIBE_LEVEL_II_QUOTES"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.Unsubscribe_Level_II_Quotes.Result)
  result.result = proc_result
  
  return qlua_pb_types.Unsubscribe_Level_II_Quotes.Result, result
end

-- IsSubscribed_Level_II_Quotes
method_names["IS_SUBSCRIBED_LEVEL_II_QUOTES"] = "IsSubscribed_Level_II_Quotes"
procedure_types[method_names["IS_SUBSCRIBED_LEVEL_II_QUOTES"]] = "IS_SUBSCRIBED_LEVEL_II_QUOTES"
args_prototypes["IS_SUBSCRIBED_LEVEL_II_QUOTES"] = qlua_pb_types.IsSubscribed_Level_II_Quotes.Request
result_object_mappers[method_names["IS_SUBSCRIBED_LEVEL_II_QUOTES"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.IsSubscribed_Level_II_Quotes.Result)
  result.result = proc_result
  
  return qlua_pb_types.IsSubscribed_Level_II_Quotes.Result, result
end

-- ParamRequest
method_names["PARAM_REQUEST"] = "ParamRequest"
procedure_types[method_names["PARAM_REQUEST"]] = "PARAM_REQUEST"
args_prototypes["PARAM_REQUEST"] = qlua_pb_types.ParamRequest.Request
result_object_mappers[method_names["PARAM_REQUEST"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.ParamRequest.Result)
  result.result = proc_result
  
  return qlua_pb_types.ParamRequest.Result, result
end

-- CancelParamRequest
method_names["CANCEL_PARAM_REQUEST"] = "CancelParamRequest"
procedure_types[method_names["CANCEL_PARAM_REQUEST"]] = "CANCEL_PARAM_REQUEST"
args_prototypes["CANCEL_PARAM_REQUEST"] = qlua_pb_types.CancelParamRequest.Request
result_object_mappers[method_names["CANCEL_PARAM_REQUEST"]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.CancelParamRequest.Result)
  result.result = proc_result
  
  return qlua_pb_types.CancelParamRequest.Result, result
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
