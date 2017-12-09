package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.rpc-handler", function()
  
  local qlua = require("qlua.api")
  local bit = mock( require("bit") )
  local sut = require("impl.rpc-handler")
  
  describe("WHEN given a request of type ProcedureType.BIT_BAND", function()
      
    local request
    
    setup(function()
      
      request = {}
      request.type = qlua.RPC.ProcedureType.BIT_BAND
    end)
  
    teardown(function()
      request = nil
    end)

    describe("WITH arguments", function()
        
      local request_args, arr
      
      setup(function()
      
        request_args = qlua.bit.band.Request()
        request_args.x1 = 1
        request_args.x2 = 8
        table.insert(request_args.xi, 4)
        table.insert(request_args.xi, 2)
        
        arr = {request_args.x1, request_args.x2, request_args.xi[1], request_args.xi[2]}
        
        request.args = request_args:SerializeToString()
        
        _G.table.sinsert = spy.new(function(t,el) return table.insert(t, el) end)
      end)

      teardown(function()

        request_args = nil
        arr = nil
      end)
    
      it("SHOULD call the global 'bit.band' function once, passing the unpacked array {x1, x2, xi[1], xi[2], ..., xi[#xi]} to it", function()
        local response = sut.call_procedure(request.type, request.args)
        
        assert.spy(bit.band).was.called_with( unpack(arr) )
        
        bit.band:revert()
      end)
    
      it("SHOULD return a qlua.bit.band.Result instance", function()
          
        local actual_result = sut.call_procedure(request.type, request.args)
        local expected_result = qlua.bit.band.Result()
        
        local actual_meta = getmetatable(actual_result)
        local expected_meta = getmetatable(expected_result)
        
        assert.are.equal(expected_meta, actual_meta)
      end)
    
      it("SHOULD return a protobuf object which string-serialized form equals to that of the expected result", function()

        local actual_result = sut.call_procedure(request.type, request.args)
        local expected_result = qlua.bit.band.Result()

        expected_result.result = bit.band( unpack(arr) )
        
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
