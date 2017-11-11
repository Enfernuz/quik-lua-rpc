package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.event-handler", function()
    
  local qlua_events = require("qlua.rpc.qlua_events_pb")

  local struct_factory = mock( require("utils.struct_factory") )
    
  local sut = require("impl.event-handler")
  
  -----

  describe("WHEN handling the ON_DEPO_LIMIT_DELETE event", function()
      
    -----
      
    describe("AND given a depo limit delete table", function()
        
      local dlimit_del
      
      setup(function()
      
        dlimit_del = {
          sec_code = "test-sec_code", 
          trdaccid = "test-trdaccid", 
          firmid = "test-firmid", 
          client_code = "test-client_code", 
          limit_kind = 0
        }
      end)
    
      teardown(function()
        dlimit_del = nil
      end)
    
      it("SHOULD call struct_factory.create_DepoLimitDelete with that depo limit delete table as an argument", function()
        
        sut:handle(qlua_events.EventType.ON_DEPO_LIMIT_DELETE, dlimit_del)

        assert.spy(struct_factory.create_DepoLimitDelete).was_called_with(dlimit_del)
      end)
    
      it("SHOULD return the same result as struct_factory.create_DepoLimitDelete", function()

        local actual = sut:handle(qlua_events.EventType.ON_DEPO_LIMIT_DELETE, dlimit_del)
        local expected = struct_factory.create_DepoLimitDelete(dlimit_del)
        
        assert.are.same(expected, actual)
      end)
    end)
  
  end)

-----
  
end)
