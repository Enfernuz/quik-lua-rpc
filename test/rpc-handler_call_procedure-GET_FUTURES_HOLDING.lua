package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.rpc-handler", function()
  
  local qlua = require("qlua.api")
  local struct_factory = require("utils.struct_factory")
  local sut = require("impl.rpc-handler")

  describe("WHEN given a request of type ProcedureType.GET_FUTURES_HOLDING", function()
      
    local request
    
    setup(function()
      
      request = {}
      request.type = qlua.RPC.ProcedureType.GET_FUTURES_HOLDING
    end)
  
    teardown(function()
      request = nil
    end)

    insulate("WITH arguments", function()
        
      local request_args
      local proc_result
      
      setup(function()

        request_args = qlua.getFuturesHolding.Request()
        request_args.firmid = "test-firmid"
        request_args.trdaccid = "test-trdaccid"
        request_args.sec_code = "test-sec_code"
        request_args.type = 2
        
        request.args = request_args:SerializeToString()

        proc_result = {
          firmid = "test-firmid", 
          trdaccid = "test-trdaccid", 
          sec_code = "test-sec_code", 
          type = 2, 
          startbuy = 13.95, 
          startsell = 15.03, 
          todaybuy = 14.43, 
          todaysell = 14.99, 
          totalnet = 5.56, 
          openbuys = 25, 
          opensells = 20, 
          cbplused = 300.01, 
          cbplplanned = 299.98, 
          varmargin = 7.87, 
          avrposnprice = 14.50, 
          positionvalue = 14.34, 
          real_varmargin = 7.42, 
          total_varmargin = 7.24, 
          session_status = 1
        }
        
        _G.getFuturesHolding = spy.new(function(firmid, trdaccid, sec_code, _type) return proc_result end)
      end)

      teardown(function()

        request_args = nil
        proc_result = nil
      end)
    
      it("SHOULD call the global 'getFuturesHolding' function once, passing the procedure arguments to it", function()
        
        local response = sut.call_procedure(request.type, request.args)
    
        assert.spy(_G.getFuturesHolding).was.called_with(request_args.firmid, request_args.trdaccid, request_args.sec_code, request_args.type)
      end)
    
      it("SHOULD return a qlua.getFuturesHolding.Result instance", function()
          
        local actual_result = sut.call_procedure(request.type, request.args)
        local expected_result = qlua.getFuturesHolding.Result()
        
        local actual_meta = getmetatable(actual_result)
        local expected_meta = getmetatable(expected_result)
        
        assert.are.equal(expected_meta, actual_meta)
      end)
    
      it("SHOULD return a protobuf object which string-serialized form equals to that of the expected result", function()
        
        local actual_result = sut.call_procedure(request.type, request.args)
        local expected_result = qlua.getFuturesHolding.Result()
        
        struct_factory.create_FuturesClientHolding(proc_result, expected_result.futures_holding)
        
        assert.are.equal(expected_result:SerializeToString(), actual_result:SerializeToString())
      end)
    
      insulate("AND the global 'getFuturesHolding' function returns nil", function()
          
        setup(function()
          _G.getFuturesHolding = spy.new(function(firmid, trdaccid, sec_code, _type) return nil end)
        end)
      
        it("SHOULD raise an error", function()
          assert.has_error(function() sut.call_procedure(request.type, request.args) end, string.format("Процедура getFuturesHolding(%s, %s, %s, %d) возвратила nil.", request_args.firmid, request_args.trdaccid, request_args.sec_code, request_args.type))
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
