-- Lua functions
local assert = assert(assert, "Функция 'assert' не найдена.")
local error = assert(error, "Функция 'error' не найдена.")
local string = assert(string, "Taблица 'string' не найдена.")
local pcall = assert(pcall, "Функция 'pcall' не найдена.")
local pairs = assert(pairs, "Функция 'pairs' не найдена.")
local ipairs = assert(ipairs, "Функция 'ipairs' не найдена.")
local tostring = assert(tostring, "Функция 'tostring' не найдена.")
local tonumber = assert(tostring, "Функция 'tonumber' не найдена.")
local loadstring = assert(loadstring, "Функция 'loadstring' не найдена.")
local table = assert(table, "Таблица 'table' не найдена.")
local bit = assert(bit, "Таблица 'bit' не найдена.")
local unpack = assert(unpack, "Функция 'unpack' не найдена.")

-- Utility modules and functions
local utils = require("utils.utils")
local uuid = require("utils.uuid")

-----
-- The DataSources in-memory storage. 
-- Warning: the storage may cause memory leaks if the datasources that aren't needed anymore have not been explicitly closed by the clients, 
-- because the datasources' objects would never be eligible for garbage collection (whereas in a local script they become so as soon as the script exits the main function).
local datasources = {}
local function get_datasource (datasource_uid)
  return assert(datasources[datasource_uid], string.format("DataSource c uuid='%s' не найден.", datasource_uid))
end

-----

local function requireNonNil (x)
  
  if x == nil then error("Целевая QLua-функция возвратила nil.") end
  return x 
end

local function to_string_string_table (t)
  
  local result = {}
  for k, v in pairs(t) do
    local value
    if type(v) == 'table' then
      value = to_string_string_table(v)
    else
      value = utils.Cp1251ToUtf8(tostring(v))
    end
    result[utils.Cp1251ToUtf8(tostring(k))] = value
  end
  
  return result
end

-----

local module = {}

-- TODO: test
module["isConnected"] = function ()
  return requireNonNil(_G.isConnected())
end

-- TODO: test
module["getScriptPath"] = function ()
  return requireNonNil(_G.getScriptPath())
end

-- TODO: test
module["getInfoParam"] = function (args)
  return utils.Cp1251ToUtf8(requireNonNil(_G.getInfoParam(args.param_name)))
end

module["message"] = function (args)
  -- returns 1 or nil
  return _G.message(utils.Utf8ToCp1251(args.message), args.icon_type)
end

-- TODO: test
module["sleep"] = function (args) 
  -- returns nil in case of error
  return _G.sleep(args.time)
end

-- TODO: test
module["getWorkingFolder"] = function ()
  return requireNonNil(_G.getWorkingFolder())
end

-- TODO: test
module["PrintDbgStr"] = function (args) 
  _G.PrintDbgStr(args.s)
end

-- TODO: test
module["os.sysdate"] = function () 
  return os.sysdate()
end

-- TODO: test
module["getItem"] = function (args) 
  
  -- returns nil in case of error
  local result = _G.getItem(args.table_name, args.index)
  if result then
    if type(result) == 'table' then
      return to_string_string_table(result)
    else
      return {singular_result = result}
    end
  else
    return nil
  end
end

-- TODO: test
module["getOrderByNumber"] = function (args) 
  
  local order, indx = _G.getOrderByNumber(args.class_code, args.order_id)
  
  -- post-processing: stringify non-string non-mandatory fields, assert the precence of mandatory fields
  if order then
    assert(order.order_num, "Таблица 'order' не содержит обязательного поля 'order_num'.")
    assert(order.flags, "Таблица 'order' не содержит обязательного поля 'flags'.")
    order.brokerref = utils.Cp1251ToUtf8(order.brokerref)
    order.userid = utils.Cp1251ToUtf8(order.userid)
    order.firmid = utils.Cp1251ToUtf8(order.firmid)
    order.account = utils.Cp1251ToUtf8(order.account)
    order.price = tostring( assert(order.price, "Таблица 'order' не содержит обязательного поля 'price'.") )
    assert(order.qty, "Таблица 'order' не содержит обязательного поля 'qty'.")
    if order.balance then order.balance = tostring(order.balance) end
    order.value = tostring( assert(order.value, "Таблица 'order' не содержит обязательного поля 'value'.") )
    if order.accruedint then order.accruedint = tostring(order.accruedint) end
    if order.yield then order.yield = tostring(order.yield) end
    if order.trans_id then order.trans_id = tostring(order.trans_id) end
    order.client_code = utils.Cp1251ToUtf8(order.client_code)
    if order.price2 then order.price2 = tostring(order.price2) end
    order.settlecode = utils.Cp1251ToUtf8(order.settlecode)
    if order.uid then order.uid = tostring(order.uid) end
    if order.canceled_uid then order.canceled_uid = tostring(order.canceled_uid) end
    order.exchange_code = utils.Cp1251ToUtf8(order.exchange_code)
    if order.activation_time then order.activation_time = tostring(order.activation_time) end
    if order.linkedorder then order.linkedorder = tostring(order.linkedorder) end
    if order.expiry then order.expiry = tostring(order.expiry) end
    assert(order.sec_code, "Таблица 'order' не содержит обязательного поля 'sec_code'.")
    assert(order.class_code, "Таблица 'order' не содержит обязательного поля 'class_code'.")
    assert(order.datetime, "Таблица 'order' не содержит обязательного поля 'datetime'.")
    order.bank_acc_id = utils.Cp1251ToUtf8(order.bank_acc_id)
    assert(order.value_entry_type, "Таблица 'order' не содержит обязательного поля 'value_entry_type'.")
    if order.repoterm then order.repoterm = tostring(order.repoterm) end
    if order.repovalue then order.repovalue = tostring(order.repovalue) end
    if order.repo2value then order.repo2value = tostring(order.repo2value) end
    if order.repo_value_balance then order.repo_value_balance = tostring(order.repo_value_balance) end
    if order.start_discount then order.start_discount = tostring(order.start_discount) end
    order.reject_reason = utils.Cp1251ToUtf8(order.reject_reason)
    if order.ext_order_flags then order.ext_order_flags = tostring(order.ext_order_flags) end
    assert(order.min_qty, "Таблица 'order' не содержит обязательного поля 'min_qty'.")
    assert(order.exec_type, "Таблица 'order' не содержит обязательного поля 'exec_type'.")
    assert(order.side_qualifier, "Таблица 'order' не содержит обязательного поля 'side_qualifier'.")
    assert(order.acnt_type, "Таблица 'order' не содержит обязательного поля 'acnt_type'.")
    assert(order.capacity, "Таблица 'order' не содержит обязательного поля 'capacity'.")
    assert(order.passive_only_order, "Таблица 'order' не содержит обязательного поля 'passive_only_order'.")
    assert(order.visible, "Таблица 'order' не содержит обязательного поля 'visible'.")
    if order.awg_price then order.awg_price = tostring(order.awg_price) end
    if order.expiry_time then order.expiry_time = tostring(order.expiry_time) end
    if order.revision_number then order.revision_number = tostring(order.revision_number) end
    order.price_currency = utils.Cp1251ToUtf8(order.price_currency)
    assert(order.ext_order_status, "Таблица 'order' не содержит обязательного поля 'ext_order_status'.")
    if order.accepted_uid then order.accepted_uid = tostring(order.accepted_uid) end
    if order.filled_value then order.filled_value = tostring(order.filled_value) end
    order.extref = utils.Cp1251ToUtf8(order.extref)
    order.settle_currency = utils.Cp1251ToUtf8(order.settle_currency)
    if order.on_behalf_of_uid then order.on_behalf_of_uid = tostring(order.on_behalf_of_uid) end
    assert(order.client_qualifier, "Таблица 'order' не содержит обязательного поля 'client_qualifier'.")
    if order.client_short_code then order.client_short_code = tostring(order.client_short_code) end
    assert(order.investment_decision_maker_qualifier, "Таблица 'order' не содержит обязательного поля 'investment_decision_maker_qualifier'.")
    if order.investment_decision_maker_short_code then order.investment_decision_maker_short_code = tostring(order.investment_decision_maker_short_code) end
    assert(order.executing_trader_qualifier, "Таблица 'order' не содержит обязательного поля 'executing_trader_qualifier'.")
    if order.executing_trader_short_code then order.executing_trader_short_code = tostring(order.executing_trader_short_code) end
  end
  
  return {
    order = order,
    indx = indx
  }
