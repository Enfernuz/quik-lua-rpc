package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.rpc-handler", function()
  
  local qlua = require("qlua.api")
  local utils = require("utils.utils")
  local sut = require("impl.rpc-handler")

  describe("WHEN given a request of type ProcedureType.SET_LABEL_PARAMS", function()
      
    local request
    
    setup(function()
      
      request = {}
      request.type = qlua.RPC.ProcedureType.SET_LABEL_PARAMS
    end)
  
    teardown(function()
      request = nil
    end)

    insulate("WITH arguments", function()
        
      local request_args
      local proc_result
      
      setup(function()
      
        request_args = qlua.SetLabelParams.Request()
        request_args.chart_tag = "test-chart_tag"
        request_args.label_id = 252
        
        local p1 = qlua.SetLabelParams.Request.LabelParamsEntry()
        p1.key = "TEXT"
        p1.value = "sample_text"
        table.insert(request_args.label_params, p1)
  
        local p2 = qlua.SetLabelParams.Request.LabelParamsEntry()
        p2.key = "IMAGE_PATH"
        p2.value = ""
        table.insert(request_args.label_params, p2)
  
        local p3 = qlua.SetLabelParams.Request.LabelParamsEntry()
        p3.key = "ALIGNMENT"
        p3.value = "TOP"
        table.insert(request_args.label_params, p3)

        request.args = request_args:SerializeToString()

        proc_result = true
        
        _G.SetLabelParams = spy.new(function(chart_tag, label_id, label_params) return proc_result end)
      end)

      teardown(function()

        request_args = nil
        proc_result = nil
      end)
    
      it("SHOULD call the global 'SetLabelParams' function once, passing the 'chart_tag' argument 1st, 'label_id' 2nd and the 'label_params' converted to an ordinary table 3rd", function()
        
        local response = sut.call_procedure(request.type, request.args)
    
        assert.spy(_G.SetLabelParams).was.called_with(request_args.chart_tag, request_args.label_id, utils.create_table(request_args.label_params))
      end)
    
      it("SHOULD return a qlua.SetLabelParams.Result instance", function()
          
        local actual_result = sut.call_procedure(request.type, request)
        local expected_result = qlua.SetLabelParams.Result()
        
        local actual_meta = getmetatable(actual_result)
        local expected_meta = getmetatable(expected_result)
        
        assert.are.equal(expected_meta, actual_meta)
      end)
    
      it("SHOULD return a protobuf object which string-serialized form equals to that of the expected result", function()
        
        local actual_result = sut.call_procedure(request.type, request)
        local expected_result = qlua.SetLabelParams.Result()
        
        expected_result.result = proc_result
        
        assert.are.equal(expected_result:SerializeToString(), actual_result:SerializeToString())
      end)
    end)
  
    describe("WITHOUT arguments", function()
      
      it("SHOULD raise an error", function()
        
        assert.has_error(function() sut.call_procedure(request.type) end, "The request has no arguments.")
      end)
    end)
  end)

end)
