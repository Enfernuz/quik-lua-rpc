package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.rpc-handler", function()
  
  local qlua = require("qlua.api")
  local utils = require("utils.utils")
  local sut = require("impl.rpc-handler")

  describe("WHEN given a request of type ProcedureType.ADD_LABEL", function()
      
    local request
    
    setup(function()
      
      request = {}
      request.type = qlua.RPC.ProcedureType.ADD_LABEL
    end)
  
    teardown(function()
      request = nil
    end)

    insulate("WITH arguments", function()
        
      local request_args
      local proc_result
      
      setup(function()
      
        request_args = qlua.AddLabel.Request()
        request_args.chart_tag = "test-chart_tag"
        
        local p1 = qlua.AddLabel.Request.LabelParamsEntry()
        p1.key = "TEXT"
        p1.value = "sample_text"
        table.insert(request_args.label_params, p1)
  
        local p2 = qlua.AddLabel.Request.LabelParamsEntry()
        p2.key = "IMAGE_PATH"
        p2.value = ""
        table.insert(request_args.label_params, p2)
  
        local p3 = qlua.AddLabel.Request.LabelParamsEntry()
        p3.key = "ALIGNMENT"
        p3.value = "TOP"
        table.insert(request_args.label_params, p3)

        request.args = request_args:SerializeToString()

        proc_result = 123
        
        _G.AddLabel = spy.new(function(chart_tag, label_params) return proc_result end)
        
        _G.table.sinsert = spy.new(function(t, el) return table.insert(t, el) end)
        _G.table.sconcat = spy.new(function(t, el) return table.concat(t, el) end)
      end)

      teardown(function()

        request_args = nil
        proc_result = nil
      end)
    
      it("SHOULD call the global 'AddLabel' function once, passing the 'chart_tag' argument 1st and the 'label_params' converted to an ordinary table 2nd", function()
        
        local response = sut.call_procedure(request.type, request.args)
    
        assert.spy(_G.AddLabel).was.called_with(request_args.chart_tag, utils.create_table(request_args.label_params))
      end)
    
      it("SHOULD return a qlua.AddLabel.Result instance", function()
          
        local actual_result = sut.call_procedure(request.type, request.args)
        local expected_result = qlua.AddLabel.Result()
        
        local actual_meta = getmetatable(actual_result)
        local expected_meta = getmetatable(expected_result)
        
        assert.are.equal(expected_meta, actual_meta)
      end)
    
      it("SHOULD return a protobuf object which string-serialized form equals to that of the expected result", function()
        
        local actual_result = sut.call_procedure(request.type, request.args)
        local expected_result = qlua.AddLabel.Result()
        
        expected_result.label_id = proc_result
        
        assert.are.equal(expected_result:SerializeToString(), actual_result:SerializeToString())
      end)
    
      insulate("AND the global 'AddLabel' returns nil", function()
          
        setup(function()
          _G.AddLabel = spy.new(function(chart_tag, label_params) return nil end)
        end)
      
        it("SHOULD raise an error", function()
          
          local label_params_as_table = utils.create_table(request_args.label_params)
          local expected_error_msg = string.format("Процедура AddLabel(%s, %s) возвратила nil.", request_args.chart_tag, utils.table.tostring(label_params_as_table))
          
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
