package.path = "../?.lua;" .. package.path

local qlua = require("qlua.api")

local struct_factory = require("utils.struct_factory")
local struct_converter = require("utils.struct_converter")
local utils = require("utils.utils")
local table = require('table')
local string = require('string')
local bit = require('bit')

local value_to_string_or_empty_string = assert(utils.value_to_string_or_empty_string)
local value_or_empty_string = assert(utils.value_or_empty_string)

local error = assert(error, "error function is missing.")

local qlua_rpc_protobuf = require("qlua-rpc-protobuf")
local qlua_rpc_json = require("qlua-rpc-json")

local module = {
  
  _VERSION = '0.2.0'
}

local datasources = {}

function module.get_datasource(datasource_uid)
  return assert(datasources[datasource_uid], string.format("DataSource c uuid='%s' не найден.", datasource_uid))
end



local function call_procedure_protobuf (procedure_type, procedure_args)
  
  local handler = qlua_rpc_protobuf[procedure_type]

  if handler == nil then 
    error(string.format("Unknown procedure type: %d.", procedure_type), 0)
  else
    return handler(procedure_args)
  end
end

local function call_procedure_json (procedure_type, procedure_args)
  
  local handler = qlua_rpc_json[procedure_type]

  if handler == nil then 
    error(string.format("Unknown procedure type: %s.", procedure_type), 0)
  else
    return handler(procedure_args)
  end
end

function module:new (serde_protocol)
  
  local sd_protocol = string.tolower(serde_protocol)
  if "json" == sd_protocol then
    self["call_procedure"] = call_procedure_json
  else if "protobuf" == sd_protocol
    self["call_procedure"] = call_procedure_protobuf
  else
    error(string.format("Unsupported serialization/deserialization protocol: %s.", serde_protocol), 0)
  end
end

return module
