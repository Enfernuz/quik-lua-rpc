package.path = "../?.lua;" .. package.path

--local qlua = require("qlua.api")
local pb_helper = require("impl.protobuf_helper")
local qlua_pb_types = require("qlua.qlua_pb_types")
local pb = require("pb")

return function (context_path)
  
  require("qlua.qlua_pb_init")(context_path)
  
  local module = {}
  
  function module.deserialize_request (serialized_request)
  
    local request = pb.decode(qlua_pb_types.RPC.Request, serialized_request)

    local method = pb_helper.get_method_name(request.type)
    if not method then
      error( string.format("There's no function's name mapped to the protobuf QLua ProcedureType %s", request.type) )
    end
    
    local args = request.args -- pb serialized, may be nil
    if args then
      local args_type = pb_helper.get_protobuf_args_prototype(request.type)
      if args_type then
        args = pb.decode(args_type, args)
      else
        error( string.format("There's no protobuf request arguments deserializer mapped to the protobuf QLua ProcedureType %s", request.type) )
      end
    end
    
    return method, args
  end
  
  function module.serialize_response (deserialized_response)
  
    local response = pb.defaults(qlua_pb_types.RPC.Response)
    local err = deserialized_response.error
    
    if err then
      response.is_error = true
      response.result = err.message -- TODO: write the full error object
    else
      local result = deserialized_response.result
      local method = result.method
      response.type = pb_helper.get_protobuf_procedure_type(method)
      if not response.type then
        -- TODO: make the message in Russian
        error( string.format("Для QLua-функции '%s' не найден соответствующий тип процедуры protobuf.", method) )
      end
      
      local data = result.data
      if data then
        local object_mapper = pb_helper.get_protobuf_result_object_mapper(method)
        response.result = pb.encode( object_mapper(data) )
      end
    end
    
    return pb.encode(qlua_pb_types.RPC.Response, response)
  end
  
  return module
end



--[[
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
]]



--[[
function module.serialize_response (deserialized_response)

  local response = qlua.RPC.Response()
  local err = deserialized_response.error
  if err then
    response.is_error = true
    response.result = err.message -- TODO: write the full error object
  else
    local result = deserialized_response.result
    local method = result.method
    response.type = pb_helper.get_protobuf_procedure_type(method)
    if not response.type then
      -- TODO: make the message in Russian
      error( string.format("Для QLua-функции '%s' не найден соответствующий тип процедуры protobuf.", method) )
    end
    
    local data = result.data
    if data then
      local object_mapper = pb_helper.get_protobuf_result_object_mapper(method)
      response.result = object_mapper(data):SerializeToString()
    end
  end
  
  return response:SerializeToString()
end
]]

--return module
