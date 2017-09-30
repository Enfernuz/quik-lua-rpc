package.path = "../?.lua;" .. package.path

require 'busted.runner'()

describe("impl.event-handler", function()
    
  local sut = require("impl.event-handler")
  
  -----

  describe("WHEN no event type provided", function()

    it("SHOULD raise an error", function()
        
      local get_event_result = function()
        return sut:handle()
      end  
      
      assert.has_error(get_event_result, "No event_type provided.")
    end)
  end)

  -----

  describe("WHEN unknown event type provided", function()
    
    local qlua_events = require("messages.qlua_events_pb")  
    
    local known_event_types
    local unknown_event_type

    setup(function()
        
      known_event_types = {}
      for _, event in ipairs(qlua_events.EVENTTYPE.values) do
        known_event_types[tostring(event.number)] = true
      end
        
      repeat unknown_event_type = math.random() until not known_event_types[tostring(unknown_event_type)]
    end)
  
    teardown(function()
      known_event_types = nil
      unknown_event_type = nil
    end)
    
    it("SHOULD raise an error", function()
        
      local get_event_result = function()
        return sut:handle(unknown_event_type)
      end  
        
      assert.has_error(get_event_result, string.format("Unknown event type: %s.", unknown_event_type))
    end)
  end)

  -----

end)
