local EventDataConverter = {}

local utils = require("utils.utils")

local converters = {}

local noop = function () end
local identity = function (x) return x end

converters["OnClose"] = noop

converters["OnStop"] = identity

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

converters["OnOrder"] = function (order)
  
  local result = {}
  
  result.order_num = assert(order.order_num, "Таблица 'order' не содержит обязательного поля 'order_num'.")
  result.flags = assert(order.flags, "Таблица 'order' не содержит обязательного поля 'flags'.")
  result.brokerref = order.brokerref
  result.userid = order.userid
  result.firmid = order.firmid
  result.account = order.account
  result.price = tostring( assert(order.price, "Таблица 'order' не содержит обязательного поля 'price'.") )
  result.qty = assert(order.qty, "Таблица 'order' не содержит обязательного поля 'qty'.")
  if order.balance then result.balance = tostring(order.balance) end
  if order.value then result.value = tostring(order.value) end
  if order.accruedint then result.accruedint = tostring(order.accruedint) end
  if order.yield then result.yield = tostring(order.yield) end
  if order.trans_id then result.trans_id = tostring(order.trans_id) end
  result.client_code = order.client_code
  if order.price2 then result.price2 = tostring(order.price2) end
  result.settlecode = order.settlecode
  if order.uid then result.uid = tostring(order.uid) end
  if order.canceled_uid then result.canceled_uid = tostring(order.canceled_uid) end
  result.exchange_code = order.exchange_code
  if order.activation_time then result.activation_time = tostring(order.activation_time) end
  if order.linkedorder then result.linkedorder = tostring(order.linkedorder) end
  if order.expiry then result.expiry = tostring(order.expiry) end
  result.sec_code = order.sec_code
  result.class_code = order.class_code
  result.datetime = assert(order.datetime, "Таблица 'order' не содержит обязательного поля 'datetime'.")
  result.withdraw_datetime = order.withdraw_datetime
  result.bank_acc_id = order.bank_acc_id
  result.value_entry_type = assert(order.value_entry_type, "Таблица 'order' не содержит обязательного поля 'value_entry_type'.")
  if order.repoterm then result.repoterm = tostring(order.repoterm) end
  if order.repovalue then result.repovalue = tostring(order.repovalue) end
  if order.repo2value then result.repo2value = tostring(order.repo2value) end
  if order.repo_value_balance then result.repo_value_balance = tostring(order.repo_value_balance) end
  if order.start_discount then result.start_discount = tostring(order.start_discount) end
  result.reject_reason = order.reject_reason
  if order.ext_order_flags then result.ext_order_flags = tostring(order.ext_order_flags) end
  result.min_qty = assert(order.min_qty, "Таблица 'order' не содержит обязательного поля 'min_qty'.")
  result.exec_type = assert(order.exec_type, "Таблица 'order' не содержит обязательного поля 'exec_type'.")
  result.side_qualifier = assert(order.side_qualifier, "Таблица 'order' не содержит обязательного поля 'side_qualifier'.")
  result.acnt_type = assert(order.acnt_type, "Таблица 'order' не содержит обязательного поля 'acnt_type'.")
  result.capacity = assert(order.acnt_type, "Таблица 'order' не содержит обязательного поля 'capacity'.")
  result.passive_only_order = assert(order.passive_only_order, "Таблица 'order' не содержит обязательного поля 'passive_only_order'.")
  result.visible = assert(order.visible, "Таблица 'order' не содержит обязательного поля 'visible'.")
  
  return result
end

converters["OnAccountBalance"] = function (acc_bal)
  
  local result = {}
  
  result.firmid = acc_bal.firmid
  result.sec_code = acc_bal.sec_code
  result.trdaccid = acc_bal.trdaccid
  result.depaccid = acc_bal.depaccid
  if acc_bal.openbal then result.openbal = tostring(acc_bal.openbal) end
  if acc_bal.currentpos then result.currentpos = tostring(acc_bal.currentpos) end
  if acc_bal.plannedpossell then result.plannedpossell = tostring(acc_bal.plannedpossell) end
  if acc_bal.plannedposbuy then result.plannedposbuy = tostring(acc_bal.plannedposbuy) end
  if acc_bal.planbal then result.planbal = tostring(acc_bal.planbal) end
  if acc_bal.usqtyb then result.usqtyb = tostring(acc_bal.usqtyb) end
  if acc_bal.usqtys then result.usqtys = tostring(acc_bal.usqtys) end
  if acc_bal.planned then result.planned = tostring(acc_bal.planned) end
  if acc_bal.settlebal then result.settlebal = tostring(acc_bal.settlebal) end
  result.bank_acc_id = acc_bal.bank_acc_id
  result.firmuse = assert(acc_bal.firmuse, "Таблица 'acc_bal' не содержит обязательного поля 'firmuse'.")
  
  return result
end

