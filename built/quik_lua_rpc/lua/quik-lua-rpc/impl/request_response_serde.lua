package.path = "../?.lua;" .. package.path

local RequestResponseSerde = {}

function RequestResponseSerde:new ()
 
  -- "Object Oriented" Lua examples: https://habr.com/post/259265/
  local public = {}

  function RequestResponseSerde:deserialize_request (serialized_request)
  end
  
  function RequestResponseSerde:serialize_response (deserialized_response)
  end

  setmetatable(public, self)
  self.__index = self
  
  return public
end

return RequestResponseSerde
