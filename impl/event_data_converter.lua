local EventDataConverter = {}

local utils = require("utils.utils")

local converters = {}

local no_op = function () end
local identity = function (x) return x end

converters["PublisherOnline"] = no_op

converters["OnClose"] = no_op

converters["OnStop"] = identity

converters["OnFirm"] = function (firm)
  return {
    firmid = utils.Cp1251ToUtf8(assert(firm.firmid, "Таблица 'firm' не содержит обязательного поля 'firmid'.")),
    firm_name = (firm.firm_name and utils.Cp1251ToUtf8(firm.firm_name)), 
    status = firm.status, 
    exchange = (firm.exchange and utils.Cp1251ToUtf8(firm.exchange))
  }
end

converters["OnAllTrade"] = function (alltrade)
  return {
    trade_num = assert(alltrade.trade_num, "Таблица 'alltrade' не содержит обязательного поля 'trade_num'."),
    flags = alltrade.flags,
    price = tostring(assert(alltrade.price, "Таблица 'alltrade' не содержит обязательного поля 'price'.")),
    qty = assert(alltrade.qty, "Таблица 'alltrade' не содержит обязательного поля 'qty'."),
    value = (alltrade.value and tostring(alltrade.value)),
    accruedint = (alltrade.accruedint and tostring(alltrade.accruedint)),
    yield = (alltrade.yield and tostring(alltrade.yield)),
    settlecode = (alltrade.settlecode and utils.Cp1251ToUtf8(alltrade.settlecode)),
    reporate = (alltrade.reporate and tostring(alltrade.reporate)),
    repovalue = (alltrade.repovalue and tostring(alltrade.repovalue)),
    repo2value = (alltrade.repo2value and tostring(alltrade.repo2value)),
    repoterm = (alltrade.repoterm and tostring(alltrade.repoterm)),
    sec_code = (alltrade.sec_code and utils.Cp1251ToUtf8(alltrade.sec_code)),
    class_code = (alltrade.class_code and utils.Cp1251ToUtf8(alltrade.class_code)),
    datetime = assert(alltrade.datetime, "Таблица 'alltrade' не содержит обязательного поля 'datetime'."),
    period = assert(alltrade.period, "Таблица 'alltrade' не содержит обязательного поля 'period'."),
    open_interest = (alltrade.open_interest and tostring(alltrade.open_interest)),
    exchange_code = (alltrade.exchange_code and utils.Cp1251ToUtf8(alltrade.exchange_code)),
    exec_market = (alltrade.exec_market and utils.Cp1251ToUtf8(alltrade.exec_market))
  }
end

converters["OnTrade"] = function (trade)
  
  local result = {}
  
  result.trade_num = assert(trade.trade_num, "Таблица 'trade' не содержит обязательного поля 'trade_num'.")
  result.order_num = assert(trade.order_num, "Таблица 'trade' не содержит обязательного поля 'order_num'.")
  result.brokerref = utils.Cp1251ToUtf8(trade.brokerref)
  result.userid = utils.Cp1251ToUtf8(trade.userid)
  result.firmid = utils.Cp1251ToUtf8(trade.firmid)
  if trade.canceled_uid then result.canceled_uid = tostring(trade.canceled_uid) end
  result.account = utils.Cp1251ToUtf8(trade.account)
  result.price = tostring( assert(trade.price, "Таблица 'trade' не содержит обязательного поля 'price'.") )
  result.qty = assert(trade.qty, "Таблица 'trade' не содержит обязательного поля 'qty'.")
  result.value = tostring( assert(trade.value, "Таблица 'trade' не содержит обязательного поля 'value'.") )
  if trade.accruedint then result.accruedint = tostring(trade.accruedint) end
  if trade.yield then result.yield = tostring(trade.yield) end
  result.settlecode = utils.Cp1251ToUtf8(trade.settlecode)
  result.cpfirmid = utils.Cp1251ToUtf8(trade.cpfirmid)
  result.flags = assert(trade.flags, "Таблица 'trade' не содержит обязательного поля 'flags'.")
  if trade.price2 then result.price2 = tostring(trade.price2) end
  if trade.reporate then result.reporate = tostring(trade.reporate) end
  result.client_code = utils.Cp1251ToUtf8(trade.client_code)
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
  result.settle_currency = utils.Cp1251ToUtf8(trade.settle_currency)
  result.trade_currency = utils.Cp1251ToUtf8(trade.trade_currency)
  result.exchange_code = utils.Cp1251ToUtf8(trade.exchange_code)
  result.station_id = utils.Cp1251ToUtf8(trade.station_id)
  result.sec_code = utils.Cp1251ToUtf8(trade.sec_code)
  result.class_code = utils.Cp1251ToUtf8(trade.class_code)
  result.datetime = assert(trade.datetime, "Таблица 'trade' не содержит обязательного поля 'datetime'.")
  result.bank_acc_id = utils.Cp1251ToUtf8(trade.bank_acc_id)
  if trade.broker_comission then result.broker_comission = tostring(trade.broker_comission) end
  if trade.linked_trade then result.linked_trade = tostring(trade.linked_trade) end
  result.period = assert(trade.period, "Таблица 'trade' не содержит обязательного поля 'period'.")
  if trade.trans_id then result.trans_id = tostring(trade.trans_id) end
  result.kind = assert(trade.kind, "Таблица 'trade' не содержит обязательного поля 'kind'.")
  result.clearing_bank_accid = utils.Cp1251ToUtf8(trade.clearing_bank_accid)
  result.canceled_datetime = trade.canceled_datetime
  result.clearing_firmid = utils.Cp1251ToUtf8(trade.clearing_firmid)
  result.system_ref = utils.Cp1251ToUtf8(trade.system_ref)
  result.uid = trade.uid
  result.lseccode = utils.Cp1251ToUtf8(trade.lseccode)
  if trade.order_revision_number then result.order_revision_number = tostring(trade.order_revision_number) end
  if trade.order_qty then result.order_qty = tostring(trade.order_qty) end
  if trade.order_price then result.order_price = tostring(trade.order_price) end
  result.order_exchange_code = utils.Cp1251ToUtf8(trade.order_exchange_code)
  result.exec_market = utils.Cp1251ToUtf8(trade.exec_market)
  result.liquidity_indicator = assert(trade.liquidity_indicator, "Таблица 'trade' не содержит обязательного поля 'liquidity_indicator'.")
  result.extref = utils.Cp1251ToUtf8(trade.extref)
  if trade.ext_trade_flags then result.ext_trade_flags = tostring(trade.ext_trade_flags) end
  if trade.on_behalf_of_uid then result.on_behalf_of_uid = tostring(trade.on_behalf_of_uid) end
  result.client_qualifier = assert(trade.client_qualifier, "Таблица 'trade' не содержит обязательного поля 'client_qualifier'.")
  if trade.client_short_code then result.client_short_code = tostring(trade.client_short_code) end
  result.investment_decision_maker_qualifier = assert(trade.investment_decision_maker_qualifier, "Таблица 'trade' не содержит обязательного поля 'investment_decision_maker_qualifier'.")
  if trade.investment_decision_maker_short_code then result.investment_decision_maker_short_code = tostring(trade.investment_decision_maker_short_code) end
  result.executing_trader_qualifier = assert(trade.executing_trader_qualifier, "Таблица 'trade' не содержит обязательного поля 'executing_trader_qualifier'.")
  if trade.executing_trader_short_code then result.executing_trader_short_code = tostring(trade.executing_trader_short_code) end
  result.waiver_flag = assert(trade.waiver_flag, "Таблица 'trade' не содержит обязательного поля 'waiver_flag'.")
  if trade.mleg_base_sid then result.mleg_base_sid = tostring(trade.mleg_base_sid) end
  result.side_qualifier = assert(trade.side_qualifier, "Таблица 'trade' не содержит обязательного поля 'side_qualifier'.")
  result.otc_post_trade_indicator = assert(trade.otc_post_trade_indicator, "Таблица 'trade' не содержит обязательного поля 'otc_post_trade_indicator'.")
  result.capacity = assert(trade.capacity, "Таблица 'trade' не содержит обязательного поля 'capacity'.")
  if trade.cross_rate then result.cross_rate = tostring(trade.cross_rate) end
  
  return result
