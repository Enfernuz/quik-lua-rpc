local module = {}

module["message"] = function (args)
  
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

return module
