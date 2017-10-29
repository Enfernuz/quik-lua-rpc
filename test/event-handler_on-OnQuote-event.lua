package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.event-handler", function()
    
  local qlua_events = require("messages.qlua_events_pb")

  local struct_factory = mock( require("utils.struct_factory") )
    
  local sut = require("impl.event-handler")
  
  -----

  describe("WHEN handling the ON_QUOTE event", function()
      
    -----
      
    describe("AND given a quote table", function()
        
      local quote
      
      setup(function()
      
        quote = {
          class_code = "test-class_code", 
          sec_code = "test-sec_code"
        }
      end)
    
      teardown(function()
        quote = nil
      end)
    
      it("SHOULD call struct_factory.create_QuoteEventInfo with that quote table as an argument", function()
        
        sut:handle(qlua_events.EventType.ON_QUOTE, quote)

        assert.spy(struct_factory.create_QuoteEventInfo).was_called_with(quote)
      end)
    
      it("SHOULD return the same result as struct_factory.create_QuoteEventInfo", function()

        local actual = sut:handle(qlua_events.EventType.ON_QUOTE, quote)
        local expected = struct_factory.create_QuoteEventInfo(quote)
        
        assert.are.same(expected, actual)
      end)
    end)
  
  end)

-----
  
end)
