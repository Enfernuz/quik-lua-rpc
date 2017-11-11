package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.event-handler", function()
    
  local qlua_events = require("qlua.rpc.qlua_events_pb")

  local struct_factory = mock( require("utils.struct_factory") )
    
  local sut = require("impl.event-handler")
  
  -----

  describe("WHEN handling the ON_ACCOUNT_POSITION event", function()
      
    -----
      
    describe("AND given an account position table", function()
        
      local acc_pos
      
      setup(function()
      
        acc_pos = {
          firmid = "test-firmid", 
          currcode = "test-currcode", 
          tag = "test-tag", 
          description = "test-description", 
          openbal = 1234.56, 
          currentpos = 2345, 
          plannedpos = 321.09, 
          limit1 = 123.4, 
          limit2 = 234.56, 
          orderbuy = 5, 
          ordersell = 0, 
          netto = 5, 
          plannedbal = 1234.56, 
          debit = 1234.56, 
          credit = 0, 
          bank_acc_id = "test-bank_acc_id", 
          margincall = 650.98, 
          settlebal = 333.44
        }
      end)
    
      teardown(function()
        acc_pos = nil
      end)
    
      it("SHOULD call struct_factory.create_AccountPosition with that account position table as an argument", function()
        
        sut:handle(qlua_events.EventType.ON_ACCOUNT_POSITION, acc_pos)

        assert.spy(struct_factory.create_AccountPosition).was_called_with(acc_pos)
      end)
    
      it("SHOULD return the same result as struct_factory.create_AccountPosition", function()

        local actual = sut:handle(qlua_events.EventType.ON_ACCOUNT_POSITION, acc_pos)
        local expected = struct_factory.create_AccountPosition(acc_pos)
        
        assert.are.same(expected, actual)
      end)
    end)
  
  end)

-----
  
end)
