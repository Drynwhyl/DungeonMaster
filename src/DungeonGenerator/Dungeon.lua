require "TerrainTypeCodes"

local Autotable = require "Autotable"
local Room = require "Room"
local RoomTemplateDefinitions = require "RoomTemplateDefinitions"
local CliffDestructables = require "CliffDestructables"

local ROOM_PLACEMENT_ATTEMPTS = 10
local MIN_HALLWAY_WIDTH = 5
local WALL_Z = 60.0
local PATH_BLOCK_ID = FourCC("Ytlc")
local WALLS = CliffDestructables.cityCliffs
WALLS["cccc"] = { id = FourCC("ZTtw"), variations = 1 }
WALLS["aaaa"] = { id = FourCC("OTtw"), variations = 1 }

local TILES_ORDER = {
    TILE_WALL,
    TILE_FLOOR,
    TILE_HALLWAY,
    TILE_DOOR,
}

local TILES = {
    [TILE_FLOOR] = CliffDestructables.tileIcecrownTiledBricks,
    [TILE_HALLWAY] = CliffDestructables.tileIcecrownBlackBricks,
    [TILE_DOOR] = CliffDestructables.tileIcecrownBlackSquares,
    [TILE_WALL] = CliffDestructables.tileIcecrownRuneBricks,
}

---@class Dungeon
---@field private cells number[][]
---@field private rect rect
---@field private roomTemplates RoomTemplate[]
---@field private startRoomTemplates RoomTemplate
---@field private bossRoomTemplates RoomTemplate
---@field private leverRoomTemplates RoomTemplate
---@field private rooms Room[]
---@field private startRoom Room
---@field private bossRoom Room
---@field private leverRoom Room
local Dungeon = {}

---@param rect rect
---@param seed number
---@param roomTemplates RoomTemplate[]
---@param startRoomTemplates RoomTemplate[]
---@param bossRoomTemplates RoomTemplate[]
---@param leverRoomTemplates RoomTemplate[]
---@return Dungeon
function Dungeon:new(rect, seed, roomTemplates, startRoomTemplates, bossRoomTemplates, leverRoomTemplates)
    seed = seed or os.time()

    local instance = {
        cells = Autotable:new(1),
        rooms = {},
        rect = rect,
        seed = seed,
        roomTemplates = roomTemplates or RoomTemplateDefinitions.common.roomTemplates,
        startRoomTemplates = startRoomTemplates or RoomTemplateDefinitions.common.roomTemplates,
        bossRoomTemplates = bossRoomTemplates or RoomTemplateDefinitions.common.roomTemplates,
        leverRoomTemplates = leverRoomTemplates or RoomTemplateDefinitions.common.roomTemplates,
    }

    for i = GetRectMinX(rect), GetRectMaxX(rect), bj_CELLWIDTH do
        for j = GetRectMinY(rect), GetRectMaxY(rect), bj_CELLWIDTH do
            local x = 1 + (i - GetRectMinX(rect)) / bj_CELLWIDTH
            local y = 1 + (j - GetRectMinY(rect)) / bj_CELLWIDTH
            instance.cells[x][y] = TILE_EMPTY
        end
    end

    setmetatable(instance, self)
    self.__index = self
    return instance
end

