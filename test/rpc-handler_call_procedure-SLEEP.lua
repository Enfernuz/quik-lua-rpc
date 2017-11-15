package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.rpc-handler", function()
  
  local qlua = require("qlua.api")
  local sut = require("impl.rpc-handler")

  describe("WHEN given a request of type ProcedureType.SLEEP", function()
      
    local request
    
    setup(function()
      
      request = {}
      request.type = qlua.RPC.ProcedureType.SLEEP
    end)
  
    teardown(function()
      request = nil
    end)

    insulate("WITH arguments", function()
        
      local request_args
      local proc_result
      
      setup(function()
      
        request_args = qlua.sleep.Request()
        request_args.time = 100500
        
        request.args = request_args:SerializeToString()

        proc_result = 1
        
        _G.sleep = spy.new(function(time) return proc_result end)
      end)

      teardown(function()

        request_args = nil
        proc_result = nil
      end)
    
      it("SHOULD call the sleep function once, passing the procedure arguments to it", function()
        
        local response = sut.call_procedure(request.type, request.args)
    
        assert.spy(_G.sleep).was.called_with(request_args.time)
      end)
    
      it("SHOULD return a qlua.sleep.Result with its data mapped to the result of the called procedure", function()
        
        local result = sut.call_procedure(request.type, request)
        
        local expected_meta = getmetatable( qlua.sleep.Result() )
        local actual_meta = getmetatable(result)
        
        assert.are.equal(expected_meta, actual_meta)
        
        assert.are.equal(proc_result, result.result)
      end)
    end)
  
    describe("WITHOUT arguments", function()
      
      it("SHOULD raise an error", function()
        
        assert.has_error(function() sut.call_procedure(request.type) end, "The request has no arguments.")
      end)
    end)
  end)

end)
