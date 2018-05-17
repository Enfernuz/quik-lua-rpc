package.path = "../?.lua;" .. package.path

local qlua = require("qlua.api")

local module = {}

local method_names = {}
local procedure_types = {}
local args_prototypes = {}
local result_object_mappers = {}

-- message
method_names[qlua.RPC.ProcedureType.MESSAGE] = "message"
procedure_types[method_names[qlua.RPC.ProcedureType.MESSAGE]] = qlua.RPC.ProcedureType.MESSAGE
args_prototypes[qlua.RPC.ProcedureType.MESSAGE] = qlua.message.Request
result_object_mappers[method_names[qlua.RPC.ProcedureType.MESSAGE]] = function (proc_result)

  local result = qlua.message.Result()
  result.result = proc_result
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
