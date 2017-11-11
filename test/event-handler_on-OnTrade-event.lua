package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.event-handler", function()
    
  local qlua_events = require("qlua.rpc.qlua_events_pb")

  local struct_factory = mock( require("utils.struct_factory") )
    
  local sut = require("impl.event-handler")
  
  -----

  describe("WHEN handling the ON_TRADE event", function()
      
    -----
      
    describe("AND given a trade table", function()
        
      local trade
      
      setup(function()
      
        trade = {
          trade_num = 1234567890,
          order_num = 987123,
          brokerref = "test-brokerref",
          userid = "test-userid",
          firmid = "test-firmid",
          canceled_uid = 456,
          account = "test-account",
          price = 123.88,
          qty = 525,
          value = 145.67,
          accruedint = 120,
          yield = 123.8,
          settlecode = "test-settlecode",
          cpfirmid = "test-cpfirmid",
          flags = 0x04,
          price2 = 88.12,
          reporate = 6.78,
          client_code = "test-client_code",
          accrued2 = 567.8,
          repoterm = 25,
          repovalue = 123.82,
          repo2value = 5751.56,
          start_discount = 0.75,
          lower_discount = 0.59,
          upper_discount = 0.88,
          block_securities = 92,
          clearing_comission = 12.34,
          exchange_comission = 23.45,
          tech_center_comission = 5.43,
          settle_date = 12345,
          settle_currency = "test-settle_currency",
          trade_currency = "test-trade_currency",
          exchange_code = "test-exchange_code",
          station_id = "test-station_id",
          sec_code = "test-sec_code",
          class_code = "test-class_code",
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
          bank_acc_id = "test-bank_acc_id",
          broker_comission = 123.56,
          linked_trade = 987654321,
          period = 2,
          trans_id = 1122334455,
          kind = 1,
          clearing_bank_accid = "test-clearing_bank_accid",
          canceled_datetime = {
            mcs = 24,
            ms = 35,
            sec = 12,
            min = 15,
            hour = 15,
            day = 13,
            week_day = 4,
            month = 7,
            year = 2017
          },
          clearing_firmid = "test-clearing_firmid",
          system_ref = "test-system_ref",
          uid = 192837465
        }
      end)
    
      teardown(function()
        trade = nil
      end)
    
      it("SHOULD call struct_factory.create_Trade with that trade table as an argument", function()
        
        sut:handle(qlua_events.EventType.ON_TRADE, trade)

        assert.spy(struct_factory.create_Trade).was_called_with(trade)
      end)
    
      it("SHOULD return the same result as struct_factory.create_Trade", function()

        local actual = sut:handle(qlua_events.EventType.ON_TRADE, trade)
        local expected = struct_factory.create_Trade(trade)
        
        assert.are.same(expected, actual)
      end)
    end)
  
  end)

-----
  
end)