end

converters["OnOrder"] = function (order)
  
  local result = {}
  
  result.order_num = assert(order.order_num, "Таблица 'order' не содержит обязательного поля 'order_num'.")
  result.flags = assert(order.flags, "Таблица 'order' не содержит обязательного поля 'flags'.")
  result.brokerref = (order.brokerref and utils.Cp1251ToUtf8(order.brokerref))
  result.userid = (order.userid and utils.Cp1251ToUtf8(order.userid))
  result.firmid = (order.firmid and utils.Cp1251ToUtf8(order.firmid))
  result.account = (order.account and utils.Cp1251ToUtf8(order.account))
  result.price = tostring( assert(order.price, "Таблица 'order' не содержит обязательного поля 'price'.") )
  result.qty = assert(order.qty, "Таблица 'order' не содержит обязательного поля 'qty'.")
  result.balance = (order.balance and tostring(order.balance))
  result.value = (order.value and tostring(order.value))
  result.accruedint = (order.accruedint and tostring(order.accruedint))
  result.yield = (order.yield and tostring(order.yield))
  result.trans_id = (order.trans_id and tostring(order.trans_id))
  result.client_code = (order.client_code and utils.Cp1251ToUtf8(order.client_code))
  result.price2 = (order.price2 and tostring(order.price2))
  result.settlecode = (order.settlecode and utils.Cp1251ToUtf8(order.settlecode))
  result.uid = (order.uid and tostring(order.uid))
  result.canceled_uid = (order.canceled_uid and tostring(order.canceled_uid))
  result.exchange_code = (order.exchange_code and utils.Cp1251ToUtf8(order.exchange_code))
  result.activation_time = (order.activation_time and tostring(order.activation_time))
  result.linkedorder = (order.linkedorder and tostring(order.linkedorder))
  result.expiry = (order.expiry and tostring(order.expiry))
  result.sec_code = (order.sec_code and utils.Cp1251ToUtf8(order.sec_code))
  result.class_code = (order.class_code and utils.Cp1251ToUtf8(order.class_code))
  result.datetime = assert(order.datetime, "Таблица 'order' не содержит обязательного поля 'datetime'.")
  result.withdraw_datetime = order.withdraw_datetime
  result.bank_acc_id = (order.bank_acc_id and utils.Cp1251ToUtf8(order.bank_acc_id))
  result.value_entry_type = assert(order.value_entry_type, "Таблица 'order' не содержит обязательного поля 'value_entry_type'.")
  result.repoterm = (order.repoterm and tostring(order.repoterm))
  result.repovalue = (order.repovalue and tostring(order.repovalue))
  result.repo2value = (order.repo2value and tostring(order.repo2value))
  result.repo_value_balance = (order.repo_value_balance and tostring(order.repo_value_balance))
  result.start_discount = (order.start_discount and tostring(order.start_discount))
  result.reject_reason = (order.reject_reason and utils.Cp1251ToUtf8(order.reject_reason))
  result.ext_order_flags = (order.ext_order_flags and tostring(order.ext_order_flags))
  result.min_qty = assert(order.min_qty, "Таблица 'order' не содержит обязательного поля 'min_qty'.")
  result.exec_type = assert(order.exec_type, "Таблица 'order' не содержит обязательного поля 'exec_type'.")
  result.side_qualifier = assert(order.side_qualifier, "Таблица 'order' не содержит обязательного поля 'side_qualifier'.")
  result.acnt_type = assert(order.acnt_type, "Таблица 'order' не содержит обязательного поля 'acnt_type'.")
  result.capacity = assert(order.acnt_type, "Таблица 'order' не содержит обязательного поля 'capacity'.")
  result.passive_only_order = assert(order.passive_only_order, "Таблица 'order' не содержит обязательного поля 'passive_only_order'.")
  result.visible = assert(order.visible, "Таблица 'order' не содержит обязательного поля 'visible'.")
  result.awg_price = (order.awg_price and tostring(order.awg_price))
  result.expiry_time = (order.expiry_time and tostring(order.expiry_time))
  result.revision_number = (order.revision_number and tostring(order.revision_number))
  result.price_currency = (order.price_currency and utils.Cp1251ToUtf8(order.price_currency))
  result.ext_order_status = assert(order.ext_order_status, "Таблица 'order' не содержит обязательного поля 'ext_order_status'.")
  result.accepted_uid = (order.accepted_uid and tostring(order.accepted_uid))
  result.filled_value = (order.filled_value and tostring(order.filled_value))
  result.extref = (order.extref and utils.Cp1251ToUtf8(order.extref))
  result.settle_currency = (order.settle_currency and utils.Cp1251ToUtf8(order.settle_currency))
  result.on_behalf_of_uid = (order.on_behalf_of_uid and tostring(order.on_behalf_of_uid))
  result.client_qualifier = assert(order.client_qualifier, "Таблица 'order' не содержит обязательного поля 'client_qualifier'.")
  result.client_short_code = (order.client_short_code and tostring(order.client_short_code))
  result.investment_decision_maker_qualifier = assert(order.investment_decision_maker_qualifier, "Таблица 'order' не содержит обязательного поля 'investment_decision_maker_qualifier'.")
  result.investment_decision_maker_short_code = (order.investment_decision_maker_short_code and tostring(order.investment_decision_maker_short_code))
  result.executing_trader_qualifier = assert(order.executing_trader_qualifier, "Таблица 'order' не содержит обязательного поля 'executing_trader_qualifier'.")
  result.executing_trader_short_code = (order.executing_trader_short_code and tostring(order.executing_trader_short_code))
  
  return result
