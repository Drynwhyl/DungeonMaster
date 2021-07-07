local Timer = require "Timer"
local WC3Math = require "WC3Math"
local Utils = require "Utils"

local Missiles = {}

local DEFAULT_Z = 44.0
local DEFAULT_COLLISION = 64.0
local MAX_COLLISION = 256.0

function Missiles.createHoming(effectModel, source, target, speed, arc, handler)
    local x, y = GetUnitX(source), GetUnitY(source)
    local fx = AddSpecialEffect(effectModel, x, y)
    BlzSetSpecialEffectZ(fx, DEFAULT_Z)
    BlzSetSpecialEffectYaw(fx, math.rad(WC3Math.angleBetweenUnits(source, target)))
    local action
    action = Timer.register(function()
        local targetX = GetUnitX(target)
        local targetY = GetUnitY(target)
        local moveDist = speed * Timer.PERIOD
        local targetDist = WC3Math.distanceBetweenPoints(x, y, targetX, targetY)

        if targetDist <= DEFAULT_COLLISION or targetDist <= moveDist + 1 then
            DestroyEffect(fx)
            Timer.unregister(action)
            handler()
        end

        local angle = WC3Math.angleBetweenPoints(x, y, targetX, targetY)
        x, y = WC3Math.polarProjection(x, y, moveDist, angle)

        local loc = Location(x, y)
        BlzSetSpecialEffectX(fx, x)
        BlzSetSpecialEffectY(fx, y)
        BlzSetSpecialEffectZ(fx, GetLocationZ(loc) + DEFAULT_Z)
        BlzSetSpecialEffectYaw(fx, math.rad(angle))
    end)
end

local function findClosestUnit(group, x, y)
    local closestUnit = FirstOfGroup(group)
    local closestDist = 99999999
    ForGroup(group, function()
        local unit = GetEnumUnit()
        local dist = WC3Math.distanceBetweenPoints(GetUnitX(unit), GetUnitY(unit), x, y)
        if dist < closestDist then
            closestDist = dist
            closestUnit = unit
        end
    end)
    return closestUnit
end

function Missiles.create(effectModel, source, targetX, targetY, speed, targetFilter, collisionRange, arc, handler)
    local x = GetUnitX(source)
    local y = GetUnitY(source)
    local fx = AddSpecialEffect(effectModel, x, y)
    BlzSetSpecialEffectYaw(fx, math.rad(WC3Math.angleBetweenPoints(x, y, targetX, targetY)))
    BlzSetSpecialEffectZ(fx, DEFAULT_Z)

    local action
    action = Timer.register(Utils.pcall(function()
        local moveDist = speed * Timer.PERIOD
        local targetDist = WC3Math.distanceBetweenPoints(x, y, targetX, targetY)

        local group = CreateGroup()
        local rangeFilter = Filter(function()
            local unit = GetFilterUnit()
            return WC3Math.distanceBetweenPoints(GetUnitX(unit), GetUnitY(unit), x, y) <= collisionRange + BlzGetUnitCollisionSize(unit)
        end)
        local combinedFilter = And(targetFilter, rangeFilter)
        GroupEnumUnitsInRange(group, x, y, collisionRange + MAX_COLLISION, combinedFilter)
        DestroyBoolExpr(combinedFilter)
        DestroyBoolExpr(rangeFilter)
        if targetDist <= DEFAULT_COLLISION or targetDist <= moveDist + 1 or CountUnitsInGroup(group) > 0 then
            DestroyEffect(fx)
            Timer.unregister(action)
            local target = findClosestUnit(group, x, y)
            GroupClear(group)
            DestroyGroup(group)
            handler(target)
        end

        local angle = WC3Math.angleBetweenPoints(x, y, targetX, targetY)
        x, y = WC3Math.polarProjection(x, y, moveDist, angle)

        local loc = Location(x, y)
        BlzSetSpecialEffectX(fx, x)
        BlzSetSpecialEffectY(fx, y)
        BlzSetSpecialEffectZ(fx, GetLocationZ(loc) + DEFAULT_Z)
        RemoveLocation(loc)
    end))
end

return Missiles
