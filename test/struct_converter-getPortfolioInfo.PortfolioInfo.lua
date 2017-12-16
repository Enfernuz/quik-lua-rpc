package.path = "../?.lua;" .. package.path

require 'busted.runner'()

describe("The function utils.struct_converter.getPortfolioInfo.PortfolioInfo", function()
    
  local qlua = require("qlua.api")
    
  local sut = require("utils.struct_converter")
  
  describe("WHEN given no 'portfolio_info' table", function()
      
    it("SHOULD raise an error", function()
      assert.has_error(sut.getPortfolioInfo.PortfolioInfo, "No 'portfolio_info' table provided.")
    end)
  end)
  
  -----

  describe("WHEN given a 'portfolio_info' table", function()
      
    local portfolio_info
    
    setup(function()
        
      portfolio_info = {
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
        curr_tag = "test-curr_tag"
      }
    end)
  
    teardown(function()
      portfolio_info = nil
    end)
  
    it("SHOULD return an equal protobuf getPortfolioInfo.PortfolioInfo struct", function()
        
      local result = sut.getPortfolioInfo.PortfolioInfo(portfolio_info)
        
      -- check the result is a protobuf getPortfolioInfo.PortfolioInfostructure
      local expected_meta = getmetatable( qlua.getPortfolioInfo.PortfolioInfo() )
      local actual_meta = getmetatable(result)
      assert.are.equal(expected_meta, actual_meta)
      
      -- check that the result has the same data as the given 'portfolio_info' table
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if type(portfolio_info[key]) == 'number' then 
          t_data[key] = tonumber(value)
        else
          t_data[key] = value
        end
      end

      assert.are.same(portfolio_info, t_data)
    end)
  
    describe("AND an existing getPortfolioInfo.PortfolioInfo protobuf struct", function()
      
      local existing_struct
      
      setup(function()
        existing_struct = qlua.getPortfolioInfo.PortfolioInfo()
      end)
  
      teardown(function()
        existing_struct = nil
      end)
    
      it("SHOULD return the existing getPortfolioInfo.PortfolioInfo protobuf struct which equals (data-wide, not literally) to the given 'portfolio_info' table", function()
          
        local result = sut.getPortfolioInfo.PortfolioInfo(portfolio_info, existing_struct)
        
        assert.are.equals(existing_struct, result)
        
        -- check that the result has the same data as the given 'portfolio_info' table
        local t_data = {}
        for field, value in result:ListFields() do
          local key = tostring(field.name)
          if type(portfolio_info[key]) == 'number' then 
            t_data[key] = tonumber(value)
          else
            t_data[key] = value
          end
        end

        assert.are.same(portfolio_info, t_data)
      end)
    end)

    local nonnullable_fields_names = {}
    local nullable_fields_names = {"is_leverage", "in_assets", "leverage", "open_limit", "val_short", "val_long", "val_long_margin", "val_long_asset", "assets", "cur_leverage", "margin", "lim_all", "av_lim_all", "locked_buy", "locked_buy_margin", "locked_buy_asset", "locked_sell", "locked_value_coef", "in_all_assets", "all_assets", "profit_loss", "rate_change", "lim_buy", "lim_sell", "lim_non_margin", "lim_buy_asset", "val_short_net", "val_long_net", "total_money_bal", "total_locked_money", "haircuts", "assets_without_hc", "status_coef", "varmargin", "go_for_positions", "go_for_orders", "rate_futures", "is_qual_client", "is_futures", "curr_tag"}

    for _, field_name in ipairs(nonnullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()

        local stored_value
    
        setup(function()
          stored_value = portfolio_info[field_name]
          portfolio_info[field_name] = nil
        end)
    
        teardown(function()
          portfolio_info[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD raise an error", function()
          assert.has_error(function() sut.getPortfolioInfo.PortfolioInfo(portfolio_info) end)
        end)
      end)
    
      -----
    end
      
    for _, field_name in ipairs(nullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()
          
        local stored_value
    
        setup(function()
          stored_value = portfolio_info[field_name]
          portfolio_info[field_name] = nil
        end)
    
        teardown(function()
          portfolio_info[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD return a struct with an empty string in that field", function()
          
          local result = sut.getPortfolioInfo.PortfolioInfo(portfolio_info)
          assert.are.equal("", result[field_name])
        end)
      end)
    
      -----
    end
  end)
  
  -----
  
  describe("WHEN given a 'portfolio_info' with CP1251-encoded values", function()
      
    local utils = require("utils.utils")
    
    local portfolio_info_utf8, portfolio_info_cp1251
    
    setup(function()
      
      portfolio_info_utf8 = {
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
        curr_tag = "test-curr_tag"
      }
      
      -- the list of fields that potentially may be encoded in CP1251 encoding
      local fields_that_may_be_encoded_in_cp1251 = {}
      
      portfolio_info_cp1251 = {}
      for k, v in pairs(portfolio_info_utf8) do
        if fields_that_may_be_encoded_in_cp1251[k] then
          portfolio_info_cp1251[k] = utils.Utf8ToCp1251( portfolio_info_utf8[k] )
        else
          portfolio_info_cp1251[k] = v
        end
      end
    end)
  
    teardown(function()
      portfolio_info_utf8 = nil
      portfolio_info_cp1251 = nil
    end)
  
    it("SHOULD return a struct with UTF8 encoded values", function()
      
      local result = sut.getPortfolioInfo.PortfolioInfo(portfolio_info_cp1251)
      
      -- check that the result has the same data as the given alltrade
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if type(portfolio_info_utf8[key]) == 'number' then 
          t_data[key] = tonumber(value)
        else
          t_data[key] = value
        end
      end
      
      assert.are.same(portfolio_info_utf8, t_data)
    end)
  
  end)
end)
