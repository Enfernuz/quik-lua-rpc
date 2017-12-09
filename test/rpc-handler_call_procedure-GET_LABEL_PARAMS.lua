package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.rpc-handler", function()
  
  local qlua = require("qlua.api")
  local utils = require("utils.utils")
  local sut = require("impl.rpc-handler")

  describe("WHEN given a request of type ProcedureType.GET_LABEL_PARAMS", function()
      
    local request
    
    setup(function()
      
      request = {}
      request.type = qlua.RPC.ProcedureType.GET_LABEL_PARAMS
    end)
  
    teardown(function()
      request = nil
    end)

    insulate("WITH arguments", function()
        
      local request_args
      local proc_result
      
      setup(function()
      
        request_args = qlua.GetLabelParams.Request()
        request_args.chart_tag = "test-chart_tag"
        request_args.label_id = 321
        
        request.args = request_args:SerializeToString()

        proc_result = {}
        proc_result["TEXT"] = utils.Utf8ToCp1251("текст в кодировке CP1251")
        proc_result["IMAGE_PATH"] = ""
        proc_result["ALIGNMENT"] = "TOP"
        
        _G.GetLabelParams = spy.new(function(chart_tag, row) return proc_result end)
        
        _G.table.sinsert = spy.new(function(t, el) return table.insert(t, el) end)
      end)

      teardown(function()

        request_args = nil
        proc_result = nil
      end)
    
      it("SHOULD call the global 'GetLabelParams' function once, passing the procedure arguments to it", function()
        
        local response = sut.call_procedure(request.type, request.args)
    
        assert.spy(_G.GetLabelParams).was.called_with(request_args.chart_tag, request_args.label_id)
      end)
    
      it("SHOULD return a qlua.GetLabelParams.Result instance", function()
          
        local actual_result = sut.call_procedure(request.type, request.args)
        local expected_result = qlua.GetLabelParams.Result()
        
        local actual_meta = getmetatable(actual_result)
        local expected_meta = getmetatable(expected_result)
        
        assert.are.equal(expected_meta, actual_meta)
      end)
    
      -- Довольно фиговый тест, если честно. Нужно либо: 
      -- а) отдельно проверять, преобразуется ли на выходе текст CP1251 в UTF8;
      -- б) написать тест на utils.put_to_string_string_pb_map и проверять, вызывается ли он в тестируемом компоненте
      it("SHOULD return a protobuf object which string-serialized form equals to that of the expected result", function()
        
        local actual_result = sut.call_procedure(request.type, request.args)
        local expected_result = qlua.GetLabelParams.Result()
        
        utils.put_to_string_string_pb_map(proc_result, expected_result.label_params, qlua.GetLabelParams.Result.LabelParamsEntry)
        
        assert.are.equal(expected_result:SerializeToString(), actual_result:SerializeToString())
      end)
    
      insulate("AND the global 'GetLabelParams' returns nil", function()
          
        setup(function()
          _G.GetLabelParams = spy.new(function(chart_tag, label_id) return nil end)
        end)
      
        it("SHOULD raise an error", function()
          
          local expected_error_msg = string.format("Процедура GetLabelParams(%s, %d) возвратила nil.", request_args.chart_tag, request_args.label_id)
          
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
