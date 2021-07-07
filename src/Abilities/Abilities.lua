local Missiles = require "Missiles"
local CastSystem = require "CastSystem"
local Utils = require "Utils"
local WC3Math = require "WC3Math"
local Timer = require "Timer"
local PlayerHero = require "HeroPick"

---@class AbilityData
---@field public abilityId number
---@field public animation number|string
---@field public animationDamagePoint number
---@field public animationDamagePoint number
---@field public animationBackswingPoint number
---@field public animationMode number
---@field public startHandler function
---@field public finishHandler function
local AbilityData = {}

---type AbilityData[]
local ABILITIES = {}

local function SilentDestroyEffect(effect)
    BlzSetSpecialEffectX(effect, GetRectCenterX(gg_rct_HeroPick))
    BlzSetSpecialEffectY(effect, GetRectCenterY(gg_rct_HeroPick))
    DestroyEffect(effect)
end

-- -------------------------------------------------------------------------
-- VAMPIRE ABILITIES
-- -------------------------------------------------------------------------

local ABILITY_ID_TRANSFUSION = FourCC("A002")
local ABILITY_ID_TIDES_OF_BLOOD = FourCC("A003")
local ABILITY_ID_BLOOD_PLAGUE = FourCC("A004")
local ABILITY_ID_BLOOD_MINISTRY = FourCC("A005")
local BUFF_ID_BLOOD_PLAGUE = FourCC("B000")

ABILITIES.TRANSFUSION = {
    abilityId = ABILITY_ID_TRANSFUSION,
    animation = 4,
    animationTime = 1.5,
    animationDamagePoint = 0.85,
    animationBackswingPoint = 1.2,
    animationMode = CastSystem.ANIMATION_MODE_FIT,
    startHandler = function()
    end,
    finishHandler = function(castData)
        local caster = castData.caster
        local target = castData.target
        DestroyEffect(AddSpecialEffectTarget("Objects\\Spawnmodels\\Human\\HumanBlood\\HumanBloodLarge0.mdl", target, "chest"))
        UnitDamageTarget(caster, target, 100, false, true, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_MAGIC, WEAPON_TYPE_WHOKNOWS)
        Missiles.createHoming("sfx\\BloodySplat Missile.mdx", target, caster,1500, 0, function()
            SetWidgetLife(caster, GetWidgetLife(caster) + 25)
            DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Undead\\VampiricAura\\VampiricAuraTarget.mdl", caster, "origin"))
        end)
    end
}

ABILITIES.TIDES_OF_BLOOD = {
    abilityId = ABILITY_ID_TIDES_OF_BLOOD,
    animation = 8,
    animationTime = 2.0,
    animationDamagePoint = 2.0,
    animationBackswingPoint = 2.0,
    animationMode = CastSystem.ANIMATION_MODE_FIT,
    startHandler = function(castData)
        local caster = castData.caster
        DestroyEffect(AddSpecialEffectTarget("sfx\\Blood Whirl.mdx", caster, "origin"))
    end,
    finishHandler = function(castData)
        local caster = castData.caster
        local casterX = GetUnitX(caster)
        local casterY = GetUnitY(caster)

        local enemyFilter = Filter(function()
            return not IsUnitAlly(GetFilterUnit(), GetOwningPlayer(caster)) and not IsUnitType(GetFilterUnit(), UNIT_TYPE_DEAD)
        end)


        for i = 1, 20 do
            local angle = i * (360 / 20)
            local x, y = WC3Math.polarProjection(casterX, casterY, 450, angle)
            Missiles.create("sfx\\BloodMissile.mdx", caster, x, y, 1500, enemyFilter, 64, 0, function(targetUnit)
                if targetUnit == nil then
                    return
                end
                UnitDamageTarget(caster, targetUnit, 100, false, true, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_MAGIC, WEAPON_TYPE_WHOKNOWS)
            end)
        end
    end
}

local bloodPlagueData = {}

ABILITIES.BLOOD_PLAGUE = {
    abilityId = ABILITY_ID_BLOOD_PLAGUE,
    animation = 4,
    animationTime = 1.5,
    animationDamagePoint = 0.85,
    animationBackswingPoint = 1.2,
    animationMode = CastSystem.ANIMATION_MODE_FIT,
    startHandler = function()
    end,
    finishHandler = function(castData)
        local caster = castData.caster
        local target = castData.target
        Missiles.createHoming("sfx\\BloodCloud.mdx", caster, target,900, 0, function()
            CastSystem.castAbility(GetOwningPlayer(caster), ABILITIES.BLOOD_PLAGUE_DEBUFF.abilityId, ORDER_cripple, target)
        end)
    end
}

