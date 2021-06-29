require("TerrainTypeCodes")

local Autotable = require "Autotable"
local Door = require "Door"

---@class Room
---@field private dungeon Dungeon
---@field public x number
---@field public y number
---@field public width number
---@field public height number
---@field public doors Door[]
local Room = {}

function Room:new(dungeon, x, y, width, height)
    ---@type Room
    local instance = {
        dungeon = dungeon,
        x = x,
        y = y,
        width = width,
        height = height,
        doors = {},
    }
    setmetatable(instance, self)
    self.__index = self

    instance:createDoors()

    return instance
end

---@return number, number
function Room:getCenter()
    return self.x + self.width // 2, self.y + self.height // 2
end

function Room:getDoor(x, y, visited)
    local directions = {
        up = { x = 0, y = 1, horizontal = false },
        down = { x = 0, y = -1, horizontal = false },
        left = { x = -1, y = 0, horizontal = true },
        right = { x = 1, y = 0, horizontal = true },
    }
    local doorCells = {}
    local horizontal
    for _, direction in pairs(directions) do
        if self.dungeon:getCell(x + direction.x, y + direction.y) == TILE_DOOR and not visited[x][y] then
            horizontal = direction.horizontal
            repeat
                table.insert(doorCells, { x = x, y = y })
                visited[x][y] = true
                x = x + direction.x
                y = y + direction.y
            until self.dungeon:getCell(x, y) ~= TILE_DOOR
            break
        end
    end
    table.sort(doorCells, function(a, b)
        return a.x < b.x or a.y < b.y
    end)
    return Door:new(self.dungeon, doorCells[1].x, doorCells[1].y, #doorCells, horizontal)
end

function Room:createDoors()
    local visited = Autotable:new(1)
    for x = self.x, self.x + self.width do
        for y = self.y, self.y + self.height do
            if self.dungeon:getCell(x, y) == TILE_DOOR and not visited[x][y] then
                table.insert(self.doors, self:getDoor(x, y, visited))
            end
        end
    end
end

return Room