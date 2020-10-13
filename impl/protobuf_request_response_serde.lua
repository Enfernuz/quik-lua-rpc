package.path = "../?.lua;" .. package.path

local RequestResponseSerde = require("impl.request_response_serde")

local utils = require("utils.utils")
local pb = require("pb")
pb.option("use_default_values")

local qlua_pb_types = require("qlua.qlua_pb_types")

local ProtobufRequestResponseSerde = {}

setmetatable(ProtobufRequestResponseSerde, {__index = RequestResponseSerde})

local method_names = {}
local args_decoders = {}
local result_encoders = {}

-- deserializes a Protobuf-encoded binary representation into a method name string and the method's arguments Lua table object
function ProtobufRequestResponseSerde:deserialize_request (pb_request)

  local decoded_request = pb.decode(qlua_pb_types.RPC.Request, pb_request)
  local method_name = assert(method_names[decoded_request.type], string.format("Для типа процедуры protobuf '%s' не найдено соответствующей QLua-функции.", decoded_request.type))
  local encoded_args = decoded_request.args -- pb-serialized, may be nil
  local decoded_args
  if encoded_args ~= "" and encoded_args then
    decoded_args = assert(args_decoders[decoded_request.type], string.format("Для типа процедуры protobuf '%s' не найден protobuf-десериализатор аргументов.", decoded_request.type))(encoded_args)
  end

  return method_name, decoded_args
end

-- serializes a response Lua table object into a Protobuf-encoded binary representation
function ProtobufRequestResponseSerde:serialize_response (response)

  local pb_response = pb.defaults(qlua_pb_types.RPC.Response)

  local err = response.error
  if err then
    pb_response.is_error = true
    local pb_err = pb.defaults(qlua_pb_types.RPC.Error)
    pb_err.code = err.code
    pb_err.message = err.message
    pb_response.result = pb.encode(qlua_pb_types.RPC.Error, pb_err)
  else
    local encoded_result = assert(result_encoders[response.method], string.format("Для типа процедуры protobuf '%s' не найден protobuf-сериализатор результата.", response.method))(response.proc_result)
    if encoded_result then
      pb_response.result = encoded_result
    end
  end

  return pb.encode(qlua_pb_types.RPC.Response, pb_response)
end

-- args decoders / result encoders implementation --

-- unknown
method_names["PROCEDURE_TYPE_UNKNOWN"] = "unknown" -- TODO: maybe set it to nil?

local proc_name

-- isConnected
proc_name = "IS_CONNECTED"
method_names[proc_name] = "isConnected"
args_decoders[proc_name] = nil -- no args
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.isConnected.Result)
  result.is_connected = proc_result
  return pb.encode(qlua_pb_types.isConnected.Result, result)
end

-- getScriptPath
proc_name = "GET_SCRIPT_PATH"
method_names[proc_name] = "getScriptPath"
args_decoders[proc_name] = nil -- no args
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getScriptPath.Result)
  result.script_path = proc_result
  return pb.encode(qlua_pb_types.getScriptPath.Result, result)
end

-- getInfoParam
proc_name = "GET_INFO_PARAM"
method_names[proc_name] = "getInfoParam"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.getInfoParam.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getInfoParam.Result)
  result.info_param = proc_result

  return pb.encode(qlua_pb_types.getInfoParam.Result, result)
end

-- message
proc_name = "MESSAGE"
method_names[proc_name] = "message"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.message.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.message.Result)
  if proc_result then
    result.value_result = proc_result
  else
    result.null_result = true
    result.value_result = nil
  end

  return pb.encode(qlua_pb_types.message.Result, result)
end

-- sleep
proc_name = "SLEEP"
method_names[proc_name] = "sleep"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.sleep.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.sleep.Result)
  if proc_result then
    result.value_result = proc_result
  else
    result.null_result = true
    result.value_result = nil
  end
  return pb.encode(qlua_pb_types.sleep.Result, result)
end

-- getWorkingFolder
proc_name = "GET_WORKING_FOLDER"
method_names[proc_name] = "getWorkingFolder"
args_decoders[proc_name] = nil -- no args
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getWorkingFolder.Result)
  result.working_folder = proc_result
  return pb.encode(qlua_pb_types.getWorkingFolder.Result, result)
end

-- PrintDbgStr
proc_name = "PRINT_DBG_STR"
method_names[proc_name] = "PrintDbgStr"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.PrintDbgStr.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function () return nil end -- no result