end

-- TODO: test
module["getNumberOf"] = function (args) 
  -- returns -1 in case of error
  return requireNonNil(_G.getNumberOf(args.table_name))
end

-- TODO: test
-- TODO: thorough testing
module["SearchItems"] = function (args) 
  
  local fn_ctr, error_msg = loadstring("return "..args.fn_def)
  local result
  if fn_ctr == nil then 
    error(string.format("Не удалось распарсить определение функции из переданной строки. Описание ошибки: [%s].", error_msg))
  else
    if not args.params or args.params == "" then
      result = _G.SearchItems(args.table_name, args.start_index, args.end_index and args.end_index or (_G.getNumberOf(args.table_name) - 1), fn_ctr()) -- returns nil in case of empty list found or error
    else 
      result = _G.SearchItems(args.table_name, args.start_index, args.end_index and args.end_index or (_G.getNumberOf(args.table_name) - 1), fn_ctr(), args.params) -- returns nil in case of empty list found or error
    end
  end
  
  return result
end

-- TODO: test
module["getClassesList"] = function ()
  return requireNonNil(_G.getClassesList())
end

-- TODO: test
module["getClassInfo"] = function (args) 
  
  local result = requireNonNil(_G.getClassInfo(args.class_code))
  result.firmid = utils.Cp1251ToUtf8( assert(result.firmid, "Результирующая таблица не содержит обязательного поля 'firmid'.") )
  result.name = result.name and utils.Cp1251ToUtf8(result.name) or nil
  result.code = result.code and utils.Cp1251ToUtf8(result.code) or nil
  
  return result
end

-- TODO: test
module["getClassSecurities"] = function (args) 
  -- returns an empty string if no securities found for the given class_code
  return requireNonNil(_G.getClassSecurities(args.class_code))
end

-- TODO: test
module["getMoney"] = function (args) 
  
  local result = requireNonNil(_G.getMoney(args.client_code, args.firmid, args.tag, args.currcode)) -- returns a table with zero'ed values if no info found or in case of error
  
  if result.money_open_limit then result.money_open_limit = tostring(result.money_open_limit) end
  if result.money_limit_locked_nonmarginal_value then result.money_limit_locked_nonmarginal_value = tostring(result.money_limit_locked_nonmarginal_value) end
  if result.money_limit_locked then result.money_limit_locked = tostring(result.money_limit_locked) end
  if result.money_open_balance then result.money_open_balance = tostring(result.money_open_balance) end
  if result.money_current_limit then result.money_current_limit = tostring(result.money_current_limit) end
  if result.money_current_balance then result.money_current_balance = tostring(result.money_current_balance) end
  if result.money_limit_available then result.money_limit_available = tostring(result.money_limit_available) end

  return result
end

-- TODO: test
module["getMoneyEx"] = function (args) 
  
  -- returns nil if no info found or in case of an error
  local result = _G.getMoneyEx(args.firmid, args.client_code, args.tag, args.currcode, args.limit_kind)

  if result then
    result.currcode = utils.Cp1251ToUtf8( assert(result.currcode, "Результирующая таблица не содержит обязательного поля 'currcode'.") )
    result.tag = utils.Cp1251ToUtf8( assert(result.tag, "Результирующая таблица не содержит обязательного поля 'tag'.") )
    result.firmid = utils.Cp1251ToUtf8( assert(result.firmid, "Результирующая таблица не содержит обязательного поля 'firmid'.") )
    result.client_code = utils.Cp1251ToUtf8( assert(result.client_code, "Результирующая таблица не содержит обязательного поля 'client_code'.") )
    if result.openbal then result.openbal = tostring(result.openbal) end
    if result.openlimit then result.openlimit = tostring(result.openlimit) end
    if result.currentbal then result.currentbal = tostring(result.currentbal) end
    if result.currentlimit then result.currentlimit = tostring(result.currentlimit) end
    if result.locked then result.locked = tostring(result.locked) end
    if result.locked_value_coef then result.locked_value_coef = tostring(result.locked_value_coef) end
    if result.locked_margin_value then result.locked_margin_value = tostring(result.locked_margin_value) end
    if result.leverage then result.leverage = tostring(result.leverage) end
    assert(result.limit_kind, "Результирующая таблица не содержит обязательного поля 'limit_kind'.")
    if result.wa_position_price then result.wa_position_price = tostring(result.wa_position_price) end
    if result.orders_collateral then result.orders_collateral = tostring(result.orders_collateral) end
    if result.positions_collateral then result.positions_collateral = tostring(result.positions_collateral) end
  end

  return result
end

-- TODO: test
module["getDepo"] = function (args) 
  
  -- returns a table with zero'ed values if no info found or in case of an error
  local result = requireNonNil(_G.getDepo(args.client_code, args.firmid, args.sec_code, args.trdaccid))

  -- post-processing: stringification of decimal numbers
  if result.depo_limit_locked_buy_value then result.depo_limit_locked_buy_value = tostring(result.depo_limit_locked_buy_value) end
  if result.depo_current_balance then result.depo_current_balance = tostring(result.depo_current_balance) end
  if result.depo_limit_locked_buy then result.depo_limit_locked_buy = tostring(result.depo_limit_locked_buy) end
  if result.depo_limit_locked then result.depo_limit_locked = tostring(result.depo_limit_locked) end
  if result.depo_limit_available then result.depo_limit_available = tostring(result.depo_limit_available) end
  if result.depo_current_limit then result.depo_current_limit = tostring(result.depo_current_limit) end
  if result.depo_open_balance then result.depo_open_balance = tostring(result.depo_open_balance) end
  if result.depo_open_limit then result.depo_open_limit = tostring(result.depo_open_limit) end

  return result
