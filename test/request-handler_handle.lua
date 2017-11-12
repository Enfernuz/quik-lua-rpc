package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.request-handler", function()
  
  local qlua = require("qlua.api")
  local protobuf = require("protobuf")
  local sut = require("impl.request-handler")

  describe("WHEN given a request", function()

    local request
    local rpc_handler
    local result_stub
    
    setup(function()
      
      request = {}
      request.type = 101
      request.args = {a = 1, b = '2', c = {}}
      
      rpc_handler = mock( require("impl.rpc-handler") )
      
      result_stub = qlua.isConnected.Result()
      result_stub.is_connected = 1
      
      rpc_handler.call_procedure = spy.new(function() return result_stub end)
    end)

    teardown(function()
        
      request = nil
      rpc_handler = nil
      result_stub = nil
    end)

    it("SHOULD return a qlua.RPC.Response with the 'type' field equal to that of the request and the 'is_error' field set to false", function()
        
      local response = sut:handle(request)
      
      local expected_meta = getmetatable( qlua.RPC.Response() )
      local actual_meta = getmetatable(response)
      
      assert.are.equal(expected_meta, actual_meta)
      assert.are.equal(request.type, response.type)
      assert.is_not_true(response.is_error)
    end)
  
    it("SHOULD call the rpc-handler's call_procedure function once, passing the request type as the 1st arg and the request args as the 2nd arg", function()
        
      local response = sut:handle(request)
    
      assert.spy(rpc_handler.call_procedure).was.called()
      assert.spy(rpc_handler.call_procedure).was.called_with(request.type, request.args)
    end)
  
    
    it("SHOULD return a qlua.RPC.Response with the 'result' field matches to the serialized to string instance of the protobuf object returned by the rpc-handler", function()

      local response = sut:handle(request)
      
      assert.are.equal(result_stub:SerializeToString(), response.result)
    end)
    
    
    insulate("AND there's an error occured in the rpc-handler's call_procedure function", function()
        
      local error_msg = "test error message"
      rpc_handler.call_procedure = spy.new(function() error("test error message", 0) end)
      
      it("SHOULD return the response with the field 'is_error' set to true and the field 'result' contained the error's message", function()
        
        local response = sut:handle(request)

        assert.are.equal(true, response.is_error)
        assert.are.equal(error_msg, response.result)
      end)
    end)
  end)

end)
