package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.rpc-handler", function()
  
  local qlua = require("qlua.api")
  local bit = mock( require("bit") )
  local sut = require("impl.rpc-handler")
  
  describe("WHEN given a request of type ProcedureType.BIT_TOHEX", function()
      
    local request
    
    setup(function()
      
      request = {}
      request.type = qlua.RPC.ProcedureType.BIT_TOHEX
    end)
  
    teardown(function()
      request = nil
    end)

    describe("WITH arguments", function()
        
      local request_args
      
      setup(function()
      
        request_args = qlua.bit.tohex.Request()
        request_args.x = 127
        request_args.n = 2
        
        request.args = request_args:SerializeToString()
      end)

      teardown(function()

        request_args = nil
      end)
    
      it("SHOULD call the global 'bit.tohex' function once, passing the procedure arguments to it", function()
        local response = sut.call_procedure(request.type, request.args)
    
        assert.spy(bit.tohex).was.called_with(request_args.x, request_args.n)
        
        bit.tohex:clear()
      end)
    
      it("SHOULD return a qlua.bit.tohex.Result instance", function()
          
        local actual_result = sut.call_procedure(request.type, request.args)
        local expected_result = qlua.bit.tohex.Result()
        
        local actual_meta = getmetatable(actual_result)
        local expected_meta = getmetatable(expected_result)
        
        assert.are.equal(expected_meta, actual_meta)
      end)
    
      it("SHOULD return a protobuf object which string-serialized form equals to that of the expected result", function()

        local actual_result = sut.call_procedure(request.type, request.args)
        local expected_result = qlua.bit.tohex.Result()

        expected_result.result = bit.tohex(request_args.x, request_args.n)
        
        assert.are.equal(expected_result:SerializeToString(), actual_result:SerializeToString())
      end)
    
      describe("WHERE the argument 'n' is 0", function()
          
        setup(function()
      
          request_args.n = 0
          request.args = request_args:SerializeToString()
        end)

        teardown(function()

          request_args.n = 2
          request.args = request_args:SerializeToString()
        end)
      
        it("SHOULD call the global 'bit.tohex' function once, passing only the 'x' argument to it", function()
          local response = sut.call_procedure(request.type, request.args)
      
          assert.spy(bit.tohex).was.called_with(request_args.x)
          
          bit.tohex:clear()
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
