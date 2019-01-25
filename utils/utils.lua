package.path = "../?.lua;" .. package.path

local table = require('table')
local os = require('os')
local string = require('string')

local pairs = assert(pairs, "Функция 'pairs' не найдена.")
local ipairs = assert(ipairs, "Функция 'ipairs' не найдена.")
local tostring = assert(tostring, "Функция 'tostring' не найдена.")
local error = assert(error, "Функция 'error' не найдена.")

local module = {}
module._VERSION = '2.1.0'

-- TODO: consider to remove
function module.create_table (pb_map)
  
  local t = {}
  for _, e in ipairs(pb_map) do
    t[e.key] = e.value
  end
  
  return t
end

-- TODO: consider to remove
function module.put_to_string_string_pb_map (t, pb_map, pb_map_entry_ctr)
  
  for k, v in pairs(t) do
    local entry = pb_map_entry_ctr()
    entry.key = module.Cp1251ToUtf8( tostring(k) )
    entry.value = module.Cp1251ToUtf8( tostring(v) )
    table.sinsert(pb_map, entry)
  end
end

function module.sleep(s)
  local ntime = os.clock() + s
  repeat until os.clock() > ntime
end

local create_qtable_parameter_types = function ()
  
  local result = {}
  
  local function put_qtable_parameter_entry (qtable_par_type)
    result[qtable_par_type] = assert(_G[qtable_par_type], string.format("Тип %s параметра QLua-таблицы не определён.", qtable_par_type))
  end
  
  put_qtable_parameter_entry("QTABLE_INT_TYPE")
  put_qtable_parameter_entry("QTABLE_DOUBLE_TYPE")
  put_qtable_parameter_entry("QTABLE_INT64_TYPE")
  put_qtable_parameter_entry("QTABLE_CACHED_STRING_TYPE")
  put_qtable_parameter_entry("QTABLE_TIME_TYPE")
  put_qtable_parameter_entry("QTABLE_DATE_TYPE")
  put_qtable_parameter_entry("QTABLE_STRING_TYPE")
  
  return result
end

local qtable_parameter_types = create_qtable_parameter_types()

function module.to_qtable_parameter_type (pb_column_parameter_type)
  
  local par_type = qtable_parameter_types[pb_column_parameter_type]
  if par_type == nil then error("Unknown column parameter type.") end
  
  return par_type
end

local create_interval_types_table = function ()
  
  local result = {}
  
  local function put_interval_entry (interval)
    result[interval] = assert(_G[interval], string.format("QLua-интервал %s не определён.", interval))
  end
  
  put_interval_entry("INTERVAL_TICK")
  put_interval_entry("INTERVAL_M1")
  put_interval_entry("INTERVAL_M2")
  put_interval_entry("INTERVAL_M3")
  put_interval_entry("INTERVAL_M4")
  put_interval_entry("INTERVAL_M5")
  put_interval_entry("INTERVAL_M6")
  put_interval_entry("INTERVAL_M10")
  put_interval_entry("INTERVAL_M15")
  put_interval_entry("INTERVAL_M20")
  put_interval_entry("INTERVAL_M30")
  put_interval_entry("INTERVAL_H1")
  put_interval_entry("INTERVAL_H2")
  put_interval_entry("INTERVAL_H4")
  put_interval_entry("INTERVAL_D1")
  put_interval_entry("INTERVAL_W1")
  put_interval_entry("INTERVAL_MN1")
  
  return result
end

local interval_types = create_interval_types_table()

function module.to_interval (pb_interval)

  local interval = interval_types[pb_interval]
  if interval == nil then error("Unknown interval type.") end

  return interval
end

module.table = {}

-- copy-pasted & adapted from http://lua-users.org/wiki/TableUtils
function module.table.val_to_str ( v )
  if "string" == type( v ) then
    v = string.gsub( v, "\n", "\\n" )
    if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
      return "'" .. v .. "'"
    end
    return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
  else
    return "table" == type( v ) and module.table.tostring( v ) or
      tostring( v )
  end
end

-- copy-pasted & adapted from http://lua-users.org/wiki/TableUtils
function module.table.key_to_str ( k )
  if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" ) then
    return k
  else
    return "[" .. module.table.val_to_str( k ) .. "]"
  end
end

-- copy-pasted & adapted from http://lua-users.org/wiki/TableUtils
function module.table.tostring( tbl )
  local result, done = {}, {}
  for k, v in ipairs( tbl ) do
    table.sinsert( result, module.table.val_to_str( v ) )
    done[ k ] = true
  end
  for k, v in pairs( tbl ) do
    if not done[ k ] then
      table.sinsert( result,
        module.table.key_to_str( k ) .. "=" .. module.table.val_to_str( v ) )
    end
  end
  return "{" .. table.sconcat( result, "," ) .. "}"
end