-- os.sysdate
proc_name = "OS_SYSDATE"
method_names[proc_name] = "os.sysdate"
args_decoders[proc_name] = nil -- no args
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.os.sysdate.Result)
  result.result = pb.defaults(qlua_pb_types.qlua_structures.DateTimeEntry)
  for k, v in pairs(proc_result) do
    result.result[k] = v
  end

  return pb.encode(qlua_pb_types.os.sysdate.Result, result)
end

-- getItem
proc_name = "GET_ITEM"
method_names[proc_name] = "getItem"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.getItem.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getItem.Result)
  if proc_result then
    result.table_row = {}
    for k, v in pairs(proc_result) do
      result.table_row[tostring(k)] = tostring(v)
    end
  else
    result.null_table_row = true
  end

  return pb.encode(qlua_pb_types.getItem.Result, result)
end

-- getOrderByNumber
proc_name = "GET_ORDER_BY_NUMBER"
method_names[proc_name] = "getOrderByNumber"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.getOrderByNumber.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getOrderByNumber.Result)

  if proc_result.order then
      result.order = pb.defaults(qlua_pb_types.qlua_structures.Order)
      for k, v in pairs(proc_result.order) do
        result.order[k] = v
      end
  end

  if proc_result.indx then
    result.value_indx = proc_result.indx
  else
    result.null_indx = true
    result.value_indx = nil
  end

  return pb.encode(qlua_pb_types.getOrderByNumber.Result, result)
end

-- getNumberOf
proc_name = "GET_NUMBER_OF"
method_names[proc_name] = "getNumberOf"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.getNumberOf.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getNumberOf.Result)
  result.result = proc_result
  return pb.encode(qlua_pb_types.getNumberOf.Result, result)
end

-- SearchItems
proc_name = "SEARCH_ITEMS"
method_names[proc_name] = "SearchItems"
args_decoders[proc_name] = function (encoded_args)

  local args = pb.decode(qlua_pb_types.SearchItems.Args, encoded_args)

  args.end_index = args.null_end_index and nil or args.value_end_index

  return args
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.SearchItems.Result)
  if proc_result then
    result.items_indices = proc_result
  else
    result.null_items_indices = true
  end
  return pb.encode(qlua_pb_types.SearchItems.Result, result)
end

-- getClassesList
proc_name = "GET_CLASSES_LIST"
method_names[proc_name] = "getClassesList"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.getClassesList.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getClassesList.Result)
  result.classes_list = proc_result

  return pb.encode(qlua_pb_types.getClassesList.Result, result)
end

-- getClassInfo
proc_name = "GET_CLASS_INFO"
method_names[proc_name] = "getClassInfo"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.getClassInfo.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getClassInfo.Result)
  result.class_info = pb.defaults(qlua_pb_types.qlua_structures.Klass)
  if proc_result then
    for k, v in pairs(proc_result) do
      result.class_info[k] = v
    end
  end

  return pb.encode(qlua_pb_types.getClassInfo.Result, result)
end

-- getClassSecurities
proc_name = "GET_CLASS_SECURITIES"
method_names[proc_name] = "getClassSecurities"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.getClassSecurities.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getClassSecurities.Result)
  result.class_securities = proc_result

  return pb.encode(qlua_pb_types.getClassSecurities.Result, result)
end

-- getMoney
proc_name = "GET_MONEY"
method_names[proc_name] = "getMoney"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.getMoney.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getMoney.Result)
  result.money = pb.defaults(qlua_pb_types.getMoney.Money)
  for k, v in pairs(proc_result) do
    result.money[k] = v
  end

  return pb.encode(qlua_pb_types.getMoney.Result, result)
end

-- getMoneyEx
proc_name = "GET_MONEY_EX"
method_names[proc_name] = "getMoneyEx"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.getMoneyEx.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getMoneyEx.Result)
  if proc_result then
    result.money_ex = pb.defaults(qlua_pb_types.qlua_structures.MoneyLimit)
    for k, v in pairs(proc_result) do
      result.money_ex[k] = v
    end
  end

  return pb.encode(qlua_pb_types.getMoneyEx.Result, result)
end

-- getDepo
proc_name = "GET_DEPO"
method_names[proc_name] = "getDepo"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.getDepo.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getDepo.Result)
  result.depo = pb.defaults(qlua_pb_types.getDepo.Depo)
  for k, v in pairs(proc_result) do
    result.depo[k] = v
  end

  return pb.encode(qlua_pb_types.getDepo.Result, result)