---@param x number
---@param y number
---@param z number
---@param tile number
---@param destructables table<string, table>
---@param globalOffsetX number
---@param globalOffsetY number
---@param visited destructable[][]
---@param pathBlockId number
---@param variationFunc fun(param:table):number
function Dungeon:placeDestructable(x, y, z, tile, destructables, globalOffsetX, globalOffsetY, visited, pathBlockId, variationFunc)
    local map = {
        { "a", "a", "a", "a" },
        { "a", "c", "c", "a" },
        { "a", "c", "c", "a" },
        { "a", "a", "a", "a" },
    }

    variationFunc = variationFunc or function(object)
        return math.random(0, object.variations - 1)
    end

    -- Check left
    if self:getCell(x - 1, y) == tile then map[2][1] = "c"; map[3][1] = "c" end
    -- Check right
    if self:getCell(x + 1, y) == tile then map[2][4] = "c"; map[3][4] = "c" end
    -- Check up
    if self:getCell(x, y + 1) == tile then map[1][2] = "c"; map[1][3] = "c" end
    -- Check down
    if self:getCell(x, y - 1) == tile then map[4][2] = "c"; map[4][3] = "c" end

    -- Check down-left
    if self:getCell(x - 1, y - 1) == tile then map[4][1] = "c" end
    -- Check up-left
    if self:getCell(x - 1, y + 1) == tile then map[1][1] = "c" end
    -- Check up-right
    if self:getCell(x + 1, y + 1) == tile then map[1][4] = "c" end
    -- Check down-right
    if self:getCell(x + 1, y - 1) == tile then map[4][4] = "c" end

    local cellUpLeft = destructables[map[2][1] .. map[1][1] .. map[1][2] .. map[2][2]]
    local cellDownLeft = destructables[map[4][1] .. map[3][1] .. map[3][2] .. map[4][2]]
    local cellUpRight = destructables[map[2][3] .. map[1][3] .. map[1][4] .. map[2][4]]
    local cellDownRight = destructables[map[4][3] .. map[3][3] .. map[3][4] .. map[4][4]]

    local varUpLeft = variationFunc(cellUpLeft)
    local varDownLeft = variationFunc(cellDownLeft)
    local varUpRight = variationFunc(cellUpRight)
    local varDownRight = variationFunc(cellDownRight)

    local mapX = x * bj_CELLWIDTH + GetRectMinX(self.rect)
    local mapY = y * bj_CELLWIDTH + GetRectMinY(self.rect)
    if not visited[x - 1][y] then
        visited[x - 1][y] = CreateDestructableZ(cellUpLeft.id, mapX - 64 + globalOffsetX, mapY + 64 + globalOffsetY, z, 0, 1, varUpLeft)
    end
    if not visited[x - 1][y - 1] then
        visited[x - 1][y - 1] = CreateDestructableZ(cellDownLeft.id, mapX - 64 + globalOffsetX, mapY - 64 + globalOffsetY, z, 0, 1, varDownLeft)
    end
    if not visited[x][y] then
        visited[x][y] = CreateDestructableZ(cellUpRight.id, mapX + 64 + globalOffsetX, mapY + 64 + globalOffsetY, z, 0, 1, varUpRight)
    end
    if not visited[x][y - 1] then
        visited[x][y - 1] = CreateDestructableZ(cellDownRight.id, mapX + 64 + globalOffsetX, mapY - 64 + globalOffsetY, z, 0, 1, varDownRight)
    end

    if pathBlockId then
        CreateDestructable(pathBlockId, mapX, mapY, 0, 1, 0)
    end
end

local function getCliffVariation(cliffData)
    if cliffData.name == "acac" or cliffData.name == "caca" then
        return 2
    end
    return math.random(0, cliffData.variations - 1)
end

