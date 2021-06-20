require "TerrainTypeCodes"

local Utils = require "Utils"
local CreateDungeon = require "DungeonGenerator"
local Dialog = require "Dialog"
local Filters = require "Filters"

local WAYGATE_UNIT_ID = FourCC("nwgt")

local playerCurrentWaygate = {}
local waygates = {}

local function createDungeonCallback()
    local waygate = playerCurrentWaygate[GetTriggerPlayer()]
    local seed = GetRandomInt(-2147483648, 2147483647)
    waygate.dungeon = CreateDungeon(seed)
    local start = waygate.dungeon.start
    WaygateSetDestination(waygate.unit, start.x, start.y)
    WaygateActivate(waygate.unit, true)
    print("DUNGEON SEED:", seed)
end

local function destroyDungeonCallback()
    local waygate = playerCurrentWaygate[GetTriggerPlayer()]
    DestroyDungeon(waygate.dungeon)
    waygate.dungeon = nil
    WaygateActivate(waygate.unit, false)
end

Utils.onGameStart(Utils.pcall(function()
    local createDialogData = {
        {
            text = "Создать подземелье",
            hotkey = string.byte("A"),
            callback = createDungeonCallback
        },
        {
            text = "Отмена",
            hotkey = 27,
            callback = nil
        },
    }
    local removeDialogData = {
        {
            text = "Удалить подземелье",
            hotkey = string.byte("A"),
            callback = destroyDungeonCallback
        },
        {
            text = "Отмена",
            hotkey = 27,
            callback = nil
        },
    }
    local generateDungeonDialog = Dialog.create(createDialogData)
    local destroyDungeonDialog = Dialog.create(removeDialogData)

    GroupEnumUnitsInRect(bj_lastCreatedGroup, GetPlayableMapRect(), Filter(function()
        if GetUnitTypeId(GetFilterUnit()) ~= WAYGATE_UNIT_ID then
            return
        end
        local waygate = {}
        table.insert(waygates, waygate)
        waygate.unit = GetFilterUnit()
        waygate.region = CreateRegion()
        local position = GetUnitLoc(waygate.unit)
        local rect = RectFromCenterSizeBJ(position, 2 * bj_CELLWIDTH, 2 * bj_CELLWIDTH)
        RegionAddRect(waygate.region, rect)

        local trigger = CreateTrigger()
        TriggerRegisterEnterRegion(trigger, waygate.region, Filters.isPlayerHero)
        TriggerRegisterLeaveRegion(trigger, waygate.region, Filters.isPlayerHero)
        TriggerAddAction(trigger, function()
            local unit = GetTriggerUnit()
            local player = GetOwningPlayer(unit)
            if GetTriggerEventId() == EVENT_GAME_ENTER_REGION then
                playerCurrentWaygate[player] = waygate
                if waygate.dungeon == nil then
                    DialogDisplay(player, generateDungeonDialog, true)
                else
                    DialogDisplay(player, destroyDungeonDialog, true)
                end
            else
                playerCurrentWaygate[player] = nil
            end
        end)

    end))

end))
