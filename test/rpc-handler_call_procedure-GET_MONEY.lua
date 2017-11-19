package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.rpc-handler", function()
  
  local qlua = require("qlua.api")
  local struct_converter = require("utils.struct_converter")
  local sut = require("impl.rpc-handler")

  describe("WHEN given a request of type ProcedureType.GET_MONEY", function()
      
    local request
    
    setup(function()
      
      request = {}
      request.type = qlua.RPC.ProcedureType.GET_MONEY
    end)
  
    teardown(function()
      request = nil
    end)

    insulate("WITH arguments", function()
        
      local request_args
      local proc_result
      
      setup(function()
      
        request_args = qlua.getMoney.Request()
        request_args.client_code = "test-client_code"
        request_args.firmid = "test-firmid"
        request_args.tag = "test-tag"
        request_args.currcode = "currcode"
        
        request.args = request_args:SerializeToString()

        proc_result = {
          money_open_limit = 100500.30, 
          money_limit_locked_nonmarginal_value = 99.8, 
          money_limit_locked = 99, 
          money_open_balance = 200000, 
          money_current_limit = 100000.1,
          money_current_balance = 199999.99, 
          money_limit_available = 500.500
        }
        
        _G.getMoney = spy.new(function(client_code, firmid, tag, currcode) return proc_result end)
      end)

      teardown(function()

        request_args = nil
        proc_result = nil
      end)
    
      it("SHOULD call the global 'getMoney' function once, passing the procedure arguments to it", function()
        
        local response = sut.call_procedure(request.type, request.args)
    
        assert.spy(_G.getMoney).was.called_with(request_args.client_code, request_args.firmid, request_args.tag, request_args.currcode)
      end)
    
      it("SHOULD return a qlua.getMoney.Result instance", function()
          
        local actual_result = sut.call_procedure(request.type, request)
        local expected_result = qlua.getMoney.Result()
        
        local actual_meta = getmetatable(actual_result)
        local expected_meta = getmetatable(expected_result)
        
        assert.are.equal(expected_meta, actual_meta)
      end)
    
      it("SHOULD return a protobuf object which string-serialized form equals to that of the expected result", function()
        
        local actual_result = sut.call_procedure(request.type, request)
        local expected_result = qlua.getMoney.Result()
        
        struct_converter.getMoney.Money(proc_result, expected_result.money)
        
        assert.are.equal(expected_result:SerializeToString(), actual_result:SerializeToString())
      end)
    end)
  
    describe("WITHOUT arguments", function()
      
      it("SHOULD raise an error", function()
        
        assert.has_error(function() sut.call_procedure(request.type) end, "The request has no arguments.")
      end)
    end)
  end)

end)
