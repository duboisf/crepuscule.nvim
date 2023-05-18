local M = {}

local config = require("crepuscule.config")
local location = require("crepuscule.location")
local Persistence = require("crepuscule.persistence")
local twilight = require("crepuscule.twilight")
local log = require("crepuscule.logger")

local persistence = Persistence.new()

local set_background = function(new_background)
  local current_background = vim.opt.background:get()
  if new_background ~= current_background then
    log("changing background from " .. current_background .. " to " .. new_background, vim.log.levels.DEBUG)
    vim.opt.background = new_background
    persistence:set_string("background", new_background)
  end
end

---@param coords crepuscule.GeoCoordinates
local function schedule(coords)
  log("latitude=" .. tostring(coords.latitude) .. ", longitude=" .. tostring(coords.longitude),
    vim.log.levels.DEBUG)
  local sunrise, sunset = twilight(coords.latitude, coords.longitude)
  log("sunrise=" .. sunrise .. ", sunset=" .. sunset, vim.log.levels.DEBUG)

  local timer = vim.loop.new_timer()
  if timer == nil then
    log("crepuscule: unexpected error: timer is nil", vim.log.levels.ERROR)
    return
  end

  timer:start(0, 1000 * 60, function()
    log("timer fired", vim.log.levels.DEBUG)

    local current_time = os.date("%H:%M")
    local background = "dark"
    if sunrise < current_time and current_time < sunset then
      background = "light"
    end

    vim.schedule(function()
      set_background(background)
    end)
  end)
end

---Setup crepuscule.
---@param cfg crepuscule.Config
function M.setup(cfg)
  config.set(cfg)

  local err = persistence:load()
  if err == nil then
    local persisted_background = persistence:get_string("background")
    if persisted_background ~= nil then
      vim.opt.background = persisted_background
    end
  else
    log("crepuscule: failed to load persisted data: " .. err, vim.log.levels.DEBUG)
  end

  local latitude = persistence:get_number("latitude")
  local longitude = persistence:get_number("longitude")
  if latitude and longitude then
    schedule({ latitude = latitude, longitude = longitude })
  else
    location.geo_coordinates(function(coords)
      if coords ~= nil then
        persistence:set_number("latitude", coords.latitude)
        persistence:set_number("longitude", coords.longitude)
        schedule(coords)
      else
        log("crepuscule: failed to get geo coordinates", vim.log.levels.ERROR)
      end
    end)
  end
end

return M
