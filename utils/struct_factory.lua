package.path = "../?.lua;" .. package.path

local qlua_structs = require("messages.qlua_structures_pb")
local qlua_events = require("messages.qlua_events_pb")
local utils = require("utils.utils")

local assert = assert
local tostring = assert(tostring)
local error = assert(error)

local value_to_string_or_empty_string = assert(utils.value_to_string_or_empty_string)
local value_or_empty_string = assert(utils.value_or_empty_string)

local StructFactory = {}

function StructFactory.create_Firm(firm, existing_struct)

  if firm == nil then error("No firm provided.", 2) end

  local result = (existing_struct == nil and qlua_structs.Firm() or existing_struct)
  
  result.firmid = utils.Cp2151ToUtf8(firm.firmid)
  result.firm_name = value_or_empty_string(firm.firm_name)
  result.status = firm.status
  result.exchange = value_or_empty_string(firm.exchange)
  
  return result
end

function StructFactory.create_AllTrade(alltrade, existing_struct)
  
  if alltrade == nil then error("No alltrade provided.", 2) end
  
  local result = (existing_struct == nil and qlua_structs.AllTrade() or existing_struct)
  
  result.trade_num = alltrade.trade_num
  result.flags = alltrade.flags
  result.price = tostring( assert(alltrade.price, "The given 'alltrade' table has no 'price' field.") )
  result.qty = alltrade.qty
  result.value = value_to_string_or_empty_string(alltrade.value)
  result.accruedint = value_to_string_or_empty_string(alltrade.accruedint)
  result.yield = value_to_string_or_empty_string(alltrade.yield)
  result.settlecode = value_or_empty_string(alltrade.settlecode)
  result.reporate = value_to_string_or_empty_string(alltrade.reporate)
  result.repovalue = value_to_string_or_empty_string(alltrade.repovalue)
  result.repo2value = value_to_string_or_empty_string(alltrade.repo2value)
  result.repoterm = value_to_string_or_empty_string(alltrade.repoterm)
  result.sec_code = alltrade.sec_code
  result.class_code = alltrade.class_code
  utils.copy_datetime(result.datetime, assert(alltrade.datetime, "The given 'alltrade' table has no 'datetime' field."))
  result.period = alltrade.period
  result.open_interest = value_to_string_or_empty_string(alltrade.open_interest)
  result.exchange_code = value_or_empty_string(alltrade.exchange_code)
  
  return result
end

function StructFactory.create_Trade(trade, existing_struct)
  
  if trade == nil then error("No trade provided.", 2) end
  
  local result = (existing_struct == nil and qlua_structs.Trade() or existing_struct)
  
  result.trade_num = assert(trade.trade_num, "The given 'trade' table has no 'trade_num' field.")
  result.order_num = assert(trade.order_num, "The given 'trade' table has no 'order_num' field.")
  result.brokerref = value_or_empty_string(trade.brokerref)
  result.userid = value_or_empty_string(trade.userid)
  result.firmid = value_or_empty_string(trade.firmid)
  result.canceled_uid = value_to_string_or_empty_string(trade.canceled_uid)
  result.account = value_or_empty_string(trade.account)
  result.price = tostring( assert(trade.price, "The given 'trade' table has no 'price' field.") )
  result.qty = assert(trade.qty, "The given 'trade' table has no 'qty' field.")
  result.value = tostring( assert(trade.value, "The given 'trade' table has no 'value' field.") )
  result.accruedint = value_to_string_or_empty_string(trade.accruedint)
  result.yield = value_to_string_or_empty_string(trade.yield)
  result.settlecode = value_or_empty_string(trade.settlecode)
  result.cpfirmid = value_or_empty_string(trade.cpfirmid)
  result.flags = assert(trade.flags, "The given 'trade' table has no 'flags' field.")
  result.price2 = value_to_string_or_empty_string(trade.price2)
  result.reporate = value_to_string_or_empty_string(trade.reporate)
  result.client_code = value_or_empty_string(trade.client_code)
  result.accrued2 = value_to_string_or_empty_string(trade.accrued2)
  result.repoterm = value_to_string_or_empty_string(trade.repoterm)
  result.repovalue = value_to_string_or_empty_string(trade.repovalue)
  result.repo2value = value_to_string_or_empty_string(trade.repo2value)
  result.start_discount = value_to_string_or_empty_string(trade.start_discount)
  result.lower_discount = value_to_string_or_empty_string(trade.lower_discount)
  result.upper_discount = value_to_string_or_empty_string(trade.upper_discount)
  result.block_securities = value_to_string_or_empty_string(trade.block_securities)
  result.clearing_comission = value_to_string_or_empty_string(trade.clearing_comission)
  result.exchange_comission = value_to_string_or_empty_string(trade.exchange_comission)
  result.tech_center_comission = value_to_string_or_empty_string(trade.tech_center_comission)
  result.settle_date = value_to_string_or_empty_string(trade.settle_date)
  result.settle_currency = value_or_empty_string(trade.settle_currency)
  result.trade_currency = value_or_empty_string(trade.trade_currency)
  result.exchange_code = value_or_empty_string(trade.exchange_code)
  result.station_id = value_or_empty_string(trade.station_id)
  result.sec_code = assert(trade.sec_code, "The given 'trade' table has no 'sec_code' field.")
  result.class_code = assert(trade.class_code, "The given 'trade' table has no 'class_code' field.")
  utils.copy_datetime(result.datetime, assert(trade.datetime, "The given 'trade' table has no 'datetime' field."))
  result.bank_acc_id = value_or_empty_string(trade.bank_acc_id)
  result.broker_comission = value_to_string_or_empty_string(trade.broker_comission)
  result.linked_trade = value_to_string_or_empty_string(trade.linked_trade)
  result.period = assert(trade.period, "The given 'trade' table has no 'period' field.")
  result.trans_id = value_to_string_or_empty_string(trade.trans_id)
  result.kind = assert(trade.kind, "The given 'trade' table has no 'kind' field.")
  result.clearing_bank_accid = value_or_empty_string(trade.clearing_bank_accid)
  if trade.canceled_datetime then utils.copy_datetime(result.canceled_datetime, trade.canceled_datetime) end
  result.clearing_firmid = value_or_empty_string(trade.clearing_firmid)
  result.system_ref = value_or_empty_string(trade.system_ref)
  result.uid = value_to_string_or_empty_string(trade.uid)
  
  return result
