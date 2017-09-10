local qlua_msg = require("qlua/proto/qlua_msg_pb")

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
    
  local request = qlua_msg.Qlua_Request()
  
  request.token = 12345;
  request.type = qlua_msg.ProcedureType.SET_TABLE_NOTIFICATION_CALLBACK

  local args = qlua_msg.SetTableNotificationCallback_Request()
  --args.red = 0
  --args.green = 255
  --args.blue = 255
  args.t_id = 1
  args.f_cb_def = "function (t_id, msg, par1, par2) message('client_callback: '..t_id..'; '..msg..'; '..par1..'; '..par2) end"
  --args.table_id = 2
  --args.row = 2
  --args.col = -1
  --args.b_color = 0x00ffff
  --args.f_color = 0x000000 -- BGR
  --args.sel_b_color = 0xffffff
  --args.sel_f_color = 0x000000
  --args.timeout = 5000
  --args.str = "test caption"
  --args.key = 1
  --args.code = 1
  --args.text = "77"
  --args.value = "88"
  --args.icode = 0
  --args.name = "qoka"
  --args.is_default = false
  --args.par_type = qlua_msg.ColumnParameterType.QTABLE_STRING_TYPE
  --args.width = 15
  --args.firm_id = "MC0094600000"
  --args.client_code = "55654"
  --args.class_code = "SPBXM"
  --args.sec_code = "AMZN"
  --args.price = 930
  --args.param_name = "PREVPRICE"
  --args.table_name = "securities"
  --args.index = 1
  --args.client_code = "55654"

  --args.firmid = "SPBFUT"
  --args.tag = "1"
  --args.class_code = "SPBFUT"
  --args.sec_code = "RIU7"
  --args.trdaccid = "L01-00000F00"
  --args.trdaccid = "15002ed"
  --args.tag = "EQTV"
  --args.currcode = "SUR"
  --args.currcode = ""
  --args.limit_kind = 1
  --args.limit_type = 0
  --args.tag = "envel"
  --args.line = 0
  --args.first_candle = 100
  --args.count = 5
  
  --[[
  local t = {}
  t.account = "test"
  
  for k,v in pairs(t) do
      local trans = qlua_msg.SendTransaction_Request.TransactionEntry()
      trans.key = tostring(k)
      trans.value = tostring(v)
      table.insert(args.transaction, trans)
  end
  --]]
  
  local ser_args = args:SerializeToString()
  request.args = ser_args

  local ser_request = request:SerializeToString()

  --print("Raw request data: "..ser_request.."\n")

  self.socket:send(ser_request)

  local msg = self.socket:recv()

  local response = qlua_msg.Qlua_Response()
  response:ParseFromString(msg)
  print( string.format("response token: %d", response.token) )
  
  if response.is_error then print("Error: "..tostring(response.result)) end
  
  if response.type == qlua_msg.ProcedureType.IS_CONNECTED then
    local result = qlua_msg.IsConnected_Result()
    result:ParseFromString(response.result)
    print( string.format("Received a reply [isConnected: %s]\n", result.is_connected) )
  elseif response.type == qlua_msg.ProcedureType.GET_SCRIPT_PATH then
    local result = qlua_msg.GetScriptPath_Result()
    result:ParseFromString(response.result)
    print( string.format("Received a reply [scriptPath: %s]\n", result.script_path) )
  elseif response.type == qlua_msg.ProcedureType.GET_INFO_PARAM then
    local result = qlua_msg.GetInfoParam_Result()
    result:ParseFromString(response.result)
    print( string.format("Received a reply [infoParam: %s]\n", result.info_param) )
  elseif response.type == qlua_msg.ProcedureType.MESSAGE then
    local result = qlua_msg.Message_Result()
    result:ParseFromString(response.result)
    print( string.format("Received a reply [result: %s]\n", result.result) )
  elseif response.type == qlua_msg.ProcedureType.SLEEP then
    local result = qlua_msg.Sleep_Result()
    result:ParseFromString(response.result)
    print( string.format("Received a reply [result: %s]\n", result.result) )
  elseif response.type == qlua_msg.ProcedureType.GET_WORKING_FOLDER then
    local result = qlua_msg.GetWorkingFolder_Result()
    result:ParseFromString(response.result)
    print( string.format("Received a reply [working_folder: %s]\n", result.working_folder) )
  elseif response.type == qlua_msg.ProcedureType.GET_ITEM then
    local result = qlua_msg.GetItem_Result()
    result:ParseFromString(response.result)
    for i, e in ipairs(result.table_row) do
        print( string.format("Received a reply [table_row: key=%s, value=%s]\n", e.key, e.value) )
    end
  elseif response.type == qlua_msg.ProcedureType.GET_CLASSES_LIST then
    local result = qlua_msg.GetClassesList_Result()
    result:ParseFromString(response.result)
    print( string.format("Received a reply [classes_list: %s]\n", result.classes_list) )
  elseif response.type == qlua_msg.ProcedureType.GET_CLASS_INFO then
    local result = qlua_msg.GetClassInfo_Result()
    result:ParseFromString(response.result)
    for i, e in ipairs(result.class_info) do
        print( string.format("Received a reply [table_row: key=%s, value=%s]\n", e.key, e.value) )
    end
  elseif response.type == qlua_msg.ProcedureType.GET_CLASS_SECURITIES then
    local result = qlua_msg.GetClassSecurities_Result()
    result:ParseFromString(response.result)
    print( string.format("Received a reply [class_securities: %s]\n", result.class_securities) )
  elseif response.type == qlua_msg.ProcedureType.GET_MONEY then
    local result = qlua_msg.GetMoney_Result()
    result:ParseFromString(response.result)
    for i, e in ipairs(result.money) do
        print( string.format("Received a reply [table_row: key=%s, value=%s]\n", e.key, e.value) )
    end
  elseif response.type == qlua_msg.ProcedureType.GET_MONEY_EX then
    local result = qlua_msg.GetMoneyEx_Result()
    result:ParseFromString(response.result)
    for i, e in ipairs(result.money_ex) do
        print( string.format("Received a reply [table_row: key=%s, value=%s]\n", e.key, e.value) )
    end
  elseif response.type == qlua_msg.ProcedureType.GET_DEPO then
    local result = qlua_msg.GetDepo_Result()
    result:ParseFromString(response.result)
    for i, e in ipairs(result.depo) do
        print( string.format("Received a reply [table_row: key=%s, value=%s]\n", e.key, e.value) )
    end
  elseif response.type == qlua_msg.ProcedureType.GET_DEPO_EX then
    local result = qlua_msg.GetDepoEx_Result()
    result:ParseFromString(response.result)
    for i, e in ipairs(result.depo_ex) do
        print( string.format("Received a reply [table_row: key=%s, value=%s]\n", e.key, e.value) )
    end
  elseif response.type == qlua_msg.ProcedureType.GET_FUTURES_LIMIT then
    local result = qlua_msg.GetFuturesLimit_Result()
    result:ParseFromString(response.result)
    for i, e in ipairs(result.futures_limit) do
        print( string.format("Received a reply [table_row: key=%s, value=%s]\n", e.key, e.value) )
    end
  elseif response.type == qlua_msg.ProcedureType.GET_FUTURES_HOLDING then
    local result = qlua_msg.GetFuturesHolding_Result()
    result:ParseFromString(response.result)
    for i, e in ipairs(result.futures_holding) do
        print( string.format("Received a reply [table_row: key=%s, value=%s]\n", e.key, e.value) )
    end
  elseif response.type == qlua_msg.ProcedureType.GET_SECURITY_INFO then
    local result = qlua_msg.GetSecurityInfo_Result()
    result:ParseFromString(response.result)
    for i, e in ipairs(result.security_info) do
        print( string.format("Received a reply [table_row: key=%s, value=%s]\n", e.key, e.value) )
    end
  elseif response.type == qlua_msg.ProcedureType.GET_TRADE_DATE then
    local result = qlua_msg.GetTradeDate_Result()
    result:ParseFromString(response.result)
    for i, e in ipairs(result.trade_date) do
        print( string.format("Received a reply [table_row: key=%s, value=%s]\n", e.key, e.value) )
    end
  elseif response.type == qlua_msg.ProcedureType.GET_QUOTE_LEVEL2 then
    local result = qlua_msg.GetQuoteLevel2_Result()
    result:ParseFromString(response.result)
    print( string.format("Received a reply [bid_count: %s, offer_count: %s]\n", result.bid_count, result.offer_count) )
    for i, e in ipairs(result.bid) do
        print( string.format("Received a reply on bid [bid: price=%s, quantity=%s]\n", e.price, e.quantity) )
    end
    for i, e in ipairs(result.offer) do
        print( string.format("Received a reply on offer [offer: price=%s, quantity=%s]\n", e.price, e.quantity) )
    end
  elseif response.type == qlua_msg.ProcedureType.GET_LINES_COUNT then
    local result = qlua_msg.GetLinesCount_Result()
    result:ParseFromString(response.result)
    print( string.format("Received a reply [lines_count: %s]\n", result.lines_count) )
  elseif response.type == qlua_msg.ProcedureType.GET_NUM_CANDLES then
    local result = qlua_msg.GetNumCandles_Result()
    result:ParseFromString(response.result)
    print( string.format("Received a reply [num_candles: %s]\n", result.num_candles) )
  elseif response.type == qlua_msg.ProcedureType.GET_CANDLES_BY_INDEX then
    local result = qlua_msg.GetCandlesByIndex_Result()
    result:ParseFromString(response.result)
    print( string.format("Received a reply [n: %s, l: %s]\n", result.n, result.l) )
    for i, e in ipairs(result.t) do
        print( string.format("Received a reply on candle #%d [open=%s, close=%s, high=%s, low=%s, volume=%s, does_exist=%d]\n", i, e.open, e.close, e.high, e.low, e.volume, e.does_exist) )
        print( string.format("datetime: [mcs=%s, ms=%s, sec=%d, min=%d, hour=%d, day=%d, week_day=%d, month=%d, year=%d]\n", e.datetime.mcs, e.datetime.ms, e.datetime.sec, e.datetime.min, e.datetime.hour, e.datetime.day, e.datetime.week_day, e.datetime.month, e.datetime.year) )
        print("-----")
    end
  elseif response.type == qlua_msg.ProcedureType.SEND_TRANSACTION then
    local result = qlua_msg.SendTransaction_Result()
    result:ParseFromString(response.result)
    print( string.format("Received a reply [transaction_result: %s]\n", result.result) )
  elseif response.type == qlua_msg.ProcedureType.CALC_BUY_SELL then
    local result = qlua_msg.CalcBuySell_Result()
    result:ParseFromString(response.result)
    print( string.format("Received a reply [calc_buy_sell result: qty=%d, comission=%d]\n", result.qty, result.comission) )
  elseif response.type == qlua_msg.ProcedureType.GET_PARAM_EX then
    local result = qlua_msg.GetParamEx_Result()
    result:ParseFromString(response.result)
    for i, e in ipairs(result.param_ex) do
        print( string.format("Received a reply [param_ex: key=%s, value=%s]\n", e.key, e.value) )
    end
  elseif response.type == qlua_msg.ProcedureType.GET_PARAM_EX_2 then
    local result = qlua_msg.GetParamEx_Result()
    result:ParseFromString(response.result)
    for i, e in ipairs(result.param_ex) do
        print( string.format("Received a reply [param_ex_2: key=%s, value=%s]\n", e.key, e.value) )
    end
  elseif response.type == qlua_msg.ProcedureType.GET_PORTFOLIO_INFO then
    local result = qlua_msg.GetPortfolioInfo_Result()
    result:ParseFromString(response.result)
    for i, e in ipairs(result.portfolio_info) do
        print( string.format("Received a reply [portfolio_info: key=%s, value=%s]\n", e.key, e.value) )
    end
  elseif response.type == qlua_msg.ProcedureType.GET_PORTFOLIO_INFO_EX then
    local result = qlua_msg.GetPortfolioInfoEx_Result()
    result:ParseFromString(response.result)
    for i, e in ipairs(result.portfolio_info_ex) do
        print( string.format("Received a reply [portfolio_info_ex: key=%s, value=%s]\n", e.key, e.value) )
    end
  elseif response.type == qlua_msg.ProcedureType.GET_BUY_SELL_INFO or response.type == qlua_msg.ProcedureType.GET_BUY_SELL_INFO_EX then
    local result = qlua_msg.GetBuySellInfo_Result()
    result:ParseFromString(response.result)
    for i, e in ipairs(result.buy_sell_info) do
        print( string.format("Received a reply [buy_sell_info: key=%s, value=%s]\n", e.key, e.value) )
    end
  elseif response.type == qlua_msg.ProcedureType.ADD_COLUMN then
    local result = qlua_msg.AddColumn_Result()
    result:ParseFromString(response.result)
    print( string.format("Received a reply [add_column: result=%d]\n", result.result) )
  elseif response.type == qlua_msg.ProcedureType.ALLOC_TABLE then
    local result = qlua_msg.AllocTable_Result()
    result:ParseFromString(response.result)
    print( string.format("Received a reply [alloc_table: t_id=%d]\n", result.t_id) )
  elseif response.type == qlua_msg.ProcedureType.CLEAR then
    local result = qlua_msg.Clear_Result()
    result:ParseFromString(response.result)
    print( string.format("Received a reply [clear: result=%s]\n", result.result) )
  elseif response.type == qlua_msg.ProcedureType.CREATE_WINDOW then
    local result = qlua_msg.CreateWindow_Result()
    result:ParseFromString(response.result)
    print( string.format("Received a reply [create_window: result=%d]\n", result.result) )
  elseif response.type == qlua_msg.ProcedureType.DELETE_ROW then
    local result = qlua_msg.DeleteRow_Result()
    result:ParseFromString(response.result)
    print( string.format("Received a reply [delete_row: result=%s]\n", result.result) )
  elseif response.type == qlua_msg.ProcedureType.DESTROY_TABLE then
    local result = qlua_msg.DestroyTable_Result()
    result:ParseFromString(response.result)
    print( string.format("Received a reply [destroy_table: result=%s]\n", result.result) )
  elseif response.type == qlua_msg.ProcedureType.INSERT_ROW then
    local result = qlua_msg.InsertRow_Result()
    result:ParseFromString(response.result)
    print( string.format("Received a reply [insert_row: result=%d]\n", result.result) )
  elseif response.type == qlua_msg.ProcedureType.IS_WINDOW_CLOSED then
    local result = qlua_msg.IsWindowClosed_Result()
    result:ParseFromString(response.result)
    print( string.format("Received a reply [is_window_closed: result=%s]\n", result.result) )
  elseif response.type == qlua_msg.ProcedureType.GET_CELL then
    local result = qlua_msg.GetCell_Result()
    result:ParseFromString(response.result)
    print( string.format("Received a reply [get_cell: image=%s, value=%s]\n", result.image, result.value == "" and "nil" or result.value) )
  elseif response.type == qlua_msg.ProcedureType.SET_CELL then
    local result = qlua_msg.SetCell_Result()
    result:ParseFromString(response.result)
    print( string.format("Received a reply [set_cell: result=%s]\n", result.result) )
  elseif response.type == qlua_msg.ProcedureType.SET_WINDOW_CAPTION then
    local result = qlua_msg.SetWindowCaption_Result()
    result:ParseFromString(response.result)
    print( string.format("Received a reply [set_window_caption: result=%s]\n", result.result) )
  elseif response.type == qlua_msg.ProcedureType.SET_WINDOW_POS then
    local result = qlua_msg.SetWindowPos_Result()
    result:ParseFromString(response.result)
    print( string.format("Received a reply [set_window_pos: result=%s]\n", result.result) )
  elseif response.type == qlua_msg.ProcedureType.SET_TABLE_NOTIFICATION_CALLBACK then
    local result = qlua_msg.SetTableNotificationCallback_Result()
    result:ParseFromString(response.result)
    print( string.format("Received a reply [set_table_notification_callback: result=%s]\n", result.result) )
  elseif response.type == qlua_msg.ProcedureType.GET_TABLE_SIZE then
    local result = qlua_msg.GetTableSize_Result()
    result:ParseFromString(response.result)
    print( string.format("Received a reply [get_table_size: rows=%d, col=%d]\n", result.rows, result.col) )
  elseif response.type == qlua_msg.ProcedureType.GET_WINDOW_CAPTION then
    local result = qlua_msg.GetWindowCaption_Result()
    result:ParseFromString(response.result)
    print( string.format("Received a reply [get_window_caption: caption=%s]\n", result.caption) )
  elseif response.type == qlua_msg.ProcedureType.SET_COLOR then
    local result = qlua_msg.SetColor_Result()
    result:ParseFromString(response.result)
    print( string.format("Received a reply [set_color: result=%s]\n", result.result) )
  elseif response.type == qlua_msg.ProcedureType.GET_WINDOW_RECT then
    local result = qlua_msg.GetWindowRect_Result()
    result:ParseFromString(response.result)
    print( string.format("Received a reply [get_window_rect: top=%d, left=%d, bottom=%d, right=%d]\n", result.top, result.left, result.bottom, result.right) )
  elseif response.type == qlua_msg.ProcedureType.RGB then
    local result = qlua_msg.RGB_Result()
    result:ParseFromString(response.result)
    print( string.format("Received a reply [rgb: result=%s]\n", result.result) )
  elseif response.type == qlua_msg.ProcedureType.HIGHLIGHT then
    local result = qlua_msg.Highlight_Result()
    result:ParseFromString(response.result)
    print( string.format("Received a reply [highlight: result=%s]\n", result.result) )
  elseif response.type == qlua_msg.ProcedureType.SET_SELECTED_ROW then
    local result = qlua_msg.SetSelectedRow_Result()
    result:ParseFromString(response.result)
    print( string.format("Received a reply [set_selected_row: result=%s]\n", result.result) )
  end

  print ("closing...\n")
  self.socket:close()
  ctx:term()
end

local instance = Client;
instance:init("tcp://127.0.0.1:5559")
instance:start()
