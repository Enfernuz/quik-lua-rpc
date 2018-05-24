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
    error(string.format("Не удалось распарсить определение функции из переданной строки. Описание ошибки: %s.", error_msg))
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

-----

return module
