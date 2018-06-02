package.path = "../?.lua;" .. package.path

local EventDataSerializer = require("impl.event_data_serializer")

local qlua_pb_types = require("qlua.qlua_pb_types")
local pb = require("pb")

local ProtobufEventDataSerializer = {}

setmetatable(ProtobufEventDataSerializer, {__index = EventDataSerializer})

-- The following functions need the module "qlua.qlua_pb_init.lua" being already loaded

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
  return event_value("ON_FIRM"), encode(qlua_pb_types.qlua_structures.Firm, firm)
end

-- TODO: test
function ProtobufEventDataSerializer:OnAllTrade (alltrade)
  
  alltrade.datetime = to_pb_obj(qlua_pb_types.qlua_structures.DateTimeEntry, alltrade.datetime)
  
  return event_value("ON_ALL_TRADE"), encode(qlua_pb_types.qlua_structures.AllTrade, alltrade)
end

-- TODO: test
function ProtobufEventDataSerializer:OnTrade (trade)
  
  trade.datetime = to_pb_obj(qlua_pb_types.qlua_structures.DateTimeEntry, trade.datetime)
  
  if trade.canceled_datetime then
    trade.canceled_datetime = to_pb_obj(qlua_pb_types.qlua_structures.DateTimeEntry, trade.canceled_datetime)
  end
  
  return event_value("ON_TRADE"), encode(qlua_pb_types.qlua_structures.Trade, trade)
end

-- TODO: test
function ProtobufEventDataSerializer:OnOrder (order)
  
  order.datetime = to_pb_obj(qlua_pb_types.qlua_structures.DateTimeEntry, order.datetime)
  
  if order.withdraw_datetime then
    order.withdraw_datetime = to_pb_obj(qlua_pb_types.qlua_structures.DateTimeEntry, order.withdraw_datetime)
  end
  
  return event_value("ON_ORDER"), encode(qlua_pb_types.qlua_structures.Order, order)
end

function ProtobufEventDataSerializer:OnAccountBalance (acc_bal)
  return event_value("ON_ACCOUNT_BALANCE"), encode(qlua_pb_types.qlua_structures.AccountBalance, acc_bal)
end

function ProtobufEventDataSerializer:OnFuturesLimitChange (fut_limit)
  return event_value("ON_FUTURES_LIMIT_CHANGE"), encode(qlua_pb_types.qlua_structures.FuturesLimit, fut_limit)
end

function ProtobufEventDataSerializer:OnFuturesLimitDelete (lim_del)
  return event_value("ON_FUTURES_LIMIT_DELETE"), encode(qlua_pb_types.qlua_structures.FuturesLimitDelete, lim_del)
end

function ProtobufEventDataSerializer:OnFuturesClientHolding (fut_pos)
  return event_value("ON_FUTURES_CLIENT_HOLDING"), encode(qlua_pb_types.qlua_structures.FuturesClientHolding, fut_pos)
end

function ProtobufEventDataSerializer:OnMoneyLimit (mlimit)
  return event_value("ON_MONEY_LIMIT"), encode(qlua_pb_types.qlua_structures.MoneyLimit, mlimit)
end

function ProtobufEventDataSerializer:OnMoneyLimitDelete (mlimit_del)
  return event_value("ON_MONEY_LIMIT_DELETE"), encode(qlua_pb_types.qlua_structures.MoneyLimitDelete, mlimit_del)
end

function ProtobufEventDataSerializer:OnDepoLimit (dlimit)
  return event_value("ON_DEPO_LIMIT"), encode(qlua_pb_types.qlua_structures.DepoLimit, dlimit)
end

function ProtobufEventDataSerializer:OnDepoLimitDelete (dlimit_del)
  return event_value("ON_DEPO_LIMIT_DELETE"), encode(qlua_pb_types.qlua_structures.DepoLimitDelete, dlimit_del)
end

function ProtobufEventDataSerializer:OnAccountPosition (acc_pos)
  return event_value("ON_ACCOUNT_POSITION"), encode(qlua_pb_types.qlua_structures.AccountPosition, acc_pos)
end

function ProtobufEventDataSerializer:OnNegDeal (neg_deal)
  return event_value("ON_NEG_DEAL"), encode(qlua_pb_types.qlua_structures.NegDeal, neg_deal)
end

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

function ProtobufEventDataSerializer:OnTransReply (trans_reply)
  return event_value("ON_TRANS_REPLY"), encode(qlua_pb_types.qlua_structures.Transaction, trans_reply)
end

function ProtobufEventDataSerializer:OnParam (param_event_data)
  return event_value("ON_PARAM"), encode(qlua_pb_types.qlua_structures.ParamEventInfo, param_event_data)
end

function ProtobufEventDataSerializer:OnQuote (quote_event_data)
  return event_value("ON_PARAM"), encode(qlua_pb_types.qlua_structures.QuoteEventInfo, quote_event_data)
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

return ProtobufEventDataSerializer
