package.path = "../?.lua;" .. package.path

require 'busted.runner'()

describe("The function utils.struct_factory.create_MoneyLimit", function()
    
  local qlua_structs = require("qlua.rpc.qlua_structures_pb")
    
  local sut = require("utils.struct_factory")
  
  describe("WHEN given no money limit table", function()
      
    it("SHOULD raise an error", function()
      assert.has_error(sut.create_MoneyLimit, "No mlimit table provided.")
    end)
  end)
  
  -----

  describe("WHEN given a money limit table", function()
      
    local mlimit
    
    setup(function()
        
      mlimit = {
        currcode = "test-currcode", 
        tag = "test-tag", 
        firmid = "test-firmid", 
        client_code = "test-client_code", 
        openbal = 567.89, 
        openlimit = 234.56, 
        currentbal = 456.78, 
        currentlimit = 123.45, 
        locked = 12.98, 
        locked_value_coef = 0.5, 
        locked_margin_value = 9.88, 
        leverage = 3.0, 
        limit_kind = 0
      }
    end)
  
    teardown(function()
      mlimit = nil
    end)
  
    it("SHOULD return an equal protobuf MoneyLimit struct", function()
        
      local result = sut.create_MoneyLimit(mlimit)
        
      -- check the result is a protobuf MoneyLimit structure
      local expected_meta = getmetatable( qlua_structs.MoneyLimit() )
      local actual_meta = getmetatable(result)
      assert.are.equal(expected_meta, actual_meta)
      
      -- check that the result has the same data as the given money limit table
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if type(mlimit[key]) == 'number' then 
          t_data[key] = tonumber(value)
        else
          t_data[key] = value
        end
      end

      assert.are.same(mlimit, t_data)
    end)
  
    describe("AND an existing MoneyLimit protobuf struct", function()
      
      local existing_struct
      
      setup(function()
        existing_struct = qlua_structs.MoneyLimit()
      end)
  
      teardown(function()
        existing_struct = nil
      end)
    
      it("SHOULD return the existing MoneyLimit protobuf struct which equals (data-wide, not literally) to the given MoneyLimit table", function()
          
        local result = sut.create_MoneyLimit(mlimit, existing_struct)
        
        assert.are.equals(existing_struct, result)
        
        -- check that the result has the same data as the given money limit table
        local t_data = {}
        for field, value in result:ListFields() do
          local key = tostring(field.name)
          if type(mlimit[key]) == 'number' then 
            t_data[key] = tonumber(value)
          else
            t_data[key] = value
          end
        end

        assert.are.same(mlimit, t_data)
      end)
    end)
      
    local nonnullable_fields_names = {"currcode", "tag", "firmid", "client_code", "limit_kind"}
    local nullable_fields_names = {"openbal", "openlimit", "currentbal", "currentlimit", "locked", "locked_value_coef", "locked_margin_value", "leverage"}
      
    for _, field_name in ipairs(nonnullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()

        local stored_value
    
        setup(function()
          stored_value = mlimit[field_name]
          mlimit[field_name] = nil
        end)
    
        teardown(function()
          mlimit[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD raise an error", function()
          assert.has_error(function() sut.create_MoneyLimit(mlimit) end)
        end)
      end)
    
      -----
    end
      
    for _, field_name in ipairs(nullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()
          
        local stored_value
    
        setup(function()
          stored_value = mlimit[field_name]
          mlimit[field_name] = nil
        end)
    
        teardown(function()
          mlimit[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD return a struct with an empty string in that field", function()
          
          local result = sut.create_MoneyLimit(mlimit)
          assert.are.equal("", result[field_name])
        end)
      end)
    
      -----
    end
  end)
  
  -----
  
  describe("WHEN given a money limit table with CP1251-encoded values", function()
      
    local utils = require("utils.utils")
    
    local mlimit_utf8, mlimit_cp1251
    
    setup(function()
      
      mlimit_utf8 = {
        currcode = "тестовый код валюты", 
        tag = "тестовый тэг", 
        firmid = "тестовый айди фирмы", 
        client_code = "тестовый код клиента", 
        openbal = 567.89, 
        openlimit = 234.56, 
        currentbal = 456.78, 
        currentlimit = 123.45, 
        locked = 12.98, 
        locked_value_coef = 0.5, 
        locked_margin_value = 9.88, 
        leverage = 3.0, 
        limit_kind = 0
      }
      
      -- the list of fields that potentially may be encoded in CP1251 encoding
      local fields_that_may_be_encoded_in_cp1251 = {
        currcode = true, 
        tag = true, 
        firmid = true, 
        client_code = true
      }
      
      mlimit_cp1251 = {}
      for k, v in pairs(mlimit_utf8) do
        if fields_that_may_be_encoded_in_cp1251[k] then
          mlimit_cp1251[k] = utils.Utf8ToCp1251( mlimit_utf8[k] )
        else
          mlimit_cp1251[k] = v
        end
      end
    end)
  
    teardown(function()
      mlimit_utf8 = nil
      mlimit_cp1251 = nil
    end)
  
    it("SHOULD return a struct with UTF8 encoded values", function()
      
      local result = sut.create_MoneyLimit(mlimit_cp1251)
      
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if type(mlimit_utf8[key]) == 'number' then 
          t_data[key] = tonumber(value)
        else
          t_data[key] = value
        end
      end

      assert.are.same(mlimit_utf8, t_data)
    end)
  
  end)
end)