-- The CP1251 to UTF8 conversion copy-pasted & adapted from: http://mydc.ru/topic334.html?view=findpost&p=2276
local cp1251_decode = {
  [128]='\208\130',[129]='\208\131',[130]='\226\128\154',[131]='\209\147',[132]='\226\128\158',[133]='\226\128\166',
  [134]='\226\128\160',[135]='\226\128\161',[136]='\226\130\172',[137]='\226\128\176',[138]='\208\137',[139]='\226\128\185',
  [140]='\208\138',[141]='\208\140',[142]='\208\139',[143]='\208\143',[144]='\209\146',[145]='\226\128\152',
  [146]='\226\128\153',[147]='\226\128\156',[148]='\226\128\157',[149]='\226\128\162',[150]='\226\128\147',[151]='\226\128\148',
  [152]='\194\152',[153]='\226\132\162',[154]='\209\153',[155]='\226\128\186',[156]='\209\154',[157]='\209\156',
  [158]='\209\155',[159]='\209\159',[160]='\194\160',[161]='\209\142',[162]='\209\158',[163]='\208\136',
  [164]='\194\164',[165]='\210\144',[166]='\194\166',[167]='\194\167',[168]='\208\129',[169]='\194\169',
  [170]='\208\132',[171]='\194\171',[172]='\194\172',[173]='\194\173',[174]='\194\174',[175]='\208\135',
  [176]='\194\176',[177]='\194\177',[178]='\208\134',[179]='\209\150',[180]='\210\145',[181]='\194\181',
  [182]='\194\182',[183]='\194\183',[184]='\209\145',[185]='\226\132\150',[186]='\209\148',[187]='\194\187',
  [188]='\209\152',[189]='\208\133',[190]='\209\149',[191]='\209\151'
}

local utf8_decode = {
  [128]={[147]='\150',[148]='\151',[152]='\145',[153]='\146',[154]='\130',[156]='\147',[157]='\148',[158]='\132',[160]='\134',[161]='\135',[162]='\149',[166]='\133',[176]='\137',[185]='\139',[186]='\155'},
  [130]={[172]='\136'},
  [132]={[150]='\185',[162]='\153'},
  [194]={[152]='\152',[160]='\160',[164]='\164',[166]='\166',[167]='\167',[169]='\169',[171]='\171',[172]='\172',[173]='\173',[174]='\174',[176]='\176',[177]='\177',[181]='\181',[182]='\182',[183]='\183',[187]='\187'},
  [208]={[129]='\168',[130]='\128',[131]='\129',[132]='\170',[133]='\189',[134]='\178',[135]='\175',[136]='\163',[137]='\138',[138]='\140',[139]='\142',[140]='\141',[143]='\143',[144]='\192',[145]='\193',[146]='\194',[147]='\195',[148]='\196',
    [149]='\197',[150]='\198',[151]='\199',[152]='\200',[153]='\201',[154]='\202',[155]='\203',[156]='\204',[157]='\205',[158]='\206',[159]='\207',[160]='\208',[161]='\209',[162]='\210',[163]='\211',[164]='\212',[165]='\213',[166]='\214',
    [167]='\215',[168]='\216',[169]='\217',[170]='\218',[171]='\219',[172]='\220',[173]='\221',[174]='\222',[175]='\223',[176]='\224',[177]='\225',[178]='\226',[179]='\227',[180]='\228',[181]='\229',[182]='\230',[183]='\231',[184]='\232',
    [185]='\233',[186]='\234',[187]='\235',[188]='\236',[189]='\237',[190]='\238',[191]='\239'},
  [209]={[128]='\240',[129]='\241',[130]='\242',[131]='\243',[132]='\244',[133]='\245',[134]='\246',[135]='\247',[136]='\248',[137]='\249',[138]='\250',[139]='\251',[140]='\252',[141]='\253',[142]='\254',[143]='\255',[144]='\161',[145]='\184',
    [146]='\144',[147]='\131',[148]='\186',[149]='\190',[150]='\179',[151]='\191',[152]='\188',[153]='\154',[154]='\156',[155]='\158',[156]='\157',[158]='\162',[159]='\159'},[210]={[144]='\165',[145]='\180'}
}

local nmdc = {
  [36] = '$',
  [124] = '|'
}

function module.Cp1251ToUtf8(s)
  
  if s == nil then return nil end
  
  local r, b = ''
  for i = 1, s and s:len() or 0 do
    b = s:byte(i)
    if b < 128 then
      r = r..string.char(b)
    else
      if b > 239 then
        r = r..'\209'..string.char(b - 112)
      elseif b > 191 then
        r = r..'\208'..string.char(b - 48)
      elseif cp1251_decode[b] then
        r = r..cp1251_decode[b]
      else
        r = r..'_'
      end
    end
  end
  return r
end

function module.Utf8ToCp1251(s)
  
  if s == nil then return nil end
  
  local a, j, r, b = 0, 0, ''
  for i = 1, s and s:len() or 0 do
    b = s:byte(i)
    if b < 128 then
      if nmdc[b] then
        r = r..nmdc[b]
      else
        r = r..string.char(b)
      end
    elseif a == 2 then
      a, j = a - 1, b
    elseif a == 1 then
      a, r = a - 1, r..utf8_decode[j][b]
    elseif b == 226 then
      a = 2
    elseif b == 194 or b == 208 or b == 209 or b == 210 then
      j, a = b, 1
    else
      r = r..'_'
    end
  end
  return r
end

return module
