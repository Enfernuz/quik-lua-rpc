local module = {}

local package = ".qlua.rpc."

module.RPC = {
  Request = package .. "RPC.Request",
  Response = package .. "RPC.Response"
}

module.isConnected = {
  Request = package .. "isConnected.Request",
  Result = package .. "isConnected.Result"
}

module.getScriptPath = {
  Request = package .. "getScriptPath.Request",
  Result = package .. "getScriptPath.Result"
}

module.getInfoParam = {
  Request = package .. "getInfoParam.Request",
  Result = package .. "getInfoParam.Result"
}

module.message = {
  Request = package .. "message.Request",
  Result = package .. "message.Result"
}

module.sleep = {
  Request = package .. "sleep.Request",
  Result = package .. "sleep.Result"
}

module.getWorkingFolder = {
  Request = package .. "getWorkingFolder.Request",
  Result = package .. "getWorkingFolder.Result"
}

module.PrintDbgStr = {
  Request = package .. "PrintDbgStr.Request",
  Result = package .. "PrintDbgStr.Result"
}

module.getItem = {
  Request = package .. "getItem.Request",
  Result = package .. "getItem.Result"
}

module.getOrderByNumber = {
  Request = package .. "getOrderByNumber.Request",
  Result = package .. "getOrderByNumber.Result"
}

module.getNumberOf = {
  Request = package .. "getNumberOf.Request",
  Result = package .. "getNumberOf.Result"
}

module.SearchItems = {
  Request = package .. "SearchItems.Request",
  Result = package .. "SearchItems.Result"
}

module.qlua_structures = {
  Order = ".qlua.structs.Order"
}

return module
