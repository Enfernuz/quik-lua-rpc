package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.request-handler", function()
    
  local sut = require("impl.request-handler")
  
  describe("WHEN given nil as a request", function()
      
    it("SHOULD raise an error", function()
      assert.has_error(function() sut:handle() end, "No request provided.")
    end)
  end)

  describe("WHEN given a request with no type", function()
      
    local request = {}
      
    it("SHOULD raise an error", function()
      assert.has_error(function() sut:handle(request) end, "The request has no type.")
    end)
  end)

  describe("WHEN given a request with a non-numeric 'type' field", function()
      
    local request_with_string_type = {}
    request_with_string_type.type = 'type-as-string'
    
    local request_with_table_type = {}
    request_with_table_type.type = {}
    
    local request_with_function_type = {}
    request_with_function_type.type = function() end
    
    local request_with_boolean_type = {}
    request_with_boolean_type.type = true
    
    local request_with_thread_type = {}
    request_with_thread_type.type = coroutine.create(function() end)
    
    -- TO-DO: add a check with the userdata type
    --[[
    local request_with_userdata_type = {}
    request_with_userdata_type.type = ???
    ]]
      
    it("SHOULD raise an error", function()
      assert.has_error(function() sut:handle(request_with_string_type) end, "The type of request must be number.")
      assert.has_error(function() sut:handle(request_with_table_type) end, "The type of request must be number.")
      assert.has_error(function() sut:handle(request_with_function_type) end, "The type of request must be number.")
      assert.has_error(function() sut:handle(request_with_boolean_type) end, "The type of request must be number.")
      assert.has_error(function() sut:handle(request_with_thread_type) end, "The type of request must be number.")
    end)
  end)
    
end)
