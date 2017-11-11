package.path = "../?.lua;" .. package.path

require 'busted.runner'()

describe("The function utils.struct_factory.create_QuoteEventInfo", function()
    
  local qlua_structs = require("qlua.rpc.qlua_structures_pb")
    
  local sut = require("utils.struct_factory")
  
  describe("WHEN given no quote table", function()
      
    it("SHOULD raise an error", function()
      assert.has_error(sut.create_QuoteEventInfo, "No quote table provided.")
    end)
  end)
  
  -----

  describe("WHEN given a quote table", function()
      
    local quote
    
    setup(function()
        
      quote = {
        class_code = "test-class_code", 
        sec_code = "test-sec_code"
      }
    end)
  
    teardown(function()
      quote = nil
    end)
  
    it("SHOULD return an equal protobuf QuoteEventInfo struct", function()
        
      local result = sut.create_QuoteEventInfo(quote)
        
      -- check the result is a protobuf QuoteEventInfo structure
      local expected_meta = getmetatable( qlua_structs.QuoteEventInfo() )
      local actual_meta = getmetatable(result)
      assert.are.equal(expected_meta, actual_meta)
      
      -- check that the result has the same data as the given quote table
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if type(quote[key]) == 'number' then 
          t_data[key] = tonumber(value)
        else
          t_data[key] = value
        end
      end

      assert.are.same(quote, t_data)
    end)

    local nonnullable_fields_names = {"class_code", "sec_code"}

    for _, field_name in ipairs(nonnullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()

        local stored_value
    
        setup(function()
          stored_value = quote[field_name]
          quote[field_name] = nil
        end)
    
        teardown(function()
          quote[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD raise an error", function()
          assert.has_error(function() sut.create_QuoteEventInfo(quote) end)
        end)
      end)
    
      -----
    end
  end)
  
  -----
  
  describe("WHEN given a quote table with CP1251-encoded values", function()
      
    local utils = require("utils.utils")
    
    local quote_utf8, quote_cp1251
    
    setup(function()
      
      quote_utf8 = {
        class_code = "тестовый код класса", 
        sec_code = "test-sec_code"
      }
      
      -- the list of fields that potentially may be encoded in CP1251 encoding
      local fields_that_may_be_encoded_in_cp1251 = { class_code = true }
      
      quote_cp1251 = {}
      for k, v in pairs(quote_utf8) do
        if fields_that_may_be_encoded_in_cp1251[k] then
          quote_cp1251[k] = utils.Utf8ToCp1251( quote_utf8[k] )
        else
          quote_cp1251[k] = v
        end
      end
    end)
  
    teardown(function()
      quote_utf8 = nil
      quote_cp1251 = nil
    end)
  
    it("SHOULD return a struct with UTF8 encoded values", function()
      
      local result = sut.create_QuoteEventInfo(quote_cp1251)
      
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if type(quote_utf8[key]) == 'number' then 
          t_data[key] = tonumber(value)
        else
          t_data[key] = value
        end
      end

      assert.are.same(quote_utf8, t_data)
    end)
  
  end)
end)