end

function StructFactory.create_Order(order, existing_struct)
  
  if order == nil then error("No order provided.", 2) end
  
  local result = (existing_struct == nil and qlua_structs.Order() or existing_struct)
  
  result.order_num = assert(order.order_num, "The given 'order' table has no 'order_num' field.")
  result.flags = assert(order.flags, "The given 'order' table has no 'flags' field.")
  result.brokerref = value_or_empty_string(order.brokerref)
  result.userid = value_or_empty_string(order.userid)
  result.firmid = value_or_empty_string(order.firmid)
  result.account = value_or_empty_string(order.account)
  result.price = tostring( assert(order.price, "The given 'order' table has no 'price' field.") )
  result.qty = assert(order.qty, "The given 'order' table has no 'qty' field.")
  result.balance = value_to_string_or_empty_string(order.balance)
  result.value = tostring( assert(order.value, "The given 'order' table has no 'value' field.") )
  result.accruedint = value_to_string_or_empty_string(order.accruedint)
  result.yield = value_to_string_or_empty_string(order.yield)
  result.trans_id = value_to_string_or_empty_string(order.trans_id)
  result.client_code = value_or_empty_string(order.client_code)
  result.price2 = value_to_string_or_empty_string(order.price2)
  result.settlecode = value_or_empty_string(order.settlecode)
  result.uid = value_to_string_or_empty_string(order.uid)
  result.canceled_uid = value_to_string_or_empty_string(order.canceled_uid)
  result.exchange_code = value_or_empty_string(order.exchange_code)
  result.activation_time = value_to_string_or_empty_string(order.activation_time)
  result.linkedorder = value_to_string_or_empty_string(order.linkedorder)
  result.expiry = value_to_string_or_empty_string(order.expiry)
  result.sec_code = assert(order.sec_code, "The given 'order' table has no 'sec_code' field.")
  result.class_code = assert(order.class_code, "The given 'order' table has no 'class_code' field.")
  utils.copy_datetime(result.datetime, assert(order.datetime, "The given 'order' table has no 'datetime' field."))
  if order.withdraw_datetime then utils.copy_datetime(result.withdraw_datetime, order.withdraw_datetime) end
  result.bank_acc_id = value_or_empty_string(order.bank_acc_id)
  result.value_entry_type = assert(order.value_entry_type, "The given 'order' table has no 'value_entry_type' field.")
  result.repoterm = value_to_string_or_empty_string(order.repoterm)
  result.repovalue = value_to_string_or_empty_string(order.repovalue)
  result.repo2value = value_to_string_or_empty_string(order.repo2value)
  result.repo_value_balance = value_to_string_or_empty_string(order.repo_value_balance)
  result.start_discount = value_to_string_or_empty_string(order.start_discount)
  result.reject_reason = value_or_empty_string(order.reject_reason)
  result.ext_order_flags = value_to_string_or_empty_string(order.ext_order_flags)
  result.min_qty = assert(order.min_qty, "The given 'order' table has no 'min_qty' field.")
  result.exec_type = assert(order.exec_type, "The given 'order' table has no 'exec_type' field.")
  result.side_qualifier = assert(order.side_qualifier, "The given 'order' table has no 'side_qualifier' field.")
  result.acnt_type = assert(order.acnt_type, "The given 'order' table has no 'acnt_type' field.")
  result.capacity = assert(order.capacity, "The given 'order' table has no 'capacity' field.")
  result.passive_only_order = assert(order.passive_only_order, "The given 'order' table has no 'passive_only_order' field.")
  result.visible = assert(order.visible, "The given 'order' table has no 'visible' field.")
  
  return result
end

