package.path = "../?.lua;" .. package.path

require 'busted.runner'()

describe("The function utils.struct_factory.create_NegDeal", function()
    
  local qlua_structs = require("messages.qlua_structures_pb")
    
  local sut = require("utils.struct_factory")
  
  describe("WHEN given no neg deal table", function()
      
    it("SHOULD raise an error", function()
      assert.has_error(sut.create_NegDeal, "No neg_deal table provided.")
    end)
  end)
  
  -----

  describe("WHEN given a neg deal table", function()
      
    local neg_deal
    
    setup(function()
        
      neg_deal = {
        neg_deal_num = 1234567, 
        neg_deal_time = 45678900987, 
        flags = 0x08, 
        brokerref = "test-brokerref", 
        userid = "test-userid", 
        firmid = "test-firmid", 
        cpuserid = "test-cpuserid", 
        cpfirmid = "test-cpfirmid", 
        account = "test-account", 
        price = 12.98, 
        qty = 320, 
        matchref = "test-matchref", 
        settlecode = "test-settlecode", 
        yield = 123.45, 
        accruedint = 33, 
        value = 43.34, 
        price2 = 12.56, 
        reporate = 7.89, 
        refundrate = 6.54, 
        trans_id = 9876543210, 
        client_code = "test-client_code", 
        repoentry = 0, 
        repovalue = 564.3, 
        repo2value = 563.4, 
        repoterm = 7, 
        start_discount = 0.5, 
        lower_discount = 0.33, 
        upper_discount = 0.67, 
        block_securities = 0, 
        uid = 456654, 
        withdraw_time = 45678900988, 
        neg_deal_date = 45678900000, 
        balance = 444.56, 
        origin_repovalue = 123.56, 
        origin_qty = 22, 
        origin_discount = 0.25, 
        neg_deal_activation_date = 45678900099, 
        neg_deal_activation_time = 45678800000, 
        quoteno = 145.78, 
        settle_currency = "test-settle_currency", 
        sec_code = "test-sec_code", 
        class_code = "test-class_code", 
        bank_acc_id = "test-bank_acc_id", 
        withdraw_date = 45678910, 
        linkedorder = 123654987, 
        activation_date_time = {
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
        withdraw_date_time = {
          mcs = 59,
          ms = 49,
          sec = 01,
          min = 15,
          hour = 11,
          day = 9,
          week_day = 1,
          month = 7,
          year = 2017
        }, 
        date_time = {
          mcs = 40,
          ms = 31,
          sec = 00,
          min = 05,
          hour = 11,
          day = 9,
          week_day = 1,
          month = 7,
          year = 2017
        }
      }
    end)
  
    teardown(function()
      neg_deal = nil
    end)
  
    it("SHOULD return an equal protobuf NegDeal struct", function()
        
      local result = sut.create_NegDeal(neg_deal)
        
      -- check the result is a protobuf NegDeal structure
      local expected_meta = getmetatable( qlua_structs.NegDeal() )
      local actual_meta = getmetatable(result)
      assert.are.equal(expected_meta, actual_meta)
      
      -- check that the result has the same data as the given neg_deal table
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if type(neg_deal[key]) == 'number' then 
          t_data[key] = tonumber(value)
        else
          t_data[key] = value
        end
      end
      
      t_data.date_time = {} -- it's a protobuf DateTimeEntry in the result, so we should reconstruct it separately as it contains additional protobuf fields.
      for field, value in result.date_time:ListFields() do
        t_data.date_time[tostring(field.name)] = tonumber(value)
      end
      
      t_data.activation_date_time = {} -- same here
      for field, value in result.activation_date_time:ListFields() do
        t_data.activation_date_time[tostring(field.name)] = tonumber(value)
      end
      
      t_data.withdraw_date_time = {} -- same here
      for field, value in result.withdraw_date_time:ListFields() do
        t_data.withdraw_date_time[tostring(field.name)] = tonumber(value)
      end
      
      assert.are.same(neg_deal, t_data)
    end)
      
    local nonnullable_fields_names = {"neg_deal_num", "flags", "price", "qty", "repoentry", "sec_code", "class_code", }
    local nullable_fields_names = {"neg_deal_time", "brokerref", "userid", "firmid", "cpuserid", "cpfirmid", "account", "matchref", "settlecode", "yield", "accruedint", "value", "price2", "reporate", "refundrate", "trans_id", "client_code", "repovalue", "repo2value", "repoterm", "start_discount", "lower_discount", "upper_discount", "block_securities", "uid", "withdraw_time", "neg_deal_date", "balance", "origin_repovalue", "origin_qty", "origin_discount", "neg_deal_activation_date", "neg_deal_activation_time", "quoteno", "settle_currency", "bank_acc_id", "withdraw_date", "linkedorder"}
      
    for _, field_name in ipairs(nonnullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()

        local stored_value
    
        setup(function()
          stored_value = neg_deal[field_name]
          neg_deal[field_name] = nil
        end)
    
        teardown(function()
          neg_deal[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD raise an error", function()
          assert.has_error(function() sut.create_NegDeal(neg_deal) end)
        end)
      end)
    
      -----
    end
      
    for _, field_name in ipairs(nullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()
          
        local stored_value
    
        setup(function()
          stored_value = neg_deal[field_name]
          neg_deal[field_name] = nil
        end)
    
        teardown(function()
          neg_deal[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD return a struct with an empty string in that field", function()
          
          local result = sut.create_NegDeal(neg_deal)
          assert.are.equal("", result[field_name])
        end)
      end)
    
      -----
    end
  end)
  
  -----
  
  describe("WHEN given a neg deal with CP1251-encoded values", function()
      
    local utils = require("utils.utils")
    
    local neg_deal_utf8, neg_deal_cp1251
    
    setup(function()
      
      neg_deal_utf8 = {
        neg_deal_num = 1234567, 
        neg_deal_time = 45678900987, 
        flags = 0x08, 
        brokerref = "тестовый брокер реф", 
        userid = "тестовый айди пользователя", 
        firmid = "тестовый айди фирмы", 
        cpuserid = "тестовый айди чего-то там пользователя", 
        cpfirmid = "тестовый айди чего-то там фирмы", 
        account = "тестовый аккаунт", 
        price = 12.98, 
        qty = 320, 
        matchref = "тестовый матчреф", 
        settlecode = "тестовый сеттлкод", 
        yield = 123.45, 
        accruedint = 33, 
        value = 43.34, 
        price2 = 12.56, 
        reporate = 7.89, 
        refundrate = 6.54, 
        trans_id = 9876543210, 
        client_code = "тестовый код клиента", 
        repoentry = 0, 
        repovalue = 564.3, 
        repo2value = 563.4, 
        repoterm = 7, 
        start_discount = 0.5, 
        lower_discount = 0.33, 
        upper_discount = 0.67, 
        block_securities = 0, 
        uid = 456654, 
        withdraw_time = 45678900988, 
        neg_deal_date = 45678900000, 
        balance = 444.56, 
        origin_repovalue = 123.56, 
        origin_qty = 22, 
        origin_discount = 0.25, 
        neg_deal_activation_date = 45678900099, 
        neg_deal_activation_time = 45678800000, 
        quoteno = 145.78, 
        settle_currency = "тестовая сеттл валюта", 
        sec_code = "GMKN", 
        class_code = "тестовый класс", 
        bank_acc_id = "тестовый айди банковского аккаунта", 
        withdraw_date = 45678910, 
        linkedorder = 123654987, 
        activation_date_time = {
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
        withdraw_date_time = {
          mcs = 59,
          ms = 49,
          sec = 01,
          min = 15,
          hour = 11,
          day = 9,
          week_day = 1,
          month = 7,
          year = 2017
        }, 
        date_time = {
          mcs = 40,
          ms = 31,
          sec = 00,
          min = 05,
          hour = 11,
          day = 9,
          week_day = 1,
          month = 7,
          year = 2017
        }
      }
      
      -- the list of fields that potentially may be encoded in CP1251 encoding
      local fields_that_may_be_encoded_in_cp1251 = {
        brokerref = true, 
        userid = true, 
        firmid = true, 
        cpuserid = true, 
        cpfirmid = true, 
        account = true, 
        matchref = true, 
        settlecode = true, 
        client_code = true, 
        settle_currency = true, 
        class_code = true, 
        bank_acc_id = true
      }
      
      neg_deal_cp1251 = {}
      for k, v in pairs(neg_deal_utf8) do
        if fields_that_may_be_encoded_in_cp1251[k] then
          neg_deal_cp1251[k] = utils.Utf8ToCp1251( neg_deal_utf8[k] )
        else
          neg_deal_cp1251[k] = v
        end
      end
    end)
  
    teardown(function()
      neg_deal_utf8 = nil
      neg_deal_cp1251 = nil
    end)
  
    it("SHOULD return a struct with UTF8 encoded values", function()
      
      local result = sut.create_NegDeal(neg_deal_cp1251)
      
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if type(neg_deal_utf8[key]) == 'number' then 
          t_data[key] = tonumber(value)
        else
          t_data[key] = value
        end
      end
      
      t_data.date_time = {} -- it's a protobuf DateTimeEntry in the result, so we should reconstruct it separately as it contains additional protobuf fields.
      for field, value in result.date_time:ListFields() do
        t_data.date_time[tostring(field.name)] = tonumber(value)
      end
      
      t_data.activation_date_time = {} -- same here
      for field, value in result.activation_date_time:ListFields() do
        t_data.activation_date_time[tostring(field.name)] = tonumber(value)
      end
      
      t_data.withdraw_date_time = {} -- same here
      for field, value in result.withdraw_date_time:ListFields() do
        t_data.withdraw_date_time[tostring(field.name)] = tonumber(value)
      end

      assert.are.same(neg_deal_utf8, t_data)
    end)
  
  end)
end)
