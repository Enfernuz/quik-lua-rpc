package.path = "../?.lua;" .. package.path

local qlua = require("qlua.api")
local qlua_structs = require("qlua.rpc.qlua_structures_pb")
local utils = require("utils.utils")

local table = require("table")

local assert = assert
local tostring = assert(tostring)
local error = assert(error)

local value_to_string_or_empty_string = assert(utils.value_to_string_or_empty_string)
local value_or_empty_string = assert(utils.value_or_empty_string)

local StructConverter = {
  _VERSION = '0.8.0', 
  getMoney = {}, 
  getDepo = {}, 
  getTradeDate = {}, 
  getQuoteLevel2 = {}, 
  getCandlesByIndex = {}, 
  getParamEx = {}, 
  getParamEx2 = {}, 
  getPortfolioInfo = {}, 
  getPortfolioInfoEx = {}
}

local function copy_datetime(src, dst)
  
  -- TO-DO: add "not nil" assertions on the src's fields
  dst.mcs = src.mcs
  dst.ms = src.ms
  dst.sec = src.sec
  dst.min = src.min
  dst.hour = src.hour
  dst.day = src.day
  dst.week_day = src.week_day
  dst.month = src.month
  dst.year = src.year
end

local function insert_quote_table(src, dst)
  
  -- TO-DO: add "not nil" assertions on the quote's fields
  for _, v in ipairs(src) do
      local quote = qlua.getQuoteLevel2.QuoteEntry() 
      quote.price = v.price
      quote.quantity = v.quantity
      table.sinsert(dst, quote)
  end
end

local function insert_candles_table(src, dst)
  
  -- TO-DO: add "not nil" assertions on the candle's fields
  for _, v in ipairs(src) do
    
      local candle = qlua_structs.CandleEntry() 
      candle.open = tostring(v.open)
      candle.close = tostring(v.close)
      candle.high = tostring(v.high)
      candle.low = tostring(v.low)
      candle.volume = tostring(v.volume)
      candle.does_exist = v.doesExist
      copy_datetime(v.datetime, candle.datetime)
      table.sinsert(dst, candle)
  end
end

function StructConverter.getMoney.Money(money, existing_struct)

  if money == nil then error("No 'money' table provided.", 2) end

  local result = (existing_struct == nil and qlua.getMoney.Money() or existing_struct)
  
  result.money_open_limit = value_to_string_or_empty_string(money.money_open_limit)
  result.money_limit_locked_nonmarginal_value = value_to_string_or_empty_string(money.money_limit_locked_nonmarginal_value)
  result.money_limit_locked = value_to_string_or_empty_string(money.money_limit_locked)
  result.money_open_balance = value_to_string_or_empty_string(money.money_open_balance)
  result.money_current_limit = value_to_string_or_empty_string(money.money_current_limit)
  result.money_current_balance = value_to_string_or_empty_string(money.money_current_balance)
  result.money_limit_available = value_to_string_or_empty_string(money.money_limit_available)
  
  return result
end

function StructConverter.getDepo.Depo(depo, existing_struct)
  
  if depo == nil then error("No 'depo' table provided.", 2) end

  local result = (existing_struct == nil and qlua.getDepo.Depo() or existing_struct)
  
  result.depo_limit_locked_buy_value = value_to_string_or_empty_string(depo.depo_limit_locked_buy_value)
  result.depo_current_balance = value_to_string_or_empty_string(depo.depo_current_balance)
  result.depo_limit_locked_buy = value_to_string_or_empty_string(depo.depo_limit_locked_buy)
  result.depo_limit_locked = value_to_string_or_empty_string(depo.depo_limit_locked)
  result.depo_limit_available = value_to_string_or_empty_string(depo.depo_limit_available)
  result.depo_current_limit = value_to_string_or_empty_string(depo.depo_current_limit)
  result.depo_open_balance = value_to_string_or_empty_string(depo.depo_open_balance)
  result.depo_open_limit = value_to_string_or_empty_string(depo.depo_open_limit)
  
  return result
end

function StructConverter.getTradeDate.TradeDate(trade_date, existing_struct)
  
  if trade_date == nil then error("No 'trade_date' table provided.", 2) end

  local result = (existing_struct == nil and qlua.getTradeDate.TradeDate() or existing_struct)
  
  result.date = assert(trade_date.date, "The given 'trade_date' table has no 'date' field.")
  result.year = assert(trade_date.year, "The given 'trade_date' table has no 'year' field.") 
  result.month = assert(trade_date.month, "The given 'trade_date' table has no 'month' field.") 
  result.day = assert(trade_date.day, "The given 'trade_date' table has no 'day' field.") 
  
  return result