function StructFactory.create_AccountBalance(acc_bal, existing_struct)
  
  if acc_bal == nil then error("No acc_bal table provided.", 2) end
  
  local result = (existing_struct == nil and qlua_structs.AccountBalance() or existing_struct)
  
  result.firmid = utils.Cp2151ToUtf8( assert(acc_bal.firmid, "The given 'acc_bal' table has no 'firmid' field.") )
  result.sec_code = assert(acc_bal.sec_code, "The given 'acc_bal' table has no 'sec_code' field.")
  result.trdaccid = utils.Cp2151ToUtf8( assert(acc_bal.trdaccid, "The given 'acc_bal' table has no 'trdaccid' field.") )
  result.depaccid = utils.Cp2151ToUtf8( assert(acc_bal.depaccid, "The given 'acc_bal' table has no 'depaccid' field.") )
  result.openbal = tostring( assert(acc_bal.openbal, "The given 'acc_bal' table has no 'openbal' field.") )
  result.currentpos = tostring( assert(acc_bal.currentpos, "The given 'acc_bal' table has no 'currentpos' field.") )
  result.plannedpossell = value_to_string_or_empty_string(acc_bal.plannedpossell)
  result.plannedposbuy = value_to_string_or_empty_string(acc_bal.plannedposbuy)
  result.planbal = value_to_string_or_empty_string(acc_bal.planbal)
  result.usqtyb = value_to_string_or_empty_string(acc_bal.usqtyb)
  result.usqtys = value_to_string_or_empty_string(acc_bal.usqtys)
  result.planned = value_to_string_or_empty_string(acc_bal.planned)
  result.settlebal = value_to_string_or_empty_string(acc_bal.settlebal)
  result.bank_acc_id = value_or_empty_string(acc_bal.bank_acc_id)
  result.firmuse = assert(acc_bal.firmuse, "The given 'acc_bal' table has no 'firmuse' field.")
  
  return result
end

function StructFactory.create_FuturesLimit(fut_limit, existing_struct)
  
  if fut_limit == nil then error("No fut_limit table provided.", 2) end
  
  local result = (existing_struct == nil and qlua_structs.FuturesLimit() or existing_struct)
  
  result.firmid = utils.Cp2151ToUtf8( assert(fut_limit.firmid, "The given 'fut_limit' table has no 'firmid' field.") )
  result.trdaccid = utils.Cp2151ToUtf8( assert(fut_limit.trdaccid, "The given 'fut_limit' table has no 'trdaccid' field.") )
  result.limit_type = assert(fut_limit.limit_type, "The given 'fut_limit' table has no 'limit_type' field.")
  result.liquidity_coef = value_to_string_or_empty_string(fut_limit.liquidity_coef)
  result.cbp_prev_limit = value_to_string_or_empty_string(fut_limit.cbp_prev_limit)
  result.cbplimit = value_to_string_or_empty_string(fut_limit.cbplimit)
  result.cbplused = value_to_string_or_empty_string(fut_limit.cbplused)
  result.cbplplanned = value_to_string_or_empty_string(fut_limit.cbplplanned)
  result.varmargin = value_to_string_or_empty_string(fut_limit.varmargin)
  result.accruedint = value_to_string_or_empty_string(fut_limit.accruedint)
  result.cbplused_for_orders = value_to_string_or_empty_string(fut_limit.cbplused_for_orders)
  result.cbplused_for_positions = value_to_string_or_empty_string(fut_limit.cbplused_for_positions)
  result.options_premium = value_to_string_or_empty_string(fut_limit.options_premium)
  result.ts_comission = value_to_string_or_empty_string(fut_limit.ts_comission)
  result.kgo = value_to_string_or_empty_string(fut_limit.kgo)
  result.currcode = utils.Cp2151ToUtf8( assert(fut_limit.currcode, "The given 'fut_limit' table has no 'currcode' field.") )
  result.real_varmargin = value_to_string_or_empty_string(fut_limit.real_varmargin)
  
  return result
end

function StructFactory.create_FuturesLimitDelete(lim_del, existing_struct)
  
  if lim_del == nil then error("No lim_del table provided.", 2) end
  
  local result = (existing_struct == nil and qlua_structs.FuturesLimitDelete() or existing_struct)
  
  result.firmid = utils.Cp2151ToUtf8( assert(lim_del.firmid, "The given 'lim_del' table has no 'firmid' field.") )
  result.limit_type = assert(lim_del.limit_type, "The given 'lim_del' table has no 'limit_type' field.")
  
  return result
end

