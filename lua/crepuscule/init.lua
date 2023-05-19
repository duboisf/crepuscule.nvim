local M = {}

local config = require("crepuscule.config")
local location = require("crepuscule.location")
local Persistence = require("crepuscule.persistence")
local log = require("crepuscule.logger")

local persistence = Persistence.new()

---Adjust the background based on the sunrise and sunset times.
---Before changing the background, it checks if we are in a fast event.
---If we are, it schedules the background change for later, otherwise it changes the background immediately.
---Returns a function that can be invoked directcly or used as a callback for a timer.
---@param sunrise string time in HH:MM format
---@param sunset string time in HH:MM format
---@return fun()
local function adjust_background_based_on_sunlight(sunrise, sunset)
  return function()
    local schedule = vim.in_fast_event() and vim.schedule or function(cb) cb() end
    schedule(function()
      local current_time = os.date("%H:%M")
      local background = "dark"
      if sunrise < current_time and current_time < sunset then
        background = "light"
      end

      local current_background = vim.opt.background:get()
      if background ~= current_background then
        log("changing background from " .. current_background .. " to " .. background, vim.log.levels.DEBUG)
        vim.opt.background = background
        persistence:set_string("background", background)
      end
    end)
  end
end

---@param coords crepuscule.GeoCoordinates
---@return string sunrise time in minutes since midnight
---@return string sunset time in minutes since midnight
local function twilight(coords)
  return require("crepuscule.twilight")(coords)
end

---Schedule a timer to adjust the background based on the sunrise and sunset times.
---@param callback fun()
---@param delay? number delay in seconds, defaults to zero
local function set_timer(callback, delay)
  local timer = vim.loop.new_timer()
  if timer == nil then
    log("crepuscule: unexpected error: timer is nil", vim.log.levels.ERROR)
    return
  end

  timer:start((delay or 0) * 1000, 1000 * 60, function()
    log("timer fired", vim.log.levels.DEBUG)
    callback()
  end)
end

---Get persisted background and set it.
local function set_persisted_background()
  local persisted_background = persistence:get_string("background")
  if persisted_background ~= nil then
    vim.opt.background = persisted_background
  end
end

---Get persisted geo coordinates
---@return crepuscule.GeoCoordinates?
local function get_persisted_geo_coordinates()
  local latitude = persistence:get_number("latitude")
  local longitude = persistence:get_number("longitude")
  if latitude and longitude then
    return { latitude = latitude, longitude = longitude }
  end
end

local function persist_geo_coordinates(coords)
  persistence:set_number("latitude", coords.latitude)
  persistence:set_number("longitude", coords.longitude)
end

---Schedule a timer to adjust the background based on the sunrise and sunset times.
---@param coords crepuscule.GeoCoordinates
---@param run_now? boolean run the callback immediately, defaults to false
local function schedule_adjustment(coords, run_now)
  local sunrise, sunset = twilight(coords)
  log("sunrise: " .. sunrise .. ", sunset: " .. sunset, vim.log.levels.DEBUG)
  if run_now then
    adjust_background_based_on_sunlight(sunrise, sunset)()
  end
  set_timer(adjust_background_based_on_sunlight(sunrise, sunset), 60)
end

---Setup crepuscule.
---@param cfg crepuscule.Config
function M.setup(cfg)
  config.set(cfg)

  local err = persistence:load()
  if err == nil then
    -- Although the persisted background might be wrong for
    -- the time of day, it's better than nothing.
    -- We'll adjust it later.
    set_persisted_background()
  else
    log("crepuscule: failed to load persisted data: " .. err, vim.log.levels.DEBUG)
  end

  local persisted_coords = get_persisted_geo_coordinates()
  if persisted_coords then
    schedule_adjustment(persisted_coords, true)
  else
    location.geo_coordinates(function(coords)
      if coords ~= nil then
        persist_geo_coordinates(coords)
        schedule_adjustment(coords)
      else
        log("crepuscule: failed to get geo coordinates", vim.log.levels.ERROR)
      end
    end)
  end
end

return M
