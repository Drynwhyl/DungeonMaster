local targetUnits = {}
local targetLocations = {}
local trigger = CreateTrigger()
TriggerRegisterAnyUnitEventBJ(trigger, EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER)
TriggerRegisterAnyUnitEventBJ(trigger, EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER)
TriggerRegisterAnyUnitEventBJ(trigger, EVENT_PLAYER_UNIT_ISSUED_ORDER)
TriggerAddAction(trigger, function()
    local unit = GetOrderedUnit()
    if targetLocations[unit] ~= nil then
        RemoveLocation(targetLocations[unit])
    end
    targetLocations[unit] = GetOrderPointLoc()
    targetUnits[unit] = GetOrderTargetUnit()
end)

function GetUnitCurrentOrderTarget(unit)
    return targetUnits[unit]
end

function GetUnitCurrentOrderPoint(unit)
    return GetLocationX(targetLocations[unit]), GetLocationY(targetLocations[unit])
end