end

-- TODO: test
module["getDepoEx"] = function (args) 

  -- returns nil if no info found or in case of an error
  local result = _G.getDepoEx(args.firmid, args.client_code, args.sec_code, args.trdaccid, args.limit_kind)
  
  -- post-processing: stringification of decimal numbers, encoding conversion, field presence checks
  if result then
    result.sec_code = utils.Cp1251ToUtf8( assert(result.sec_code, "Результирующая таблица не содержит обязательного поля 'sec_code'.") )
    result.trdaccid = utils.Cp1251ToUtf8( assert(result.trdaccid, "Результирующая таблица не содержит обязательного поля 'trdaccid'.") )
    result.firmid = utils.Cp1251ToUtf8( assert(result.firmid, "Результирующая таблица не содержит обязательного поля 'firmid'.") )
    result.client_code = utils.Cp1251ToUtf8( assert(result.client_code, "Результирующая таблица не содержит обязательного поля 'client_code'.") )
    assert(result.openbal, "Результирующая таблица не содержит обязательного поля 'openbal'.")
    assert(result.openlimit, "Результирующая таблица не содержит обязательного поля 'openlimit'.")
    assert(result.currentbal, "Результирующая таблица не содержит обязательного поля 'currentbal'.")
    assert(result.currentlimit, "Результирующая таблица не содержит обязательного поля 'currentlimit'.")
    assert(result.locked_sell, "Результирующая таблица не содержит обязательного поля 'locked_sell'.")
    assert(result.locked_buy, "Результирующая таблица не содержит обязательного поля 'locked_buy'.")
    result.locked_buy_value = tostring( assert(result.locked_buy_value, "Результирующая таблица не содержит обязательного поля 'locked_buy_value'.") )
    result.locked_sell_value = tostring( assert(result.locked_sell_value, "Результирующая таблица не содержит обязательного поля 'locked_sell_value'.") )
    result.wa_position_price = tostring( assert(result.wa_position_price, "Результирующая таблица не содержит обязательного поля 'awg_position_price'.") )
    assert(result.limit_kind, "Результирующая таблица не содержит обязательного поля 'limit_kind'.")
  end
    
  return result
end

-- TODO: test
module["getFuturesLimit"] = function (args) 

  -- returns nil if no info found or in case of an error
  local result = _G.getFuturesLimit(args.firmid, args.trdaccid, args.limit_type, args.currcode)
  
  -- post-processing: stringification of decimal numbers, encoding conversion, field presence checks
  if result then
    result.firmid = utils.Cp1251ToUtf8( assert(result.firmid, "Результирующая таблица не содержит обязательного поля 'firmid'.") )
    result.trdaccid = utils.Cp1251ToUtf8( assert(result.trdaccid, "Результирующая таблица не содержит обязательного поля 'trdaccid'.") )
    assert(result.limit_type, "Результирующая таблица не содержит обязательного поля 'limit_type'.")
    if result.liquidity_coef then result.liquidity_coef = tostring(result.liquidity_coef) end
    if result.cbp_prev_limit then result.cbp_prev_limit = tostring(result.cbp_prev_limit) end
    if result.cbplimit then result.cbplimit = tostring(result.cbplimit) end
    if result.cbplused then result.cbplused = tostring(result.cbplused) end
    if result.cbplplanned then result.cbplplanned = tostring(result.cbplplanned) end
    if result.varmargin then result.varmargin = tostring(result.varmargin) end
    if result.accruedint then result.accruedint = tostring(result.accruedint) end
    if result.cbplused_for_orders then result.cbplused_for_orders = tostring(result.cbplused_for_orders) end
    if result.cbplused_for_positions then result.cbplused_for_positions = tostring(result.cbplused_for_positions) end
    if result.options_premium then result.options_premium = tostring(result.options_premium) end
    if result.ts_comission then result.ts_comission = tostring(result.ts_comission) end
    if result.kgo then result.kgo = tostring(result.kgo) end
    result.currcode = utils.Cp1251ToUtf8( assert(result.currcode, "Результирующая таблица не содержит обязательного поля 'currcode'.") )
    if result.real_varmargin then result.real_varmargin = tostring(result.real_varmargin) end
  end

  return result
end

-- TODO: test
module["getFuturesHolding"] = function (args) 

  -- returns nil if no info found or in case of an error
  local result = _G.getFuturesHolding(args.firmid, args.trdaccid, args.sec_code, args.type)
  
  -- post-processing: stringification of decimal numbers, encoding conversion, field presence checks
  if result then
    result.firmid = utils.Cp1251ToUtf8( assert(result.firmid, "Результирующая таблица не содержит обязательного поля 'firmid'.") )
    result.trdaccid = utils.Cp1251ToUtf8( assert(result.trdaccid, "Результирующая таблица не содержит обязательного поля 'trdaccid'.") )
    assert(result.sec_code, "Результирующая таблица не содержит обязательного поля 'sec_code'.")
    assert(result.type, "Результирующая таблица не содержит обязательного поля 'type'.")
    if result.startbuy then result.startbuy = tostring(result.startbuy) end
    if result.startsell then result.startsell = tostring(result.startsell) end
    if result.todaybuy then result.todaybuy = tostring(result.todaybuy) end
    if result.todaysell then result.todaysell = tostring(result.todaysell) end
    if result.totalnet then result.totalnet = tostring(result.totalnet) end
    assert(result.openbuys, "Результирующая таблица не содержит обязательного поля 'openbuys'.")
    assert(result.opensells, "Результирующая таблица не содержит обязательного поля 'opensells'.")
    if result.cbplused then result.cbplused = tostring(result.cbplused) end
    if result.cbplplanned then result.cbplplanned = tostring(result.cbplplanned) end
    if result.varmargin then result.varmargin = tostring(result.varmargin) end
    if result.avrposnprice then result.avrposnprice = tostring(result.avrposnprice) end
    if result.positionvalue then result.positionvalue = tostring(result.positionvalue) end
    if result.real_varmargin then result.real_varmargin = tostring(result.real_varmargin) end
    if result.total_varmargin then result.total_varmargin = tostring(result.total_varmargin) end
    assert(result.session_status, "Результирующая таблица не содержит обязательного поля 'session_status'.")
  end

  return result
end

