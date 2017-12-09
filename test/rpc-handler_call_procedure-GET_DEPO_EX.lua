package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.rpc-handler", function()
  
  local qlua = require("qlua.api")
  local struct_factory = require("utils.struct_factory")
  local sut = require("impl.rpc-handler")

  describe("WHEN given a request of type ProcedureType.GET_DEPO_EX", function()
      
    local request
    
    setup(function()
      
      request = {}
      request.type = qlua.RPC.ProcedureType.GET_DEPO_EX
    end)
  
    teardown(function()
      request = nil
    end)

    insulate("WITH arguments", function()
        
      local request_args
      local proc_result
      
      setup(function()

        request_args = qlua.getDepoEx.Request()
        request_args.firmid = "test-firmid"
        request_args.client_code = "test-client_code"
        request_args.sec_code = "test-sec_code"
        request_args.trdaccid = "test-trdaccid"
        request_args.limit_kind = 1
        
        request.args = request_args:SerializeToString()

        proc_result = {
          sec_code = "test-sec_code", 
          trdaccid = "test-trdaccid", 
          firmid = "test-firmid", 
          client_code = "test-client_code", 
          openbal = 100, 
          openlimit = 150, 
          currentbal = 90, 
          currentlimit = 140, 
          locked_sell = 10, 
          locked_buy = 20, 
          locked_buy_value = 1200.60, 
          locked_sell_value = 600.30, 
          awg_position_price = 60.3, 
          limit_kind = 0
        }
        
        _G.getDepoEx = spy.new(function(firmid, client_code, sec_code, trdaccid, limit_kind) return proc_result end)
      end)

      teardown(function()

        request_args = nil
        proc_result = nil
      end)
    
      it("SHOULD call the global 'getDepoEx' function once, passing the procedure arguments to it", function()
        
        local response = sut.call_procedure(request.type, request.args)
    
        assert.spy(_G.getDepoEx).was.called_with(request_args.firmid, request_args.client_code, request_args.sec_code, request_args.trdaccid, request_args.limit_kind)
      end)
    
      it("SHOULD return a qlua.getDepoEx.Result instance", function()
          
        local actual_result = sut.call_procedure(request.type, request.args)
        local expected_result = qlua.getDepoEx.Result()
        
        local actual_meta = getmetatable(actual_result)
        local expected_meta = getmetatable(expected_result)
        
        assert.are.equal(expected_meta, actual_meta)
      end)
    
      it("SHOULD return a protobuf object which string-serialized form equals to that of the expected result", function()
        
        local actual_result = sut.call_procedure(request.type, request.args)
        local expected_result = qlua.getDepoEx.Result()
        
        struct_factory.create_DepoLimit(proc_result, expected_result.depo_ex)
        
        assert.are.equal(expected_result:SerializeToString(), actual_result:SerializeToString())
      end)
    
      insulate("AND the global 'getDepoEx' function returns nil", function()
          
        setup(function()
          _G.getDepoEx = spy.new(function(firmid, client_code, sec_code, trdaccid, limit_kind) return nil end)
        end)
      
        it("SHOULD raise an error", function()
          assert.has_error(function() sut.call_procedure(request.type, request.args) end, string.format("Процедура getDepoEx(%s, %s, %s, %s, %d) возвратила nil.", request_args.firmid, request_args.client_code, request_args.sec_code, request_args.trdaccid, request_args.limit_kind))
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
