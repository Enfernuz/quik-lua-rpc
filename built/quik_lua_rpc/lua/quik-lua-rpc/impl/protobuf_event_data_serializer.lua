package.path = "../?.lua;" .. package.path

local EventDataSerializer = require("impl.event_data_serializer")

local qlua_pb_types = require("qlua.qlua_pb_types")
local pb = require("pb")

local ProtobufEventDataSerializer = {}

setmetatable(ProtobufEventDataSerializer, {__index = EventDataSerializer})

-- The following functions need the module "qlua.qlua_pb_init.lua" to be already loaded

local function to_pb_obj (pb_type, obj)
  
  local result = pb.defaults(pb_type)
  for k, v in pairs(obj) do
    result[k] = v
  end
  
  return result
end

local function encode (pb_type, obj)
  return pb.encode(pb_type, to_pb_obj(pb_type, obj))
end

local function event_value (event_type)
  return pb.enum(".qlua.events.EventType", event_type)
end

function ProtobufEventDataSerializer:PublisherOnline ()
  return event_value("PUBLISHER_ONLINE"), nil
end

function ProtobufEventDataSerializer:OnClose ()
  return event_value("ON_CLOSE"), nil
end

function ProtobufEventDataSerializer:OnStop (stop_event_data)
  return event_value("ON_STOP"), encode(qlua_pb_types.qlua_structures.StopEventInfo, stop_event_data)
end

function ProtobufEventDataSerializer:OnFirm (firm)
  
  local status = firm.status
  if status then
    firm.value_status = status
  else
    firm.null_status = true
    firm.value_status = nil
  end
  
  return event_value("ON_FIRM"), encode(qlua_pb_types.qlua_structures.Firm, firm)
end

-- TODO: test
function ProtobufEventDataSerializer:OnAllTrade (alltrade)
  
  alltrade.datetime = to_pb_obj(qlua_pb_types.qlua_structures.DateTimeEntry, alltrade.datetime)
  alltrade.uid = tostring(uid)
  
  local flags = alltrade.flags
  if flags then
    alltrade.value_flags = flags
  else
    alltrade.null_flags = true
    alltrade.value_flags = nil
  end
  
  return event_value("ON_ALL_TRADE"), encode(qlua_pb_types.qlua_structures.AllTrade, alltrade)
end

-- TODO: test
function ProtobufEventDataSerializer:OnTrade (trade)
  
  trade.datetime = to_pb_obj(qlua_pb_types.qlua_structures.DateTimeEntry, trade.datetime)
  trade.uid = tostring(trade.uid)
  
  if trade.canceled_datetime then
    trade.canceled_datetime = to_pb_obj(qlua_pb_types.qlua_structures.DateTimeEntry, trade.canceled_datetime)
  end
  
  return event_value("ON_TRADE"), encode(qlua_pb_types.qlua_structures.Trade, trade)
end

-- TODO: test
function ProtobufEventDataSerializer:OnOrder (order)
  
  order.datetime = to_pb_obj(qlua_pb_types.qlua_structures.DateTimeEntry, order.datetime)
  order.uid = tostring(order.uid)
  if order.withdraw_datetime then
    order.withdraw_datetime = to_pb_obj(qlua_pb_types.qlua_structures.DateTimeEntry, order.withdraw_datetime)
  end
  
  return event_value("ON_ORDER"), encode(qlua_pb_types.qlua_structures.Order, order)
end

-- TODO: test
function ProtobufEventDataSerializer:OnAccountBalance (acc_bal)
  return event_value("ON_ACCOUNT_BALANCE"), encode(qlua_pb_types.qlua_structures.AccountBalance, acc_bal)
end

-- TODO: test
function ProtobufEventDataSerializer:OnFuturesLimitChange (fut_limit)
  return event_value("ON_FUTURES_LIMIT_CHANGE"), encode(qlua_pb_types.qlua_structures.FuturesLimit, fut_limit)
end

-- TODO: test
function ProtobufEventDataSerializer:OnFuturesLimitDelete (lim_del)
  return event_value("ON_FUTURES_LIMIT_DELETE"), encode(qlua_pb_types.qlua_structures.FuturesLimitDelete, lim_del)
end

function ProtobufEventDataSerializer:OnFuturesClientHolding (fut_pos)
  return event_value("ON_FUTURES_CLIENT_HOLDING"), encode(qlua_pb_types.qlua_structures.FuturesClientHolding, fut_pos)
end

function ProtobufEventDataSerializer:OnMoneyLimit (mlimit)
  return event_value("ON_MONEY_LIMIT"), encode(qlua_pb_types.qlua_structures.MoneyLimit, mlimit)
end

