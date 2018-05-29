-- Lua functions
local error = assert(error, "Функция 'error' не найдена.")
local string = assert(string, "Taблица 'string' не найдена.")
local pcall = assert(pcall, "Функция 'pcall' не найдена.")
local pairs = assert(pairs, "Функция 'pairs' не найдена.")
local tostring = assert(tostring, "Функция 'tostring' не найдена.")
local loadstring = assert(loadstring, "Функция 'loadstring' не найдена.")

-- QLua functions
assert(_G.isConnected, "Функция 'isConnected' не найдена.")
assert(_G.getScriptPath, "Функция 'getScriptPath' не найдена.")
assert(_G.getInfoParam, "Функция 'getInfoParam' не найдена.")
assert(_G.getItem, "Функция 'getItem' не найдена.")
assert(_G.message, "Функция 'message' не найдена.")
assert(_G.sleep, "Функция 'sleep' не найдена.")
assert(_G.getWorkingFolder, "Функция 'getWorkingFolder' не найдена.")
assert(_G.PrintDbgStr, "Функция 'PrintDbgStr' не найдена.")
assert(_G.getOrderByNumber, "Функция 'getOrderByNumber' не найдена.")
assert(_G.getNumberOf, "Функция 'getNumberOf' не найдена.")
assert(_G.SearchItems, "Функция 'SearchItems' не найдена.")

-- Utility modules and functions
local utils = require("utils.utils")
local value_or_empty_string = assert(utils.value_or_empty_string, "Функция 'value_or_empty_string' не найдена в модуле 'utils.utils'.")
local uuid = require("utils.uuid")

-----
-- The DataSources in-memory storage. 
-- Warning: the storage may cause memory leaks if the datasources that aren't needed anymore have not been explicitly closed by the clients, 
-- because the datasources' objects would never be eligible for garbage collection (whereas in a local script they are as soon as the script exits the main function).
local datasources = {}
local function get_datasource (datasource_uid)
  return assert(datasources[datasource_uid], string.format("DataSource c uuid='%s' не найден.", datasource_uid))
end

-----

local function to_string_string_table (t)
  
  local result = {}
  for k, v in pairs(t) do
    result[utils.Cp1251ToUtf8(tostring(k))] = utils.Cp1251ToUtf8(tostring(v))
  end
  
  return result
end

-----

local module = {}

-- TODO: test
module["isConnected"] = function ()
  return _G.isConnected()
end

-- TODO: test
module["getScriptPath"] = function ()
  return _G.getScriptPath()
end

-- TODO: test
module["getInfoParam"] = function (args)
  return _G.getInfoParam(args.param_name)
end

module["message"] = function (args)
  
  local proc_result = _G.message(utils.Utf8ToCp1251(args.message), args.icon_type)
  
  if proc_result == nil then
    if args.icon_type == nil then 
      error( string.format("QLua-функция message(%s) возвратила nil.", args.message) )
    else
      error( string.format("QLua-функция message(%s, %d) возвратила nil.", args.message, args.icon_type) )
    end
  end
  
  return proc_result
end

-- TODO: test
module["sleep"] = function (args) 
  
  local proc_result = _G.sleep(args.time)
  
  if proc_result == nil then
    error( string.format("QLua-функция sleep(%d) возвратила nil.", args.time) )
  end
  
  return proc_result
end

-- TODO: test
module["getWorkingFolder"] = _G.getWorkingFolder

-- TODO: test
module["PrintDbgStr"] = function (args) 
  
  _G.PrintDbgStr(args.s)
  
  return nil
end

-- TODO: test
module["getItem"] = function (args) 
  
  local proc_result = _G.getItem(args.table_name, args.index)
  
  return to_string_string_table(proc_result)
end

