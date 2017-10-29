package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.event-handler", function()
    
  local qlua_events = require("messages.qlua_events_pb")

  local struct_factory = mock( require("utils.struct_factory") )
    
  local sut = require("impl.event-handler")
  
  -----

  describe("WHEN handling the ON_ORDER event", function()
      
    -----
      
    describe("AND given an order table", function()
        
      local order
      
      setup(function()
      
        order = {
          order_num = 987123,
          flags = 0x05,
          brokerref = "test-brokerref",
          userid = "test-userid",
          firmid = "test-firmid",
          account = "test-account",
          price = 123.88,
          qty = 525,
          balance = 567.8,
          value = 145.67,
          accruedint = 120,
          yield = 123.8,
          trans_id = 1234567890, 
          client_code = "test-client_code",
          price2 = 88.12,
          settlecode = "test-settlecode",
          uid = 192837465, 
          canceled_uid = 456,
          exchange_code = "test-exchange_code",
          activation_time = 123123123,
          linkedorder = 321789, 
          expiry = 231231231,
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
          withdraw_datetime = {
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
          bank_acc_id = "test-bank_acc_id",
          value_entry_type = 7, 
          repoterm = 25,
          repovalue = 123.82,
          repo2value = 5751.56,
          repo_value_balance = 5300.24,
          start_discount = 0.75,
          reject_reason = "test-reject_reason", 
          ext_order_flags = 0x02, 
          min_qty = 250, 
          exec_type = 3,
          side_qualifier = 1,
          acnt_type = 9, 
          capacity = 600, 
          passive_only_order = 1, 
          visible = 1
        }
      end)
    
      teardown(function()
        order = nil
      end)
    
      it("SHOULD call struct_factory.create_Order with that order table as an argument", function()
        
        sut:handle(qlua_events.EventType.ON_ORDER, order)

        assert.spy(struct_factory.create_Order).was_called_with(order)
      end)
    
      it("SHOULD return the same result as struct_factory.create_Order", function()

        local actual = sut:handle(qlua_events.EventType.ON_ORDER, order)
        local expected = struct_factory.create_Order(order)
        
        assert.are.same(expected, actual)
      end)
    end)
  
  end)

-----
  
end)
