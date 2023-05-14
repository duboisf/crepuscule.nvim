local M = {}

local curl = require("plenary.curl")
local log = require("crepuscule.logger")

---@class crepuscule.CurlResult
---@field  exit number The shell process exit code
---@field  status number The https response status
---@field  headers Array<string> The https response headers
---@field  body string The http response body.

---Get the geo coordinates using the ipapi.co service.
---@param callback fun(latitude: number, longitude: number)
function M.geo_coordinates(callback)
  curl.get("https://ipapi.co/json/", {
    ---@param result crepuscule.CurlResult
    callback = function(result)
      if result.status == 200 then
        local data = vim.json.decode(result.body)
        if data ~= nil then
          callback(data.latitude, data.longitude)
        end
      end
    end,
    on_error = function(info)
      if info and type(info.stderr) == "string" then
        log("unexpected error getting geo coordinates: " .. info.stderr, vim.log.levels.DEBUG)
      else
        log("unexpected error getting geo coordinates: " .. vim.inspect(info), vim.log.levels.DEBUG)
      end
    end
  })
end

return M