function StructFactory.create_FuturesClientHolding(fut_pos, existing_struct)
  
  if fut_pos == nil then error("No fut_pos table provided.", 2) end
  
  local result = (existing_struct == nil and qlua_structs.FuturesClientHolding() or existing_struct)
  
  result.firmid = utils.Cp2151ToUtf8( assert(fut_pos.firmid, "The given 'fut_pos' table has no 'firmid' field.") )
  result.trdaccid = utils.Cp2151ToUtf8( assert(fut_pos.trdaccid, "The given 'fut_pos' table has no 'trdaccid' field.") )
  result.sec_code = assert(fut_pos.sec_code, "The given 'fut_pos' table has no 'sec_code' field.")
  result.type = assert(fut_pos.type, "The given 'fut_pos' table has no 'type' field.")
  result.startbuy = value_to_string_or_empty_string(fut_pos.startbuy)
  result.startsell = value_to_string_or_empty_string(fut_pos.startsell)
  result.todaybuy = value_to_string_or_empty_string(fut_pos.todaybuy)
  result.todaysell = value_to_string_or_empty_string(fut_pos.todaysell)
  result.totalnet = value_to_string_or_empty_string(fut_pos.totalnet)
  result.openbuys = assert(fut_pos.openbuys, "The given 'fut_pos' table has no 'openbuys' field.")
  result.opensells = assert(fut_pos.opensells, "The given 'fut_pos' table has no 'opensells' field.")
  result.cbplused = value_to_string_or_empty_string(fut_pos.cbplused)
  result.cbplplanned = value_to_string_or_empty_string(fut_pos.cbplplanned)
  result.varmargin = value_to_string_or_empty_string(fut_pos.varmargin)
  result.avrposnprice = value_to_string_or_empty_string(fut_pos.avrposnprice)
  result.positionvalue = value_to_string_or_empty_string(fut_pos.positionvalue)
  result.real_varmargin = value_to_string_or_empty_string(fut_pos.real_varmargin)
  result.total_varmargin = value_to_string_or_empty_string(fut_pos.total_varmargin)
  result.session_status = assert(fut_pos.session_status, "The given 'fut_pos' table has no 'session_status' field.")
  
  return result
end

function StructFactory.create_MoneyLimit(mlimit, existing_struct)
  
  if mlimit == nil then error("No mlimit table provided.", 2) end

  local result = (existing_struct == nil and qlua_structs.MoneyLimit() or existing_struct)
  
  result.currcode = utils.Cp2151ToUtf8( assert(mlimit.currcode, "The given 'mlimit' table has no 'currcode' field.") )
  result.tag = utils.Cp2151ToUtf8( assert(mlimit.tag, "The given 'mlimit' table has no 'tag' field.") )
  result.firmid = utils.Cp2151ToUtf8( assert(mlimit.firmid, "The given 'mlimit' table has no 'firmid' field.") )
  result.client_code = utils.Cp2151ToUtf8( assert(mlimit.client_code, "The given 'mlimit' table has no 'client_code' field.") )
  result.openbal = value_to_string_or_empty_string(mlimit.openbal)
  result.openlimit = value_to_string_or_empty_string(mlimit.openlimit)
  result.currentbal = value_to_string_or_empty_string(mlimit.currentbal)
  result.currentlimit = value_to_string_or_empty_string(mlimit.currentlimit)
  result.locked = value_to_string_or_empty_string(mlimit.locked)
  result.locked_value_coef = value_to_string_or_empty_string(mlimit.locked_value_coef)
  result.locked_margin_value = value_to_string_or_empty_string(mlimit.locked_margin_value)
  result.leverage = value_to_string_or_empty_string(mlimit.leverage)
  result.limit_kind = assert(mlimit.limit_kind, "The given 'mlimit' table has no 'limit_kind' field.")
  
  return result
end

function StructFactory.create_MoneyLimitDelete(mlimit_del, existing_struct)
  
  if mlimit_del == nil then error("No mlimit_del table provided.", 2) end
  
  local result = (existing_struct == nil and qlua_structs.MoneyLimitDelete() or existing_struct)
  
  result.currcode = utils.Cp2151ToUtf8( assert(mlimit_del.currcode, "The given 'mlimit_del' table has no 'currcode' field.") )
  result.tag = utils.Cp2151ToUtf8( assert(mlimit_del.tag, "The given 'mlimit_del' table has no 'tag' field.") )
  result.client_code = utils.Cp2151ToUtf8( assert(mlimit_del.client_code, "The given 'mlimit_del' table has no 'client_code' field.") )
  result.firmid = utils.Cp2151ToUtf8( assert(mlimit_del.firmid, "The given 'mlimit_del' table has no 'firmid' field.") )
  result.limit_kind = assert(mlimit_del.limit_kind, "The given 'mlimit_del' table has no 'limit_kind' field.")
  
  return result
end

