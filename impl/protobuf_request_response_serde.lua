package.path = "../?.lua;" .. package.path

local RequestResponseSerde = require("impl.request_response_serde")

local pb_helper = require("impl.protobuf_helper")

local ProtobufRequestResponseSerde = {}

setmetatable(ProtobufRequestResponseSerde, {__index = RequestResponseSerde})

function ProtobufRequestResponseSerde:deserialize_request (pb_request)
  return pb_helper.decode_request(pb_request)
end

function ProtobufRequestResponseSerde:serialize_response (response)
  return pb_helper.encode_response(response)
end

return ProtobufRequestResponseSerde
