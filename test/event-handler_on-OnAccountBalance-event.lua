package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.event-handler", function()
    
  local qlua_events = require("messages.qlua_events_pb")

  local struct_factory = mock( require("utils.struct_factory") )
    
  local sut = require("impl.event-handler")
  
  -----

  describe("WHEN handling the ON_ACCOUNT_BALANCE event", function()
      
    -----
      
    describe("AND given an account balance table", function()
        
      local account_balance
      
      setup(function()
      
        account_balance = {
          firmid = "test-firmid", 
          sec_code = "test-sec_code",
          trdaccid = "test-trdaccid", 
          depaccid = "test-depaccid", 
          openbal = 2143.65, 
          currentpos = 4365.76, 
          plannedpossell = 1234.56, 
          plannedposbuy = 6543.21, 
          planbal = 3456.78, 
          usqtyb = 123.40, 
          usqtys = 234.56, 
          planned = 345.76, 
          settlebal = 456.78, 
          bank_acc_id = "test-bank_acc_id", 
          firmuse = 5
        }
      end)
    
      teardown(function()
        account_balance = nil
      end)
    
      it("SHOULD call struct_factory.create_AccountBalance with that account balance table as an argument", function()
        
        sut:handle(qlua_events.EventType.ON_ACCOUNT_BALANCE, account_balance)

        assert.spy(struct_factory.create_AccountBalance).was_called_with(account_balance)
      end)
    
      it("SHOULD return the same result as struct_factory.create_AccountBalance", function()

        local actual = sut:handle(qlua_events.EventType.ON_ACCOUNT_BALANCE, account_balance)
        local expected = struct_factory.create_AccountBalance(account_balance)
        
        assert.are.same(expected, actual)
      end)
    end)
  
  end)

-----
  
end)
