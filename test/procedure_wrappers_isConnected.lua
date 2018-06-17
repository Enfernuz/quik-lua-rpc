package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.procedure_wrappers", function()
  
  local sut = require("impl.procedure_wrappers")

  insulate("WHEN its 'isConnected' member-function has been invoked", function()

    local method = "isConnected"
    local qlua_func_result

    setup(function()
      
      qlua_func_result = 1
      _G.isConnected = spy.new(function() return qlua_func_result end)
    end)

    teardown(function()
      qlua_func_result = nil
    end)
  
    it("SHOULD call the global 'isConnected' function once and return its result", function()
        
      local proc_result = sut[method]()
    
      assert.spy(_G.isConnected).was.called()
      assert.are.equal(qlua_func_result, proc_result)
    end)
  end)
end)
