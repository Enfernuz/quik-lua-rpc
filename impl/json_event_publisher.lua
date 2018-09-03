package.path = "../?.lua;" .. package.path

local EventPublisher = require("impl.event_publisher")
local json = require("utils.json")

local JsonEventPublisher = {}

setmetatable(JsonEventPublisher, {__index = EventPublisher})

function JsonEventPublisher:serialize (event_type, event_data)
  
  if event_data then
    return event_type, json.encode(event_data)
  else
    return event_type, nil
  end
end

return JsonEventPublisher
