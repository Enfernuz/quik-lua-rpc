package.path = "../?.lua;" .. package.path

require 'busted.runner'()

describe("The function utils.struct_factory.create_FuturesClientHolding", function()
    
  local qlua_structs = require("messages.qlua_structures_pb")
    
  local sut = require("utils.struct_factory")
  
  describe("WHEN given no futures client holding table", function()
      
    it("SHOULD raise an error", function()
      assert.has_error(sut.create_FuturesClientHolding, "No fut_pos table provided.")
    end)
  end)
  
  -----

  describe("WHEN given futures client holding table", function()
      
    local fut_pos
    
    setup(function()
        
      fut_pos = {
        firmid = "test-firmid", 
        trdaccid = "test-trdaccid", 
        sec_code = "test-sec_code", 
        type = 2, 
        startbuy = 13.95, 
        startsell = 15.03, 
        todaybuy = 14.43, 
        todaysell = 14.99, 
        totalnet = 5.56, 
        openbuys = 25, 
        opensells = 20, 
        cbplused = 300.01, 
        cbplplanned = 299.98, 
        varmargin = 7.87, 
        avrposnprice = 14.50, 
        positionvalue = 14.34, 
        real_varmargin = 7.42, 
        total_varmargin = 7.24, 
        session_status = 1
      }
    end)
  
    teardown(function()
      fut_pos = nil
    end)
  
    it("SHOULD return an equal protobuf FuturesClientHolding struct", function()
        
      local result = sut.create_FuturesClientHolding(fut_pos)
        
      -- check the result is a protobuf FuturesClientHolding structure
      local expected_meta = getmetatable( qlua_structs.FuturesClientHolding() )
      local actual_meta = getmetatable(result)
      assert.are.equal(expected_meta, actual_meta)
      
      -- check that the result has the same data as the given futures client holding table
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if type(fut_pos[key]) == 'number' then 
          t_data[key] = tonumber(value)
        else
          t_data[key] = value
        end
      end

      assert.are.same(fut_pos, t_data)
    end)
      
    local nonnullable_fields_names = {"firmid", "trdaccid", "sec_code", "type", "openbuys", "opensells", "session_status"}
    local nullable_fields_names = {"startbuy", "startsell", "todaybuy", "todaysell", "totalnet", "cbplused", "cbplplanned", "varmargin", "avrposnprice", "positionvalue", "real_varmargin", "total_varmargin"}
      
    for _, field_name in ipairs(nonnullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()

        local stored_value
    
        setup(function()
          stored_value = fut_pos[field_name]
          fut_pos[field_name] = nil
        end)
    
        teardown(function()
          fut_pos[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD raise an error", function()
          assert.has_error(function() sut.create_FuturesClientHolding(fut_pos) end)
        end)
      end)
    
      -----
    end
      
    for _, field_name in ipairs(nullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()
          
        local stored_value
    
        setup(function()
          stored_value = fut_pos[field_name]
          fut_pos[field_name] = nil
        end)
    
        teardown(function()
          fut_pos[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD return a struct with an empty string in that field", function()
          
          local result = sut.create_FuturesClientHolding(fut_pos)
          assert.are.equal("", result[field_name])
        end)
      end)
    
      -----
    end
  end)
  
  -----
  
  describe("WHEN given a futures client holding table with CP1251-encoded values", function()
      
    local utils = require("utils.utils")
    
    local fut_pos_utf8, fut_pos_cp1251
    
    setup(function()
      
      fut_pos_utf8 = {
        firmid = "тестовый айди фирмы", 
        trdaccid = "тестовый айди аккаунта", 
        sec_code = "RBCM", 
        type = 2, 
        startbuy = 13.95, 
        startsell = 15.03, 
        todaybuy = 14.43, 
        todaysell = 14.99, 
        totalnet = 5.56, 
        openbuys = 25, 
        opensells = 20, 
        cbplused = 300.01, 
        cbplplanned = 299.98, 
        varmargin = 7.87, 
        avrposnprice = 14.50, 
        positionvalue = 14.34, 
        real_varmargin = 7.42, 
        total_varmargin = 7.24, 
        session_status = 1
      }
      
      -- the list of fields that potentially may be encoded in CP1251 encoding
      local fields_that_may_be_encoded_in_cp1251 = {
        firmid = true, 
        trdaccid = true
      }
      
      fut_pos_cp1251 = {}
      for k, v in pairs(fut_pos_utf8) do
        if fields_that_may_be_encoded_in_cp1251[k] then
          fut_pos_cp1251[k] = utils.Utf8ToCp1251( fut_pos_utf8[k] )
        else
          fut_pos_cp1251[k] = v
        end
      end
    end)
  
    teardown(function()
      fut_pos_utf8 = nil
      fut_pos_cp1251 = nil
    end)
  
    it("SHOULD return a struct with UTF8 encoded values", function()
      
      local result = sut.create_FuturesClientHolding(fut_pos_cp1251)
      
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if type(fut_pos_utf8[key]) == 'number' then 
          t_data[key] = tonumber(value)
        else
          t_data[key] = value
        end
      end

      assert.are.same(fut_pos_utf8, t_data)
    end)
  
  end)
end)
