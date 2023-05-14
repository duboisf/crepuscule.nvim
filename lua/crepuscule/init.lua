local M = {}

local config = require("crepuscule.config")
local location = require("crepuscule.location")
local twilight = require("crepuscule.twilight")
local log = require("crepuscule.logger")

function M.setup(cfg)
  config.set(cfg)
  local fd, err_name, err_msg = vim.loop.fs_open("crepuscule.cache", "r", 438)
  if fd ~= nil then
    local stat
    stat, err_name, err_msg = vim.loop.fs_stat("crepuscule.cache")
    if stat ~= nil then
      local data
      data, err_name, err_msg = vim.loop.fs_read(fd, stat.size, 0)
    end
  end
  local timer = vim.loop.new_timer()
  location.geo_coordinates(function(latitude, longitude)
    local sunrise, sunset = twilight(latitude, longitude)
    log("sunrise=" .. sunrise .. ", sunset=" .. sunset, vim.log.levels.DEBUG)
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
        local current_background = vim.opt.background:get()
        log("current background=" .. current_background, vim.log.levels.DEBUG)
        if background ~= current_background then
          log("changing background from " .. current_background .. " to " .. background, vim.log.levels.DEBUG)
          vim.opt.background = background
        end
      end)
    end)
  end)
end

return M
