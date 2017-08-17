local qlua_rpc = require("qlua/proto/qlua_rpc_pb")

local zmq = require("lzmq.ffi")

local inspect = require("inspect")
assert(inspect ~= nil, "inspect lib is missing.")

local ctx = zmq.context()

local Client = {
  
  socket = ctx:socket(zmq.REQ)
}

function Client:init(socket_addr)
  
  self.socket:connect(socket_addr)
end

function Client:start()
    
  local request = qlua_rpc.Qlua_Request()
  request.type = qlua_rpc.GET_QUOTE_LEVEL2

  local args = qlua_rpc.GetQuoteLevel2_Request()
  --args.client_code = "55654"
  --args.firmid = "MC0094600000"
  args.class_code = "SPBFUT"
  args.sec_code = "RIU7"
  --args.trdaccid = "L01-00000F00"
  --args.tag = "EQTV"
  --args.currcode = "SUR"
  --args.limit_kind = 1
  
  local ser_args = args:SerializeToString()
  request.args = ser_args
  
  local ser_request = request:SerializeToString()

  --print("Raw request data: "..ser_request.."\n")

  self.socket:send(ser_request)

  local msg = self.socket:recv()

  local response = qlua_rpc.Qlua_Response()
  response:ParseFromString(msg)
  if response.type == qlua_rpc.IS_CONNECTED then
    local result = qlua_rpc.IsConnected_Result()
    result:ParseFromString(response.result)
    print( string.format("Received a reply [isConnected: %s]\n", result.is_connected) )
  elseif response.type == qlua_rpc.GET_SCRIPT_PATH then
    local result = qlua_rpc.GetScriptPath_Result()
    result:ParseFromString(response.result)
    print( string.format("Received a reply [scriptPath: %s]\n", result.script_path) )
  elseif response.type == qlua_rpc.GET_INFO_PARAM then
    local result = qlua_rpc.GetInfoParam_Result()
    result:ParseFromString(response.result)
    print( string.format("Received a reply [infoParam: %s]\n", result.info_param) )
  elseif response.type == qlua_rpc.MESSAGE then
    local result = qlua_rpc.Message_Result()
    result:ParseFromString(response.result)
    print( string.format("Received a reply [result: %s]\n", result.result) )
  elseif response.type == qlua_rpc.SLEEP then
    local result = qlua_rpc.Sleep_Result()
    result:ParseFromString(response.result)
    print( string.format("Received a reply [result: %s]\n", result.result) )
  elseif response.type == qlua_rpc.GET_WORKING_FOLDER then
    local result = qlua_rpc.GetWorkingFolder_Result()
    result:ParseFromString(response.result)
    print( string.format("Received a reply [working_folder: %s]\n", result.working_folder) )
  elseif response.type == qlua_rpc.GET_ITEM then
    local result = qlua_rpc.GetItem_Result()
    result:ParseFromString(response.result)
    for i, e in ipairs(result.table_row) do
        print( string.format("Received a reply [table_row: key=%s, value=%s]\n", e.k, e.v) )
    end
  elseif response.type == qlua_rpc.GET_CLASSES_LIST then
    local result = qlua_rpc.GetClassesList_Result()
    result:ParseFromString(response.result)
    print( string.format("Received a reply [classes_list: %s]\n", result.classes_list) )
  elseif response.type == qlua_rpc.GET_CLASS_INFO then
    local result = qlua_rpc.GetClassInfo_Result()
    result:ParseFromString(response.result)
    for i, e in ipairs(result.class_info) do
        print( string.format("Received a reply [table_row: key=%s, value=%s]\n", e.k, e.v) )
    end
  elseif response.type == qlua_rpc.GET_CLASS_SECURITIES then
    local result = qlua_rpc.GetClassSecurities_Result()
    result:ParseFromString(response.result)
    print( string.format("Received a reply [class_securities: %s]\n", result.class_securities) )
  elseif response.type == qlua_rpc.GET_MONEY then
    local result = qlua_rpc.GetMoney_Result()
    result:ParseFromString(response.result)
    for i, e in ipairs(result.money) do
        print( string.format("Received a reply [table_row: key=%s, value=%s]\n", e.k, e.v) )
    end
  elseif response.type == qlua_rpc.GET_MONEY_EX then
    local result = qlua_rpc.GetMoneyEx_Result()
    result:ParseFromString(response.result)
    for i, e in ipairs(result.money_ex) do
        print( string.format("Received a reply [table_row: key=%s, value=%s]\n", e.k, e.v) )
    end
  elseif response.type == qlua_rpc.GET_DEPO then
    local result = qlua_rpc.GetDepo_Result()
    result:ParseFromString(response.result)
    for i, e in ipairs(result.depo) do
        print( string.format("Received a reply [table_row: key=%s, value=%s]\n", e.k, e.v) )
    end
  elseif response.type == qlua_rpc.GET_DEPO_EX then
    local result = qlua_rpc.GetDepoEx_Result()
    result:ParseFromString(response.result)
    for i, e in ipairs(result.depo_ex) do
        print( string.format("Received a reply [table_row: key=%s, value=%s]\n", e.k, e.v) )
    end
  elseif response.type == qlua_rpc.GET_QUOTE_LEVEL2 then
    local result = qlua_rpc.GetQuoteLevel2_Result()
    result:ParseFromString(response.result)
    print( string.format("Received a reply [bid_count: %s, offer_count: %s]\n", result.bid_count, result.offer_count) )
    for i, e in ipairs(result.bid) do
        print( string.format("Received a reply on bid [bid: price=%s, quantity=%s]\n", e.price, e.quantity) )
    end
    for i, e in ipairs(result.offer) do
        print( string.format("Received a reply on offer [offer: price=%s, quantity=%s]\n", e.price, e.quantity) )
    end
  end

  print ("closing...\n")
  self.socket:close()
  ctx:term()
end

local instance = Client;
instance:init("tcp://127.0.0.1:5559")
instance:start()