end

converters["OnAccountBalance"] = function (acc_bal)
  
  local result = {}
  
  result.firmid = utils.Cp1251ToUtf8(acc_bal.firmid)
  result.sec_code = utils.Cp1251ToUtf8(acc_bal.sec_code)
  result.trdaccid = utils.Cp1251ToUtf8(acc_bal.trdaccid)
  result.depaccid = utils.Cp1251ToUtf8(acc_bal.depaccid)
  if acc_bal.openbal then result.openbal = tostring(acc_bal.openbal) end
  if acc_bal.currentpos then result.currentpos = tostring(acc_bal.currentpos) end
  if acc_bal.plannedpossell then result.plannedpossell = tostring(acc_bal.plannedpossell) end
  if acc_bal.plannedposbuy then result.plannedposbuy = tostring(acc_bal.plannedposbuy) end
  if acc_bal.planbal then result.planbal = tostring(acc_bal.planbal) end
  if acc_bal.usqtyb then result.usqtyb = tostring(acc_bal.usqtyb) end
  if acc_bal.usqtys then result.usqtys = tostring(acc_bal.usqtys) end
  if acc_bal.planned then result.planned = tostring(acc_bal.planned) end
  if acc_bal.settlebal then result.settlebal = tostring(acc_bal.settlebal) end
  result.bank_acc_id = utils.Cp1251ToUtf8(acc_bal.bank_acc_id)
  result.firmuse = assert(acc_bal.firmuse, "Таблица 'acc_bal' не содержит обязательного поля 'firmuse'.")
  
  return result
end

converters["OnFuturesLimitChange"] = function (fut_limit)
  
  local result = {}
  
  result.firmid = (fut_limit.firmid and utils.Cp1251ToUtf8(fut_limit.firmid))
  result.trdaccid = (fut_limit.trdaccid and utils.Cp1251ToUtf8(fut_limit.trdaccid))
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
  result.currcode = utils.Cp1251ToUtf8(fut_limit.currcode)
  if fut_limit.real_varmargin then result.real_varmargin = tostring(fut_limit.real_varmargin) end
  
  return result
end

converters["OnFuturesLimitDelete"] = function (lim_del)
  return {
    firmid = (lim_del.firmid and utils.Cp1251ToUtf8(lim_del.firmid)),
    limit_type = assert(lim_del.limit_type, "Таблица 'lim_del' не содержит обязательного поля 'limit_type'.")
  }
end

