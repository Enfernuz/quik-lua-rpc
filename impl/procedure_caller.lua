-- Lua functions
local error = assert(error, "The error function is missing.")
local string = assert(string, "The string function is missing.")
local pcall = assert(pcall, "The pcall function is missing.")

-- QLua functions
local message = assert(message, "The message function is missing.")

-----
-- The DataSources in-memory storage. 
-- Warning: the storage may cause memory leaks if the datasources that aren't needed anymore have not been explicitly closed by the clients, 
-- because the datasources' objects would never be eligible for garbage collection (whereas in a local script they are as soon as the script exits the main function).
local datasources = {}
local function get_datasource (datasource_uid)
  return assert(datasources[datasource_uid], string.format("DataSource c uuid='%s' не найден.", datasource_uid))
end

-----

local method_name_to_qlua_function = {}

method_name_to_qlua_function["message"] = function (args)
  
  local proc_result = message(args.message, args.icon_type)
  
  if proc_result == nil then
    if args.icon_type == nil then 
      error(string.format("Процедура message(%s) возвратила nil.", args.message))
    else
      error(string.format("Процедура message(%s, %d) возвратила nil.", args.message, args.icon_type))
    end
  end
  
  return proc_result
end

-----

local module = {}

function module.carry_out (request)
  
  local func = method_name_to_qlua_function[request.method]
  if func then
    local ok, ret = pcall(function() return func(request.args) end)

    return {
      method = request.method,
      is_error = not ok,
      result = ret
    }
  else
    error( string.format("Could't find the QLua function mapped to the method '%s'.", request.method) )
  end
end

return module
