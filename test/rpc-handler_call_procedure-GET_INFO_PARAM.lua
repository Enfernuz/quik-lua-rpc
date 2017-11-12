package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.rpc-handler", function()
  
  local qlua = require("qlua.api")
  local sut = require("impl.rpc-handler")

  describe("WHEN given a request of type ProcedureType.GET_INFO_PARAM", function()
      
    local request
    
    setup(function()
      
      request = {}
      request.type = qlua.RPC.ProcedureType.GET_INFO_PARAM
    end)
  
    teardown(function()
      request = nil
    end)

    insulate("WITH arguments", function()
        
      local request_args
      local rpc_result
      
      setup(function()
      
        request_args = qlua.getInfoParam.Request()
        request_args.param_name = "test-param_name"
        
        request.args = request_args:SerializeToString()

        rpc_result = "test-info_param"
        
        _G.getInfoParam = spy.new(function(param_name) return rpc_result end)
      end)

      teardown(function()

        request_args = nil
        rpc_result = nil
      end)
    
      it("SHOULD call the getInfoParam function once, passing the procedure arguments to it", function()
        
        local response = sut.call_procedure(request.type, request.args)
    
        assert.spy(_G.getInfoParam).was.called_with(request_args.param_name)
      end)
    
      it("SHOULD return a qlua.getInfoParam.Result with its data mapped to the result of the called procedure", function()
        
        local result = sut.call_procedure(request.type, request)
        
        local expected_meta = getmetatable( qlua.getInfoParam.Result() )
        local actual_meta = getmetatable(result)
        
        assert.are.equal(expected_meta, actual_meta)
        
        assert.are.equal(rpc_result, result.info_param)
      end)
    end)
  
    describe("WITHOUT arguments", function()
      
      it("SHOULD raise an error", function()
        
        assert.has_error(function() sut.call_procedure(request.type) end, "The request has no arguments.")
      end)
    end)
  end)

end)
