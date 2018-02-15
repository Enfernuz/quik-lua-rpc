local service

-----
OnInit = function(script_path)
  service = require(script_path.."/service.lua")
  service.init(script_path)
  OnInit = service.event_callbacks.OnInit or service.terminate
end

OnClose = service.event_callbacks.OnClose or service.terminate
OnStop = service.event_callbacks.OnStop or service.terminate

OnConnected = service.event_callbacks.OnConnected
OnDisconnected = service.event_callbacks.OnDisconnected
OnCleanUp = service.event_callbacks.OnCleanUp

OnFirm = service.event_callbacks.OnFirm
OnAllTrade = service.event_callbacks.OnAllTrade
OnTrade = service.event_callbacks.OnTrade
OnOrder = service.event_callbacks.OnOrder
OnAccountBalance = service.event_callbacks.OnAccountBalance
OnFuturesLimitChange = service.event_callbacks.OnFuturesLimitChange
OnFuturesLimitDelete = service.event_callbacks.OnFuturesLimitDelete
OnFuturesClientHolding = service.event_callbacks.OnFuturesClientHolding
OnMoneyLimit = service.event_callbacks.OnMoneyLimit
OnMoneyLimitDelete = service.event_callbacks.OnMoneyLimitDelete
OnDepoLimit = service.event_callbacks.OnDepoLimit
OnDepoLimitDelete = service.event_callbacks.OnDepoLimitDelete
OnAccountPosition = service.event_callbacks.OnAccountPosition
OnNegDeal = service.event_callbacks.OnNegDeal
OnNegTrade = service.event_callbacks.OnNegTrade
OnStopOrder = service.event_callbacks.OnStopOrder
OnTransReply = service.event_callbacks.OnTransReply
OnParam = service.event_callbacks.OnParam
OnQuote = service.event_callbacks.OnQuote

-----

function main()
  message("KEKS")
  service.start()
end
