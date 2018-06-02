local EventDataConverter = {}

local utils = require("utils.utils")

local converters = {}

local noop = function () end
local identity = function (x) return x end

converters["OnClose"] = noop

converters["PublisherOnline"] = noop

converters["PublisherOffline"] = noop

converters["OnFirm"] = function (firm)
  return {
    firmid = utils.Cp1251ToUtf8(firm.firmid),
    firm_name = firm.firm_name, 
    status = firm.status, 
    exchange = firm.exchange
  }
end

converters["OnAllTrade"] = function (alltrade)
  
  local result = {}
  
  result.trade_num = assert(alltrade.trade_num, "Таблица 'alltrade' не содержит обязательного поля 'trade_num'.")
  result.flags = assert(alltrade.flags, "Таблица 'alltrade' не содержит обязательного поля 'flags'.")
  result.price = tostring( assert(alltrade.price, "Таблица 'alltrade' не содержит обязательного поля 'price'.") )
  result.qty = assert(alltrade.qty, "Таблица 'alltrade' не содержит обязательного поля 'qty'.")
  if alltrade.value then result.value = tostring(alltrade.value) end
  if alltrade.accruedint then result.accruedint = tostring(alltrade.accruedint) end
  if alltrade.yield then result.yield = tostring(alltrade.yield) end
  result.settlecode = alltrade.settlecode
  if alltrade.reporate then result.reporate = tostring(alltrade.reporate) end
  if alltrade.repovalue then result.repovalue = tostring(alltrade.repovalue) end
  if alltrade.repo2value then result.repo2value = tostring(alltrade.repo2value) end
  if alltrade.repoterm then result.repoterm = tostring(alltrade.repoterm) end
  result.sec_code = alltrade.sec_code
  result.class_code = alltrade.class_code
  result.datetime = assert(alltrade.datetime, "Таблица 'alltrade' не содержит обязательного поля 'datetime'.")
  result.period = assert(alltrade.period, "Таблица 'alltrade' не содержит обязательного поля 'period'.")
  if alltrade.open_interest then result.open_interest = tostring(alltrade.open_interest) end
  result.exchange_code = alltrade.exchange_code
  
  return result
end

converters["OnStopOrder"] = function (stop_order)
  
  local result = {}
  
  result.order_num = assert(stop_order.order_num, "Таблица 'stop_order' не содержит обязательного поля 'order_num'.")
  if stop_order.ordertime then result.ordertime = tostring(stop_order.ordertime) end
  result.flags = assert(stop_order.flags, "Таблица 'stop_order' не содержит обязательного поля 'flags'.")
  result.brokerref = stop_order.brokerref
  result.firmid = stop_order.firmid
  result.account = utils.Cp1251ToUtf8(stop_order.account)
  result.condition = assert(stop_order.condition, "Таблица 'stop_order' не содержит обязательного поля 'condition'.")
  result.condition_price = tostring( assert(stop_order.condition_price, "Таблица 'stop_order' не содержит обязательного поля 'condition_price'.") )
  result.price = tostring( assert(stop_order.price, "Таблица 'stop_order' не содержит обязательного поля 'price'.") )
  result.qty = assert(stop_order.qty, "Таблица 'stop_order' не содержит обязательного поля 'qty'.")
  if stop_order.linkedorder then result.linkedorder = tostring(stop_order.linkedorder) end
  if stop_order.expiry then result.expiry = tostring(stop_order.expiry) end
  if stop_order.trans_id then result.trans_id = tostring(stop_order.trans_id) end
  result.client_code = utils.Cp1251ToUtf8(stop_order.client_code)
  if stop_order.co_order_num then result.co_order_num = tostring(stop_order.co_order_num) end
  if stop_order.co_order_price then result.co_order_price = tostring(stop_order.co_order_price) end
  result.stop_order_type = assert(stop_order.stop_order_type, "Таблица 'stop_order' не содержит обязательного поля 'stop_order_type'.")
  if stop_order.orderdate then result.orderdate = tostring(stop_order.orderdate) end
  if stop_order.alltrade_num then result.alltrade_num = tostring(stop_order.alltrade_num) end
  result.stopflags = assert(stop_order.stopflags, "Таблица 'stop_order' не содержит обязательного поля 'stopflags'.")
  if stop_order.offset then result.offset = tostring(stop_order.offset) end
  if stop_order.spread then result.spread = tostring(stop_order.spread) end
  if stop_order.balance then result.balance = tostring(stop_order.balance) end
  if stop_order.uid then result.uid = tostring(stop_order.uid) end
  result.filled_qty = assert(stop_order.filled_qty, "Таблица 'stop_order' не содержит обязательного поля 'filled_qty'.")
  if stop_order.withdraw_time then result.withdraw_time = tostring(stop_order.withdraw_time) end
  if stop_order.condition_price2 then result.condition_price2 = tostring(stop_order.condition_price2) end
  if stop_order.active_from_time then result.active_from_time = tostring(stop_order.active_from_time) end
  if stop_order.active_to_time then result.active_to_time = tostring(stop_order.active_to_time) end
  result.sec_code = stop_order.sec_code
  result.class_code = stop_order.class_code
  result.condition_sec_code = stop_order.condition_sec_code
  result.condition_class_code = stop_order.condition_class_code
  if stop_order.canceled_uid then result.canceled_uid = tostring(stop_order.canceled_uid) end
  result.order_date_time = assert(stop_order.order_date_time, "Таблица 'stop_order' не содержит обязательного поля 'order_date_time'.")
  result.withdraw_datetime = stop_order.withdraw_datetime
  
  return result
end

converters["OnQuote"] = identity

converters["OnDisconnected"] = noop

converters["OnConnected"] = identity

converters["OnCleanUp"] = noop

function EventDataConverter.convert (event_type, event_data)
  return converters[event_type](event_data)
end

return EventDataConverter
