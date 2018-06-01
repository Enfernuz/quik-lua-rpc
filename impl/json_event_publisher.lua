package.path = "../?.lua;" .. package.path

local EventPublisher = require("impl.event_publisher")
local json = require("utils.json")

local JsonEventPublisher = {}

setmetatable(JsonEventPublisher, {__index = EventPublisher})

function JsonEventPublisher:serialize (event_type, event_data)
  return event_type, json.encode(event_data)
end

return JsonEventPublisher
