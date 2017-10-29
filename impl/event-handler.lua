package.path = "../?.lua;" .. package.path

local qlua_events = require("messages.qlua_events_pb")
local struct_factory = require("utils.struct_factory")

local error = assert(error, "error function is missing.")
local pcall = assert(pcall, "pcall function is missing.")

local EventHandler = {}

local function return_nil() 
  return nil 
end

local event_handlers = {}

event_handlers[qlua_events.EventType.PUBLISHER_ONLINE] = return_nil
event_handlers[qlua_events.EventType.PUBLISHER_OFFLINE] = return_nil
event_handlers[qlua_events.EventType.ON_CLOSE] = return_nil
event_handlers[qlua_events.EventType.ON_CONNECTED] = return_nil
event_handlers[qlua_events.EventType.ON_DISCONNECTED] = return_nil
event_handlers[qlua_events.EventType.ON_CLEAN_UP] = return_nil

event_handlers[qlua_events.EventType.ON_FIRM] = struct_factory.create_Firm
event_handlers[qlua_events.EventType.ON_ALL_TRADE] = struct_factory.create_AllTrade
event_handlers[qlua_events.EventType.ON_TRADE] = struct_factory.create_Trade
event_handlers[qlua_events.EventType.ON_ORDER] = struct_factory.create_Order
event_handlers[qlua_events.EventType.ON_ACCOUNT_BALANCE] = struct_factory.create_AccountBalance
event_handlers[qlua_events.EventType.ON_FUTURES_LIMIT_CHANGE] = struct_factory.create_FuturesLimit
event_handlers[qlua_events.EventType.ON_FUTURES_LIMIT_DELETE] = struct_factory.create_FuturesLimitDelete
event_handlers[qlua_events.EventType.ON_FUTURES_CLIENT_HOLDING] = struct_factory.create_FuturesClientHolding
event_handlers[qlua_events.EventType.ON_MONEY_LIMIT] = struct_factory.create_MoneyLimit
event_handlers[qlua_events.EventType.ON_MONEY_LIMIT_DELETE] = struct_factory.create_MoneyLimitDelete
event_handlers[qlua_events.EventType.ON_DEPO_LIMIT] = struct_factory.create_DepoLimit
event_handlers[qlua_events.EventType.ON_DEPO_LIMIT_DELETE] = struct_factory.create_DepoLimitDelete
event_handlers[qlua_events.EventType.ON_ACCOUNT_POSITION] = struct_factory.create_AccountPosition
event_handlers[qlua_events.EventType.ON_NEG_DEAL] = struct_factory.create_NegDeal
event_handlers[qlua_events.EventType.ON_NEG_TRADE] = struct_factory.create_NegTrade
event_handlers[qlua_events.EventType.ON_STOP_ORDER] = struct_factory.create_StopOrder
event_handlers[qlua_events.EventType.ON_TRANS_REPLY] = struct_factory.create_Transaction
event_handlers[qlua_events.EventType.ON_PARAM] = struct_factory.create_ParamEventInfo
event_handlers[qlua_events.EventType.ON_QUOTE] = struct_factory.create_QuoteEventInfo

function EventHandler:handle(event_type, event_data)

  if event_type == nil then error("No event_type provided.", 2) end

  local f_handler = event_handlers[event_type]
  
  if f_handler == nil then 
    error(string.format("Unknown event type: %s.", event_type), 0)
  else
    local ok, result = pcall( function() return f_handler(event_data) end )
    if ok then
      return result
    else
      error(string.format("Couldn't handle an event with type %d. Error message: [%s].", event_type, result), 0)
    end
  end
end

return EventHandler
