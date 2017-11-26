package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")
local _ = match._

describe("impl.rpc-handler", function()
  
  local qlua = require("qlua.api")
  local sut = require("impl.rpc-handler")

  describe("WHEN given a request of type ProcedureType.DS_SET_UPDATE_CALLBACK", function()
      
    local request
    
    setup(function()
      
      request = {}
      request.type = qlua.RPC.ProcedureType.DS_SET_UPDATE_CALLBACK
    end)
  
    teardown(function()
      request = nil
    end)

    insulate("WITH arguments", function()
        
      local request_args
      local proc_result
      local datasource
      
      setup(function()
      
        request_args = qlua.datasource.SetUpdateCallback.Request()
        request_args.datasource_uuid = "test-datasource_uuid"
        request_args.f_cb_def = "function(index, datasource) end"
        
        request.args = request_args:SerializeToString()

        proc_result = true
        
        datasource = {
          SetUpdateCallback = spy.new(function(datasource_uuid, f_cb_def) return proc_result end)
        }
        
        sut.get_datasource = spy.new(function(datasource_uuid) return datasource end)
      end)

      teardown(function()

        request_args = nil
        proc_result = nil
      end)
    
      it("SHOULD call its 'get_datasource' function once with the datasource_uuid argument", function()
          
        sut.call_procedure(request.type, request.args)
          
        assert.spy(sut.get_datasource).was.called_with(request_args.datasource_uuid)
      end)
    
      -----
    
      insulate("AND the 'f_cb_def' argument is not a correct Lua function definition", function()
          
        local tmp
        
        setup(function()
            
          tmp = request_args.f_cb_def
          request_args.f_cb_def = "some incorrect Lua code"
          request.args = request_args:SerializeToString()
        end)
          
        teardown(function()
            
          request_args.f_cb_def = tmp
          tmp = nil
          request.args = request_args:SerializeToString()
        end)
      
        it("SHOULD raise an error", function()
            
          local f_cb_ctr, err_msg = loadstring("return "..request_args.f_cb_def)
          local expected_error_message = string.format("Не удалось распарсить определение функции из переданной строки. Описание ошибки: %s.", err_msg)
          
          assert.has_error(function() sut.call_procedure(request.type, request.args) end, expected_error_message)
        end)
      end)
    
      -----
    
      insulate("AND IF 'f_cb_def' argument is a correct Lua function definition", function()
        
        local f_cb_ctr, f_cb
        
        setup(function()
            
          f_cb_ctr = loadstring("return "..request_args.f_cb_def)
          _G.loadstring = spy.new(function(f_cb_def) return f_cb_ctr end)
        end)
      
        teardown(function()
            
          f_cb_ctr = nil
          f_cb = nil
        end)
      
        -- TO-DO: how can we be sure that the function argument of 'SetUpdateCallback' is a correct callback function and not just ANY function?
        it("[LQ TEST] SHOULD call the 'SetUpdateCallback' function on the datasource returned by its 'get_datasource' function, passing the datasource and a function to it", function()
            
          sut.call_procedure(request.type, request)
          
          assert.spy(datasource.SetUpdateCallback).was.called_with(datasource, match.is_function())
        end)
      
        it("SHOULD return a qlua.datasource.SetUpdateCallback.Result instance", function()
            
          local actual_result = sut.call_procedure(request.type, request)
          local expected_result = qlua.datasource.SetUpdateCallback.Result()
          
          local actual_meta = getmetatable(actual_result)
          local expected_meta = getmetatable(expected_result)
          
          assert.are.equal(expected_meta, actual_meta)
        end)

        it("SHOULD return a protobuf object which string-serialized form equals to that of the expected result", function()
          
          local actual_result = sut.call_procedure(request.type, request)
          local expected_result = qlua.datasource.SetUpdateCallback.Result()
          expected_result.result = proc_result
                        
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
