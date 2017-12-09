package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.rpc-handler", function()
  
  local qlua = require("qlua.api")
  local sut = require("impl.rpc-handler")

  describe("WHEN given a request of type ProcedureType.DS_CLOSE", function()
      
    local request
    
    setup(function()
      
      request = {}
      request.type = qlua.RPC.ProcedureType.DS_CLOSE
    end)
  
    teardown(function()
      request = nil
    end)

    insulate("WITH arguments", function()
        
      local request_args
      local proc_result
      local datasource
      
      setup(function()
      
        request_args = qlua.datasource.Close.Request()
        request_args.datasource_uuid = "test-datasource_uuid"
        
        request.args = request_args:SerializeToString()

        proc_result = true
        
        datasource = {
          Close = spy.new(function(candle_index) return proc_result end)
        }
        
        sut.get_datasource = spy.new(function(datasource_uuid) return datasource end)
      end)

      teardown(function()

        request_args = nil
        proc_result = nil
        datasource = nil
      end)
    
      it("SHOULD call its 'get_datasource' function once with the datasource_uuid argument", function()
          
        sut.call_procedure(request.type, request.args)
          
        assert.spy(sut.get_datasource).was.called_with(request_args.datasource_uuid)
      end)
    
      it("SHOULD call the 'Close' function on the datasource returned by its 'get_datasource' function, passing self to it", function()
          
        sut.call_procedure(request.type, request.args)
        
        assert.spy(datasource.Close).was.called_with(datasource)
      end)
    
      it("SHOULD return a qlua.datasource.Close.Result instance", function()
          
        local actual_result = sut.call_procedure(request.type, request.args)
        local expected_result = qlua.datasource.Close.Result()
        
        local actual_meta = getmetatable(actual_result)
        local expected_meta = getmetatable(expected_result)
        
        assert.are.equal(expected_meta, actual_meta)
      end)
    
      it("SHOULD return a protobuf object which string-serialized form equals to that of the expected result", function()
        
        local actual_result = sut.call_procedure(request.type, request.args)
        local expected_result = qlua.datasource.Close.Result()
        
        expected_result.result = proc_result
        
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
