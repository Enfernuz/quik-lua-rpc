package.path = "../?.lua;" .. package.path

local RequestResponseSerde = require("impl.request_response_serde")
local json = require("utils.json")

local JsonRequestResponseSerde = {}
setmetatable(JsonRequestResponseSerde, {__index = RequestResponseSerde})

function JsonRequestResponseSerde:deserialize_request (serialized_request)
  
  if serialized_request == nil then error("Аргумент #0 'serialized_request' не должен быть nil.") end
  
  local deserialized_request = json.decode(serialized_request)

  return deserialized_request.method, deserialized_request.args
end

function JsonRequestResponseSerde:serialize_response (deserialized_response)
  
  if deserialized_response == nil then error("Аргумент #0 'deserialized_response' не должен быть nil.") end
  
  return json.encode(deserialized_response.proc_result) -- TODO: broken atm. Implement it similar to the protobuf object mapping logic (wrapping the proc_result to a result object).
end

return JsonRequestResponseSerde
