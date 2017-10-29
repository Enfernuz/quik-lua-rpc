package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.event-handler", function()
    
  local qlua_events = require("messages.qlua_events_pb")

  local struct_factory = mock( require("utils.struct_factory") )
    
  local sut = require("impl.event-handler")
  
  -----

  describe("WHEN handling the ON_FUTURES_LIMIT_DELETE event", function()
      
    -----
      
    describe("AND given a limit delete table", function()
        
      local lim_del
      
      setup(function()
      
        lim_del = {
          firmid = "test-firmid", 
          limit_type = 2
        }
      end)
    
      teardown(function()
        lim_del = nil
      end)
    
      it("SHOULD call struct_factory.create_FuturesLimitDelete with that limit delete table as an argument", function()
        
        sut:handle(qlua_events.EventType.ON_FUTURES_LIMIT_DELETE, lim_del)

        assert.spy(struct_factory.create_FuturesLimitDelete).was_called_with(lim_del)
      end)
    
      it("SHOULD return the same result as struct_factory.create_FuturesLimitDelete", function()

        local actual = sut:handle(qlua_events.EventType.ON_FUTURES_LIMIT_DELETE, lim_del)
        local expected = struct_factory.create_FuturesLimitDelete(lim_del)
        
        assert.are.same(expected, actual)
      end)
    end)
  
  end)

-----
  
end)