-- TODO: test
module["getSecurityInfo"] = function (args) 

  local result = _G.getSecurityInfo(args.class_code, args.sec_code) -- returns nil if no info found or in case of an error
  
  if result then
    assert(result.code, "Результирующая таблица не содержит обязательного поля 'code'.")
    result.name = result.name and utils.Cp1251ToUtf8(result.name) or nil
    result.short_name = result.short_name and utils.Cp1251ToUtf8(result.short_name) or nil
    result.class_code = utils.Cp1251ToUtf8( assert(result.class_code, "Функция getSecurityInfo: результирующая таблица не содержит обязательного поля 'class_code'.") )
    result.class_name = result.class_name and utils.Cp1251ToUtf8(result.class_name) or nil
    if result.face_value then result.face_value = tostring(result.face_value) end
    result.face_unit = result.face_unit and utils.Cp1251ToUtf8(result.face_unit) or nil
    if result.scale then result.scale = tostring(result.scale) end
    if result.mat_date then result.mat_date = tostring(result.mat_date) end
    if result.lot_size then result.lot_size = tostring(result.lot_size) end
    result.isin_code = result.isin_code and utils.Cp1251ToUtf8(result.isin_code) or nil
    if result.min_price_step then result.min_price_step = tostring(result.min_price_step) end
  end

  return result
end

-- TODO: test
module["getTradeDate"] = function () 
  
  local result = requireNonNil(_G.getTradeDate())
  
  assert(result.date, "Результирующая таблица не содержит обязательного поля 'date'.")
  assert(result.year, "Результирующая таблица не содержит обязательного поля 'year'.")
  assert(result.month, "Результирующая таблица не содержит обязательного поля 'month'.")
  assert(result.day, "Результирующая таблица не содержит обязательного поля 'day'.") 
  
  return result
end

-- TODO: test
module["getQuoteLevel2"] = function (args) 
  
  local result = requireNonNil(_G.getQuoteLevel2(args.class_code, args.sec_code))
  
  assert(result.bid_count, "Результирующая таблица не содержит обязательного поля 'bid_count'.")
  assert(result.offer_count, "Результирующая таблица не содержит обязательного поля 'offer_count'.")
  
  result.bids = {}
  local bid = result.bid
  if bid and bid ~= "" then
    for _, v in ipairs(bid) do
      table.sinsert(result.bids, {price = v.price, quantity = v.quantity})
    end
  end
  result.bid = nil
  
  result.offers = {}
  local offer = result.offer
  if offer and offer ~= "" then
    for _, v in ipairs(offer) do
      table.sinsert(result.offers, {price = v.price, quantity = v.quantity})
    end
  end
  result.offer = nil
  
  return result
end

-- TODO: test
module["getLinesCount"] = function (args) 
  return requireNonNil(_G.getLinesCount(args.tag)) -- returns 0 if no chart with this tag found
end

-- TODO: test
module["getNumCandles"] = function (args) 
  return requireNonNil(_G.getNumCandles(args.tag)) -- returns 0 if no chart with this tag found
end

-- TODO: test
module["getCandlesByIndex"] = function (args) 
  
  local t, n, l = _G.getCandlesByIndex(args.tag, args.line, args.first_candle, args.count) -- returns ({}, 0, "") if no info found or in case of error
  
  if not t then 
    error("Целевая QLua-функция возвратила nil вместо значения 't'.")
  end
  
  if not n then
    error("Целевая QLua-функция возвратила nil вместо значения 'n'.")
  end
  
  if not l then
    error("Целевая QLua-функция возвратила nil вместо значения 'l'.")
  end

  local processedCandles = {}
  for i, candle in pairs(t) do

      table.sinsert(processedCandles, candle)
      -- post-processing: stringification of decimal numbers
      candle.open = tostring(assert(candle.open, string.format("Свеча с индексом %s не содержит обязательного поля 'open'.", i)))
      candle.close = tostring(assert(candle.close, string.format("Свеча с индексом %s не содержит обязательного поля 'close'.", i)))
      candle.high = tostring(assert(candle.high, string.format("Свеча с индексом %s не содержит обязательного поля 'high'.", i)))
      candle.low = tostring(assert(candle.low, string.format("Свеча с индексом %s не содержит обязательного поля 'low'.", i)))
      candle.volume = tostring(assert(candle.volume, string.format("Свеча с индексом %s не содержит обязательного поля 'volume'.", i)))
  end
  
  return {
    t = processedCandles,
    n = n,
    l = utils.Cp1251ToUtf8(l)
  }
end

-- TODO: test
module["datasource.CreateDataSource"] = function (args)
  
  local ds, error_desc
  if args.param == nil or args.param == "" then
    ds, error_desc = _G.CreateDataSource(args.class_code, args.sec_code, utils.to_interval(args.interval))
  else 
    ds, error_desc = _G.CreateDataSource(args.class_code, args.sec_code, utils.to_interval(args.interval), args.param)
  end
  
  local result
  if ds then
    local datasource_uuid = uuid()
    if not datasource_uuid then
      ds:Close()
      error("Не удалось сгенерировать UUID для источника данных.")
    end
    datasources[datasource_uuid] = ds
    result = {
      datasource_uuid = datasource_uuid,
      is_error = false
    }
  else
    result = {
      is_error = true,
      error_desc = error_desc
    }
  end
  
  return result
end

-- TODO: test
module["datasource.SetUpdateCallback"] = function (args) 
  
  local ds_uuid = args.datasource_uuid
  local ds = get_datasource(ds_uuid)
  
  local f_cb_def = args.f_cb_def
  local f_cb
  if f_cb_def and f_cb_def ~= '' then
    local f_cb_ctr, error_msg = loadstring("return "..args.f_cb_def)
    if f_cb_ctr == nil then 
      error( string.format("Не удалось распарсить определение функции из переданной строки. Описание ошибки: [%s].", error_msg) )
    else
      f_cb = f_cb_ctr()
    end
  end
  
  local actual_callback_code = "return function (index) "
  
  local watch_code = ""
  if args.watching_O then
    watch_code = "props.O = ds:O(index) "
  end
  
  if args.watching_H then
    watch_code = watch_code .. "props.H = ds:H(index) "
  end
  
  if args.watching_L then
    watch_code = watch_code .. "props.L = ds:L(index) "
  end
  
  if args.watching_C then
    watch_code = watch_code .. "props.C = ds:C(index) "
  end
  
  if args.watching_V then
    watch_code = watch_code .. "props.V = ds:V(index) "
  end
  
  if args.watching_T then
    watch_code = watch_code .. "props.T = ds:T(index) "
  end
  
  if args.watching_Size then
    watch_code = watch_code .. "props.Size = ds:Size(index) "
  end
  
  if watch_code ~= "" then
    local data_object_init_code = "local props = {uuid = \"" .. ds_uuid .. "\", index = " .. index .. "} "
    watch_code = data_object_init_code .. watch_code .. "_G.OnDataSourceUpdate(props) " 
    actual_callback_code = actual_callback_code .. watch_code
  end
  
  if f_cb then
    actual_callback_code = actual_callback_code .. "f_cb(index, ds) "
  end
  
  actual_callback_code = actual_callback_code .. "end"
  
  local actual_callback_ctr = loadstring(actual_callback_code)
  return requireNonNil(ds:SetUpdateCallback(actual_callback_ctr()))
