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

module.getClassesList = {
  Request = package .. "getClassesList.Request",
  Result = package .. "getClassesList.Result"
}

module.getClassInfo = {
  Request = package .. "getClassInfo.Request",
  Result = package .. "getClassInfo.Result"
}

module.getClassSecurities = {
  Request = package .. "getClassSecurities.Request",
  Result = package .. "getClassSecurities.Result"
}

module.getMoney = {
  Request = package .. "getMoney.Request",
  Result = package .. "getMoney.Result",
  Money = package .. "getMoney.Money"
}

module.getMoneyEx = {
  Request = package .. "getMoneyEx.Request",
  Result = package .. "getMoneyEx.Result"
}

module.getDepo = {
  Request = package .. "getDepo.Request",
  Result = package .. "getDepo.Result", 
  Depo = package .. "getDepo.Depo"
}

module.getDepoEx = {
  Request = package .. "getDepoEx.Request",
  Result = package .. "getDepoEx.Result"
}

module.qlua_structures = {
  Klass = ".qlua.structs.Klass",
  Order = ".qlua.structs.Order",
  MoneyLimit = ".qlua.structs.MoneyLimit", 
  DepoLimit = ".qlua.structs.DepoLimit"
}

return module
