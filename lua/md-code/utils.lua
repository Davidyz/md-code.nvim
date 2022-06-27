local M = {}

-- @param from table
-- @param to table
-- @returns table
function M.extend_table(from, to)
  for _, key in ipairs(from) do
    if type(from[key]) == "table" then
      to.key = {}
      M.extend_table(from[key], to[key])
    else
      to[key] = from[key]
    end
  end
end

-- @param array table
-- @param item
-- @return boolean
function M.contains(array, item)
  for _, i in ipairs(array) do
    if i == item then
      return true
    end
  end
  return false
end

--- separate a string.
---@param str string
---@param reps string
---@return table
function M.split(str, reps)
  local resultStrList = {}
  string.gsub(str, "[^" .. reps .. "]+", function(w)
    table.insert(resultStrList, w)
  end)
  return resultStrList
end

--- @param str string
--- @param ftypes table
function M.find_ft(str, ftypes)
  if M.contains(ftypes, str) then
    return str
  end
  str = string.match(str, "{.*}")
  if str == nil then
    return ""
  end
  for _, i in ipairs(M.split(str, " ")) do
    local word = string.match(i, "%.(%a+)")
    if M.contains(ftypes, word) then
      return word
    end
  end
  return ""
end

M.suffix = {
  -- a table that maps filetypes to corresponding suffix.
  python = "py",
  haskell = "hs",
}

-- @param ftypes string
-- @return string
function M.getSuffix(ftype)
  -- return the suffix associated with a filetype.
  -- To include custom suffixes, edit M.suffix.
  return M.suffix[ftype] or ftype
end

return M
