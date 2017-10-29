package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.event-handler", function()
    
  local qlua_events = require("messages.qlua_events_pb")

  local struct_factory = mock( require("utils.struct_factory") )
    
  local sut = require("impl.event-handler")
  
  -----

  describe("WHEN handling the ON_NEG_DEAL event", function()
      
    -----
      
    describe("AND given a neg deal table", function()
        
      local neg_deal
      
      setup(function()
      
        neg_deal = {
          neg_deal_num = 1234567, 
          neg_deal_time = 45678900987, 
          flags = 0x08, 
          brokerref = "test-brokerref", 
          userid = "test-userid", 
          firmid = "test-firmid", 
          cpuserid = "test-cpuserid", 
          cpfirmid = "test-cpfirmid", 
          account = "test-account", 
          price = 12.98, 
          qty = 320, 
          matchref = "test-matchref", 
          settlecode = "test-settlecode", 
          yield = 123.45, 
          accruedint = 33, 
          value = 43.34, 
          price2 = 12.56, 
          reporate = 7.89, 
          refundrate = 6.54, 
          trans_id = 9876543210, 
          client_code = "test-client_code", 
          repoentry = 0, 
          repovalue = 564.3, 
          repo2value = 563.4, 
          repoterm = 7, 
          start_discount = 0.5, 
          lower_discount = 0.33, 
          upper_discount = 0.67, 
          block_securities = 0, 
          uid = 456654, 
          withdraw_time = 45678900988, 
          neg_deal_date = 45678900000, 
          balance = 444.56, 
          origin_repovalue = 123.56, 
          origin_qty = 22, 
          origin_discount = 0.25, 
          neg_deal_activation_date = 45678900099, 
          neg_deal_activation_time = 45678800000, 
          quoteno = 145.78, 
          settle_currency = "test-settle_currency", 
          sec_code = "test-sec_code", 
          class_code = "test-class_code", 
          bank_acc_id = "test-bank_acc_id", 
          withdraw_date = 45678910, 
          linkedorder = 123654987, 
          activation_date_time = {
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
          withdraw_date_time = {
            mcs = 59,
            ms = 49,
            sec = 01,
            min = 15,
            hour = 11,
            day = 9,
            week_day = 1,
            month = 7,
            year = 2017
          }, 
          date_time = {
            mcs = 40,
            ms = 31,
            sec = 00,
            min = 05,
            hour = 11,
            day = 9,
            week_day = 1,
            month = 7,
            year = 2017
          }
        }
      end)
    
      teardown(function()
        neg_deal = nil
      end)
    
      it("SHOULD call struct_factory.create_NegDeal with that neg deal table as an argument", function()
        
        sut:handle(qlua_events.EventType.ON_NEG_DEAL, neg_deal)

        assert.spy(struct_factory.create_NegDeal).was_called_with(neg_deal)
      end)
    
      it("SHOULD return the same result as struct_factory.create_NegDeal", function()

        local actual = sut:handle(qlua_events.EventType.ON_NEG_DEAL, neg_deal)
        local expected = struct_factory.create_NegDeal(neg_deal)
        
        assert.are.same(expected, actual)
      end)
    end)
  
  end)

-----
  
end)
