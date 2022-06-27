local utils = require("md-code.utils")

local M = {}
M.opened_buffer = {}
local default_config = {
  create_buffer_cmd = "vs",
  temp_path = "/tmp/",
  filetypes = vim.fn.getcompletion("", "filetype"),
}

if vim.fn.isdirectory("/tmp/") == 1 then
  default_config.temp_path = "/tmp/mdorg/"
else
  default_config.temp_path = [[%userprofile%\AppData\Local\Temp]]
end

local configs = default_config

-- @param user_config table
function M.setup(user_config)
  if type(user_config) == "table" and user_config ~= {} then
    configs = utils.extend_table(user_config, configs)
  end
end

M.module_status = false
M.createdBuffer = "vs"

M.filename = "mdnorg"
M.md_code_start = 0
M.md_code_done = 0
M.md_code_bufferID = 0

--- ```cpp
--- print("hello")
--- return 0;
--- print("hello")
--- ```

--- @code python
--- print("hello")
--- return 0;
--- print("python")
--- @end

--- Get the lines in the codeblock and the filetype
M.GetBufferCodeBlockType = function(line)
  local ty = ""
  local code = {}
  local filetype = vim.bo.filetype
  local done = 0
  local start = 0

  local filetypeBlock = {
    begin = "```(.+)",
    done = "```",
  }

  if filetype == "norg" then
    filetypeBlock = {
      begin = "@code (%a+)",
      done = "@end",
    }
  end

  -- Find the start of the codeblock
  while line ~= 0 do
    local str = vim.fn.getline(line)
    local str_begin, str_end, buf_ftype = string.find(str, filetypeBlock.begin, 1, false)

    if str_begin ~= nil and str_end ~= nil then
      -- find the filetype
      ty = utils.find_ft(buf_ftype, configs.filetypes)
      if ty == "" then
        ty = "txt"
      end
      start = line + 1
      vim.g.mdorg_indent = str_begin
      break
    end

    line = line - 1
  end

  -- Find the end of the codeblock
  while line ~= vim.fn.line("$") do
    line = line + 1
    local str = vim.fn.getline(line)
    if vim.g.mdorg_indent ~= 1 then
      str = string.sub(str, vim.g.mdorg_indent)
    end
    local str_begin, str_end, str_sub = string.find(str, filetypeBlock.done)

    if str_begin ~= nil and str_end ~= nil then
      done = line - 1
      break
    end

    code[#code + 1] = str
  end

  return ty, code, start, done
end

--- insert the code
--- @param code table
M.InsertBlockCode = function(code)
  local buferid = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_lines(buferid, 0, -1, false, code)
end

--- create a new buffer for the codeblock
---@param ty string
M.CreatedBufferEditCodeBlock = function(ty)
  M.OpenDir(configs.temp_path)
  local new_buf = nil
  if configs.create_buffer_cmd == "vs" then
    vim.cmd("vsplit " .. configs.temp_path .. M.filename .. "." .. utils.getSuffix(ty))
    M.module_status = true
    if utils.contains(configs.filetypes, ty) then
      vim.bo.filetype = ty
    end
    new_buf = vim.api.nvim_get_current_buf()
  end
  return new_buf
end

--- Create a directory if it doesn't exist.
---@param pathname string
M.OpenDir = function(pathname)
  local file = io.open(pathname)
  if file then
    file:close()
  else
    vim.fn.mkdir(pathname, "p")
  end
end

--- Automatically save the code in the buffer
M.CloseMdCode = function()
  local file = utils.split(vim.fn.expand("%:t"), ".")
  if vim.api.nvim__buf_stats(vim.g.Mbufferid) ~= 0 and file[1] == M.filename then
    M.ResCodeBlock()
    -- vim.cmd("silent augroup! AutoCloseMdorg")
  end
end

--- Save the code block
M.ResCodeBlock = function()
  local code = {}
  if M.module_status then
    M.module_status = false
    local space = ""
    for i = 1, vim.g.mdorg_indent - 1 do
      space = space .. " "
    end
    for i = 1, vim.fn.line("$") do
      code[#code + 1] = space .. vim.fn.getline(i)
    end
    -- vim.cmd("silent !rm " .. vim.fn.expand("%:p"))
    vim.fn.delete(vim.fn.expand("%:p"))
    M.opened_buffer[vim.api.nvim_get_current_buf()] = nil
    vim.cmd("bd!")
    vim.api.nvim_buf_set_lines(vim.g.Mbufferid, M.md_code_start - 1, M.md_code_done, false, code)
  end
end

--- Edit the current codeblock
M.EditBufferCodeBlock = function()
  vim.g.Mbufferid = vim.api.nvim_get_current_buf()
  local line = vim.fn.line(".")
  local ty, code, start, done = M.GetBufferCodeBlockType(line)

  if string.len(ty) > 0 then
    M.md_code_start = start
    M.md_code_done = done
    -- Create a new split
    M.opened_buffer[M.CreatedBufferEditCodeBlock(ty)] = {}
    M.InsertBlockCode(code)
  end
end
vim.g.mdorg_Edit = M.EditBufferCodeBlock
vim.g.mdorg_Res = M.ResCodeBlock
vim.g.mdorg_close = M.CloseMdCode

vim.api.nvim_set_keymap("n", "q", "", {
  callback = function()
    if M.opened_buffer[vim.api.nvim_get_current_buf()] ~= nil then
      return M.ResCodeBlock()
    end
  end,
  noremap = true,
})

return M