-- TODO: test
module["getOrderByNumber"] = function (args) 
  
  local order, indx = _G.getOrderByNumber(args.class_code, args.order_id)
  
  if order then
    assert(order.order_num, "Функция getOrderByNumber: таблица 'order' не содержит обязательного поля 'order_num'.")
    assert(order.flags, "Функция getOrderByNumber: таблица 'order' не содержит обязательного поля 'flags'.")
    order.brokerref = utils.Cp1251ToUtf8(order.brokerref)
    order.userid = utils.Cp1251ToUtf8(order.userid)
    order.firmid = utils.Cp1251ToUtf8(order.firmid)
    order.account = utils.Cp1251ToUtf8(order.account)
    order.price = tostring( assert(order.price, "Функция getOrderByNumber: таблица 'order' не содержит обязательного поля 'price'.") )
    assert(order.qty, "Функция getOrderByNumber: таблица 'order' не содержит обязательного поля 'qty'.")
    if order.balance then order.balance = tostring(order.balance) end
    order.value = tostring( assert(order.value, "Функция getOrderByNumber: таблица 'order' не содержит обязательного поля 'value'.") )
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
    assert(order.sec_code, "Функция getOrderByNumber: таблица 'order' не содержит обязательного поля 'sec_code'.")
    assert(order.class_code, "Функция getOrderByNumber: таблица 'order' не содержит обязательного поля 'class_code'.")
    assert(order.datetime, "Функция getOrderByNumber: таблица 'order' не содержит обязательного поля 'datetime'.")
    order.bank_acc_id = utils.Cp1251ToUtf8(order.bank_acc_id)
    assert(order.value_entry_type, "Функция getOrderByNumber: таблица 'order' не содержит обязательного поля 'value_entry_type'.")
    if order.repoterm then order.repoterm = tostring(order.repoterm) end
    if order.repovalue then order.repovalue = tostring(order.repovalue) end
    if order.repo2value then order.repo2value = tostring(order.repo2value) end
    if order.repo_value_balance then order.repo_value_balance = tostring(order.repo_value_balance) end
    if order.start_discount then order.start_discount = tostring(order.start_discount) end
    order.reject_reason = utils.Cp1251ToUtf8(order.reject_reason)
    if order.ext_order_flags then order.ext_order_flags = tostring(order.ext_order_flags) end
    assert(order.min_qty, "Функция getOrderByNumber: таблица 'order' не содержит обязательного поля 'min_qty'.")
    assert(order.exec_type, "Функция getOrderByNumber: таблица 'order' не содержит обязательного поля 'exec_type'.")
    assert(order.side_qualifier, "Функция getOrderByNumber: таблица 'order' не содержит обязательного поля 'side_qualifier'.")
    assert(order.acnt_type, "Функция getOrderByNumber: таблица 'order' не содержит обязательного поля 'acnt_type'.")
    assert(order.capacity, "Функция getOrderByNumber: таблица 'order' не содержит обязательного поля 'capacity'.")
    assert(order.passive_only_order, "Функция getOrderByNumber: таблица 'order' не содержит обязательного поля 'passive_only_order'.")
    assert(order.visible, "Функция getOrderByNumber: таблица 'order' не содержит обязательного поля 'visible'.")
    
    return {
      order = order,
      indx = indx
    }
  else
    return nil
  end
end

-- TODO: test
module["getNumberOf"] = function (args) 
  return _G.getNumberOf(args.table_name) -- returns -1 in case of error
end

-- TODO: test
module["SearchItems"] = function (args) 
  
  local fn_ctr, error_msg = loadstring("return "..args.fn_def)
  local result
  if fn_ctr == nil then 
    error(string.format("Функция SearchItems: не удалось распарсить определение функции из переданной строки. Описание ошибки: [%s].", error_msg))
  else
    if not args.params or args.params == "" then
      result = _G.SearchItems(args.table_name, args.start_index, args.end_index == 0 and (_G.getNumberOf(args.table_name) - 1) or args.end_index, fn_ctr()) -- returns nil in case of empty list found or error
    else 
      result = _G.SearchItems(args.table_name, args.start_index, args.end_index == 0 and (_G.getNumberOf(args.table_name) - 1) or args.end_index, fn_ctr(), args.params) -- returns nil in case of empty list found or error
    end
  end
  
  return result
end

-- TODO: test
module["getClassesList"] = function () 
  return _G.getClassesList()
end

-- TODO: test
module["getClassInfo"] = function (args) 
  
  local result = _G.getClassInfo(args.class_code)
  
  if result == nil then
    error( string.format("QLua-функция getClassInfo(%s) возвратила nil.", args.class_code) )
  end
  
  return result
end

-- TODO: test
module["getClassSecurities"] = function (args) 
  return _G.getClassSecurities(args.class_code) -- returns an empty string if no securities found for the given class_code
end

