package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.rpc-handler", function()
  
  local qlua = require("qlua.api")
  local utils = require("utils.utils")
  local sut = require("impl.rpc-handler")

  describe("WHEN given a request of type ProcedureType.GET_WINDOW_CAPTION", function()
      
    local request
    
    setup(function()
      
      request = {}
      request.type = qlua.RPC.ProcedureType.GET_WINDOW_CAPTION
    end)
  
    teardown(function()
      request = nil
    end)

    insulate("WITH arguments", function()
        
      local request_args
      local proc_result
      
      setup(function()
      
        request_args = qlua.Highlight.Request()
        request_args.t_id = 42
        
        request.args = request_args:SerializeToString()

        proc_result = "test-caption"
        
        _G.GetWindowCaption = spy.new(function(t_id) return proc_result end)
      end)

      teardown(function()

        request_args = nil
        proc_result = nil
      end)
    
      it("SHOULD call the global 'GetWindowCaption' function once, passing the procedure arguments to it", function()
        
        local response = sut.call_procedure(request.type, request.args)
    
        assert.spy(_G.GetWindowCaption).was.called_with(request_args.t_id)
      end)
    
      it("SHOULD return a qlua.GetWindowCaption.Result instance", function()
          
        local actual_result = sut.call_procedure(request.type, request.args)
        local expected_result = qlua.GetWindowCaption.Result()
        
        local actual_meta = getmetatable(actual_result)
        local expected_meta = getmetatable(expected_result)
        
        assert.are.equal(expected_meta, actual_meta)
      end)
    
      it("SHOULD return a protobuf object which string-serialized form equals to that of the expected result", function()
        
        local actual_result = sut.call_procedure(request.type, request.args)
        local expected_result = qlua.GetWindowCaption.Result()
        
        expected_result.caption = proc_result
        
        assert.are.equal(expected_result:SerializeToString(), actual_result:SerializeToString())
      end)
    
      describe("AND the global 'GetWindowCaption' function returns a CP1251-encoded string", function()
          
        setup(function()
          proc_result = utils.Utf8ToCp1251("тестовый заголовок окна")
        end)
      
        teardown(function()
          proc_result = "test-caption"
        end)
      
        it("SHOULD convert the string into UTF8", function()
            
          local result = sut.call_procedure(request.type, request.args)
          
          assert.are.equal(utils.Cp2151ToUtf8(proc_result), result.caption)
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