end

-- TODO: test
module["datasource.O"] = function (args)
 
  local ds = get_datasource(args.datasource_uuid)
  return tostring( requireNonNil(ds:O(args.candle_index)) )
end

-- TODO: test
module["datasource.H"] = function (args)
 
  local ds = get_datasource(args.datasource_uuid)
  return tostring( requireNonNil(ds:H(args.candle_index)) )
end

-- TODO: test
module["datasource.L"] = function (args)
 
  local ds = get_datasource(args.datasource_uuid)
  return tostring( requireNonNil(ds:L(args.candle_index)) )
end

-- TODO: test
module["datasource.C"] = function (args)
  
  local ds = get_datasource(args.datasource_uuid)
  return tostring( requireNonNil(ds:C(args.candle_index)) )
end

-- TODO: test
module["datasource.V"] = function (args)
 
  local ds = get_datasource(args.datasource_uuid)
  return tostring( requireNonNil(ds:V(args.candle_index)) )
end

-- TODO: test
module["datasource.T"] = function (args) 
  
  local ds = get_datasource(args.datasource_uuid)
  return requireNonNil(ds:T(args.candle_index))
end

-- TODO: test
module["datasource.Size"] = function (args) 
  
  local ds = get_datasource(args.datasource_uuid)
  return requireNonNil(ds:Size())
end

-- TODO: test
module["datasource.Close"] = function (args) 
  
  local ds = get_datasource(args.datasource_uuid)
  return requireNonNil(ds:Close())
end

-- TODO: test
module["datasource.SetEmptyCallback"] = function (args)
  
  local ds = get_datasource(args.datasource_uuid)
  return requireNonNil(ds:SetEmptyCallback())
end

-- TODO: test
module["sendTransaction"] = function (args) 
  -- if ok, returns an empty string
  -- if not ok, returns an error message
  return requireNonNil(_G.sendTransaction(args.transaction))
end

-- TODO: test
module["CalcBuySell"] = function (args) 
  
  local price = tonumber(args.price)
  if price == nil then
    error( string.format("Не удалось преобразовать в число значение '%s' аргумента 'price'.", args.price) ) 
  end
  
  local qty, comission = _G.CalcBuySell(args.class_code, args.sec_code, args.client_code, args.account, price, args.is_buy, args.is_market) -- returns (0; 0) in case of error
  
  if qty == nil then
    error("Целевая QLua-функция возвратила nil вместо значения 'qty'.")
  end
  
  if comission == nil then
    error("Целевая QLua-функция возвратила nil вместо значения 'comission'.")
  end

  return {
    qty = qty,
    comission = tostring(comission)
  }
end

-- TODO: test
module["getParamEx"] = function (args) 
  
  local result = requireNonNil(_G.getParamEx(args.class_code, args.sec_code, args.param_name)) -- always returns a table
  
  --post-processing:
  --result.param_type AS IS
  --result.param_value AS IS
  --result.param_image from CP1251 to UTF8
  --result.result AS IS
  result.param_image = utils.Cp1251ToUtf8(result.param_image)
  
  return result
end

-- TODO: test
module["getParamEx2"] = function (args) 
  
  local result = requireNonNil(_G.getParamEx2(args.class_code, args.sec_code, args.param_name)) -- always returns a table
  
  --post-processing:
  --result.param_type AS IS
  --result.param_value AS IS
  --result.param_image from CP1251 to UTF8
  --result.result AS IS
  result.param_image = utils.Cp1251ToUtf8(result.param_image)
  
  return result
end

-- TODO: test
module["getPortfolioInfo"] = function (args) 

  --no post-processing ?
  --result.is_leverage from CP1251 to UTF8
  --result.in_assets AS IS
  --result.leverage AS IS
  --result.open_limit AS IS
  --result.val_short AS IS
  --result.val_long AS IS
  --result.val_long_margin AS IS
  --result.val_long_asset AS IS
  --result.assets AS IS
  --result.cur_leverage AS IS
  --result.margin AS IS
  --result.lim_all AS IS
  --result.av_lim_all AS IS
  --result.locked_buy AS IS
  --result.locked_buy_margin AS IS
  --result.locked_buy_asset AS IS
  --result.locked_sell AS IS
  --result.locked_value_coef AS IS
  --result.in_all_assets AS IS
  --result.all_assets AS IS
  --result.profit_loss AS IS
  --result.rate_change AS IS
  --result.lim_buy AS IS
  --result.lim_sell AS IS
  --result.lim_non_margin AS IS
  --result.lim_buy_asset AS IS
  --result.val_short_net AS IS
  --result.val_long_net AS IS
  --result.total_money_bal AS IS
  --result.total_locked_money AS IS
  --result.haircuts AS IS
  --result.assets_without_hc AS IS
  --result.status_coef AS IS
  --result.varmargin AS IS
  --result.go_for_positions AS IS
  --result.go_for_orders AS IS
  --result.rate_futures AS IS
  --result.is_qual_client AS IS
  --result.is_futures AS IS
  --result.curr_tag AS IS

  local result = requireNonNil(_G.getPortfolioInfo(args.firm_id, args.client_code)) -- returns {} in case of error

  result.is_leverage = utils.Cp1251ToUtf8(result.is_leverage)
  result.in_assets = result.in_assets
  result.leverage = result.leverage
  result.open_limit = result.open_limit
  result.val_short = result.val_short
  result.val_long = result.val_long
  result.val_long_margin = result.val_long_margin
  result.val_long_asset = result.val_long_asset
  result.assets = result.assets
  result.cur_leverage = result.cur_leverage
  result.margin = result.margin
  result.lim_all = result.lim_all
  result.av_lim_all = result.av_lim_all
  result.locked_buy = result.locked_buy
  result.locked_buy_margin = result.locked_buy_margin
  result.locked_buy_asset = result.locked_buy_asset
  result.locked_sell = result.locked_sell
  result.locked_value_coef = result.locked_value_coef
  result.in_all_assets = result.in_all_assets
  result.all_assets = result.all_assets
  result.profit_loss = result.profit_loss
  result.rate_change = result.rate_change
  result.lim_buy = result.lim_buy
  result.lim_sell = result.lim_sell
  result.lim_non_margin = result.lim_non_margin
  result.lim_buy_asset = result.lim_buy_asset
  result.val_short_net = result.val_short_net
  result.val_long_net = result.val_long_net
  result.total_money_bal = result.total_money_bal
  result.total_locked_money = result.total_locked_money
  result.haircuts = result.haircuts
  result.assets_without_hc = result.assets_without_hc
  result.status_coef = result.status_coef
  result.varmargin = result.varmargin
  result.go_for_positions = result.go_for_positions
  result.go_for_orders = result.go_for_orders
  result.rate_futures = result.rate_futures
  result.is_qual_client = result.is_qual_client
  result.is_futures = result.is_futures
  result.curr_tag = result.curr_tag

  return result