-- TODO: test
module["getMoney"] = function (args) 
  
  local result = _G.getMoney(args.client_code, args.firmid, args.tag, args.currcode) -- returns a table with zero'ed values if no info found or in case of error
  
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
  
  local result = _G.getMoneyEx(args.firmid, args.client_code, args.tag, args.currcode, args.limit_kind) -- returns nil if no info found or in case of an error
  
  if result == nil then 
    error( string.format("QLua-функция getMoneyEx(%s, %s, %s, %s, %d) возвратила nil.", args.firmid, args.client_code, args.tag, args.currcode, args.limit_kind) )
  end
  
  result.currcode = utils.Cp1251ToUtf8( assert(result.currcode, "Функция getMoneyEx: результирующая таблица не содержит обязательного поля 'currcode'.") )
  result.tag = utils.Cp1251ToUtf8( assert(result.tag, "Функция getMoneyEx: результирующая таблица не содержит обязательного поля 'tag'.") )
  result.firmid = utils.Cp1251ToUtf8( assert(result.firmid, "Функция getMoneyEx: результирующая таблица не содержит обязательного поля 'firmid'.") )
  result.client_code = utils.Cp1251ToUtf8( assert(result.client_code, "Функция getMoneyEx: результирующая таблица не содержит обязательного поля 'client_code'.") )
  if result.openbal then result.openbal = tostring(result.openbal) end
  if result.openlimit then result.openlimit = tostring(result.openlimit) end
  if result.currentbal then result.currentbal = tostring(result.currentbal) end
  if result.currentlimit then result.currentlimit = tostring(result.currentlimit) end
  if result.locked then result.locked = tostring(result.locked) end
  if result.locked_value_coef then result.locked_value_coef = tostring(result.locked_value_coef) end
  if result.locked_margin_value then result.locked_margin_value = tostring(result.locked_margin_value) end
  if result.leverage then result.leverage = tostring(result.leverage) end
  assert(result.limit_kind, "Функция getMoneyEx: результирующая таблица не содержит обязательного поля 'limit_kind'.")

  return result
end

-- TODO: test
module["getDepo"] = function (args) 
  
  local result = _G.getDepo(args.client_code, args.firmid, args.sec_code, args.trdaccid) -- returns a table with zero'ed values if no info found or in case of an error

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

  local result = _G.getDepoEx(args.firmid, args.client_code, args.sec_code, args.trdaccid, args.limit_kind) -- returns nil if no info found or in case of an error
  
  if result == nil then
    error( string.format("QLua-функция getDepoEx(%s, %s, %s, %s, %d) возвратила nil.", args.firmid, args.client_code, args.sec_code, args.trdaccid, args.limit_kind) )
  end
  
  result.sec_code = utils.Cp1251ToUtf8( assert(result.sec_code, "Функция getDepoEx: результирующая таблица не содержит обязательного поля 'sec_code'.") )
  result.trdaccid = utils.Cp1251ToUtf8( assert(result.trdaccid, "Функция getDepoEx: результирующая таблица не содержит обязательного поля 'trdaccid'.") )
  result.firmid = utils.Cp1251ToUtf8( assert(result.firmid, "Функция getDepoEx: результирующая таблица не содержит обязательного поля 'firmid'.") )
  result.client_code = utils.Cp1251ToUtf8( assert(result.client_code, "Функция getDepoEx: результирующая таблица не содержит обязательного поля 'client_code'.") )
  assert(result.openbal, "Функция getDepoEx: результирующая таблица не содержит обязательного поля 'openbal'.")
  assert(result.openlimit, "Функция getDepoEx: результирующая таблица не содержит обязательного поля 'openlimit'.")
  assert(result.currentbal, "Функция getDepoEx: результирующая таблица не содержит обязательного поля 'currentbal'.")
  assert(result.currentlimit, "Функция getDepoEx: результирующая таблица не содержит обязательного поля 'currentlimit'.")
  assert(result.locked_sell, "Функция getDepoEx: результирующая таблица не содержит обязательного поля 'locked_sell'.")
  assert(result.locked_buy, "Функция getDepoEx: результирующая таблица не содержит обязательного поля 'locked_buy'.")
  result.locked_buy_value = tostring( assert(result.locked_buy_value, "Функция getDepoEx: результирующая таблица не содержит обязательного поля 'locked_buy_value'.") )
  result.locked_sell_value = tostring( assert(result.locked_sell_value, "Функция getDepoEx: результирующая таблица не содержит обязательного поля 'locked_sell_value'.") )
  result.awg_position_price = tostring( assert(result.awg_position_price, "Функция getDepoEx: результирующая таблица не содержит обязательного поля 'awg_position_price'.") )
  assert(result.limit_kind, "Функция getDepoEx: результирующая таблица не содержит обязательного поля 'limit_kind'.")
    
  return result