converters["OnFuturesClientHolding"] = function (fut_pos)
  
  local result = {}
  
  result.firmid = utils.Cp1251ToUtf8(assert(fut_pos.firmid, "Таблица 'fut_pos' не содержит обязательного поля 'firmid'."))
  result.trdaccid = utils.Cp1251ToUtf8(assert(fut_pos.trdaccid, "Таблица 'fut_pos' не содержит обязательного поля 'trdaccid'."))
  result.sec_code = utils.Cp1251ToUtf8(assert(fut_pos.sec_code, "Таблица 'fut_pos' не содержит обязательного поля 'sec_code'."))
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
  
  result.currcode = utils.Cp1251ToUtf8(mlimit.currcode)
  result.tag = utils.Cp1251ToUtf8(mlimit.tag)
  result.firmid = utils.Cp1251ToUtf8(mlimit.firmid)
  result.client_code = utils.Cp1251ToUtf8(mlimit.client_code)
  if mlimit.openbal then result.openbal = tostring(mlimit.openbal) end
  if mlimit.openlimit then result.openlimit = tostring(mlimit.openlimit) end
  if mlimit.currentbal then result.currentbal = tostring(mlimit.currentbal) end
  if mlimit.currentlimit then result.currentlimit = tostring(mlimit.currentlimit) end
  if mlimit.locked then result.locked = tostring(mlimit.locked) end
  if mlimit.locked_value_coef then result.locked_value_coef = tostring(mlimit.locked_value_coef) end
  if mlimit.locked_margin_value then result.locked_margin_value = tostring(mlimit.locked_margin_value) end
  if mlimit.leverage then result.leverage = tostring(mlimit.leverage) end
  result.limit_kind = assert(mlimit.limit_kind, "Таблица 'mlimit' не содержит обязательного поля 'limit_kind'.")
  if mlimit.wa_position_price then result.wa_position_price = tostring(mlimit.wa_position_price) end
  if mlimit.orders_collateral then result.orders_collateral = tostring(mlimit.orders_collateral) end
  if mlimit.positions_collateral then result.positions_collateral = tostring(mlimit.positions_collateral) end

  return result
end

converters["OnMoneyLimitDelete"] = function (mlimit_del)
  return {
    currcode = (mlimit_del.currcode and utils.Cp1251ToUtf8(mlimit_del.currcode)),
    tag = (mlimit_del.tag and utils.Cp1251ToUtf8(mlimit_del.tag)),
    client_code = (mlimit_del.client_code and utils.Cp1251ToUtf8(mlimit_del.client_code)),
    firmid = (mlimit_del.firmid and utils.Cp1251ToUtf8(mlimit_del.firmid)),
    limit_kind = assert(mlimit_del.limit_kind, "Таблица 'mlimit_del' не содержит обязательного поля 'limit_kind'.")
  }
end

converters["OnDepoLimit"] = function (dlimit)
  
  local result = {}
  
  result.sec_code = utils.Cp1251ToUtf8(assert(dlimit.sec_code, "Таблица 'dlimit' не содержит обязательного поля 'sec_code'."))
  result.trdaccid = utils.Cp1251ToUtf8(assert(dlimit.trdaccid, "Таблица 'dlimit' не содержит обязательного поля 'trdaccid'."))
  result.firmid = utils.Cp1251ToUtf8(assert(dlimit.firmid, "Таблица 'dlimit' не содержит обязательного поля 'firmid'."))
  result.client_code = utils.Cp1251ToUtf8(assert(dlimit.client_code, "Таблица 'dlimit' не содержит обязательного поля 'client_code'."))
  result.openbal = assert(dlimit.openbal, "Таблица 'dlimit' не содержит обязательного поля 'openbal'.")
  result.openlimit = assert(dlimit.openlimit, "Таблица 'dlimit' не содержит обязательного поля 'openlimit'.")
  result.currentbal = assert(dlimit.currentbal, "Таблица 'dlimit' не содержит обязательного поля 'currentbal'.")
  result.currentlimit = assert(dlimit.currentlimit, "Таблица 'dlimit' не содержит обязательного поля 'currentlimit'.")
  result.locked_sell = assert(dlimit.locked_sell, "Таблица 'dlimit' не содержит обязательного поля 'locked_sell'.")
  result.locked_buy = assert(dlimit.locked_buy, "Таблица 'dlimit' не содержит обязательного поля 'locked_buy'.")
  result.locked_buy_value = tostring( assert(dlimit.locked_buy_value, "Таблица 'dlimit' не содержит обязательного поля 'locked_buy_value'.") )
  result.locked_sell_value = tostring( assert(dlimit.locked_sell_value, "Таблица 'dlimit' не содержит обязательного поля 'locked_sell_value'.") )
  result.wa_position_price = tostring( assert(dlimit.wa_position_price, "Таблица 'dlimit' не содержит обязательного поля 'wa_position_price'.") )
  result.limit_kind = assert(dlimit.limit_kind, "Таблица 'dlimit' не содержит обязательного поля 'limit_kind'.")
  
  return result
end

converters["OnDepoLimitDelete"] = function (dlimit_del)
  return {
    sec_code = utils.Cp1251ToUtf8(assert(dlimit.sec_code, "Таблица 'dlimit_del' не содержит обязательного поля 'sec_code'.")),
    trdaccid = utils.Cp1251ToUtf8(assert(dlimit.trdaccid, "Таблица 'dlimit_del' не содержит обязательного поля 'trdaccid'.")),
    firmid = utils.Cp1251ToUtf8(assert(dlimit.firmid, "Таблица 'dlimit_del' не содержит обязательного поля 'firmid'.")),
    client_code = utils.Cp1251ToUtf8(assert(dlimit.client_code, "Таблица 'dlimit_del' не содержит обязательного поля 'client_code'.")),
    limit_kind = assert(dlimit.limit_kind, "Таблица 'dlimit_del' не содержит обязательного поля 'limit_kind'.")
  }
