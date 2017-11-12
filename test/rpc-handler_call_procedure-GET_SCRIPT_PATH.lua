package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.rpc-handler", function()
  
  local qlua = require("qlua.api")
  local sut = require("impl.rpc-handler")

  insulate("WHEN given a request of type ProcedureType.GET_SCRIPT_PATH", function()

    local request
    local rpc_result
    
    setup(function()
      
      request = {}
      request.type = qlua.RPC.ProcedureType.GET_SCRIPT_PATH
      
      rpc_result = "D:\\tmp\\QUIK\\lua\\blah-blah-blah\\"
      
      _G.getScriptPath = spy.new(function() return rpc_result end)
    end)

    teardown(function()
        
      request = nil
    end)
  
    it("SHOULD call the getScriptPath function once", function()
        
      local response = sut.call_procedure(request.type)
    
      assert.spy(_G.getScriptPath).was.called()
    end)

    it("SHOULD return a qlua.getScriptPath.Result with its data mapped to the result of the called procedure", function()
        
      local result = sut.call_procedure(request.type)
      
      local expected_meta = getmetatable( qlua.getScriptPath.Result() )
      local actual_meta = getmetatable(result)
      
      assert.are.equal(expected_meta, actual_meta)
      
      assert.are.equal(rpc_result, result.script_path)
    end)
  end)

end)
