package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.event-handler", function()
    
  local qlua_events = require("messages.qlua_events_pb")

  local struct_factory = mock( require("utils.struct_factory") )
    
  local sut = require("impl.event-handler")
  
  -----

  describe("WHEN handling the ON_FUTURES_CLIENT_HOLDING event", function()
      
    -----
      
    describe("AND given a futures client holding table", function()
        
      local fut_pos
      
      setup(function()
      
        fut_pos = {
          firmid = "test-firmid", 
          trdaccid = "test-trdaccid", 
          sec_code = "test-sec_code", 
          type = 2, 
          startbuy = 13.95, 
          startsell = 15.03, 
          todaybuy = 14.43, 
          todaysell = 14.99, 
          totalnet = 5.56, 
          openbuys = 25, 
          opensells = 20, 
          cbplused = 300.01, 
          cbplplanned = 299.98, 
          varmargin = 7.87, 
          avrposnprice = 14.50, 
          positionvalue = 14.34, 
          real_varmargin = 7.42, 
          total_varmargin = 7.24, 
          session_status = 1
        }
      end)
    
      teardown(function()
        fut_pos = nil
      end)
    
      it("SHOULD call struct_factory.create_FuturesClientHolding with that futures client holding table as an argument", function()
        
        sut:handle(qlua_events.EventType.ON_FUTURES_CLIENT_HOLDING, fut_pos)

        assert.spy(struct_factory.create_FuturesClientHolding).was_called_with(fut_pos)
      end)
    
      it("SHOULD return the same result as struct_factory.create_FuturesClientHolding", function()

        local actual = sut:handle(qlua_events.EventType.ON_FUTURES_CLIENT_HOLDING, fut_pos)
        local expected = struct_factory.create_FuturesClientHolding(fut_pos)
        
        assert.are.same(expected, actual)
      end)
    end)
  
  end)

-----
  
end)
