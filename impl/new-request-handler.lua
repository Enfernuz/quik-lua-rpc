package.path = "../?.lua;" .. package.path

local json = require("utils.json")

-----

local function init_handlers (context_path)
  
  local protobuf_request_response_serde = require("impl.protobuf_request_response_serde")(context_path)
  
  local result = {}
  
  result["protobuf"] = {
    request_deserializer = protobuf_request_response_serde.deserialize_request,
    response_serializer = protobuf_request_response_serde.serialize_response
  }

  result["json"] = {
    
    request_deserializer = function (request)
      local deserialized_request = json.decode(request)
      return deserialized_request.method, deserialized_request.params, deserialized_request.id
    end,
    
    response_serializer = function (response)
      
      response.jsonrpc = "2.0"
      return json.encode(response)
    end
  }
  
  return result
end

-----

local RequestHandler = {}
local handlers

function RequestHandler:new (serde_protocol, context_path)
  
  if not serde_protocol then
    error("Serialization/deserialization protocol is not specified.")
  end
  
  if not handlers then
    handlers = init_handlers(context_path)
  end
  
  -- "Object Oriented" Lua examples: https://habr.com/post/259265/
  local obj = {}
  
  local handler = handlers[serde_protocol]
  if not handler then
    error( string.format("Unsupported serialization/deserialization protocol: %s.", serde_protocol) )
  end
  
  local request_deserializer = handlers[serde_protocol].request_deserializer
  local response_serializer = handlers[serde_protocol].response_serializer
  
  function obj:deserialize_request (request)
    if request == nil then error("No request provided.") end
    return request_deserializer(request)
  end
  
  function obj:serialize_response (response)
    if response == nil then error("No response provided.") end
    return response_serializer(response)
  end

  setmetatable(obj, self)
  self.__index = self
  
  return obj
end

return RequestHandler
