package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.rpc-handler", function()
  
  local qlua = require("qlua.api")
  local struct_converter = require("utils.struct_converter")
  local sut = require("impl.rpc-handler")

  describe("WHEN given a request of type ProcedureType.GET_BUY_SELL_INFO", function()
      
    local request
    
    setup(function()
      
      request = {}
      request.type = qlua.RPC.ProcedureType.GET_BUY_SELL_INFO
    end)
  
    teardown(function()
      request = nil
    end)

    insulate("WITH arguments", function()
        
      local request_args
      local proc_result
      
      setup(function()

        request_args = qlua.getBuySellInfo.Request()
        request_args.firm_id = "test-firm_id"
        request_args.client_code = "test-client_code"
        request_args.class_code = "test-class_code"
        request_args.sec_code = "test-sec_code"
        request_args.price = "123.45"
        
        request.args = request_args:SerializeToString()

        proc_result = {
          is_margin_sec = "test-is_margin_sec", 
          is_asset_sec = "test-is_asset_sec", 
          balance = "test-balance", 
          can_buy = "test-can_buy", 
          can_sell = "test-can_sell", 
          position_valuation = "test-position_valuation", 
          value = "test-value", 
          open_value = "test-open_value", 
          lim_long = "test-lim_long", 
          long_coef = "test-long_coef", 
          lim_short = "test-lim_short", 
          short_coef = "test-short_coef", 
          value_coef = "test-value_coef", 
          open_value_coef = "test-open_value_coef", 
          share = "test-share", 
          short_wa_price = "test-short_wa_price", 
          long_wa_price = "test-long_wa_price", 
          profit_loss = "test-profit_loss", 
          spread_hc = "test-spread_hc", 
          can_buy_own = "test-can_buy_own", 
          can_sell_own = "test-can_sell_own"
        }
        
        _G.getBuySellInfo = spy.new(function(firm_id, client_code, class_code, sec_code, price) return proc_result end)
      end)

      teardown(function()

        request_args = nil
        proc_result = nil
      end)
    
      it("SHOULD call the global 'getBuySellInfo' function once, passing the procedure arguments to it AND the 'price' argument must be converted to number", function()
        
        local response = sut.call_procedure(request.type, request.args)
    
        assert.spy(_G.getBuySellInfo).was.called_with(request_args.firm_id, request_args.client_code, request_args.class_code, request_args.sec_code, tonumber(request_args.price))
      end)
    
      it("SHOULD return a qlua.getBuySellInfo.Result instance", function()
          
        local actual_result = sut.call_procedure(request.type, request.args)
        local expected_result = qlua.getBuySellInfo.Result()
        
        local actual_meta = getmetatable(actual_result)
        local expected_meta = getmetatable(expected_result)
        
        assert.are.equal(expected_meta, actual_meta)
      end)
    
      it("SHOULD return a protobuf object which string-serialized form equals to that of the expected result", function()
        
        local actual_result = sut.call_procedure(request.type, request.args)
        local expected_result = qlua.getBuySellInfo.Result()
        
        struct_converter.getBuySellInfo.BuySellInfo(proc_result, expected_result.buy_sell_info)
        
        assert.are.equal(expected_result:SerializeToString(), actual_result:SerializeToString())
      end)
    
      -----
      
      insulate("AND the global 'getBuySellInfo' function returns nil", function()
          
        setup(function()
          _G.getBuySellInfo = spy.new(function(firm_id, client_code, class_code, sec_code, price) return nil end)
        end)
      
        it("SHOULD raise an error", function()
          
          local expected_error_msg = string.format("Процедура getBuySellInfo(%s, %s, %s, %s, %s) возвратила nil.", request_args.firm_id, request_args.client_code, request_args.class_code, request_args.sec_code, request_args.price)
          
          assert.has_error(function() sut.call_procedure(request.type, request.args) end, expected_error_msg)
        end)
      end)
    
      -----
      
      insulate("AND the 'price' argument cannot be converted to a number", function()
        
        local tmp
        
        setup(function()
            
          tmp = request_args.price
          request_args.price = "not a number"
          
          request.args = request_args:SerializeToString()
        end)
      
        teardown(function()
            
          request_args.price = tmp
          tmp = nil
          
          request.args = request_args:SerializeToString()
        end)
      
        it("SHOULD raise an error", function()
            
          local expected_error_msg = string.format("Не удалось преобразовать в число значение '%s' параметра price", request_args.price)
            
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
