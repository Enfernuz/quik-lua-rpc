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

converters["OnTrade"] = function (trade)
  
  local result = {}
  
  result.trade_num = assert(trade.trade_num, "Таблица 'trade' не содержит обязательного поля 'trade_num'.")
  result.order_num = assert(trade.order_num, "Таблица 'trade' не содержит обязательного поля 'order_num'.")
  result.brokerref = trade.brokerref
  result.userid = trade.userid
  result.firmid = trade.firmid
  if trade.canceled_uid then result.canceled_uid = tostring(trade.canceled_uid) end
  result.account = trade.account
  result.price = tostring( assert(trade.price, "Таблица 'trade' не содержит обязательного поля 'price'.") )
  result.qty = assert(trade.qty, "Таблица 'trade' не содержит обязательного поля 'qty'.")
  result.value = tostring( assert(trade.value, "Таблица 'trade' не содержит обязательного поля 'value'.") )
  if trade.accruedint then result.accruedint = tostring(trade.accruedint) end
  if trade.yield then result.yield = tostring(trade.yield) end
  result.settlecode = trade.settlecode
  result.cpfirmid = trade.cpfirmid
  result.flags = assert(trade.flags, "Таблица 'trade' не содержит обязательного поля 'flags'.")
  if trade.price2 then result.price2 = tostring(trade.price2) end
  if trade.reporate then result.reporate = tostring(trade.reporate) end
  result.client_code = trade.client_code
  if trade.accrued2 then result.accrued2 = tostring(trade.accrued2) end
  if trade.repoterm then result.repoterm = tostring(trade.repoterm) end
  if trade.repovalue then result.repovalue = tostring(trade.repovalue) end
  if trade.repo2value then result.repo2value = tostring(trade.repo2value) end
  if trade.start_discount then result.start_discount = tostring(trade.start_discount) end
  if trade.lower_discount then result.lower_discount = tostring(trade.lower_discount) end
  if trade.upper_discount then result.upper_discount = tostring(trade.upper_discount) end
  if trade.block_securities then result.block_securities = tostring(trade.block_securities) end
  if trade.clearing_comission then result.clearing_comission = tostring(trade.clearing_comission) end
  if trade.exchange_comission then result.exchange_comission = tostring(trade.exchange_comission) end
  if trade.tech_center_comission then result.tech_center_comission = tostring(trade.tech_center_comission) end
  if trade.settle_date then result.settle_date = tostring(trade.settle_date) end
  result.settle_currency = trade.settle_currency
  result.trade_currency = trade.trade_currency
  result.exchange_code = trade.exchange_code
  result.station_id = trade.station_id
  result.sec_code = trade.sec_code
  result.class_code = trade.class_code
  result.datetime = assert(trade.datetime, "Таблица 'trade' не содержит обязательного поля 'datetime'.")
  result.bank_acc_id = trade.bank_acc_id
  if trade.broker_comission then result.broker_comission = tostring(trade.broker_comission) end
  if trade.linked_trade then result.linked_trade = tostring(trade.linked_trade) end
  result.period = assert(trade.period, "Таблица 'trade' не содержит обязательного поля 'period'.")
  if trade.trans_id then result.trans_id = tostring(trade.trans_id) end
  result.kind = assert(trade.kind, "Таблица 'trade' не содержит обязательного поля 'kind'.")
  result.clearing_bank_accid = trade.clearing_bank_accid
  result.canceled_datetime = trade.canceled_datetime
  result.clearing_firmid = trade.clearing_firmid
  result.system_ref = trade.system_ref
  result.uid = trade.uid
  
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
