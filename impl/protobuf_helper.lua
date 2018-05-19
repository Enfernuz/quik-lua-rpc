package.path = "../?.lua;" .. package.path

local qlua = require("qlua.api")
local utils = require("utils.utils")
local struct_factory = require("utils.struct_factory")

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

-- sleep
method_names[qlua.RPC.ProcedureType.SLEEP] = "sleep"
procedure_types[method_names[qlua.RPC.ProcedureType.SLEEP]] = qlua.RPC.ProcedureType.SLEEP
args_prototypes[qlua.RPC.ProcedureType.SLEEP] = qlua.sleep.Request
result_object_mappers[method_names[qlua.RPC.ProcedureType.SLEEP]] = function (proc_result)

  local result = qlua.sleep.Result()
  result.result = proc_result
  return result
end

-- getWorkingFolder
method_names[qlua.RPC.ProcedureType.GET_WORKING_FOLDER] = "getWorkingFolder"
procedure_types[method_names[qlua.RPC.ProcedureType.GET_WORKING_FOLDER]] = qlua.RPC.ProcedureType.GET_WORKING_FOLDER
args_prototypes[qlua.RPC.ProcedureType.GET_WORKING_FOLDER] = nil
result_object_mappers[method_names[qlua.RPC.ProcedureType.GET_WORKING_FOLDER]] = function (proc_result)

  local result = qlua.getWorkingFolder.Result()
  result.working_folder = proc_result
  return result
end

-- PrintDbgStr
method_names[qlua.RPC.ProcedureType.PRINT_DBG_STR] = "PrintDbgStr"
procedure_types[method_names[qlua.RPC.ProcedureType.PRINT_DBG_STR]] = qlua.RPC.ProcedureType.PRINT_DBG_STR
args_prototypes[qlua.RPC.ProcedureType.PRINT_DBG_STR] = qlua.PrintDbgStr.Request
result_object_mappers[method_names[qlua.RPC.ProcedureType.PRINT_DBG_STR]] = nil

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

-- getOrderByNumber
method_names[qlua.RPC.ProcedureType.GET_ORDER_BY_NUMBER] = "getOrderByNumber"
procedure_types[method_names[qlua.RPC.ProcedureType.GET_ORDER_BY_NUMBER]] = qlua.RPC.ProcedureType.GET_ORDER_BY_NUMBER
args_prototypes[qlua.RPC.ProcedureType.GET_ORDER_BY_NUMBER] = qlua.getOrderByNumber.Request
result_object_mappers[method_names[qlua.RPC.ProcedureType.GET_ORDER_BY_NUMBER]] = function (proc_result)

  local result = qlua.getOrderByNumber.Result()
  struct_factory.create_Order(proc_result.t, result.order)
  result.indx = proc_result.i
  return result
end

-- getNumberOf
method_names[qlua.RPC.ProcedureType.GET_NUMBER_OF] = "getNumberOf"
procedure_types[method_names[qlua.RPC.ProcedureType.GET_NUMBER_OF]] = qlua.RPC.ProcedureType.GET_NUMBER_OF
args_prototypes[qlua.RPC.ProcedureType.GET_NUMBER_OF] = qlua.getNumberOf.Request
result_object_mappers[method_names[qlua.RPC.ProcedureType.GET_NUMBER_OF]] = function (proc_result)

  local result = qlua.getNumberOf.Result()
  result.result = proc_result
  return result
end

-- SearchItems
method_names[qlua.RPC.ProcedureType.SEARCH_ITEMS] = "SearchItems"
procedure_types[method_names[qlua.RPC.ProcedureType.SEARCH_ITEMS]] = qlua.RPC.ProcedureType.SEARCH_ITEMS
args_prototypes[qlua.RPC.ProcedureType.SEARCH_ITEMS] = qlua.SearchItems.Request
result_object_mappers[method_names[qlua.RPC.ProcedureType.SEARCH_ITEMS]] = function (proc_result)

  local result = qlua.SearchItems.Result()
  if proc_result then 
    for i, item_index in ipairs(proc_result) do
      table.sinsert(result.items_indices, item_index)
    end
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
