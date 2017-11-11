package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.event-handler", function()
    
  local qlua_events = require("qlua.rpc.qlua_events_pb")

  local struct_factory = mock( require("utils.struct_factory") )
    
  local sut = require("impl.event-handler")
  
  -----

  describe("WHEN handling the ON_STOP_ORDER event", function()
      
    -----
      
    describe("AND given a stop order table", function()
        
      local stop_order
      
      setup(function()
      
        stop_order = {
          order_num = 1234567890, 
          ordertime = 1020304050, 
          flags = 0x2, 
          brokerref = "test-brokerref", 
          firmid = "test-firmid", 
          account = "test-account", 
          condition = 1, 
          condition_price = 17.88, 
          price = 18.05, 
          qty = 55, 
          linkedorder = 9876543210, 
          expiry = 1122334455, 
          trans_id = 741852963, 
          client_code = "test-client_code", 
          co_order_num = 13680, 
          co_order_price = 18.5, 
          stop_order_type = 1, 
          orderdate = 1020300000, 
          alltrade_num = 321654987, 
          stopflags = 0x4, 
          offset = 1.22, 
          spread = 2.33, 
          balance = 25.65, 
          uid = 445566, 
          filled_qty = 20, 
          withdraw_time = 1020304999, 
          condition_price2 = 17.99, 
          active_from_time = 1020304050, 
          active_to_time = 1020309999, 
          sec_code = "test-sec_code", 
          class_code = "test-class_code", 
          condition_sec_code = "test-condition_sec_code", 
          condition_class_code = "test-condition_class_code", 
          canceled_uid = 556677, 
          order_date_time = {
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
            mcs = 0,
            ms = 0,
            sec = 0,
            min = 0,
            hour = 13,
            day = 10,
            week_day = 2,
            month = 7,
            year = 2017
          } 
        }
      end)
    
      teardown(function()
        stop_order = nil
      end)
    
      it("SHOULD call struct_factory.create_StopOrder with that stop order table as an argument", function()
        
        sut:handle(qlua_events.EventType.ON_STOP_ORDER, stop_order)

        assert.spy(struct_factory.create_StopOrder).was_called_with(stop_order)
      end)
    
      it("SHOULD return the same result as struct_factory.create_StopOrder", function()

        local actual = sut:handle(qlua_events.EventType.ON_STOP_ORDER, stop_order)
        local expected = struct_factory.create_StopOrder(stop_order)
        
        assert.are.same(expected, actual)
      end)
    end)
  
  end)

-----
  
end)
