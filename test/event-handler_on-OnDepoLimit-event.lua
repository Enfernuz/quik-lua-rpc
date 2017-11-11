package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.event-handler", function()
    
  local qlua_events = require("qlua.rpc.qlua_events_pb")

  local struct_factory = mock( require("utils.struct_factory") )
    
  local sut = require("impl.event-handler")
  
  -----

  describe("WHEN handling the ON_DEPO_LIMIT event", function()
      
    -----
      
    describe("AND given a depo limit table", function()
        
      local dlimit
      
      setup(function()
      
        dlimit = {
          sec_code = "test-sec_code", 
          trdaccid = "test-trdaccid", 
          firmid = "test-firmid", 
          client_code = "test-client_code", 
          openbal = 100, 
          openlimit = 150, 
          currentbal = 90, 
          currentlimit = 140, 
          locked_sell = 10, 
          locked_buy = 20, 
          locked_buy_value = 1200.60, 
          locked_sell_value = 600.30, 
          awg_position_price = 60.3, 
          limit_kind = 0
        }
      end)
    
      teardown(function()
        dlimit = nil
      end)
    
      it("SHOULD call struct_factory.create_DepoLimit with that depo limit table as an argument", function()
        
        sut:handle(qlua_events.EventType.ON_DEPO_LIMIT, dlimit)

        assert.spy(struct_factory.create_DepoLimit).was_called_with(dlimit)
      end)
    
      it("SHOULD return the same result as struct_factory.create_DepoLimit", function()

        local actual = sut:handle(qlua_events.EventType.ON_DEPO_LIMIT, dlimit)
        local expected = struct_factory.create_DepoLimit(dlimit)
        
        assert.are.same(expected, actual)
      end)
    end)
  
  end)

-----
  
end)
