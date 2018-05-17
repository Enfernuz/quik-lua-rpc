package.path = "../?.lua;" .. package.path

local protobuf_request_response_serde = require("impl.protobuf_request_response_serde")
local procedure_caller = require("impl.procedure_caller")
local json = require("utils.json")

-----

local handlers = {}

handlers["protobuf"] = function (protobuf_request)
  
  local request = protobuf_request_response_serde.deserialize_request(protobuf_request)
  local deserialized_response = procedure_caller.carry_out(request)
  return protobuf_request_response_serde.serialize_response(deserialized_response)
end

handlers["json"] = function (json_request)
  return procedure_caller.carry_out( json.decode(json_request) )
end

-----

local RequestHandler = {}

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
    
    if request == nil then error("No request provided.", 2) end
    
    return handler(request)
  end
  
  setmetatable(obj, self)
  self.__index = self
  
  return obj
end

return RequestHandler
