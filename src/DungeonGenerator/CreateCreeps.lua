require 'TerrainTypeCodes'

local Utils = require 'Utils'
local Filters = require 'Filters'

local UNIT_ID_ZOMBIE = FourCC('ndmu')
local UNIT_ID_BOSS_1 = FourCC('nfod')
local UNIT_ID_GUARD_1 = FourCC('nnwq')
local UNIT_ID_WAYGATE = FourCC("nwgt")

local HALLWAY_CREEPS_PER_CELL = 0.03

local RECT_START = gg_rct_Base

local function getRoomCenter(room)
    local center = room.cells[room.width // 2][room.height // 2]
    return Location(center.x, center.y)
end

local function getDoorCenter(door)
    local center
    if door.horizontal then
        center = door.cells[door.width // 2][0]
    else
        center = door.cells[0][door.height // 2]
    end
    return Location(center.x, center.y)
end

local function CreateCreeps(dungeonRect, dungeonRooms, leverRoom, bossRoom)
    local hallwayCells = {}
    for x = GetRectMinX(dungeonRect), GetRectMaxX(dungeonRect), bj_CELLWIDTH do
        for y = GetRectMinY(dungeonRect), GetRectMaxY(dungeonRect), bj_CELLWIDTH do
            if GetTerrainType(x, y) == TILE_HALLWAY then
                table.insert(hallwayCells, Location(x, y))
            end
        end
    end

    local hallwayCreepNumber = #hallwayCells * HALLWAY_CREEPS_PER_CELL
    for _ = 1, hallwayCreepNumber do
        local index = GetRandomInt(1, #hallwayCells)
        local location = hallwayCells[index]
        table.remove(hallwayCells, index)
        CreateUnitAtLoc(Player(PLAYER_NEUTRAL_AGGRESSIVE), UNIT_ID_ZOMBIE, location, GetRandomDirectionDeg())
        RemoveLocation(location)
    end

    local guardRoomCenter = getRoomCenter(leverRoom)
    local guardDoorCenter = getDoorCenter(leverRoom.doors[GetRandomInt(1, #leverRoom.doors)])
    local guard = CreateUnitAtLoc(Player(PLAYER_NEUTRAL_AGGRESSIVE), UNIT_ID_GUARD_1, guardRoomCenter, AngleBetweenPoints(guardRoomCenter, guardDoorCenter))

    local bossRoomCenter = getRoomCenter(bossRoom)
    local bossDoor = bossRoom.doors[GetRandomInt(1, #bossRoom.doors)]
    local bossDoorCenter = getDoorCenter(bossDoor)
    local boss = CreateUnitAtLoc(Player(PLAYER_NEUTRAL_AGGRESSIVE), UNIT_ID_BOSS_1, bossRoomCenter, AngleBetweenPoints(bossRoomCenter, bossDoorCenter))

    local bossRegion = CreateRegion()
    for _, row in pairs(bossRoom.cells) do
        for _, cell in pairs(row) do
            if GetTerrainType(cell.x, cell.y) == TILE_FLOOR then
                for x = cell.x - 64, cell.x + 64, 32 do
                    for y = cell.y - 64, cell.y + 64, 32 do
                        RegionAddCell(bossRegion, x, y)
                    end
                end
            end
        end
    end

    local bossFightStartTrigger = CreateTrigger()
    TriggerRegisterEnterRegion(bossFightStartTrigger, bossRegion, Filters.isPlayerHero)
    TriggerAddAction(bossFightStartTrigger, function()
        ModifyGateBJ(bj_GATEOPERATION_CLOSE, bossDoor.gate)
        DisableTrigger(GetTriggeringTrigger())
    end)

    local bossFightEndTrigger = CreateTrigger()
    TriggerRegisterUnitEvent(bossFightEndTrigger, boss, EVENT_UNIT_DEATH)
    TriggerAddAction(bossFightEndTrigger, Utils.pcall(function()
        ModifyGateBJ(bj_GATEOPERATION_DESTROY, bossDoor.gate)
        local waygate = CreateUnitAtLoc(Player(PLAYER_NEUTRAL_PASSIVE), UNIT_ID_WAYGATE, bossRoomCenter, bj_UNIT_FACING)
        WaygateActivate(waygate, true)
        WaygateSetDestination(waygate, GetRectCenterX(RECT_START), GetRectCenterY(RECT_START))
        RemoveLocation(guardRoomCenter)
        RemoveLocation(guardDoorCenter)
        RemoveLocation(bossRoomCenter)
        RemoveLocation(bossDoorCenter)
    end))
end

return CreateCreeps