end

-- TODO: test
module["getFuturesLimit"] = function (args) 

  local result = _G.getFuturesLimit(args.firmid, args.trdaccid, args.limit_type, args.currcode) -- returns nil if no info found or in case of an error
  
  if result == nil then
    error( string.format("QLua-функция getFuturesLimit(%s, %s, %d, %s) возвратила nil.", args.firmid, args.trdaccid, args.limit_type, args.currcode) )
  end
  
  result.firmid = utils.Cp1251ToUtf8( assert(result.firmid, "Функция getFuturesLimit: результирующая таблица не содержит обязательного поля 'firmid'.") )
  result.trdaccid = utils.Cp1251ToUtf8( assert(result.trdaccid, "Функция getFuturesLimit: результирующая таблица не содержит обязательного поля 'trdaccid'.") )
  assert(result.limit_type, "Функция getFuturesLimit: результирующая таблица не содержит обязательного поля 'limit_type'.")
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
  result.currcode = utils.Cp1251ToUtf8( assert(result.currcode, "Функция getFuturesLimit: результирующая таблица не содержит обязательного поля 'currcode'.") )
  if result.real_varmargin then result.real_varmargin = tostring(result.real_varmargin) end

  return result
end

-- TODO: test
module["getFuturesHolding"] = function (args) 

  local result = _G.getFuturesHolding(args.firmid, args.trdaccid, args.sec_code, args.type) -- returns nil if no info found or in case of an error
   
  if result == nil then
    error( string.format("QLua-функция getFuturesHolding(%s, %s, %s, %d) возвратила nil.", args.firmid, args.trdaccid, args.sec_code, args.type) )
  end
  
  result.firmid = utils.Cp1251ToUtf8( assert(result.firmid, "Функция getFuturesHolding: результирующая таблица не содержит обязательного поля 'firmid'.") )
  result.trdaccid = utils.Cp1251ToUtf8( assert(result.trdaccid, "Функция getFuturesHolding: результирующая таблица не содержит обязательного поля 'trdaccid'.") )
  assert(result.sec_code, "Функция getFuturesHolding: результирующая таблица не содержит обязательного поля 'sec_code'.")
  assert(result.type, "Функция getFuturesHolding: результирующая таблица не содержит обязательного поля 'type'.")
  if result.startbuy then result.startbuy = tostring(result.startbuy) end
  if result.startsell then result.startsell = tostring(result.startsell) end
  if result.todaybuy then result.todaybuy = tostring(result.todaybuy) end
  if result.todaysell then result.todaysell = tostring(result.todaysell) end
  if result.totalnet then result.totalnet = tostring(result.totalnet) end
  assert(result.openbuys, "Функция getFuturesHolding: результирующая таблица не содержит обязательного поля 'openbuys'.")
  assert(result.opensells, "Функция getFuturesHolding: результирующая таблица не содержит обязательного поля 'opensells'.")
  if result.cbplused then result.cbplused = tostring(result.cbplused) end
  if result.cbplplanned then result.cbplplanned = tostring(result.cbplplanned) end
  if result.varmargin then result.varmargin = tostring(result.varmargin) end
  if result.avrposnprice then result.avrposnprice = tostring(result.avrposnprice) end
  if result.positionvalue then result.positionvalue = tostring(result.positionvalue) end
  if result.real_varmargin then result.real_varmargin = tostring(result.real_varmargin) end
  if result.total_varmargin then result.total_varmargin = tostring(result.total_varmargin) end
  assert(result.session_status, "Функция getFuturesHolding: результирующая таблица не содержит обязательного поля 'session_status'.")

  return result
end

-- TODO: test
module["getSecurityInfo"] = function (args) 

  local result = _G.getSecurityInfo(args.class_code, args.sec_code) -- returns nil if no info found or in case of an error
  
  if result == nil then
    error( string.format("QLua-функция getSecurityInfo(%s, %s) возвратила nil.", args.class_code, args.sec_code) )
  end
  
  assert(result.code, "Функция getSecurityInfo: результирующая таблица не содержит обязательного поля 'code'.")
  result.name = utils.Cp1251ToUtf8(result.name)
  result.short_name = utils.Cp1251ToUtf8(result.short_name)
  result.class_code = utils.Cp1251ToUtf8( assert(result.class_code, "Функция getSecurityInfo: результирующая таблица не содержит обязательного поля 'class_code'.") )
  result.class_name = utils.Cp1251ToUtf8(result.class_name)
  if result.face_value then result.face_value = tostring(result.face_value) end
  result.face_unit = utils.Cp1251ToUtf8(result.face_unit)
  if result.scale then result.scale = tostring(result.scale) end
  if result.mat_date then result.mat_date = tostring(result.mat_date) end
  if result.lot_size then result.lot_size = tostring(result.lot_size) end
  result.isin_code = utils.Cp1251ToUtf8(result.isin_code)
  if result.min_price_step then result.min_price_step = tostring(result.min_price_step) end

  return result
