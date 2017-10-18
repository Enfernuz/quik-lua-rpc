package.path = "../?.lua;" .. package.path

require 'busted.runner'()

describe("The function utils.struct_factory.create_Trade", function()
    
  local qlua_structs = require("messages.qlua_structures_pb")
    
  local sut = require("utils.struct_factory")
  
  describe("WHEN given no trade", function()
      
    it("SHOULD raise an error", function()
      assert.has_error(sut.create_Trade, "No trade provided.")
    end)
  end)
  
  -----

  describe("WHEN given a trade", function()
      
    local trade
    
    setup(function()
        
      trade = {
        trade_num = 1234567890,
        order_num = 987123,
        brokerref = "test-brokerref",
        userid = "test-userid",
        firmid = "test-firmid",
        canceled_uid = 456,
        account = "test-account",
        price = 123.88,
        qty = 525,
        value = 145.67,
        accruedint = 120,
        yield = 123.8,
        settlecode = "test-settlecode",
        cpfirmid = "test-cpfirmid",
        flags = 0x04,
        price2 = 88.12,
        reporate = 6.78,
        client_code = "test-client_code",
        accrued2 = 567.8,
        repoterm = 25,
        repovalue = 123.82,
        repo2value = 5751.56,
        start_discount = 0.75,
        lower_discount = 0.59,
        upper_discount = 0.88,
        block_securities = 92,
        clearing_comission = 12.34,
        exchange_comission = 23.45,
        tech_center_comission = 5.43,
        settle_date = 12345,
        settle_currency = "test-settle_currency",
        trade_currency = "test-trade_currency",
        exchange_code = "test-exchange_code",
        station_id = "test-station_id",
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
        bank_acc_id = "test-bank_acc_id",
        broker_comission = 123.56,
        linked_trade = 987654321,
        period = 2,
        trans_id = 1122334455,
        kind = 1,
        clearing_bank_accid = "test-clearing_bank_accid",
        canceled_datetime = {
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
        clearing_firmid = "test-clearing_firmid",
        system_ref = "test-system_ref",
        uid = 192837465
      }
    end)
  
    teardown(function()
      trade = nil
    end)
  
    it("SHOULD return an equal protobuf Trade struct", function()
        
      local result = sut.create_Trade(trade)
        
      -- check the result is a protobuf AllTrade structure
      local expected_meta = getmetatable( qlua_structs.Trade() )
      local actual_meta = getmetatable(result)
      assert.are.equal(expected_meta, actual_meta)
      
      -- check that the result has the same data as the given alltrade
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if type(trade[key]) == 'number' then 
          t_data[key] = tonumber(value)
        else
          t_data[key] = value
        end
      end
      
      t_data.datetime = {} -- it's a protobuf DateTimeEntry in the result, so we should reconstruct it separately as it contains additional protobuf fields.
      for field, value in result.datetime:ListFields() do
        t_data.datetime[tostring(field.name)] = tonumber(value)
      end
      
      t_data.canceled_datetime = {} -- same here
      for field, value in result.canceled_datetime:ListFields() do
        t_data.canceled_datetime[tostring(field.name)] = tonumber(value)
      end
      
      assert.are.same(trade, t_data)
    end)
      
    local nonnullable_fields_names = {"trade_num", "order_num", "price", "qty", "value", "flags", "sec_code", "class_code", "datetime", "period", "kind"}
    local nullable_fields_names = {"brokerref", "userid", "firmid", "canceled_uid", "account", "accruedint", "yield", "settlecode", "cpfirmid", "price2", "reporate", "client_code", "accrued2", "repoterm", "repovalue", "repo2value", "start_discount", "lower_discount", "upper_discount", "block_securities", "clearing_comission", "exchange_comission", "tech_center_comission", "settle_date", "settle_currency", "trade_currency", "exchange_code", "station_id", "bank_acc_id", "broker_comission", "linked_trade", "trans_id", "clearing_bank_accid", "clearing_firmid", "system_ref", "uid"}
      
    for _, field_name in ipairs(nonnullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()

        local stored_value
    
        setup(function()
          stored_value = trade[field_name]
          trade[field_name] = nil
        end)
    
        teardown(function()
          trade[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD raise an error", function()
          assert.has_error(function() sut.create_Trade(trade) end)
        end)
      end)
    
      -----
    end
      
    for _, field_name in ipairs(nullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()
          
        local stored_value
    
        setup(function()
          stored_value = trade[field_name]
          trade[field_name] = nil
        end)
    
        teardown(function()
          trade[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD return a struct with an empty string in that field", function()
          
          local result = sut.create_Trade(trade)
          assert.are.equal("", result[field_name])
        end)
      end)
    
      -----
    end
  end)
  
  -----
  
  describe("WHEN given a trade with CP1251-encoded values", function()
      
    local utils = require("utils.utils")
    
    local trade_utf8, trade_cp1251
    
    setup(function()
      
      trade_utf8 = {
        trade_num = 1234567890,
        order_num = 987123,
        brokerref = "тестовый брокер реф",
        userid = "тестовый юзер айди",
        firmid = "тестовый фирм айди",
        canceled_uid = 456,
        account = "тестовый аккаунт",
        price = 123.88,
        qty = 525,
        value = 145.67,
        accruedint = 120,
        yield = 123.8,
        settlecode = "тестовый сеттлкод",
        cpfirmid = "тестовый сипи фирм айди",
        flags = 0x04,
        price2 = 88.12,
        reporate = 6.78,
        client_code = "тестовый код клиента",
        accrued2 = 567.8,
        repoterm = 25,
        repovalue = 123.82,
        repo2value = 5751.56,
        start_discount = 0.75,
        lower_discount = 0.59,
        upper_discount = 0.88,
        block_securities = 92,
        clearing_comission = 12.34,
        exchange_comission = 23.45,
        tech_center_comission = 5.43,
        settle_date = 12345,
        settle_currency = "доллар США",
        trade_currency = "рубль",
        exchange_code = "тестовый эксчейндж код",
        station_id = "тестовый стейшн айди",
        sec_code = "GAZP",
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
        bank_acc_id = "тестовый банк акк айди",
        broker_comission = 123.56,
        linked_trade = 987654321,
        period = 2,
        trans_id = 1122334455,
        kind = 1,
        clearing_bank_accid = "тестовый клиринг банк акк айди",
        canceled_datetime = {
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
        clearing_firmid = "тестовый клиринг фирм айди",
        system_ref = "тестовый систем реф",
        uid = 192837465
      }
      
      -- the list of fields that potentially may be encoded in CP1251 encoding
      local fields_that_may_be_encoded_in_cp1251 = {
        brokerref = true, 
        userid = true, 
        firmid = true, 
        account = true, 
        settlecode = true, 
        cpfirmid = true, 
        client_code = true, 
        settle_currency = true, 
        trade_currency = true, 
        exchange_code = true, 
        station_id = true, 
        bank_acc_id = true, 
        clearing_bank_accid = true, 
        clearing_firmid = true, 
        system_ref = true
      }
      
      trade_cp1251 = {}
      for k, v in pairs(trade_utf8) do
        if fields_that_may_be_encoded_in_cp1251[k] then
          trade_cp1251[k] = utils.Utf8ToCp1251( trade_utf8[k] )
        else
          trade_cp1251[k] = v
        end
      end
    end)
  
    teardown(function()
      trade_utf8 = nil
      trade_cp1251 = nil
    end)
  
    it("SHOULD return a struct with UTF8 encoded values", function()
      
      local result = sut.create_Trade(trade_cp1251)
      
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if type(trade_utf8[key]) == 'number' then 
          t_data[key] = tonumber(value)
        else
          t_data[key] = value
        end
      end
      
      t_data.datetime = {} -- it's a protobuf DateTimeEntry in the result, so we should reconstruct it separately as it contains additional protobuf fields.
      for field, value in result.datetime:ListFields() do
        t_data.datetime[tostring(field.name)] = tonumber(value)
      end
      
      t_data.canceled_datetime = {} -- same here
      for field, value in result.canceled_datetime:ListFields() do
        t_data.canceled_datetime[tostring(field.name)] = tonumber(value)
      end
      
      assert.are.same(trade_utf8, t_data)
    end)
  
  end)
end)
