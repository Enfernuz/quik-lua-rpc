package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.rpc-handler", function()
  
  local qlua = require("qlua.api")
  local sut = require("impl.rpc-handler")

  insulate("WHEN given a request of type ProcedureType.IS_CONNECTED", function()

    local request
    local rpc_result
    
    setup(function()
      
      request = {}
      request.type = qlua.RPC.ProcedureType.IS_CONNECTED
      
      rpc_result = 1
      
      _G.isConnected = spy.new(function() return rpc_result end)
    end)

    teardown(function()
        
      request = nil
    end)
  
    it("SHOULD call the global 'isConnected' function once", function()
        
      local response = sut.call_procedure(request.type)
    
      assert.spy(_G.isConnected).was.called()
    end)

    it("SHOULD return a qlua.isConnected.Result instance", function()
        
      local actual_result = sut.call_procedure(request.type)
      local expected_result = qlua.isConnected.Result()
        
      local actual_meta = getmetatable(actual_result)
      local expected_meta = getmetatable(expected_result)
      
      assert.are.equal(expected_meta, actual_meta)
    end)

    it("SHOULD return a protobuf object which string-serialized form equals to that of the expected result", function()
        
      local actual_result = sut.call_procedure(request.type)
      local expected_result = qlua.isConnected.Result()
      expected_result.is_connected = rpc_result

      assert.are.equal(expected_result:SerializeToString(), actual_result:SerializeToString())
    end)
  end)

end)
