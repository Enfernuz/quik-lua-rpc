package.path = "../?.lua;" .. package.path

require 'busted.runner'()

local match = require("luassert.match")

describe("impl.event-handler", function()
    
  local qlua_events = require("messages.qlua_events_pb")

  local struct_factory = mock( require("utils.struct_factory") )
    
  local sut = require("impl.event-handler")
  
  -----

  describe("WHEN handling the ON_PARAM event", function()
      
    -----
      
    describe("AND given a param table", function()
        
      local param
      
      setup(function()
      
        param = {
          class_code = "test-class_code", 
          sec_code = "test-sec_code"
        }
      end)
    
      teardown(function()
        param = nil
      end)
    
      it("SHOULD call struct_factory.create_ParamEventInfo with that param table as an argument", function()
        
        sut:handle(qlua_events.EventType.ON_PARAM, param)

        assert.spy(struct_factory.create_ParamEventInfo).was_called_with(param)
      end)
    
      it("SHOULD return the same result as struct_factory.create_ParamEventInfo", function()

        local actual = sut:handle(qlua_events.EventType.ON_PARAM, param)
        local expected = struct_factory.create_ParamEventInfo(param)
        
        assert.are.same(expected, actual)
      end)
    end)
  
  end)

-----
  
end)
