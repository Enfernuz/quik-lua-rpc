package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.rpc-handler", function()
  
  local qlua = require("qlua.api")
  local sut = require("impl.rpc-handler")

  insulate("WHEN given a request of type ProcedureType.GET_CLASSES_LIST", function()

    local request
    local proc_result
    
    setup(function()
      
      request = {}
      request.type = qlua.RPC.ProcedureType.GET_CLASSES_LIST
      
      proc_result = "TQBR,SPBFUT"
      
      _G.getClassesList = spy.new(function() return proc_result end)
    end)

    teardown(function()
        
      request = nil
      proc_result = nil
    end)
  
    it("SHOULD call the global 'getClassesList' function once", function()
        
      local response = sut.call_procedure(request.type)
    
      assert.spy(_G.getClassesList).was.called()
    end)
  
    it("SHOULD return a qlua.getClassesList.Result instance", function()
        
      local actual_result = sut.call_procedure(request.type)
      local expected_result = qlua.getClassesList.Result()
      
      local actual_meta = getmetatable(actual_result)
      local expected_meta = getmetatable(expected_result)
      
      assert.are.equal(expected_meta, actual_meta)
    end)

    it("SHOULD return a protobuf object which string-serialized form equals to that of the expected result", function()
        
      local actual_result = sut.call_procedure(request.type)
      local expected_result = qlua.getClassesList.Result()
      expected_result.classes_list = proc_result
      
      assert.are.equal(expected_result:SerializeToString(), actual_result:SerializeToString())
    end)
  end)

end)
