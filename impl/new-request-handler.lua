package.path = "../?.lua;" .. package.path

local qlua_pb = require("impl.qlua-protobuf-to-func-mapping")
local procedure_caller = require("impl.qlua-procedure-caller")
local json = require("utils.json")

local RequestHandler = {}

local handlers = {}

handlers["protobuf"] = function (protobuf_request)
  
  local request = qlua_pb.deserialize_request(protobuf_request)
  local deserialized_response = procedure_caller.carry_out(request)
  return qlua_pb.serialize_response(deserialized_response)
end

handlers["json"] = function (json_request)
  
  local request = json.decode(json_request)
  local req_type = request.method
  local req_args = request.params
  
  -- TODO: implement
end

function RequestHandler:new (serde_protocol)
  
  if not serde_protocol then
    error("Serialization/deserialization protocol is not specified.")
  end
  
  -- "Object Oriented" Lua examples: https://habr.com/post/259265/
  local obj = {}
  
  local handler = handlers[serde_protocol]
  if not handler then
    error( string.format("Unsupported serialization/deserialization protocol: %s.", serde_protocol) )
  end
  
  function obj:handle (request)
     return handler(request)
  end
  
  setmetatable(obj, self)
  self.__index = self
  
  return obj
end

return RequestHandler
