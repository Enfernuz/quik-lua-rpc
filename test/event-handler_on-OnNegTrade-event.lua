package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.event-handler", function()
    
  local qlua_events = require("messages.qlua_events_pb")

  local struct_factory = mock( require("utils.struct_factory") )
    
  local sut = require("impl.event-handler")
  
  -----

  describe("WHEN handling the ON_NEG_TRADE event", function()
      
    -----
      
    describe("AND given a neg trade table", function()
        
      local neg_trade
      
      setup(function()
      
        neg_trade = {
          trade_num = 1234567, 
          trade_date = 45678900987, 
          settle_date = 45678900000, 
          flags = 0x1, 
          brokerref = "test-brokerref", 
          firmid = "test-firmid", 
          account = "test-account", 
          cpfirmid = "test-cpfirmid", 
          cpaccount = "test-cpaccount", 
          price = 369.85, 
          qty = 100, 
          value = 36985, 
          settlecode = "test-settlecode", 
          report_num = 7887, 
          cpreport_num = 8778, 
          accruedint = 123.45, 
          repotradeno = 87654321, 
          price1 = 369, 
          reporate = 7.89, 
          price2 = 369.5, 
          client_code = "test-client_code", 
          ts_comission = 100.99, 
          balance = 78.98, 
          settle_time = 45678900986, 
          amount = 123, 
          repovalue = 25000, 
          repoterm = 3, 
          repo2value = 25500, 
          return_value = 999, 
          discount = 0, 
          lower_discount = 0, 
          upper_discount = 0.5, 
          block_securities = 0, 
          urgency_flag = 0, 
          type = 1, 
          operation_type = 2, 
          expected_discount = 0, 
          expected_quantity = 100, 
          expected_repovalue = 25000, 
          expected_repo2value = 25500, 
          expected_return_value = 999, 
          order_num = 678098, 
          report_trade_date = 456789321, 
          settled = 1, 
          clearing_type = 2, 
          report_comission = 10.99, 
          coupon_payment = 0.00, 
          principal_payment = 99.10, 
          principal_payment_date = 456789123, 
          nextdaysettle = 10, 
          settle_currency = "test-settle_currency", 
          sec_code = "test-sec_code", 
          class_code = "test-class_code", 
          compval = 1, 
          parenttradeno = 987321, 
          bankid = "test-bankid", 
          bankaccid = "test-bankaccid", 
          precisebalance = 100.10, 
          confirmtime = 456789010, 
          ex_flags = 0x2, 
          confirmreport = 7
        }
      end)
    
      teardown(function()
        neg_trade = nil
      end)
    
      it("SHOULD call struct_factory.create_NegTrade with that neg trade table as an argument", function()
        
        sut:handle(qlua_events.EventType.ON_NEG_TRADE, neg_trade)

        assert.spy(struct_factory.create_NegTrade).was_called_with(neg_trade)
      end)
    
      it("SHOULD return the same result as struct_factory.create_NegTrade", function()

        local actual = sut:handle(qlua_events.EventType.ON_NEG_TRADE, neg_trade)
        local expected = struct_factory.create_NegTrade(neg_trade)
        
        assert.are.same(expected, actual)
      end)
    end)
  
  end)

-----
  
end)