end

-- getDepoEx
proc_name = "GET_DEPO_EX"
method_names[proc_name] = "getDepoEx"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.getDepoEx.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getDepoEx.Result)
  if proc_result then
    -- TODO: check if the initialization is neccessary
    result.depo_ex = pb.defaults(qlua_pb_types.qlua_structures.DepoLimit)
    for k, v in pairs(proc_result) do
      result.depo_ex[k] = v
    end
  end

  return pb.encode(qlua_pb_types.getDepoEx.Result, result)
end

-- getFuturesLimit
proc_name = "GET_FUTURES_LIMIT"
method_names[proc_name] = "getFuturesLimit"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.getFuturesLimit.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getFuturesLimit.Result)
  result.futures_limit = pb.defaults(qlua_pb_types.qlua_structures.FuturesLimit)
  if proc_result then
    for k, v in pairs(proc_result) do
      result.futures_limit[k] = v
    end
  end

  return pb.encode(qlua_pb_types.getFuturesLimit.Result, result)
end

-- getFuturesHolding
proc_name = "GET_FUTURES_HOLDING"
method_names[proc_name] = "getFuturesHolding"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.getFuturesHolding.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getFuturesHolding.Result)
  result.futures_holding = pb.defaults(qlua_pb_types.qlua_structures.FuturesClientHolding)
  if proc_result then
    for k, v in pairs(proc_result) do
      result.futures_holding[k] = v
    end
  end

  return pb.encode(qlua_pb_types.getFuturesHolding.Result, result)
end

-- getSecurityInfo
proc_name = "GET_SECURITY_INFO"
method_names[proc_name] = "getSecurityInfo"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.getSecurityInfo.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getSecurityInfo.Result)
  result.security_info = pb.defaults(qlua_pb_types.qlua_structures.Security)
  if proc_result then
    for k, v in pairs(proc_result) do
      result.security_info[k] = v
    end
  end

  return pb.encode(qlua_pb_types.getSecurityInfo.Result, result)
end

-- getTradeDate
proc_name = "GET_TRADE_DATE"
method_names[proc_name] = "getTradeDate"
args_decoders[proc_name] = nil -- no args
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getTradeDate.Result)
  result.trade_date = pb.defaults(qlua_pb_types.getTradeDate.TradeDate)
  for k, v in pairs(proc_result) do
    result.trade_date[k] = v
  end

  return pb.encode(qlua_pb_types.getTradeDate.Result, result)
end

-- getQuoteLevel2
proc_name = "GET_QUOTE_LEVEL2"
method_names[proc_name] = "getQuoteLevel2"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.getQuoteLevel2.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getQuoteLevel2.Result)
  result.bid_count = proc_result.bid_count
  result.offer_count = proc_result.offer_count
  result.bids = proc_result.bids
  result.offers = proc_result.offers

  return pb.encode(qlua_pb_types.getQuoteLevel2.Result, result)
end

-- getLinesCount
proc_name = "GET_LINES_COUNT"
method_names[proc_name] = "getLinesCount"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.getLinesCount.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getLinesCount.Result)
  result.lines_count = proc_result
  return pb.encode(qlua_pb_types.getLinesCount.Result, result)
end

-- getNumCandles
proc_name = "GET_NUM_CANDLES"
method_names[proc_name] = "getNumCandles"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.getNumCandles.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getNumCandles.Result)
  result.num_candles = proc_result
  return pb.encode(qlua_pb_types.getNumCandles.Result, result)
end

-- getCandlesByIndex
proc_name = "GET_CANDLES_BY_INDEX"
method_names[proc_name] = "getCandlesByIndex"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.getCandlesByIndex.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

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

  return pb.encode(qlua_pb_types.getCandlesByIndex.Result, result)
end

-- datasource.CreateDataSource
proc_name = "CREATE_DATA_SOURCE"
method_names[proc_name] = "datasource.CreateDataSource"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.datasource.CreateDataSource.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.datasource.CreateDataSource.Result)

  if proc_result.is_error then
    result.is_error = true
    result.error_desc = proc_result.error_desc
  else
    result.is_error = false
    result.datasource_uuid = proc_result.datasource_uuid
  end

  return pb.encode(qlua_pb_types.datasource.CreateDataSource.Result, result)