function Dungeon:createWalls(visitedCells)
    local visited = Autotable:new(1)
    for x = 1, self:getWidth() do
        for y = 1, self:getHeight() do
            if self:getCell(x, y) == TILE_WALL and not visitedCells[x][y] then
                self:placeDestructable(x, y, WALL_Z + #TILES, TILE_WALL, WALLS, 64, -64, visited, PATH_BLOCK_ID, getCliffVariation)
                visitedCells[x][y] = true
            end
        end
    end
    for originX, row in pairs(visitedCells) do
        for originY in pairs(row) do
            for x = originX - 1, originX + 1 do
                for y = originY - 1, originY + 1 do
                    self:setCell(x, y, TILE_WALL)
                end
            end
        end
    end
end

function Dungeon:createTiles(visitedCells)
    local z = WALL_Z + 1
    for _, tile in ipairs(TILES_ORDER) do
        local visited = Autotable:new(1)
        for x = 1, self:getWidth() do
            for y = 1, self:getHeight() do
                if self:getCell(x, y) == tile and not visitedCells[x][y] then
                    self:placeDestructable(x, y, z, tile, TILES[tile], 0, 0, visited)
                end
            end
        end
        z = z + 1
    end
end

function Dungeon:renderOnMap()
    local visitedCells = Autotable:new(1)
    self:createWalls(visitedCells)
    self:createTiles(visitedCells)
end

function Dungeon:generate()
    math.randomseed(self.seed)
    self:placeRooms()
    --TODO: add connect rooms
    --TODO: add create creeps
    self:renderOnMap()
end

function Dungeon:getWidth()
    return #self.cells
end

function Dungeon:getHeight()
    return #self.cells[1]
end

function Dungeon:getCell(x, y, doPrint)
    if x < 1 or x > self:getWidth() or y < 1 or y > self:getHeight() then
        if doPrint then
            print("ERROR in Dungeon:getCell out of range: x =", x, "y =", y, "width =", self:getWidth(), "height =", self:getHeight())
        end
        return TILE_UNKNOWN
    end
    return self.cells[x][y] or TILE_EMPTY
end

function Dungeon:setCell(x, y, tile)
    if x < 1 or x > self:getWidth() or y < 1 or y > self:getHeight() then
        print("ERROR: In Dungeon:setCell array index out of range: x=" .. x .. " y=" .. y)
        return
    end
    if tile == TILE_WALL then
        print("tile wall", x, y)
    end
    self.cells[x][y] = tile
end

function Dungeon:cellsAreEmpty(originX, originY, size)
    for x = originX - size, originX + size do
        for y = originY - size, originY + size do
            if self:getCell(x, y) ~= TILE_EMPTY then
                return false
            end
        end
    end
    return true
end

function Dungeon:isRoomPlaceable(originX, originY, roomTemplate)
    for x = 1, roomTemplate:getWidth() do
        for y = 1, roomTemplate:getHeight() do
            -- TODO: Replace with cheaper algorithm - just add hallway width to room dimension and iterate over all room cells
            if not self:cellsAreEmpty(originX + x, originY + y, MIN_HALLWAY_WIDTH) then
                return false
            end
        end
    end
    return true
end

function Dungeon:placeRoomForReal(originX, originY, roomTemplate)
    if not self:isRoomPlaceable(originX, originY, roomTemplate) then
        return nil
    end
    for x = 1, roomTemplate:getWidth() do
        for y = 1, roomTemplate:getHeight() do
            -- TODO: Possible bug, should subtract 1 from coordinates in setCell calls
            self:setCell(originX + x, originY + y, roomTemplate:getCell(x, y))
        end
    end
    return Room:new(originX, originY, roomTemplate:getWidth(), roomTemplate:getHeight())
end

---@param templates RoomTemplate[]
---@param attempts number
---@return Room
function Dungeon:placeRandomRoom(templates, attempts)
    attempts = attempts or ROOM_PLACEMENT_ATTEMPTS
    for _ = 1, attempts do
        local index = math.random(1, #templates)
        local angle = math.random(0, 3) * 90
        local template = templates[index]:rotate(angle)
        local x = math.random(1, self:getWidth() - template:getWidth())
        local y = math.random(1, self:getHeight() - template:getHeight())
        local room = self:placeRoomForReal(x, y, template)
        if room then
            return room
        end
    end
    return nil
end

---@return void
function Dungeon:placeRooms()
    self.startRoom = self:placeRandomRoom(self.startRoomTemplates)
    self.bossRoom = self:placeRandomRoom(self.bossRoomTemplates)
    self.leverRoom = self:placeRandomRoom(self.leverRoomTemplates)
    repeat
        local room = self:placeRandomRoom(self.roomTemplates, 10)
        if room then
            table.insert(self.rooms, room)
            print("room #" .. #self.rooms)
        end
    until room == nil
end

---@return void
function Dungeon:clear()
    EnumDestructablesInRect(self.rect, nil, function()
        RemoveDestructable(GetEnumDestructable())
    end)
    EnumItemsInRect(self.rect, nil, function()
        RemoveItem(GetEnumPlayer())
    end)
    GroupEnumUnitsInRect(bj_lastCreatedGroup, self.rect, nil)
    ForGroup(bj_lastCreatedGroup, function()
        RemoveUnit(GetEnumUnit())
    end)
end

return Dungeon