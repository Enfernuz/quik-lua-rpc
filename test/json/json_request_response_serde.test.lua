require("busted.runner")()

local io = require("io")
local json = require("utils/json")

local ctx_path = "test/json/"

local readFile = function (file_path)
  local f = assert(io.open(ctx_path..file_path, "r"))
  local content = f:read("*all")
  f:close()
  return content
end

describe("JSON args deserializer / result serializer", function ()
    
    local sut = require("impl/json_request_response_serde")
    
    describe("WHEN given DeleteRow", function ()
        
      local method_name = "DeleteRow"
      
      describe("Args as a JSON string", function ()
        local req_json = readFile(method_name.."/request.json")
        it("SHOULD return the correct method name and args table", function()
          local actual_method_name, actual_args = sut:deserialize_request(req_json)
          assert.are.equal(actual_method_name, method_name)
          assert.are.same(actual_args, {t_id = 1, key = 2})
        end)
      end)
  
      describe("Result table", function ()
        local expected_json = readFile(method_name.."/result.json")
        it("SHOULD serialize it into JSON and return the correct string", function()
          local actual_json = sut:serialize_response({method = method_name, proc_result = true})
          assert.are.same(json.decode(actual_json), json.decode(expected_json))
        end)
      end)
    end)
end)
