package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.event-handler", function()
    
  local qlua_events = require("qlua.rpc.qlua_events_pb")

  local struct_factory = mock( require("utils.struct_factory") )
    
  local sut = require("impl.event-handler")
  
  -----

  describe("WHEN handling the ON_MONEY_LIMIT_DELETE event", function()
      
    -----
      
    describe("AND given a money limit delete table", function()
        
      local mlimit_del
      
      setup(function()
      
        mlimit_del = {
          currcode = "test-currcode", 
          tag = "test-tag", 
          firmid = "test-firmid", 
          client_code = "test-client_code", 
          limit_kind = 0
        }
      end)
    
      teardown(function()
        mlimit_del = nil
      end)
    
      it("SHOULD call struct_factory.create_MoneyLimitDelete with that money limit delete table as an argument", function()
        
        sut:handle(qlua_events.EventType.ON_MONEY_LIMIT_DELETE, mlimit_del)

        assert.spy(struct_factory.create_MoneyLimitDelete).was_called_with(mlimit_del)
      end)
    
      it("SHOULD return the same result as struct_factory.create_MoneyLimitDelete", function()

        local actual = sut:handle(qlua_events.EventType.ON_MONEY_LIMIT_DELETE, mlimit_del)
        local expected = struct_factory.create_MoneyLimitDelete(mlimit_del)
        
        assert.are.same(expected, actual)
      end)
    end)
  
  end)

-----
  
end)
