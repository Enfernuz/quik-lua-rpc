local module = {}

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
