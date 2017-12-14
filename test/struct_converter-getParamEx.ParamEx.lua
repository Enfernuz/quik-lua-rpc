package.path = "../?.lua;" .. package.path

require 'busted.runner'()

describe("The function utils.struct_converter.getParamEx.ParamEx", function()
    
  local qlua = require("qlua.api")
    
  local sut = require("utils.struct_converter")
  
  describe("WHEN given no 'param_ex' table", function()
      
    it("SHOULD raise an error", function()
      assert.has_error(sut.getParamEx.ParamEx, "No 'param_ex' table provided.")
    end)
  end)
  
  -----

  describe("WHEN given a 'param_ex' table", function()
      
    local param_ex
    
    setup(function()
        
      param_ex = {
        param_type ="test-param_type", 
        param_value = "test-param_value", 
        param_image = "test-param_image", 
        result = "test-result"
      }
    end)
  
    teardown(function()
      param_ex = nil
    end)
  
    it("SHOULD return an equal protobuf getParamEx.ParamEx struct", function()
        
      local result = sut.getParamEx.ParamEx(param_ex)
        
      -- check the result is a protobuf getParamEx.ParamEx structure
      local expected_meta = getmetatable( qlua.getParamEx.ParamEx() )
      local actual_meta = getmetatable(result)
      assert.are.equal(expected_meta, actual_meta)
      
      -- check that the result has the same data as the given 'param_ex' table
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if type(param_ex[key]) == 'number' then 
          t_data[key] = tonumber(value)
        else
          t_data[key] = value
        end
      end

      assert.are.same(param_ex, t_data)
    end)
  
    describe("AND an existing getParamEx.ParamEx protobuf struct", function()
      
      local existing_struct
      
      setup(function()
        existing_struct = qlua.getParamEx.ParamEx()
      end)
  
      teardown(function()
        existing_struct = nil
      end)
    
      it("SHOULD return the existing getParamEx.ParamEx protobuf struct which equals (data-wide, not literally) to the given 'param_ex' table", function()
          
        local result = sut.getParamEx.ParamEx(param_ex, existing_struct)
        
        assert.are.equals(existing_struct, result)
        
        -- check that the result has the same data as the given 'param_ex' table
        local t_data = {}
        for field, value in result:ListFields() do
          local key = tostring(field.name)
          if type(param_ex[key]) == 'number' then 
            t_data[key] = tonumber(value)
          else
            t_data[key] = value
          end
        end

        assert.are.same(param_ex, t_data)
      end)
    end)

    local nonnullable_fields_names = {}
    local nullable_fields_names = {"param_type", "param_value", "param_image", "result"}
      
    for _, field_name in ipairs(nonnullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()

        local stored_value
    
        setup(function()
          stored_value = param_ex[field_name]
          param_ex[field_name] = nil
        end)
    
        teardown(function()
          param_ex[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD raise an error", function()
          assert.has_error(function() sut.getParamEx.ParamEx(param_ex) end)
        end)
      end)
    
      -----
    end
      
    for _, field_name in ipairs(nullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()
          
        local stored_value
    
        setup(function()
          stored_value = param_ex[field_name]
          param_ex[field_name] = nil
        end)
    
        teardown(function()
          param_ex[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD return a struct with an empty string in that field", function()
          
          local result = sut.getParamEx.ParamEx(param_ex)
          assert.are.equal("", result[field_name])
        end)
      end)
    
      -----
    end
  end)
  
  -----
  
  describe("WHEN given a 'param_ex' with CP1251-encoded values", function()
      
    local utils = require("utils.utils")
    
    local param_ex_utf8, param_ex_cp1251
    
    setup(function()
      
      param_ex_utf8 = {
        param_type ="test-param_type", 
        param_value = "test-param_value", 
        param_image = "test-param_image", 
        result = "test-result"
      }
      
      -- the list of fields that potentially may be encoded in CP1251 encoding
      local fields_that_may_be_encoded_in_cp1251 = {
        param_type = true, 
        param_value = true, 
        param_image = true, 
        result = true
      }
      
      param_ex_cp1251 = {}
      for k, v in pairs(param_ex_utf8) do
        if fields_that_may_be_encoded_in_cp1251[k] then
          param_ex_cp1251[k] = utils.Utf8ToCp1251( param_ex_utf8[k] )
        else
          param_ex_cp1251[k] = v
        end
      end
    end)
  
    teardown(function()
      param_ex_utf8 = nil
      param_ex_cp1251 = nil
    end)
  
    it("SHOULD return a struct with UTF8 encoded values", function()
      
      local result = sut.getParamEx.ParamEx(param_ex_cp1251)
      
      -- check that the result has the same data as the given alltrade
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if type(param_ex_utf8[key]) == 'number' then 
          t_data[key] = tonumber(value)
        else
          t_data[key] = value
        end
      end
      
      assert.are.same(param_ex_utf8, t_data)
    end)
  
  end)
end)