converters["OnFuturesLimitChange"] = function (fut_limit)
  
  local result = {}
  
  result.firmid = fut_limit.firmid
  result.trdaccid = fut_limit.trdaccid
  result.limit_type = assert(fut_limit.limit_type, "Таблица 'fut_limit' не содержит обязательного поля 'limit_type'.")
  if fut_limit.liquidity_coef then result.liquidity_coef = tostring(fut_limit.liquidity_coef) end
  if fut_limit.cbp_prev_limit then result.cbp_prev_limit = tostring(fut_limit.cbp_prev_limit) end
  if fut_limit.cbplimit then result.cbplimit = tostring(fut_limit.cbplimit) end
  if fut_limit.cbplused then result.cbplused = tostring(fut_limit.cbplused) end
  if fut_limit.cbplplanned then result.cbplplanned = tostring(fut_limit.cbplplanned) end
  if fut_limit.varmargin then result.varmargin = tostring(fut_limit.varmargin) end
  if fut_limit.accruedint then result.accruedint = tostring(fut_limit.accruedint) end
  if fut_limit.cbplused_for_orders then result.cbplused_for_orders = tostring(fut_limit.cbplused_for_orders) end
  if fut_limit.cbplused_for_positions then result.cbplused_for_positions = tostring(fut_limit.cbplused_for_positions) end
  if fut_limit.options_premium then result.options_premium = tostring(fut_limit.options_premium) end
  if fut_limit.ts_comission then result.ts_comission = tostring(fut_limit.ts_comission) end
  if fut_limit.kgo then result.kgo = tostring(fut_limit.kgo) end
  result.currcode = fut_limit.currcode
  if fut_limit.real_varmargin then result.real_varmargin = tostring(fut_limit.real_varmargin) end
  
  return result
end

converters["OnFuturesLimitDelete"] = function (lim_del)
  
  local result = {}
  
  result.firmid = lim_del.firmid
  result.limit_type = assert(lim_del.limit_type, "Таблица 'lim_del' не содержит обязательного поля 'limit_type'.")
  
  return result
end

converters["OnFuturesClientHolding"] = function (fut_pos)
  
  local result = {}
  
  result.firmid = fut_pos.firmid
  result.trdaccid = fut_pos.trdaccid
  result.sec_code = fut_pos.sec_code
  result.type = assert(fut_pos.type, "Таблица 'fut_pos' не содержит обязательного поля 'type'.")
  if fut_pos.startbuy then result.startbuy = tostring(fut_pos.startbuy) end
  if fut_pos.startsell then result.startsell = tostring(fut_pos.startsell) end
  if fut_pos.todaybuy then result.todaybuy = tostring(fut_pos.todaybuy) end
  if fut_pos.todaysell then result.todaysell = tostring(fut_pos.todaysell) end
  if fut_pos.totalnet then result.totalnet = tostring(fut_pos.totalnet) end
  result.openbuys = assert(fut_pos.openbuys, "Таблица 'fut_pos' не содержит обязательного поля 'openbuys'.")
  result.opensells = assert(fut_pos.opensells, "Таблица 'fut_pos' не содержит обязательного поля 'opensells'.")
  if fut_pos.cbplused then result.cbplused = tostring(fut_pos.cbplused) end
  if fut_pos.cbplplanned then result.cbplplanned = tostring(fut_pos.cbplplanned) end
  if fut_pos.varmargin then result.varmargin = tostring(fut_pos.varmargin) end
  if fut_pos.avrposnprice then result.avrposnprice = tostring(fut_pos.avrposnprice) end
  if fut_pos.positionvalue then result.positionvalue = tostring(fut_pos.positionvalue) end
  if fut_pos.real_varmargin then result.real_varmargin = tostring(fut_pos.real_varmargin) end
  if fut_pos.total_varmargin then result.total_varmargin = tostring(fut_pos.total_varmargin) end
  result.session_status = assert(fut_pos.session_status, "Таблица 'fut_pos' не содержит обязательного поля 'session_status'.")
  
  return result
end

converters["OnMoneyLimit"] = function (mlimit)
  
  local result = {}
  
  result.currcode = mlimit.currcode
  result.tag = mlimit.tag
  result.firmid = mlimit.firmid
  result.client_code = mlimit.client_code
  if mlimit.openbal then result.openbal = tostring(mlimit.openbal) end
  if mlimit.openlimit then result.openlimit = tostring(mlimit.openlimit) end
  if mlimit.currentbal then result.currentbal = tostring(mlimit.currentbal) end
  if mlimit.currentlimit then result.currentlimit = tostring(mlimit.currentlimit) end
  if mlimit.locked then result.locked = tostring(mlimit.locked) end
  if mlimit.locked_value_coef then result.locked_value_coef = tostring(mlimit.locked_value_coef) end
  if mlimit.locked_margin_value then result.locked_margin_value = tostring(mlimit.locked_margin_value) end
  if mlimit.leverage then result.leverage = tostring(mlimit.leverage) end
  result.limit_kind = assert(mlimit.limit_kind, "Таблица 'mlimit' не содержит обязательного поля 'limit_kind'.")

  return result
end

converters["OnMoneyLimitDelete"] = function (mlimit_del)
  
  local result = {}
  
  result.currcode = mlimit_del.currcode
  result.tag = mlimit_del.tag
  result.client_code = mlimit_del.client_code
  result.firmid = mlimit_del.firmid
  result.limit_kind = assert(mlimit_del.limit_kind, "Таблица 'mlimit_del' не содержит обязательного поля 'limit_kind'.")
  
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
