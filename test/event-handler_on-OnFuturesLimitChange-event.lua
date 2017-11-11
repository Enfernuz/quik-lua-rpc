package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.event-handler", function()
    
  local qlua_events = require("qlua.rpc.qlua_events_pb")

  local struct_factory = mock( require("utils.struct_factory") )
    
  local sut = require("impl.event-handler")
  
  -----

  describe("WHEN handling the ON_FUTURES_LIMIT_CHANGE event", function()
      
    -----
      
    describe("AND given a futures limit table", function()
        
      local fut_limit
      
      setup(function()
      
        fut_limit = {
          firmid = "test-firmid",
          trdaccid = "test-trdaccid", 
          limit_type = 1, 
          liquidity_coef = 0.56,
          cbp_prev_limit = 123.4, 
          cbplimit = 234.56, 
          cbplused = 345.6, 
          cbplplanned = 456.78, 
          varmargin = 98.89, 
          accruedint = 12.3, 
          cbplused_for_orders = 32.19, 
          cbplused_for_positions = 19.23, 
          options_premium = 77.89, 
          ts_comission = 0.81, 
          kgo = 4567, 
          currcode = "test-currcode", 
          real_varmargin = 83.91
        }
      end)
    
      teardown(function()
        fut_limit = nil
      end)
    
      it("SHOULD call struct_factory.create_FuturesLimit with that futures limit table as an argument", function()
        
        sut:handle(qlua_events.EventType.ON_FUTURES_LIMIT_CHANGE, fut_limit)

        assert.spy(struct_factory.create_FuturesLimit).was_called_with(fut_limit)
      end)
    
      it("SHOULD return the same result as struct_factory.create_FuturesLimit", function()

        local actual = sut:handle(qlua_events.EventType.ON_FUTURES_LIMIT_CHANGE, fut_limit)
        local expected = struct_factory.create_FuturesLimit(fut_limit)
        
        assert.are.same(expected, actual)
      end)
    end)
  
  end)

-----
  
end)
