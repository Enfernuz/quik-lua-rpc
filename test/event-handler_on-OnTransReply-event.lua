package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.event-handler", function()
    
  local qlua_events = require("messages.qlua_events_pb")

  local struct_factory = mock( require("utils.struct_factory") )
    
  local sut = require("impl.event-handler")
  
  -----

  describe("WHEN handling the ON_TRANS_REPLY event", function()
      
    -----
      
    describe("AND given a trans reply table", function()
        
      local trans_reply
      
      setup(function()
      
        trans_reply = {
          trans_id = 1234567890, 
          status = 2, 
          result_msg = "test-result_msg", 
          date_time = {
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
          uid = 445566, 
          flags = 0x4, 
          server_trans_id = 9876543210, 
          order_num = 963852741, 
          price = 75.35, 
          quantity = 15, 
          balance = 236.98, 
          firm_id = "test-firm_id", 
          account = "test-account", 
          client_code = "test-client_code", 
          brokerref = "test-brokerref", 
          class_code = "test-class_code", 
          sec_code = "test-sec_code", 
          exchange_code = "test-exchange_code"
        }
      end)
    
      teardown(function()
        trans_reply = nil
      end)
    
      it("SHOULD call struct_factory.create_Transaction with that trans reply table as an argument", function()
        
        sut:handle(qlua_events.EventType.ON_TRANS_REPLY, trans_reply)

        assert.spy(struct_factory.create_Transaction).was_called_with(trans_reply)
      end)
    
      it("SHOULD return the same result as struct_factory.create_Transaction", function()

        local actual = sut:handle(qlua_events.EventType.ON_TRANS_REPLY, trans_reply)
        local expected = struct_factory.create_Transaction(trans_reply)
        
        assert.are.same(expected, actual)
      end)
    end)
  
  end)

-----
  
end)
