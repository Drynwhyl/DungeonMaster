require "TerrainTypeCodes"

local Utils = require "Utils"
local Dungeon = require "Dungeon"
local Dialog = require "Dialog"
local Filters = require "Filters"
local WC3Math = require "WC3Math"
local CreateDungeonDialog = require "CreateDungeonDialog"

local WAYGATE_UNIT_ID = FourCC("nwgt")

local playerCurrentWaygate = {}
---@field dungeon Dungeon
local waygates = {}

local function createDungeonCallback()
    local waygate = playerCurrentWaygate[GetTriggerPlayer()]
    waygate.dungeon = Dungeon:new(gg_rct_Dungeon, 1)
    waygate.dungeon:generate()
    local startX, startY  = waygate.dungeon:toMapCoords(waygate.dungeon.startRoom:getCenter())
    WaygateSetDestination(waygate.unit, startX, startY)
    WaygateActivate(waygate.unit, true)
    print("DUNGEON SEED:", WC3Math.baseN(waygate.dungeon.seed, 91))
end

local function destroyDungeonCallback()
    local waygate = playerCurrentWaygate[GetTriggerPlayer()]
    waygate.dungeon:clear()
    waygate.dungeon = nil
    WaygateActivate(waygate.unit, false)
end

---@param createDungeonDialog CreateDungeonDialog
---@param player player
local function createDungeonHandler(createDungeonDialog, player)
    local waygate = playerCurrentWaygate[player]
    if createDungeonDialog.playerData[player].loadMode == false then
        createDungeonDialog:close(player)
        waygate.dungeon = Dungeon:new(gg_rct_Dungeon, createDungeonDialog.level)
        waygate.dungeon:generate()
        local startX, startY  = waygate.dungeon:toMapCoords(waygate.dungeon.startRoom:getCenter())
        WaygateSetDestination(waygate.unit, startX, startY)
        WaygateActivate(waygate.unit, true)
        print("DUNGEON SEED:", WC3Math.baseN(waygate.dungeon.seed, 91))
    end
end

Utils.onGameStart(Utils.pcall(function()
    local createDungeonDialog = CreateDungeonDialog:new(createDungeonHandler)

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
                    createDungeonDialog:open(player)
                    --DialogDisplay(player, generateDungeonDialog, true)
                else
                    DialogDisplay(player, destroyDungeonDialog, true)
                end
            else
                playerCurrentWaygate[player] = nil
            end
        end)

    end))
end))
