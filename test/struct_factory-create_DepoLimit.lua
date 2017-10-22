package.path = "../?.lua;" .. package.path

require 'busted.runner'()

describe("The function utils.struct_factory.create_DepoLimit", function()
    
  local qlua_structs = require("messages.qlua_structures_pb")
    
  local sut = require("utils.struct_factory")
  
  describe("WHEN given no depo limit table", function()
      
    it("SHOULD raise an error", function()
      assert.has_error(sut.create_DepoLimit, "No dlimit table provided.")
    end)
  end)
  
  -----

  describe("WHEN given a depo limit table", function()
      
    local dlimit
    
    setup(function()
        
      dlimit = {
        sec_code = "test-sec_code", 
        trdaccid = "test-trdaccid", 
        firmid = "test-firmid", 
        client_code = "test-client_code", 
        openbal = 100, 
        openlimit = 150, 
        currentbal = 90, 
        currentlimit = 140, 
        locked_sell = 10, 
        locked_buy = 20, 
        locked_buy_value = 1200.60, 
        locked_sell_value = 600.30, 
        awg_position_price = 60.3, 
        limit_kind = 0
      }
    end)
  
    teardown(function()
      dlimit = nil
    end)
  
    it("SHOULD return an equal protobuf DepoLimit struct", function()
        
      local result = sut.create_DepoLimit(dlimit)
        
      -- check the result is a protobuf DepoLimit structure
      local expected_meta = getmetatable( qlua_structs.DepoLimit() )
      local actual_meta = getmetatable(result)
      assert.are.equal(expected_meta, actual_meta)
      
      -- check that the result has the same data as the given depo limit table
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if type(dlimit[key]) == 'number' then 
          t_data[key] = tonumber(value)
        else
          t_data[key] = value
        end
      end

      assert.are.same(dlimit, t_data)
    end)
      
    local nonnullable_fields_names = {"sec_code", "trdaccid", "firmid", "client_code", "openbal", "openlimit", "currentbal", "currentlimit", "locked_sell", "locked_buy", "locked_buy_value", "locked_sell_value", "awg_position_price", "limit_kind"}
    local nullable_fields_names = {}
      
    for _, field_name in ipairs(nonnullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()

        local stored_value
    
        setup(function()
          stored_value = dlimit[field_name]
          dlimit[field_name] = nil
        end)
    
        teardown(function()
          dlimit[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD raise an error", function()
          assert.has_error(function() sut.create_DepoLimit(dlimit) end)
        end)
      end)
    
      -----
    end
      
    for _, field_name in ipairs(nullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()
          
        local stored_value
    
        setup(function()
          stored_value = dlimit[field_name]
          dlimit[field_name] = nil
        end)
    
        teardown(function()
          dlimit[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD return a struct with an empty string in that field", function()
          
          local result = sut.create_DepoLimit(dlimit)
          assert.are.equal("", result[field_name])
        end)
      end)
    
      -----
    end
  end)
  
  -----
  
  describe("WHEN given a depo limit table with CP1251-encoded values", function()
      
    local utils = require("utils.utils")
    
    local dlimit_utf8, dlimit_cp1251
    
    setup(function()
      
      dlimit_utf8 = {
        sec_code = "RASP", 
        trdaccid = "тестовый айди аккаунта", 
        firmid = "тестовый айди фирмы", 
        client_code = "тестовый код клиента", 
        openbal = 100, 
        openlimit = 150, 
        currentbal = 90, 
        currentlimit = 140, 
        locked_sell = 10, 
        locked_buy = 20, 
        locked_buy_value = 1200.60, 
        locked_sell_value = 600.30, 
        awg_position_price = 60.3, 
        limit_kind = 0
      }
      
      -- the list of fields that potentially may be encoded in CP1251 encoding
      local fields_that_may_be_encoded_in_cp1251 = {
        trdaccid = true, 
        firmid = true, 
        client_code = true
      }
      
      dlimit_cp1251 = {}
      for k, v in pairs(dlimit_utf8) do
        if fields_that_may_be_encoded_in_cp1251[k] then
          dlimit_cp1251[k] = utils.Utf8ToCp1251( dlimit_utf8[k] )
        else
          dlimit_cp1251[k] = v
        end
      end
    end)
  
    teardown(function()
      dlimit_utf8 = nil
      dlimit_cp1251 = nil
    end)
  
    it("SHOULD return a struct with UTF8 encoded values", function()
      
      local result = sut.create_DepoLimit(dlimit_cp1251)
      
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if type(dlimit_utf8[key]) == 'number' then 
          t_data[key] = tonumber(value)
        else
          t_data[key] = value
        end
      end

      assert.are.same(dlimit_utf8, t_data)
    end)
  
  end)
end)