function StructFactory.create_DepoLimit(dlimit, existing_struct)
  
  if dlimit == nil then error("No dlimit table provided.", 2) end
  
  local result = (existing_struct == nil and qlua_structs.DepoLimit() or existing_struct)
  
  result.sec_code = utils.Cp2151ToUtf8( assert(dlimit.sec_code, "The given 'dlimit' table has no 'sec_code' field.") )
  result.trdaccid = utils.Cp2151ToUtf8( assert(dlimit.trdaccid, "The given 'dlimit' table has no 'trdaccid' field.") )
  result.firmid = utils.Cp2151ToUtf8( assert(dlimit.firmid, "The given 'dlimit' table has no 'firmid' field.") )
  result.client_code = utils.Cp2151ToUtf8( assert(dlimit.client_code, "The given 'dlimit' table has no 'client_code' field.") )
  result.openbal = assert(dlimit.openbal, "The given 'dlimit' table has no 'openbal' field.")
  result.openlimit = assert(dlimit.openlimit, "The given 'dlimit' table has no 'openlimit' field.")
  result.currentbal = assert(dlimit.currentbal, "The given 'dlimit' table has no 'currentbal' field.")
  result.currentlimit = assert(dlimit.currentlimit, "The given 'dlimit' table has no 'currentlimit' field.")
  result.locked_sell = assert(dlimit.locked_sell, "The given 'dlimit' table has no 'locked_sell' field.")
  result.locked_buy = assert(dlimit.locked_buy, "The given 'dlimit' table has no 'locked_buy' field.")
  result.locked_buy_value = tostring( assert(dlimit.locked_buy_value, "The given 'dlimit' table has no 'locked_buy_value' field.") )
  result.locked_sell_value = tostring( assert(dlimit.locked_sell_value, "The given 'dlimit' table has no 'locked_sell_value' field.") )
  result.awg_position_price = tostring( assert(dlimit.awg_position_price, "The given 'dlimit' table has no 'awg_position_price' field.") )
  result.limit_kind = assert(dlimit.limit_kind, "The given 'dlimit' table has no 'limit_kind' field.")
  
  return result
end

function StructFactory.create_DepoLimitDelete(dlimit_del, existing_struct)
  
  if dlimit_del == nil then error("No dlimit_del table provided.", 2) end
  
  local result = (existing_struct == nil and qlua_structs.DepoLimitDelete() or existing_struct)
  
  result.sec_code = utils.Cp2151ToUtf8( assert(dlimit_del.sec_code, "The given 'dlimit_del' table has no 'sec_code' field.") )
  result.trdaccid = utils.Cp2151ToUtf8( assert(dlimit_del.trdaccid, "The given 'dlimit_del' table has no 'trdaccid' field.") )
  result.firmid = utils.Cp2151ToUtf8( assert(dlimit_del.firmid, "The given 'dlimit_del' table has no 'firmid' field.") )
  result.client_code = utils.Cp2151ToUtf8( assert(dlimit_del.client_code, "The given 'dlimit_del' table has no 'client_code' field.") )
  result.limit_kind = assert(dlimit_del.limit_kind, "The given 'dlimit_del' table has no 'limit_kind' field.")
  
  return result
end

function StructFactory.create_AccountPosition(acc_pos, existing_struct)
  
  if acc_pos == nil then error("No acc_pos table provided.", 2) end
  
  local result = (existing_struct == nil and qlua_structs.AccountPosition() or existing_struct)
  
  result.firmid = utils.Cp2151ToUtf8( assert(acc_pos.firmid, "The given 'acc_pos' table has no 'firmid' field.") )
  result.currcode = utils.Cp2151ToUtf8( assert(acc_pos.currcode, "The given 'acc_pos' table has no 'currcode' field.") )
  result.tag = utils.Cp2151ToUtf8( assert(acc_pos.tag, "The given 'acc_pos' table has no 'tag' field.") )
  result.description = value_or_empty_string(acc_pos.description)
  result.openbal = value_to_string_or_empty_string(acc_pos.openbal)
  result.currentpos = value_to_string_or_empty_string(acc_pos.currentpos)
  result.plannedpos = value_to_string_or_empty_string(acc_pos.plannedpos)
  result.limit1 = value_to_string_or_empty_string(acc_pos.limit1)
  result.limit2 = value_to_string_or_empty_string(acc_pos.limit2)
  result.orderbuy = value_to_string_or_empty_string(acc_pos.orderbuy)
  result.ordersell = value_to_string_or_empty_string(acc_pos.ordersell)
  result.netto = value_to_string_or_empty_string(acc_pos.netto)
  result.plannedbal = value_to_string_or_empty_string(acc_pos.plannedbal)
  result.debit = value_to_string_or_empty_string(acc_pos.debit)
  result.credit = value_to_string_or_empty_string(acc_pos.credit)
  result.bank_acc_id = value_or_empty_string(acc_pos.bank_acc_id)
  result.margincall = value_to_string_or_empty_string(acc_pos.margincall)
  result.settlebal = value_to_string_or_empty_string(acc_pos.settlebal)
  
  return result
end