-- TODO: test
function ProtobufEventDataSerializer:OnMoneyLimitDelete (mlimit_del)
  return event_value("ON_MONEY_LIMIT_DELETE"), encode(qlua_pb_types.qlua_structures.MoneyLimitDelete, mlimit_del)
end

function ProtobufEventDataSerializer:OnDepoLimit (dlimit)
  return event_value("ON_DEPO_LIMIT"), encode(qlua_pb_types.qlua_structures.DepoLimit, dlimit)
end

-- TODO: test
function ProtobufEventDataSerializer:OnDepoLimitDelete (dlimit_del)
  return event_value("ON_DEPO_LIMIT_DELETE"), encode(qlua_pb_types.qlua_structures.DepoLimitDelete, dlimit_del)
end

-- TODO: test
function ProtobufEventDataSerializer:OnAccountPosition (acc_pos)
  return event_value("ON_ACCOUNT_POSITION"), encode(qlua_pb_types.qlua_structures.AccountPosition, acc_pos)
end

-- TODO: test
function ProtobufEventDataSerializer:OnNegDeal (neg_deal)
  
  neg_deal.date_time = to_pb_obj(qlua_pb_types.qlua_structures.DateTimeEntry, neg_deal.date_time)
  
  if neg_deal.withdraw_date_time then
    neg_deal.withdraw_date_time = to_pb_obj(qlua_pb_types.qlua_structures.DateTimeEntry, neg_deal.withdraw_date_time)
  end
  
  if neg_deal.activation_date_time then
    neg_deal.activation_date_time = to_pb_obj(qlua_pb_types.qlua_structures.DateTimeEntry, neg_deal.activation_date_time)
  end
  
  return event_value("ON_NEG_DEAL"), encode(qlua_pb_types.qlua_structures.NegDeal, neg_deal)
end

-- TODO: test
function ProtobufEventDataSerializer:OnNegTrade (neg_trade)
  return event_value("ON_NEG_TRADE"), encode(qlua_pb_types.qlua_structures.NegTrade, neg_trade)
end

function ProtobufEventDataSerializer:OnStopOrder (stop_order)
  
  stop_order.order_date_time = to_pb_obj(qlua_pb_types.qlua_structures.DateTimeEntry, stop_order.order_date_time)
  
  if stop_order.withdraw_datetime then
    stop_order.withdraw_datetime = to_pb_obj(qlua_pb_types.qlua_structures.DateTimeEntry, stop_order.withdraw_datetime)
  end
  
  return event_value("ON_STOP_ORDER"), encode(qlua_pb_types.qlua_structures.StopOrder, stop_order)
end

-- TODO: test
function ProtobufEventDataSerializer:OnTransReply (trans_reply)
  
  trans_reply.date_time = to_pb_obj(qlua_pb_types.qlua_structures.DateTimeEntry, trans_reply.date_time)
  
  return event_value("ON_TRANS_REPLY"), encode(qlua_pb_types.qlua_structures.Transaction, trans_reply)
end

function ProtobufEventDataSerializer:OnParam (param_event_data)
  return event_value("ON_PARAM"), encode(qlua_pb_types.qlua_structures.ParamEventInfo, param_event_data)
end

-- TODO: test
function ProtobufEventDataSerializer:OnQuote (quote_event_data)
  return event_value("ON_QUOTE"), encode(qlua_pb_types.qlua_structures.QuoteEventInfo, quote_event_data)
end

function ProtobufEventDataSerializer:OnConnected (connected_event_data)
  return event_value("ON_CONNECTED"), encode(qlua_pb_types.qlua_structures.ConnectedEventInfo, connected_event_data)
end

function ProtobufEventDataSerializer:OnDisconnected ()
  return event_value("ON_DISCONNECTED"), nil
end

function ProtobufEventDataSerializer:OnCleanUp ()
  return event_value("ON_CLEAN_UP"), nil
end

function ProtobufEventDataSerializer:OnDataSourceUpdate (update_info)
  
  local pb_update_info = to_pb_obj(qlua_pb_types.qlua_structures.DataSourceUpdateInfo, update_info)
  
  if update_info.time then
    pb_update_info.time = to_pb_obj(qlua_pb_types.qlua_structures.DataSourceTime, update_info.time)
  end
  
  local ds_size = update_info.size
  if ds_size then
    pb_update_info.value_size = ds_size
  else 
    pb_update_info.null_size = true
    pb_update_info.value_size = nil
  end
    
  return event_value("ON_DATA_SOURCE_UPDATE"), pb.encode(qlua_pb_types.qlua_structures.DataSourceUpdateInfo, pb_update_info)
end

return ProtobufEventDataSerializer
