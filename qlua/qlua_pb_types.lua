local module = {}

local package = ".qlua.rpc."

local proto = "RPC"
local path = package .. proto .. "."
module[proto] = {
  Request = path .. "Request",
  Response = path .. "Response"
}

proto = "isConnected"
path = package .. proto .. "."
module[proto] = {
  Request = path .. "Request",
  Result = path .. "Result"
}

proto = "getScriptPath"
path = package .. proto .. "."
module[proto] = {
  Request = path .. "Request",
  Result = path .. "Result"
}

proto = "getInfoParam"
path = package .. proto .. "."
module[proto] = {
  Request = path .. "Request",
  Result = path .. "Result"
}

proto = "message"
path = package .. proto .. "."
module[proto] = {
  Request = path .. "Request",
  Result = path .. "Result"
}

proto = "sleep"
path = package .. proto .. "."
module[proto] = {
  Request = path .. "Request",
  Result = path .. "Result"
}

proto = "getWorkingFolder"
path = package .. proto .. "."
module[proto] = {
  Request = path .. "Request",
  Result = path .. "Result"
}

proto = "PrintDbgStr"
path = package .. proto .. "."
module[proto] = {
  Request = path .. "Request",
  Result = path .. "Result"
}

proto = "getItem"
path = package .. proto .. "."
module[proto] = {
  Request = path .. "Request",
  Result = path .. "Result"
}

proto = "getOrderByNumber"
path = package .. proto .. "."
module[proto] = {
  Request = path .. "Request",
  Result = path .. "Result"
}

proto = "getNumberOf"
path = package .. proto .. "."
module[proto] = {
  Request = path .. "Request",
  Result = path .. "Result"
}

proto = "SearchItems"
path = package .. proto .. "."
module[proto] = {
  Request = path .. "Request",
  Result = path .. "Result"
}

proto = "getClassesList"
path = package .. proto .. "."
module[proto] = {
  Request = path .. "Request",
  Result = path .. "Result"
}

proto = "getClassInfo"
path = package .. proto .. "."
module[proto] = {
  Request = path .. "Request",
  Result = path .. "Result"
}

proto = "getClassSecurities"
path = package .. proto .. "."
module[proto] = {
  Request = path .. "Request",
  Result = path .. "Result"
}

proto = "getMoney"
path = package .. proto .. "."
module[proto] = {
  Request = path .. "Request",
  Result = path .. "Result"
  Money = path .. "Money"
}

proto = "getMoneyEx"
path = package .. proto .. "."
module[proto] = {
  Request = path .. "Request",
  Result = path .. "Result"
}

proto = "getDepo"
path = package .. proto .. "."
module[proto] = {
  Request = path .. "Request",
  Result = path .. "Result" 
  Depo = path .. "Depo"
}

proto = "getDepoEx"
path = package .. proto .. "."
module[proto] = {
  Request = path .. "Request",
  Result = path .. "Result"
}

proto = "getFuturesLimit"
path = package .. proto .. "."
module[proto] = {
  Request = path .. "Request",
  Result = path .. "Result"
}

proto = "getFuturesHolding"
path = package .. proto .. "."
module[proto] = {
  Request = path .. "Request",
  Result = path .. "Result"
}

proto = "getSecurityInfo"
path = package .. proto .. "."
module[proto] = {
  Request = path .. "Request",
  Result = path .. "Result"
}

proto = "getTradeDate"
path = package .. proto .. "."
module[proto] = {
  Request = path .. "Request",
  Result = path .. "Result", 
  TradeDate = path .. "TradeDate"
}

proto = "getQuoteLevel2"
path = package .. proto .. "."
module[proto] = {
  Request = path .. "Request",
  Result = path .. "Result", 
  QuoteEntry = path .. "QuoteEntry"
}

proto = "getLinesCount"
path = package .. proto .. "."
module[proto] = {
  Request = path .. "Request",
  Result = path .. "Result"
}

proto = "getNumCandles"
path = package .. proto .. "."
module[proto] = {
  Request = path .. "Request",
  Result = path .. "Result"
}

proto = "getCandlesByIndex"
path = package .. proto .. "."
module[proto] = {
  Request = path .. "Request",
  Result = path .. "Result"
}

module.datasource = {}

local subpackage = "datasource."
proto = "CreateDataSource"
path = package .. subpackage .. proto .. "."
module.datasource[proto] = {
  Request = path .. "Request",
  Result = path .. "Result"
}

