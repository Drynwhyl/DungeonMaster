---@class Room
---@field x number
---@field y number
---@field width number
---@field height number
local Room = {}

function Room:new(x, y, width, height)
    local instance = {
        x = x,
        y = y,
        width = width,
        height = height,
    }
    setmetatable(instance, self)
    self.__index = self
    return instance
end

return Room