end

-- datasource.SetUpdateCallback
proc_name = "DS_SET_UPDATE_CALLBACK"
method_names[proc_name] = "datasource.SetUpdateCallback"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.datasource.SetUpdateCallback.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.datasource.SetUpdateCallback.Result)
  result.result = proc_result

  return pb.encode(qlua_pb_types.datasource.SetUpdateCallback.Result, result)
end

-- datasource.O
proc_name = "DS_O"
method_names[proc_name] = "datasource.O"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.datasource.O.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.datasource.O.Result)
  result.value = proc_result

  return pb.encode(qlua_pb_types.datasource.O.Result, result)
end

-- datasource.H
proc_name = "DS_H"
method_names[proc_name] = "datasource.H"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.datasource.H.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.datasource.H.Result)
  result.value = proc_result

  return pb.encode(qlua_pb_types.datasource.H.Result, result)
end

-- datasource.L
proc_name = "DS_L"
method_names[proc_name] = "datasource.L"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.datasource.L.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.datasource.L.Result)
  result.value = proc_result

  return pb.encode(qlua_pb_types.datasource.L.Result, result)
end

-- datasource.C
proc_name = "DS_C"
method_names[proc_name] = "datasource.C"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.datasource.C.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.datasource.C.Result)
  result.value = proc_result

  return pb.encode(qlua_pb_types.datasource.C.Result, result)
end

-- datasource.V
proc_name = "DS_V"
method_names[proc_name] = "datasource.V"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.datasource.V.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.datasource.V.Result)
  result.value = proc_result

  return pb.encode(qlua_pb_types.datasource.V.Result, result)
end

-- datasource.T
proc_name = "DS_T"
method_names[proc_name] = "datasource.T"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.datasource.T.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.datasource.T.Result)

  -- TODO: test
  for k, v in pairs(proc_result) do
    result.time[k] = v
  end

  return pb.encode(qlua_pb_types.datasource.T.Result, result)
end

-- datasource.Size
proc_name = "DS_SIZE"
method_names[proc_name] = "datasource.Size"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.datasource.Size.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.datasource.Size.Result)
  result.value = proc_result

  return pb.encode(qlua_pb_types.datasource.Size.Result, result)
end

-- datasource.Close
proc_name = "DS_CLOSE"
method_names[proc_name] = "datasource.Close"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.datasource.Close.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.datasource.Close.Result)
  result.result = proc_result

  return pb.encode(qlua_pb_types.datasource.Close.Result, result)
end

-- datasource.Close
proc_name = "DS_SET_EMPTY_CALLBACK"
method_names[proc_name] = "datasource.SetEmptyCallback"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.datasource.SetEmptyCallback.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.datasource.SetEmptyCallback.Result)
  result.result = proc_result

  return pb.encode(qlua_pb_types.datasource.SetEmptyCallback.Result, result)
end

-- sendTransaction
proc_name = "SEND_TRANSACTION"
method_names[proc_name] = "sendTransaction"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.sendTransaction.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.sendTransaction.Result)
  result.result = proc_result

  return pb.encode(qlua_pb_types.sendTransaction.Result, result)
end

-- CalcBuySell
proc_name = "CALC_BUY_SELL"
method_names[proc_name] = "CalcBuySell"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.CalcBuySell.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.CalcBuySell.Result)
  result.qty = proc_result.qty
  result.comission = proc_result.comission

  return pb.encode(qlua_pb_types.CalcBuySell.Result, result)
end

-- getParamEx
proc_name = "GET_PARAM_EX"
method_names[proc_name] = "getParamEx"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.getParamEx.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getParamEx.Result)
  result.param_ex = pb.defaults(qlua_pb_types.getParamEx.ParamEx)
  for k, v in pairs(proc_result) do
    result.param_ex[k] = v
  end

  return pb.encode(qlua_pb_types.getParamEx.Result, result)
end

-- getParamEx2
proc_name = "GET_PARAM_EX_2"
method_names[proc_name] = "getParamEx2"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.getParamEx2.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getParamEx2.Result)
  result.param_ex = pb.defaults(qlua_pb_types.getParamEx2.ParamEx2)
  for k, v in pairs(proc_result) do
    result.param_ex[k] = v
  end

  return pb.encode(qlua_pb_types.getParamEx2.Result, result)
end