end

converters["OnAccountPosition"] = function (acc_pos)
  
  local result = {}
  
  result.firmid = utils.Cp1251ToUtf8(acc_pos.firmid)
  result.currcode = utils.Cp1251ToUtf8(acc_pos.currcode)
  result.tag = utils.Cp1251ToUtf8(acc_pos.tag)
  result.description = utils.Cp1251ToUtf8(acc_pos.description)
  if acc_pos.openbal then result.openbal = tostring(acc_pos.openbal) end
  if acc_pos.currentpos then result.currentpos = tostring(acc_pos.currentpos) end
  if acc_pos.plannedpos then result.plannedpos = tostring(acc_pos.plannedpos) end
  if acc_pos.limit1 then result.limit1 = tostring(acc_pos.limit1) end
  if acc_pos.limit2 then result.limit2 = tostring(acc_pos.limit2) end
  if acc_pos.orderbuy then result.orderbuy = tostring(acc_pos.orderbuy) end
  if acc_pos.ordersell then result.ordersell = tostring(acc_pos.ordersell) end
  if acc_pos.netto then result.netto = tostring(acc_pos.netto) end
  if acc_pos.plannedbal then result.plannedbal = tostring(acc_pos.plannedbal) end
  if acc_pos.debit then result.debit = tostring(acc_pos.debit) end
  if acc_pos.credit then result.credit = tostring(acc_pos.credit) end
  result.bank_acc_id = utils.Cp1251ToUtf8(acc_pos.bank_acc_id)
  if acc_pos.margincall then result.margincall = tostring(acc_pos.margincall) end
  if acc_pos.settlebal then result.settlebal = tostring(acc_pos.settlebal) end
  
  return result
end

converters["OnNegDeal"] = function (neg_deal)
  
  local result = {}
  
  result.neg_deal_num = assert(neg_deal.neg_deal_num, "Таблица 'neg_deal' не содержит обязательного поля 'neg_deal_num'.")
  if neg_deal.neg_deal_time then result.neg_deal_time = tostring(neg_deal.neg_deal_time) end
  result.flags = assert(neg_deal.flags, "Таблица 'neg_deal' не содержит обязательного поля 'flags'.")
  result.brokerref = utils.Cp1251ToUtf8(neg_deal.brokerref)
  result.userid = utils.Cp1251ToUtf8(neg_deal.userid)
  result.firmid = utils.Cp1251ToUtf8(neg_deal.firmid)
  result.cpuserid = utils.Cp1251ToUtf8(neg_deal.cpuserid)
  result.cpfirmid = utils.Cp1251ToUtf8(neg_deal.cpfirmid)
  result.account = utils.Cp1251ToUtf8(neg_deal.account)
  result.price = tostring( assert(neg_deal.price, "Таблица 'neg_deal' не содержит обязательного поля 'price'.") )
  result.qty = assert(neg_deal.qty, "Таблица 'neg_deal' не содержит обязательного поля 'qty'.")
  result.matchref = utils.Cp1251ToUtf8(neg_deal.matchref)
  result.settlecode = utils.Cp1251ToUtf8(neg_deal.settlecode)
  if neg_deal.yield then result.yield = tostring(neg_deal.yield) end
  if neg_deal.accruedint then result.accruedint = tostring(neg_deal.accruedint) end
  if neg_deal.value then result.value = tostring(neg_deal.value) end
  if neg_deal.price2 then result.price2 = tostring(neg_deal.price2) end
  if neg_deal.reporate then result.reporate = tostring(neg_deal.reporate) end
  if neg_deal.refundrate then result.refundrate = tostring(neg_deal.refundrate) end
  if neg_deal.trans_id then result.trans_id = tostring(neg_deal.trans_id) end
  result.client_code = utils.Cp1251ToUtf8(neg_deal.client_code)
  result.repoentry = assert(neg_deal.repoentry, "Таблица 'neg_deal' не содержит обязательного поля 'repoentry'.")
  if neg_deal.repovalue then result.repovalue = tostring(neg_deal.repovalue) end
  if neg_deal.repo2value then result.repo2value = tostring(neg_deal.repo2value) end
  if neg_deal.repoterm then result.repoterm = tostring(neg_deal.repoterm) end
  if neg_deal.start_discount then result.start_discount = tostring(neg_deal.start_discount) end
  if neg_deal.lower_discount then result.lower_discount = tostring(neg_deal.lower_discount) end
  if neg_deal.upper_discount then result.upper_discount = tostring(neg_deal.upper_discount) end
  if neg_deal.block_securities then result.block_securities = tostring(neg_deal.block_securities) end
  if neg_deal.uid then result.uid = tostring(neg_deal.uid) end
  if neg_deal.withdraw_time then result.withdraw_time = tostring(neg_deal.withdraw_time) end
  if neg_deal.neg_deal_date then result.neg_deal_date = tostring(neg_deal.neg_deal_date) end
  if neg_deal.balance then result.balance = tostring(neg_deal.balance) end
  if neg_deal.origin_repovalue then result.origin_repovalue = tostring(neg_deal.origin_repovalue) end
  if neg_deal.origin_qty then result.origin_qty = tostring(neg_deal.origin_qty) end
  if neg_deal.origin_discount then result.origin_discount = tostring(neg_deal.origin_discount) end
  if neg_deal.neg_deal_activation_date then result.neg_deal_activation_date = tostring(neg_deal.neg_deal_activation_date) end
  if neg_deal.neg_deal_activation_time then result.neg_deal_activation_time = tostring(neg_deal.neg_deal_activation_time) end
  if neg_deal.quoteno then result.quoteno = tostring(neg_deal.quoteno) end
  result.settle_currency = utils.Cp1251ToUtf8(neg_deal.settle_currency)
  result.sec_code = utils.Cp1251ToUtf8(neg_deal.sec_code)
  result.class_code = utils.Cp1251ToUtf8(neg_deal.class_code)
  result.bank_acc_id = utils.Cp1251ToUtf8(neg_deal.bank_acc_id)
  if neg_deal.withdraw_date then result.withdraw_date = tostring(neg_deal.withdraw_date) end
  if neg_deal.linkedorder then result.linkedorder = tostring(neg_deal.linkedorder) end
  result.activation_date_time = neg_deal.activation_date_time
  result.withdraw_date_time = neg_deal.withdraw_date_time
  result.date_time = assert(neg_deal.date_time, "Таблица 'neg_deal' не содержит обязательного поля 'date_time'.")
  result.lseccode = utils.Cp1251ToUtf8(neg_deal.lseccode)
  if neg_deal.canceled_uid then result.canceled_uid = tostring(neg_deal.canceled_uid) end
  result.system_ref = utils.Cp1251ToUtf8(neg_deal.system_ref)
  result.price_currency = utils.Cp1251ToUtf8(neg_deal.price_currency)
  result.order_exchange_code = utils.Cp1251ToUtf8(neg_deal.order_exchange_code)
  result.extref = utils.Cp1251ToUtf8(neg_deal.extref)
  if neg_deal.period then result.period = tostring(neg_deal.period) end
  result.client_qualifier = assert(neg_deal.client_qualifier, "Таблица 'neg_deal' не содержит обязательного поля 'client_qualifier'.")
  if neg_deal.client_short_code then result.client_short_code = tostring(neg_deal.client_short_code) end
  result.investment_decision_maker_qualifier = assert(neg_deal.investment_decision_maker_qualifier, "Таблица 'neg_deal' не содержит обязательного поля 'investment_decision_maker_qualifier'.")
  if neg_deal.investment_decision_maker_short_code then result.investment_decision_maker_short_code = tostring(neg_deal.investment_decision_maker_short_code) end
  result.executing_trader_qualifier = assert(neg_deal.executing_trader_qualifier, "Таблица 'neg_deal' не содержит обязательного поля 'executing_trader_qualifier'.")
  if neg_deal.executing_trader_short_code then result.executing_trader_short_code = tostring(neg_deal.executing_trader_short_code) end
  
  return result
