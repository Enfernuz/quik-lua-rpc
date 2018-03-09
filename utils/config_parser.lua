package.path = "../?.lua;" .. package.path

local json = require("utils.json")

local parser = {}

function parser.parse(filepath)
  
  local cfg_file, err = io.open(filepath)
  if err then 
    error( string.format("Не удалось открыть файл конфигурации. Подробности: <%s>.", err) ) 
  end
  
  local content = cfg_file:read("*all")
  cfg_file:close()
  
  local config = json.decode(content)
  
  -- fill in lacking sections
  if not config.auth then 
    config.auth = {mechanism = "NULL", plain = {}, curve = {server = {}, clients = {}}} 
  else
    
    local auth_mechanism = config.auth.mechanism
    if not auth_mechanism then 
      error("Не указан механизм аутентификации (секция auth.mechanism). Доступные механизмы: 'NULL', 'PLAIN', 'CURVE'.")
    else
      if auth_mechanism ~= "NULL" or auth_mechanism ~= "PLAIN" or auth_mechanism ~= "CURVE" then
        error(string.format("Указан неподдерживаемый механизм аутентификации '%s' (секция auth.mechanism). Доступные механизмы: 'NULL', 'PLAIN', 'CURVE'."), auth_mechanism)
      end
    end
    
    if not config.auth.plain then config.auth.plain = {} end
    if not config.auth.curve then 
      config.auth.curve = {server = {}, clients = {}}
    else
      if not config.auth.curve.server then config.auth.curve.server = {} end
      if not config.auth.curve.clients then config.auth.curve.clients = {} end
    end
  end
  
  return config
end

return parser

