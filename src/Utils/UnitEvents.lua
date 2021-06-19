local Utils = require "Utils"

local UnitEvents = {}

local DETECT_UNIT_REMOVED_ABILITY_ID = FourCC("A  #")

local enumUnit
local onCreateTrigger = CreateTrigger()
local onRemoveTrigger = CreateTrigger()

TriggerRegisterAnyUnitEventBJ(onRemoveTrigger, EVENT_PLAYER_UNIT_ISSUED_ORDER)
TriggerAddCondition(onRemoveTrigger, Condition(function()
    return GetIssuedOrderId() == OrderId("undefend")
            and GetUnitAbilityLevel(GetTriggerUnit(), DETECT_UNIT_REMOVED_ABILITY_ID) == 0 --Unit already removed
end))
TriggerRegisterEnterRectSimple(onCreateTrigger, GetPlayableMapRect())
for i = 0, bj_MAX_PLAYER_SLOTS - 1 do
    SetPlayerAbilityAvailable(Player(i), DETECT_UNIT_REMOVED_ABILITY_ID, false)
end

function UnitEvents.onCreate(func)
    TriggerAddAction(onCreateTrigger, func)
end

function UnitEvents.onRemove(func)
    TriggerAddAction(onRemoveTrigger, func)
end

function UnitEvents.getUnit()
    return GetTriggerUnit() or enumUnit
end

function UnitEvents.registerAnyUnitEvent(event)
    local trigger = CreateTrigger()
    local count = 0
    UnitEvents.onCreate(function()
        TriggerRegisterUnitEvent(trigger, UnitEvents.getUnit(), event)
        counter = counter + 1
    end)
end

Utils.onGameStart(function()
    local group = CreateGroup()
    GroupEnumUnitsInRect(group, GetPlayableMapRect())
    ForGroup(group, function()
        enumUnit = GetEnumUnit()
        UnitAddAbility(enumUnit, DETECT_UNIT_REMOVED_ABILITY_ID)
        UnitMakeAbilityPermanent(enumUnit, true, DETECT_UNIT_REMOVED_ABILITY_ID)
        TriggerExecute(onCreateTrigger)
    end)
end)

return UnitEvents