end

-- TODO: test
module["getPortfolioInfoEx"] = function (args) 

  --no post-processing ?
  --params from PortfolioInfo AS IS (except is_leverage)
  --result.init_margin AS IS
  --result.min_margin AS IS
  --result.corrected_margin AS IS
  --result.client_type AS IS
  --result.portfolio_value AS IS
  --result.start_limit_open_pos AS IS
  --result.total_limit_open_pos AS IS
  --result.limit_open_pos AS IS
  --result.used_lim_open_pos AS IS
  --result.acc_var_margin AS IS
  --result.cl_var_margin AS IS
  --result.opt_liquid_cost AS IS
  --result.fut_asset AS IS
  --result.fut_total_asset AS IS
  --result.fut_debt AS IS
  --result.fut_rate_asset AS IS
  --result.fut_rate_asset_open AS IS
  --result.fut_rate_go AS IS
  --result.planed_rate_go AS IS
  --result.cash_leverage AS IS
  --result.fut_position_type AS IS
  --result.fut_accured_int AS IS
  
  local portfolio_info_ex = requireNonNil(_G.getPortfolioInfoEx(args.firm_id, args.client_code, args.limit_kind)) -- returns {} in case of error
  
  local result = {portfolio_info = {}, ex = {}}
  
  result.portfolio_info.is_leverage = utils.Cp1251ToUtf8(portfolio_info_ex.is_leverage)
  result.portfolio_info.in_assets = portfolio_info_ex.in_assets
  result.portfolio_info.leverage = portfolio_info_ex.leverage
  result.portfolio_info.open_limit = portfolio_info_ex.open_limit
  result.portfolio_info.val_short = portfolio_info_ex.val_short
  result.portfolio_info.val_long = portfolio_info_ex.val_long
  result.portfolio_info.val_long_margin = portfolio_info_ex.val_long_margin
  result.portfolio_info.val_long_asset = portfolio_info_ex.val_long_asset
  result.portfolio_info.assets = portfolio_info_ex.assets
  result.portfolio_info.cur_leverage = portfolio_info_ex.cur_leverage
  result.portfolio_info.margin = portfolio_info_ex.margin
  result.portfolio_info.lim_all = portfolio_info_ex.lim_all
  result.portfolio_info.av_lim_all = portfolio_info_ex.av_lim_all
  result.portfolio_info.locked_buy = portfolio_info_ex.locked_buy
  result.portfolio_info.locked_buy_margin = portfolio_info_ex.locked_buy_margin
  result.portfolio_info.locked_buy_asset = portfolio_info_ex.locked_buy_asset
  result.portfolio_info.locked_sell = portfolio_info_ex.locked_sell
  result.portfolio_info.locked_value_coef = portfolio_info_ex.locked_value_coef
  result.portfolio_info.in_all_assets = portfolio_info_ex.in_all_assets
  result.portfolio_info.all_assets = portfolio_info_ex.all_assets
  result.portfolio_info.profit_loss = portfolio_info_ex.profit_loss
  result.portfolio_info.rate_change = portfolio_info_ex.rate_change
  result.portfolio_info.lim_buy = portfolio_info_ex.lim_buy
  result.portfolio_info.lim_sell = portfolio_info_ex.lim_sell
  result.portfolio_info.lim_non_margin = portfolio_info_ex.lim_non_margin
  result.portfolio_info.lim_buy_asset = portfolio_info_ex.lim_buy_asset
  result.portfolio_info.val_short_net = portfolio_info_ex.val_short_net
  result.portfolio_info.val_long_net = portfolio_info_ex.val_long_net
  result.portfolio_info.total_money_bal = portfolio_info_ex.total_money_bal
  result.portfolio_info.total_locked_money = portfolio_info_ex.total_locked_money
  result.portfolio_info.haircuts = portfolio_info_ex.haircuts
  result.portfolio_info.assets_without_hc = portfolio_info_ex.assets_without_hc
  result.portfolio_info.status_coef = portfolio_info_ex.status_coef
  result.portfolio_info.varmargin = portfolio_info_ex.varmargin
  result.portfolio_info.go_for_positions = portfolio_info_ex.go_for_positions
  result.portfolio_info.go_for_orders = portfolio_info_ex.go_for_orders
  result.portfolio_info.rate_futures = portfolio_info_ex.rate_futures
  result.portfolio_info.is_qual_client = portfolio_info_ex.is_qual_client
  result.portfolio_info.is_futures = portfolio_info_ex.is_futures
  result.portfolio_info.curr_tag = portfolio_info_ex.curr_tag
  
  result.ex.init_margin = portfolio_info_ex.init_margin
  result.ex.min_margin = portfolio_info_ex.min_margin
  result.ex.corrected_margin = portfolio_info_ex.corrected_margin
  result.ex.client_type = portfolio_info_ex.client_type
  result.ex.portfolio_value = portfolio_info_ex.portfolio_value
  result.ex.start_limit_open_pos = portfolio_info_ex.start_limit_open_pos
  result.ex.total_limit_open_pos = portfolio_info_ex.total_limit_open_pos
  result.ex.limit_open_pos = portfolio_info_ex.limit_open_pos
  result.ex.used_lim_open_pos = portfolio_info_ex.used_lim_open_pos
  result.ex.acc_var_margin = portfolio_info_ex.acc_var_margin
  result.ex.cl_var_margin = portfolio_info_ex.cl_var_margin
  result.ex.opt_liquid_cost = portfolio_info_ex.opt_liquid_cost
  result.ex.fut_asset = portfolio_info_ex.fut_asset
  result.ex.fut_total_asset = portfolio_info_ex.fut_total_asset
  result.ex.fut_debt = portfolio_info_ex.fut_debt
  result.ex.fut_rate_asset = portfolio_info_ex.fut_rate_asset
  result.ex.fut_rate_asset_open = portfolio_info_ex.fut_rate_asset_open
  result.ex.fut_rate_go = portfolio_info_ex.fut_rate_go
  result.ex.planed_rate_go = portfolio_info_ex.planed_rate_go
  result.ex.cash_leverage = portfolio_info_ex.cash_leverage
  result.ex.fut_position_type = portfolio_info_ex.fut_position_type
  result.ex.fut_accured_int = portfolio_info_ex.fut_accured_int
  
  return result
end

