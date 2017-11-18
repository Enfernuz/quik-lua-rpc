package.path = "../?.lua;" .. package.path

require 'busted.runner'()

describe("The function utils.struct_converter.create_getMoney_Money", function()
    
  local qlua = require("qlua.api")
    
  local sut = require("utils.struct_converter")
  
  describe("WHEN given no 'money' table", function()
      
    it("SHOULD raise an error", function()
      assert.has_error(sut.create_getMoney_Money, "No 'money' table provided.")
    end)
  end)
  
  -----

  describe("WHEN given a 'money' table", function()
      
    local money
    
    setup(function()
        
      money = {
        money_open_limit = 100500.30, 
        money_limit_locked_nonmarginal_value = 99.8, 
        money_limit_locked = 99, 
        money_open_balance = 200000, 
        money_current_limit = 100000.1,
        money_current_balance = 199999.99,
        money_limit_available = 500.500
      }
    end)
  
    teardown(function()
      money = nil
    end)
  
    it("SHOULD return an equal protobuf getMoney.Money struct", function()
        
      local result = sut.create_getMoney_Money(money)
        
      -- check the result is a protobuf getMoney.Money structure
      local expected_meta = getmetatable( qlua.getMoney.Money() )
      local actual_meta = getmetatable(result)
      assert.are.equal(expected_meta, actual_meta)
      
      -- check that the result has the same data as the given 'money' table
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if type(money[key]) == 'number' then 
          t_data[key] = tonumber(value)
        else
          t_data[key] = value
        end
      end

      assert.are.same(money, t_data)
    end)
  
    describe("AND an existing getMoney.Money protobuf struct", function()
      
      local existing_struct
      
      setup(function()
        existing_struct = qlua.getMoney.Money()
      end)
  
      teardown(function()
        existing_struct = nil
      end)
    
      it("SHOULD return the existing getMoney.Money protobuf struct which equals (data-wide, not literally) to the given 'money' table", function()
          
        local result = sut.create_getMoney_Money(money, existing_struct)
        
        assert.are.equals(existing_struct, result)
        
        -- check that the result has the same data as the given 'money' table
        local t_data = {}
        for field, value in result:ListFields() do
          local key = tostring(field.name)
          if type(money[key]) == 'number' then 
            t_data[key] = tonumber(value)
          else
            t_data[key] = value
          end
        end

        assert.are.same(money, t_data)
      end)
    end)
      
    local nonnullable_fields_names = {}
    local nullable_fields_names = {"money_open_limit", "money_limit_locked_nonmarginal_value", "money_limit_locked", "money_open_balance", "money_current_limit", "money_current_balance", "money_limit_available"}
      
    for _, field_name in ipairs(nonnullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()

        local stored_value
    
        setup(function()
          stored_value = money[field_name]
          money[field_name] = nil
        end)
    
        teardown(function()
          money[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD raise an error", function()
          assert.has_error(function() sut.create_getMoney_Money(money) end)
        end)
      end)
    
      -----
    end
      
    for _, field_name in ipairs(nullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()
          
        local stored_value
    
        setup(function()
          stored_value = money[field_name]
          money[field_name] = nil
        end)
    
        teardown(function()
          money[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD return a struct with an empty string in that field", function()
          
          local result = sut.create_getMoney_Money(money)
          assert.are.equal("", result[field_name])
        end)
      end)
    
      -----
    end
  end)
  
  -----
end)
