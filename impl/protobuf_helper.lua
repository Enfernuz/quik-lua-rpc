package.path = "../?.lua;" .. package.path

local qlua = require("qlua.api")
local utils = require("utils.utils")

local module = {}

local method_names = {}
local procedure_types = {}
local args_prototypes = {}
local result_object_mappers = {}

-- unknown
method_names[qlua.RPC.ProcedureType.PROCEDURE_TYPE_UNKNOWN] = "unknown"
procedure_types[method_names[qlua.RPC.ProcedureType.PROCEDURE_TYPE_UNKNOWN]] = qlua.RPC.ProcedureType.PROCEDURE_TYPE_UNKNOWN

-- isConnected
method_names[qlua.RPC.ProcedureType.IS_CONNECTED] = "isConnected"
procedure_types[method_names[qlua.RPC.ProcedureType.IS_CONNECTED]] = qlua.RPC.ProcedureType.IS_CONNECTED
args_prototypes[qlua.RPC.ProcedureType.IS_CONNECTED] = nil
result_object_mappers[method_names[qlua.RPC.ProcedureType.IS_CONNECTED]] = function (proc_result)

  local result = qlua.isConnected.Result()
  result.is_connected = proc_result
  
  return result
end

-- getScriptPath
method_names[qlua.RPC.ProcedureType.GET_SCRIPT_PATH] = "getScriptPath"
procedure_types[method_names[qlua.RPC.ProcedureType.GET_SCRIPT_PATH]] = qlua.RPC.ProcedureType.GET_SCRIPT_PATH
args_prototypes[qlua.RPC.ProcedureType.GET_SCRIPT_PATH] = nil
result_object_mappers[method_names[qlua.RPC.ProcedureType.GET_SCRIPT_PATH]] = function (proc_result)

  local result = qlua.getScriptPath.Result()
  result.script_path = proc_result
  
  return result
end

-- getInfoParam
method_names[qlua.RPC.ProcedureType.GET_INFO_PARAM] = "getInfoParam"
procedure_types[method_names[qlua.RPC.ProcedureType.GET_INFO_PARAM]] = qlua.RPC.ProcedureType.GET_INFO_PARAM
args_prototypes[qlua.RPC.ProcedureType.GET_INFO_PARAM] = qlua.getInfoParam.Request
result_object_mappers[method_names[qlua.RPC.ProcedureType.GET_INFO_PARAM]] = function (proc_result)

  local result = qlua.getInfoParam.Result()
  result.info_param = proc_result
  
  return result
end

-- message
method_names[qlua.RPC.ProcedureType.MESSAGE] = "message"
procedure_types[method_names[qlua.RPC.ProcedureType.MESSAGE]] = qlua.RPC.ProcedureType.MESSAGE
args_prototypes[qlua.RPC.ProcedureType.MESSAGE] = qlua.message.Request
result_object_mappers[method_names[qlua.RPC.ProcedureType.MESSAGE]] = function (proc_result)

  local result = qlua.message.Result()
  result.result = proc_result
  return result
end

-- getItem
method_names[qlua.RPC.ProcedureType.GET_ITEM] = "getItem"
procedure_types[method_names[qlua.RPC.ProcedureType.GET_ITEM]] = qlua.RPC.ProcedureType.GET_ITEM
args_prototypes[qlua.RPC.ProcedureType.GET_ITEM] = qlua.getItem.Request
result_object_mappers[method_names[qlua.RPC.ProcedureType.GET_ITEM]] = function (proc_result)

  local result = qlua.getItem.Result()
  if proc_result then
    utils.new_put_to_string_string_pb_map(proc_result, result.table_row, qlua.getItem.Result.TableRowEntry)
  end
  
  return result
end

-----

function module.get_method_name (pb_procedure_type)
  return method_names[pb_procedure_type]
end

function module.get_protobuf_procedure_type (method_name)
  return procedure_types[method_name]
end

function module.get_protobuf_args_prototype (pb_procedure_type)
  return args_prototypes[pb_procedure_type]
end

function module.get_protobuf_result_object_mapper (method_name)
  return result_object_mappers[method_name]
end

return module
