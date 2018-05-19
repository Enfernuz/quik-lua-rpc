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

local qlua_protobuf_to_func_mapping = require("impl.qlua-protobuf-to-func-mapping")
local qlua_procedure_caller = require("impl.qlua-procedure-caller")

local module = {
  
  _VERSION = '0.3.0'
}

local datasources = {}

function module.get_datasource(datasource_uid)
  return assert(datasources[datasource_uid], string.format("DataSource c uuid='%s' не найден.", datasource_uid))
end

local function make_rpc (qlua_func_name, args)
  print('general')
  local handler = qlua_procedure_caller[qlua_func_name]

  if handler == nil then 
    error(string.format("Unknown QLua function name: %s.", qlua_func_name), 0)
  end
    
  return handler(args)
end

local function make_rpc_protobuf (procedure_type, procedure_args)
  print('protobuf')
  local qlua_func_name = qlua_protobuf_to_func_mapping[procedure_type]
  if qlua_func_name == nil then
    error(string.format("Unknown QLua protobuf procedure type: %d.", procedure_type), 0)
  end
  
  return make_rpc(qlua_func_name, procedure_args)
end

function module:new (serde_protocol)
  
  local obj = {}
  
  
  local sd_protocol = string.lower(serde_protocol)
  local rpc_method_handle
  if "json" == sd_protocol then
    rpc_method_handle = make_rpc
  elseif "protobuf" == sd_protocol then
    rpc_method_handle = make_rpc_protobuf
  else
    error(string.format("Unsupported serialization/deserialization protocol: %s.", serde_protocol), 0)
  end
  
  function obj:call_procedure (proc_type, proc_args)
    return rpc_method_handle(proc_type, proc_args)
  end
  
  setmetatable(obj, self)
  self.__index = self
  
  return obj
end

return module
