package.path = "../?.lua;" .. package.path

local qlua = require("qlua.api")

local module = {}

local proc_type_to_method_name = {}

proc_type_to_method_name[qlua.RPC.ProcedureType.MESSAGE] = "message"

local proc_type_to_args_ctr = {}
proc_type_to_args_ctr[qlua.RPC.ProcedureType.MESSAGE] = qlua.message.Request

local proc_type_to_result_serializer = {}
proc_type_to_result_serializer[proc_type_to_method_name[qlua.RPC.ProcedureType.MESSAGE]] = function (proc_result)

  local result = qlua.message.Result()
  result.result = proc_result
  return result
end

local method_name_to_proc_type = {}
method_name_to_proc_type[proc_type_to_method_name[qlua.RPC.ProcedureType.MESSAGE]] = qlua.RPC.ProcedureType.MESSAGE

function module.deserialize_request (serialized_request)
  
  local request = qlua.RPC.Request()
  request:ParseFromString(serialized_request)
  
  local method = proc_type_to_method_name[request.type]
  if not method then
    error( string.format("There's no function's name mapped to the protobuf QLua ProcedureType %s", request.type) )
  end
  
  local args = request.args -- pb serialized, may be nil
  if args then
    local args_ctr = proc_type_to_args_ctr[request.type]
    if args_ctr then
      local args_deserialized = args_ctr()
      args_deserialized:ParseFromString(args)
      args = args_deserialized
    else
      error( string.format("There's no protobuf request arguments deserializer mapped to the protobuf QLua ProcedureType %s", request.type) )
    end
  end
  
  return {
    method = method,
    args = args
  }
end

function module.serialize_response (deserialized_response)
  
  local response = qlua.RPC.Response()
  
  local proc_type = method_name_to_proc_type[deserialized_response.method]
  if proc_type then
    response.type = proc_type
  else
    error( string.format("There's no protobuf QLua ProcedureType mapped to the function's name  %s", deserialized_response.method) )
  end
  
  if deserialized_response.is_error then
    response.is_error = true
    if deserialized_response.result then
      response.result = deserialized_response.result
    else
      --TODO: maybe set a generic error message
    end
  else
    if deserialized_response.result then
      response.result = proc_type_to_result_serializer[deserialized_response.method](deserialized_response.result):SerializeToString()
    end
  end
  
  return response:SerializeToString()
end

return module
