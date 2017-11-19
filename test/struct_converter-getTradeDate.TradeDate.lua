package.path = "../?.lua;" .. package.path

require 'busted.runner'()

describe("The function utils.struct_converter.getTradeDate.TradeDate", function()
    
  local qlua = require("qlua.api")
    
  local sut = require("utils.struct_converter")
  
  describe("WHEN given no 'trade_date' table", function()
      
    it("SHOULD raise an error", function()
      assert.has_error(sut.getTradeDate.TradeDate, "No 'trade_date' table provided.")
    end)
  end)
  
  -----

  describe("WHEN given a 'trade_date' table", function()
      
    local trade_date
    
    setup(function()
        
      trade_date = {
        date = "01.02.2017", 
        year = 2017, 
        month = 2, 
        day = 1
      }
    end)
  
    teardown(function()
      trade_date = nil
    end)
  
    it("SHOULD return an equal protobuf getTradeDate.TradeDate struct", function()
        
      local result = sut.getTradeDate.TradeDate(trade_date)
        
      -- check the result is a protobuf getTradeDate.TradeDate structure
      local expected_meta = getmetatable( qlua.getTradeDate.TradeDate() )
      local actual_meta = getmetatable(result)
      assert.are.equal(expected_meta, actual_meta)
      
      -- check that the result has the same data as the given 'trade_date' table
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if type(trade_date[key]) == 'number' then 
          t_data[key] = tonumber(value)
        else
          t_data[key] = value
        end
      end

      assert.are.same(trade_date, t_data)
    end)
  
    describe("AND an existing getTradeDate.TradeDate protobuf struct", function()
      
      local existing_struct
      
      setup(function()
        existing_struct = qlua.getTradeDate.TradeDate()
      end)
  
      teardown(function()
        existing_struct = nil
      end)
    
      it("SHOULD return the existing getTradeDate.TradeDate protobuf struct which equals (data-wide, not literally) to the given 'trade_date' table", function()
          
        local result = sut.getTradeDate.TradeDate(trade_date, existing_struct)
        
        assert.are.equals(existing_struct, result)
        
        -- check that the result has the same data as the given 'trade_date' table
        local t_data = {}
        for field, value in result:ListFields() do
          local key = tostring(field.name)
          if type(trade_date[key]) == 'number' then 
            t_data[key] = tonumber(value)
          else
            t_data[key] = value
          end
        end

        assert.are.same(trade_date, t_data)
      end)
    end)
      
    local nonnullable_fields_names = {"date", "year", "month", "day"}
      
    for _, field_name in ipairs(nonnullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()

        local stored_value
    
        setup(function()
          stored_value = trade_date[field_name]
          trade_date[field_name] = nil
        end)
    
        teardown(function()
          trade_date[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD raise an error", function()
          assert.has_error(function() sut.getTradeDate.TradeDate(trade_date) end)
        end)
      end)
    
      -----
    end
  end)
  
  -----
end)
