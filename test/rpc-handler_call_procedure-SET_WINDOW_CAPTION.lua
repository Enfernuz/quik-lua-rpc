package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.rpc-handler", function()
  
  local qlua = require("qlua.api")
  local sut = require("impl.rpc-handler")

  describe("WHEN given a request of type ProcedureType.SET_WINDOW_CAPTION", function()
      
    local request
    
    setup(function()
      
      request = {}
      request.type = qlua.RPC.ProcedureType.SET_WINDOW_CAPTION
    end)
  
    teardown(function()
      request = nil
    end)

    insulate("WITH arguments", function()
        
      local request_args
      local proc_result
      
      setup(function()
      
        request_args = qlua.SetWindowCaption.Request()
        request_args.t_id = 123
        request_args.str = "test-str"
        
        request.args = request_args:SerializeToString()

        proc_result = true
        
        _G.SetWindowCaption = spy.new(function(t_id, str) return proc_result end)
      end)

      teardown(function()

        request_args = nil
        proc_result = nil
      end)
    
      it("SHOULD call the global 'SetWindowCaption' function once, passing the procedure arguments to it", function()
        
        local response = sut.call_procedure(request.type, request.args)
    
        assert.spy(_G.SetWindowCaption).was.called_with(request_args.t_id, request_args.str)
      end)
    
      it("SHOULD return a qlua.SetWindowCaption.Result instance", function()
          
        local actual_result = sut.call_procedure(request.type, request)
        local expected_result = qlua.SetWindowCaption.Result()
        
        local actual_meta = getmetatable(actual_result)
        local expected_meta = getmetatable(expected_result)
        
        assert.are.equal(expected_meta, actual_meta)
      end)
    
      it("SHOULD return a protobuf object which string-serialized form equals to that of the expected result", function()
        
        local actual_result = sut.call_procedure(request.type, request)
        local expected_result = qlua.SetWindowCaption.Result()
        
        expected_result.result = proc_result
        
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
