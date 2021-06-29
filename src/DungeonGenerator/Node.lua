local Autotable = require "Autotable"

---@class Node
---@field private dungeon Dungeon
---@field public x number
---@field public y number
---@field public width number
---@field public height number
---@field public neighbours Node[]
local Node = {}

function Node:new(dungeon, x, y, width, height)
    local instance = {
        dungeon = dungeon,
        x = x,
        y = y,
        width = width,
        height = height,
        neighbours = {},
    }
    setmetatable(instance, self)
    self.__index = self
    return instance
end

function Node:generate(dungeon, centerX, centerY, size)
    local halfSize = size // 2
    for x = centerX - halfSize, centerX + halfSize do
        for y = centerY - halfSize, centerY + halfSize do
            local cell = dungeon:getCell(x, y)
            --if cell == TILE_FLOOR or cell == TILE_WALL or cell == TILE_DOOR then
            if cell ~= TILE_EMPTY then
                return nil
            end
        end
    end
    return Node:new(dungeon, centerX - halfSize, centerY - halfSize, size, size)
end

---@return number
function Node:getCenterX()
    return self.x + self.width // 2
end

---@return number
function Node:getCenterY()
    return self.y + self.height // 2
end

function Node:addNeighbour(node, neighbour)
    if node and neighbour then
        table.insert(node.neighbours, neighbour)
    end
end

---@param dungeon Dungeon
function Node:createGraph(dungeon, nodeSize)
    ---@type Node[][]
    local nodes = Autotable:new(1)

    for x = 1, dungeon:getWidth() do
        for y = 1, dungeon:getHeight() do
            nodes[x][y] = self:generate(dungeon, x, y, nodeSize)
        end
    end

    for x = 1, dungeon:getWidth() do
        for y = 1, dungeon:getHeight() do
            self:addNeighbour(nodes[x][y], nodes[x][y + 1])
            self:addNeighbour(nodes[x][y], nodes[x][y - 1])
            self:addNeighbour(nodes[x][y], nodes[x - 1][y])
            self:addNeighbour(nodes[x][y], nodes[x + 1][y])
        end
    end

    return nodes
end

return Node