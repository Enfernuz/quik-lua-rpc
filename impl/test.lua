package.path = "../?.lua;" .. package.path

local rpc_handler = require("impl.rpc-handler")

local json_handler = rpc_handler:new('json')
local pb_handler = rpc_handler:new('protobuf')

pcall(function() json_handler.call_procedure('qwerty', {}) end)
pcall(function() pb_handler.call_procedure(123, {}) end)
