---@class Door
---@field private dungeon Dungeon
---@field public horizontal boolean
---@field public size number
---@field public x number
---@field public y number
local Door = {}

function Door:new(dungeon, x, y, size, horizontal)
    ---@type Door
    local instance = {
        dungeon = dungeon,
        x = x,
        y = y,
        size = size,
        horizontal = horizontal,
    }

    setmetatable(instance, self)
    self.__index = self

    return instance
end

function Door:getCenter()
    if self.horizontal then
        return self.x + self.size // 2, self.y
    else
        return self.x, self.y + self.size // 2
    end
end

---@param nodes Node[][]
---@return Node
function Door:findNearestNode(nodes, nodeSize)
    local x, y = self:getCenter()
    local offset = nodeSize // 2 + 1
    if self.horizontal then
        return nodes[x][y + offset] or nodes[x][y - offset]
    else
        return nodes[x + offset][y] or nodes[x - offset][y]
    end
end

return Door