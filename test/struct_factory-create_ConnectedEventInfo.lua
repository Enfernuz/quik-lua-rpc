package.path = "../?.lua;" .. package.path

require 'busted.runner'()

describe("The function utils.struct_factory.create_ConnectedEventInfo", function()
    
  local qlua_structs = require("qlua.rpc.qlua_structures_pb")
    
  local sut = require("utils.struct_factory")
  
  describe("WHEN given no 'flag' argument", function()
      
    it("SHOULD return an equal protobuf ConnectedEventInfo struct with 'flag' field set to true", function()
        
      local result = sut.create_ConnectedEventInfo()
        
      -- check the result is a protobuf ParamEventInfo structure
      local expected_meta = getmetatable( qlua_structs.ConnectedEventInfo() )
      local actual_meta = getmetatable(result)
      assert.are.equal(expected_meta, actual_meta)
      
      -- check that the result has the same data as the given param table
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        t_data[key] = value
      end

      assert.are.equal(true, t_data.flag)
    end)
  end)
  
  -----
  
  describe("WHEN given flag=false", function()
      
    local flag
    
    setup(function()
      flag = false
    end)
    
    teardown(function()
      flag = nil
    end)
  
    it("SHOULD return an equal protobuf ConnectedEventInfo struct", function()
        
      local result = sut.create_ConnectedEventInfo(flag)
        
      -- check the result is a protobuf ParamEventInfo structure
      local expected_meta = getmetatable( qlua_structs.ConnectedEventInfo() )
      local actual_meta = getmetatable(result)
      assert.are.equal(expected_meta, actual_meta)
      
      -- check that the result has the same data as the given param table
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        t_data[key] = value
      end

      assert.are.equal(flag, t_data.flag)
    end)
  end)

  -----

  describe("WHEN given flag=true", function()
      
    local flag
    
    setup(function()
      flag = true
    end)
    
    teardown(function()
      flag = nil
    end)
  
    it("SHOULD return an equal protobuf ConnectedEventInfo struct", function()
        
      local result = sut.create_ConnectedEventInfo(flag)
        
      -- check the result is a protobuf ParamEventInfo structure
      local expected_meta = getmetatable( qlua_structs.ConnectedEventInfo() )
      local actual_meta = getmetatable(result)
      assert.are.equal(expected_meta, actual_meta)
      
      -- check that the result has the same data as the given param table
      local t_data = {}
      for field, value in result:ListFields() do
        local key = tostring(field.name)
        t_data[key] = value
      end

      assert.are.equal(flag, t_data.flag)
    end)
  end)
end)
