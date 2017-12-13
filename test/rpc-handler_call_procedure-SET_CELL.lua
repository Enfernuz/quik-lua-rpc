package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.rpc-handler", function()
  
  local qlua = require("qlua.api")
  local sut = require("impl.rpc-handler")

  describe("WHEN given a request of type ProcedureType.SET_CELL", function()
      
    local request
    
    setup(function()
      
      request = {}
      request.type = qlua.RPC.ProcedureType.SET_CELL
    end)
  
    teardown(function()
      request = nil
    end)

    insulate("WITH arguments", function()
        
      local request_args
      local proc_result
      
      setup(function()
      
        request_args = qlua.SetCell.Request()
        request_args.t_id = 42
        request_args.key = 11
        request_args.code = 7
        request_args.text = "test-text"
        request_args.value = 12.34
        
        request.args = request_args:SerializeToString()

        proc_result = true
        
        _G.SetCell = spy.new(function(t_id, key, code, text, value) return proc_result end)
      end)

      teardown(function()

        request_args = nil
        proc_result = nil
      end)
    
      it("SHOULD call the global 'SetCell' function once, passing the procedure arguments to it", function()
        
        local response = sut.call_procedure(request.type, request.args)
    
        assert.spy(_G.SetCell).was.called_with(request_args.t_id, request_args.key, request_args.code, request_args.text, request_args.value)
      end)
    
      it("SHOULD return a qlua.SetCell.Result instance", function()
          
        local actual_result = sut.call_procedure(request.type, request.args)
        local expected_result = qlua.SetCell.Result()
        
        local actual_meta = getmetatable(actual_result)
        local expected_meta = getmetatable(expected_result)
        
        assert.are.equal(expected_meta, actual_meta)
      end)
    
      it("SHOULD return a protobuf object which string-serialized form equals to that of the expected result", function()
        
        local actual_result = sut.call_procedure(request.type, request.args)
        local expected_result = qlua.SetCell.Result()
        
        expected_result.result = proc_result
        
        assert.are.equal(expected_result:SerializeToString(), actual_result:SerializeToString())
      end)
    
      -----
      insulate("WHERE the argument 'value' equals to 0", function()
        
        local tmp
        
        setup(function()
            
          tmp = request_args.value
          request_args.value = 0
          request.args = request_args:SerializeToString()
          
          _G.SetCell:clear()
        end)
      
        teardown(function()
            
          request_args.value = tmp
          tmp = nil
          request.args = request_args:SerializeToString()
        end)
        
        it("SHOULD call the global 'SetCell' function once, passing the procedure arguments to it except the 'value' argument", function()
        
          local response = sut.call_procedure(request.type, request.args)
      
          assert.spy(_G.SetCell).was.called_with(request_args.t_id, request_args.key, request_args.code, request_args.text)
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
