package.path = "?.lua;" .. package.path

local scriptPath = getScriptPath()

local zmq = require("lzmq")
local utils = require("utils.utils")

local function localize (str)
  return utils.Utf8ToCp1251(str)
end

function main ()
  
  local pub, sec = zmq.curve_keypair()
  if pub == nil then
    local msg = string.format("Не удалось сгенерировать ключевую пару. ZMQ errno: %s.", tostring(sec.no()))
    error( localize(msg) )
  end
  
  local filePath = scriptPath.."\\curve.txt"
  local file, err = io.open(filePath, "a+")
  if err then 
    local msg = string.format("Не удалось открыть файл '%s' для записи ключевой пары. Подробности: <%s>.", filePath, err)
    error( localize(msg) ) 
  end
  
  file:write( string.format("[pub]\n%s\n[sec]\n%s\n\n", tostring(pub), tostring(sec)) )
  
  file:close()
  
  local msg = string.format("Ключевая пара добавлена в файл\n%s.", filePath)
  message( localize(msg) )
end