-- getPortfolioInfo
proc_name = "GET_PORTFOLIO_INFO"
method_names[proc_name] = "getPortfolioInfo"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.getPortfolioInfo.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getPortfolioInfo.Result)
  result.portfolio_info = pb.defaults(qlua_pb_types.getPortfolioInfo.PortfolioInfo)
  for k, v in pairs(proc_result) do
    result.portfolio_info[k] = v
  end

  return pb.encode(qlua_pb_types.getPortfolioInfo.Result, result)
end

-- getPortfolioInfoEx
proc_name = "GET_PORTFOLIO_INFO_EX"
method_names[proc_name] = "getPortfolioInfoEx"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.getPortfolioInfoEx.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getPortfolioInfoEx.Result)
  result.portfolio_info_ex = pb.defaults(qlua_pb_types.getPortfolioInfoEx.PortfolioInfoEx)
  result.portfolio_info_ex.portfolio_info = pb.defaults(qlua_pb_types.getPortfolioInfo.PortfolioInfo)

  local portfolio_info = result.portfolio_info_ex.portfolio_info
  for k, v in pairs(proc_result.portfolio_info) do
    portfolio_info[k] = v
  end

  for k, v in pairs(proc_result.ex) do
    result.portfolio_info_ex[k] = v
  end

  return pb.encode(qlua_pb_types.getPortfolioInfoEx.Result, result)
end

-- getBuySellInfo
proc_name = "GET_BUY_SELL_INFO"
method_names[proc_name] = "getBuySellInfo"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.getBuySellInfo.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getBuySellInfo.Result)
  result.buy_sell_info = pb.defaults(qlua_pb_types.getBuySellInfo.BuySellInfo)
  for k, v in pairs(proc_result) do
    result.buy_sell_info[k] = v
  end

  return pb.encode(qlua_pb_types.getBuySellInfo.Result, result)
end

-- getBuySellInfoEx
proc_name = "GET_BUY_SELL_INFO_EX"
method_names[proc_name] = "getBuySellInfoEx"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.getBuySellInfoEx.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.getBuySellInfoEx.Result)
  result.buy_sell_info_ex = pb.defaults(qlua_pb_types.getBuySellInfoEx.BuySellInfoEx)
  result.buy_sell_info_ex.buy_sell_info = pb.defaults(qlua_pb_types.getBuySellInfoEx.BuySellInfo)

  local buy_sell_info = result.buy_sell_info_ex.buy_sell_info
  buy_sell_info.is_margin_sec = proc_result.buy_sell_info.is_margin_sec
  buy_sell_info.is_asset_sec = proc_result.buy_sell_info.is_asset_sec
  buy_sell_info.balance = proc_result.buy_sell_info.balance
  buy_sell_info.can_buy = proc_result.buy_sell_info.can_buy
  buy_sell_info.can_sell = proc_result.buy_sell_info.can_sell
  buy_sell_info.position_valuation = proc_result.buy_sell_info.position_valuation
  buy_sell_info.value = proc_result.buy_sell_info.value
  buy_sell_info.open_value = proc_result.buy_sell_info.open_value
  buy_sell_info.lim_long = proc_result.buy_sell_info.lim_long
  buy_sell_info.long_coef = proc_result.buy_sell_info.long_coef
  buy_sell_info.lim_short = proc_result.buy_sell_info.lim_short
  buy_sell_info.short_coef = proc_result.buy_sell_info.short_coef
  buy_sell_info.value_coef = proc_result.buy_sell_info.value_coef
  buy_sell_info.open_value_coef = proc_result.buy_sell_info.open_value_coef
  buy_sell_info.share = proc_result.buy_sell_info.share
  buy_sell_info.short_wa_price = proc_result.buy_sell_info.short_wa_price
  buy_sell_info.long_wa_price = proc_result.buy_sell_info.long_wa_price
  buy_sell_info.profit_loss = proc_result.buy_sell_info.profit_loss
  buy_sell_info.spread_hc = proc_result.buy_sell_info.spread_hc
  buy_sell_info.can_buy_own = proc_result.buy_sell_info.can_buy_own
  buy_sell_info.can_sell_own = proc_result.buy_sell_info.can_sell_own

  result.buy_sell_info_ex.limit_kind = proc_result.limit_kind
  result.buy_sell_info_ex.d_long = proc_result.d_long
  result.buy_sell_info_ex.d_min_long = proc_result.d_min_long
  result.buy_sell_info_ex.d_short = proc_result.d_short
  result.buy_sell_info_ex.d_min_short = proc_result.d_min_short
  result.buy_sell_info_ex.client_type = proc_result.client_type
  result.buy_sell_info_ex.is_long_allowed = proc_result.is_long_allowed
  result.buy_sell_info_ex.is_short_allowed = proc_result.is_short_allowed

  return pb.encode(qlua_pb_types.getBuySellInfoEx.Result, result)
