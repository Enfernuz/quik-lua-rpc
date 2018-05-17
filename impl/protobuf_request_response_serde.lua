package.path = "../?.lua;" .. package.path

local qlua = require("qlua.api")
local pb_helper = require("impl.protobuf_helper")

local module = {}

function module.deserialize_request (serialized_request)
  
  local request = qlua.RPC.Request()
  request:ParseFromString(serialized_request)
  
  local method = pb_helper.get_method_name(request.type)
  if not method then
    error( string.format("There's no function's name mapped to the protobuf QLua ProcedureType %s", request.type) )
  end
  
  local args = request.args -- pb serialized, may be nil
  if args then
    local prototype = pb_helper.get_protobuf_args_prototype(request.type)
    if prototype then
      local args_deserialized = prototype()
      args_deserialized:ParseFromString(args)
      args = args_deserialized
    else
      error( string.format("There's no protobuf request arguments deserializer mapped to the protobuf QLua ProcedureType %s", request.type) )
    end
  end
  
  return method, args
end

function module.serialize_response (deserialized_response)
  
  local response = qlua.RPC.Response()
  
  local proc_type = pb_helper.get_protobuf_procedure_type[deserialized_response.method]
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
      local object_mapper = pb_helper.get_protobuf_result_object_mapper(deserialized_response.method)
      response.result = object_mapper(deserialized_response.result):SerializeToString()
    end
  end
  
  return response:SerializeToString()
end

return module