end

-- TODO: test
module["getTradeDate"] = function () 
  
  local result = _G.getTradeDate()
  
  assert(result.date, "Функция getTradeDate: результирующая таблица не содержит обязательного поля 'date'.")
  assert(result.year, "Функция getTradeDate: результирующая таблица не содержит обязательного поля 'year'.")
  assert(result.month, "Функция getTradeDate: результирующая таблица не содержит обязательного поля 'month'.")
  assert(result.day, "Функция getTradeDate: результирующая таблица не содержит обязательного поля 'day'.") 
  
  return result
end

-- TODO: test
module["getQuoteLevel2"] = function (args) 
  
  local result = _G.getQuoteLevel2(args.class_code, args.sec_code)
  
  assert(result.bid_count, "Функция getQuoteLevel2: результирующая таблица не содержит обязательного поля 'bid_count'.")
  assert(result.offer_count, "Функция getQuoteLevel2: результирующая таблица не содержит обязательного поля 'offer_count'.")
  if result.bid == "" then result.bid = nil end
  if result.offer == "" then result.offer = nil end
  
  return result
end

-- TODO: test
module["getLinesCount"] = function (args) 
  return _G.getLinesCount(args.tag) -- returns 0 if no chart with this tag found
end

-- TODO: test
module["getNumCandles"] = function (args) 
  return _G.getNumCandles(args.tag) -- returns 0 if no chart with this tag found
end

-- TODO: test
module["getCandlesByIndex"] = function (args) 
  
  -- just to see that there are three variables in the function's output
  local t, n, l = _G.getCandlesByIndex(args.tag, args.line, args.first_candle, args.count) -- returns ({}, 0, "") if no info found or in case of error
  
  for i, candle in ipairs(t) do
    
      candle.open = tostring(assert(candle.open, string.format("Функция getCandlesByIndex: свеча с индексом %d не содержит обязательного поля 'open'.", i)))
      candle.close = tostring(assert(candle.close, string.format("Функция getCandlesByIndex: свеча с индексом %d не содержит обязательного поля 'close'.", i)))
      candle.high = tostring(assert(candle.high, string.format("Функция getCandlesByIndex: свеча с индексом %d не содержит обязательного поля 'high'.", i)))
      candle.low = tostring(assert(candle.low, string.format("Функция getCandlesByIndex: свеча с индексом %d не содержит обязательного поля 'low'.", i)))
      candle.volume = tostring(assert(candle.volume, string.format("Функция getCandlesByIndex: свеча с индексом %d не содержит обязательного поля 'volume'.", i)))
  end
  
  return {
    t = t,
    n = n,
    l = l
  }
end

-- TODO: test
module["datasource.CreateDataSource"] = function (args) 
  
  assert(args.interval, "Функция datasource.CreateDataSource: аргумент 'interval' не должен быть nil.")
  local interval = assert(_G[args.interval], string.format("Функция datasource.CreateDataSource: QLua-интервал не найден для значения '%s'.", args.interval))
  local ds, error_desc
  if args.param == nil or args.param == "" then
    ds, error_desc = _G.CreateDataSource(args.class_code, args.sec_code, interval)
  else 
    ds, error_desc = _G.CreateDataSource(args.class_code, args.sec_code, interval, args.param)
  end
  
  local result
  if ds then
    local datasource_uuid = assert(uuid(), "Функция datasource.CreateDataSource: не удалось сгенерировать UUID.")
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
  
  local ds = get_datasource(args.datasource_uuid)
  
  local f_cb_ctr, error_msg = loadstring("return "..args.f_cb_def)
  if f_cb_ctr == nil then 
    error( string.format("Функция datasource.SetUpdateCallback: не удалось распарсить определение функции из переданной строки. Описание ошибки: [%s].", error_msg) )
  else
    local f_cb = f_cb_ctr()
    return ds:SetUpdateCallback(function(index) f_cb(index, ds) end)
  end
end

