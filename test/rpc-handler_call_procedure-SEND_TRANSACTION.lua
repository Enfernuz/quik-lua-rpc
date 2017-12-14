package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.rpc-handler", function()
  
  local qlua = require("qlua.api")
  local utils = require("utils.utils")
  local sut = require("impl.rpc-handler")

  describe("WHEN given a request of type ProcedureType.SEND_TRANSACTION", function()
      
    local request
    
    setup(function()
      
      request = {}
      request.type = qlua.RPC.ProcedureType.SEND_TRANSACTION
    end)
  
    teardown(function()
      request = nil
    end)

    insulate("WITH arguments", function()
        
      local request_args
      local proc_result
      
      setup(function()
      
        request_args = qlua.sendTransaction.Request()
        
        local p1 = qlua.sendTransaction.Request.TransactionEntry()
        p1.key = "ACCOUNT"
        p1.value = "abcde"
        table.insert(request_args.transaction, p1)
  
        local p2 = qlua.sendTransaction.Request.TransactionEntry()
        p2.key = "PRICE"
        p2.value = "12.34"
        table.insert(request_args.transaction, p2)
  
        local p3 = qlua.sendTransaction.Request.TransactionEntry()
        p3.key = "STOP_PRICE"
        p3.value = "9.87"
        table.insert(request_args.transaction, p3)
        
        request.args = request_args:SerializeToString()

        proc_result = "test-response"
        
        _G.sendTransaction = spy.new(function(transaction) return proc_result end)
      end)

      teardown(function()

        request_args = nil
        proc_result = nil
      end)
    
      it("SHOULD call the global 'sendTransaction' function once, passing the 'transaction' argument converted to an ordinary table", function()
        
        local response = sut.call_procedure(request.type, request.args)
    
        assert.spy(_G.sendTransaction).was.called_with(utils.create_table(request_args.transaction))
      end)
    
      it("SHOULD return a qlua.sendTransaction.Result instance", function()
          
        local actual_result = sut.call_procedure(request.type, request.args)
        local expected_result = qlua.sendTransaction.Result()
        
        local actual_meta = getmetatable(actual_result)
        local expected_meta = getmetatable(expected_result)
        
        assert.are.equal(expected_meta, actual_meta)
      end)
    
      it("SHOULD return a protobuf object which string-serialized form equals to that of the expected result", function()
        
        local actual_result = sut.call_procedure(request.type, request.args)
        local expected_result = qlua.sendTransaction.Result()
        
        expected_result.result = proc_result
        
        assert.are.equal(expected_result:SerializeToString(), actual_result:SerializeToString())
      end)
    end)
  
    describe("WITHOUT arguments", function()
      
      it("SHOULD raise an error", function()
        
        assert.has_error(function() sut.call_procedure(request.type) end, "The request has no arguments.")
      end)
    end)
  end)

end)
