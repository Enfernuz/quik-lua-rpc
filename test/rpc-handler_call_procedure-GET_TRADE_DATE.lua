package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.rpc-handler", function()
  
  local qlua = require("qlua.api")
  local struct_converter = require("utils.struct_converter")
  local sut = require("impl.rpc-handler")

  insulate("WHEN given a request of type ProcedureType.GET_TRADE_DATE", function()

    local request
    local proc_result
    
    setup(function()
      
      request = {}
      request.type = qlua.RPC.ProcedureType.GET_TRADE_DATE
      
      proc_result = {
        date = "01.02.2017", 
        year = 2017, 
        month = 2, 
        day = 1
      }
      
      _G.getTradeDate = spy.new(function() return proc_result end)
    end)

    teardown(function()
        
      request = nil
      proc_result = nil
    end)
  
    it("SHOULD call the global 'getTradeDate' function once", function()
        
      local response = sut.call_procedure(request.type)
    
      assert.spy(_G.getTradeDate).was.called(1)
    end)
  
    it("SHOULD return a qlua.getTradeDate.Result instance", function()
        
      local actual_result = sut.call_procedure(request.type)
      local expected_result = qlua.getTradeDate.Result()
      
      local actual_meta = getmetatable(actual_result)
      local expected_meta = getmetatable(expected_result)
      
      assert.are.equal(expected_meta, actual_meta)
    end)

    it("SHOULD return a protobuf object which string-serialized form equals to that of the expected result", function()
        
      local actual_result = sut.call_procedure(request.type)
      local expected_result = qlua.getTradeDate.Result()
      struct_converter.getTradeDate.TradeDate(proc_result, expected_result.trade_date)
      
      assert.are.equal(expected_result:SerializeToString(), actual_result:SerializeToString())
    end)
  end)

end)
