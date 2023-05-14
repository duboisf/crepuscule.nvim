local M = {}

---@class crepuscule.Config
local config = {
  log_level = vim.log.levels.WARN,
}

---@return crepuscule.Config
function M.get()
  -- Return a copy of the config table.
  return vim.tbl_extend("force", {}, config)
end

---@param new_config crepuscule.Config
---@return nil
function M.set(new_config)
  -- Set the config table.
  config = vim.tbl_extend("force", config, new_config)
end

return M