function StructFactory.create_NegDeal(neg_deal, existing_struct)
  
  if neg_deal == nil then error("No neg_deal table provided.", 2) end
  
  local result = (existing_struct == nil and qlua_structs.NegDeal() or existing_struct)
  
  result.neg_deal_num = assert(neg_deal.neg_deal_num, "The given 'neg_deal' table has no 'neg_deal_num' field.")
  result.neg_deal_time = value_to_string_or_empty_string(neg_deal.neg_deal_time)
  result.flags = assert(neg_deal.flags, "The given 'neg_deal' table has no 'flags' field.")
  result.brokerref = value_or_empty_string(neg_deal.brokerref)
  result.userid = value_or_empty_string(neg_deal.userid)
  result.firmid = value_or_empty_string(neg_deal.firmid)
  result.cpuserid = value_or_empty_string(neg_deal.cpuserid)
  result.cpfirmid = value_or_empty_string(neg_deal.cpfirmid)
  result.account = value_or_empty_string(neg_deal.account)
  result.price = tostring( assert(neg_deal.price, "The given 'neg_deal' table has no 'price' field.") )
  result.qty = assert(neg_deal.qty, "The given 'neg_deal' table has no 'qty' field.")
  result.matchref = value_or_empty_string(neg_deal.matchref)
  result.settlecode = value_or_empty_string(neg_deal.settlecode)
  result.yield = value_to_string_or_empty_string(neg_deal.yield)
  result.accruedint = value_to_string_or_empty_string(neg_deal.accruedint)
  result.value = value_to_string_or_empty_string(neg_deal.value)
  result.price2 = value_to_string_or_empty_string(neg_deal.price2)
  result.reporate = value_to_string_or_empty_string(neg_deal.reporate)
  result.refundrate = value_to_string_or_empty_string(neg_deal.refundrate)
  result.trans_id = value_to_string_or_empty_string(neg_deal.trans_id)
  result.client_code = value_or_empty_string(neg_deal.client_code)
  result.repoentry = assert(neg_deal.repoentry, "The given 'neg_deal' table has no 'repoentry' field.")
  result.repovalue = value_to_string_or_empty_string(neg_deal.repovalue)
  result.repo2value = value_to_string_or_empty_string(neg_deal.repo2value)
  result.repoterm = value_to_string_or_empty_string(neg_deal.repoterm)
  result.start_discount = value_to_string_or_empty_string(neg_deal.start_discount)
  result.lower_discount = value_to_string_or_empty_string(neg_deal.lower_discount)
  result.upper_discount = value_to_string_or_empty_string(neg_deal.upper_discount)
  result.block_securities = value_to_string_or_empty_string(neg_deal.block_securities)
  result.uid = value_to_string_or_empty_string(neg_deal.uid)
  result.withdraw_time = value_to_string_or_empty_string(neg_deal.withdraw_time)
  result.neg_deal_date = value_to_string_or_empty_string(neg_deal.neg_deal_date)
  result.balance = value_to_string_or_empty_string(neg_deal.balance)
  result.origin_repovalue = value_to_string_or_empty_string(neg_deal.origin_repovalue)
  result.origin_qty = value_to_string_or_empty_string(neg_deal.origin_qty)
  result.origin_discount = value_to_string_or_empty_string(neg_deal.origin_discount)
  result.neg_deal_activation_date = value_to_string_or_empty_string(neg_deal.neg_deal_activation_date)
  result.neg_deal_activation_time = value_to_string_or_empty_string(neg_deal.neg_deal_activation_time)
  result.quoteno = value_to_string_or_empty_string(neg_deal.quoteno)
  result.settle_currency = value_or_empty_string(neg_deal.settle_currency)
  result.sec_code = assert(neg_deal.sec_code, "The given 'neg_deal' table has no 'sec_code' field.")
  result.class_code = utils.Cp2151ToUtf8( assert(neg_deal.class_code, "The given 'neg_deal' table has no 'class_code' field.") )
  result.bank_acc_id = value_or_empty_string(neg_deal.bank_acc_id)
  result.withdraw_date = value_to_string_or_empty_string(neg_deal.withdraw_date)
  result.linkedorder = value_to_string_or_empty_string(neg_deal.linkedorder)
  if neg_deal.activation_date_time then utils.copy_datetime(result.activation_date_time, neg_deal.activation_date_time) end
  if neg_deal.withdraw_date_time then utils.copy_datetime(result.withdraw_date_time, neg_deal.withdraw_date_time) end
  if neg_deal.date_time then utils.copy_datetime(result.date_time, neg_deal.date_time) end
  
  return result
end

