package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.rpc-handler", function()
  
  local qlua = require("qlua.api")
  local struct_converter = require("utils.struct_converter")
  local sut = require("impl.rpc-handler")

  describe("WHEN given a request of type ProcedureType.GET_PARAM_EX_2", function()
      
    local request
    
    setup(function()
      
      request = {}
      request.type = qlua.RPC.ProcedureType.GET_PARAM_EX_2
    end)
  
    teardown(function()
      request = nil
    end)

    insulate("WITH arguments", function()
        
      local request_args
      local proc_result
      
      setup(function()
      
        request_args = qlua.getParamEx2.Request()
        request_args.class_code = "test-class_code"
        request_args.sec_code = "test-sec_code"
        request_args.param_name = "test-param_name"
        
        request.args = request_args:SerializeToString()

        proc_result = {
          param_type ="test-param_type", 
          param_value = "test-param_value", 
          param_image = "test-param_image", 
          result = "test-result"
        }
        
        _G.getParamEx2 = spy.new(function(class_code, sec_code, param_name) return proc_result end)
      end)

      teardown(function()

        request_args = nil
        proc_result = nil
      end)
    
      it("SHOULD call the global 'getParamEx2' function once, passing the procedure arguments to it", function()
        
        local response = sut.call_procedure(request.type, request.args)
    
        assert.spy(_G.getParamEx2).was.called_with(request_args.class_code, request_args.sec_code, request_args.param_name)
      end)
    
      it("SHOULD return a qlua.getParamEx2.Result instance", function()
          
        local actual_result = sut.call_procedure(request.type, request.args)
        local expected_result = qlua.getParamEx2.Result()
        
        local actual_meta = getmetatable(actual_result)
        local expected_meta = getmetatable(expected_result)
        
        assert.are.equal(expected_meta, actual_meta)
      end)
    
      it("SHOULD return a protobuf object which string-serialized form equals to that of the expected result", function()
        
        local actual_result = sut.call_procedure(request.type, request.args)
        local expected_result = qlua.getParamEx2.Result()
        
        struct_converter.getParamEx2.ParamEx2(proc_result, expected_result.param_ex)
        
        assert.are.equal(expected_result:SerializeToString(), actual_result:SerializeToString())
      end)
    
      -----
      
      insulate("AND the global 'getParamEx2' function returns nil", function()
          
        setup(function()
          _G.getParamEx2 = spy.new(function(class_code, sec_code, param_name) return nil end)
        end)
      
        it("SHOULD raise an error", function()
          
          local expected_error_msg = string.format("Процедура getParamEx2(%s, %s, %s) возвратила nil.", request_args.class_code, request_args.sec_code, request_args.param_name)
          
          assert.has_error(function() sut.call_procedure(request.type, request.args) end, expected_error_msg)
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
