package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.rpc-handler", function()
  
  local qlua = require("qlua.api")
  local sut = require("impl.rpc-handler")

  describe("WHEN given a request of type ProcedureType.GET_WINDOW_RECT", function()
      
    local request
    
    setup(function()
      
      request = {}
      request.type = qlua.RPC.ProcedureType.GET_WINDOW_RECT
    end)
  
    teardown(function()
      request = nil
    end)

    describe("WITH arguments", function()
        
      local request_args
      local proc_result_top, proc_result_left, proc_result_bottom, proc_result_right
      
      setup(function()
      
        request_args = qlua.GetWindowRect.Request()
        request_args.t_id = 42
        
        request.args = request_args:SerializeToString()

        proc_result_top = 1.0
        proc_result_left = 2.0
        proc_result_bottom = 3.5
        proc_result_right = 0
        
        _G.GetWindowRect = spy.new(function(t_id) return proc_result_top, proc_result_left, proc_result_bottom, proc_result_right end)
      end)

      teardown(function()

        request_args = nil
        proc_result_top = nil
        proc_result_left = nil
        proc_result_bottom = nil
        proc_result_right = nil
      end)
    
      it("SHOULD call the global 'GetWindowRect' function once, passing the procedure arguments to it", function()
        
        local response = sut.call_procedure(request.type, request.args)
    
        assert.spy(_G.GetWindowRect).was.called_with(request_args.t_id)
      end)
    
      it("SHOULD return a qlua.GetWindowRect.Result instance", function()
          
        local actual_result = sut.call_procedure(request.type, request.args)
        local expected_result = qlua.GetWindowRect.Result()
        
        local actual_meta = getmetatable(actual_result)
        local expected_meta = getmetatable(expected_result)
        
        assert.are.equal(expected_meta, actual_meta)
      end)
    
      it("SHOULD return a protobuf object which string-serialized form equals to that of the expected result", function()
        
        local actual_result = sut.call_procedure(request.type, request.args)
        local expected_result = qlua.GetWindowRect.Result()
        
        expected_result.top = proc_result_top
        expected_result.left = proc_result_left
        expected_result.bottom = proc_result_bottom
        expected_result.right = proc_result_right
        
        assert.are.equal(expected_result:SerializeToString(), actual_result:SerializeToString())
      end)
    
      describe("AND the global 'GetWindowRect' function's 1st result is nil", function()
          
        setup(function()
          proc_result_top = nil
        end)
      
        teardown(function()
            proc_result_top = 1.0
        end)
          
        it("SHOULD raise an error", function()
          
          local expected_error_msg = string.format("Процедура GetWindowRect(%s) возвратила nil.", request_args.t_id)
          assert.has_error(function() sut.call_procedure(request.type, request.args) end, expected_error_msg)
        end)
      end)
    
      describe("AND the global 'GetWindowRect' function's 2nd result is nil", function()
          
        setup(function()
          proc_result_left = nil
        end)
      
        teardown(function()
            proc_result_left = 2.0
        end)
          
        it("SHOULD raise an error", function()

          local expected_error_msg = string.format("Процедура GetWindowRect(%s) возвратила nil.", request_args.t_id)
          assert.has_error(function() sut.call_procedure(request.type, request.args) end, expected_error_msg)
        end)
      end)
    
      describe("AND the global 'GetWindowRect' function's 3rd result is nil", function()
          
        setup(function()
          proc_result_bottom = nil
        end)
      
        teardown(function()
            proc_result_bottom = 2.0
        end)
          
        it("SHOULD raise an error", function()

          local expected_error_msg = string.format("Процедура GetWindowRect(%s) возвратила nil.", request_args.t_id)
          assert.has_error(function() sut.call_procedure(request.type, request.args) end, expected_error_msg)
        end)
      end)
    
      describe("AND the global 'GetWindowRect' function's 4th result is nil", function()
          
        setup(function()
          proc_result_right = nil
        end)
      
        teardown(function()
            proc_result_right = 2.0
        end)
          
        it("SHOULD raise an error", function()

          local expected_error_msg = string.format("Процедура GetWindowRect(%s) возвратила nil.", request_args.t_id)
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
