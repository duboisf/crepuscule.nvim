--Most of the code in this file was copied from https://forum.logicmachine.net/printthread.php?tid=14
--It was slightly refactored to eliminate luals diagnostic warnings

local pi = math.pi
local doublepi = pi * 2
local rads = pi / 180.0

---Get the timezone offset from UTC in hours
---@param when osdate
local function TZ(when)
  local ts = os.time(when)
  local utcdate, localdate = os.date('!*t', ts) --[[@as osdate]], os.date('*t', ts) --[[@as osdate]]
  localdate.isdst = false

  local diff = os.time(localdate) - os.time(utcdate)
  return math.floor(diff / 3600)
end

local function range(x)
  local a = x / doublepi
  local b = doublepi * (a - math.floor(a))
  return b < 0 and (doublepi + b) or b
end

---sunrise / sunset calculation
---@param latitude number in degrees
---@param longitude number in degrees
---@param when? osdate date at which to calculate sunrise/sunset, defaults to now
---@return number sunrise in minutes since midnight
---@return number sunset in minutes since midnight
local function rscalc(latitude, longitude, when)
  when = when or os.date('*t') --[[@as osdate]]

  local y2k = { year = 2000, month = 1, day = 1 }
  local y2kdays = os.time(when) - os.time(y2k)
  y2kdays = math.ceil(y2kdays / 86400)

  local meanlongitude = range(280.461 * rads + 0.9856474 * rads * y2kdays)
  local meananomaly = range(357.528 * rads + 0.9856003 * rads * y2kdays)
  local lambda = range(meanlongitude + 1.915 * rads * math.sin(meananomaly) + rads / 50 * math.sin(2 * meananomaly))

  local obliq = 23.439 * rads - y2kdays * rads / 2500000

  local alpha = math.atan2(math.cos(obliq) * math.sin(lambda), math.cos(lambda))
  local declination = math.asin(math.sin(obliq) * math.sin(lambda))

  local LL = meanlongitude - alpha
  if meanlongitude < pi then
    LL = LL + doublepi
  end

  local dfo = pi / 216.45

  if latitude < 0 then
    dfo = -dfo
  end

  local fo = math.min(math.tan(declination + dfo) * math.tan(latitude * rads), 1)
  local ha = 12 * math.asin(fo) / pi + 6

  local timezone = TZ(when)
  local equation = 12 + timezone + 24 * (1 - LL / doublepi) - longitude / 15

  local sunrise, sunset = equation - ha, equation + ha

  if sunrise > 24 then
    sunrise = sunrise - 24
  end

  if sunset > 24 then
    sunset = sunset - 24
  end

  return math.floor(sunrise * 60), math.ceil(sunset * 60)
end

---Convert minutes since midnight to HH:MM format
---@param minutes number
---@return string time in HH:MM format
local minutes_to_time = function(minutes)
  local hours = math.floor(minutes / 60)
  local mins = minutes - hours * 60
  return string.format('%02d:%02d', hours, mins)
end

---Get the sunrise and sunset times for a given location
---@param latitude number in degrees
---@param longitude number in degrees
---@param when? osdate date at which to calculate sunrise/sunset, defaults to now
---@return string sunrise time in HH:MM format
---@return string sunset time in HH:MM format
return function(latitude, longitude, when)
  local sunrise, sunset = rscalc(latitude, longitude, when)
  return minutes_to_time(sunrise), minutes_to_time(sunset)
end
