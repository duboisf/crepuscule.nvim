---@class crepuscule.Persistence
local persistence = {}

local log = require("crepuscule.logger")

local uv = vim.loop

local data = {}
-- indicates whether the data has been modified since the last load/save
local dirty = false
local persisted_filepath = vim.fn.stdpath("data") .. "/crepuscule.json"

---@return crepuscule.Persistence
function persistence.new()
  local self = {}
  setmetatable(self, { __index = persistence })
  return self
end

---@param key string
---@param value string
function persistence:set_string(key, value)
  dirty = true
  log("persistence: setting key=" .. key .. ", value=" .. value, vim.log.levels.DEBUG)
  data[key] = value
end

---@param key string
---@return string?
function persistence:get_string(key)
  log("persistence: getting key=" .. key, vim.log.levels.DEBUG)
  return data[key]
end

---@param key string
---@param value number
function persistence:set_number(key, value)
  dirty = true
  log("persistence: setting key=" .. key .. ", value=" .. value, vim.log.levels.DEBUG)
  data[key] = value
end

---@param key string
---@return number?
function persistence:get_number(key)
  log("persistence: getting key=" .. key, vim.log.levels.DEBUG)
  return data[key]
end

---@return string? error
function persistence:load()
  log("persistence: loading data from filename=" .. persisted_filepath, vim.log.levels.DEBUG)
  local fd = uv.fs_open(persisted_filepath, "r", 438)
  if fd == nil then
    return "load: failed to open file"
  end

  local stat = uv.fs_fstat(fd)
  if stat == nil then
    return "load: failed to stat file"
  end

  local raw = uv.fs_read(fd, stat.size, 0)
  if raw == nil then
    return "load: failed to read file"
  end

  uv.fs_close(fd)

  local ok, result = pcall(vim.fn.json_decode, raw)
  if not ok then
    return "load: failed to decode data"
  end

  data = result

  return nil
end

---@return string? error
local function save()
  if not dirty then
    return nil
  end

  local ok, raw = pcall(vim.fn.json_encode, data)
  if not ok then
    return "save: failed to encode data"
  end

  local fd = uv.fs_open(persisted_filepath, "w", 438)
  if fd == nil then
    return "save: failed to open file"
  end

  local bytes_written = uv.fs_write(fd, raw, 0)
  if bytes_written == nil then
    return "save: failed to write to file"
  end

  local closed = uv.fs_close(fd)
  if closed == nil then
    return "save: failed to close file"
  end

  dirty = false
  return nil
end

-- Create autocommand to persist data on exit
vim.api.nvim_create_autocmd(
  "VimLeavePre",
  {
    pattern = "*",
    desc = "Persist crepuscule.nvim data on exit",
    callback = save,
    once = true
  }
)

return persistence
