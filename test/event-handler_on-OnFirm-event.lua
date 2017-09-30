package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.event-handler", function()
    
  local qlua_events = require("messages.qlua_events_pb")

  local struct_factory = mock( require("utils.struct_factory") )
    
  local sut = require("impl.event-handler")
  
  -----

  describe("WHEN handling the ON_FIRM event", function()
      
    -----
      
    describe("AND given a firm", function()
        
      local firm, protobuf_struct_Firm_meta
      
      setup(function()
      
        firm = {
          firmid = "test-firmid",
          firm_name = "test-firm_name",
          status = 1,
          exchange = "test-exchange"
        }
      end)
    
      teardown(function()
        firm = nil
      end)
    
      it("SHOULD call struct_factory.create_Firm with that firm as an argument", function()
        
        sut:handle(qlua_events.EventType.ON_FIRM, firm)

        assert.spy(struct_factory.create_Firm).was_called_with(firm)
      end)
    
      it("SHOULD return the same result as struct_factory.create_Firm", function()

        local actual = sut:handle(qlua_events.EventType.ON_FIRM, firm)
        local expected = struct_factory.create_Firm(firm)
        
        assert.are.same(expected, actual)
      end)
    end)
  
  end)

-----
  
end)