end

converters["OnNegTrade"] = function (neg_trade)
  
  local result = {}
  
  result.trade_num = assert(neg_trade.trade_num, "Таблица 'neg_trade' не содержит обязательного поля 'trade_num'.")
  if neg_trade.trade_date then result.trade_date = tostring(neg_trade.trade_date) end
  if neg_trade.settle_date then result.settle_date = tostring(neg_trade.settle_date) end
  result.flags = assert(neg_trade.flags, "Таблица 'neg_trade' не содержит обязательного поля 'flags'.")
  result.brokerref = utils.Cp1251ToUtf8(neg_trade.brokerref)
  result.firmid = utils.Cp1251ToUtf8(neg_trade.firmid)
  result.account = utils.Cp1251ToUtf8(neg_trade.account)
  result.cpfirmid = utils.Cp1251ToUtf8(neg_trade.cpfirmid)
  result.cpaccount = utils.Cp1251ToUtf8(neg_trade.cpaccount)
  result.price = tostring( assert(neg_trade.price, "Таблица 'neg_trade' не содержит обязательного поля 'price'.") )
  result.qty = assert(neg_trade.qty, "Таблица 'neg_trade' не содержит обязательного поля 'qty'.")
  if neg_trade.value then result.value = tostring(neg_trade.value) end
  result.settlecode = utils.Cp1251ToUtf8(neg_trade.settlecode)
  if neg_trade.report_num then result.report_num = tostring(neg_trade.report_num) end
  if neg_trade.cpreport_num then result.cpreport_num = tostring(neg_trade.cpreport_num) end
  if neg_trade.accruedint then result.accruedint = tostring(neg_trade.accruedint) end
  if neg_trade.repotradeno then result.repotradeno = tostring(neg_trade.repotradeno) end
  if neg_trade.price1 then result.price1 = tostring(neg_trade.price1) end
  if neg_trade.reporate then result.reporate = tostring(neg_trade.reporate) end
  if neg_trade.price2 then result.price2 = tostring(neg_trade.price2) end
  result.client_code = utils.Cp1251ToUtf8(neg_trade.client_code)
  if neg_trade.ts_comission then result.ts_comission = tostring(neg_trade.ts_comission) end
  if neg_trade.balance then result.balance = tostring(neg_trade.balance) end
  if neg_trade.settle_time then result.settle_time = tostring(neg_trade.settle_time) end
  if neg_trade.amount then result.amount = tostring(neg_trade.amount) end
  if neg_trade.repovalue then result.repovalue = tostring(neg_trade.repovalue) end
  if neg_trade.repoterm then result.repoterm = tostring(neg_trade.repoterm) end
  if neg_trade.repo2value then result.repo2value = tostring(neg_trade.repo2value) end
  if neg_trade.return_value then result.return_value = tostring(neg_trade.return_value) end
  if neg_trade.discount then result.discount = tostring(neg_trade.discount) end
  if neg_trade.lower_discount then result.lower_discount = tostring(neg_trade.lower_discount) end
  if neg_trade.upper_discount then result.upper_discount = tostring(neg_trade.upper_discount) end
  if neg_trade.block_securities then result.block_securities = tostring(neg_trade.block_securities) end
  if neg_trade.urgency_flag then result.urgency_flag = tostring(neg_trade.urgency_flag) end
  result.type = assert(neg_trade.type, "Таблица 'neg_trade' не содержит обязательного поля 'type'.")
  result.operation_type = assert(neg_trade.operation_type, "Таблица 'neg_trade' не содержит обязательного поля 'operation_type'.")
  if neg_trade.expected_discount then result.expected_discount = tostring(neg_trade.expected_discount) end
  if neg_trade.expected_quantity then result.expected_quantity = tostring(neg_trade.expected_quantity) end
  if neg_trade.expected_repovalue then result.expected_repovalue = tostring(neg_trade.expected_repovalue) end
  if neg_trade.expected_repo2value then result.expected_repo2value = tostring(neg_trade.expected_repo2value) end
  if neg_trade.expected_return_value then result.expected_return_value = tostring(neg_trade.expected_return_value) end
  if neg_trade.order_num then result.order_num = tostring(neg_trade.order_num) end
  if neg_trade.report_trade_date then result.report_trade_date = tostring(neg_trade.report_trade_date) end
  result.settled = assert(neg_trade.settled, "Таблица 'neg_trade' не содержит обязательного поля 'settled'.")
  result.clearing_type = assert(neg_trade.clearing_type, "Таблица 'neg_trade' не содержит обязательного поля 'clearing_type'.")
  if neg_trade.report_comission then result.report_comission = tostring(neg_trade.report_comission) end
  if neg_trade.coupon_payment then result.coupon_payment = tostring(neg_trade.coupon_payment) end
  if neg_trade.principal_payment then result.principal_payment = tostring(neg_trade.principal_payment) end
  if neg_trade.principal_payment_date then result.principal_payment_date = tostring(neg_trade.principal_payment_date) end
  if neg_trade.nextdaysettle then result.nextdaysettle = tostring(neg_trade.nextdaysettle) end
  result.settle_currency = utils.Cp1251ToUtf8(neg_trade.settle_currency)
  result.sec_code = utils.Cp1251ToUtf8(assert(neg_trade.sec_code, "Таблица 'neg_trade' не содержит обязательного поля 'sec_code'."))
  result.class_code = utils.Cp1251ToUtf8(assert(neg_trade.class_code, "Таблица 'neg_trade' не содержит обязательного поля 'class_code'."))
  if neg_trade.compval then result.compval = tostring(neg_trade.compval) end
  if neg_trade.parenttradeno then result.parenttradeno = tostring(neg_trade.parenttradeno) end
  result.bankid = utils.Cp1251ToUtf8(neg_trade.bankid)
  result.bankaccid = utils.Cp1251ToUtf8(neg_trade.bankaccid)
  if neg_trade.precisebalance then result.precisebalance = tostring(neg_trade.precisebalance) end
  if neg_trade.confirmtime then result.confirmtime = tostring(neg_trade.confirmtime) end
  result.ex_flags = assert(neg_trade.ex_flags, "Таблица 'neg_trade' не содержит обязательного поля 'ex_flags'.")
  if neg_trade.confirmreport then result.confirmreport = tostring(neg_trade.confirmreport) end
  result.extref = utils.Cp1251ToUtf8(neg_trade.extref)
  
  return result
