package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local inspect = require("inspect")

describe("impl.event-handler", function()
    
  local qlua_events = require("messages.qlua_events_pb")
  local qlua_structs = require("messages.qlua_structures_pb")
    
  local sut = require("impl.event-handler")
  
  -----

  describe("WHEN handling the ON_FIRM event", function()
      
    -----
      
    describe("AND given a correct firm", function()
        
      local firm, protobuf_struct_Firm_meta
      
      setup(function()
      
        firm = {
          firmid = "test-firmid",
          firm_name = "test-firm_name",
          status = 1,
          exchange = "test-exchange"
        }
      
        protobuf_struct_Firm_meta = getmetatable( qlua_structs.Firm() )
      end)
    
      teardown(function()
        firm = nil
        protobuf_struct_Firm_meta = nil
      end)
    
      it("SHOULD create an equal protobuf struct", function()
          
        local result = sut:handle(qlua_events.EventType.ON_FIRM, firm)

        assert.are.equal(protobuf_struct_Firm_meta, getmetatable(result))
        
        assert.are.equal(firm.firmid, result.firmid)
        assert.are.equal(firm.firm_name, result.firm_name)
        assert.are.equal(firm.status, result.status)
        assert.are.equal(firm.exchange, result.exchange)
      end)
    end)
  
    -----
      
    describe("AND given no firm", function()
      
      it("SHOULD raise an error if no firm provided", function()
          
        local get_event_result = function() 
          return sut:handle(qlua_events.EventType.ON_FIRM)
        end
          
        assert.has_error(get_event_result)
      end)
    end)
  
    -----

    describe("AND given a firm", function()
      
      local firm
      
      setup(function()
          
        firm = {
          firmid = "test-firmid",
          firm_name = "test-firm_name",
          status = 1,
          exchange = "test-exchange"
        }
      end)
    
      teardown(function()
        firm = nil
      end)
      
      local required_fields_names = {"firmid", "status"}
      local non_required_fields_names = {"firm_name", "exchange"}
      
      for _, field_name in ipairs(required_fields_names) do
        
        -----
        
        describe(string.format("with no field '%s'", field_name), function()
            
          local stored_value
      
          setup(function()
            stored_value = firm[field_name]
            firm[field_name] = nil
          end)
      
          teardown(function()
            firm[field_name] = stored_value
            stored_value = nil
          end)
      
          it("should raise an error", function()
            
            local get_event_result = function() 
              return sut:handle(qlua_events.EventType.ON_FIRM, firm)
            end
            
            assert.has_error(get_event_result)
          end)
        end)
      
        -----
      end
      
      for _, field_name in ipairs(non_required_fields_names) do
        
        -----
        
        describe(string.format("with no field '%s'", field_name), function()
            
          local stored_value
      
          setup(function()
            stored_value = firm[field_name]
            firm[field_name] = nil
          end)
      
          teardown(function()
            firm[field_name] = stored_value
            stored_value = nil
          end)
      
          it("SHOULD return a struct with an empty string in that field", function()
            
            local result = sut:handle(qlua_events.EventType.ON_FIRM, firm)
            assert.are.equal("", result[field_name])
          end)
        end)
      
        -----
      end
    end)
  
    -----
  
  end)

-----
  
end)
