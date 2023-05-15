local M = {}

local curl = require("plenary.curl")
local log = require("crepuscule.logger")

---@class crepuscule.CurlResult
---@field  exit number The shell process exit code
---@field  status number The https response status
---@field  headers Array<string> The https response headers
---@field  body string The http response body.

---@class crepuscule.GeoCoordinates
---@field latitude number
---@field longitude number

--[[
Example of the ipapi.co response:
curl -q "https://ipapi.co/8.8.8.8json/"
{
    "ip": "8.8.8.8",
    "network": "8.8.8.0/24",
    "version": "IPv4",
    "city": "Mountain View",
    "region": "California",
    "region_code": "CA",
    "country": "US",
    "country_name": "United States",
    "country_code": "US",
    "country_code_iso3": "USA",
    "country_capital": "Washington",
    "country_tld": ".us",
    "continent_code": "NA",
    "in_eu": false,
    "postal": "94043",
    "latitude": 37.42301,
    "longitude": -122.083352,
    "timezone": "America/Los_Angeles",
    "utc_offset": "-0700",
    "country_calling_code": "+1",
    "currency": "USD",
    "currency_name": "Dollar",
    "languages": "en-US,es-US,haw,fr",
    "country_area": 9629091.0,
    "country_population": 327167434,
    "asn": "AS15169",
    "org": "GOOGLE"
}
--]]
---@class crepuscule.IpApiResult
---@field latitude number
---@field longitude number

---Get the geo coordinates using the ipapi.co service.
---@param callback fun(success: boolean, coordinates: crepuscule.GeoCoordinates)
function M.geo_coordinates(callback)
  curl.get("https://ipapi.co/json/", {
    ---@param result crepuscule.CurlResult
    callback = function(result)
      if result.status == 200 then
        ---@type crepuscule.IpApiResult?
        local data = vim.json.decode(result.body)
        if data ~= nil then
          callback(true, {
            latitude = data.latitude,
            longitude = data.longitude,
          })
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
