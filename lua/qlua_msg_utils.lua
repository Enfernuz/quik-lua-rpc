local qlua_msg = require("qlua/proto/qlua_msg_pb")
assert(qlua_msg ~= nil, "qlua/proto/qlua_msg_pb lib is missing")

local utils = {}

function utils.insert_table(src, dst)
  
  for k,v in pairs(src) do
      local table_entry = qlua_msg.TableEntry() 
      table_entry.k = tostring(k)
      table_entry.v = tostring(v)
      table.sinsert(dst, table_entry)
  end
end

function utils.insert_quote_table(src, dst)
  
  for i,v in ipairs(src) do
      local quote = qlua_msg.GetQuoteLevel2_Result.QuoteEntry() 
      quote.price = tostring(v.price)
      quote.quantity = tostring(v.quantity)
      table.sinsert(dst, quote)
  end
end

function utils.copy_datetime(dst, src)
  
  dst.mcs = tostring(src.mcs)
  dst.ms = tostring(src.ms)
  dst.sec = src.sec
  dst.min = src.min
  dst.hour = src.hour
  dst.day = src.day
  dst.week_day = src.week_day
  dst.month = src.month
  dst.year = src.year
end

function utils.create_table(pb_map)
  
  local t = {}
  for i,e in ipairs(pb_map) do
    t[e.key] = e.value
  end
  
  return t
end

function utils.put_to_string_string_pb_map(t, pb_map, pb_map_entry_ctr)
  
  for k,v in pairs(t) do
    local entry = pb_map_entry_ctr()
    entry.key = tostring(k)
    entry.value = tostring(v)
    table.sinsert(pb_map, entry)
  end
end

function utils.insert_candles_table(src, dst)
  
  for i,v in ipairs(src) do
      local candle = qlua_msg.CandleEntry() 
      candle.open = tostring(v.open)
      candle.close = tostring(v.close)
      candle.high = tostring(v.high)
      candle.low = tostring(v.low)
      candle.volume = tostring(v.volume)
      candle.does_exist = v.doesExist
      utils.copy_datetime(candle.datetime, v.datetime)
      table.sinsert(dst, candle)
  end
end

function utils.sleep(s)
  local ntime = os.clock() + s
  repeat until os.clock() > ntime
end

local qtable_parameter_types = {}
qtable_parameter_types[qlua_msg.ColumnParameterType.QTABLE_INT_TYPE] = QTABLE_INT_TYPE
qtable_parameter_types[qlua_msg.ColumnParameterType.QTABLE_DOUBLE_TYPE] = QTABLE_DOUBLE_TYPE
qtable_parameter_types[qlua_msg.ColumnParameterType.QTABLE_INT64_TYPE] = QTABLE_INT64_TYPE
qtable_parameter_types[qlua_msg.ColumnParameterType.QTABLE_CACHED_STRING_TYPE] = QTABLE_CACHED_STRING_TYPE
qtable_parameter_types[qlua_msg.ColumnParameterType.QTABLE_TIME_TYPE] = QTABLE_TIME_TYPE
qtable_parameter_types[qlua_msg.ColumnParameterType.QTABLE_DATE_TYPE] = QTABLE_DATE_TYPE
qtable_parameter_types[qlua_msg.ColumnParameterType.QTABLE_STRING_TYPE] = QTABLE_STRING_TYPE

function utils.to_qtable_parameter_type(pb_column_parameter_type)
  
  local par_type = qtable_parameter_types[pb_column_parameter_type]
  if par_type == nil then error("Unknown column parameter type.") end
  
  return par_type
end

local interval_types = {}
interval_types[qlua_msg.Interval.INTERVAL_TICK] = INTERVAL_TICK
interval_types[qlua_msg.Interval.INTERVAL_M1] = INTERVAL_M1
interval_types[qlua_msg.Interval.INTERVAL_M2] = INTERVAL_M2
interval_types[qlua_msg.Interval.INTERVAL_M3] = INTERVAL_M3
interval_types[qlua_msg.Interval.INTERVAL_M4] = INTERVAL_M4
interval_types[qlua_msg.Interval.INTERVAL_M5] = INTERVAL_M5
interval_types[qlua_msg.Interval.INTERVAL_M6] = INTERVAL_M6
interval_types[qlua_msg.Interval.INTERVAL_M10] = INTERVAL_M10
interval_types[qlua_msg.Interval.INTERVAL_M15] = INTERVAL_M15
interval_types[qlua_msg.Interval.INTERVAL_M20] = INTERVAL_M20
interval_types[qlua_msg.Interval.INTERVAL_M30] = INTERVAL_M30
interval_types[qlua_msg.Interval.INTERVAL_H1] = INTERVAL_H1
interval_types[qlua_msg.Interval.INTERVAL_H2] = INTERVAL_H2
interval_types[qlua_msg.Interval.INTERVAL_H4] = INTERVAL_H4
interval_types[qlua_msg.Interval.INTERVAL_D1] = INTERVAL_D1
interval_types[qlua_msg.Interval.INTERVAL_W1] = INTERVAL_W1
interval_types[qlua_msg.Interval.INTERVAL_MN1] = INTERVAL_MN1

function utils.to_interval(pb_interval)

  local interval = interval_types[pb_interval]
  if interval == nil then error("Unknown interval type.") end

  return interval
end

return utils