function StructFactory.create_NegTrade(neg_trade, existing_struct)
  
  if neg_trade == nil then error("No neg_trade table provided.", 2) end
  
  local result = (existing_struct == nil and qlua_structs.NegTrade() or existing_struct)
  
  result.trade_num = assert(neg_trade.trade_num, "The given 'neg_trade' table has no 'trade_num' field.")
  result.trade_date = value_to_string_or_empty_string(neg_trade.trade_date)
  result.settle_date = value_to_string_or_empty_string(neg_trade.settle_date)
  result.flags = assert(neg_trade.flags, "The given 'neg_trade' table has no 'flags' field.")
  result.brokerref = value_or_empty_string(neg_trade.brokerref)
  result.firmid = value_or_empty_string(neg_trade.firmid)
  result.account = value_or_empty_string(neg_trade.account)
  result.cpfirmid = value_or_empty_string(neg_trade.cpfirmid)
  result.cpaccount = value_or_empty_string(neg_trade.cpaccount)
  result.price = tostring( assert(neg_trade.price, "The given 'neg_trade' table has no 'price' field.") )
  result.qty = assert(neg_trade.qty, "The given 'neg_trade' table has no 'qty' field.")
  result.value = value_to_string_or_empty_string(neg_trade.value)
  result.settlecode = value_or_empty_string(neg_trade.settlecode)
  result.report_num = value_to_string_or_empty_string(neg_trade.report_num)
  result.cpreport_num = value_to_string_or_empty_string(neg_trade.cpreport_num)
  result.accruedint = value_to_string_or_empty_string(neg_trade.accruedint)
  result.repotradeno = value_to_string_or_empty_string(neg_trade.repotradeno)
  result.price1 = value_to_string_or_empty_string(neg_trade.price1)
  result.reporate = value_to_string_or_empty_string(neg_trade.reporate)
  result.price2 = value_to_string_or_empty_string(neg_trade.price2)
  result.client_code = value_or_empty_string(neg_trade.client_code)
  result.ts_comission = value_to_string_or_empty_string(neg_trade.ts_comission)
  result.balance = value_to_string_or_empty_string(neg_trade.balance)
  result.settle_time = value_to_string_or_empty_string(neg_trade.settle_time)
  result.amount = value_to_string_or_empty_string(neg_trade.amount)
  result.repovalue = value_to_string_or_empty_string(neg_trade.repovalue)
  result.repoterm = value_to_string_or_empty_string(neg_trade.repoterm)
  result.repo2value = value_to_string_or_empty_string(neg_trade.repo2value)
  result.return_value = value_to_string_or_empty_string(neg_trade.return_value)
  result.discount = value_to_string_or_empty_string(neg_trade.discount)
  result.lower_discount = value_to_string_or_empty_string(neg_trade.lower_discount)
  result.upper_discount = value_to_string_or_empty_string(neg_trade.upper_discount)
  result.block_securities = value_to_string_or_empty_string(neg_trade.block_securities)
  result.urgency_flag = value_to_string_or_empty_string(neg_trade.urgency_flag)
  result.type = assert(neg_trade.type, "The given 'neg_trade' table has no 'type' field.")
  result.operation_type = assert(neg_trade.operation_type, "The given 'neg_trade' table has no 'operation_type' field.")
  result.expected_discount = value_to_string_or_empty_string(neg_trade.expected_discount)
  result.expected_quantity = value_to_string_or_empty_string(neg_trade.expected_quantity)
  result.expected_repovalue = value_to_string_or_empty_string(neg_trade.expected_repovalue)
  result.expected_repo2value = value_to_string_or_empty_string(neg_trade.expected_repo2value)
  result.expected_return_value = value_to_string_or_empty_string(neg_trade.expected_return_value)
  result.order_num = value_to_string_or_empty_string(neg_trade.order_num)
  result.report_trade_date = value_to_string_or_empty_string(neg_trade.report_trade_date)
  result.settled = assert(neg_trade.settled, "The given 'neg_trade' table has no 'settled' field.")
  result.clearing_type = assert(neg_trade.clearing_type, "The given 'neg_trade' table has no 'clearing_type' field.")
  result.report_comission = value_to_string_or_empty_string(neg_trade.report_comission)
  result.coupon_payment = value_to_string_or_empty_string(neg_trade.coupon_payment)
  result.principal_payment = value_to_string_or_empty_string(neg_trade.principal_payment)
  result.principal_payment_date = value_to_string_or_empty_string(neg_trade.principal_payment_date)
  result.nextdaysettle = value_to_string_or_empty_string(neg_trade.nextdaysettle)
  result.settle_currency = value_or_empty_string(neg_trade.settle_currency)
  result.sec_code = assert(neg_trade.sec_code, "The given 'neg_trade' table has no 'sec_code' field.")
  result.class_code = utils.Cp2151ToUtf8( assert(neg_trade.class_code, "The given 'neg_trade' table has no 'class_code' field.") )
  result.compval = value_to_string_or_empty_string(neg_trade.compval)
  result.parenttradeno = value_to_string_or_empty_string(neg_trade.parenttradeno)
  result.bankid = value_or_empty_string(neg_trade.bankid)
  result.bankaccid = value_or_empty_string(neg_trade.bankaccid)
  result.precisebalance = value_to_string_or_empty_string(neg_trade.precisebalance)
  result.confirmtime = value_to_string_or_empty_string(neg_trade.confirmtime)
  result.ex_flags = assert(neg_trade.ex_flags, "The given 'neg_trade' table has no 'ex_flags' field.")
  result.confirmreport = value_to_string_or_empty_string(neg_trade.confirmreport)
  
  return result
end

