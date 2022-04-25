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

return M