-- TODO: test
module["getBuySellInfo"] = function (args) 

  local price = tonumber(args.price)
  if not price then 
    error( string.format("Не удалось преобразовать в число значение '%s' аргумента 'price'.", args.price) )
  end
  
  -- returns {} in case of error
  return requireNonNil(_G.getBuySellInfo(args.firm_id, args.client_code, args.class_code, args.sec_code, price))

  --post-processing of properties:
  --result.is_margin_sec AS IS
  --result.is_asset_sec AS IS
  --result.balance AS IS
  --result.can_buy AS IS
  --result.can_sell AS IS
  --result.position_valuation AS IS
  --result.value AS IS
  --result.open_value AS IS
  --result.lim_long AS IS
  --result.long_coef AS IS
  --result.lim_short AS IS
  --result.short_coef AS IS
  --result.value_coef AS IS
  --result.open_value_coef AS IS
  --result.share AS IS
  --result.short_wa_price AS IS
  --result.long_wa_price AS IS
  --result.profit_loss AS IS
  --result.spread_hc AS IS
  --result.can_buy_own AS IS
  --result.can_sell_own AS IS
end

-- TODO: test
module["getBuySellInfoEx"] = function (args) 
  
  local price = tonumber(args.price)
  if not price then 
    error( string.format("Не удалось преобразовать в число значение '%s' аргумента 'price'.", args.price) )
  end
  
  -- returns {} in case of error
  local result = requireNonNil(_G.getBuySellInfoEx(args.firm_id, args.client_code, args.class_code, args.sec_code, price))
  
  local buy_sell_info_ex = {
    buy_sell_info = {}
  }
  buy_sell_info_ex.buy_sell_info.is_margin_sec = result.is_margin_sec
  buy_sell_info_ex.buy_sell_info.is_asset_sec = result.is_asset_sec
  buy_sell_info_ex.buy_sell_info.balance = result.balance
  buy_sell_info_ex.buy_sell_info.can_buy = result.can_buy
  buy_sell_info_ex.buy_sell_info.can_sell = result.can_sell
  buy_sell_info_ex.buy_sell_info.position_valuation = result.position_valuation
  buy_sell_info_ex.buy_sell_info.value = result.value
  buy_sell_info_ex.buy_sell_info.open_value = result.open_value
  buy_sell_info_ex.buy_sell_info.lim_long = result.lim_long
  buy_sell_info_ex.buy_sell_info.long_coef = result.long_coef
  buy_sell_info_ex.buy_sell_info.lim_short = result.lim_short
  buy_sell_info_ex.buy_sell_info.short_coef = result.short_coef
  buy_sell_info_ex.buy_sell_info.value_coef = result.value_coef
  buy_sell_info_ex.buy_sell_info.open_value_coef = result.open_value_coef
  buy_sell_info_ex.buy_sell_info.share = result.share
  buy_sell_info_ex.buy_sell_info.short_wa_price = result.short_wa_price
  buy_sell_info_ex.buy_sell_info.long_wa_price = result.long_wa_price
  buy_sell_info_ex.buy_sell_info.profit_loss = result.profit_loss
  buy_sell_info_ex.buy_sell_info.spread_hc = result.spread_hc
  buy_sell_info_ex.buy_sell_info.can_buy_own = result.can_buy_own
  buy_sell_info_ex.buy_sell_info.can_sell_own = result.can_sell_own
  
  if result.limit_kind then buy_sell_info_ex.limit_kind = tostring(result.limit_kind) end
  buy_sell_info_ex.limit_kind = result.limit_kind
  buy_sell_info_ex.d_long = result.d_long
  buy_sell_info_ex.d_min_long = result.d_min_long
  buy_sell_info_ex.d_short = result.d_short
  buy_sell_info_ex.d_min_short = result.d_min_short
  buy_sell_info_ex.client_type = result.client_type
  buy_sell_info_ex.is_long_allowed = result.is_long_allowed
  buy_sell_info_ex.is_short_allowed = result.is_short_allowed
  
  return buy_sell_info_ex
end

-- TODO: test
module["AddColumn"] = function (args) 
  -- returns 0 or 1
  return requireNonNil(_G.AddColumn(args.t_id, args.icode, args.name, args.is_default, utils.to_qtable_parameter_type(args.par_type), args.width)) 
end

-- TODO: test
module["AllocTable"] = function ()
  -- returns a number
  return requireNonNil(_G.AllocTable())
end

-- TODO: test
module["Clear"] = function (args)
  -- returns true or false
  return requireNonNil(_G.Clear(args.t_id))
end

-- TODO: test
module["CreateWindow"] = function (args)
  -- returns 0 or 1
  return requireNonNil(_G.CreateWindow(args.t_id))
end

-- TODO: test
module["DeleteRow"] = function (args)
  -- returns true or false
  return requireNonNil(_G.DeleteRow(args.t_id, args.key))
end

-- TODO: test
module["DestroyTable"] = function (args)
  -- returns true or false
  return requireNonNil(_G.DestroyTable(args.t_id))
end

-- TODO: test
module["InsertRow"] = function (args) 
  -- returns a number
  return requireNonNil(_G.InsertRow(args.t_id, args.key))
end

-- TODO: test
module["IsWindowClosed"] = function (args)
  -- returns nil in case of error
  return _G.IsWindowClosed(args.t_id)
end

-- TODO: test
module["GetCell"] = function (args) 

  -- returns nil in case of error
  local result = _G.GetCell(args.t_id, args.key, args.code)
  
  -- post-processing: stringification of decimal numbers
  if result and result.value then
    result.value = tostring(result.value)
  end
  
  return result
end

-- TODO: test
module["GetTableSize"] = function (args) 

  local rows, col = _G.GetTableSize(args.t_id) -- returns nil in case of error
  
  if rows == nil or col == nil then
    return nil
  end
  
  return {
    rows = rows,
    col = col
  }
end

-- TODO: test
module["GetWindowCaption"] = function (args)
  local window_caption = _G.GetWindowCaption(args.t_id)
  return window_caption and utils.Cp1251ToUtf8(window_caption)
end

-- TODO: test
module["GetWindowRect"] = function (args) 

  local top, left, bottom, right = _G.GetWindowRect(args.t_id) -- returns nil in case of error
  
  if top == nil or left == nil or bottom == nil or right == nil then
    return nil
  end

  return {
    top = top, 
    left = left, 
    bottom = bottom, 
    right = right
  }
end

-- TODO: test
module["SetCell"] = function (args) 
  
  if args.value then
    if args.value == "" then
      args.value = nil
    else
      args.value = assert(tonumber(args.value), "Не удалось распарсить число из аргумента 'value'.")
    end
  end
  
  -- returns true or false
  return requireNonNil(_G.SetCell(args.t_id, args.key, args.code, args.text, args.value))
end

-- TODO: test
module["SetWindowCaption"] = function (args) 
  -- returns true or false
  return requireNonNil(_G.SetWindowCaption(args.t_id, args.str))