end

function StructConverter.getQuoteLevel2.Result(quote_level_2) 
  
  if quote_level_2 == nil then error("No 'quote_level_2' table provided.", 2) end
  
  local result = qlua.getQuoteLevel2.Result()
  
  result.bid_count = assert(quote_level_2.bid_count, "The given 'quote_level_2' table has no 'bid_count' field.")
  result.offer_count = assert(quote_level_2.offer_count, "The given 'quote_level_2' table has no 'offer_count' field.")
  if quote_level_2.bid and quote_level_2.bid ~= "" then insert_quote_table(quote_level_2.bid, result.bids) end
  if quote_level_2.offer and quote_level_2.offer ~= "" then insert_quote_table(quote_level_2.offer, result.offers) end
  
  return result
end

function StructConverter.getCandlesByIndex.Result(t, n, l) 
  
  if type(t) ~= 'table' then error("The 1st argument is not a table.", 2) end
  if type(n) ~= 'number' then error("The 2nd argument is not a number.", 2) end
  if type(l) ~= 'string' then error("The 3rd argument is not a string.", 2) end
  
  local result = qlua.getCandlesByIndex.Result()
  
  insert_candles_table(t, result.t)
  result.n = n
  result.l = l
  
  return result
end

function StructConverter.getParamEx.ParamEx(param_ex, existing_struct)
  
  if param_ex == nil then error("No 'param_ex' table provided.", 2) end

  local result = (existing_struct == nil and qlua.getParamEx.ParamEx() or existing_struct)
  
  result.param_type = value_or_empty_string(param_ex.param_type)
  result.param_value = value_or_empty_string(param_ex.param_value)
  result.param_image = value_or_empty_string(param_ex.param_image)
  result.result = value_or_empty_string(param_ex.result)
  
  return result
end

function StructConverter.getParamEx2.ParamEx2(param_ex, existing_struct)
  
  if param_ex == nil then error("No 'param_ex' table provided.", 2) end

  local result = (existing_struct == nil and qlua.getParamEx2.ParamEx2() or existing_struct)
  
  result.param_type = value_or_empty_string(param_ex.param_type)
  result.param_value = value_or_empty_string(param_ex.param_value)
  result.param_image = value_or_empty_string(param_ex.param_image)
  result.result = value_or_empty_string(param_ex.result)
  
  return result
end

function StructConverter.getPortfolioInfo.PortfolioInfo(portfolio_info, existing_struct)
  
  if portfolio_info == nil then error("No 'portfolio_info' table provided.", 2) end

  local result = (existing_struct == nil and qlua.getPortfolioInfo.PortfolioInfo() or existing_struct)
  
  result.is_leverage = value_or_empty_string(portfolio_info.is_leverage)
  result.in_assets = value_or_empty_string(portfolio_info.in_assets)
  result.leverage = value_or_empty_string(portfolio_info.leverage)
  result.open_limit = value_or_empty_string(portfolio_info.open_limit)
  result.val_short = value_or_empty_string(portfolio_info.val_short)
  result.val_long = value_or_empty_string(portfolio_info.val_long)
  result.val_long_margin = value_or_empty_string(portfolio_info.val_long_margin)
  result.val_long_asset = value_or_empty_string(portfolio_info.val_long_asset)
  result.assets = value_or_empty_string(portfolio_info.assets)
  result.cur_leverage = value_or_empty_string(portfolio_info.cur_leverage)
  result.margin = value_or_empty_string(portfolio_info.margin)
  result.lim_all = value_or_empty_string(portfolio_info.lim_all)
  result.av_lim_all = value_or_empty_string(portfolio_info.av_lim_all)
  result.locked_buy = value_or_empty_string(portfolio_info.locked_buy)
  result.locked_buy_margin = value_or_empty_string(portfolio_info.locked_buy_margin)
  result.locked_buy_asset = value_or_empty_string(portfolio_info.locked_buy_asset)
  result.locked_sell = value_or_empty_string(portfolio_info.locked_sell)
  result.locked_value_coef = value_or_empty_string(portfolio_info.locked_value_coef)
  result.in_all_assets = value_or_empty_string(portfolio_info.in_all_assets)
  result.all_assets = value_or_empty_string(portfolio_info.all_assets)
  result.profit_loss = value_or_empty_string(portfolio_info.profit_loss)
  result.rate_change = value_or_empty_string(portfolio_info.rate_change)
  result.lim_buy = value_or_empty_string(portfolio_info.lim_buy)
  result.lim_sell = value_or_empty_string(portfolio_info.lim_sell)
  result.lim_non_margin = value_or_empty_string(portfolio_info.lim_non_margin)
  result.lim_buy_asset = value_or_empty_string(portfolio_info.lim_buy_asset)
  result.val_short_net = value_or_empty_string(portfolio_info.val_short_net)
  result.val_long_net = value_or_empty_string(portfolio_info.val_long_net)
  result.total_money_bal = value_or_empty_string(portfolio_info.total_money_bal)
  result.total_locked_money = value_or_empty_string(portfolio_info.total_locked_money)
  result.haircuts = value_or_empty_string(portfolio_info.haircuts)
  result.assets_without_hc = value_or_empty_string(portfolio_info.assets_without_hc)
  result.status_coef = value_or_empty_string(portfolio_info.status_coef)
  result.varmargin = value_or_empty_string(portfolio_info.varmargin)
  result.go_for_positions = value_or_empty_string(portfolio_info.go_for_positions)
  result.go_for_orders = value_or_empty_string(portfolio_info.go_for_orders)
  result.rate_futures = value_or_empty_string(portfolio_info.rate_futures)
  result.is_qual_client = value_or_empty_string(portfolio_info.is_qual_client)
  result.is_futures = value_or_empty_string(portfolio_info.is_futures)
  result.curr_tag = value_or_empty_string(portfolio_info.curr_tag)
  
  return result
