package.path = "../?.lua;" .. package.path

local qlua = require("qlua.api")
local rpc_handler = require("impl.rpc-handler")

local unpack = assert(unpack, "unpack function is missing.")
local error = assert(error, "error function is missing.")
local type = assert(type, "type function is missing.")
local pcall = assert(pcall, "pcall function is missing.")
local ipairs = assert(ipairs, "ipairs function is missing.")
local loadstring = assert(loadstring, "loadstring function is missing.")
local tostring = assert(tostring, "tostring function is missing.")
local tonumber = assert(tonumber, "tonumber function is missing.")

local RequestHandler = {
  _VERSION = '0.1.1'
}

local request_handlers = {}

function RequestHandler:get_datasource(datasource_uuid) 
  local ds = rpc_handler.datasources[datasource_uuid] -- TO-DO: лучше вынести datasources из rpc-handler в какой-нибудь state
  if ds == nil then error(string.format("Не найдено data source с uuid '%s'.", datasource_uuid), 0) end
  return ds
end

function RequestHandler:handle(request)
  
  if request == nil then error("No request provided.", 2) end
  if request.type == nil then error("The request has no type.", 2) end
  if type(request.type) ~= 'number' then error("The type of request must be number.", 2) end

  local ok, result = pcall( function() return rpc_handler.call_procedure(request.type, request.args) end )
  
  local response = qlua.RPC.Response()
  response.type = request.type
  
  if ok then 
    if result then
      response.result = result:SerializeToString()
    end
  else
    response.is_error = true
    if result then
      response.result = result
    end
  end
  
  return response
end

return RequestHandler
