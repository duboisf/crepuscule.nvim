local M = {}

local curl = require("plenary.curl")

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
  })
end

return M
