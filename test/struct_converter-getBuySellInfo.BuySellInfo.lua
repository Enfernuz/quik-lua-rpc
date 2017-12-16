package.path = "../?.lua;" .. package.path

require 'busted.runner'()

describe("The function utils.struct_converter.getBuySellInfo.BuySellInfo", function()
    
  local qlua = require("qlua.api")
    
  local sut = require("utils.struct_converter")
  
  describe("WHEN given no 'buy_sell_info' table", function()
      
    it("SHOULD raise an error", function()
      assert.has_error(sut.getBuySellInfo.BuySellInfo, "No 'buy_sell_info' table provided.")
    end)
  end)
  
  -----

  describe("WHEN given a 'buy_sell_info' table", function()
      
    local buy_sell_info
    
    setup(function()
        
      buy_sell_info = {
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
    end)
  
    teardown(function()
      buy_sell_info = nil
    end)
  
    it("SHOULD return an equal protobuf getBuySellInfo.BuySellInfo struct", function()
        
      local result = sut.getBuySellInfo.BuySellInfo(buy_sell_info)
        
      -- check the result is a protobuf getBuySellInfo.BuySellInfo structure
      local expected_meta = getmetatable( qlua.getBuySellInfo.BuySellInfo() )
      local actual_meta = getmetatable(result)
      assert.are.equal(expected_meta, actual_meta)
      
      -- check that the result has the same data as the given 'buy_sell_info' table
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if type(buy_sell_info[key]) == 'number' then 
          t_data[key] = tonumber(value)
        else
          t_data[key] = value
        end
      end

      assert.are.same(buy_sell_info, t_data)
    end)
  
    describe("AND an existing getBuySellInfo.BuySellInfo protobuf struct", function()
      
      local existing_struct
      
      setup(function()
        existing_struct = qlua.getBuySellInfo.BuySellInfo()
      end)
  
      teardown(function()
        existing_struct = nil
      end)
    
      it("SHOULD return the existing getBuySellInfo.BuySellInfo protobuf struct which equals (data-wide, not literally) to the given 'buy_sell_info' table", function()
          
        local result = sut.getBuySellInfo.BuySellInfo(buy_sell_info, existing_struct)
        
        assert.are.equals(existing_struct, result)
        
        -- check that the result has the same data as the given 'buy_sell_info' table
        local t_data = {}
        for field, value in result:ListFields() do
          local key = tostring(field.name)
          if type(buy_sell_info[key]) == 'number' then 
            t_data[key] = tonumber(value)
          else
            t_data[key] = value
          end
        end

        assert.are.same(buy_sell_info, t_data)
      end)
    end)

    local nonnullable_fields_names = {}
    local nullable_fields_names = {"is_margin_sec", "is_asset_sec", "balance", "can_buy", "can_sell", "position_valuation", "value", "open_value", "lim_long", "long_coef", "lim_short", "short_coef", "value_coef", "open_value_coef", "share", "short_wa_price", "long_wa_price", "profit_loss", "spread_hc", "can_buy_own", "can_sell_own"}

    for _, field_name in ipairs(nonnullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()

        local stored_value
    
        setup(function()
          stored_value = buy_sell_info[field_name]
          buy_sell_info[field_name] = nil
        end)
    
        teardown(function()
          buy_sell_info[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD raise an error", function()
          assert.has_error(function() sut.getBuySellInfo.BuySellInfo(buy_sell_info) end)
        end)
      end)
    
      -----
    end
      
    for _, field_name in ipairs(nullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()
          
        local stored_value
    
        setup(function()
          stored_value = buy_sell_info[field_name]
          buy_sell_info[field_name] = nil
        end)
    
        teardown(function()
          buy_sell_info[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD return a struct with an empty string in that field", function()
          
          local result = sut.getBuySellInfo.BuySellInfo(buy_sell_info)
          assert.are.equal("", result[field_name])
        end)
      end)
    
      -----
    end
  end)
  
  -----
  
  describe("WHEN given a 'buy_sell_info' with CP1251-encoded values", function()
      
    local utils = require("utils.utils")
    
    local buy_sell_info_utf8, buy_sell_info_cp1251
    
    setup(function()
      
      buy_sell_info_utf8 = {
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
      
      -- the list of fields that potentially may be encoded in CP1251 encoding
      local fields_that_may_be_encoded_in_cp1251 = {}
      
      buy_sell_info_cp1251 = {}
      for k, v in pairs(buy_sell_info_utf8) do
        if fields_that_may_be_encoded_in_cp1251[k] then
          buy_sell_info_cp1251[k] = utils.Utf8ToCp1251( buy_sell_info_utf8[k] )
        else
          buy_sell_info_cp1251[k] = v
        end
      end
    end)
  
    teardown(function()
      buy_sell_info_utf8 = nil
      buy_sell_info_cp1251 = nil
    end)
  
    it("SHOULD return a struct with UTF8 encoded values", function()
      
      local result = sut.getBuySellInfo.BuySellInfo(buy_sell_info_cp1251)
      
      -- check that the result has the same data as the given alltrade
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if type(buy_sell_info_utf8[key]) == 'number' then 
          t_data[key] = tonumber(value)
        else
          t_data[key] = value
        end
      end
      
      assert.are.same(buy_sell_info_utf8, t_data)
    end)
  
  end)
end)
