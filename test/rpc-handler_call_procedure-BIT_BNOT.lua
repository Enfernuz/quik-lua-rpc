package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.rpc-handler", function()
  
  local qlua = require("qlua.api")
  local bit = mock( require("bit") )
  local sut = require("impl.rpc-handler")
  
  describe("WHEN given a request of type ProcedureType.BIT_BNOT", function()
      
    local request
    
    setup(function()
      
      request = {}
      request.type = qlua.RPC.ProcedureType.BIT_BNOT
    end)
  
    teardown(function()
      request = nil
    end)

    describe("WITH arguments", function()
        
      local request_args
      
      setup(function()
      
        request_args = qlua.bit.tohex.Request()
        request_args.x = 255
        
        request.args = request_args:SerializeToString()
      end)

      teardown(function()

        request_args = nil
      end)
    
      it("SHOULD call the global 'bit.bnot' function once, passing the procedure arguments to it", function()
        local response = sut.call_procedure(request.type, request.args)
    
        assert.spy(bit.bnot).was.called_with(request_args.x)
        
        bit.tohex:clear()
      end)
    
      it("SHOULD return a qlua.bit.bnot.Result instance", function()
          
        local actual_result = sut.call_procedure(request.type, request.args)
        local expected_result = qlua.bit.bnot.Result()
        
        local actual_meta = getmetatable(actual_result)
        local expected_meta = getmetatable(expected_result)
        
        assert.are.equal(expected_meta, actual_meta)
      end)
    
      it("SHOULD return a protobuf object which string-serialized form equals to that of the expected result", function()

        local actual_result = sut.call_procedure(request.type, request.args)
        local expected_result = qlua.bit.bnot.Result()

        expected_result.result = bit.bnot(request_args.x)
        
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
