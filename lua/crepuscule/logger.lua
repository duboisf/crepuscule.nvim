local config = require("crepuscule.config")

---Log a message.
---@param msg string
---@param lvl number
return function(msg, lvl)
  if lvl < config.get().log_level then
    return
  end
  local current_time = os.date("%H:%M:%S")
  local callback = function()
    vim.notify(current_time .. ": crepuscule.nvim: " .. msg, lvl)
  end
  if vim.in_fast_event() then
    vim.schedule(function()
      callback()
    end)
  else
    callback()
  end
end
