require "TerrainTypeCodes"

local Autotable = require "Autotable"
local Room = require "Room"
local RoomTemplateDefinitions = require "RoomTemplateDefinitions"
local CliffDestructables = require "CliffDestructables"
local Node = require "Node"
local PriorityQueue = require "PriorityQueue"
local WC3Math = require "WC3Math"
local Filters = require "Filters"
local Utils = require "Utils"
local CreepTypes = require "CreepTypes"

local ROOM_PLACEMENT_ATTEMPTS = 20
local MIN_HALLWAY_WIDTH = 5
local WALL_Z = 60.0
local PATH_BLOCK_ID = FourCC("Ytlc")
local WALLS = CliffDestructables.cityCliffs
WALLS["cccc"] = { id = FourCC("ZTtw"), variations = 1 }
WALLS["aaaa"] = { id = FourCC("OTtw"), variations = 1 }

local TILES_ORDER = {
    --TILE_WALL,
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
---@field private startRoomTemplates RoomTemplate[]
---@field private bossRoomTemplates RoomTemplate[]
---@field private leverRoomTemplates RoomTemplate[]
---@field public rooms Room[]
---@field public startRoom Room
---@field public bossRoom Room
---@field public leverRoom Room
---@field public level number
local Dungeon = {}

---@param rect rect
---@param seed number
---@param roomTemplates RoomTemplate[]
---@param startRoomTemplates RoomTemplate[]
---@param bossRoomTemplates RoomTemplate[]
---@param leverRoomTemplates RoomTemplate[]
---@return Dungeon
function Dungeon:new(rect, level, seed, roomTemplates, startRoomTemplates, bossRoomTemplates, leverRoomTemplates)
    seed = seed or os.time()

    local instance = {
        cells = Autotable:new(1),
        rooms = {},
        rect = rect,
        seed = seed,
        level = level,
        roomTemplates = roomTemplates or RoomTemplateDefinitions.common.roomTemplates,
        startRoomTemplates = startRoomTemplates or RoomTemplateDefinitions.common.startRoomTemplates,
        bossRoomTemplates = bossRoomTemplates or RoomTemplateDefinitions.common.bossRoomTemplates,
        leverRoomTemplates = leverRoomTemplates or RoomTemplateDefinitions.common.leverRoomTemplates,
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


local destCounter = 0
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
    if self:getCell(x - 1, y) == tile then
        map[2][1] = "c";
        map[3][1] = "c"
    end
    -- Check right
    if self:getCell(x + 1, y) == tile then
        map[2][4] = "c";
        map[3][4] = "c"
    end
    -- Check up
    if self:getCell(x, y + 1) == tile then
        map[1][2] = "c";
        map[1][3] = "c"
    end
    -- Check down
    if self:getCell(x, y - 1) == tile then
        map[4][2] = "c";
        map[4][3] = "c"
    end

    -- Check down-left
    if self:getCell(x - 1, y - 1) == tile then
        map[4][1] = "c"
    end
    -- Check up-left
    if self:getCell(x - 1, y + 1) == tile then
        map[1][1] = "c"
    end
    -- Check up-right
    if self:getCell(x + 1, y + 1) == tile then
        map[1][4] = "c"
    end
    -- Check down-right
    if self:getCell(x + 1, y - 1) == tile then
        map[4][4] = "c"
    end

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
        visited[x - 1][y] = true
        CreateDestructableZ(cellUpLeft.id, mapX - 64 + globalOffsetX, mapY + 64 + globalOffsetY, z, 0, 1, varUpLeft)
        destCounter = destCounter + 1
    end
    if not visited[x - 1][y - 1] then
        visited[x - 1][y - 1] = true
        CreateDestructableZ(cellDownLeft.id, mapX - 64 + globalOffsetX, mapY - 64 + globalOffsetY, z, 0, 1, varDownLeft)
        destCounter = destCounter + 1
    end
    if not visited[x][y] then
        visited[x][y] = true
        CreateDestructableZ(cellUpRight.id, mapX + 64 + globalOffsetX, mapY + 64 + globalOffsetY, z, 0, 1, varUpRight)
        destCounter = destCounter + 1
    end
    if not visited[x][y - 1] then
        visited[x][y - 1] = true
        CreateDestructableZ(cellDownRight.id, mapX + 64 + globalOffsetX, mapY - 64 + globalOffsetY, z, 0, 1, varDownRight)
        destCounter = destCounter + 1
    end

    if pathBlockId then
        CreateDestructable(pathBlockId, mapX, mapY, 0, 1, 0)
        destCounter = destCounter + 1
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
                self:placeDestructable(x, y, WALL_Z + #TILES_ORDER, TILE_WALL, WALLS, 64, -64, visited, PATH_BLOCK_ID, getCliffVariation)
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

function Dungeon:createTiles(visitedCells, tiles, z)
    z = z or WALL_Z
    for _, tile in ipairs(tiles) do
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

local function heuristic(x1, y1, x2, y2)
    return math.abs(x1 - x2) + math.abs(y1 - y2)
end

local directions = {
    up = { x = 0, y = 1, horizontal = false },
    down = { x = 0, y = -1, horizontal = false },
    left = { x = -1, y = 0, horizontal = true },
    right = { x = 1, y = 0, horizontal = true },
}

function Dungeon:cellContainsPathing(x, y, pathing)
    for _, dir in pairs(directions) do
        if self:getCell(x + dir.x, y + dir.y) == pathing then
            return true
        end
    end
    return false
end

---@param nodes Node[][]
---@param startDoor Door
---@param finishDoor Door
function Dungeon:findPath(nodes, startDoor, finishDoor)
    local graph = PriorityQueue()

    local start = startDoor:findNearestNode(nodes, MIN_HALLWAY_WIDTH)
    local goal = finishDoor:findNearestNode(nodes, MIN_HALLWAY_WIDTH)

    if start == nil or goal == nil then
        print("ERROR: start/finish nodes are nil!")
        return
    end

    graph:put(start, 0)

    ---@type table<Node, Node>
    local cameFrom = { [start] = start }

    ---@type table<Node, number>
    local costSoFar = { [start] = 0 }

    local found = false
    while not graph:empty() do
        ---@type Node
        local current = graph:pop()
        if current == goal then
            print("FOUND!")
            found = true
            break
        end

        for _, next in pairs(current.neighbours) do
            local prev = cameFrom[current]
            local moveCost = 0

            local prevMoveType
            if prev:getCenterX() - current:getCenterX() == 0 then
                prevMoveType = 0
            else
                prevMoveType = 1
            end

            local nextMoveType
            if next:getCenterX() - current:getCenterX() == 0 then
                prevMoveType = 0
            else
                prevMoveType = 1
            end

            if prevMoveType == nextMoveType then
                moveCost = moveCost + 4
            else
                moveCost = moveCost + 5
            end

            if next.hallway == true then
                moveCost = 0
            end

            local newCost = costSoFar[current] + moveCost
            if costSoFar[next] == nil or newCost < costSoFar[next] then
                costSoFar[next] = newCost
                local priority = newCost + heuristic(
                        goal:getCenterX(), goal:getCenterY(),
                        next:getCenterX(), next:getCenterY()
                )
                graph:put(next, priority)
                cameFrom[next] = current
            end
        end
    end

    -- Draw hallways
    local count = 0
    if found then
        local current = goal;
        local path = { current }
        while true do
            count = count + 1
            current.hallway = true
            self:fillCells(current:getCenterX(), current:getCenterY(), TILE_HALLWAY, 3)
            for i = current.x, current.x + current.width do
                for j = current.y, current.y + current.height do
                    if self:getCell(i, j) == TILE_HALLWAY and self:cellContainsPathing(i, j, TILE_EMPTY) then
                        -- TODO move wall texture generation outside find pathing function: scan every map cell and do the same algorithm
                        self:setCell(i, j, TILE_WALL)
                    end
                end
            end
            if current == start then
                break
            end
            current = cameFrom[current]
            table.insert(path, current)
        end
    end
    print("generation done...")

    return found
end

function Dungeon:connectRooms()
    local nodes = Node:createGraph(self, MIN_HALLWAY_WIDTH)
    self:findPath(nodes, self.startRoom.doors[1], self.bossRoom.doors[1])
    self:findPath(nodes, self.startRoom.doors[1], self.leverRoom.doors[math.random(1, #self.leverRoom.doors)])

    local allRooms = { self.leverRoom }
    for _, room in pairs(self.rooms) do
        table.insert(allRooms, room)
    end

    local connectedRooms = {}
    for _, room in pairs(allRooms) do
        for _, otherRoom in pairs(allRooms) do
            if room ~= otherRoom and connectedRooms[room] ~= otherRoom and connectedRooms[otherRoom] ~= room then
                local startIndex = math.random(1, #room.doors);
                local finishIndex = math.random(1, #otherRoom.doors)
                local startDoor = room.doors[startIndex]
                local finishDoor = otherRoom.doors[finishIndex]

                local connected = self:findPath(nodes, startDoor, finishDoor)
                if connected then
                    room.doors[startIndex].visited = true
                    otherRoom.doors[finishIndex].visited = true
                    connectedRooms[room] = otherRoom
                    connectedRooms[otherRoom] = room
                    if math.random(1, 2) == 1 then
                        --break
                    end
                end
                --hallwayCount = hallwayCount + 1
                --print("hallway count", hallwayCount)
            end
        end
    end

    for _, room in pairs(allRooms) do
        for _, door in pairs(room.doors) do
            if door.visited ~= true then
                for x = door.x, door.x + (door.horizontal and door.size or 0) do
                    for y = door.y, door.y + (door.horizontal and 0 or door.size) do
                        self:setCell(x, y, TILE_WALL)
                    end
                end
            end
        end
    end
end

function Dungeon:toMapCoords(x, y)
    return GetRectMinX(self.rect) + x * bj_CELLWIDTH, GetRectMinY(self.rect) + y * bj_CELLWIDTH
end

local function scaleCreep(creep, level)
    BlzSetUnitIntegerField(creep, UNIT_IF_LEVEL, level)
    BlzSetUnitMaxHP(creep, BlzGetUnitMaxHP(creep) * level)
    SetWidgetLife(creep, BlzGetUnitMaxHP(creep))
    BlzSetUnitBaseDamage(creep, BlzGetUnitBaseDamage(creep, 0) * level - 1,0)
    BlzSetUnitDiceSides(creep, BlzGetUnitDiceSides(creep, 0) * level,0)
    BlzSetUnitArmor(creep, BlzGetUnitArmor(creep) * level)
end

function Dungeon:createCreeps()
    --local UNIT_ID_ZOMBIE = FourCC("ndmu")
    local UNIT_ID_ZOMBIE = CreepTypes.tier1[1]
    local UNIT_ID_BOSS_1 = FourCC("nfod")
    local UNIT_ID_GUARD_1 = FourCC("nnwq")
    local UNIT_ID_WAYGATE = FourCC("nwgt")
    local DESTRUCTABLE_ID_HORIZONTAL_DOOR = FourCC("ITg1")
    local DESTRUCTABLE_ID_VERTICAL_DOOR = FourCC("ITg3")
    local DESTRUCTABLE_ID_FOOTSWITCH = FourCC("DTfp")
    local HALLWAY_CREEPS_PER_CELL = 0.03
    local RECT_START = gg_rct_Base

    local hallwayCells = {}
    for x = 1, self:getWidth() do
        for y = 1, self:getHeight() do
            if self:getCell(x, y) == TILE_HALLWAY then
                table.insert(hallwayCells, { x = x, y = y })
            end
        end
    end

    local hallwayCreepNumber = math.floor(#hallwayCells * HALLWAY_CREEPS_PER_CELL)
    for _ = 1, hallwayCreepNumber do
        local index = math.random(1, #hallwayCells)
        local cell = hallwayCells[index]
        local x, y = self:toMapCoords(cell.x, cell.y)
        table.remove(hallwayCells, index)
        local unit = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), UNIT_ID_ZOMBIE, x, y, math.random(0, 360))
        scaleCreep(unit, self.level)
    end

    local guardX, guardY = self:toMapCoords(self.leverRoom:getCenter())
    local guardDoorX, guardDoorY = self:toMapCoords(self.leverRoom.doors[1]:getCenter())
    local guardFacing = WC3Math.angleBetweenPoints(guardX, guardY, guardDoorX, guardDoorY)
    local guard = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), UNIT_ID_GUARD_1, guardX, guardY, guardFacing)

    local bossX, bossY = self:toMapCoords(self.bossRoom:getCenter())
    local doorX, doorY = self:toMapCoords(self.bossRoom.doors[1]:getCenter())
    local bossFacing = WC3Math.angleBetweenPoints(bossX, bossY, doorX, doorY)
    local boss = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), UNIT_ID_BOSS_1, bossX, bossY, bossFacing)

    local roomCenterX, roomCenterY = self:toMapCoords(self.leverRoom:getCenter())
    local footSwitch = CreateDestructable(DESTRUCTABLE_ID_FOOTSWITCH, roomCenterX, roomCenterY, 0, 1, 0)
    local footSwitchRegion = CreateRegion()
    local footSwitchRect = Rect(
            roomCenterX - 0.5 * bj_CELLWIDTH,
            roomCenterY - 0.5 * bj_CELLWIDTH,
            roomCenterX + 0.5 * bj_CELLWIDTH,
            roomCenterY + 0.5 * bj_CELLWIDTH
    )
    RegionAddRect(footSwitchRegion, footSwitchRect)
    RemoveRect(footSwitchRect)

    local bossRoomDoor = self.bossRoom.doors[1]
    local centerX, centerY = self:toMapCoords(bossRoomDoor:getCenter())
    local gate = CreateDestructable(bossRoomDoor.horizontal and DESTRUCTABLE_ID_HORIZONTAL_DOOR or DESTRUCTABLE_ID_VERTICAL_DOOR, centerX, centerY, 270.0, 1.0, -1)
    bossRoomDoor.gate = gate
    SetDestructableInvulnerable(gate, true)

    local trigger = CreateTrigger()
    TriggerRegisterEnterRegion(trigger, footSwitchRegion, Filter(function()
        if GetPlayerController(GetOwningPlayer(GetFilterUnit())) == MAP_CONTROL_USER and IsDestructableAliveBJ(footSwitch) then
            KillDestructable(footSwitch)
            ModifyGateBJ(bj_GATEOPERATION_OPEN, gate)
            RemoveRegion(footSwitchRegion)
            DestroyTrigger(trigger)
        end
    end))

    local bossRegion = CreateRegion()
    for x = self.bossRoom.x, self.bossRoom.x + self.bossRoom.width do
        for y = self.bossRoom.y, self.bossRoom.y + self.bossRoom.height do
            if self:getCell(x, y) == TILE_FLOOR then
                local realX, realY = self:toMapCoords(x, y)
                for i = realX - 64, realX + 64, 32 do
                    for j = realY - 64, realY + 64, 32 do
                        RegionAddCell(bossRegion, i, j)
                    end
                end
            end
        end
    end

    local bossFightStartTrigger = CreateTrigger()
    TriggerRegisterEnterRegion(bossFightStartTrigger, bossRegion, Filters.isPlayerHero)
    TriggerAddAction(bossFightStartTrigger, function()
        ModifyGateBJ(bj_GATEOPERATION_CLOSE, gate)
        RemoveRegion(bossRegion)
        DestroyTrigger(GetTriggeringTrigger())
    end)

    local bossFightEndTrigger = CreateTrigger()
    TriggerRegisterUnitEvent(bossFightEndTrigger, boss, EVENT_UNIT_DEATH)
    TriggerAddAction(bossFightEndTrigger, Utils.pcall(function()
        ModifyGateBJ(bj_GATEOPERATION_DESTROY, gate)
        local waygate = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), UNIT_ID_WAYGATE, bossX, bossY, bj_UNIT_FACING)
        WaygateActivate(waygate, true)
        WaygateSetDestination(waygate, GetRectCenterX(RECT_START), GetRectCenterY(RECT_START))
        DestroyTrigger(GetTriggeringTrigger())
    end))
end

function Dungeon:renderOnMap()
    local visitedCells = Autotable:new(1)
    self:createTiles(visitedCells, TILES_ORDER)
    local tilesCount = destCounter
    print("tiles count: ", tilesCount)
    self:createWalls(visitedCells)
    local wallsCount = destCounter - tilesCount
    print("walls count: ", wallsCount)
    --TODO: this causes to many fps drop
    --self:createTiles(Autotable:new(1), { TILE_WALL }, WALL_Z + 7)
    print("tiles2 count: ", destCounter - wallsCount)
    print("total count: ", destCounter)
    self.weatherEffect = AddWeatherEffect(self.rect, FourCC("FDbh"))
    EnableWeatherEffect(self.weatherEffect, true)
end

function Dungeon:generate()
    math.randomseed(self.seed)
    self:placeRooms()
    self:connectRooms()
    self:renderOnMap()
    self:createCreeps()
end

function Dungeon:getWidth()
    return #self.cells
end

function Dungeon:getHeight()
    return #self.cells[1]
end

function Dungeon:getCell(x, y)
    if x < 1 or x > self:getWidth() or y < 1 or y > self:getHeight() then
        return TILE_UNKNOWN
    end
    return self.cells[x][y] or TILE_EMPTY
end

function Dungeon:setCell(x, y, tile)
    if x < 1 or x > self:getWidth() or y < 1 or y > self:getHeight() then
        print("ERROR: In Dungeon:setCell array index out of range: x=" .. x .. " y=" .. y)
        return
    end
    self.cells[x][y] = tile
end

function Dungeon:fillCells(centerX, centerY, tile, size)
    size = size and size - 1 or 0
    for x = centerX - size, centerX + size do
        for y = centerY - size, centerY + size do
            self:setCell(x, y, tile)
        end
    end
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
            self:setCell(originX + x - 1, originY + y - 1, roomTemplate:getCell(x, y))
        end
    end
    return Room:new(self, originX, originY, roomTemplate:getWidth(), roomTemplate:getHeight())
end

---@param templates RoomTemplate[]
---@param attempts number
---@return Room
function Dungeon:placeRandomRoom(templates, attempts)
    attempts = attempts or 100000
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
        local room = self:placeRandomRoom(self.roomTemplates, ROOM_PLACEMENT_ATTEMPTS)
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
        RemoveItem(GetEnumItem())
    end)
    GroupEnumUnitsInRect(bj_lastCreatedGroup, self.rect, nil)
    ForGroup(bj_lastCreatedGroup, function()
        RemoveUnit(GetEnumUnit())
    end)
    RemoveWeatherEffect(self.weatherEffect)
end

return Dungeon