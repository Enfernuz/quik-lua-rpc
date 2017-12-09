package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.rpc-handler", function()
  
  local qlua = require("qlua.api")
  local sut = require("impl.rpc-handler")

  describe("WHEN given a request of type ProcedureType.SET_SELECTED_ROW", function()
      
    local request
    
    setup(function()
      
      request = {}
      request.type = qlua.RPC.ProcedureType.SET_SELECTED_ROW
    end)
  
    teardown(function()
      request = nil
    end)

    insulate("WITH arguments", function()
        
      local request_args
      local proc_result
      
      setup(function()
      
        request_args = qlua.SetSelectedRow.Request()
        request_args.table_id = 42
        request_args.row = 0xFFFFFFFF
        
        request.args = request_args:SerializeToString()

        proc_result = 1
        
        _G.SetSelectedRow = spy.new(function(table_id, row) return proc_result end)
      end)

      teardown(function()

        request_args = nil
        proc_result = nil
      end)
    
      it("SHOULD call the global 'SetSelectedRow' function once, passing the procedure arguments to it", function()
        
        local response = sut.call_procedure(request.type, request.args)
    
        assert.spy(_G.SetSelectedRow).was.called_with(request_args.table_id, request_args.row)
      end)
    
      it("SHOULD return a qlua.SetSelectedRow.Result instance", function()
          
        local actual_result = sut.call_procedure(request.type, request.args)
        local expected_result = qlua.SetSelectedRow.Result()
        
        local actual_meta = getmetatable(actual_result)
        local expected_meta = getmetatable(expected_result)
        
        assert.are.equal(expected_meta, actual_meta)
      end)
    
      it("SHOULD return a protobuf object which string-serialized form equals to that of the expected result", function()
        
        local actual_result = sut.call_procedure(request.type, request.args)
        local expected_result = qlua.SetSelectedRow.Result()
        
        expected_result.result = proc_result
        
        assert.are.equal(expected_result:SerializeToString(), actual_result:SerializeToString())
      end)
    
      insulate("AND the global 'SetSelectedRow' returns -1", function()
          
        setup(function()
          _G.SetSelectedRow = spy.new(function(table_id, row) return -1 end)
        end)
      
        it("SHOULD raise an error", function()
          
          local expected_error_msg = string.format("Процедура SetSelectedRow(%d, %d) возвратила -1.", request_args.table_id, request_args.row)
          
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
