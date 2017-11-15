package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.rpc-handler", function()
  
  local qlua = require("qlua.api")
  local utils = require("utils.utils")
  local sut = require("impl.rpc-handler")

  describe("WHEN given a request of type ProcedureType.GET_ITEM", function()
      
    local request
    
    setup(function()
      
      request = {}
      request.type = qlua.RPC.ProcedureType.GET_ITEM
    end)
  
    teardown(function()
      request = nil
    end)

    insulate("WITH arguments", function()
        
      local request_args
      local proc_result
      
      setup(function()
      
        request_args = qlua.getItem.Request()
        request_args.table_name = "test-table_name"
        request_args.index = 20
        
        request.args = request_args:SerializeToString()

        proc_result = {param1 = "value1", param2 = "value2"}
        
        _G.getItem = spy.new(function(table_name, index) return proc_result end)
        table.sinsert = table.insert
      end)

      teardown(function()

        request_args = nil
        proc_result = nil
      end)
    
      it("SHOULD call the getItem function once, passing the procedure arguments to it", function()
        
        local response = sut.call_procedure(request.type, request.args)
    
        assert.spy(_G.getItem).was.called_with(request_args.table_name, request_args.index)
      end)
    
      it("SHOULD return a qlua.getItem.Result with its data mapped to the result of the called procedure", function()
        
        local result = sut.call_procedure(request.type, request)
        
        local expected_meta = getmetatable( qlua.getItem.Result() )
        local actual_meta = getmetatable(result)
        
        assert.are.equal(expected_meta, actual_meta)
        
        local data = {}
        for _, entry in ipairs(result.table_row) do
          data[entry.key] = entry.value
        end
        
        assert.are.same(proc_result, data)
      end)
    end)
  
    describe("WITHOUT arguments", function()
      
      it("SHOULD raise an error", function()
        
        assert.has_error(function() sut.call_procedure(request.type) end, "The request has no arguments.")
      end)
    end)
  end)

end)
