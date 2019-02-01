package.path = "../?.lua;" .. package.path

local EventDataSerializer = {}

function EventDataSerializer:new ()

  -- "Object Oriented" Lua examples: https://habr.com/post/259265/
  local public = {}
  
  -- return event_key, event_data
  
  function EventDataSerializer:OnClose ()
    return nil, nil
  end
  
  function EventDataSerializer:PublisherOnline ()
    return nil, nil
  end
  
  function EventDataSerializer:PublisherOffline (signal)
    return nil, nil
  end
  
  function EventDataSerializer:OnFirm (firm)
    return nil, nil
  end
  
  function EventDataSerializer:OnAllTrade (alltrade)
    return nil, nil
  end
  
  function EventDataSerializer:OnTrade (trade)
    return nil, nil
  end
  
  function EventDataSerializer:OnOrder (order)
    return nil, nil
  end
  
  function EventDataSerializer:OnAccountBalance (acc_bal)
    return nil, nil
  end
  
  function EventDataSerializer:OnFuturesLimitChange (fut_limit)
    return nil, nil
  end
  
  function EventDataSerializer:OnFuturesLimitDelete (lim_del)
    return nil, nil
  end
  
  function EventDataSerializer:OnFuturesClientHolding (fut_pos)
    return nil, nil
  end
  
  function EventDataSerializer:OnMoneyLimit (mlimit)
    return nil, nil
  end
  
  function EventDataSerializer:OnMoneyLimitDelete (mlimit_del)
    return nil, nil
  end
  
  function EventDataSerializer:OnDepoLimit (dlimit)
    return nil, nil
  end
  
  function EventDataSerializer:OnDepoLimitDelete (dlimit_del)
    return nil, nil
  end
  
  function EventDataSerializer:OnAccountPosition (acc_pos)
    return nil, nil
  end
  
  function EventDataSerializer:OnNegDeal (neg_deal)
    return nil, nil
  end
  
  function EventDataSerializer:OnNegTrade (neg_trade)
    return nil, nil
  end
  
  function EventDataSerializer:OnStopOrder (stop_order)
    return nil, nil
  end
  
  function EventDataSerializer:OnTransReply (trans_reply)
    return nil, nil
  end
  
  function EventDataSerializer:OnParam (class_code, sec_code)
    return nil, nil
  end
  
  function EventDataSerializer:OnQuote (class_code, sec_code)
    return nil, nil
  end
  
  function EventDataSerializer:OnDisconnected ()
    return nil, nil
  end
  
  function EventDataSerializer:OnConnected (flag)
    return nil, nil
  end
  
  function EventDataSerializer:OnCleanUp ()
    return nil, nil
  end
  
  function EventDataSerializer:OnDataSourceUpdate (update_info)
    return nil, nil
  end

  setmetatable(public, self)
  self.__index = self
  
  return public
end

return EventDataSerializer
