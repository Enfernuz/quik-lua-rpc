package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.event-handler", function()
    
  local qlua_events = require("messages.qlua_events_pb")

  local struct_factory = mock( require("utils.struct_factory") )
    
  local sut = require("impl.event-handler")
  
  -----

  describe("WHEN handling the ON_MONEY_LIMIT event", function()
      
    -----
      
    describe("AND given a money limit table", function()
        
      local mlimit
      
      setup(function()
      
        mlimit = {
          currcode = "test-currcode", 
          tag = "test-tag", 
          firmid = "test-firmid", 
          client_code = "test-client_code", 
          openbal = 567.89, 
          openlimit = 234.56, 
          currentbal = 456.78, 
          currentlimit = 123.45, 
          locked = 12.98, 
          locked_value_coef = 0.5, 
          locked_margin_value = 9.88, 
          leverage = 3.0, 
          limit_kind = 0
        }
      end)
    
      teardown(function()
        mlimit = nil
      end)
    
      it("SHOULD call struct_factory.create_MoneyLimit with that money limit table as an argument", function()
        
        sut:handle(qlua_events.EventType.ON_MONEY_LIMIT, mlimit)

        assert.spy(struct_factory.create_MoneyLimit).was_called_with(mlimit)
      end)
    
      it("SHOULD return the same result as struct_factory.create_MoneyLimit", function()

        local actual = sut:handle(qlua_events.EventType.ON_MONEY_LIMIT, mlimit)
        local expected = struct_factory.create_MoneyLimit(mlimit)
        
        assert.are.same(expected, actual)
      end)
    end)
  
  end)

-----
  
end)
