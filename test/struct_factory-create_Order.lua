package.path = "../?.lua;" .. package.path

require 'busted.runner'()

describe("The function utils.struct_factory.create_Order", function()
    
  local qlua_structs = require("qlua.rpc.qlua_structures_pb")
    
  local sut = require("utils.struct_factory")
  
  describe("WHEN given no order", function()
      
    it("SHOULD raise an error", function()
      assert.has_error(sut.create_Order, "No order provided.")
    end)
  end)
  
  -----

  describe("WHEN given an order", function()
      
    local order
    
    setup(function()
        
      order = {
        order_num = 987123,
        flags = 0x05,
        brokerref = "test-brokerref",
        userid = "test-userid",
        firmid = "test-firmid",
        account = "test-account",
        price = 123.88,
        qty = 525,
        balance = 567.8,
        value = 145.67,
        accruedint = 120,
        yield = 123.8,
        trans_id = 1234567890, 
        client_code = "test-client_code",
        price2 = 88.12,
        settlecode = "test-settlecode",
        uid = 192837465, 
        canceled_uid = 456,
        exchange_code = "test-exchange_code",
        activation_time = 123123123,
        linkedorder = 321789, 
        expiry = 231231231,
        sec_code = "test-sec_code",
        class_code = "test-class_code",
        datetime = {
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
          mcs = 24,
          ms = 35,
          sec = 12,
          min = 15,
          hour = 15,
          day = 13,
          week_day = 4,
          month = 7,
          year = 2017
        },
        bank_acc_id = "test-bank_acc_id",
        value_entry_type = 7, 
        repoterm = 25,
        repovalue = 123.82,
        repo2value = 5751.56,
        repo_value_balance = 5300.24,
        start_discount = 0.75,
        reject_reason = "test-reject_reason", 
        ext_order_flags = 0x02, 
        min_qty = 250, 
        exec_type = 3,
        side_qualifier = 1,
        acnt_type = 9, 
        capacity = 600, 
        passive_only_order = 1, 
        visible = 1
      }
    end)
  
    teardown(function()
      order = nil
    end)
  
    it("SHOULD return an equal protobuf Order struct", function()
        
      local result = sut.create_Order(order)
        
      -- check the result is a protobuf Order structure
      local expected_meta = getmetatable( qlua_structs.Order() )
      local actual_meta = getmetatable(result)
      assert.are.equal(expected_meta, actual_meta)
      
      -- check that the result has the same data as the given order
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if type(order[key]) == 'number' then 
          t_data[key] = tonumber(value)
        else
          t_data[key] = value
        end
      end
      
      t_data.datetime = {} -- it's a protobuf DateTimeEntry in the result, so we should reconstruct it separately as it contains additional protobuf fields.
      for field, value in result.datetime:ListFields() do
        t_data.datetime[tostring(field.name)] = tonumber(value)
      end
      
      t_data.withdraw_datetime = {} -- same here
      for field, value in result.withdraw_datetime:ListFields() do
        t_data.withdraw_datetime[tostring(field.name)] = tonumber(value)
      end
      
      assert.are.same(order, t_data)
    end)
  
    describe("AND an existing Order protobuf struct", function()
      
      local existing_struct
      
      setup(function()
        existing_struct = qlua_structs.Order()
      end)
  
      teardown(function()
        existing_struct = nil
      end)
    
      it("SHOULD return the existing Order protobuf struct which equals (data-wide, not literally) to the given order table", function()
          
        local result = sut.create_Order(order, existing_struct)
        
        assert.are.equals(existing_struct, result)
        
        -- check that the result has the same data as the given order table
        local t_data = {}
        for field, value in result:ListFields() do
          local key = tostring(field.name)
          if type(order[key]) == 'number' then 
            t_data[key] = tonumber(value)
          else
            t_data[key] = value
          end
        end
        
        t_data.datetime = {} -- it's a protobuf DateTimeEntry in the result, so we should reconstruct it separately as it contains additional protobuf fields.
      for field, value in result.datetime:ListFields() do
        t_data.datetime[tostring(field.name)] = tonumber(value)
      end
      
      t_data.withdraw_datetime = {} -- same here
      for field, value in result.withdraw_datetime:ListFields() do
        t_data.withdraw_datetime[tostring(field.name)] = tonumber(value)
      end

        assert.are.same(order, t_data)
      end)
    end)
      
    local nonnullable_fields_names = {"order_num", "flags", "price", "qty", "value", "sec_code", "class_code", "datetime", "value_entry_type", "min_qty", "exec_type", "side_qualifier", "acnt_type", "capacity", "passive_only_order", "visible"}
    local nullable_fields_names = {"brokerref", "userid", "firmid", "account", "balance", "accruedint", "yield", "trans_id", "client_code", "price2", "settlecode", "uid", "canceled_uid", "exchange_code", "activation_time", "linkedorder", "expiry", "bank_acc_id", "repoterm", "repovalue", "repo2value", "repo_value_balance", "start_discount", "reject_reason", "ext_order_flags"}
      
    for _, field_name in ipairs(nonnullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()

        local stored_value
    
        setup(function()
          stored_value = order[field_name]
          order[field_name] = nil
        end)
    
        teardown(function()
          order[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD raise an error", function()
          assert.has_error(function() sut.create_Order(order) end)
        end)
      end)
    
      -----
    end
      
    for _, field_name in ipairs(nullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()
          
        local stored_value
    
        setup(function()
          stored_value = order[field_name]
          order[field_name] = nil
        end)
    
        teardown(function()
          order[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD return a struct with an empty string in that field", function()
          
          local result = sut.create_Order(order)
          assert.are.equal("", result[field_name])
        end)
      end)
    
      -----
    end
  end)
  
  -----
  
  describe("WHEN given an order with CP1251-encoded values", function()
      
    local utils = require("utils.utils")
    
    local order_utf8, order_cp1251
    
    setup(function()
      
      order_utf8 = {
        order_num = 987123,
        flags = 0x05,
        brokerref = "тестовый брокер реф",
        userid = "тестовый юзер айди",
        firmid = "тестовый фирм айди",
        account = "тестовый аккаунт",
        price = 123.88,
        qty = 525,
        balance = 567.8,
        value = 145.67,
        accruedint = 120,
        yield = 123.8,
        trans_id = 1234567890, 
        client_code = "тестовый код клиента",
        price2 = 88.12,
        settlecode = "тестовый сеттл код",
        uid = 192837465, 
        canceled_uid = 456,
        exchange_code = "тестовый код биржи",
        activation_time = 123123123,
        linkedorder = 321789, 
        expiry = 231231231,
        sec_code = "URKA",
        class_code = "TQBR",
        datetime = {
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
          mcs = 24,
          ms = 35,
          sec = 12,
          min = 15,
          hour = 15,
          day = 13,
          week_day = 4,
          month = 7,
          year = 2017
        },
        bank_acc_id = "тестовый банк айди",
        value_entry_type = 7, 
        repoterm = 25,
        repovalue = 123.82,
        repo2value = 5751.56,
        repo_value_balance = 5300.24,
        start_discount = 0.75,
        reject_reason = "тестовая причина отказа", 
        ext_order_flags = 0x02, 
        min_qty = 250, 
        exec_type = 3,
        side_qualifier = 1,
        acnt_type = 9, 
        capacity = 600, 
        passive_only_order = 1, 
        visible = 1
      }
      
      -- the list of fields that potentially may be encoded in CP1251 encoding
      local fields_that_may_be_encoded_in_cp1251 = {
        brokerref = true, 
        userid = true, 
        firmid = true, 
        account = true, 
        client_code = true, 
        settlecode = true, 
        exchange_code = true, 
        bank_acc_id = true, 
        reject_reason = true
      }
      
      order_cp1251 = {}
      for k, v in pairs(order_utf8) do
        if fields_that_may_be_encoded_in_cp1251[k] then
          order_cp1251[k] = utils.Utf8ToCp1251( order_utf8[k] )
        else
          order_cp1251[k] = v
        end
      end
    end)
  
    teardown(function()
      order_utf8 = nil
      order_cp1251 = nil
    end)
  
    it("SHOULD return a struct with UTF8 encoded values", function()
      
      local result = sut.create_Order(order_cp1251)
      
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if type(order_utf8[key]) == 'number' then 
          t_data[key] = tonumber(value)
        else
          t_data[key] = value
        end
      end
      
      t_data.datetime = {} -- it's a protobuf DateTimeEntry in the result, so we should reconstruct it separately as it contains additional protobuf fields.
      for field, value in result.datetime:ListFields() do
        t_data.datetime[tostring(field.name)] = tonumber(value)
      end
      
      t_data.withdraw_datetime = {} -- same here
      for field, value in result.withdraw_datetime:ListFields() do
        t_data.withdraw_datetime[tostring(field.name)] = tonumber(value)
      end
      
      assert.are.same(order_utf8, t_data)
    end)
  
  end)
end)
