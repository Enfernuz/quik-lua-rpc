package.path = "../?.lua;" .. package.path

require 'busted.runner'()

describe("The function utils.struct_factory.create_DepoLimitDelete", function()
    
  local qlua_structs = require("qlua.rpc.qlua_structures_pb")
    
  local sut = require("utils.struct_factory")
  
  describe("WHEN given no depo limit delete table", function()
      
    it("SHOULD raise an error", function()
      assert.has_error(sut.create_DepoLimitDelete, "No dlimit_del table provided.")
    end)
  end)
  
  -----

  describe("WHEN given a depo limit delete table", function()
      
    local dlimit_del
    
    setup(function()
        
      dlimit_del = {
        sec_code = "test-sec_code", 
        trdaccid = "test-trdaccid", 
        firmid = "test-firmid", 
        client_code = "test-client_code", 
        limit_kind = 0
      }
    end)
  
    teardown(function()
      dlimit_del = nil
    end)
  
    it("SHOULD return an equal protobuf DepoLimitDelete struct", function()
        
      local result = sut.create_DepoLimitDelete(dlimit_del)
        
      -- check the result is a protobuf DepoLimitDelete structure
      local expected_meta = getmetatable( qlua_structs.DepoLimitDelete() )
      local actual_meta = getmetatable(result)
      assert.are.equal(expected_meta, actual_meta)
      
      -- check that the result has the same data as the given depo limit delete table
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if type(dlimit_del[key]) == 'number' then 
          t_data[key] = tonumber(value)
        else
          t_data[key] = value
        end
      end

      assert.are.same(dlimit_del, t_data)
    end)
  
    describe("AND an existing DepoLimitDelete protobuf struct", function()
      
      local existing_struct
      
      setup(function()
        existing_struct = qlua_structs.DepoLimitDelete()
      end)
  
      teardown(function()
        existing_struct = nil
      end)
    
      it("SHOULD return the existing DepoLimitDelete protobuf struct which equals (data-wide, not literally) to the given depo limit delete table", function()
          
        local result = sut.create_DepoLimitDelete(dlimit_del, existing_struct)
        
        assert.are.equals(existing_struct, result)
        
        -- check that the result has the same data as the given depo limit delete table
        local t_data = {}
        for field, value in result:ListFields() do
          local key = tostring(field.name)
          if type(dlimit_del[key]) == 'number' then 
            t_data[key] = tonumber(value)
          else
            t_data[key] = value
          end
        end

        assert.are.same(dlimit_del, t_data)
      end)
    end)
      
    local nonnullable_fields_names = {"sec_code", "trdaccid", "firmid", "client_code", "limit_kind"}
    local nullable_fields_names = {}
      
    for _, field_name in ipairs(nonnullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()

        local stored_value
    
        setup(function()
          stored_value = dlimit_del[field_name]
          dlimit_del[field_name] = nil
        end)
    
        teardown(function()
          dlimit_del[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD raise an error", function()
          assert.has_error(function() sut.create_DepoLimitDelete(dlimit_del) end)
        end)
      end)
    
      -----
    end
      
    for _, field_name in ipairs(nullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()
          
        local stored_value
    
        setup(function()
          stored_value = dlimit_del[field_name]
          dlimit_del[field_name] = nil
        end)
    
        teardown(function()
          dlimit_del[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD return a struct with an empty string in that field", function()
          
          local result = sut.create_DepoLimitDelete(dlimit_del)
          assert.are.equal("", result[field_name])
        end)
      end)
    
      -----
    end
  end)
  
  -----
  
  describe("WHEN given a depo limit delete table with CP1251-encoded values", function()
      
    local utils = require("utils.utils")
    
    local dlimit_del_utf8, dlimit_del_cp1251
    
    setup(function()
      
      dlimit_del_utf8 = {
        sec_code = "RASP", 
        trdaccid = "тестовый айди аккаунта", 
        firmid = "тестовый айди фирмы", 
        client_code = "тестовый код клиента", 
        limit_kind = 0
      }
      
      -- the list of fields that potentially may be encoded in CP1251 encoding
      local fields_that_may_be_encoded_in_cp1251 = {
        trdaccid = true, 
        firmid = true, 
        client_code = true
      }
      
      dlimit_del_cp1251 = {}
      for k, v in pairs(dlimit_del_utf8) do
        if fields_that_may_be_encoded_in_cp1251[k] then
          dlimit_del_cp1251[k] = utils.Utf8ToCp1251( dlimit_del_utf8[k] )
        else
          dlimit_del_cp1251[k] = v
        end
      end
    end)
  
    teardown(function()
      dlimit_del_utf8 = nil
      dlimit_del_cp1251 = nil
    end)
  
    it("SHOULD return a struct with UTF8 encoded values", function()
      
      local result = sut.create_DepoLimitDelete(dlimit_del_cp1251)
      
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if type(dlimit_del_utf8[key]) == 'number' then 
          t_data[key] = tonumber(value)
        else
          t_data[key] = value
        end
      end

      assert.are.same(dlimit_del_utf8, t_data)
    end)
  
  end)
end)