end

-- AddColumn
proc_name = "ADD_COLUMN"
method_names[proc_name] = "AddColumn"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.AddColumn.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.AddColumn.Result)
  result.result = proc_result

  return pb.encode(qlua_pb_types.AddColumn.Result, result)
end

-- AllocTable
proc_name = "ALLOC_TABLE"
method_names[proc_name] = "AllocTable"
args_decoders[proc_name] = nil -- no args
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.AllocTable.Result)
  result.t_id = proc_result

  return pb.encode(qlua_pb_types.AllocTable.Result, result)
end

-- Clear
proc_name = "CLEAR"
method_names[proc_name] = "Clear"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.Clear.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.Clear.Result)
  result.result = proc_result

  return pb.encode(qlua_pb_types.Clear.Result, result)
end

-- CreateWindow
proc_name = "CREATE_WINDOW"
method_names[proc_name] = "CreateWindow"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.CreateWindow.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.CreateWindow.Result)
  result.result = proc_result

  return pb.encode(qlua_pb_types.CreateWindow.Result, result)
end

-- DeleteRow
proc_name = "DELETE_ROW"
method_names[proc_name] = "DeleteRow"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.DeleteRow.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.DeleteRow.Result)
  result.result = proc_result

  return pb.encode(qlua_pb_types.DeleteRow.Result, result)
end

-- DestroyTable
proc_name = "DESTROY_TABLE"
method_names[proc_name] = "DestroyTable"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.DestroyTable.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.DestroyTable.Result)
  result.result = proc_result

  return pb.encode(qlua_pb_types.DestroyTable.Result, result)
end

-- InsertRow
proc_name = "INSERT_ROW"
method_names[proc_name] = "InsertRow"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.InsertRow.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.InsertRow.Result)
  result.result = proc_result

  return pb.encode(qlua_pb_types.InsertRow.Result, result)
end

-- IsWindowClosed
proc_name = "IS_WINDOW_CLOSED"
method_names[proc_name] = "IsWindowClosed"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.IsWindowClosed.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.IsWindowClosed.Result)
  if proc_result == nil then
    result.null_window_closed = true
    result.value_window_closed = nil
  else
    result.value_window_closed = proc_result
  end

  return pb.encode(qlua_pb_types.IsWindowClosed.Result, result)
end

-- GetCell
proc_name = "GET_CELL"
method_names[proc_name] = "GetCell"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.GetCell.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.GetCell.Result)
  if proc_result then
    result.image = proc_result.image
    result.value = proc_result.value
  end

  return pb.encode(qlua_pb_types.GetCell.Result, result)
end

-- GetTableSize
proc_name = "GET_TABLE_SIZE"
method_names[proc_name] = "GetTableSize"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.GetTableSize.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.GetTableSize.Result)
  if proc_result then
    result.table_size = pb.defaults(qlua_pb_types.GetTableSize.TableSize)
    result.table_size.rows = proc_result.rows
    result.table_size.col = proc_result.col
  end

  return pb.encode(qlua_pb_types.GetTableSize.Result, result)
end

-- GetWindowCaption
proc_name = "GET_WINDOW_CAPTION"
method_names[proc_name] = "GetWindowCaption"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.GetWindowCaption.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.GetWindowCaption.Result)
  if proc_result then
    result.caption = proc_result
  end

  return pb.encode(qlua_pb_types.GetWindowCaption.Result, result)
end

-- GetWindowRect
proc_name = "GET_WINDOW_RECT"
method_names[proc_name] = "GetWindowRect"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.GetWindowRect.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.GetWindowRect.Result)
  if proc_result then
    result.window_rect = pb.defaults(qlua_pb_types.GetWindowRect.WindowRect)
    result.window_rect.top = proc_result.top
    result.window_rect.left = proc_result.left
    result.window_rect.bottom = proc_result.bottom
    result.window_rect.right = proc_result.right
  end

  return pb.encode(qlua_pb_types.GetWindowRect.Result, result)
