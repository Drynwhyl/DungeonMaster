require "TerrainTypeCodes"
local Autotable = require "Autotable"
local WC3Math = require "WC3Math"

---@class RoomTemplate
---@field private cells number[][]
---@field private width number
---@field private height number
local RoomTemplate = {}

---@param cells number[][]
function RoomTemplate:new(cells)
    local instance = {}
    instance.cells = cells or Autotable:new(1)
    setmetatable(instance, self)
    self.__index = self
    return instance
end

---@param rect rect
---@return RoomTemplate
function RoomTemplate:parse(rect)
    local instance = self:new()
    local minX = GetRectMinX(rect)
    local minY = GetRectMinY(rect)
    for x = GetRectMinX(rect), GetRectMaxX(rect), bj_CELLWIDTH do
        for y = GetRectMinY(rect), GetRectMaxY(rect), bj_CELLWIDTH do
            instance.cells[1 + (x - minX) / bj_CELLWIDTH][1 + (y - minY) / bj_CELLWIDTH] = GetTerrainType(x, y);
            SetTerrainType(x, y, TILE_EMPTY, -1, 1, 1)
        end
    end
    return instance
end

function RoomTemplate:getWidth()
    return #(self.cells)
end

function RoomTemplate:getHeight()
    return #(self.cells[1])
end

function RoomTemplate:getArea()
    return self:getWidth() * self:getHeight()
end

function RoomTemplate:setCell(x, y, tile)
    if x < 1 or x > self:getWidth() or y < 1 or y > self:getHeight() then
        print("ERROR: In RoomTemplate:setCell array index out of range: x=" .. x .. " y=" .. y)
        return
    end
    self.cells[x][y] = tile
end

function RoomTemplate:getCell(x, y)
    if x < 1 or x > self:getWidth() or y < 1 or y > self:getHeight() then
        return TILE_UNKNOWN
    end
    return self.cells[x][y]
end

---@param templateRects rect[]
---@return RoomTemplate[]
function RoomTemplate:batchParse(templateRects)
    ---@type RoomTemplate[]
    local templates = {}
    for _, rect in ipairs(templateRects) do
        table.insert(templates, self:parse(rect))
    end
    table.sort(templates, function(a, b)
        return a:getArea() > b:getArea()
    end)
    return templates
end

local function transpose(matrix)
    local newMatrix = Autotable:new(1)
    local width = #matrix
    local height = #matrix[1]
    for i = 1, width do
        for j = 1, height do
            newMatrix[j][i] = matrix[i][j]
        end
    end
    return newMatrix
end

local function reverseRows(matrix)
    local newMatrix = Autotable:new(1)
    local width = #matrix
    local height = #matrix[1]
    for i = 1, width do
        for j = 1, height do
            newMatrix[i][j] = matrix[i][height - j + 1]
        end
    end
    return newMatrix
end

local function reverseCols(matrix)
    local newMatrix = Autotable:new(1)
    local width = #matrix
    local height = #matrix[1]
    for i = 1, width do
        for j = 1, height do
            newMatrix[i][j] = matrix[width - i + 1][j]
        end
    end
    return newMatrix
end

function RoomTemplate:rotate(angle)
    if angle == 90 then
        return RoomTemplate:new(reverseCols(transpose(self.cells)))
    elseif angle == 270 then
        return RoomTemplate:new(reverseRows(transpose(self.cells)))
    elseif angle == 180 then
        return RoomTemplate:new(reverseCols(reverseRows(self.cells)))
    else
        return self
    end
end

return RoomTemplate