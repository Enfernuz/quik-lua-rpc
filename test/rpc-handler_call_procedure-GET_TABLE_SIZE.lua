package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.rpc-handler", function()
  
  local qlua = require("qlua.api")
  local sut = require("impl.rpc-handler")

  describe("WHEN given a request of type ProcedureType.GET_TABLE_SIZE", function()
      
    local request
    
    setup(function()
      
      request = {}
      request.type = qlua.RPC.ProcedureType.GET_TABLE_SIZE
    end)
  
    teardown(function()
      request = nil
    end)

    describe("WITH arguments", function()
        
      local request_args
      local proc_result_rows, proc_result_col
      
      setup(function()
      
        request_args = qlua.GetTableSize.Request()
        request_args.t_id = 42
        
        request.args = request_args:SerializeToString()

        proc_result_rows = 9
        proc_result_col = 20
        
        _G.GetTableSize = spy.new(function(t_id) return proc_result_rows, proc_result_col end)
      end)

      teardown(function()

        request_args = nil
        proc_result_rows = nil
        proc_result_col = nil
      end)
    
      it("SHOULD call the global 'GetTableSize' function once, passing the procedure arguments to it", function()
        
        local response = sut.call_procedure(request.type, request.args)
    
        assert.spy(_G.GetTableSize).was.called_with(request_args.t_id)
      end)
    
      it("SHOULD return a qlua.GetTableSize.Result instance", function()
          
        local actual_result = sut.call_procedure(request.type, request.args)
        local expected_result = qlua.GetTableSize.Result()
        
        local actual_meta = getmetatable(actual_result)
        local expected_meta = getmetatable(expected_result)
        
        assert.are.equal(expected_meta, actual_meta)
      end)
    
      it("SHOULD return a protobuf object which string-serialized form equals to that of the expected result", function()
        
        local actual_result = sut.call_procedure(request.type, request.args)
        local expected_result = qlua.GetTableSize.Result()
        
        expected_result.rows = proc_result_rows
        expected_result.col = proc_result_col
        
        assert.are.equal(expected_result:SerializeToString(), actual_result:SerializeToString())
      end)
    
      describe("AND the global 'GetTableSize' function's 1st result is nil", function()
          
        setup(function()
          proc_result_rows = nil
        end)
      
        teardown(function()
            proc_result_rows = 9
        end)
          
        it("SHOULD raise an error", function()
          
          local expected_error_msg = string.format("Процедура GetTableSize(%s) возвратила nil.", request_args.t_id)
          assert.has_error(function() sut.call_procedure(request.type, request.args) end, expected_error_msg)
        end)
      end)
    
      describe("AND the global 'GetTableSize' function's 2nd result is nil", function()
          
        setup(function()
          proc_result_col = nil
        end)
      
        teardown(function()
            proc_result_col = 20
        end)
          
        it("SHOULD raise an error", function()

          local expected_error_msg = string.format("Процедура GetTableSize(%s) возвратила nil.", request_args.t_id)
          assert.has_error(function() sut.call_procedure(request.type, request.args) end, expected_error_msg)
        end)
      end)
    end)
  
    describe("WITHOUT arguments", function()
      
      it("SHOULD raise an error", function()
        
        assert.has_error(function() sut.call_procedure(request.type) end, "The request has no arguments.")
      end)
    end)
  end)

end)
