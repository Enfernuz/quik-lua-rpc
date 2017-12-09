package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")
local _ = match._

describe("impl.rpc-handler", function()
  
  local qlua = require("qlua.api")
  local sut = require("impl.rpc-handler")

  describe("WHEN given a request of type ProcedureType.ADD_COLUMN", function()
      
    local request
    
    setup(function()
      
      request = {}
      request.type = qlua.RPC.ProcedureType.ADD_COLUMN
    end)
  
    teardown(function()
      request = nil
    end)

    describe("WITH arguments", function()
        
      local request_args
      local proc_result
      
      setup(function()

        request_args = qlua.AddColumn.Request()
        request_args.t_id = 18
        request_args.icode = 3
        request_args.name = "test-name"
        request_args.is_default = true
        request_args.width = 100

        proc_result = 1
      end)

      teardown(function()

        request_args = nil
        proc_result = nil
      end)
    
      describe("WHERE the argument 'par_type'", function()
          
        insulate("IS ColumnParameterType.UNDEFINED", function()
            
          setup(function()
            request_args.par_type = qlua.AddColumn.ColumnParameterType.UNDEFINED
            request.args = request_args:SerializeToString()
          end)
        
          teardown(function()
            request_args.par_type = qlua.AddColumn.ColumnParameterType.QTABLE_DOUBLE_TYPE
            request.args = request_args:SerializeToString()
          end)
        
          it("SHOULD raise an error", function()
            assert.has_error(function() sut.call_procedure(request.type, request.args) end, "Unknown column parameter type.")  
          end)
        end)
      
        describe("IS NOT ColumnParameterType.UNDEFINED", function()
            
          local utils, corresponding_qlua_column_parameter_type
          
          setup(function()
              
            request_args.par_type = qlua.AddColumn.ColumnParameterType.QTABLE_DOUBLE_TYPE
            request.args = request_args:SerializeToString()
            
            corresponding_qlua_column_parameter_type = 123
            
            utils = require("utils.utils")
            utils.to_qtable_parameter_type = spy.new(function(pb_interval) return corresponding_qlua_column_parameter_type end)
            
            _G.AddColumn = spy.new(function(t_id, icode, name, is_default, column_parameter_type, width) return proc_result end)
          end)
        
          teardown(function()
            utils = nil
            corresponding_qlua_column_parameter_type = nil
          end)
        
          it("SHOULD call the global 'AddColumn' function once, passing the procedure arguments to it along with the corresponding QLua column parameter type as the 5th argument", function()
        
            local response = sut.call_procedure(request.type, request.args)
        
            assert.spy(_G.AddColumn).was.called_with(request_args.t_id, request_args.icode, request_args.name, request_args.is_default, corresponding_qlua_column_parameter_type, request_args.width)
          end)
        
          it("SHOULD return a qlua.AddColumn.Result instance", function()
        
            local actual_result = sut.call_procedure(request.type, request.args)
            local expected_result = qlua.AddColumn.Result()

            local actual_meta = getmetatable(actual_result)
            local expected_meta = getmetatable(expected_result)

            assert.are.equal(expected_meta, actual_meta)
          end)
        
          it("SHOULD return a protobuf object which string-serialized form equals to that of the expected result", function()
          
            local actual_result = sut.call_procedure(request.type, request.args)
            local expected_result = qlua.AddColumn.Result()
            
            expected_result.result = proc_result
            
            assert.are.equal(expected_result:SerializeToString(), actual_result:SerializeToString())
          end)
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
