package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.rpc-handler", function()
  
  local qlua = require("qlua.api")
  local struct_factory = require("utils.struct_factory")
  local sut = require("impl.rpc-handler")

  describe("WHEN given a request of type ProcedureType.GET_MONEY_EX", function()
      
    local request
    
    setup(function()
      
      request = {}
      request.type = qlua.RPC.ProcedureType.GET_MONEY_EX
    end)
  
    teardown(function()
      request = nil
    end)

    insulate("WITH arguments", function()
        
      local request_args
      local proc_result
      
      setup(function()

        request_args = qlua.getMoneyEx.Request()
        request_args.firmid = "test-firmid"
        request_args.client_code = "test-client_code"
        request_args.tag = "test_tag"
        request_args.currcode = "test_currcode"
        request_args.limit_kind = 2
        
        request.args = request_args:SerializeToString()

        proc_result = {
          currcode = "test-currcode", 
          tag = "test-tag", 
          firmid = "test-firmid", 
          client_code = "test-client_code", 
          openbal = 567.89, 
          openlimit = 234.56, 
          currentbal = 456.78, 
          currentlimit = 123.45, 
          locked = 12.98, 
          locked_value_coef = 0.5, 
          locked_margin_value = 9.88, 
          leverage = 3.0, 
          limit_kind = 0
        }
        
        _G.getMoneyEx = spy.new(function(firmid, client_code, tag, currcode, limit_kind) return proc_result end)
      end)

      teardown(function()

        request_args = nil
        proc_result = nil
      end)
    
      it("SHOULD call the global 'getMoneyEx' function once, passing the procedure arguments to it", function()
        
        local response = sut.call_procedure(request.type, request.args)
    
        assert.spy(_G.getMoneyEx).was.called_with(request_args.firmid, request_args.client_code, request_args.tag, request_args.currcode, request_args.limit_kind)
      end)
    
      it("SHOULD return a qlua.getMoneyEx.Result instance", function()
          
        local actual_result = sut.call_procedure(request.type, request.args)
        local expected_result = qlua.getMoneyEx.Result()
        
        local actual_meta = getmetatable(actual_result)
        local expected_meta = getmetatable(expected_result)
        
        assert.are.equal(expected_meta, actual_meta)
      end)
    
      it("SHOULD return a protobuf object which string-serialized form equals to that of the expected result", function()
        
        local actual_result = sut.call_procedure(request.type, request.args)
        local expected_result = qlua.getMoneyEx.Result()
        
        struct_factory.create_MoneyLimit(proc_result, expected_result.money_ex)
        
        assert.are.equal(expected_result:SerializeToString(), actual_result:SerializeToString())
      end)
    
      insulate("AND the global 'getMoneyEx' function returns nil", function()
          
        setup(function()
          _G.getMoneyEx = spy.new(function(firmid, client_code, tag, currcode, limit_kind) return nil end)
        end)
      
        it("SHOULD raise an error", function()
          assert.has_error(function() sut.call_procedure(request.type, request.args) end, string.format("Процедура getMoneyEx(%s, %s, %s, %s, %d) возвратила nil.", request_args.firmid, request_args.client_code, request_args.tag, request_args.currcode, request_args.limit_kind))
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