end

-- SetCell
proc_name = "SET_CELL"
method_names[proc_name] = "SetCell"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.SetCell.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.SetCell.Result)
  result.result = proc_result

  return pb.encode(qlua_pb_types.SetCell.Result, result)
end

-- SetWindowCaption
proc_name = "SET_WINDOW_CAPTION"
method_names[proc_name] = "SetWindowCaption"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.SetWindowCaption.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.SetWindowCaption.Result)
  result.result = proc_result

  return pb.encode(qlua_pb_types.SetWindowCaption.Result, result)
end

-- SetWindowPos
proc_name = "SET_WINDOW_POS"
method_names[proc_name] = "SetWindowPos"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.SetWindowPos.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.SetWindowPos.Result)
  result.result = proc_result

  return pb.encode(qlua_pb_types.SetWindowPos.Result, result)
end

-- SetTableNotificationCallback
proc_name = "SET_TABLE_NOTIFICATION_CALLBACK"
method_names[proc_name] = "SetTableNotificationCallback"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.SetTableNotificationCallback.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.SetTableNotificationCallback.Result)
  result.result = proc_result

  return pb.encode(qlua_pb_types.SetTableNotificationCallback.Result, result)
end

-- RGB
proc_name = "RGB"
method_names[proc_name] = "RGB"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.RGB.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.RGB.Result)
  result.result = proc_result

  return pb.encode(qlua_pb_types.RGB.Result, result)
end

-- SetColor
proc_name = "SET_COLOR"
method_names[proc_name] = "SetColor"
args_decoders[proc_name] = function (encoded_args)

  local args = pb.decode(qlua_pb_types.SetColor.Args, encoded_args)

  args.row = args.null_row and nil or args.value_row
  args.col = args.null_col and nil or args.value_col
  args.b_color = args.null_b_color and nil or args.value_b_color
  args.f_color = args.null_f_color and nil or args.value_f_color
  args.sel_b_color = args.null_sel_b_color and nil or args.value_sel_b_color
  args.sel_f_color = args.null_sel_f_color and nil or args.value_sel_f_color

  return args
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.SetColor.Result)
  result.result = proc_result

  return pb.encode(qlua_pb_types.SetColor.Result, result)
end

-- Highlight
proc_name = "HIGHLIGHT"
method_names[proc_name] = "Highlight"
args_decoders[proc_name] = function (encoded_args)

  local args = pb.decode(qlua_pb_types.Highlight.Args, encoded_args)

  args.row = args.null_row and nil or args.value_row
  args.col = args.null_col and nil or args.value_col
  args.b_color = args.null_b_color and nil or args.value_b_color
  args.f_color = args.null_f_color and nil or args.value_f_color

  return args
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.Highlight.Result)
  result.result = proc_result

  return pb.encode(qlua_pb_types.Highlight.Result, result)
end

-- SetSelectedRow
proc_name = "SET_SELECTED_ROW"
method_names[proc_name] = "SetSelectedRow"
args_decoders[proc_name] = function (encoded_args)

  local args = pb.decode(qlua_pb_types.SetSelectedRow.Args, encoded_args)
  args.row = args.null_row and nil or args.value_row

  return args
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.SetSelectedRow.Result)
  result.result = proc_result

  return pb.encode(qlua_pb_types.SetSelectedRow.Result, result)
end

-- AddLabel
proc_name = "ADD_LABEL"
method_names[proc_name] = "AddLabel"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.AddLabel.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.AddLabel.Result)

  if proc_result then
    result.label_id = proc_result
  else
    result.null_result = true
    result.label_id = nil
  end

  return pb.encode(qlua_pb_types.AddLabel.Result, result)
end

-- DelLabel
proc_name = "DEL_LABEL"
method_names[proc_name] = "DelLabel"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.DelLabel.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.DelLabel.Result)
  result.result = proc_result

  return pb.encode(qlua_pb_types.DelLabel.Result, result)
end

-- DelAllLabels
proc_name = "DEL_ALL_LABELS"
method_names[proc_name] = "DelAllLabels"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.DelAllLabels.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.DelAllLabels.Result)
  result.result = proc_result

  return pb.encode(qlua_pb_types.DelAllLabels.Result, result)
end

