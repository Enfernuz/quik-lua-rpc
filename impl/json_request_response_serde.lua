package.path = "../?.lua;" .. package.path

local RequestResponseSerde = require("impl.request_response_serde")
local json = require("utils.json")

local JsonRequestResponseSerde = {}
setmetatable(JsonRequestResponseSerde, {__index = RequestResponseSerde})

function JsonRequestResponseSerde:deserialize_request (serialized_request)
  
  if serialized_request == nil then error("Аргумент #0 'serialized_request' не должен быть nil.") end
  
  local deserialized_request = json.decode(serialized_request)
  
  return deserialized_request.method, deserialized_request.params, deserialized_request.id
end

function JsonRequestResponseSerde:serialize_response (deserialized_response)
  
  if deserialized_response == nil then error("Аргумент #0 'deserialized_response' не должен быть nil.") end
  
  deserialized_response.jsonrpc = "2.0"
  
  return json.encode(deserialized_response)
end

return JsonRequestResponseSerde
