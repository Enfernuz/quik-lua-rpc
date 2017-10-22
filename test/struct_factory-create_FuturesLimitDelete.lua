package.path = "../?.lua;" .. package.path

require 'busted.runner'()

describe("The function utils.struct_factory.create_FuturesLimitDelete", function()
    
  local qlua_structs = require("messages.qlua_structures_pb")
    
  local sut = require("utils.struct_factory")
  
  describe("WHEN given no futures limit delete table", function()
      
    it("SHOULD raise an error", function()
      assert.has_error(sut.create_FuturesLimitDelete, "No lim_del table provided.")
    end)
  end)
  
  -----

  describe("WHEN given futures limit delete table", function()
      
    local lim_del
    
    setup(function()
        
      lim_del = {
        firmid = "test-firmid", 
        limit_type = 2
      }
    end)
  
    teardown(function()
      lim_del = nil
    end)
  
    it("SHOULD return an equal protobuf FuturesLimitDelete struct", function()
        
      local result = sut.create_FuturesLimitDelete(lim_del)
        
      -- check the result is a protobuf FuturesLimitDelete structure
      local expected_meta = getmetatable( qlua_structs.FuturesLimitDelete() )
      local actual_meta = getmetatable(result)
      assert.are.equal(expected_meta, actual_meta)
      
      -- check that the result has the same data as the given futures limit delete table
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if type(lim_del[key]) == 'number' then 
          t_data[key] = tonumber(value)
        else
          t_data[key] = value
        end
      end

      assert.are.same(lim_del, t_data)
    end)
      
    local nonnullable_fields_names = {"firmid", "limit_type"}
    local nullable_fields_names = {}
      
    for _, field_name in ipairs(nonnullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()

        local stored_value
    
        setup(function()
          stored_value = lim_del[field_name]
          lim_del[field_name] = nil
        end)
    
        teardown(function()
          lim_del[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD raise an error", function()
          assert.has_error(function() sut.create_FuturesLimitDelete(lim_del) end)
        end)
      end)
    
      -----
    end
      
    for _, field_name in ipairs(nullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()
          
        local stored_value
    
        setup(function()
          stored_value = lim_del[field_name]
          lim_del[field_name] = nil
        end)
    
        teardown(function()
          lim_del[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD return a struct with an empty string in that field", function()
          
          local result = sut.create_FuturesLimitDelete(lim_del)
          assert.are.equal("", result[field_name])
        end)
      end)
    
      -----
    end
  end)
  
  -----
  
  describe("WHEN given a futures limit delete table with CP1251-encoded values", function()
      
    local utils = require("utils.utils")
    
    local lim_del_utf8, lim_del_cp1251
    
    setup(function()
      
      lim_del_utf8 = {
        firmid = "тестовый айди фирмы",
        limit_type = 2, 
      }
      
      -- the list of fields that potentially may be encoded in CP1251 encoding
      local fields_that_may_be_encoded_in_cp1251 = { firmid = true }
      
      lim_del_cp1251 = {}
      for k, v in pairs(lim_del_utf8) do
        if fields_that_may_be_encoded_in_cp1251[k] then
          lim_del_cp1251[k] = utils.Utf8ToCp1251( lim_del_utf8[k] )
        else
          lim_del_cp1251[k] = v
        end
      end
    end)
  
    teardown(function()
      lim_del_utf8 = nil
      lim_del_cp1251 = nil
    end)
  
    it("SHOULD return a struct with UTF8 encoded values", function()
      
      local result = sut.create_FuturesLimitDelete(lim_del_cp1251)
      
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if type(lim_del_utf8[key]) == 'number' then 
          t_data[key] = tonumber(value)
        else
          t_data[key] = value
        end
      end

      assert.are.same(lim_del_utf8, t_data)
    end)
  
  end)
end)