end

converters["OnStopOrder"] = function (stop_order)
  
  local result = {}
  
  result.order_num = assert(stop_order.order_num, "Таблица 'stop_order' не содержит обязательного поля 'order_num'.")
  result.ordertime = (stop_order.ordertime and tostring(stop_order.ordertime))
  result.flags = assert(stop_order.flags, "Таблица 'stop_order' не содержит обязательного поля 'flags'.")
  result.brokerref = (stop_order.brokerref and utils.Cp1251ToUtf8(stop_order.brokerref))
  result.firmid = (stop_order.firmid and utils.Cp1251ToUtf8(stop_order.firmid))
  result.account = (stop_order.account and utils.Cp1251ToUtf8(stop_order.account))
  result.condition = assert(stop_order.condition, "Таблица 'stop_order' не содержит обязательного поля 'condition'.")
  result.condition_price = tostring( assert(stop_order.condition_price, "Таблица 'stop_order' не содержит обязательного поля 'condition_price'.") )
  result.price = tostring( assert(stop_order.price, "Таблица 'stop_order' не содержит обязательного поля 'price'.") )
  result.qty = assert(stop_order.qty, "Таблица 'stop_order' не содержит обязательного поля 'qty'.")
  result.linkedorder = (stop_order.linkedorder and tostring(stop_order.linkedorder))
  result.expiry = (stop_order.expiry and tostring(stop_order.expiry))
  result.trans_id = (stop_order.trans_id and tostring(stop_order.trans_id))
  result.client_code = (stop_order.client_code and utils.Cp1251ToUtf8(stop_order.client_code))
  result.co_order_num = (stop_order.co_order_num and tostring(stop_order.co_order_num))
  result.co_order_price = (stop_order.co_order_price and tostring(stop_order.co_order_price))
  result.stop_order_type = assert(stop_order.stop_order_type, "Таблица 'stop_order' не содержит обязательного поля 'stop_order_type'.")
  result.orderdate = (stop_order.orderdate and tostring(stop_order.orderdate))
  result.alltrade_num = (stop_order.alltrade_num and tostring(stop_order.alltrade_num))
  result.stopflags = assert(stop_order.stopflags, "Таблица 'stop_order' не содержит обязательного поля 'stopflags'.")
  result.offset = (stop_order.offset and tostring(stop_order.offset))
  result.spread = (stop_order.spread and tostring(stop_order.spread))
  result.balance = (stop_order.balance and tostring(stop_order.balance))
  result.uid = (stop_order.uid and tostring(stop_order.uid))
  result.filled_qty = assert(stop_order.filled_qty, "Таблица 'stop_order' не содержит обязательного поля 'filled_qty'.")
  result.withdraw_time = (stop_order.withdraw_time and tostring(stop_order.withdraw_time))
  result.condition_price2 = (stop_order.condition_price2 and tostring(stop_order.condition_price2))
  result.active_from_time = (stop_order.active_from_time and tostring(stop_order.active_from_time))
  result.active_to_time = (stop_order.active_to_time and tostring(stop_order.active_to_time))
  result.sec_code = (stop_order.sec_code and utils.Cp1251ToUtf8(stop_order.sec_code))
  result.class_code = (stop_order.class_code and utils.Cp1251ToUtf8(stop_order.class_code))
  result.condition_sec_code = (stop_order.condition_sec_code and utils.Cp1251ToUtf8(stop_order.condition_sec_code))
  result.condition_class_code = (stop_order.condition_class_code and utils.Cp1251ToUtf8(stop_order.condition_class_code))
  result.canceled_uid = (stop_order.canceled_uid and tostring(stop_order.canceled_uid))
  result.order_date_time = assert(stop_order.order_date_time, "Таблица 'stop_order' не содержит обязательного поля 'order_date_time'.")
  result.withdraw_datetime = stop_order.withdraw_datetime
  result.activation_date_time = stop_order.activation_date_time
  
  return result
