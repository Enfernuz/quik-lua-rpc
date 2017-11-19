package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.rpc-handler", function()
  
  local qlua = require("qlua.api")
  local struct_factory = require("utils.struct_factory")
  local sut = require("impl.rpc-handler")

  describe("WHEN given a request of type ProcedureType.GET_FUTURES_LIMIT", function()
      
    local request
    
    setup(function()
      
      request = {}
      request.type = qlua.RPC.ProcedureType.GET_FUTURES_LIMIT
    end)
  
    teardown(function()
      request = nil
    end)

    insulate("WITH arguments", function()
        
      local request_args
      local proc_result
      
      setup(function()

        request_args = qlua.getFuturesLimit.Request()
        request_args.firmid = "test-firmid"
        request_args.trdaccid = "test-trdaccid"
        request_args.limit_type = 1
        request_args.currcode = "test-currcode"
        
        request.args = request_args:SerializeToString()

        proc_result = {
          firmid = "test-firmid",
          trdaccid = "test-trdaccid", 
          limit_type = 1, 
          liquidity_coef = 0.56,
          cbp_prev_limit = 123.4, 
          cbplimit = 234.56, 
          cbplused = 345.6, 
          cbplplanned = 456.78, 
          varmargin = 98.89, 
          accruedint = 12.3, 
          cbplused_for_orders = 32.19, 
          cbplused_for_positions = 19.23, 
          options_premium = 77.89, 
          ts_comission = 0.81, 
          kgo = 4567, 
          currcode = "test-currcode", 
          real_varmargin = 83.91
        }
        
        _G.getFuturesLimit = spy.new(function(firmid, trdaccid, limit_type, currcode) return proc_result end)
      end)

      teardown(function()

        request_args = nil
        proc_result = nil
      end)
    
      it("SHOULD call the global 'getFuturesLimit' function once, passing the procedure arguments to it", function()
        
        local response = sut.call_procedure(request.type, request.args)
    
        assert.spy(_G.getFuturesLimit).was.called_with(request_args.firmid, request_args.trdaccid, request_args.limit_type, request_args.currcode)
      end)
    
      it("SHOULD return a qlua.getFuturesLimit.Result instance", function()
          
        local actual_result = sut.call_procedure(request.type, request)
        local expected_result = qlua.getFuturesLimit.Result()
        
        local actual_meta = getmetatable(actual_result)
        local expected_meta = getmetatable(expected_result)
        
        assert.are.equal(expected_meta, actual_meta)
      end)
    
      it("SHOULD return a protobuf object which string-serialized form equals to that of the expected result", function()
        
        local actual_result = sut.call_procedure(request.type, request)
        local expected_result = qlua.getFuturesLimit.Result()
        
        struct_factory.create_FuturesLimit(proc_result, expected_result.futures_limit)
        
        assert.are.equal(expected_result:SerializeToString(), actual_result:SerializeToString())
      end)
    
      insulate("AND the global 'getFuturesLimit' function returns nil", function()
          
        setup(function()
          _G.getFuturesLimit = spy.new(function(firmid, trdaccid, limit_type, currcode) return nil end)
        end)
      
        it("SHOULD raise an error", function()
          assert.has_error(function() sut.call_procedure(request.type, request.args) end, string.format("Процедура getFuturesLimit(%s, %s, %d, %s) возвратила nil.", request_args.firmid, request_args.trdaccid, request_args.limit_type, request_args.currcode))
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
