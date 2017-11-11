package.path = "../?.lua;" .. package.path

require 'busted.runner'()

describe("impl.event-handler", function()
    
  local qlua_events = require("qlua.rpc.qlua_events_pb")
    
  local sut = require("impl.event-handler")
  
  local no_arg_events = {
    { event = qlua_events.EventType.PUBLISHER_ONLINE, name = "PUBLISHER_ONLINE" },
    { event = qlua_events.EventType.PUBLISHER_OFFLINE, name = "PUBLISHER_OFFLINE" },
    { event = qlua_events.EventType.ON_CLOSE, name = "ON_CLOSE" },
    { event = qlua_events.EventType.ON_CONNECTED, name = "ON_CONNECTED" },
    { event = qlua_events.EventType.ON_DISCONNECTED, name = "ON_DISCONNECTED" },
    { event = qlua_events.EventType.ON_CLEAN_UP, name = "ON_CLEAN_UP" }
  }
  
  for _, no_arg_event in ipairs(no_arg_events) do
    
    -----
    
    describe(string.format("WHEN handling '%s' event", no_arg_event.name), function()
      
      it("should return nil", function() 
        assert.is_nil( sut:handle(no_arg_event.event) )
      end)
    end)
  
    -----
  end
end)
