package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.rpc-handler", function()
  
  local qlua = require("qlua.api")
  local struct_factory = mock( require("utils.struct_factory") )
  local sut = require("impl.rpc-handler")

  describe("WHEN given a request of type ProcedureType.GET_ORDER_BY_NUMBER", function()
      
    local request
    
    setup(function()
      
      request = {}
      request.type = qlua.RPC.ProcedureType.GET_ORDER_BY_NUMBER
    end)
  
    teardown(function()
      request = nil
    end)

    insulate("WITH arguments", function()
        
      local request_args
      local first, second
      local request_result
      
      setup(function()
      
        request_args = qlua.getOrderByNumber.Request()
        request_args.class_code = "test-class_code"
        request_args.order_id = 12345
        
        request.args = request_args:SerializeToString()

        first = {
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
        
        second = 42
        
        request_result = qlua.getOrderByNumber.Result()
        
        _G.getOrderByNumber = spy.new(function(class_code, order_id) return first, second end)
        qlua.getOrderByNumber.Result = spy.new(function() return request_result end)
      end)

      teardown(function()

        request_args = nil
        first = nil
        second = nil
        request_result = nil
      end)
    
      it("SHOULD call the global 'getOrderByNumber' function once, passing the procedure arguments to it", function()
        
        local response = sut.call_procedure(request.type, request.args)
    
        assert.spy(_G.getOrderByNumber).was.called_with(request_args.class_code, request_args.order_id)
        qlua.getOrderByNumber.Result:clear()
      end)
    
      it("SHOULD return a qlua.getOrderByNumber.Result instance", function()
          
        local actual_result = sut.call_procedure(request.type, request.args)
        local expected_result = qlua.getOrderByNumber.Result()
        
        local actual_meta = getmetatable(actual_result)
        local expected_meta = getmetatable(expected_result)
        
        assert.are.equal(expected_meta, actual_meta)
      end)
    
      it("SHOULD return a protobuf object which string-serialized form equals to that of the expected result", function()
        
        local actual_result = sut.call_procedure(request.type, request.args)
        local expected_result = qlua.getOrderByNumber.Result()
        struct_factory.create_Order(first, expected_result.order)
        expected_result.indx = second
    
        assert.are.equal(expected_result:SerializeToString(), actual_result:SerializeToString())
      end)
    
      insulate("AND the global 'getOrderByNumber' function returns nil", function()
          
        setup(function()
          _G.getOrderByNumber = spy.new(function(class_code, order_id) return nil end)
        end)
      
        it("SHOULD raise an error", function()
          assert.has_error(function() sut.call_procedure(request.type, request.args) end, string.format("Процедура getOrderByNumber(%s, %d) вернула (nil, nil).", request_args.class_code, request_args.order_id))
        end)
      end)
    end)
  
    describe("WITHOUT arguments", function()
      
      it("SHOULD raise an error", function()
        
        assert.has_error(function() sut.call_procedure(request.type) end, "The request has no arguments.")
      end)
    end)
  end)

end)
