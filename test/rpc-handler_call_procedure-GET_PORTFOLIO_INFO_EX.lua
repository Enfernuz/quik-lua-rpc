package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.rpc-handler", function()
  
  local qlua = require("qlua.api")
  local struct_converter = require("utils.struct_converter")
  local sut = require("impl.rpc-handler")

  describe("WHEN given a request of type ProcedureType.GET_PORTFOLIO_INFO_EX", function()
      
    local request
    
    setup(function()
      
      request = {}
      request.type = qlua.RPC.ProcedureType.GET_PORTFOLIO_INFO_EX
    end)
  
    teardown(function()
      request = nil
    end)

    insulate("WITH arguments", function()
        
      local request_args
      local proc_result
      
      setup(function()

        request_args = qlua.getPortfolioInfoEx.Request()
        request_args.firm_id = "test-firm_id"
        request_args.client_code = "test-client_code"
        request_args.limit_kind = 1
        
        request.args = request_args:SerializeToString()

        proc_result = {
        
          is_leverage = "test-is_leverage",
          in_assets = "test-in_assets",
          leverage = "test-leverage",
          open_limit = "test-open_limit",
          val_short = "test-val_short",
          val_long = "test-val_long",
          val_long_margin = "test-val_long_margin",
          val_long_asset = "test-val_long_asset",
          assets = "test-assets",
          cur_leverage = "test-cur_leverage",
          margin = "test-margin",
          lim_all = "test-lim_all",
          av_lim_all = "test-av_lim_all",
          locked_buy = "test-locked_buy",
          locked_buy_margin = "test-locked_buy_margin",
          locked_buy_asset = "test-locked_buy_asset",
          locked_sell = "test-locked_sell",
          locked_value_coef = "test-locked_value_coef",
          in_all_assets = "test-in_all_assets",
          all_assets = "test-all_assets",
          profit_loss = "test-profit_loss",
          rate_change = "test-rate_change",
          lim_buy = "test-lim_buy",
          lim_sell = "test-lim_sell",
          lim_non_margin = "test-lim_non_margin",
          lim_buy_asset = "test-lim_buy_asset",
          val_short_net = "test-val_short_net",
          val_long_net = "test-val_long_net",
          total_money_bal = "test-total_money_bal",
          total_locked_money = "test-total_locked_money",
          haircuts = "test-haircuts",
          assets_without_hc = "test-assets_without_hc",
          status_coef = "test-status_coef",
          varmargin = "test-varmargin",
          go_for_positions = "test-go_for_positions",
          go_for_orders = "test-go_for_orders",
          rate_futures = "test-rate_futures",
          is_qual_client = "test-is_qual_client",
          is_futures = "test-is_futures",
          curr_tag = "test-curr_tag", 
          
          init_margin = "test-init_margin",
          min_margin = "test-min_margin",
          corrected_margin = "test-corrected_margin",
          client_type = "test-client_type", 
          portfolio_value = "test-portfolio_value", 
          start_limit_open_pos = "test-start_limit_open_pos",
          total_limit_open_pos = "test-total_limit_open_pos", 
          limit_open_pos = "test-limit_open_pos", 
          used_lim_open_pos = "test-used_lim_open_pos", 
          acc_var_margin = "test-acc_var_margin", 
          cl_var_margin = "test-cl_var_margin", 
          opt_liquid_cost = "test-opt_liquid_cost", 
          fut_asset = "test-fut_asset", 
          fut_total_asset = "test-fut_total_asset", 
          fut_debt = "test-fut_debt", 
          fut_rate_asset = "test-fut_rate_asset", 
          fut_rate_asset_open = "test-fut_rate_asset_open", 
          fut_rate_go = "test-fut_rate_go", 
          planed_rate_go = "test-planed_rate_go", 
          cash_leverage = "test-cash_leverage", 
          fut_position_type = "test-fut_position_type", 
          fut_accured_int = "test-fut_accured_int"
        }
        
        _G.getPortfolioInfoEx = spy.new(function(firm_id, client_code, limit_kind) return proc_result end)
      end)

      teardown(function()

        request_args = nil
        proc_result = nil
      end)
    
      it("SHOULD call the global 'getPortfolioInfoEx' function once, passing the procedure arguments to it", function()
        
        local response = sut.call_procedure(request.type, request.args)
    
        assert.spy(_G.getPortfolioInfoEx).was.called_with(request_args.firm_id, request_args.client_code, request_args.limit_kind)
      end)
    
      it("SHOULD return a qlua.getPortfolioInfoEx.Result instance", function()
          
        local actual_result = sut.call_procedure(request.type, request.args)
        local expected_result = qlua.getPortfolioInfoEx.Result()
        
        local actual_meta = getmetatable(actual_result)
        local expected_meta = getmetatable(expected_result)
        
        assert.are.equal(expected_meta, actual_meta)
      end)
    
      it("SHOULD return a protobuf object which string-serialized form equals to that of the expected result", function()
        
        local actual_result = sut.call_procedure(request.type, request.args)
        local expected_result = qlua.getPortfolioInfoEx.Result()
        
        struct_converter.getPortfolioInfoEx.PortfolioInfoEx(proc_result, expected_result.portfolio_info_ex)
        
        assert.are.equal(expected_result:SerializeToString(), actual_result:SerializeToString())
      end)
    
      -----
      
      insulate("AND the global 'getPortfolioInfoEx' function returns nil", function()
          
        setup(function()
          _G.getPortfolioInfoEx = spy.new(function(firm_id, client_code, limit_kind) return nil end)
        end)
      
        it("SHOULD raise an error", function()
          
          local expected_error_msg = string.format("Процедура getPortfolioInfoEx(%s, %s, %d) возвратила nil.", request_args.firm_id, request_args.client_code, request_args.limit_kind)
          
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
