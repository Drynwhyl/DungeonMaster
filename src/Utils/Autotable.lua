---@class Autotable
local Autotable = {}

-- index function to do the magic
function Autotable:index(key)
    local mt = getmetatable(self)
    local t = {}
    if mt.depth ~= 1 then
        setmetatable(t, { __index = mt.__index, depth = mt.depth - 1 })
    end
    self[key] = t
    return t
end

--- Creates a new auto-table.
---@param depth number @(optional, default 0) how deep to auto-generate tables. The last
--- table in the chain generated will itself not be an auto-table. If `depth == 0` then
--- there is no limit.
---@return Autotable
function Autotable:new(depth, initializer)
    return setmetatable(initializer or {}, { __index = Autotable.index, depth = depth or 0 })
end

--- Checks a table to be an auto-table
---@param table table @table to check
---@return boolean @'true' if 'table' is an auto-table, 'false' otherwise
local function isAutotable(table)
    if type(table) ~= "table" then
        return false
    end
    return ((getmetatable(table) or {}).__index == autotable__index)
end

return Autotable