local zmq = require("lzmq.ffi")
local zmq_poller = require("lzmq.ffi.poller")

local ctx = zmq.context()

local RequestReplyBroker = {
  
  frontend = ctx:socket(zmq.ROUTER), 
  backend = ctx:socket(zmq.DEALER), 
  
  poller = zmq_poller.new(2), 
}

function RequestReplyBroker:init(frontend_addr, backend_addr)
  
  self.frontend:bind(frontend_addr)
  self.backend:bind(backend_addr)
  
  zmq.device(zmq.QUEUE, self.frontend, self.backend)
end

function RequestReplyBroker:start()
  
  self.poller:start()
end

function RequestReplyBroker:close()

  self.frontend:close()
  self.backend:close()
  
  ctx:term()
end

local instance = RequestReplyBroker;
instance:init("tcp://127.0.0.1:5559", "tcp://127.0.0.1:5560")
instance:start()
instance:close()