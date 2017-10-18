package.path = "../?.lua;" .. package.path

require 'busted.runner'()

describe("The function utils.struct_factory.create_AccountBalance", function()
    
  local qlua_structs = require("messages.qlua_structures_pb")
    
  local sut = require("utils.struct_factory")
  
  describe("WHEN given no account balance table", function()
      
    it("SHOULD raise an error", function()
      assert.has_error(sut.create_AccountBalance, "No acc_bal table provided.")
    end)
  end)
  
  -----

  describe("WHEN given account balance table", function()
      
    local account_balance
    
    setup(function()
        
      account_balance = {
        firmid = "test-firmid", 
        sec_code = "test-sec_code",
        trdaccid = "test-trdaccid", 
        depaccid = "test-depaccid", 
        openbal = 2143.65, 
        currentpos = 4365.76, 
        plannedpossell = 1234.56, 
        plannedposbuy = 6543.21, 
        planbal = 3456.78, 
        usqtyb = 123.40, 
        usqtys = 234.56, 
        planned = 345.76, 
        settlebal = 456.78, 
        bank_acc_id = "test-bank_acc_id", 
        firmuse = 5
      }
    end)
  
    teardown(function()
      account_balance = nil
    end)
  
    it("SHOULD return an equal protobuf AccountBalance struct", function()
        
      local result = sut.create_AccountBalance(account_balance)
        
      -- check the result is a protobuf Order structure
      local expected_meta = getmetatable( qlua_structs.AccountBalance() )
      local actual_meta = getmetatable(result)
      assert.are.equal(expected_meta, actual_meta)
      
      -- check that the result has the same data as the given account balance
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if type(account_balance[key]) == 'number' then 
          t_data[key] = tonumber(value)
        else
          t_data[key] = value
        end
      end

      assert.are.same(account_balance, t_data)
    end)
      
    local nonnullable_fields_names = {"firmid", "sec_code", "trdaccid", "depaccid", "openbal", "currentpos", "firmuse"}
    local nullable_fields_names = {"plannedpossell", "plannedposbuy", "planbal", "usqtyb", "usqtys", "planned", "settlebal", "bank_acc_id"}
      
    for _, field_name in ipairs(nonnullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()

        local stored_value
    
        setup(function()
          stored_value = account_balance[field_name]
          account_balance[field_name] = nil
        end)
    
        teardown(function()
          account_balance[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD raise an error", function()
          assert.has_error(function() sut.create_AccountBalance(account_balance) end)
        end)
      end)
    
      -----
    end
      
    for _, field_name in ipairs(nullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()
          
        local stored_value
    
        setup(function()
          stored_value = account_balance[field_name]
          account_balance[field_name] = nil
        end)
    
        teardown(function()
          account_balance[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD return a struct with an empty string in that field", function()
          
          local result = sut.create_AccountBalance(account_balance)
          assert.are.equal("", result[field_name])
        end)
      end)
    
      -----
    end
  end)
  
  -----
  
  describe("WHEN given an account balance table with CP1251-encoded values", function()
      
    local utils = require("utils.utils")
    
    local account_balance_utf8, account_balance_cp1251
    
    setup(function()
      
      account_balance_utf8 = {
        firmid = "тестовый фирм айди", 
        sec_code = "AFKS",
        trdaccid = "тестовый трейд акк айди", 
        depaccid = "тестовый деп акк айди", 
        openbal = 2143.65, 
        currentpos = 4365.76, 
        plannedpossell = 1234.56, 
        plannedposbuy = 6543.21, 
        planbal = 3456.78, 
        usqtyb = 123.40, 
        usqtys = 234.56, 
        planned = 345.76, 
        settlebal = 456.78, 
        bank_acc_id = "тестовый банк акк айди", 
        firmuse = 5
      }
      
      -- the list of fields that potentially may be encoded in CP1251 encoding
      local fields_that_may_be_encoded_in_cp1251 = {
        firmid = true, 
        trdaccid = true, 
        depaccid = true, 
        bank_acc_id = true
      }
      
      account_balance_cp1251 = {}
      for k, v in pairs(account_balance_utf8) do
        if fields_that_may_be_encoded_in_cp1251[k] then
          account_balance_cp1251[k] = utils.Utf8ToCp1251( account_balance_utf8[k] )
        else
          account_balance_cp1251[k] = v
        end
      end
    end)
  
    teardown(function()
      account_balance_utf8 = nil
      account_balance_cp1251 = nil
    end)
  
    it("SHOULD return a struct with UTF8 encoded values", function()
      
      local result = sut.create_AccountBalance(account_balance_cp1251)
      
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if type(account_balance_utf8[key]) == 'number' then 
          t_data[key] = tonumber(value)
        else
          t_data[key] = value
        end
      end

      assert.are.same(account_balance_utf8, t_data)
    end)
  
  end)
end)
