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
method_names[qlua.RPC.ProcedureType.PROCEDURE_TYPE_UNKNOWN] = "unknown"
procedure_types[method_names[qlua.RPC.ProcedureType.PROCEDURE_TYPE_UNKNOWN]] = qlua.RPC.ProcedureType.PROCEDURE_TYPE_UNKNOWN

-- isConnected
method_names[qlua.RPC.ProcedureType.IS_CONNECTED] = "isConnected"
procedure_types[method_names[qlua.RPC.ProcedureType.IS_CONNECTED]] = qlua.RPC.ProcedureType.IS_CONNECTED
args_prototypes[qlua.RPC.ProcedureType.IS_CONNECTED] = nil
result_object_mappers[method_names[qlua.RPC.ProcedureType.IS_CONNECTED]] = function (proc_result)

  local result = qlua.isConnected.Result()
  result.is_connected = proc_result
  return result
end

-- getScriptPath
method_names[qlua.RPC.ProcedureType.GET_SCRIPT_PATH] = "getScriptPath"
procedure_types[method_names[qlua.RPC.ProcedureType.GET_SCRIPT_PATH]] = qlua.RPC.ProcedureType.GET_SCRIPT_PATH
args_prototypes[qlua.RPC.ProcedureType.GET_SCRIPT_PATH] = nil
result_object_mappers[method_names[qlua.RPC.ProcedureType.GET_SCRIPT_PATH]] = function (proc_result)

  local result = qlua.getScriptPath.Result()
  result.script_path = proc_result
  return result
end

-- getInfoParam
method_names[qlua.RPC.ProcedureType.GET_INFO_PARAM] = "getInfoParam"
procedure_types[method_names[qlua.RPC.ProcedureType.GET_INFO_PARAM]] = qlua.RPC.ProcedureType.GET_INFO_PARAM
args_prototypes[qlua.RPC.ProcedureType.GET_INFO_PARAM] = qlua.getInfoParam.Request
result_object_mappers[method_names[qlua.RPC.ProcedureType.GET_INFO_PARAM]] = function (proc_result)

  local result = qlua.getInfoParam.Result()
  result.info_param = proc_result
  return result
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
method_names[qlua.RPC.ProcedureType.SLEEP] = "sleep"
procedure_types[method_names[qlua.RPC.ProcedureType.SLEEP]] = qlua.RPC.ProcedureType.SLEEP
args_prototypes[qlua.RPC.ProcedureType.SLEEP] = qlua.sleep.Request
result_object_mappers[method_names[qlua.RPC.ProcedureType.SLEEP]] = function (proc_result)

  local result = qlua.sleep.Result()
  result.result = proc_result
  return result
end

-- getWorkingFolder
method_names[qlua.RPC.ProcedureType.GET_WORKING_FOLDER] = "getWorkingFolder"
procedure_types[method_names[qlua.RPC.ProcedureType.GET_WORKING_FOLDER]] = qlua.RPC.ProcedureType.GET_WORKING_FOLDER
args_prototypes[qlua.RPC.ProcedureType.GET_WORKING_FOLDER] = nil
result_object_mappers[method_names[qlua.RPC.ProcedureType.GET_WORKING_FOLDER]] = function (proc_result)

  local result = qlua.getWorkingFolder.Result()
  result.working_folder = proc_result
  return result
end

-- PrintDbgStr
method_names[qlua.RPC.ProcedureType.PRINT_DBG_STR] = "PrintDbgStr"
procedure_types[method_names[qlua.RPC.ProcedureType.PRINT_DBG_STR]] = qlua.RPC.ProcedureType.PRINT_DBG_STR
args_prototypes[qlua.RPC.ProcedureType.PRINT_DBG_STR] = qlua.PrintDbgStr.Request
result_object_mappers[method_names[qlua.RPC.ProcedureType.PRINT_DBG_STR]] = nil

-- getItem
method_names[qlua.RPC.ProcedureType.GET_ITEM] = "getItem"
procedure_types[method_names[qlua.RPC.ProcedureType.GET_ITEM]] = qlua.RPC.ProcedureType.GET_ITEM
args_prototypes[qlua.RPC.ProcedureType.GET_ITEM] = qlua.getItem.Request
result_object_mappers[method_names[qlua.RPC.ProcedureType.GET_ITEM]] = function (proc_result)

  local result = qlua.getItem.Result()
  if proc_result then
    utils.new_put_to_string_string_pb_map(proc_result, result.table_row, qlua.getItem.Result.TableRowEntry)
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
  return qlua_pb_types.class_securities.Result, result
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
