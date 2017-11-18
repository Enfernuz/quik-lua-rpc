package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")
local _ = match._

describe("impl.rpc-handler", function()
  
  local qlua = require("qlua.api")
  local sut = require("impl.rpc-handler")

  describe("WHEN given a request of type ProcedureType.SEARCH_ITEMS", function()
      
    local request
    
    setup(function()
      
      request = {}
      request.type = qlua.RPC.ProcedureType.SEARCH_ITEMS
    end)
  
    teardown(function()
      request = nil
    end)

    insulate("WITH arguments", function()
        
      local request_args
      local proc_result, getNumberOfResult
      
      setup(function()
      
        request_args = qlua.SearchItems.Request()
        request_args.table_name = "test-table_name"
        request_args.start_index = 0
        request_args.end_index = 9
        request_args.fn_def = "function(p1, p2, p3) return true end"
        request_args.params = "param1,param2,param3"
        
        request.args = request_args:SerializeToString()

        proc_result = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9}
        getNumberOfResult = #proc_result
        
        _G.SearchItems = spy.new(function(tbl_name, strt_indx, end_indx, fn, params) return proc_result end)
        _G.getNumberOf = spy.new(function(tbl_name) return getNumberOfResult end)
        _G.table.sinsert = spy.new(function(t, el) return table.insert end)
      end)

      teardown(function()

        request_args = nil
        proc_result = nil
        getNumberOfResult = nil
      end)
    
      -----
    
      insulate("AND the 'fn_def' argument is not a correct Lua function definition", function()
          
        local tmp
        
        setup(function()
            
          tmp = request_args.fn_def
          request_args.fn_def = "some incorrect Lua code"
          request.args = request_args:SerializeToString()
        end)
          
        teardown(function()
            
          request_args.fn_def = tmp
          tmp = nil
          request.args = request_args:SerializeToString()
        end)
      
        it("SHOULD raise an error", function()
            
          local fn_ctr, err_msg = loadstring("return "..request_args.fn_def)
          local expected_error_message = string.format("Не удалось распарсить определение функции из переданной строки. Описание ошибки: %s.", err_msg)
          
          assert.has_error(function() sut.call_procedure(request.type, request.args) end, expected_error_message)
        end)
      end)
    
      -----
    
      insulate("AND IF 'fn_def' argument is a correct Lua function definition", function()
        
        local fn_ctr, fn
        
        setup(function()
            
          fn_ctr = loadstring("return "..request_args.fn_def)
          _G.loadstring = spy.new(function(fn_def) return fn_ctr end)
          
          fn = fn_ctr()
          fn_ctr = spy.new(function() return fn end)
        end)
      
        teardown(function()
            
          fn_ctr = nil
          fn = nil
        end)
      
        -----
      
        insulate("AND IF the 'end_index' argument is 0", function()
          
          local tmp
            
          setup(function()
              
            tmp = request_args.end_index
            request_args.end_index = 0
            request.args = request_args:SerializeToString()
          end)
        
          teardown(function()
              
            request_args.end_index = tmp
            request.args = request_args:SerializeToString()
            tmp = nil
          end)
        
          before_each(function()
            _G.SearchItems:clear()
          end)
        
          it("SHOULD call the global 'getNumberOf' function once, passing the 'table_name' argument to it", function()
              
            sut.call_procedure(request.type, request.args)
            
            assert.spy(_G.getNumberOf).was.called_with(request_args.table_name)
          end)
        
          it("SHOULD call the global 'SearchItems' function once, passing 5 arguments and the 'table_name' request argument as the 1st argument", function()
            
            sut.call_procedure(request.type, request.args)
            
            assert.spy(_G.SearchItems).was.called_with(request_args.table_name, _, _, _, _)
          end)
        
          it("SHOULD call the global 'SearchItems' function once, passing 5 arguments and the 'start_index' request argument as the 2nd argument", function()
            
            sut.call_procedure(request.type, request.args)
            
            assert.spy(_G.SearchItems).was.called_with(_, request_args.start_index, _, _, _)
          end)
        
          it("SHOULD call the global 'SearchItems' function once, passing 5 arguments and the decremented result of 'getNumberOf(table_name)' as the 3rd argument", function()
            
            sut.call_procedure(request.type, request.args)
            
            assert.spy(_G.SearchItems).was.called_with(_, _, getNumberOf(request_args.table_name) - 1, _, _)
          end)
        
          it("SHOULD call the global 'SearchItems' function once, passing 5 arguments and the function invocation of the result of 'loadstring(\"return \"..args.fn_def)' as the 4th argument", function()
            
            sut.call_procedure(request.type, request.args)
            
            assert.spy(_G.loadstring).was.called_with("return "..request_args.fn_def)
            assert.spy(_G.SearchItems).was.called_with(_, _, _, fn_ctr(), _)
          end)
        
          it("SHOULD call the global 'SearchItems' function once, passing 5 arguments and the 'params' argument as the 5th argument", function()
            
            sut.call_procedure(request.type, request.args)
            
            assert.spy(_G.SearchItems).was.called_with(_, _, _, _, request_args.params)
          end)
        end)
      
        -----
      
        insulate("AND IF the 'params' argument is an empty string", function()
          
          local tmp
            
          setup(function()
              
            tmp = request_args.params
            request_args.params = ""
            request.args = request_args:SerializeToString()
          end)
        
          teardown(function()
              
            request_args.params = tmp
            tmp = nil
            request.args = request_args:SerializeToString()
          end)
      
          before_each(function()
            _G.SearchItems:clear()
          end)
      
          it("SHOULD call the global 'SearchItems' function once, passing 4 arguments and the 'table_name' request argument as the 1st argument", function()
            
            sut.call_procedure(request.type, request.args)
            
            assert.spy(_G.SearchItems).was.called_with(request_args.table_name, _, _, _)
          end)
        
          it("SHOULD call the global 'SearchItems' function once, passing 4 arguments and the 'start_index' request argument as the 2nd argument", function()
            
            sut.call_procedure(request.type, request.args)
            
            assert.spy(_G.SearchItems).was.called_with(_, request_args.start_index, _, _)
          end)
        
          it("SHOULD call the global 'SearchItems' function once, passing 4 arguments and the decremented result of 'getNumberOf(table_name)' as the 3rd argument", function()
            
            sut.call_procedure(request.type, request.args)
            
            assert.spy(_G.SearchItems).was.called_with(_, _, getNumberOf(request_args.table_name) - 1, _)
          end)
        
          it("SHOULD call the global 'SearchItems' function once, passing 4 arguments and the function invocation of the result of 'loadstring(\"return \"..args.fn_def)' as the 4th argument", function()
            
            sut.call_procedure(request.type, request.args)
            
            assert.spy(_G.loadstring).was.called_with("return "..request_args.fn_def)
            assert.spy(_G.SearchItems).was.called_with(_, _, _, fn_ctr())
          end)
        end)
      
          it("SHOULD return a qlua.SearchItems.Result instance", function()
              
            local actual_result = sut.call_procedure(request.type, request)
            local expected_result = qlua.SearchItems.Result()
            
            local actual_meta = getmetatable(actual_result)
            local expected_meta = getmetatable(expected_result)
            
            assert.are.equal(expected_meta, actual_meta)
          end)
        
          it("SHOULD invoke the 'table.sinsert' function for each of the elements in the procedure result array", function()
              
            _G.table.sinsert:clear()
              
            sut.call_procedure(request.type, request)
            
            for i, item_index in ipairs(proc_result) do
              assert.spy(_G.table.sinsert).was.called_with(_, item_index)
            end
          end)
      
          it("SHOULD return a protobuf object which string-serialized form equals to that of the expected result", function()
            
            local actual_result = sut.call_procedure(request.type, request)
            local expected_result = qlua.SearchItems.Result()
            
            for i, item_index in ipairs(proc_result) do
              table.sinsert(expected_result.items_indices, item_index)
            end
            
            assert.are.equal(expected_result:SerializeToString(), actual_result:SerializeToString())
          end)
        end)
      end)

    -----

    describe("WITHOUT arguments", function()
      
      it("SHOULD raise an error", function()
        
        assert.has_error(function() sut.call_procedure(request.type) end, "The request has no arguments.")
      end)
    end)
  
    -----
  end)

end)
