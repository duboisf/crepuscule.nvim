local M = {}

local location = require("crepuscule.location")
local twilight = require("crepuscule.twilight")

function M.setup()
  location.geo_coordinates(function(latitude, longitude)
    print(latitude, longitude)
    local sunrise, sunset = twilight(latitude, longitude)
    local current_time = os.date("%H:%M")
    vim.schedule(function()
      if current_time > sunrise and current_time < sunset then
        vim.opt.background = "light"
      else
        vim.opt.background = "dark"
      end
    end)
  end)
end

return M