end

converters["OnTransReply"] = function (trans_reply)
  
  local result = {}
  
  result.trans_id = assert(trans_reply.trans_id, "Таблица 'trans_reply' не содержит обязательного поля 'trans_id'.")
  result.status = assert(trans_reply.status, "Таблица 'trans_reply' не содержит обязательного поля 'status'.")
  result.result_msg = (trans_reply.result_msg and utils.Cp1251ToUtf8(trans_reply.result_msg))
  result.date_time = assert(trans_reply.date_time, "Таблица 'trans_reply' не содержит обязательного поля 'date_time'.")
  result.uid = tostring( assert(trans_reply.uid, "Таблица 'trans_reply' не содержит обязательного поля 'uid'.") )
  result.flags = assert(trans_reply.flags, "Таблица 'trans_reply' не содержит обязательного поля 'flags'.")
  result.server_trans_id = (trans_reply.server_trans_id and tostring(trans_reply.server_trans_id))
  result.order_num = (trans_reply.order_num and tostring(trans_reply.order_num))
  result.price = (trans_reply.price and tostring(trans_reply.price))
  result.quantity = (trans_reply.quantity and tostring(trans_reply.quantity))
  result.balance = (trans_reply.balance and tostring(trans_reply.balance))
  result.firm_id = (trans_reply.firm_id and utils.Cp1251ToUtf8(trans_reply.firm_id))
  result.account = (trans_reply.account and utils.Cp1251ToUtf8(trans_reply.account))
  result.client_code = (trans_reply.client_code and utils.Cp1251ToUtf8(trans_reply.client_code))
  result.brokerref = (trans_reply.brokerref and utils.Cp1251ToUtf8(trans_reply.brokerref))
  result.class_code = (trans_reply.class_code and utils.Cp1251ToUtf8(trans_reply.class_code))
  result.sec_code = (trans_reply.sec_code and utils.Cp1251ToUtf8(trans_reply.sec_code))
  result.exchange_code = (trans_reply.exchange_code and utils.Cp1251ToUtf8(trans_reply.exchange_code))
  result.error_code = assert(trans_reply.error_code, "Таблица 'trans_reply' не содержит обязательного поля 'error_code'.")
  result.error_source = assert(trans_reply.error_source, "Таблица 'trans_reply' не содержит обязательного поля 'error_source'.")
  result.first_ordernum = (trans_reply.first_ordernum and tostring(trans_reply.first_ordernum))
  result.gate_reply_time = assert(trans_reply.gate_reply_time, "Таблица 'trans_reply' не содержит обязательного поля 'gate_reply_time'.")
  
  return result
end

converters["OnQuote"] = function (quote)
  
  quote.sec_code = utils.Cp1251ToUtf8(assert(quote.sec_code, "Таблица 'quote' не содержит обязательного поля 'sec_code'."))
  quote.class_code = utils.Cp1251ToUtf8(assert(quote.class_code, "Таблица 'quote' не содержит обязательного поля 'class_code'."))
  
  return quote
end

converters["OnParam"] = function (param)
  
  param.sec_code = utils.Cp1251ToUtf8(assert(param.sec_code, "Таблица 'param' не содержит обязательного поля 'sec_code'."))
  param.class_code = utils.Cp1251ToUtf8(assert(param.class_code, "Таблица 'param' не содержит обязательного поля 'class_code'."))
  
  return param
end

converters["OnDisconnected"] = no_op

converters["OnConnected"] = identity

converters["OnCleanUp"] = no_op

converters["OnDataSourceUpdate"] = identity

function EventDataConverter.convert (event_type, event_data)
  return converters[event_type](event_data)
end

return EventDataConverter
