package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.rpc-handler", function()
  
  local qlua = require("qlua.api")
  local struct_converter = require("utils.struct_converter")
  
  local sut = require("impl.rpc-handler")

  describe("WHEN given a request of type ProcedureType.GET_CANDLES_BY_INDEX", function()
      
    local request
    
    setup(function()
      
      request = {}
      request.type = qlua.RPC.ProcedureType.GET_CANDLES_BY_INDEX
    end)
  
    teardown(function()
      request = nil
    end)

    insulate("WITH arguments", function()
        
      local request_args
      local t, n, l
      
      setup(function()
      
        request_args = qlua.getCandlesByIndex.Request()
        request_args.tag = "test-tag"
        request_args.line = 1
        request_args.first_candle = 1
        request_args.count = 3
        
        request.args = request_args:SerializeToString()

        t = {
          {
            open = 99.25, 
            close = 88.63, 
            high = 100.1, 
            low = 85.05, 
            volume = 250543, 
            doesExist = 1, 
            datetime = {
              mcs = 10, 
              ms = 20, 
              sec = 30, 
              min = 35, 
              hour = 11, 
              day = 20, 
              week_day = 5, 
              month = 6, 
              year = 2018
            }
          },
          {
            open = 88.63, 
            close = 89.90, 
            high = 93.25, 
            low = 79.99, 
            volume = 159023, 
            doesExist = 1, 
            datetime = {
              mcs = 9, 
              ms = 19, 
              sec = 22, 
              min = 40, 
              hour = 11, 
              day = 20, 
              week_day = 5, 
              month = 6, 
              year = 2018
            }
          },
          {
            open = 89.91, 
            close = 98.98, 
            high = 99.99, 
            low = 89.91, 
            volume = 299876, 
            doesExist = 0, 
            datetime = {
              mcs = 10, 
              ms = 20, 
              sec = 30, 
              min = 45, 
              hour = 11, 
              day = 20, 
              week_day = 5, 
              month = 6, 
              year = 2018
            }
          }
        }
        
        n = 3
        
        l = "test-l"

        _G.getCandlesByIndex = spy.new(function(tag, line, first_candle, count) return t, n, l end)
        _G.table.sinsert = spy.new(function(t, el) return table.insert(t, el) end)
      end)

      teardown(function()

        request_args = nil
        t = nil
        n = nil 
        l = nil
      end)
    
      it("SHOULD call the global 'getCandlesByIndex' function once, passing the procedure arguments to it", function()
        
        local response = sut.call_procedure(request.type, request.args)
    
        assert.spy(_G.getCandlesByIndex).was.called_with(request_args.tag, request_args.line, request_args.first_candle, request_args.count)
      end)
    
      it("SHOULD return a qlua.getCandlesByIndex.Result instance", function()
          
        local actual_result = sut.call_procedure(request.type, request.args)
        local expected_result = qlua.getCandlesByIndex.Result()
        
        local actual_meta = getmetatable(actual_result)
        local expected_meta = getmetatable(expected_result)
        
        assert.are.equal(expected_meta, actual_meta)
      end)
    
      it("SHOULD return a protobuf object which string-serialized form equals to that of the expected result", function()
        
        local actual_result = sut.call_procedure(request.type, request.args)
        local expected_result = struct_converter.getCandlesByIndex.Result(t, n, l)
        
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
