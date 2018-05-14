package.path = "../?.lua;" .. package.path

local qlua = require("qlua.api")

local module = {}

module[qlua.RPC.ProcedureType.MESSAGE] = "message"

return module