ABILITIES.BLOOD_PLAGUE_DEBUFF = {
    abilityId = FourCC("A   "),
    startHandler = function(castData)
        local caster = castData.caster
        local target = castData.target
        table.insert(bloodPlagueData,{ target = target, caster = PlayerHero[GetOwningPlayer(caster)] })
    end
}

local bloodPlagueDeathTrig = CreateTrigger()
TriggerRegisterAnyUnitEventBJ(bloodPlagueDeathTrig, EVENT_PLAYER_UNIT_DEATH)
TriggerAddAction(bloodPlagueDeathTrig, function()
    local unit = GetDyingUnit()

    local caster
    for _, data in pairs(bloodPlagueData) do
        if data.target == unit then
            caster = data.caster
        end
    end

    if caster == nil then
        return
    end

    DestroyEffect(AddSpecialEffect("Objects\\Spawnmodels\\Human\\HumanLargeDeathExplode\\HumanLargeDeathExplode.mdl", GetUnitX(unit), GetUnitY(unit)))
    local fx = AddSpecialEffect("sfx\\BloodCloud.mdx", GetUnitX(unit), GetUnitY(unit))
    TimerStart(CreateTimer(), 0.1, false, function()
        DestroyTimer(GetExpiredTimer())
        DestroyEffect(fx)
    end)
    local group = CreateGroup()
    GroupEnumUnitsInRange(group, GetUnitX(unit), GetUnitY(unit), 300, Filter(function()
        local filterUnit = GetFilterUnit()
        return IsUnitEnemy(filterUnit, GetOwningPlayer(caster)) and UnitAlive(filterUnit)
    end))
    ForGroup(group, function()
        local enumUnit = GetEnumUnit()
        --UnitDamageTarget(caster, enumUnit, 10, false, true, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_MAGIC, WEAPON_TYPE_WHOKNOWS)
        CastSystem.castAbility(GetOwningPlayer(caster), ABILITIES.BLOOD_PLAGUE_DEBUFF.abilityId, ORDER_cripple, enumUnit)
    end)
end)

ABILITIES.BLOOD_MINISTRY = {
    abilityId = ABILITY_ID_BLOOD_MINISTRY,
    animation = 8,
    animationTime = 2.0,
    animationDamagePoint = 2.0,
    animationBackswingPoint = 2.0,
    animationMode = CastSystem.ANIMATION_MODE_FIT,
    startHandler = function(castData)
        local x, y = castData.target.x, castData.target.y

        local altar = AddSpecialEffect("Doodads\\Outland\\Props\\Altar\\Altar.mdl", x, y)
        BlzSetSpecialEffectScale(altar, 1.5 )

        local circleRune = AddSpecialEffect("Doodads\\BlackCitadel\\Props\\RuneArt\\RuneArt1.mdl", x, y)
        BlzSetSpecialEffectScale(circleRune, 2)

        local smallRunes = {}
        for i = 1, 16 do
            local newX, newY = WC3Math.polarProjection(x, y, 300, i * (360 / 12))
            local smallRuneFx = AddSpecialEffect("Doodads\\BlackCitadel\\Props\\RuneArt\\RuneArt" .. math.random(3, 6) .. ".mdl", newX, newY)
            BlzSetSpecialEffectYaw(smallRuneFx, math.rad(i * (360 / 12)))
            table.insert(smallRunes, smallRuneFx)
        end

        castData.altarFx = altar
        castData.circleFx = circleRune
        castData.smallRunes = smallRunes
    end,
    endHandler = function(castData)
        SilentDestroyEffect(castData.altarFx)
        SilentDestroyEffect(castData.circleFx)
        for _, runeFx in pairs(castData.smallRunes) do
            SilentDestroyEffect(runeFx)
        end
    end
}


Timer.register(function()
    for key, data in pairs(bloodPlagueData) do
        local target = data.target
        local caster = data.caster
        if UnitHasBuffBJ(target, BUFF_ID_BLOOD_PLAGUE) and UnitAlive(target) then
            UnitDamageTarget(caster, target, 0.25, false, true, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_MAGIC, WEAPON_TYPE_WHOKNOWS)
        else
            bloodPlagueData[key] = nil
        end
    end
end)

Utils.onGameStart(function()
    for _, abilityData in pairs(ABILITIES) do
        CastSystem.registerAbility(abilityData)
    end
end)