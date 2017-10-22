package.path = "../?.lua;" .. package.path

require 'busted.runner'()

describe("The function utils.struct_factory.create_NegTrade", function()
    
  local qlua_structs = require("messages.qlua_structures_pb")
    
  local sut = require("utils.struct_factory")
  
  describe("WHEN given no neg trade table", function()
      
    it("SHOULD raise an error", function()
      assert.has_error(sut.create_NegTrade, "No neg_trade table provided.")
    end)
  end)
  
  -----

  describe("WHEN given a neg trade table", function()
      
    local neg_trade
    
    setup(function()
        
      neg_trade = {
        trade_num = 1234567, 
        trade_date = 45678900987, 
        settle_date = 45678900000, 
        flags = 0x1, 
        brokerref = "test-brokerref", 
        firmid = "test-firmid", 
        account = "test-account", 
        cpfirmid = "test-cpfirmid", 
        cpaccount = "test-cpaccount", 
        price = 369.85, 
        qty = 100, 
        value = 36985, 
        settlecode = "test-settlecode", 
        report_num = 7887, 
        cpreport_num = 8778, 
        accruedint = 123.45, 
        repotradeno = 87654321, 
        price1 = 369, 
        reporate = 7.89, 
        price2 = 369.5, 
        client_code = "test-client_code", 
        ts_comission = 100.99, 
        balance = 78.98, 
        settle_time = 45678900986, 
        amount = 123, 
        repovalue = 25000, 
        repoterm = 3, 
        repo2value = 25500, 
        return_value = 999, 
        discount = 0, 
        lower_discount = 0, 
        upper_discount = 0.5, 
        block_securities = 0, 
        urgency_flag = 0, 
        type = 1, 
        operation_type = 2, 
        expected_discount = 0, 
        expected_quantity = 100, 
        expected_repovalue = 25000, 
        expected_repo2value = 25500, 
        expected_return_value = 999, 
        order_num = 678098, 
        report_trade_date = 456789321, 
        settled = 1, 
        clearing_type = 2, 
        report_comission = 10.99, 
        coupon_payment = 0.00, 
        principal_payment = 99.10, 
        principal_payment_date = 456789123, 
        nextdaysettle = 10, 
        settle_currency = "test-settle_currency", 
        sec_code = "test-sec_code", 
        class_code = "test-class_code", 
        compval = 1, 
        parenttradeno = 987321, 
        bankid = "test-bankid", 
        bankaccid = "test-bankaccid", 
        precisebalance = 100.10, 
        confirmtime = 456789010, 
        ex_flags = 0x2, 
        confirmreport = 7
      }
    end)
  
    teardown(function()
      neg_trade = nil
    end)
  
    it("SHOULD return an equal protobuf NegTrade struct", function()
        
      local result = sut.create_NegTrade(neg_trade)
        
      -- check the result is a protobuf NegTrade structure
      local expected_meta = getmetatable( qlua_structs.NegTrade() )
      local actual_meta = getmetatable(result)
      assert.are.equal(expected_meta, actual_meta)
      
      -- check that the result has the same data as the given neg_trade table
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if type(neg_trade[key]) == 'number' then 
          t_data[key] = tonumber(value)
        else
          t_data[key] = value
        end
      end
      
      assert.are.same(neg_trade, t_data)
    end)
      
    local nonnullable_fields_names = {"trade_num", "flags", "price", "qty", "type", "operation_type", "settled", "clearing_type", "sec_code", "class_code", "ex_flags"}
    local nullable_fields_names = {"trade_date", "settle_date", "brokerref", "firmid", "account", "cpfirmid", "cpaccount", "value", "settlecode", "report_num", "cpreport_num", "accruedint", "repotradeno", "price1", "reporate", "price2", "client_code", "ts_comission", "balance", "settle_time", "amount", "repovalue", "repoterm", "repo2value", "return_value", "discount", "lower_discount", "upper_discount", "block_securities", "urgency_flag", "expected_discount", "expected_quantity", "expected_repovalue", "expected_repo2value", "expected_return_value", "order_num", "report_trade_date", "report_comission", "coupon_payment", "principal_payment", "principal_payment_date", "nextdaysettle", "settle_currency", "compval", "parenttradeno", "bankid", "bankaccid", "precisebalance", "confirmtime", "confirmreport"}
      
    for _, field_name in ipairs(nonnullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()

        local stored_value
    
        setup(function()
          stored_value = neg_trade[field_name]
          neg_trade[field_name] = nil
        end)
    
        teardown(function()
          neg_trade[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD raise an error", function()
          assert.has_error(function() sut.create_NegTrade(neg_trade) end)
        end)
      end)
    
      -----
    end
      
    for _, field_name in ipairs(nullable_fields_names) do
      
      -----
      
      describe(string.format("with no field '%s'", field_name), function()
          
        local stored_value
    
        setup(function()
          stored_value = neg_trade[field_name]
          neg_trade[field_name] = nil
        end)
    
        teardown(function()
          neg_trade[field_name] = stored_value
          stored_value = nil
        end)
    
        it("SHOULD return a struct with an empty string in that field", function()
          
          local result = sut.create_NegTrade(neg_trade)
          assert.are.equal("", result[field_name])
        end)
      end)
    
      -----
    end
  end)
  
  -----
  
  describe("WHEN given a neg trade with CP1251-encoded values", function()
      
    local utils = require("utils.utils")
    
    local neg_trade_utf8, neg_trade_cp1251
    
    setup(function()
      
      neg_trade_utf8 = {
        trade_num = 1234567, 
        trade_date = 45678900987, 
        settle_date = 45678900000, 
        flags = 0x1, 
        brokerref = "тестовый брокер реф", 
        firmid = "тестовый айди фирмы", 
        account = "тестовый аккаунд", 
        cpfirmid = "тестовый айди сипи-фирмы", 
        cpaccount = "тестовый айди сипи-аккаунта", 
        price = 369.85, 
        qty = 100, 
        value = 36985, 
        settlecode = "тестовый сеттл код", 
        report_num = 7887, 
        cpreport_num = 8778, 
        accruedint = 123.45, 
        repotradeno = 87654321, 
        price1 = 369, 
        reporate = 7.89, 
        price2 = 369.5, 
        client_code = "тестовый код клиента", 
        ts_comission = 100.99, 
        balance = 78.98, 
        settle_time = 45678900986, 
        amount = 123, 
        repovalue = 25000, 
        repoterm = 3, 
        repo2value = 25500, 
        return_value = 999, 
        discount = 0, 
        lower_discount = 0, 
        upper_discount = 0.5, 
        block_securities = 0, 
        urgency_flag = 0, 
        type = 1, 
        operation_type = 2, 
        expected_discount = 0, 
        expected_quantity = 100, 
        expected_repovalue = 25000, 
        expected_repo2value = 25500, 
        expected_return_value = 999, 
        order_num = 678098, 
        report_trade_date = 456789321, 
        settled = 1, 
        clearing_type = 2, 
        report_comission = 10.99, 
        coupon_payment = 0.00, 
        principal_payment = 99.10, 
        principal_payment_date = 456789123, 
        nextdaysettle = 10, 
        settle_currency = "тестовая валюта сеттла", 
        sec_code = "test-sec_code", 
        class_code = "тестовый код класса", 
        compval = 1, 
        parenttradeno = 987321, 
        bankid = "тестовый айди банка", 
        bankaccid = "тестовый айди банковского аккаунта", 
        precisebalance = 100.10, 
        confirmtime = 456789010, 
        ex_flags = 0x2, 
        confirmreport = 7
      }
      
      -- the list of fields that potentially may be encoded in CP1251 encoding
      local fields_that_may_be_encoded_in_cp1251 = {
        brokerref = true, 
        firmid = true, 
        account = true, 
        cpfirmid = true, 
        cpaccount = true, 
        settlecode = true, 
        client_code = true, 
        settle_currency = true, 
        class_code = true, 
        bankid = true, 
        bankaccid = true
      }
      
      neg_trade_cp1251 = {}
      for k, v in pairs(neg_trade_utf8) do
        if fields_that_may_be_encoded_in_cp1251[k] then
          neg_trade_cp1251[k] = utils.Utf8ToCp1251( neg_trade_utf8[k] )
        else
          neg_trade_cp1251[k] = v
        end
      end
    end)
  
    teardown(function()
      neg_trade_utf8 = nil
      neg_trade_cp1251 = nil
    end)
  
    it("SHOULD return a struct with UTF8 encoded values", function()
      
      local result = sut.create_NegTrade(neg_trade_cp1251)
      
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        if type(neg_trade_utf8[key]) == 'number' then 
          t_data[key] = tonumber(value)
        else
          t_data[key] = value
        end
      end

      assert.are.same(neg_trade_utf8, t_data)
    end)
  
  end)
end)