proto = "SetUpdateCallback"
path = package .. subpackage .. proto .. "."
module.datasource[proto] = {
  Request = path .. "Request",
  Result = path .. "Result"
}

proto = "O"
path = package .. subpackage .. proto .. "."
module.datasource[proto] = {
  Request = path .. "Request",
  Result = path .. "Result"
}

proto = "H"
path = package .. subpackage .. proto .. "."
module.datasource[proto] = {
  Request = path .. "Request",
  Result = path .. "Result"
}

proto = "L"
path = package .. subpackage .. proto .. "."
module.datasource[proto] = {
  Request = path .. "Request",
  Result = path .. "Result"
}

proto = "C"
path = package .. subpackage .. proto .. "."
module.datasource[proto] = {
  Request = path .. "Request",
  Result = path .. "Result"
}

proto = "V"
path = package .. subpackage .. proto .. "."
module.datasource[proto] = {
  Request = path .. "Request",
  Result = path .. "Result"
}

proto = "T"
path = package .. subpackage .. proto .. "."
module.datasource[proto] = {
  Request = path .. "Request",
  Result = path .. "Result"
}

proto = "Size"
path = package .. subpackage .. proto .. "."
module.datasource[proto] = {
  Request = path .. "Request",
  Result = path .. "Result"
}

proto = "Close"
path = package .. subpackage .. proto .. "."
module.datasource[proto] = {
  Request = path .. "Request",
  Result = path .. "Result"
}

proto = "SetEmptyCallback"
path = package .. subpackage .. proto .. "."
module.datasource[proto] = {
  Request = path .. "Request",
  Result = path .. "Result"
}

proto = "sendTransaction"
path = package .. proto .. "."
module[proto] = {
  Request = path .. "Request",
  Result = path .. "Result"
}

proto = "CalcBuySell"
path = package .. proto .. "."
module[proto] = {
  Request = path .. "Request",
  Result = path .. "Result"
}

proto = "getParamEx"
path = package .. proto .. "."
module[proto] = {
  Request = path .. "Request",
  Result = path .. "Result",
  ParamEx = path .. "ParamEx"
}

proto = "getParamEx2"
path = package .. proto .. "."
module[proto] = {
  Request = path .. "Request",
  Result = path .. "Result",
  ParamEx2 = path .. "ParamEx2"
}

proto = "getPortfolioInfo"
path = package .. proto .. "."
module[proto] = {
  Request = path .. "Request",
  Result = path .. "Result",
  PortfolioInfo = path .. "PortfolioInfo"
}

proto = "getPortfolioInfoEx"
path = package .. proto .. "."
module[proto] = {
  Request = path .. "Request",
  Result = path .. "Result",
  PortfolioInfoEx = path .. "PortfolioInfoEx"
}

proto = "getBuySellInfo"
path = package .. proto .. "."
module[proto] = {
  Request = path .. "Request",
  Result = path .. "Result",
  BuySellInfo = path .. "BuySellInfo"
}

proto = "getBuySellInfoEx"
path = package .. proto .. "."
module[proto] = {
  Request = path .. "Request",
  Result = path .. "Result",
  BuySellInfoEx = path .. "BuySellInfoEx"
}

proto = "AddColumn"
path = package .. proto .. "."
module[proto] = {
  Request = path .. "Request",
  Result = path .. "Result"
}

proto = "AllocTable"
path = package .. proto .. "."
module[proto] = {
  Request = path .. "Request",
  Result = path .. "Result"
}

proto = "Clear"
path = package .. proto .. "."
module[proto] = {
  Request = path .. "Request",
  Result = path .. "Result"
}

proto = "CreateWindow"
path = package .. proto .. "."
module[proto] = {
  Request = path .. "Request",
  Result = path .. "Result"
}

proto = "DeleteRow"
path = package .. proto .. "."
module[proto] = {
  Request = path .. "Request",
  Result = path .. "Result"
}

path = ".qlua.structs."
module.qlua_structures = {
  Klass = path .. "Klass",
  Order = path .. "Order",
  MoneyLimit = path .. "MoneyLimit", 
  DepoLimit = path .. "DepoLimit", 
  FuturesLimit = path .. "FuturesLimit", 
  FuturesClientHolding = path .. "FuturesClientHolding", 
  Security = path .. "Security", 
  CandleEntry = path .. "CandleEntry"
}

return module
