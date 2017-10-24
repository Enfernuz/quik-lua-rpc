package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.event-handler", function()
    
  local qlua_events = require("messages.qlua_events_pb")

  local struct_factory = mock( require("utils.struct_factory") )
    
  local sut = require("impl.event-handler")
  
  -----

  describe("WHEN handling the ON_ALL_TRADE event", function()
      
    -----
      
    describe("AND given an alltrade table", function()
        
      local alltrade
      
      setup(function()
      
        alltrade = {
          trade_num = 1234567890,
          flags = 0x04,
          price = 19.90,
          qty = 250,
          value = 4975.0,
          accruedint = 1.0,
          yield = 2.1,
          settlecode = "test-settlecode",
          reporate = 3.59,
          repovalue = 2.78,
          repo2value = 8.72,
          repoterm = 28,
          sec_code = "AFKS",
          class_code = "TQBR",
          datetime = {
            mcs = 59,
            ms = 49,
            sec = 39,
            min = 29,
            hour = 10,
            day = 9,
            week_day = 1,
            month = 7,
            year = 2017
          },
          period = 1,
          open_interest = 100500,
          exchange_code = "MOEX"
        }
      end)
    
      teardown(function()
        alltrade = nil
      end)
    
      it("SHOULD call struct_factory.create_AllTrade with that alltrade table as an argument", function()
        
        sut:handle(qlua_events.EventType.ON_ALL_TRADE, alltrade)

        assert.spy(struct_factory.create_AllTrade).was_called_with(alltrade)
      end)
    
      it("SHOULD return the same result as struct_factory.create_AllTrade", function()

        local actual = sut:handle(qlua_events.EventType.ON_ALL_TRADE, alltrade)
        local expected = struct_factory.create_AllTrade(alltrade)
        
        assert.are.same(expected, actual)
      end)
    end)
  
  end)

-----
  
end)
