package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.rpc-handler", function()
  
  local qlua = require("qlua.api")
  local sut = require("impl.rpc-handler")

  describe("WHEN given a request of type ProcedureType.MESSAGE", function()
      
    local request
    
    setup(function()
      
      request = {}
      request.type = qlua.RPC.ProcedureType.MESSAGE
    end)
  
    teardown(function()
      request = nil
    end)

    insulate("WITH arguments", function()
        
      local request_args
      local rpc_result
      
      setup(function()
      
        request_args = qlua.message.Request()
        request_args.message = "test-message"
        request_args.icon_type = qlua.message.IconType.INFO
        
        request.args = request_args:SerializeToString()

        rpc_result = 1
        
        _G.message = spy.new(function(msg, icon_type) return rpc_result end)
      end)

      teardown(function()

        request_args = nil
        rpc_result = nil
      end)
    
      -- Если поместить этот тест после нижнего insulate (если describe ниже сделать insulate и убрать teardown), то будет ошибка: после того insulate icon_type станет UNDEFINED, а не INFO.
      -- Вроде insulate выполняет какой-то сэндбоксинг, чтобы изолировать тестовое окружение, но, видимо, я не до конца разобрался, как он работает.
      it("SHOULD call the message function once, passing the procedure arguments to it", function()
      
        local response = sut.call_procedure(request.type, request.args)
        assert.spy(_G.message).was.called_with(request_args.message, request_args.icon_type)
      end)
    
      describe("AND the icon_type is UNDEFINED", function()
          
        setup(function()
          request_args.icon_type = qlua.message.IconType.UNDEFINED
          request.args = request_args:SerializeToString()
        end)
      
        teardown(function()
          request_args.icon_type = qlua.message.IconType.INFO
          request.args = request_args:SerializeToString()
        end)
      
        it("SHOULD call the message function once, passing only the 'message' field from the procedure arguments to it", function()
          
          local response = sut.call_procedure(request.type, request.args)
          assert.spy(_G.message).was.called_with(request_args.message)
        end)
      
        insulate("AND the message function returns nil", function()
          
          setup(function()
            _G.message = function(msg, icon_type) return nil end
          end)
        
          it("SHOULD raise an error", function()
            assert.has_error(function() sut.call_procedure(request.type, request.args) end, string.format("Процедура message(%s) возвратила nil.", request_args.message))
          end)
        end)
      end)

      it("SHOULD return a qlua.message.Result with its data mapped to the result of the called procedure", function()
        
        local result = sut.call_procedure(request.type, request.args)
        
        local expected_meta = getmetatable( qlua.message.Result() )
        local actual_meta = getmetatable(result)
        
        assert.are.equal(expected_meta, actual_meta)
        
        assert.are.equal(rpc_result, result.result)
      end)
    
      insulate("AND the message function returns nil", function()
          
          setup(function()
            _G.message = function(msg, icon_type) return nil end
          end)
        
          it("SHOULD raise an error", function()
            assert.has_error(function() sut.call_procedure(request.type, request.args) end, string.format("Процедура message(%s, %d) возвратила nil.", request_args.message, request_args.icon_type))
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
