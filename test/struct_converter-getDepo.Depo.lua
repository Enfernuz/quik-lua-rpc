package.path = "../?.lua;" .. package.path

require 'busted.runner'()

describe("The function utils.struct_converter.getDepo.Depo", function()
    
  local qlua = require("qlua.api")
    
  local sut = require("utils.struct_converter")
  
  describe("WHEN given no 'depo' table", function()
      
    it("SHOULD raise an error", function()
      assert.has_error(sut.getDepo.Depo, "No 'depo' table provided.")
    end)
  end)
  
  -----

  describe("WHEN given a 'depo' table", function()
      
    local depo
    
    setup(function()
        
      depo = {
        depo_limit_locked_buy_value = 100500.30, 
        depo_current_balance = 99.8, 
        depo_limit_locked_buy = 99, 
        depo_limit_locked = 200000, 
        depo_limit_available = 100000.1,
        depo_current_limit = 199999.99,
        depo_open_balance = 500.500, 
        depo_open_limit = 123.45
      }
    end)
  
    teardown(function()
      depo = nil
    end)
  
    it("SHOULD return an equal protobuf getDepo.Depo struct", function()
        
      local result = sut.getDepo.Depo(depo)
        
      -- check the result is a protobuf getDepo.Depo structure
      local expected_meta = getmetatable( qlua.getDepo.Depo() )
      local actual_meta = getmetatable(result)
      assert.are.equal(expected_meta, actual_meta)
      
      -- check that the result has the same data as the given 'depo' table
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if type(depo[key]) == 'number' then 
          t_data[key] = tonumber(value)
        else
          t_data[key] = value
        end
      end

      assert.are.same(depo, t_data)
    end)
  
    describe("AND an existing getDepo.Depo protobuf struct", function()
      
      local existing_struct
      
      setup(function()
        existing_struct = qlua.getDepo.Depo()
      end)
  
      teardown(function()
        existing_struct = nil
      end)
    
      it("SHOULD return the existing getDepo.Depo protobuf struct which equals (data-wide, not literally) to the given 'depo' table", function()
          
        local result = sut.getDepo.Depo(depo, existing_struct)
        
        assert.are.equals(existing_struct, result)
        
        -- check that the result has the same data as the given 'depo' table
        local t_data = {}
        for field, value in result:ListFields() do
          local key = tostring(field.name)
          if type(depo[key]) == 'number' then 
            t_data[key] = tonumber(value)
          else
            t_data[key] = value
          end
        end

        assert.are.same(depo, t_data)
      end)
    end)

    local nonnullable_fields_names = {}
    local nullable_fields_names = {"depo_limit_locked_buy_value", "depo_current_balance", "depo_limit_locked_buy", "depo_limit_locked", "depo_limit_available", "depo_current_limit", "depo_open_balance", "depo_open_limit"}
      
    for _, field_name in ipairs(nonnullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()

        local stored_value
    
        setup(function()
          stored_value = depo[field_name]
          depo[field_name] = nil
        end)
    
        teardown(function()
          depo[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD raise an error", function()
          assert.has_error(function() sut.getDepo.Depo(depo) end)
        end)
      end)
    
      -----
    end
      
    for _, field_name in ipairs(nullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()
          
        local stored_value
    
        setup(function()
          stored_value = depo[field_name]
          depo[field_name] = nil
        end)
    
        teardown(function()
          depo[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD return a struct with an empty string in that field", function()
          
          local result = sut.getDepo.Depo(depo)
          assert.are.equal("", result[field_name])
        end)
      end)
    
      -----
    end
  end)
  
  -----
end)
