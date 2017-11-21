package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.rpc-handler", function()
  
  local qlua = require("qlua.api")
  local struct_converter = require("utils.struct_converter")
  local sut = require("impl.rpc-handler")

  describe("WHEN given a request of type ProcedureType.GET_QUOTE_LEVEL2", function()
      
    local request
    
    setup(function()
      
      request = {}
      request.type = qlua.RPC.ProcedureType.GET_QUOTE_LEVEL2
    end)
  
    teardown(function()
      request = nil
    end)

    insulate("WITH arguments", function()
        
      local request_args
      local proc_result
      
      setup(function()
      
        request_args = qlua.getQuoteLevel2.Request()
        request_args.class_code = "test-class_code"
        request_args.sec_code = "test-sec_code"
        
        request.args = request_args:SerializeToString()

        proc_result = {
          bid_count = "5", 
          offer_count = "2", 
          bid = {
            {price = "101.1", quantity = "1"}, 
            {price = "101.5", quantity = "3"}, 
            {price = "102.0", quantity = "1"}, 
            {price = "102.9", quantity = "2"},
            {price = "105", quantity = "1"}
          }, 
          offer = {
            {price = "100", quantity = "1"},
            {price = "99.9", quantity = "1"}
          }
        }
        
        _G.getQuoteLevel2 = spy.new(function(class_code, sec_code) return proc_result end)
        _G.table.sinsert = spy.new(function(t, el) return table.insert(t, el) end)
      end)

      teardown(function()

        request_args = nil
        proc_result = nil
      end)
    
      it("SHOULD call the global 'getQuoteLevel2' function once, passing the procedure arguments to it", function()
        
        local response = sut.call_procedure(request.type, request.args)
    
        assert.spy(_G.getQuoteLevel2).was.called_with(request_args.class_code, request_args.sec_code)
      end)
    
      it("SHOULD return a qlua.getQuoteLevel2.Result instance", function()
          
        local actual_result = sut.call_procedure(request.type, request)
        local expected_result = qlua.getQuoteLevel2.Result()
        
        local actual_meta = getmetatable(actual_result)
        local expected_meta = getmetatable(expected_result)
        
        assert.are.equal(expected_meta, actual_meta)
      end)
    
      it("SHOULD return a protobuf object which string-serialized form equals to that of the expected result", function()
        
        local actual_result = sut.call_procedure(request.type, request)
        local expected_result = struct_converter.getQuoteLevel2.Result(proc_result)
        
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
