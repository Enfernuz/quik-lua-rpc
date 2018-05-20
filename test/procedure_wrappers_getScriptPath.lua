package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

require("test.mock_qlua")

describe("impl.procedure_wrappers", function()
  
  local sut = require("impl.procedure_wrappers")

  insulate("WHEN its 'getScriptPath' member-function has been invoked", function()

    local method = "getScriptPath"
    local qlua_func_result

    setup(function()
      
      qlua_func_result = "D:\\tmp\\QUIK\\lua\\blah-blah-blah\\"
      _G.getScriptPath = spy.new(function() return qlua_func_result end)
    end)

    teardown(function()
      qlua_func_result = nil
    end)
  
    it("SHOULD call the global 'getScriptPath' function once and return its result", function()
        
      local proc_result = sut[method]()
    
      assert.spy(_G.getScriptPath).was.called()
      assert.are.equal(qlua_func_result, proc_result)
    end)
  end)
end)
