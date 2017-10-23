package.path = "../?.lua;" .. package.path

require 'busted.runner'()

describe("The function utils.struct_factory.create_Transaction", function()
    
  local qlua_structs = require("messages.qlua_structures_pb")
    
  local sut = require("utils.struct_factory")
  
  describe("WHEN given no trans_reply table", function()
      
    it("SHOULD raise an error", function()
      assert.has_error(sut.create_Transaction, "No trans_reply table provided.")
    end)
  end)
  
  -----

  describe("WHEN given a transaction table", function()
      
    local trans_reply
    
    setup(function()
        
      trans_reply = {
        trans_id = 1234567890, 
        status = 2, 
        result_msg = "test-result_msg", 
        date_time = {
          mcs = 59,
          ms = 49,
          sec = 39,
          min = 29,
          hour = 10,
          day = 9,
          week_day = 1,
          month = 7,
          year = 2017
        }, 
        uid = 445566, 
        flags = 0x4, 
        server_trans_id = 9876543210, 
        order_num = 963852741, 
        price = 75.35, 
        quantity = 15, 
        balance = 236.98, 
        firm_id = "test-firm_id", 
        account = "test-account", 
        client_code = "test-client_code", 
        brokerref = "test-brokerref", 
        class_code = "test-class_code", 
        sec_code = "test-sec_code", 
        exchange_code = "test-exchange_code"
      }
    end)
  
    teardown(function()
      trans_reply = nil
    end)
  
    it("SHOULD return an equal protobuf Transaction struct", function()
        
      local result = sut.create_Transaction(trans_reply)
        
      -- check the result is a protobuf Transaction structure
      local expected_meta = getmetatable( qlua_structs.Transaction() )
      local actual_meta = getmetatable(result)
      assert.are.equal(expected_meta, actual_meta)
      
      -- check that the result has the same data as the given transaction table
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if type(trans_reply[key]) == 'number' then 
          t_data[key] = tonumber(value)
        else
          t_data[key] = value
        end
      end
      
      t_data.date_time = {} -- it's a protobuf DateTimeEntry in the result, so we should reconstruct it separately as it contains additional protobuf fields.
      for field, value in result.date_time:ListFields() do
        t_data.date_time[tostring(field.name)] = tonumber(value)
      end

      assert.are.same(trans_reply, t_data)
    end)
      
    local nonnullable_fields_names = {"trans_id", "status", "date_time", "flags", }
    local nullable_fields_names = {"result_msg", "uid", "server_trans_id", "order_num", "price", "quantity", "balance", "firm_id", "account", "client_code", "brokerref", "class_code", "sec_code", "exchange_code"}
      
    for _, field_name in ipairs(nonnullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()

        local stored_value
    
        setup(function()
          stored_value = trans_reply[field_name]
          trans_reply[field_name] = nil
        end)
    
        teardown(function()
          trans_reply[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD raise an error", function()
          assert.has_error(function() sut.create_Transaction(trans_reply) end)
        end)
      end)
    
      -----
    end
      
    for _, field_name in ipairs(nullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()
          
        local stored_value
    
        setup(function()
          stored_value = trans_reply[field_name]
          trans_reply[field_name] = nil
        end)
    
        teardown(function()
          trans_reply[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD return a struct with an empty string in that field", function()
          
          local result = sut.create_Transaction(trans_reply)
          assert.are.equal("", result[field_name])
        end)
      end)
    
      -----
    end
  end)
  
  -----
  
  describe("WHEN given a money limit table with CP1251-encoded values", function()
      
    local utils = require("utils.utils")
    
    local trans_reply_utf8, trans_reply_cp1251
    
    setup(function()
      
      trans_reply_utf8 = {
        trans_id = 1234567890, 
        status = 2, 
        result_msg = "тестовое сообщение", 
        date_time = {
          mcs = 59,
          ms = 49,
          sec = 39,
          min = 29,
          hour = 10,
          day = 9,
          week_day = 1,
          month = 7,
          year = 2017
        }, 
        uid = 445566, 
        flags = 0x4, 
        server_trans_id = 9876543210, 
        order_num = 963852741, 
        price = 75.35, 
        quantity = 15, 
        balance = 236.98, 
        firm_id = "тестовый айди фирмы", 
        account = "тестовый аккаунт", 
        client_code = "тестовый код клиента", 
        brokerref = "тестовый брокерреф", 
        class_code = "тестовый код класса", 
        sec_code = "test-sec_code", 
        exchange_code = "тестовый код биржи"
      }
      
      -- the list of fields that potentially may be encoded in CP1251 encoding
      local fields_that_may_be_encoded_in_cp1251 = {
        result_msg = true, 
        firm_id = true, 
        account = true, 
        client_code = true, 
        brokerref = true, 
        class_code = true, 
        exchange_code = true
      }
      
      trans_reply_cp1251 = {}
      for k, v in pairs(trans_reply_utf8) do
        if fields_that_may_be_encoded_in_cp1251[k] then
          trans_reply_cp1251[k] = utils.Utf8ToCp1251( trans_reply_utf8[k] )
        else
          trans_reply_cp1251[k] = v
        end
      end
    end)
  
    teardown(function()
      trans_reply_utf8 = nil
      trans_reply_cp1251 = nil
    end)
  
    it("SHOULD return a struct with UTF8 encoded values", function()
      
      local result = sut.create_Transaction(trans_reply_cp1251)
      
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if type(trans_reply_utf8[key]) == 'number' then 
          t_data[key] = tonumber(value)
        else
          t_data[key] = value
        end
      end
      
      t_data.date_time = {} -- it's a protobuf DateTimeEntry in the result, so we should reconstruct it separately as it contains additional protobuf fields.
      for field, value in result.date_time:ListFields() do
        t_data.date_time[tostring(field.name)] = tonumber(value)
      end

      assert.are.same(trans_reply_utf8, t_data)
    end)
  
  end)
end)
