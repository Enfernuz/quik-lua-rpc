package.path = "../?.lua;" .. package.path

require 'busted.runner'()

describe("The function utils.struct_converter.getQuoteLevel2.Result", function()
    
  local qlua = require("qlua.api")
    
  local sut = require("utils.struct_converter")
  
  describe("WHEN given no 'quote_level_2' table", function()
      
    it("SHOULD raise an error", function()
      assert.has_error(sut.getQuoteLevel2.Result, "No 'quote_level_2' table provided.")
    end)
  end)
  
  -----

  insulate("WHEN given a 'quote_level_2' table", function()

    local quote_level_2
    
    setup(function()
        
      quote_level_2 = {
        bid_count = "5", 
        offer_count = "2", 
        bid = {
          {price = "101.1", quantity = "1"}, 
          {price = "101.5", quantity = "3"}, 
          {price = "102.0", quantity = "1"}, 
          {price = "102.9", quantity = "2"},
          {price = "105", quantity = "1"}
        }, 
        offer = {
          {price = "100", quantity = "1"},
          {price = "99.9", quantity = "1"}
        }
      }
      
      _G.table.sinsert = spy.new(function(t, el) return table.insert(t, el) end)
    end)
  
    teardown(function()
      quote_level_2 = nil
    end)
  
    it("SHOULD return an equal protobuf getQuoteLevel2.Result struct", function()
        
      local result = sut.getQuoteLevel2.Result(quote_level_2)
        
      -- check the result is a protobuf getTradeDate.TradeDate structure
      local expected_meta = getmetatable( qlua.getQuoteLevel2.Result() )
      local actual_meta = getmetatable(result)
      assert.are.equal(expected_meta, actual_meta)
      
      -- check that the result has the same data as the given 'trade_date' table
      local t_data = {bid = {}, offer = {}}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if key ~= "bids" and key ~= "offers" then
          if type(quote_level_2[key]) == 'number' then 
            t_data[key] = tonumber(value)
          else
            t_data[key] = value
          end
        end
      end
      
      for _, bid_entry in ipairs(result.bids) do 
        local bid = {}
        for field, value in bid_entry:ListFields() do 
          bid[field.name] = value
        end
        table.insert(t_data.bid, bid)
      end
      
       for _, offer_entry in ipairs(result.offers) do 
        local offer = {}
        for field, value in offer_entry:ListFields() do 
          offer[field.name] = value
        end
        table.insert(t_data.offer, offer)
      end

      assert.are.same(quote_level_2, t_data)
    end)
      
    local nonnullable_fields_names = {"bid_count", "offer_count"}
      
    for _, field_name in ipairs(nonnullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()

        local stored_value
    
        setup(function()
          stored_value = quote_level_2[field_name]
          quote_level_2[field_name] = nil
        end)
    
        teardown(function()
          quote_level_2[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD raise an error", function()
          assert.has_error(function() sut.getQuoteLevel2.Result(quote_level_2) end)
        end)
      end)
    
      -----
    end
  end)
  
  -----
end)
