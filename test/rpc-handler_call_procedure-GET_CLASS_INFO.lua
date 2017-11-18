package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.rpc-handler", function()
  
  local qlua = require("qlua.api")
  local struct_factory = require("utils.struct_factory")
  local sut = require("impl.rpc-handler")

  describe("WHEN given a request of type ProcedureType.GET_CLASS_INFO", function()
      
    local request
    
    setup(function()
      
      request = {}
      request.type = qlua.RPC.ProcedureType.GET_CLASS_INFO
    end)
  
    teardown(function()
      request = nil
    end)

    insulate("WITH arguments", function()
        
      local request_args
      local proc_result
      
      setup(function()
      
        request_args = qlua.getClassInfo.Request()
        request_args.class_code = "test-class_code"
        
        request.args = request_args:SerializeToString()

        proc_result = {
          firmid = "test-firmid", 
          name = "test-name", 
          code = "test-code", 
          npars = 54, 
          nsecs = 45
        }
        
        _G.getClassInfo = spy.new(function(class_code) return proc_result end)
      end)

      teardown(function()

        request_args = nil
        proc_result = nil
      end)
    
      it("SHOULD call the global 'getClassInfo' function once, passing the procedure arguments to it", function()
        
        local response = sut.call_procedure(request.type, request.args)
    
        assert.spy(_G.getClassInfo).was.called_with(request_args.class_code)
      end)
    
      it("SHOULD return a qlua.getClassInfo.Result instance", function()
          
        local actual_result = sut.call_procedure(request.type, request)
        local expected_result = qlua.getClassInfo.Result()
        
        local actual_meta = getmetatable(actual_result)
        local expected_meta = getmetatable(expected_result)
        
        assert.are.equal(expected_meta, actual_meta)
      end)
    
      it("SHOULD return a protobuf object which string-serialized form equals to that of the expected result", function()
        
        local actual_result = sut.call_procedure(request.type, request)
        local expected_result = qlua.getClassInfo.Result()
        
        struct_factory.create_Klass(proc_result, expected_result.class_info)
        
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
