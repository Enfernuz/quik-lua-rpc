package.path = "../?.lua;" .. package.path

require 'busted.runner'()

describe("The function utils.struct_converter.getBuySellInfoEx.BuySellInfoEx", function()
    
  local qlua = require("qlua.api")
    
  local sut = require("utils.struct_converter")
  
  describe("WHEN given no 'buy_sell_info_ex' table", function()
      
    it("SHOULD raise an error", function()
      assert.has_error(sut.getBuySellInfoEx.BuySellInfoEx, "No 'buy_sell_info_ex' table provided.")
    end)
  end)
  
  -----

  describe("WHEN given a 'buy_sell_info_ex' table", function()
      
    local buy_sell_info_ex
    
    setup(function()
        
      buy_sell_info_ex = {
        
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
        can_sell_own = "test-can_sell_own", 
        
        limit_kind = "test-limit_kind", 
        d_long = "test-d_long", 
        d_short = "test-d_short", 
        d_min_long = "test-d_min_long",
        d_min_short = "test-d_min_short", 
        client_type = "test-client_type", 
        is_long_allowed = "test-is_long_allowed", 
        is_short_allowed = "test-is_short_allowed"
      }
    end)
  
    teardown(function()
      buy_sell_info_ex = nil
    end)
  
    it("SHOULD return an equal protobuf getBuySellInfoEx.BuySellInfoEx struct", function()
        
      local result = sut.getBuySellInfoEx.BuySellInfoEx(buy_sell_info_ex)
        
      -- check the result is a protobuf getBuySellInfoEx.BuySellInfoEx structure
      local expected_meta = getmetatable( qlua.getBuySellInfoEx.BuySellInfoEx() )
      local actual_meta = getmetatable(result)
      assert.are.equal(expected_meta, actual_meta)
      
      -- check that the result has the same data as the given 'buy_sell_info_ex' table
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if type(buy_sell_info_ex[key]) == 'number' then 
          t_data[key] = tonumber(value)
        elseif key == 'buy_sell_info' then
          
          for buy_sell_info_inner_field, buy_sell_info_inner_value in value:ListFields() do
            local k = tostring(buy_sell_info_inner_field.name)
            if type(buy_sell_info_ex[k]) == 'number' then 
              t_data[k] = tonumber(buy_sell_info_inner_value)
            else
              t_data[k] = buy_sell_info_inner_value
            end
          end
          
        else
          t_data[key] = value
        end
      end

      assert.are.same(buy_sell_info_ex, t_data)
    end)
  
    describe("AND an existing getBuySellInfoEx.BuySellInfoEx protobuf struct", function()
      
      local existing_struct
      
      setup(function()
        existing_struct = qlua.getBuySellInfoEx.BuySellInfoEx()
      end)
  
      teardown(function()
        existing_struct = nil
      end)
    
      it("SHOULD return the existing getBuySellInfoEx.BuySellInfoEx protobuf struct which equals (data-wide, not literally) to the given 'buy_sell_info_ex' table", function()
          
        local result = sut.getBuySellInfoEx.BuySellInfoEx(buy_sell_info_ex, existing_struct)
        
        assert.are.equals(existing_struct, result)
        
        -- check that the result has the same data as the given 'buy_sell_info_ex' table
        local t_data = {}
        for field, value in result:ListFields() do
          local key = tostring(field.name)
          if type(buy_sell_info_ex[key]) == 'number' then 
            t_data[key] = tonumber(value)
          elseif key == 'buy_sell_info' then
            
            for buy_sell_info_inner_field, buy_sell_info_inner_value in value:ListFields() do
              local k = tostring(buy_sell_info_inner_field.name)
              if type(buy_sell_info_ex[k]) == 'number' then 
                t_data[k] = tonumber(buy_sell_info_inner_value)
              else
                t_data[k] = buy_sell_info_inner_value
              end
            end
            
          else
            t_data[key] = value
          end
        end

        assert.are.same(buy_sell_info_ex, t_data)
      end)
    end)

    local nonnullable_fields_names = {}
    local nullable_fields_names = {"limit_kind", "d_long", "d_short", "d_min_short", "client_type", "is_long_allowed", "is_short_allowed"}

    for _, field_name in ipairs(nonnullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()

        local stored_value
    
        setup(function()
          stored_value = buy_sell_info_ex[field_name]
          buy_sell_info_ex[field_name] = nil
        end)
    
        teardown(function()
          buy_sell_info_ex[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD raise an error", function()
          assert.has_error(function() sut.getBuySellInfoEx.BuySellInfoEx(buy_sell_info_ex) end)
        end)
      end)
    
      -----
    end
      
    for _, field_name in ipairs(nullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()
          
        local stored_value
    
        setup(function()
          stored_value = buy_sell_info_ex[field_name]
          buy_sell_info_ex[field_name] = nil
        end)
    
        teardown(function()
          buy_sell_info_ex[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD return a struct with an empty string in that field", function()
          
          local result = sut.getBuySellInfoEx.BuySellInfoEx(buy_sell_info_ex)

          assert.are.equal("", result[field_name])
        end)
      end)
    
      -----
    end
  end)
  
  -----
  
  describe("WHEN given a 'buy_sell_info_ex' with CP1251-encoded values", function()
      
    local utils = require("utils.utils")
    
    local buy_sell_info_ex_utf8, buy_sell_info_ex_cp1251
    
    setup(function()
      
      buy_sell_info_ex_utf8 = {

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
        can_sell_own = "test-can_sell_own", 
        
        limit_kind = "test-limit_kind", 
        d_long = "test-d_long", 
        d_short = "test-d_short", 
        d_min_long = "test-d_min_long", 
        d_min_short = "test-d_min_short", 
        client_type = "test-client_type", 
        is_long_allowed = "test-is_long_allowed", 
        is_short_allowed = "test-is_short_allowed"
      }
      
      -- the list of fields that potentially may be encoded in CP1251 encoding
      local fields_that_may_be_encoded_in_cp1251 = {}
      
      buy_sell_info_ex_cp1251 = {}
      for k, v in pairs(buy_sell_info_ex_utf8) do
        if fields_that_may_be_encoded_in_cp1251[k] then
          buy_sell_info_ex_cp1251[k] = utils.Utf8ToCp1251( buy_sell_info_ex_utf8[k] )
        else
          buy_sell_info_ex_cp1251[k] = v
        end
      end
    end)
  
    teardown(function()
      buy_sell_info_ex_utf8 = nil
      buy_sell_info_ex_cp1251 = nil
    end)
  
    it("SHOULD return a struct with UTF8 encoded values", function()
      
      local result = sut.getBuySellInfoEx.BuySellInfoEx(buy_sell_info_ex_cp1251)
      
      -- check that the result has the same data as the given 'buy_sell_info_ex' table
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if type(buy_sell_info_ex_utf8[key]) == 'number' then 
          t_data[key] = tonumber(value)
        elseif key == 'buy_sell_info' then
          
          for buy_sell_info_inner_field, buy_sell_info_inner_value in value:ListFields() do
            local k = tostring(buy_sell_info_inner_field.name)
            if type(buy_sell_info_ex_utf8[k]) == 'number' then 
              t_data[k] = tonumber(buy_sell_info_inner_value)
            else
              t_data[k] = buy_sell_info_inner_value
            end
          end
          
        else
          t_data[key] = value
        end
      end
      
      assert.are.same(buy_sell_info_ex_utf8, t_data)
    end)
  
  end)
end)
