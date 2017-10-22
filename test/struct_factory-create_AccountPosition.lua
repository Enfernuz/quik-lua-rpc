package.path = "../?.lua;" .. package.path

require 'busted.runner'()

describe("The function utils.struct_factory.create_AccountPosition", function()
    
  local qlua_structs = require("messages.qlua_structures_pb")
    
  local sut = require("utils.struct_factory")
  
  describe("WHEN given no account position table", function()
      
    it("SHOULD raise an error", function()
      assert.has_error(sut.create_AccountPosition, "No acc_pos table provided.")
    end)
  end)
  
  -----

  describe("WHEN given an account position table", function()
      
    local acc_pos
    
    setup(function()
        
      acc_pos = {
        firmid = "test-firmid", 
        currcode = "test-currcode", 
        tag = "test-tag", 
        description = "test-description", 
        openbal = 1234.56, 
        currentpos = 2345, 
        plannedpos = 321.09, 
        limit1 = 123.4, 
        limit2 = 234.56, 
        orderbuy = 5, 
        ordersell = 0, 
        netto = 5, 
        plannedbal = 1234.56, 
        debit = 1234.56, 
        credit = 0, 
        bank_acc_id = "test-bank_acc_id", 
        margincall = 650.98, 
        settlebal = 333.44
      }
    end)
  
    teardown(function()
      acc_pos = nil
    end)
  
    it("SHOULD return an equal protobuf AccountPosition struct", function()
        
      local result = sut.create_AccountPosition(acc_pos)
        
      -- check the result is a protobuf AccountPosition structure
      local expected_meta = getmetatable( qlua_structs.AccountPosition() )
      local actual_meta = getmetatable(result)
      assert.are.equal(expected_meta, actual_meta)
      
      -- check that the result has the same data as the given account position table
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if type(acc_pos[key]) == 'number' then 
          t_data[key] = tonumber(value)
        else
          t_data[key] = value
        end
      end

      assert.are.same(acc_pos, t_data)
    end)
      
    local nonnullable_fields_names = {"firmid", "currcode", "tag"}
    local nullable_fields_names = {"description", "openbal", "currentpos", "plannedpos", "limit1", "limit2", "orderbuy", "ordersell", "netto", "plannedbal", "debit", "credit", "bank_acc_id", "margincall", "settlebal"}
      
    for _, field_name in ipairs(nonnullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()

        local stored_value
    
        setup(function()
          stored_value = acc_pos[field_name]
          acc_pos[field_name] = nil
        end)
    
        teardown(function()
          acc_pos[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD raise an error", function()
          assert.has_error(function() sut.create_AccountPosition(acc_pos) end)
        end)
      end)
    
      -----
    end
      
    for _, field_name in ipairs(nullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()
          
        local stored_value
    
        setup(function()
          stored_value = acc_pos[field_name]
          acc_pos[field_name] = nil
        end)
    
        teardown(function()
          acc_pos[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD return a struct with an empty string in that field", function()
          
          local result = sut.create_AccountPosition(acc_pos)
          assert.are.equal("", result[field_name])
        end)
      end)
    
      -----
    end
  end)
  
  -----
  
  describe("WHEN given an account position table with CP1251-encoded values", function()
      
    local utils = require("utils.utils")
    
    local acc_pos_utf8, acc_pos_cp1251
    
    setup(function()
      
      acc_pos_utf8 = {
        firmid = "тестовый айди фирмы", 
        currcode = "тестовый код валюты", 
        tag = "тестовый тэг", 
        description = "тестовое описание", 
        openbal = 1234.56, 
        currentpos = 2345, 
        plannedpos = 321.09, 
        limit1 = 123.4, 
        limit2 = 234.56, 
        orderbuy = 5, 
        ordersell = 0, 
        netto = 5, 
        plannedbal = 1234.56, 
        debit = 1234.56, 
        credit = 0, 
        bank_acc_id = "тестовый айди банковского аккаунта", 
        margincall = 650.98, 
        settlebal = 333.44
      }
      
      -- the list of fields that potentially may be encoded in CP1251 encoding
      local fields_that_may_be_encoded_in_cp1251 = {
        firmid = true, 
        currcode = true, 
        tag = true, 
        description = true, 
        bank_acc_id = true
      }
      
      acc_pos_cp1251 = {}
      for k, v in pairs(acc_pos_utf8) do
        if fields_that_may_be_encoded_in_cp1251[k] then
          acc_pos_cp1251[k] = utils.Utf8ToCp1251( acc_pos_utf8[k] )
        else
          acc_pos_cp1251[k] = v
        end
      end
    end)
  
    teardown(function()
      acc_pos_utf8 = nil
      acc_pos_cp1251 = nil
    end)
  
    it("SHOULD return a struct with UTF8 encoded values", function()
      
      local result = sut.create_AccountPosition(acc_pos_cp1251)
      
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if type(acc_pos_utf8[key]) == 'number' then 
          t_data[key] = tonumber(value)
        else
          t_data[key] = value
        end
      end

      assert.are.same(acc_pos_utf8, t_data)
    end)
  
  end)
end)
