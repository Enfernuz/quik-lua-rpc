package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.rpc-handler", function()
  
  local qlua = require("qlua.api")
  local sut = require("impl.rpc-handler")

  describe("WHEN given a request of type ProcedureType.CALC_BUY_SELL", function()
      
    local request
    
    setup(function()
      
      request = {}
      request.type = qlua.RPC.ProcedureType.CALC_BUY_SELL
    end)
  
    teardown(function()
      request = nil
    end)

    insulate("WITH arguments", function()
        
      local request_args
      local proc_result_qty, proc_result_comission
      
      setup(function()
      
        request_args = qlua.CalcBuySell.Request()
        request_args.class_code = "test-class_code"
        request_args.sec_code = "test-sec_code"
        request_args.client_code = "test-client_code"
        request_args.account = "test-account"
        request_args.price = "1234.56"
        request_args.is_buy = true
        request_args.is_market = true
        
        request.args = request_args:SerializeToString()

        proc_result_qty = 99
        proc_result_comission = 0.54
        
        _G.CalcBuySell = spy.new(function(class_code, sec_code, client_code, account, price, is_buy, is_market) return proc_result_qty, proc_result_comission end)
      end)

      teardown(function()

        request_args = nil
        proc_result_qty = nil
        proc_result_comission = nil
      end)
    
      it("SHOULD call the global 'CalcBuySell' function once, passing the procedure arguments to it AND the 'price' argument must be converted to number", function()
        
        local response = sut.call_procedure(request.type, request.args)
    
        assert.spy(_G.CalcBuySell).was.called_with(request_args.class_code, request_args.sec_code, request_args.client_code, request_args.account, tonumber(request_args.price), request_args.is_buy, request_args.is_market)
      end)
    
      it("SHOULD return a qlua.CalcBuySell.Result instance", function()
          
        local actual_result = sut.call_procedure(request.type, request.args)
        local expected_result = qlua.CalcBuySell.Result()
        
        local actual_meta = getmetatable(actual_result)
        local expected_meta = getmetatable(expected_result)
        
        assert.are.equal(expected_meta, actual_meta)
      end)
    
      it("SHOULD return a protobuf object which string-serialized form equals to that of the expected result", function()
        
        local actual_result = sut.call_procedure(request.type, request.args)
        local expected_result = qlua.CalcBuySell.Result()
        
        expected_result.qty = proc_result_qty
        expected_result.comission = tostring(proc_result_comission)
        
        assert.are.equal(expected_result:SerializeToString(), actual_result:SerializeToString())
      end)
    
      -----
      
      insulate("AND the 'price' argument cannot be converted to a number", function()
        
        local tmp
        
        setup(function()
            
          tmp = request_args.price
          request_args.price = "not a number"
          
          request.args = request_args:SerializeToString()
        end)
      
        teardown(function()
            
          request_args.price = tmp
          tmp = nil
          
          request.args = request_args:SerializeToString()
        end)
      
        it("SHOULD raise an error", function()
            
          local expected_error_msg = string.format("Не удалось преобразовать в число значение '%s' параметра price", request_args.price)
            
          assert.has_error(function() sut.call_procedure(request.type, request.args) end, expected_error_msg)
        end)
      end)
    end)
  
    -----
  
    describe("WITHOUT arguments", function()
      
      it("SHOULD raise an error", function()
        
        assert.has_error(function() sut.call_procedure(request.type) end, "The request has no arguments.")
      end)
    end)
  end)

end)
