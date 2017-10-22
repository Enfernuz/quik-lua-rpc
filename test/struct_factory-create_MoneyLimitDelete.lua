package.path = "../?.lua;" .. package.path

require 'busted.runner'()

describe("The function utils.struct_factory.create_MoneyLimitDelete", function()
    
  local qlua_structs = require("messages.qlua_structures_pb")
    
  local sut = require("utils.struct_factory")
  
  describe("WHEN given no money limit delete table", function()
      
    it("SHOULD raise an error", function()
      assert.has_error(sut.create_MoneyLimitDelete, "No mlimit_del table provided.")
    end)
  end)
  
  -----

  describe("WHEN given a money limit delete table", function()
      
    local mlimit_del
    
    setup(function()
        
      mlimit_del = {
        currcode = "test-currcode", 
        tag = "test-tag", 
        firmid = "test-firmid", 
        client_code = "test-client_code", 
        limit_kind = 0
      }
    end)
  
    teardown(function()
      mlimit_del = nil
    end)
  
    it("SHOULD return an equal protobuf MoneyLimitDelete struct", function()
        
      local result = sut.create_MoneyLimitDelete(mlimit_del)
        
      -- check the result is a protobuf MoneyLimitDelete structure
      local expected_meta = getmetatable( qlua_structs.MoneyLimitDelete() )
      local actual_meta = getmetatable(result)
      assert.are.equal(expected_meta, actual_meta)
      
      -- check that the result has the same data as the given money limit delete table
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if type(mlimit_del[key]) == 'number' then 
          t_data[key] = tonumber(value)
        else
          t_data[key] = value
        end
      end

      assert.are.same(mlimit_del, t_data)
    end)
      
    local nonnullable_fields_names = {"currcode", "tag", "firmid", "client_code", "limit_kind"}
    local nullable_fields_names = {}
      
    for _, field_name in ipairs(nonnullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()

        local stored_value
    
        setup(function()
          stored_value = mlimit_del[field_name]
          mlimit_del[field_name] = nil
        end)
    
        teardown(function()
          mlimit_del[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD raise an error", function()
          assert.has_error(function() sut.create_MoneyLimitDelete(mlimit_del) end)
        end)
      end)
    
      -----
    end
      
    for _, field_name in ipairs(nullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()
          
        local stored_value
    
        setup(function()
          stored_value = mlimit_del[field_name]
          mlimit_del[field_name] = nil
        end)
    
        teardown(function()
          mlimit_del[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD return a struct with an empty string in that field", function()
          
          local result = sut.create_MoneyLimitDelete(mlimit_del)
          assert.are.equal("", result[field_name])
        end)
      end)
    
      -----
    end
  end)
  
  -----
  
  describe("WHEN given a money limit delete table with CP1251-encoded values", function()
      
    local utils = require("utils.utils")
    
    local mlimit_del_utf8, mlimit_del_cp1251
    
    setup(function()
      
      mlimit_del_utf8 = {
        currcode = "тестовый код валюты", 
        tag = "тестовый тэг", 
        firmid = "тестовый айди фирмы", 
        client_code = "тестовый код клиента", 
        limit_kind = 0
      }
      
      -- the list of fields that potentially may be encoded in CP1251 encoding
      local fields_that_may_be_encoded_in_cp1251 = {
        currcode = true, 
        tag = true, 
        firmid = true, 
        client_code = true
      }
      
      mlimit_del_cp1251 = {}
      for k, v in pairs(mlimit_del_utf8) do
        if fields_that_may_be_encoded_in_cp1251[k] then
          mlimit_del_cp1251[k] = utils.Utf8ToCp1251( mlimit_del_utf8[k] )
        else
          mlimit_del_cp1251[k] = v
        end
      end
    end)
  
    teardown(function()
      mlimit_del_utf8 = nil
      mlimit_del_cp1251 = nil
    end)
  
    it("SHOULD return a struct with UTF8 encoded values", function()
      
      local result = sut.create_MoneyLimitDelete(mlimit_del_cp1251)
      
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if type(mlimit_del_utf8[key]) == 'number' then 
          t_data[key] = tonumber(value)
        else
          t_data[key] = value
        end
      end

      assert.are.same(mlimit_del_utf8, t_data)
    end)
  
  end)
end)
