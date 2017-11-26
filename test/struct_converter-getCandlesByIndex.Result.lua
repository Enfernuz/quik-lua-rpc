--[[

----- WARNING: THIS IS A LOW-QUALITY TEST. REFACTORING IS WELCOME. -----

--]]

package.path = "../?.lua;" .. package.path

require 'busted.runner'()

describe("[LQ TEST] The function utils.struct_converter.getCandlesByIndex.Result", function()
    
  local qlua = require("qlua.api")
    
  local sut = require("utils.struct_converter")
  
  describe("WHEN given no table as the 1st argument", function()
      
    it("SHOULD raise an error", function()
      assert.has_error(function() sut.getCandlesByIndex.Result(nil) end, "The 1st argument is not a table.")
    end)
  end)

  describe("WHEN given no number as the 2nd argument", function()
      
    it("SHOULD raise an error", function()
      assert.has_error(function() sut.getCandlesByIndex.Result({}, nil) end, "The 2nd argument is not a number.")
    end)
  end)

  describe("WHEN given no string as the 3rd argument", function()
      
    it("SHOULD raise an error", function()
      assert.has_error(function() sut.getCandlesByIndex.Result({}, 1, nil) end, "The 3rd argument is not a string.")
    end)
  end)
  
  -----

  insulate("WHEN given a (t = table, n = number, l = string) arguments", function()

    local t, n, l

    setup(function()
        
      t = {
        {
          open = 99.25, 
          close = 88.63, 
          high = 100.1, 
          low = 85.05, 
          volume = 250543, 
          doesExist = 1, 
          datetime = {
            mcs = 10, 
            ms = 20, 
            sec = 30, 
            min = 35, 
            hour = 11, 
            day = 20, 
            week_day = 5, 
            month = 6, 
            year = 2018
          }
        },
        {
          open = 88.63, 
          close = 89.90, 
          high = 93.25, 
          low = 79.99, 
          volume = 159023, 
          doesExist = 1, 
          datetime = {
            mcs = 9, 
            ms = 19, 
            sec = 22, 
            min = 40, 
            hour = 11, 
            day = 20, 
            week_day = 5, 
            month = 6, 
            year = 2018
          }
        },
        {
          open = 89.91, 
          close = 98.98, 
          high = 99.99, 
          low = 89.91, 
          volume = 299876, 
          doesExist = 0, 
          datetime = {
            mcs = 10, 
            ms = 20, 
            sec = 30, 
            min = 45, 
            hour = 11, 
            day = 20, 
            week_day = 5, 
            month = 6, 
            year = 2018
          }
        }
      }
      
      n = #t
      
      l = "test-l"

      _G.table.sinsert = spy.new(function(t, el) return table.insert(t, el) end)
    end)
  
    teardown(function()
      t = nil
      n = nil
      l = nil
    end)
  
    it("SHOULD return an equal protobuf getCandlesByIndex.Result struct", function()
        
      local result = sut.getCandlesByIndex.Result(t, n, l)

      -- check the result is a protobuf getCandlesByIndex.Result structure
      local expected_meta = getmetatable( qlua.getCandlesByIndex.Result() )
      local actual_meta = getmetatable(result)
      assert.are.equal(expected_meta, actual_meta)
      
      -- check that the result has the same data as the given (t, n, l) arguments
      local data = {t = {}}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if key ~= "t" then
          data[key] = value
        end
      end
      
      for i, candle_entry in ipairs(result.t) do 
        local candle = {}
        for field, value in candle_entry:ListFields() do 
          if field.name == "does_exist" then
            candle["doesExist"] = value
          else
            if type(t[i][field.name]) == 'number' then 
              candle[field.name] = tonumber(value)
            end
          end
        end
        candle.datetime = {} -- it's a protobuf DateTimeEntry in the result, so we should reconstruct it separately as it contains additional protobuf fields.
        for field, value in candle_entry.datetime:ListFields() do
          candle.datetime[field.name] = value
        end
        table.insert(data.t, candle)
      end

      assert.are.same({t = t, n = n, l = l}, data)
    end)
  end)
  
  -----
end)
