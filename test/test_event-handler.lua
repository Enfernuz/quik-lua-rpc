package.path = "../?.lua;" .. package.path

local lu = require("test.luaunit")

local qlua_events = require("messages.qlua_events_pb")
local qlua_structs = require("messages.qlua_structures_pb")

local sut = require("impl.event-handler")

local tostring = tostring

TestNoArgEvents = {} -- class

    function TestNoArgEvents:test_shouldReturnNilOnNoArgEvents()

      lu.assertNil( sut:handle(qlua_events.EventType.PUBLISHER_ONLINE) )
      lu.assertNil( sut:handle(qlua_events.EventType.PUBLISHER_OFFLINE) )
      lu.assertNil( sut:handle(qlua_events.EventType.ON_CLOSE) )
      lu.assertNil( sut:handle(qlua_events.EventType.ON_CONNECTED) )
      lu.assertNil( sut:handle(qlua_events.EventType.ON_DISCONNECTED) )
      lu.assertNil( sut:handle(qlua_events.EventType.ON_CLEAN_UP) )
    end
    
-- end class

TestOnFirmEvent = {} -- class

    function TestOnFirmEvent:setUp()
      
      self.firm = {
        firmid = "test-firmid",
        firm_name = "test-firm_name",
        status = 1,
        exchange = "test-exchange"
      }
      
      self.invalid_firm = {
        firm_name = "test-firm_name",
        status = 2,
        exchange = "test-exchange"
      }
    end

    function TestOnFirmEvent:test_shouldCreatePbStruct_Firm()

      local result = sut:handle(qlua_events.EventType.ON_FIRM, self.firm)
      
      local t = {}
      for field, value in result:ListFields() do
        t[tostring(field.name)] = value
      end
      
      lu.assertEquals(self.firm, t)
    end
    
    function TestOnFirmEvent:test_givesErrorIfNoFirmProvided()
      lu.assertError(function() return sut:handle(qlua_events.EventType.ON_FIRM) end)
    end
    
    function TestOnFirmEvent:test_givesErrorIfFirmIsNotValid()
      lu.assertErrorMsgEquals("ee", function() return sut:handle(qlua_events.EventType.ON_FIRM, self.invalid_firm) end)
    end

-- end class

TestOnAllTradeEvent = {} -- class

    function TestOnAllTradeEvent:setUp()
      
      self.alltrade = {
        trade_num = 12345,
        flags = 0x8,
        price = "120.5",
        qty = 200,
        value = "555.7",
        accruedint = "10.4",
        yield = "6.8",
        settlecode = "test-settlecode"
      }
    end

    function TestOnFirmEvent:test_shouldCreatePbStruct_Firm()

      
    end
    
-- end class

local runner = lu.LuaUnit.new()
runner:setOutputType("tap")
os.exit( runner:runSuite() )