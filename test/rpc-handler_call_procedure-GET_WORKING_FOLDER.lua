package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.rpc-handler", function()
  
  local qlua = require("qlua.api")
  local sut = require("impl.rpc-handler")

  insulate("WHEN given a request of type ProcedureType.GET_WORKING_FOLDER", function()

    local request
    local proc_result
    
    setup(function()
      
      request = {}
      request.type = qlua.RPC.ProcedureType.GET_WORKING_FOLDER
      
      proc_result = "C:\\blah\\blah\\blah\\QUIK"
      
      _G.getWorkingFolder = spy.new(function() return proc_result end)
    end)

    teardown(function()
        
      request = nil
    end)
  
    it("SHOULD call the getWorkingFolder function once", function()
        
      local response = sut.call_procedure(request.type)
    
      assert.spy(_G.getWorkingFolder).was.called()
    end)

    it("SHOULD return a qlua.getWorkingFolder.Result with its data mapped to the result of the called procedure", function()
        
      local result = sut.call_procedure(request.type)
      
      local expected_meta = getmetatable( qlua.getWorkingFolder.Result() )
      local actual_meta = getmetatable(result)
      
      assert.are.equal(expected_meta, actual_meta)
      
      assert.are.equal(proc_result, result.working_folder)
    end)
  end)

end)