-- TODO: test
module["datasource.O"] = function (args) 
 
  local ds = get_datasource(args.datasource_uuid)
  
  return tostring( ds:O(args.candle_index) )
end

-- TODO: test
module["datasource.H"] = function (args) 
 
  local ds = get_datasource(args.datasource_uuid)
  
  return tostring( ds:H(args.candle_index) )
end

-- TODO: test
module["datasource.L"] = function (args) 
 
  local ds = get_datasource(args.datasource_uuid)
  
  return tostring( ds:L(args.candle_index) )
end

-- TODO: test
module["datasource.C"] = function (args) 
 
  local ds = get_datasource(args.datasource_uuid)
  
  return tostring( ds:C(args.candle_index) )
end

-- TODO: test
module["datasource.V"] = function (args) 
 
  local ds = get_datasource(args.datasource_uuid)
  
  return tostring( ds:V(args.candle_index) )
end

-- TODO: test
module["datasource.T"] = function (args) 
  
  local ds = get_datasource(args.datasource_uuid)

  return ds:T(args.candle_index)
end

-- TODO: test
module["datasource.Size"] = function (args) 
  
  local ds = get_datasource(args.datasource_uuid)

  return ds:Size()
end

-- TODO: test
module["datasource.Close"] = function (args) 
  
  local ds = get_datasource(args.datasource_uuid)
  
  return ds:Close()
end

-- TODO: test
module["datasource.SetEmptyCallback"] = function (args) 
  
  local ds = get_datasource(args.datasource_uuid)

  return ds:SetEmptyCallback()
end

-- TODO: test
module["sendTransaction"] = function (args) 
  return _G.sendTransaction(args.transaction) -- returns an empty string (seems to be always)
end

-- TODO: test
module["CalcBuySell"] = function (args) 
  
  local price = tonumber(args.price)
  if price == nil then
    error( string.format("Функция CalcBuySell: не удалось преобразовать в число значение '%s' аргумента 'price'.", args.price) ) 
  end
  
  local qty, comission = _G.CalcBuySell(args.class_code, args.sec_code, args.client_code, args.account, price, args.is_buy, args.is_market) -- returns (0; 0) in case of error

  return {
    qty = qty,
    comission = tostring(comission)
  }
end

-- TODO: test
module["getParamEx"] = function (args) 
  
  local result = _G.getParamEx(args.class_code, args.sec_code, args.param_name) -- always returns a table
  
  if result == nil then
    error( string.format("QLua-функция getParamEx(%s, %s, %s) возвратила nil.", args.class_code, args.sec_code, args.param_name) )
  end
  
  --result.param_type AS IS
  --result.param_value AS IS
  --result.param_image AS IS
  --result.result AS IS
    
  return result
end

-- TODO: test
module["getParamEx2"] = function (args) 
  
  local result = _G.getParamEx2(args.class_code, args.sec_code, args.param_name) -- always returns a table
  
  if result == nil then
    error(string.format("QLua-функция getParamEx2(%s, %s, %s) возвратила nil.", args.class_code, args.sec_code, args.param_name), 0)
  end
  
  --result.param_type AS IS
  --result.param_value AS IS
  --result.param_image AS IS
  --result.result AS IS

  return result
end

-- TODO: test
module["getPortfolioInfo"] = function (args) 

  local result = _G.getPortfolioInfo(args.firm_id, args.client_code) -- returns {} in case of error
  
  if result == nil then
    error( string.format("QLua-функция getPortfolioInfo(%s, %s) возвратила nil.", args.firm_id, args.client_code) )
  end
  
  --result.is_leverage AS IS
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

  return result
end

-- TODO: test
module["getPortfolioInfoEx"] = function (args) 

  local result = _G.getPortfolioInfoEx(args.firm_id, args.client_code, args.limit_kind) -- returns {} in case of error
  
  if result == nil then
    error( string.format("QLua-функция getPortfolioInfoEx(%s, %s, %d) возвратила nil.", args.firm_id, args.client_code, args.limit_kind) )
  end
  
  --params from PortfolioInfo AS IS
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
  
  return result
end

-- TODO: test
module["getBuySellInfo"] = function (args) 

  local price = tonumber(args.price)
  if price == nil then 
    error( string.format("Функция getBuySellInfo: не удалось преобразовать в число значение '%s' аргумента 'price'.", args.price) )
  end
  
  local result = _G.getBuySellInfo(args.firm_id, args.client_code, args.class_code, args.sec_code, price) -- returns {} in case of error
  if result == nil then
    error( string.format("QLua-функция getBuySellInfo(%s, %s, %s, %s, %s) возвратила nil.", args.firm_id, args.client_code, args.class_code, args.sec_code, args.price) )
  end
  
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
  
  return result