end

function StructConverter.getPortfolioInfoEx.PortfolioInfoEx(portfolio_info_ex, existing_struct)
  
  if portfolio_info_ex == nil then error("No 'portfolio_info_ex' table provided.", 2) end

  local result = (existing_struct == nil and qlua.getPortfolioInfoEx.PortfolioInfoEx() or existing_struct)
  
  StructConverter.getPortfolioInfo.PortfolioInfo(portfolio_info_ex, result.portfolio_info)
  
  result.init_margin = value_or_empty_string(portfolio_info_ex.init_margin)
  result.min_margin = value_or_empty_string(portfolio_info_ex.min_margin)
  result.corrected_margin = value_or_empty_string(portfolio_info_ex.corrected_margin)
  result.client_type = value_or_empty_string(portfolio_info_ex.client_type)
  result.portfolio_value = value_or_empty_string(portfolio_info_ex.portfolio_value)
  result.start_limit_open_pos = value_or_empty_string(portfolio_info_ex.start_limit_open_pos)
  result.total_limit_open_pos = value_or_empty_string(portfolio_info_ex.total_limit_open_pos)
  result.limit_open_pos = value_or_empty_string(portfolio_info_ex.limit_open_pos)
  result.used_lim_open_pos = value_or_empty_string(portfolio_info_ex.used_lim_open_pos)
  result.acc_var_margin = value_or_empty_string(portfolio_info_ex.acc_var_margin)
  result.cl_var_margin = value_or_empty_string(portfolio_info_ex.cl_var_margin)
  result.opt_liquid_cost = value_or_empty_string(portfolio_info_ex.opt_liquid_cost)
  result.fut_asset = value_or_empty_string(portfolio_info_ex.fut_asset)
  result.fut_total_asset = value_or_empty_string(portfolio_info_ex.fut_total_asset)
  result.fut_debt = value_or_empty_string(portfolio_info_ex.fut_debt)
  result.fut_rate_asset = value_or_empty_string(portfolio_info_ex.fut_rate_asset)
  result.fut_rate_asset_open = value_or_empty_string(portfolio_info_ex.fut_rate_asset_open)
  result.fut_rate_go = value_or_empty_string(portfolio_info_ex.fut_rate_go)
  result.planed_rate_go = value_or_empty_string(portfolio_info_ex.planed_rate_go)
  result.cash_leverage = value_or_empty_string(portfolio_info_ex.cash_leverage)
  result.fut_position_type = value_or_empty_string(portfolio_info_ex.fut_position_type)
  result.fut_accured_int = value_or_empty_string(portfolio_info_ex.fut_accured_int)
  
  return result
end

return StructConverter
