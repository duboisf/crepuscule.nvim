--[[
TODO use plenary.curl to get location
curl -q "https://ipapi.co/$(curl -s ifconfig.me)/json/"
--]]
local M = {}

---Get the current location using the ipapi.co service.
---TODO implement this function using plenary.curl
---@return number latitude
---@return number longitude
function M.location()
  return 0, 0
end

return M