end

-- TODO: test
module["getBuySellInfoEx"] = function (args) 
  
  local price = tonumber(args.price)
  if price == nil then 
    error( string.format("Функция getBuySellInfoEx: не удалось преобразовать в число значение '%s' аргумента 'price'.", args.price) )
  end
  
  local result = _G.getBuySellInfoEx(args.firm_id, args.client_code, args.class_code, args.sec_code, price) -- returns {} in case of error
  if result == nil then
    error( string.format("QLua-функция getBuySellInfoEx(%s, %s, %s, %s, %s) возвратила nil.", args.firm_id, args.client_code, args.class_code, args.sec_code, args.price) )
  end
  
  --params from PortfolioInfo AS IS
  if result.limit_kind then result.limit_kind = tostring(result.limit_kind) end
  --result.d_long AS IS
  --result.d_min_long AS IS
  --result.d_short AS IS
  --result.d_min_short AS IS
  --result.client_type AS IS
  --result.is_long_allowed AS IS
  --result.is_short_allowed AS IS
  
  return result
end

-- TODO: test
module["AddColumn"] = function (args) 
  return _G.AddColumn(args.t_id, args.icode, args.name, args.is_default, utils.to_qtable_parameter_type(args.par_type), args.width) -- returns 0 or 1
end

-- TODO: test
module["AllocTable"] = function () 
  return _G.AllocTable() -- returns a number
end

-- TODO: test
module["Clear"] = function (args) 
  return _G.Clear(args.t_id) -- returns true or false
end

-- TODO: test
module["CreateWindow"] = function (args) 
  return _G.CreateWindow(args.t_id) -- returns 0 or 1
end

-- TODO: test
module["DeleteRow"] = function (args) 
  return _G.DeleteRow(args.t_id, args.key) -- returns true or false
end

-- TODO: test
module["DestroyTable"] = function (args) 
  return _G.DestroyTable(args.t_id) -- returns true or false
end

-- TODO: test
module["InsertRow"] = function (args) 
  return _G.InsertRow(args.t_id, args.key) -- returns a number
end

-- TODO: test
module["IsWindowClosed"] = function (args) 
  
  local result = _G.IsWindowClosed(args.t_id) -- returns nil in case of error
  
  if result == nil then
    error( string.format("QLua-функция IsWindowClosed(%s) возвратила nil.", args.t_id) )
  end
  
  return result
end

-- TODO: test
module["GetCell"] = function (args) 

  local result = _G.GetCell(args.t_id, args.key, args.code) -- returns nil in case of error
  
  if result == nil then
    error( string.format("QLua-функция GetCell(%s, %s, %s) возвратила nil.", args.t_id, args.key, args.code) )
  end
  
  if result.value then result.value = tostring(result.value) end
  
  return result
end

-- TODO: test
module["GetTableSize"] = function (args) 

  local rows, col = _G.GetTableSize(args.t_id) -- returns nil in case of error
  
  if rows == nil or col == nil then
    error( string.format("QLua-функция GetTableSize(%s) возвратила nil.", args.t_id) )
  end
  
  return {
    rows = rows,
    col = col
  }
end

-- TODO: test
module["GetWindowCaption"] = function (args) 

  local result = _G.GetWindowCaption(args.t_id) -- returns nil in case of error
  
  if result == nil then 
    error( string.format("QLua-функция GetWindowCaption(%s) возвратила nil.", args.t_id) )
  end
  
  return utils.Cp1251ToUtf8(result)
end

-- TODO: test
module["GetWindowRect"] = function (args) 

  local top, left, bottom, right = _G.GetWindowRect(args.t_id) -- returns nil in case of error
  
  if top == nil then
    error( string.format("QLua-функция GetWindowRect(%s) возвратила nil вместо параметра 'top'.", args.t_id) )
  end
  
  if left == nil then
    error( string.format("QLua-функция GetWindowRect(%s) возвратила nil вместо параметра 'left'.", args.t_id) )
  end
  
  if bottom == nil then
    error( string.format("QLua-функция GetWindowRect(%s) возвратила nil вместо параметра 'bottom'.", args.t_id) )
  end
  
  if right == nil then
    error( string.format("QLua-функция GetWindowRect(%s) возвратила nil вместо параметра 'right'.", args.t_id) )
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
  
  local result
  if args.value == 0 then
    result = _G.SetCell(args.t_id, args.key, args.code, args.text) -- returns true or false
  else
    result = _G.SetCell(args.t_id, args.key, args.code, args.text, args.value) -- returns true or false
  end
  
  return result
