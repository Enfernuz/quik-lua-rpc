package.path = "../?.lua;" .. package.path

local zmq = require("lzmq")

local EventPublisher = {}

function EventPublisher:new ()
  
  local private = {}
  private.pub_sockets = {}
 
  -- "Object Oriented" Lua examples: https://habr.com/post/259265/
  local public = {}

  function public:publish (event_type, event_data)

    local pub_key, pub_data = self:serialize(event_type, event_data)
    
    for _, pub_socket in ipairs(private.pub_sockets) do

      local ok, err
      if pub_data == nil then
        ok, err = pcall(function() pub_socket:send(pub_key) end) -- send the subscription key
        -- if not ok then (log error somehow...) end
      else
        ok, err = pcall(function() pub_socket:send_more(pub_key) end) -- send the subscription key
        if ok then
          local msg = zmq.msg_init_data(pub_data)
          ok, err = pcall(function() msg:send(pub_socket) end)
          -- if not ok then (log error somehow...) end
          msg:close()
        else
          -- (log error somehow...)
        end
      end
    end
    
  end

  function public:add_pub_socket (pub_socket)
    table.sinsert(private.pub_sockets, pub_socket)
  end

  setmetatable(public, self)
  self.__index = self
  
  return public
end

return EventPublisher
