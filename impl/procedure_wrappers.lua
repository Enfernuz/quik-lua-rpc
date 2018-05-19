-- Lua functions
local error = assert(error, "The error function is missing.")
local string = assert(string, "The string function is missing.")
local pcall = assert(pcall, "The pcall function is missing.")
local pairs = assert(pairs, "The pairs function is missing.")
local tostring = assert(tostring, "The tostring function is missing.")

-- QLua functions
local isConnected = assert(isConnected, "The message function is missing.")
local getScriptPath = assert(getScriptPath, "The getScriptPath function is missing.")
local getInfoParam = assert(getInfoParam, "The getInfoParam function is missing.")
local getItem = assert(getItem, "The getItem function is missing.")
local message = assert(message, "The message function is missing.")

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

module["getItem"] = function (args) 
  
  local proc_result = getItem(args.table_name, args.index)
  
  return to_string_string_table(proc_result)
end

-----

return module
