package.path = "../?.lua;" .. package.path

require 'busted.runner'()

describe("The function utils.struct_factory.create_ParamEventInfo", function()
    
  local qlua_structs = require("messages.qlua_structures_pb")
    
  local sut = require("utils.struct_factory")
  
  describe("WHEN given no param table", function()
      
    it("SHOULD raise an error", function()
      assert.has_error(sut.create_ParamEventInfo, "No param table provided.")
    end)
  end)
  
  -----

  describe("WHEN given a param table", function()
      
    local param
    
    setup(function()
        
      param = {
        class_code = "test-class_code", 
        sec_code = "test-sec_code"
      }
    end)
  
    teardown(function()
      param = nil
    end)
  
    it("SHOULD return an equal protobuf ParamEventInfo struct", function()
        
      local result = sut.create_ParamEventInfo(param)
        
      -- check the result is a protobuf ParamEventInfo structure
      local expected_meta = getmetatable( qlua_structs.ParamEventInfo() )
      local actual_meta = getmetatable(result)
      assert.are.equal(expected_meta, actual_meta)
      
      -- check that the result has the same data as the given param table
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if type(param[key]) == 'number' then 
          t_data[key] = tonumber(value)
        else
          t_data[key] = value
        end
      end

      assert.are.same(param, t_data)
    end)

    local nonnullable_fields_names = {"class_code", "sec_code"}

    for _, field_name in ipairs(nonnullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()

        local stored_value
    
        setup(function()
          stored_value = param[field_name]
          param[field_name] = nil
        end)
    
        teardown(function()
          param[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD raise an error", function()
          assert.has_error(function() sut.create_ParamEventInfo(param) end)
        end)
      end)
    
      -----
    end
  end)
  
  -----
  
  describe("WHEN given a param table with CP1251-encoded values", function()
      
    local utils = require("utils.utils")
    
    local param_utf8, param_cp1251
    
    setup(function()
      
      param_utf8 = {
        class_code = "тестовый код класса", 
        sec_code = "test-sec_code"
      }
      
      -- the list of fields that potentially may be encoded in CP1251 encoding
      local fields_that_may_be_encoded_in_cp1251 = { class_code = true }
      
      param_cp1251 = {}
      for k, v in pairs(param_utf8) do
        if fields_that_may_be_encoded_in_cp1251[k] then
          param_cp1251[k] = utils.Utf8ToCp1251( param_utf8[k] )
        else
          param_cp1251[k] = v
        end
      end
    end)
  
    teardown(function()
      param_utf8 = nil
      param_cp1251 = nil
    end)
  
    it("SHOULD return a struct with UTF8 encoded values", function()
      
      local result = sut.create_ParamEventInfo(param_cp1251)
      
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if type(param_utf8[key]) == 'number' then 
          t_data[key] = tonumber(value)
        else
          t_data[key] = value
        end
      end

      assert.are.same(param_utf8, t_data)
    end)
  
  end)
end)