-- GetLabelParams
proc_name = "GET_LABEL_PARAMS"
method_names[proc_name] = "GetLabelParams"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.GetLabelParams.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.GetLabelParams.Result)
  if proc_result then
    result.label_params = proc_result
  end

  return pb.encode(qlua_pb_types.GetLabelParams.Result, result)
end

-- SetLabelParams
proc_name = "SET_LABEL_PARAMS"
method_names[proc_name] = "SetLabelParams"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.SetLabelParams.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.SetLabelParams.Result)
  result.result = proc_result

  return pb.encode(qlua_pb_types.SetLabelParams.Result, result)
end

-- Subscribe_Level_II_Quotes
proc_name = "SUBSCRIBE_LEVEL_II_QUOTES"
method_names[proc_name] = "Subscribe_Level_II_Quotes"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.Subscribe_Level_II_Quotes.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.Subscribe_Level_II_Quotes.Result)
  result.result = proc_result

  return pb.encode(qlua_pb_types.Subscribe_Level_II_Quotes.Result, result)
end

-- Unsubscribe_Level_II_Quotes
proc_name = "UNSUBSCRIBE_LEVEL_II_QUOTES"
method_names[proc_name] = "Unsubscribe_Level_II_Quotes"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.Unsubscribe_Level_II_Quotes.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.Unsubscribe_Level_II_Quotes.Result)
  result.result = proc_result

  return pb.encode(qlua_pb_types.Unsubscribe_Level_II_Quotes.Result, result)
end

-- IsSubscribed_Level_II_Quotes
proc_name = "IS_SUBSCRIBED_LEVEL_II_QUOTES"
method_names[proc_name] = "IsSubscribed_Level_II_Quotes"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.IsSubscribed_Level_II_Quotes.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.IsSubscribed_Level_II_Quotes.Result)
  result.result = proc_result

  return pb.encode(qlua_pb_types.IsSubscribed_Level_II_Quotes.Result, result)
end

-- ParamRequest
proc_name = "PARAM_REQUEST"
method_names[proc_name] = "ParamRequest"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.ParamRequest.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.ParamRequest.Result)
  result.result = proc_result

  return pb.encode(qlua_pb_types.ParamRequest.Result, result)
end

-- CancelParamRequest
proc_name = "CANCEL_PARAM_REQUEST"
method_names[proc_name] = "CancelParamRequest"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.CancelParamRequest.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.CancelParamRequest.Result)
  result.result = proc_result

  return pb.encode(qlua_pb_types.CancelParamRequest.Result, result)
end

-- bit.tohex
proc_name = "BIT_TOHEX"
method_names[proc_name] = "bit.tohex"
args_decoders[proc_name] = function (encoded_args)
  local args = pb.decode(qlua_pb_types.bit.tohex.Args, encoded_args)
  if not args.null_n then
    args.n = args.value_n
  end
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.bit.tohex.Result)
  result.result = proc_result

  return pb.encode(qlua_pb_types.bit.tohex.Result, result)
end

-- bit.bnot
proc_name = "BIT_BNOT"
method_names[proc_name] = "bit.bnot"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.bit.bnot.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.bit.bnot.Result)
  result.result = proc_result

  return pb.encode(qlua_pb_types.bit.bnot.Result, result)
end

-- bit.band
proc_name = "BIT_BAND"
method_names[proc_name] = "bit.band"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.bit.band.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.bit.band.Result)
  result.result = proc_result

  return pb.encode(qlua_pb_types.bit.band.Result, result)
end

-- bit.bor
proc_name = "BIT_BOR"
method_names[proc_name] = "bit.bor"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.bit.bor.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.bit.bor.Result)
  result.result = proc_result

  return pb.encode(qlua_pb_types.bit.bor.Result, result)
end

-- bit.bxor
proc_name = "BIT_BXOR"
method_names[proc_name] = "bit.bxor"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.bit.bxor.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.bit.bxor.Result)
  result.result = proc_result

  return pb.encode(qlua_pb_types.bit.bxor.Result, result)
end

-- bit.test
proc_name = "BIT_TEST"
method_names[proc_name] = "bit.test"
args_decoders[proc_name] = function (encoded_args)
  return pb.decode(qlua_pb_types.bit.test.Args, encoded_args)
end
result_encoders[method_names[proc_name]] = function (proc_result)

  local result = pb.defaults(qlua_pb_types.bit.test.Result)
  result.result = proc_result

  return pb.encode(qlua_pb_types.bit.test.Result, result)
end

return ProtobufRequestResponseSerde