end

-- TODO: test
module["SetWindowPos"] = function (args) 
  -- returns true or false
  return requireNonNil(_G.SetWindowPos(args.t_id, args.x, args.y, args.dx, args.dy))
end

-- TODO: test
module["SetTableNotificationCallback"] = function (args) 
  
  local f_cb_ctr, error_msg = loadstring("return "..args.f_cb_def)
  
  if f_cb_ctr == nil then 
    error( string.format("Не удалось распарсить определение функции обратного вызова из переданной строки. Описание ошибки: [%s].", error_msg) )
  end
  
  -- returns 0 or 1
  return requireNonNil(_G.SetTableNotificationCallback(args.t_id, f_cb_ctr()))
end

-- TODO: test
module["RGB"] = function (args) 
  -- NB: на самом деле, библиотечная функция RGB должна называться BGR, ибо она выдаёт числа именно в этом формате. В SetColor, однако, тоже ожидается цвет в формате BGR, так что это не баг, а фича.
  -- returns a number
  return requireNonNil(_G.RGB(args.red, args.green, args.blue))
end

-- TODO: test
module["SetColor"] = function (args) 
  
  -- What does it return in case of error? I hope not nil...
  return requireNonNil(
    _G.SetColor(
        args.t_id, 
        args.row and args.row or _G.QTABLE_NO_INDEX, 
        args.col and args.col or _G.QTABLE_NO_INDEX, 
        args.b_color and args.b_color or _G.QTABLE_DEFAULT_COLOR, 
        args.f_color and args.f_color or _G.QTABLE_DEFAULT_COLOR, 
        args.sel_b_color and args.sel_b_color or _G.QTABLE_DEFAULT_COLOR, 
        args.sel_f_color and args.sel_f_color or _G.QTABLE_DEFAULT_COLOR
      )
    )
end

-- TODO: test
module["Highlight"] = function (args) 
  
  -- What does it return in case of error?
  return requireNonNil(
    _G.Highlight(
        args.t_id, 
        args.row and args.row or _G.QTABLE_NO_INDEX, 
        args.col and args.col or _G.QTABLE_NO_INDEX, 
        args.b_color and args.b_color or _G.QTABLE_DEFAULT_COLOR, 
        args.f_color and args.f_color or _G.QTABLE_DEFAULT_COLOR, 
        args.timeout
      )
    )
end

-- TODO: test
module["SetSelectedRow"] = function (args) 
  -- returns -1 in case of error
  return requireNonNil(_G.SetSelectedRow(args.table_id, args.row and args.row or -1))
end

-- TODO: test
module["AddLabel"] = function (args)
  
  local label_params = args.label_params
  
  -- TODO: this does not cover all future additional parameters...
  if not label_params.TEXT then label_params.TEXT = "" end
  if not label_params.IMAGE_PATH then label_params.IMAGE_PATH = "" end
  if label_params.YVALUE then label_params.YVALUE = tonumber(label_params.YVALUE) end
  if label_params.DATE then label_params.DATE = tonumber(label_params.DATE) end
  if label_params.TIME then label_params.TIME = tonumber(label_params.TIME) end
  if label_params.R then label_params.R = tonumber(label_params.R) end
  if label_params.G then label_params.G = tonumber(label_params.G) end
  if label_params.B then label_params.B = tonumber(label_params.B) end
  if label_params.TRANSPARENCY then label_params.TRANSPARENCY = tonumber(label_params.TRANSPARENCY) end
  if label_params.TRANSPARENT_BACKGROUND then label_params.TRANSPARENT_BACKGROUND = tonumber(label_params.TRANSPARENT_BACKGROUND) end
  if label_params.FONT_HEIGHT then label_params.FONT_HEIGHT = tonumber(label_params.FONT_HEIGHT) end

  -- returns nil in case of error
  return _G.AddLabel(args.chart_tag, args.label_params)
end

-- TODO: test
module["DelLabel"] = function (args)
  -- returns true or false
  return requireNonNil(_G.DelLabel(args.chart_tag, args.label_id))
end

-- TODO: test
module["DelAllLabels"] = function (args)
  -- returns true or false
  return requireNonNil(_G.DelAllLabels(args.chart_tag))
end

-- TODO: test
module["GetLabelParams"] = function (args) 
  
  local label_params = _G.GetLabelParams(args.chart_tag, args.label_id) -- returns nil in case of error
  if label_params then
    local result = {}
    for k, v in pairs(label_params) do
      result[utils.Cp1251ToUtf8( tostring(k) )] = utils.Cp1251ToUtf8( tostring(v) )
    end
    return result
  end
  
  return nil
end

-- TODO: test
module["SetLabelParams"] = function (args)
  -- returns true or false
  return requireNonNil(_G.SetLabelParams(args.chart_tag, args.label_id, args.label_params))
end

-- TODO: test
module["Subscribe_Level_II_Quotes"] = function (args)
  -- returns true or false
  return requireNonNil(_G.Subscribe_Level_II_Quotes(args.class_code, args.sec_code))
end

-- TODO: test
module["Unsubscribe_Level_II_Quotes"] = function (args)
  -- returns true or false
  return requireNonNil(_G.Unsubscribe_Level_II_Quotes(args.class_code, args.sec_code))
end

-- TODO: test
module["IsSubscribed_Level_II_Quotes"] = function (args)
  -- returns true or false
  return requireNonNil(_G.IsSubscribed_Level_II_Quotes(args.class_code, args.sec_code))
end

-- TODO: test
module["ParamRequest"] = function (args) 
  -- returns true or false
  return requireNonNil(_G.ParamRequest(args.class_code, args.sec_code, args.db_name))
end

-- TODO: test
module["CancelParamRequest"] = function (args)
  -- returns true or false
  return requireNonNil(_G.CancelParamRequest(args.class_code, args.sec_code, args.db_name))
end

-- TODO: test
module["bit.tohex"] = function (args)
  return requireNonNil( bit.tohex(args.x, args.n or nil) )
end

-- TODO: test
module["bit.bnot"] = function (args) 
  return requireNonNil( bit.bnot(args.x) )
end

-- TODO: test
module["bit.band"] = function (args) 
  return requireNonNil( bit.band(args.x1, args.x2, args.xi and unpack(args.xi) or nil) )
end

-- TODO: test
module["bit.bor"] = function (args) 
  return requireNonNil( bit.bor(args.x1, args.x2, args.xi and unpack(args.xi) or nil) )
end

-- TODO: test
module["bit.bxor"] = function (args) 
  return requireNonNil( bit.bxor(args.x1, args.x2, args.xi and unpack(args.xi) or nil) )
end

-- TODO: test
module["bit.test"] = function (args) 
  return requireNonNil( bit.test(args.x, args.n) )
end

-----

return module
