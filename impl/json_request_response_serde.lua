package.path = "../?.lua;" .. package.path

local RequestResponseSerde = require("impl.request_response_serde")
local json_helper = require("impl.json_helper")

local JsonRequestResponseSerde = {}
setmetatable(JsonRequestResponseSerde, {__index = RequestResponseSerde})

function JsonRequestResponseSerde:deserialize_request (serialized_request)
  return json_helper.decode_request(serialized_request)
end

function JsonRequestResponseSerde:serialize_response (deserialized_response)
  return json_helper.encode_response(deserialized_response)
end

return JsonRequestResponseSerde
