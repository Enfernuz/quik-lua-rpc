package.path = "../?.lua;" .. package.path

require 'busted.runner'()

describe("The function utils.struct_converter.getPortfolioInfoEx.PortfolioInfoEx", function()
    
  local qlua = require("qlua.api")
    
  local sut = require("utils.struct_converter")
  
  describe("WHEN given no 'portfolio_info_ex' table", function()
      
    it("SHOULD raise an error", function()
      assert.has_error(sut.getPortfolioInfoEx.PortfolioInfoEx, "No 'portfolio_info_ex' table provided.")
    end)
  end)
  
  -----

  describe("WHEN given a 'portfolio_info_ex' table", function()
      
    local portfolio_info_ex
    
    setup(function()
        
      portfolio_info_ex = {
        
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
    end)
  
    teardown(function()
      portfolio_info_ex = nil
    end)
  
    it("SHOULD return an equal protobuf getPortfolioInfoEx.PortfolioInfoEx struct", function()
        
      local result = sut.getPortfolioInfoEx.PortfolioInfoEx(portfolio_info_ex)
        
      -- check the result is a protobuf getPortfolioInfoEx.PortfolioInfoEx structure
      local expected_meta = getmetatable( qlua.getPortfolioInfoEx.PortfolioInfoEx() )
      local actual_meta = getmetatable(result)
      assert.are.equal(expected_meta, actual_meta)
      
      -- check that the result has the same data as the given 'portfolio_info_ex' table
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if type(portfolio_info_ex[key]) == 'number' then 
          t_data[key] = tonumber(value)
        elseif key == 'portfolio_info' then
          
          for portoflio_info_inner_field, portoflio_info_inner_value in value:ListFields() do
            local k = tostring(portoflio_info_inner_field.name)
            if type(portfolio_info_ex[k]) == 'number' then 
              t_data[k] = tonumber(portoflio_info_inner_value)
            else
              t_data[k] = portoflio_info_inner_value
            end
          end
          
        else
          t_data[key] = value
        end
      end

      assert.are.same(portfolio_info_ex, t_data)
    end)
  
    describe("AND an existing getPortfolioInfoEx.PortfolioInfoEx protobuf struct", function()
      
      local existing_struct
      
      setup(function()
        existing_struct = qlua.getPortfolioInfoEx.PortfolioInfoEx()
      end)
  
      teardown(function()
        existing_struct = nil
      end)
    
      it("SHOULD return the existing getPortfolioInfoEx.PortfolioInfoEx protobuf struct which equals (data-wide, not literally) to the given 'portfolio_info_ex' table", function()
          
        local result = sut.getPortfolioInfoEx.PortfolioInfoEx(portfolio_info_ex, existing_struct)
        
        assert.are.equals(existing_struct, result)
        
        -- check that the result has the same data as the given 'portfolio_info_ex' table
        local t_data = {}
        for field, value in result:ListFields() do
          local key = tostring(field.name)
          if type(portfolio_info_ex[key]) == 'number' then 
            t_data[key] = tonumber(value)
          elseif key == 'portfolio_info' then
            
            for portoflio_info_inner_field, portoflio_info_inner_value in value:ListFields() do
              local k = tostring(portoflio_info_inner_field.name)
              if type(portfolio_info_ex[k]) == 'number' then 
                t_data[k] = tonumber(portoflio_info_inner_value)
              else
                t_data[k] = portoflio_info_inner_value
              end
            end
            
          else
            t_data[key] = value
          end
        end

        assert.are.same(portfolio_info_ex, t_data)
      end)
    end)

    local nonnullable_fields_names = {}
    local nullable_fields_names = {"init_margin", "min_margin", "corrected_margin", "client_type", "portfolio_value", "start_limit_open_pos", "total_limit_open_pos", "limit_open_pos", "used_lim_open_pos", "acc_var_margin", "cl_var_margin", "opt_liquid_cost", "fut_asset", "fut_total_asset", "fut_debt", "fut_rate_asset", "fut_rate_asset_open", "fut_rate_go", "planed_rate_go", "cash_leverage", "fut_position_type", "fut_accured_int"}

    for _, field_name in ipairs(nonnullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()

        local stored_value
    
        setup(function()
          stored_value = portfolio_info_ex[field_name]
          portfolio_info_ex[field_name] = nil
        end)
    
        teardown(function()
          portfolio_info_ex[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD raise an error", function()
          assert.has_error(function() sut.getPortfolioInfoEx.PortfolioInfoEx(portfolio_info_ex) end)
        end)
      end)
    
      -----
    end
      
    for _, field_name in ipairs(nullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()
          
        local stored_value
    
        setup(function()
          stored_value = portfolio_info_ex[field_name]
          portfolio_info_ex[field_name] = nil
        end)
    
        teardown(function()
          portfolio_info_ex[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD return a struct with an empty string in that field", function()
          
          local result = sut.getPortfolioInfoEx.PortfolioInfoEx(portfolio_info_ex)

          assert.are.equal("", result[field_name])
        end)
      end)
    
      -----
    end
  end)
  
  -----
  
  describe("WHEN given a 'portfolio_info_ex' with CP1251-encoded values", function()
      
    local utils = require("utils.utils")
    
    local portfolio_info_ex_utf8, portfolio_info_ex_cp1251
    
    setup(function()
      
      portfolio_info_ex_utf8 = {
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
      
      -- the list of fields that potentially may be encoded in CP1251 encoding
      local fields_that_may_be_encoded_in_cp1251 = {}
      
      portfolio_info_ex_cp1251 = {}
      for k, v in pairs(portfolio_info_ex_utf8) do
        if fields_that_may_be_encoded_in_cp1251[k] then
          portfolio_info_ex_cp1251[k] = utils.Utf8ToCp1251( portfolio_info_ex_utf8[k] )
        else
          portfolio_info_ex_cp1251[k] = v
        end
      end
    end)
  
    teardown(function()
      portfolio_info_ex_utf8 = nil
      portfolio_info_ex_cp1251 = nil
    end)
  
    it("SHOULD return a struct with UTF8 encoded values", function()
      
      local result = sut.getPortfolioInfoEx.PortfolioInfoEx(portfolio_info_ex_cp1251)
      
      -- check that the result has the same data as the given 'portfolio_info_ex' table
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if type(portfolio_info_ex_utf8[key]) == 'number' then 
          t_data[key] = tonumber(value)
        elseif key == 'portfolio_info' then
          
          for portoflio_info_inner_field, portoflio_info_inner_value in value:ListFields() do
            local k = tostring(portoflio_info_inner_field.name)
            if type(portfolio_info_ex_utf8[k]) == 'number' then 
              t_data[k] = tonumber(portoflio_info_inner_value)
            else
              t_data[k] = portoflio_info_inner_value
            end
          end
          
        else
          t_data[key] = value
        end
      end
      
      assert.are.same(portfolio_info_ex_utf8, t_data)
    end)
  
  end)
end)