end

-- TODO: test
module["SetWindowCaption"] = function (args) 
  return _G.SetWindowCaption(args.t_id, args.str) -- returns true or false
end

-- TODO: test
module["SetWindowPos"] = function (args) 
  return _G.SetWindowPos(args.t_id, args.x, args.y, args.dx, args.dy) -- returns true or false
end

-- TODO: test
module["SetTableNotificationCallback"] = function (args) 
  
  local f_cb_ctr, error_msg = loadstring("return "..args.f_cb_def)
  
  if f_cb_ctr == nil then 
    error( string.format("Функция SetTableNotificationCallback: не удалось распарсить определение функции из переданной строки. Описание ошибки: [%s].", error_msg) )
  end
  
  return _G.SetTableNotificationCallback(args.t_id, f_cb_ctr()) -- returns 0 or 1
end

-- TODO: test
module["RGB"] = function (args) 
  -- NB: на самом деле, библиотечная функция RGB должна называться BGR, ибо она выдаёт числа именно в этом формате. В SetColor, однако, тоже ожидается цвет в формате BGR, так что это не баг, а фича.
  return _G.RGB(args.red, args.green, args.blue) -- returns a number
end

-- TODO: test
module["SetColor"] = function (args) 
  return _G.SetColor(args.t_id, args.row, args.col, args.b_color, args.f_color, args.sel_b_color, args.sel_f_color) -- what does it return in case of error ?
end

-- TODO: test
module["Highlight"] = function (args) 
  return _G.Highlight(args.t_id, args.row, args.col, args.b_color, args.f_color, args.timeout) -- what does it return in case of error ?
end

-- TODO: test
module["SetSelectedRow"] = function (args) 
  return _G.SetSelectedRow(args.table_id, args.row) -- returns -1 in case of error
end

-- TODO: test
module["AddLabel"] = function (args) 

  local result = _G.AddLabel(args.chart_tag, args.label_params) -- returns nil in case of error
  
  if result == nil then
    error( string.format("QLua-функция AddLabel(%s, %s) возвратила nil.", args.chart_tag, utils.table.tostring(args.label_params)))
  end

  return result
end

-- TODO: test
module["DelLabel"] = function (args) 
  return _G.DelLabel(args.chart_tag, args.label_id) -- returns true or false
end

-- TODO: test
module["DelAllLabels"] = function (args) 
  return _G.DelAllLabels(args.chart_tag) -- returns true or false
end

-- TODO: test
module["GetLabelParams"] = function (args) 
  
  local label_params = _G.GetLabelParams(args.chart_tag, args.label_id) -- returns nil in case of error
  if label_params == nil then
    error( string.format("QLua-функция GetLabelParams(%s, %d) возвратила nil.", args.chart_tag, args.label_id) )
  end
  
  local result = {}
  for k, v in pairs(label_params) do
    result[utils.Cp1251ToUtf8( tostring(k) )] = utils.Cp1251ToUtf8( tostring(v) )
  end
  
  return result
end

-- TODO: test
module["SetLabelParams"] = function (args) 
  return _G.SetLabelParams(args.chart_tag, args.label_id, args.label_params) -- returns true or false
end

-- TODO: test
module["Subscribe_Level_II_Quotes"] = function (args) 
  return _G.Subscribe_Level_II_Quotes(args.class_code, args.sec_code) -- returns true or false
end

-- TODO: test
module["Unsubscribe_Level_II_Quotes"] = function (args) 
  return _G.Unsubscribe_Level_II_Quotes(args.class_code, args.sec_code) -- returns true or false
end

-- TODO: test
module["IsSubscribed_Level_II_Quotes"] = function (args) 
  return _G.IsSubscribed_Level_II_Quotes(args.class_code, args.sec_code) -- returns true or false
end

-- TODO: test
module["ParamRequest"] = function (args) 
  return _G.ParamRequest(args.class_code, args.sec_code, args.db_name) -- returns true or false
end

-- TODO: test
module["CancelParamRequest"] = function (args) 
  return _G.CancelParamRequest(args.class_code, args.sec_code, args.db_name) -- returns true or false
end

-----

return module