function StructFactory.create_StopOrder(stop_order, existing_struct)
  
  if stop_order == nil then error("No stop_order table provided.", 2) end
  
  local result = (existing_struct == nil and qlua_structs.StopOrder() or existing_struct)
  
  result.order_num = assert(stop_order.order_num, "The given 'stop_order' table has no 'order_num' field.")
  result.ordertime = value_to_string_or_empty_string(stop_order.ordertime)
  result.flags = assert(stop_order.flags, "The given 'stop_order' table has no 'flags' field.")
  result.brokerref = value_or_empty_string(stop_order.brokerref)
  result.firmid = value_or_empty_string(stop_order.firmid)
  result.account = utils.Cp2151ToUtf8( assert(stop_order.account, "The given 'stop_order' table has no 'account' field.") )
  result.condition = assert(stop_order.condition, "The given 'stop_order' table has no 'condition' field.")
  result.condition_price = tostring( assert(stop_order.condition_price, "The given 'stop_order' table has no 'condition_price' field.") )
  result.price = tostring( assert(stop_order.price, "The given 'stop_order' table has no 'price' field.") )
  result.qty = assert(stop_order.qty, "The given 'stop_order' table has no 'qty' field.")
  result.linkedorder = value_to_string_or_empty_string(stop_order.linkedorder)
  result.expiry = value_to_string_or_empty_string(stop_order.expiry)
  result.trans_id = value_to_string_or_empty_string(stop_order.trans_id)
  result.client_code = utils.Cp2151ToUtf8( assert(stop_order.client_code, "The given 'stop_order' table has no 'client_code' field.") )
  result.co_order_num = value_to_string_or_empty_string(stop_order.co_order_num)
  result.co_order_price = value_to_string_or_empty_string(stop_order.co_order_price)
  result.stop_order_type = assert(stop_order.stop_order_type, "The given 'stop_order' table has no 'stop_order_type' field.")
  result.orderdate = value_to_string_or_empty_string(stop_order.orderdate)
  result.alltrade_num = value_to_string_or_empty_string(stop_order.alltrade_num)
  result.stopflags = assert(stop_order.stopflags, "The given 'stop_order' table has no 'stopflags' field.")
  result.offset = value_to_string_or_empty_string(stop_order.offset)
  result.spread = value_to_string_or_empty_string(stop_order.spread)
  result.balance = value_to_string_or_empty_string(stop_order.balance)
  result.uid = value_to_string_or_empty_string(stop_order.uid)
  result.filled_qty = assert(stop_order.filled_qty, "The given 'stop_order' table has no 'filled_qty' field.")
  result.withdraw_time = value_to_string_or_empty_string(stop_order.withdraw_time)
  result.condition_price2 = value_to_string_or_empty_string(stop_order.condition_price2)
  result.active_from_time = value_to_string_or_empty_string(stop_order.active_from_time)
  result.active_to_time = value_to_string_or_empty_string(stop_order.active_to_time)
  result.sec_code = assert(stop_order.sec_code, "The given 'stop_order' table has no 'sec_code' field.")
  result.class_code = utils.Cp2151ToUtf8( assert(stop_order.class_code, "The given 'stop_order' table has no 'class_code' field.") )
  result.condition_sec_code = value_or_empty_string(stop_order.condition_sec_code)
  result.condition_class_code = value_or_empty_string(stop_order.condition_class_code)
  result.canceled_uid = value_to_string_or_empty_string(stop_order.canceled_uid)
  utils.copy_datetime(result.order_date_time, assert(stop_order.order_date_time, "The given 'stop_order' table has no 'order_date_time' field."))
  if stop_order.withdraw_datetime then utils.copy_datetime(result.withdraw_datetime, stop_order.withdraw_datetime) end
  
  return result
end

function StructFactory.create_Transaction(trans_reply, existing_struct)
  
  local result = (existing_struct == nil and qlua_structs.Transaction() or existing_struct)
  
  result.trans_id = trans_reply.trans_id
  result.status = trans_reply.status
  result.result_msg = value_or_empty_string(trans_reply.result_msg)
  if trans_reply.date_time ~= nil then utils.copy_datetime(result.date_time, trans_reply.date_time) end
  result.uid = value_to_string_or_empty_string(trans_reply.uid)
  result.flags = trans_reply.flags
  result.server_trans_id = value_to_string_or_empty_string(trans_reply.server_trans_id)
  result.order_num = value_to_string_or_empty_string(trans_reply.order_num)
  result.price = value_to_string_or_empty_string(trans_reply.price)
  result.quantity = value_to_string_or_empty_string(trans_reply.quantity)
  result.balance = value_to_string_or_empty_string(trans_reply.balance)
  result.firm_id = value_or_empty_string(trans_reply.firm_id)
  result.account = value_or_empty_string(trans_reply.account)
  result.client_code = value_or_empty_string(trans_reply.client_code)
  result.brokerref = value_or_empty_string(trans_reply.brokerref)
  result.class_code = value_or_empty_string(trans_reply.class_code)
  result.sec_code = value_or_empty_string(trans_reply.sec_code)
  result.exchange_code = value_or_empty_string(trans_reply.exchange_code)
  
  return result
end

function StructFactory.create_Security(security, existing_struct)
  
  local result = (existing_struct == nil and qlua_structs.Transaction() or existing_struct)
  
  result.code = value_or_empty_string(security.code)
  result.name = value_or_empty_string(security.name)
  result.short_name = value_or_empty_string(security.short_name)
  result.class_code = value_or_empty_string(security.class_code)
  result.class_name = value_or_empty_string(security.class_name)
  result.face_value = value_to_string_or_empty_string(security.face_value)
  result.face_unit = value_or_empty_string(security.face_unit)
  result.scale = value_to_string_or_empty_string(security.scale)
  result.mat_date = value_to_string_or_empty_string(security.mat_date)
  result.lot_size = value_to_string_or_empty_string(security.lot_size)
  result.isin_code = value_or_empty_string(security.isin_code)
  result.min_price_step = value_to_string_or_empty_string(security.min_price_step)
  
  return result
end

return StructFactory
