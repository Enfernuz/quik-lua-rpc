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

module.getFuturesLimit = {
  Request = package .. "getFuturesLimit.Request",
  Result = package .. "getFuturesLimit.Result"
}

module.getFuturesHolding = {
  Request = package .. "getFuturesHolding.Request",
  Result = package .. "getFuturesHolding.Result"
}

module.getSecurityInfo = {
  Request = package .. "getSecurityInfo.Request",
  Result = package .. "getSecurityInfo.Result"
}

module.getTradeDate = {
  Request = package .. "getTradeDate.Request",
  Result = package .. "getTradeDate.Result", 
  TradeDate = package .. "getTradeDate.TradeDate"
}

module.getQuoteLevel2 = {
  Request = package .. "getQuoteLevel2.Request",
  Result = package .. "getQuoteLevel2.Result", 
  QuoteEntry = package .. "getQuoteLevel2.QuoteEntry"
}

module.getLinesCount = {
  Request = package .. "getLinesCount.Request",
  Result = package .. "getLinesCount.Result"
}

module.getNumCandles = {
  Request = package .. "getNumCandles.Request",
  Result = package .. "getNumCandles.Result"
}

module.getCandlesByIndex = {
  Request = package .. "getCandlesByIndex.Request",
  Result = package .. "getCandlesByIndex.Result"
}

module.datasource = {}
module.datasource.CreateDataSource = {
  Request = package .. "datasource.CreateDataSource.Request",
  Result = package .. "datasource.CreateDataSource.Result"
}

module.datasource.SetUpdateCallback = {
  Request = package .. "datasource.SetUpdateCallback.Request",
  Result = package .. "datasource.SetUpdateCallback.Result"
}

module.qlua_structures = {
  Klass = ".qlua.structs.Klass",
  Order = ".qlua.structs.Order",
  MoneyLimit = ".qlua.structs.MoneyLimit", 
  DepoLimit = ".qlua.structs.DepoLimit", 
  FuturesLimit = ".qlua.structs.FuturesLimit", 
  FuturesClientHolding = ".qlua.structs.FuturesClientHolding", 
  Security = ".qlua.structs.Security", 
  CandleEntry = ".qlua.structs.CandleEntry"
}

return module
