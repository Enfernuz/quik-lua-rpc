package.path = "../?.lua;" .. package.path

require 'busted.runner'()

describe("The function utils.struct_factory.create_StopOrder", function()
    
  local qlua_structs = require("qlua.rpc.qlua_structures_pb")
    
  local sut = require("utils.struct_factory")
  
  describe("WHEN given no stop order table", function()
      
    it("SHOULD raise an error", function()
      assert.has_error(sut.create_StopOrder, "No stop_order table provided.")
    end)
  end)
  
  -----

  describe("WHEN given a stop order table", function()
      
    local stop_order
    
    setup(function()
        
      stop_order = {
        order_num = 1234567890, 
        ordertime = 1020304050, 
        flags = 0x2, 
        brokerref = "test-brokerref", 
        firmid = "test-firmid", 
        account = "test-account", 
        condition = 1, 
        condition_price = 17.88, 
        price = 18.05, 
        qty = 55, 
        linkedorder = 9876543210, 
        expiry = 1122334455, 
        trans_id = 741852963, 
        client_code = "test-client_code", 
        co_order_num = 13680, 
        co_order_price = 18.5, 
        stop_order_type = 1, 
        orderdate = 1020300000, 
        alltrade_num = 321654987, 
        stopflags = 0x4, 
        offset = 1.22, 
        spread = 2.33, 
        balance = 25.65, 
        uid = 445566, 
        filled_qty = 20, 
        withdraw_time = 1020304999, 
        condition_price2 = 17.99, 
        active_from_time = 1020304050, 
        active_to_time = 1020309999, 
        sec_code = "test-sec_code", 
        class_code = "test-class_code", 
        condition_sec_code = "test-condition_sec_code", 
        condition_class_code = "test-condition_class_code", 
        canceled_uid = 556677, 
        order_date_time = {
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
        withdraw_datetime = {
          mcs = 0,
          ms = 0,
          sec = 0,
          min = 0,
          hour = 13,
          day = 10,
          week_day = 2,
          month = 7,
          year = 2017
        } 
      }
    end)
  
    teardown(function()
      stop_order = nil
    end)
  
    it("SHOULD return an equal protobuf StopOrder struct", function()
        
      local result = sut.create_StopOrder(stop_order)
        
      -- check the result is a protobuf StopOrder structure
      local expected_meta = getmetatable( qlua_structs.StopOrder() )
      local actual_meta = getmetatable(result)
      assert.are.equal(expected_meta, actual_meta)
      
      -- check that the result has the same data as the given stop order table
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if type(stop_order[key]) == 'number' then 
          t_data[key] = tonumber(value)
        else
          t_data[key] = value
        end
      end
      
      t_data.order_date_time = {} -- it's a protobuf DateTimeEntry in the result, so we should reconstruct it separately as it contains additional protobuf fields.
      for field, value in result.order_date_time:ListFields() do
        t_data.order_date_time[tostring(field.name)] = tonumber(value)
      end
      
      t_data.withdraw_datetime = {} -- same here
      for field, value in result.withdraw_datetime:ListFields() do
        t_data.withdraw_datetime[tostring(field.name)] = tonumber(value)
      end

      assert.are.same(stop_order, t_data)
    end)
  
    describe("AND an existing StopOrder protobuf struct", function()
      
      local existing_struct
      
      setup(function()
        existing_struct = qlua_structs.StopOrder()
      end)
  
      teardown(function()
        existing_struct = nil
      end)
    
      it("SHOULD return the existing StopOrder protobuf struct which equals (data-wide, not literally) to the given stop order table", function()
          
        local result = sut.create_StopOrder(stop_order, existing_struct)
        
        assert.are.equals(existing_struct, result)
        
        -- check that the result has the same data as the given security table
        local t_data = {}
        for field, value in result:ListFields() do
          local key = tostring(field.name)
          if type(stop_order[key]) == 'number' then 
            t_data[key] = tonumber(value)
          else
            t_data[key] = value
          end
        end
        
        t_data.order_date_time = {} -- it's a protobuf DateTimeEntry in the result, so we should reconstruct it separately as it contains additional protobuf fields.
      for field, value in result.order_date_time:ListFields() do
        t_data.order_date_time[tostring(field.name)] = tonumber(value)
      end
      
      t_data.withdraw_datetime = {} -- same here
      for field, value in result.withdraw_datetime:ListFields() do
        t_data.withdraw_datetime[tostring(field.name)] = tonumber(value)
      end

        assert.are.same(stop_order, t_data)
      end)
    end)
      
    local nonnullable_fields_names = {"order_num", "flags", "account", "condition", "condition_price", "price", "qty", "client_code", "stop_order_type", "stopflags", "filled_qty", "sec_code", "class_code", "order_date_time"}
    local nullable_fields_names = {"ordertime", "brokerref", "firmid", "linkedorder", "expiry", "trans_id", "co_order_num", "co_order_price", "orderdate", "alltrade_num", "offset", "spread", "balance", "uid", "withdraw_time", "condition_price2", "active_from_time", "active_to_time", "condition_sec_code", "condition_class_code", "canceled_uid"}
      
    for _, field_name in ipairs(nonnullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()

        local stored_value
    
        setup(function()
          stored_value = stop_order[field_name]
          stop_order[field_name] = nil
        end)
    
        teardown(function()
          stop_order[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD raise an error", function()
          assert.has_error(function() sut.create_MoneyLimit(stop_order) end)
        end)
      end)
    
      -----
    end
      
    for _, field_name in ipairs(nullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()
          
        local stored_value
    
        setup(function()
          stored_value = stop_order[field_name]
          stop_order[field_name] = nil
        end)
    
        teardown(function()
          stop_order[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD return a struct with an empty string in that field", function()
          
          local result = sut.create_StopOrder(stop_order)
          assert.are.equal("", result[field_name])
        end)
      end)
    
      -----
    end
  end)
  
  -----
  
  describe("WHEN given a stop order table with CP1251-encoded values", function()
      
    local utils = require("utils.utils")
    
    local stop_order_utf8, stop_order_cp1251
    
    setup(function()
      
      stop_order_utf8 = {
        order_num = 1234567890, 
        ordertime = 1020304050, 
        flags = 0x2, 
        brokerref = "тестовый брокерреф", 
        firmid = "тестовый айди фирмы", 
        account = "тестовый аккаунт", 
        condition = 1, 
        condition_price = 17.88, 
        price = 18.05, 
        qty = 55, 
        linkedorder = 9876543210, 
        expiry = 1122334455, 
        trans_id = 741852963, 
        client_code = "тестовый код клиента", 
        co_order_num = 13680, 
        co_order_price = 18.5, 
        stop_order_type = 1, 
        orderdate = 1020300000, 
        alltrade_num = 321654987, 
        stopflags = 0x4, 
        offset = 1.22, 
        spread = 2.33, 
        balance = 25.65, 
        uid = 445566, 
        filled_qty = 20, 
        withdraw_time = 1020304999, 
        condition_price2 = 17.99, 
        active_from_time = 1020304050, 
        active_to_time = 1020309999, 
        sec_code = "test-sec_code", 
        class_code = "тестовый код класса", 
        condition_sec_code = "test-condition_sec_code", 
        condition_class_code = "тестовый код класса условия", 
        canceled_uid = 556677, 
        order_date_time = {
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
        withdraw_datetime = {
          mcs = 0,
          ms = 0,
          sec = 0,
          min = 0,
          hour = 13,
          day = 10,
          week_day = 2,
          month = 7,
          year = 2017
        } 
      }
      
      -- the list of fields that potentially may be encoded in CP1251 encoding
      local fields_that_may_be_encoded_in_cp1251 = {
        brokerref = true, 
        firmid = true, 
        account = true, 
        client_code = true, 
        class_code = true, 
        condition_class_code = true
      }
      
      stop_order_cp1251 = {}
      for k, v in pairs(stop_order_utf8) do
        if fields_that_may_be_encoded_in_cp1251[k] then
          stop_order_cp1251[k] = utils.Utf8ToCp1251( stop_order_utf8[k] )
        else
          stop_order_cp1251[k] = v
        end
      end
    end)
  
    teardown(function()
      stop_order_utf8 = nil
      stop_order_cp1251 = nil
    end)
  
    it("SHOULD return a struct with UTF8 encoded values", function()
      
      local result = sut.create_StopOrder(stop_order_cp1251)
      
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if type(stop_order_utf8[key]) == 'number' then 
          t_data[key] = tonumber(value)
        else
          t_data[key] = value
        end
      end
      
      t_data.order_date_time = {} -- it's a protobuf DateTimeEntry in the result, so we should reconstruct it separately as it contains additional protobuf fields.
      for field, value in result.order_date_time:ListFields() do
        t_data.order_date_time[tostring(field.name)] = tonumber(value)
      end
      
      t_data.withdraw_datetime = {} -- same here
      for field, value in result.withdraw_datetime:ListFields() do
        t_data.withdraw_datetime[tostring(field.name)] = tonumber(value)
      end

      assert.are.same(stop_order_utf8, t_data)
    end)
  
  end)
end)
