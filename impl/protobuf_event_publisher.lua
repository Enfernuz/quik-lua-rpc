package.path = "../?.lua;" .. package.path

local EventPublisher = require("impl.event_publisher")
local pb_event_data_serializer = require("impl.protobuf_event_data_serializer")

local ProtobufEventPublisher = {}

setmetatable(ProtobufEventPublisher, {__index = EventPublisher})

-- The following functions need the module "qlua.qlua_pb_init.lua" being already loaded

function ProtobufEventPublisher:serialize (event_type, event_data)
  return pb_event_data_serializer[event_type](pb_event_data_serializer, event_data)
end

return ProtobufEventPublisher
