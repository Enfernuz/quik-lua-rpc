package.path = "../?.lua;" .. package.path

require 'busted.runner'()

describe("The function utils.struct_factory.create_Firm", function()
    
  local qlua_structs = require("messages.qlua_structures_pb")
    
  local sut = require("utils.struct_factory")
  
  describe("WHEN given no firm", function()
      
    it("SHOULD raise an error", function()
      assert.has_error(sut.create_Firm, "No firm provided.")
    end)
  end)
  
  -----

  describe("WHEN given a firm", function()
      
    local firm
    
    setup(function()
        
      firm = {
        firmid = "test-firmid",
        firm_name = "test-firm_name",
        status = 1,
        exchange = "test-exchange"
      }
    end)
  
    teardown(function()
      firm = nil
    end)
  
    it("SHOULD return an equal protobuf Firm struct", function()
        
      local result = sut.create_Firm(firm)
        
      -- check the result is a protobuf Firm structure
      local expected_pb_firm_meta = getmetatable( qlua_structs.Firm() )
      local actual_meta = getmetatable(result)
      assert.are.equal(expected_pb_firm_meta, actual_meta)
      
      -- check that the result has the same data as the given firm
      local expected_data = {}
      for field, value in result:ListFields() do
        expected_data[tostring(field.name)] = value
      end
      assert.are.same(expected_data, firm)
      
    end)
      
    local nonnullable_fields_names = {"firmid", "status"}
    local nullable_fields_names = {"firm_name", "exchange"}
      
    for _, field_name in ipairs(nonnullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()

        local stored_value
    
        setup(function()
          stored_value = firm[field_name]
          firm[field_name] = nil
        end)
    
        teardown(function()
          firm[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD raise an error", function()
          assert.has_error(function() sut.create_Firm(firm) end)
        end)
      end)
    
      -----
    end
      
    for _, field_name in ipairs(nullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()
          
        local stored_value
    
        setup(function()
          stored_value = firm[field_name]
          firm[field_name] = nil
        end)
    
        teardown(function()
          firm[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD return a struct with an empty string in that field", function()
          
          local result = sut.create_Firm(firm)
          assert.are.equal("", result[field_name])
        end)
      end)
    
      -----
    end
  end)
  
  -----
  
  describe("WHEN given a firm with CP1251-encoded values", function()
      
    local utils = require("utils.utils")
    
    local firm_utf8, firm_cp1251
    
    setup(function()
      
      firm_utf8 = {
        firmid = "тестовый идентификатор фирмы",
        firm_name = "тестовое наименование фирмы",
        status = 1,
        exchange = "тестовая биржа"
      }
      
      firm_cp1251 = {
        firmid = utils.Utf8ToCp1251(firm_utf8.firmid),
        firm_name = utils.Utf8ToCp1251(firm_utf8.firm_name),
        status = firm_utf8.status,
        exchange = utils.Utf8ToCp1251(firm_utf8.exchange)
      }
    end)
  
    teardown(function()
      firm_utf8 = nil
      firm_cp1251 = nil
    end)
  
    it("SHOULD return a struct with UTF8 encoded values", function()
      
      local result = sut.create_Firm(firm_cp1251)
      
      local expected_data = {}
      for field, value in result:ListFields() do
        expected_data[tostring(field.name)] = value
      end
      assert.are.same(expected_data, firm_utf8)
    end)
  
  end)
end)
