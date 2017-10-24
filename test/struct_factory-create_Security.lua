package.path = "../?.lua;" .. package.path

require 'busted.runner'()

describe("The function utils.struct_factory.create_Security", function()
    
  local qlua_structs = require("messages.qlua_structures_pb")
    
  local sut = require("utils.struct_factory")
  
  describe("WHEN given no security table", function()
      
    it("SHOULD raise an error", function()
      assert.has_error(sut.create_Security, "No security table provided.")
    end)
  end)
  
  -----

  describe("WHEN given a Security table", function()
      
    local security
    
    setup(function()
        
      security = {
        code = "test-code", 
        name = "test-name", 
        short_name = "test-short_name", 
        class_code = "test-class_code", 
        class_name = "test-class_name", 
        face_value = 1, 
        face_unit = "test-face_unit", 
        scale = 100, 
        mat_date = 1020304050, 
        lot_size = 10, 
        isin_code = "test-isin_code", 
        min_price_step = 1.0
      }
    end)
  
    teardown(function()
      security = nil
    end)
  
    it("SHOULD return an equal protobuf Security struct", function()
        
      local result = sut.create_Security(security)
        
      -- check the result is a protobuf Security structure
      local expected_meta = getmetatable( qlua_structs.Security() )
      local actual_meta = getmetatable(result)
      assert.are.equal(expected_meta, actual_meta)
      
      -- check that the result has the same data as the given transaction table
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if type(security[key]) == 'number' then 
          t_data[key] = tonumber(value)
        else
          t_data[key] = value
        end
      end

      assert.are.same(security, t_data)
    end)
  
    describe("AND an existing Security protobuf struct", function()
      
      local existing_struct
      
      setup(function()
        existing_struct = qlua_structs.Security()
      end)
  
      teardown(function()
        existing_struct = nil
      end)
    
      it("SHOULD return the existing Security protobuf struct which equals (data-wide, not literally) to the given Security table", function()
          
        local result = sut.create_Security(security, existing_struct)
        
        assert.are.equals(existing_struct, result)
        
        -- check that the result has the same data as the given security table
        local t_data = {}
        for field, value in result:ListFields() do
          local key = tostring(field.name)
          if type(security[key]) == 'number' then 
            t_data[key] = tonumber(value)
          else
            t_data[key] = value
          end
        end

        assert.are.same(security, t_data)
      end)
    end)
      
    local nonnullable_fields_names = {"code", "class_code"}
    local nullable_fields_names = {"name", "short_name", "class_name", "face_value", "face_unit", "scale", "mat_date", "lot_size", "isin_code", "min_price_step"}
      
    for _, field_name in ipairs(nonnullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()

        local stored_value
    
        setup(function()
          stored_value = security[field_name]
          security[field_name] = nil
        end)
    
        teardown(function()
          security[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD raise an error", function()
          assert.has_error(function() sut.create_Security(security) end)
        end)
      end)
    
      -----
    end
      
    for _, field_name in ipairs(nullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()
          
        local stored_value
    
        setup(function()
          stored_value = security[field_name]
          security[field_name] = nil
        end)
    
        teardown(function()
          security[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD return a struct with an empty string in that field", function()
          
          local result = sut.create_Security(security)
          assert.are.equal("", result[field_name])
        end)
      end)
    
      -----
    end
  end)
  
  -----
  
  describe("WHEN given a money limit table with CP1251-encoded values", function()
      
    local utils = require("utils.utils")
    
    local security_utf8, security_cp1251
    
    setup(function()
      
      security_utf8 = {
        code = "test-code", 
        name = "тестовое наименование", 
        short_name = "тестовое короткое наименование", 
        class_code = "тестовый код класса", 
        class_name = "тестовое наименование класса", 
        face_value = 1, 
        face_unit = "тестовая единица измерения?", 
        scale = 100, 
        mat_date = 1020304050, 
        lot_size = 10, 
        isin_code = "test-isin_code", 
        min_price_step = 1.0
      }
      
      -- the list of fields that potentially may be encoded in CP1251 encoding
      local fields_that_may_be_encoded_in_cp1251 = {
        name = true, 
        short_name = true, 
        class_code = true, 
        class_name = true, 
        face_unit = true
      }
      
      security_cp1251 = {}
      for k, v in pairs(security_utf8) do
        if fields_that_may_be_encoded_in_cp1251[k] then
          security_cp1251[k] = utils.Utf8ToCp1251( security_utf8[k] )
        else
          security_cp1251[k] = v
        end
      end
    end)
  
    teardown(function()
      security_utf8 = nil
      security_cp1251 = nil
    end)
  
    it("SHOULD return a struct with UTF8 encoded values", function()
      
      local result = sut.create_Security(security_cp1251)
      
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if type(security_utf8[key]) == 'number' then 
          t_data[key] = tonumber(value)
        else
          t_data[key] = value
        end
      end

      assert.are.same(security_utf8, t_data)
    end)
  
  end)
end)
