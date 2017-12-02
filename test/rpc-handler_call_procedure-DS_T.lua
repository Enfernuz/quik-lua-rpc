package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.rpc-handler", function()
  
  local qlua = require("qlua.api")
  local sut = require("impl.rpc-handler")

  describe("WHEN given a request of type ProcedureType.DS_T", function()
      
    local request
    
    setup(function()
      
      request = {}
      request.type = qlua.RPC.ProcedureType.DS_T
    end)
  
    teardown(function()
      request = nil
    end)

    insulate("WITH arguments", function()
        
      local request_args
      local proc_result
      local datasource
      
      setup(function()
      
        request_args = qlua.datasource.T.Request()
        request_args.datasource_uuid = "test-datasource_uuid"
        request_args.candle_index = 9
        
        request.args = request_args:SerializeToString()

        proc_result = {
          year = 2017, 
          month = 12, 
          day = 1, 
          week_day = 5, 
          hour = 11, 
          min = 30, 
          sec = 0, 
          ms = 33, 
          count = 19
        }
        
        datasource = {
          T = spy.new(function(candle_index) return proc_result end)
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
    
      it("SHOULD call the 'T' function on the datasource returned by its 'get_datasource' function, passing self and the 'candle_index' argument to it", function()
          
        sut.call_procedure(request.type, request)
        
        assert.spy(datasource.T).was.called_with(datasource, request_args.candle_index)
      end)
    
      it("SHOULD return a qlua.datasource.T.Result instance", function()
          
        local actual_result = sut.call_procedure(request.type, request)
        local expected_result = qlua.datasource.T.Result()
        
        local actual_meta = getmetatable(actual_result)
        local expected_meta = getmetatable(expected_result)
        
        assert.are.equal(expected_meta, actual_meta)
      end)
    
      it("SHOULD return a protobuf object which string-serialized form equals to that of the expected result", function()
        
        local actual_result = sut.call_procedure(request.type, request)
        local expected_result = qlua.datasource.T.Result()
        
        expected_result.year = proc_result.year
        expected_result.month = proc_result.month
        expected_result.day = proc_result.day
        expected_result.week_day = proc_result.week_day
        expected_result.hour = proc_result.hour
        expected_result.min = proc_result.min
        expected_result.sec = proc_result.sec
        expected_result.ms = proc_result.ms
        expected_result.count = proc_result.count
        
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
