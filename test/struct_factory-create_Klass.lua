package.path = "../?.lua;" .. package.path

require 'busted.runner'()

describe("The function utils.struct_factory.create_Klass", function()
    
  local qlua_structs = require("qlua.rpc.qlua_structures_pb")
    
  local sut = require("utils.struct_factory")
  
  describe("WHEN given no class_info table", function()
      
    it("SHOULD raise an error", function()
      assert.has_error(sut.create_Klass, "No class_info table provided.")
    end)
  end)
  
  -----

  describe("WHEN given a class_info table", function()
      
    local class_info
    
    setup(function()
        
      class_info = {
        firmid = "test-firmid", 
        name = "test-name", 
        code = "test-code", 
        npars = 54, 
        nsecs = 45
      }
    end)
  
    teardown(function()
      class_info = nil
    end)
  
    it("SHOULD return an equal protobuf Klass struct", function()
        
      local result = sut.create_Klass(class_info)
        
      -- check the result is a protobuf Klass structure
      local expected_meta = getmetatable( qlua_structs.Klass() )
      local actual_meta = getmetatable(result)
      assert.are.equal(expected_meta, actual_meta)
      
      -- check that the result has the same data as the given class_info
      local expected_data = {}
      for field, value in result:ListFields() do
        expected_data[tostring(field.name)] = value
      end
      
      assert.are.same(expected_data, class_info)
    end)
  
    describe("AND an existing Klass protobuf struct", function()
      
      local existing_struct
      
      setup(function()
        existing_struct = qlua_structs.Klass()
      end)
  
      teardown(function()
        existing_struct = nil
      end)
    
      it("SHOULD return the existing Klass protobuf struct which equals (data-wide, not literally) to the given 'class_info' table", function()
          
        local result = sut.create_Klass(class_info, existing_struct)
        
        assert.are.equals(existing_struct, result)
        
        -- check that the result has the same data as the given 'class_info' table
        local t_data = {}
        for field, value in result:ListFields() do
          local key = tostring(field.name)
          if type(class_info[key]) == 'number' then 
            t_data[key] = tonumber(value)
          else
            t_data[key] = value
          end
        end

        assert.are.same(class_info, t_data)
      end)
    end)
      
    local nonnullable_fields_names = {"code"}
    local nullable_fields_names = {"firmid", "name"}
      
    for _, field_name in ipairs(nonnullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()

        local stored_value
    
        setup(function()
          stored_value = class_info[field_name]
          class_info[field_name] = nil
        end)
    
        teardown(function()
          class_info[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD raise an error", function()
          assert.has_error(function() sut.create_Klass(class_info) end)
        end)
      end)
    
      -----
    end
      
    for _, field_name in ipairs(nullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()
          
        local stored_value
    
        setup(function()
          stored_value = class_info[field_name]
          class_info[field_name] = nil
        end)
    
        teardown(function()
          class_info[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD return a struct with an empty string in that field", function()
          
          local result = sut.create_Klass(class_info)
          assert.are.equal("", result[field_name])
        end)
      end)
    
      -----
    end
  end)
  
  -----
  
  describe("WHEN given a 'class_info' table with CP1251-encoded values", function()
      
    local utils = require("utils.utils")
    
    local class_info_utf8, class_info_cp1251
    
    setup(function()
      
      class_info_utf8 = {
        firmid = "тестовый идентификатор фирмы",
        name = "тестовое имя класса", 
        code = "тестовый код класса",
        npars = 10, 
        nsecs = 21
      }
      
      class_info_cp1251 = {
        firmid = utils.Utf8ToCp1251(class_info_utf8.firmid),
        name = utils.Utf8ToCp1251(class_info_utf8.name),
        code =  utils.Utf8ToCp1251(class_info_utf8.code),
        npars = class_info_utf8.npars, 
        nsecs = class_info_utf8.nsecs
      }
    end)
  
    teardown(function()
      class_info_utf8 = nil
      class_info_cp1251 = nil
    end)
  
    it("SHOULD return a struct with UTF8 encoded values", function()
      
      local result = sut.create_Klass(class_info_cp1251)
      
      local expected_data = {}
      for field, value in result:ListFields() do
        expected_data[tostring(field.name)] = value
      end
      assert.are.same(expected_data, class_info_utf8)
    end)
  
  end)
end)
