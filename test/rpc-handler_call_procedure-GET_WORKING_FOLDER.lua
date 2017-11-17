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
  
    it("SHOULD call the global 'getWorkingFolder' function once", function()
        
      local response = sut.call_procedure(request.type)
    
      assert.spy(_G.getWorkingFolder).was.called()
    end)
  
    it("SHOULD return a qlua.getWorkingFolder.Result instance", function()
        
      local actual_result = sut.call_procedure(request.type)
      local expected_result = qlua.getWorkingFolder.Result()
      
      local actual_meta = getmetatable(actual_result)
      local expected_meta = getmetatable(expected_result)
      
      assert.are.equal(expected_meta, actual_meta)
    end)

    it("SHOULD return a protobuf object which string-serialized form equals to that of the expected result", function()
        
      local actual_result = sut.call_procedure(request.type)
      local expected_result = qlua.getWorkingFolder.Result()
      expected_result.working_folder = proc_result
      
      assert.are.equal(expected_result:SerializeToString(), actual_result:SerializeToString())
    end)
  end)

end)
