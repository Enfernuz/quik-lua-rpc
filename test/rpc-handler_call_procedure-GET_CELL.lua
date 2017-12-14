package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.rpc-handler", function()
  
  local qlua = require("qlua.api")
  local sut = require("impl.rpc-handler")

  describe("WHEN given a request of type ProcedureType.GET_CELL", function()
      
    local request
    
    setup(function()
      
      request = {}
      request.type = qlua.RPC.ProcedureType.GET_CELL
    end)
  
    teardown(function()
      request = nil
    end)

    insulate("WITH arguments", function()
        
      local request_args
      local proc_result
      
      setup(function()
      
        request_args = qlua.GetCell.Request()
        request_args.t_id = 42
        request_args.key = 11
        request_args.code = 7
        
        request.args = request_args:SerializeToString()

        proc_result = {
          image = "test-image",
          value = 123.45
        }
        
        _G.GetCell = spy.new(function(t_id, key, code) return proc_result end)
      end)

      teardown(function()

        request_args = nil
        proc_result = nil
      end)
    
      it("SHOULD call the global 'GetCell' function once, passing the procedure arguments to it", function()
        
        local response = sut.call_procedure(request.type, request.args)
    
        assert.spy(_G.GetCell).was.called_with(request_args.t_id, request_args.key, request_args.code)
      end)
    
      it("SHOULD return a qlua.GetCell.Result instance", function()
          
        local actual_result = sut.call_procedure(request.type, request.args)
        local expected_result = qlua.GetCell.Result()
        
        local actual_meta = getmetatable(actual_result)
        local expected_meta = getmetatable(expected_result)
        
        assert.are.equal(expected_meta, actual_meta)
      end)
    
      it("SHOULD return a protobuf object which string-serialized form equals to that of the expected result", function()
        
        local actual_result = sut.call_procedure(request.type, request.args)
        local expected_result = qlua.GetCell.Result()
        
        expected_result.image = proc_result.image
        expected_result.value = tostring(proc_result.value)
        
        assert.are.equal(expected_result:SerializeToString(), actual_result:SerializeToString())
      end)
    
      -----
      insulate("AND the global function 'GetCell' returns a result with no 'value' field set", function()
        
        local tmp
        
        setup(function()
            
          tmp = proc_result.value
          proc_result.value = nil
          
          _G.GetCell:clear()
        end)
      
        teardown(function()
            
          proc_result.value = tmp
          tmp = nil
        end)
        
        it("SHOULD call return a qlua.GetCell.Result instance with the field 'value' as an empty string ", function()
        
          local response = sut.call_procedure(request.type, request.args)
          
          local expected_field_value = ""
          local actual_field_value = response.value
      
          assert.are.equal(expected_field_value, actual_field_value)
        end)
      end)
    
      -----
      insulate("AND the global 'GetCell' function returns nil", function()
          
        setup(function()
          _G.GetCell = spy.new(function(t_id, key, code) return nil end)
        end)
      
        it("SHOULD raise an error", function()
          
          local expected_error_msg = string.format("Процедура GetCell(%s, %s, %s) вернула nil.", request_args.t_id, request_args.key, request_args.code)
          
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
