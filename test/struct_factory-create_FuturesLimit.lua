package.path = "../?.lua;" .. package.path

require 'busted.runner'()

describe("The function utils.struct_factory.create_FuturesLimit", function()
    
  local qlua_structs = require("messages.qlua_structures_pb")
    
  local sut = require("utils.struct_factory")
  
  describe("WHEN given no futures limit table", function()
      
    it("SHOULD raise an error", function()
      assert.has_error(sut.create_FuturesLimit, "No fut_limit table provided.")
    end)
  end)
  
  -----

  describe("WHEN given futures limit table", function()
      
    local fut_limit
    
    setup(function()
        
      fut_limit = {
        firmid = "test-firmid",
        trdaccid = "test-trdaccid", 
        limit_type = 1, 
        liquidity_coef = 0.56,
        cbp_prev_limit = 123.4, 
        cbplimit = 234.56, 
        cbplused = 345.6, 
        cbplplanned = 456.78, 
        varmargin = 98.89, 
        accruedint = 12.3, 
        cbplused_for_orders = 32.19, 
        cbplused_for_positions = 19.23, 
        options_premium = 77.89, 
        ts_comission = 0.81, 
        kgo = 4567, 
        currcode = "test-currcode", 
        real_varmargin = 83.91
      }
    end)
  
    teardown(function()
      fut_limit = nil
    end)
  
    it("SHOULD return an equal protobuf FuturesLimit struct", function()
        
      local result = sut.create_FuturesLimit(fut_limit)
        
      -- check the result is a protobuf FuturesLimit structure
      local expected_meta = getmetatable( qlua_structs.FuturesLimit() )
      local actual_meta = getmetatable(result)
      assert.are.equal(expected_meta, actual_meta)
      
      -- check that the result has the same data as the given account balance
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if type(fut_limit[key]) == 'number' then 
          t_data[key] = tonumber(value)
        else
          t_data[key] = value
        end
      end

      assert.are.same(fut_limit, t_data)
    end)
  
    describe("AND an existing FuturesLimit protobuf struct", function()
      
      local existing_struct
      
      setup(function()
        existing_struct = qlua_structs.FuturesLimit()
      end)
  
      teardown(function()
        existing_struct = nil
      end)
    
      it("SHOULD return the existing FuturesLimit protobuf struct which equals (data-wide, not literally) to the given futures limit table", function()
          
        local result = sut.create_FuturesLimit(fut_limit, existing_struct)
        
        assert.are.equals(existing_struct, result)
        
        -- check that the result has the same data as the given futures limit table
        local t_data = {}
        for field, value in result:ListFields() do
          local key = tostring(field.name)
          if type(fut_limit[key]) == 'number' then 
            t_data[key] = tonumber(value)
          else
            t_data[key] = value
          end
        end

        assert.are.same(fut_limit, t_data)
      end)
    end)
      
    local nonnullable_fields_names = {"firmid", "trdaccid", "limit_type", "currcode"}
    local nullable_fields_names = {"liquidity_coef", "cbp_prev_limit", "cbplimit", "cbplused", "cbplplanned", "varmargin", "accruedint", "cbplused_for_orders", "cbplused_for_positions", "options_premium", "ts_comission", "kgo", "real_varmargin"}
      
    for _, field_name in ipairs(nonnullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()

        local stored_value
    
        setup(function()
          stored_value = fut_limit[field_name]
          fut_limit[field_name] = nil
        end)
    
        teardown(function()
          fut_limit[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD raise an error", function()
          assert.has_error(function() sut.create_FuturesLimit(fut_limit) end)
        end)
      end)
    
      -----
    end
      
    for _, field_name in ipairs(nullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()
          
        local stored_value
    
        setup(function()
          stored_value = fut_limit[field_name]
          fut_limit[field_name] = nil
        end)
    
        teardown(function()
          fut_limit[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD return a struct with an empty string in that field", function()
          
          local result = sut.create_FuturesLimit(fut_limit)
          assert.are.equal("", result[field_name])
        end)
      end)
    
      -----
    end
  end)
  
  -----
  
  describe("WHEN given a futures limit table with CP1251-encoded values", function()
      
    local utils = require("utils.utils")
    
    local fut_limit_utf8, fut_limit_cp1251
    
    setup(function()
      
      fut_limit_utf8 = {
        firmid = "тестовый айди фирмы",
        trdaccid = "тестовый айди торгового аккаунта", 
        limit_type = 1, 
        liquidity_coef = 0.56,
        cbp_prev_limit = 123.4, 
        cbplimit = 234.56, 
        cbplused = 345.6, 
        cbplplanned = 456.78, 
        varmargin = 98.89, 
        accruedint = 12.3, 
        cbplused_for_orders = 32.19, 
        cbplused_for_positions = 19.23, 
        options_premium = 77.89, 
        ts_comission = 0.81, 
        kgo = 4567, 
        currcode = "тестовый код валюты", 
        real_varmargin = 83.91
      }
      
      -- the list of fields that potentially may be encoded in CP1251 encoding
      local fields_that_may_be_encoded_in_cp1251 = {
        firmid = true, 
        trdaccid = true, 
        currcode = true
      }
      
      fut_limit_cp1251 = {}
      for k, v in pairs(fut_limit_utf8) do
        if fields_that_may_be_encoded_in_cp1251[k] then
          fut_limit_cp1251[k] = utils.Utf8ToCp1251( fut_limit_utf8[k] )
        else
          fut_limit_cp1251[k] = v
        end
      end
    end)
  
    teardown(function()
      fut_limit_utf8 = nil
      fut_limit_cp1251 = nil
    end)
  
    it("SHOULD return a struct with UTF8 encoded values", function()
      
      local result = sut.create_FuturesLimit(fut_limit_cp1251)
      
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if type(fut_limit_utf8[key]) == 'number' then 
          t_data[key] = tonumber(value)
        else
          t_data[key] = value
        end
      end

      assert.are.same(fut_limit_utf8, t_data)
    end)
  
  end)
end)
