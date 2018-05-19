-- Lua functions
local error = assert(error, "Функция 'error' не найдена.")
local string = assert(string, "Taблица 'string' не найдена.")
local pcall = assert(pcall, "Функция 'pcall' не найдена.")
local pairs = assert(pairs, "Функция 'pairs' не найдена.")
local tostring = assert(tostring, "Функция 'tostring' не найдена.")
local loadstring = assert(loadstring, "Функция 'loadstring' не найдена.")

-- QLua functions
local isConnected = assert(isConnected, "Функция 'isConnected' не найдена.")
local getScriptPath = assert(getScriptPath, "Функция 'getScriptPath' не найдена.")
local getInfoParam = assert(getInfoParam, "Функция 'getInfoParam' не найдена.")
local getItem = assert(getItem, "Функция 'getItem' не найдена.")
local message = assert(message, "Функция 'message' не найдена.")
local sleep = assert(sleep, "Функция 'sleep' не найдена.")
local getWorkingFolder = assert(getWorkingFolder, "Функция 'getWorkingFolder' не найдена.")
local PrintDbgStr = assert(PrintDbgStr, "Функция 'PrintDbgStr' не найдена.")
local getOrderByNumber = assert(getOrderByNumber, "Функция 'getOrderByNumber' не найдена.")
local getNumberOf = assert(getNumberOf, "Функция 'getNumberOf' не найдена.")
local SearchItems = assert(SearchItems, "Функция 'SearchItems' не найдена.")

-- Utility modules
local utils = require("utils.utils")

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

module["isConnected"] = function ()
  return isConnected()
end

module["getScriptPath"] = function ()
  return getScriptPath()
end

module["getInfoParam"] = function (args)
  return getInfoParam(args.param_name)
end

module["message"] = function (args)
  
  local proc_result = message(utils.Utf8ToCp1251(args.message), args.icon_type)
  
  if proc_result == nil then
    if args.icon_type == nil then 
      error( string.format("Процедура message(%s) возвратила nil.", args.message) )
    else
      error( string.format("Процедура message(%s, %d) возвратила nil.", args.message, args.icon_type) )
    end
  end
  
  return proc_result
end

module["sleep"] = function (args) 
  
  local proc_result = sleep(args.time)
  
  if proc_result == nil then
    error(string.format("Процедура sleep(%d) возвратила nil.", args.time))
  end
  
  return proc_result
end

module["getWorkingFolder"] = getWorkingFolder

module["PrintDbgStr"] = function (args) 
  
  PrintDbgStr(args.s)
  
  return nil
end

module["getItem"] = function (args) 
  
  local proc_result = getItem(args.table_name, args.index)
  
  return to_string_string_table(proc_result)
end

module["getOrderByNumber"] = function (args) 
  
  local t, i = getOrderByNumber(args.class_code, args.order_id)
  
  if t == nil then
    error(string.format("Процедура getOrderByNumber(%s, %d) вернула (nil, nil).", args.class_code, args.order_id))
  end
    
  return {
    t = t,
    i = i
  }
end

module["getNumberOf"] = function (args) 
  return getNumberOf(args.table_name) -- returns -1 in case of error
end

module["SearchItems"] = function (args) 
  
  local fn_ctr, error_msg = loadstring("return "..args.fn_def)
  local result
  if fn_ctr == nil then 
    error(string.format("Не удалось распарсить определение функции из переданной строки. Описание ошибки: %s.", error_msg))
  else
    if args.params == "" then
      result = SearchItems(args.table_name, args.start_index, args.end_index == 0 and (getNumberOf(args.table_name) - 1) or args.end_index, fn_ctr()) -- returns nil in case of empty list found or error
    else 
      result = SearchItems(args.table_name, args.start_index, args.end_index == 0 and (getNumberOf(args.table_name) - 1) or args.end_index, fn_ctr(), args.params) -- returns nil in case of empty list found or error
    end
  end
  
  return result
end

-----

return module
