local Autotable = require "Autotable"

local ABILITY_ATTRIBUTES = FourCC("Ast0")
local ABILITY_ATTACK_DAMAGE = FourCC("Ast1")
local ABILITY_ATTACK_SPEED = FourCC("Ast2")
local ABILITY_MOVE_SPEED = FourCC("Ast3")
local ABILITY_LIFE = FourCC("Ast4")
local ABILITY_MANA = FourCC("Ast5")
local ABILITY_LIFE_REGEN = FourCC("Ast6")
local ABILITY_MANA_REGEN = FourCC("Ast7")
local ABILITY_LIFESTEAL = FourCC("Ast8")
local ABILITY_CRITSTRIKE_DODGE = FourCC("Ast9")

STAT_NAME = {
    STRENGTH = "STRENGTH",
    AGILITY = "AGILITY",
    INTELLIGENCE = "INTELLIGENCE",
    ATTACK_DAMAGE = "ATTACK_DAMAGE",
    ATTACK_SPEED = "ATTACK_SPEED",
    MOVE_SPEED = "MOVE_SPEED",
    LIFE = "LIFE",
    MANA = "MANA",
    LIFE_REGEN = "LIFE_REGEN",
    MANA_REGEN = "MANA_REGEN",
    LIFESTEAL = "LIFESTEAL",
    CRIT_CHANCE = "CRIT_CHANCE",
    CRIT_DAMAGE = "CRIT_DAMAGE",
    DODGE_CHANCE = "DODGE_CHANCE",
}

STAT_TYPE = {
    BASE = "BASE",
    BONUS = "BONUS",
    ALL = "ALL",
}

local statFunctions = Autotable:new(1)

local function SetUnitAbilityStat(unit, abilityId, field, value, setterFunc)
    if GetUnitAbilityLevel(unit, abilityId) == 0 then
        UnitAddAbility(unit, abilityId)
        UnitMakeAbilityPermanent(unit, true, abilityId)
    end
    setterFunc(BlzGetUnitAbility(unit, abilityId), field, 0, value)
    IncUnitAbilityLevel(unit, abilityId)
    DecUnitAbilityLevel(unit, abilityId)
end

local function SetUnitIntegerAbilityStat(unit, abilityId, field, value)
    SetUnitAbilityStat(unit, abilityId, field, value, BlzSetAbilityIntegerLevelField)
end

local function SetUnitRealAbilityStat(unit, abilityId, field, value)
    SetUnitAbilityStat(unit, abilityId, field, value, BlzSetAbilityRealLevelField)
end

local function GetUnitAbilityStat(unit, abilityId, field, getterFunc)
    if GetUnitAbilityLevel(unit, abilityId) == 0 then
        UnitAddAbility(unit, abilityId)
        UnitMakeAbilityPermanent(unit, true, abilityId)
    end
    return getterFunc(BlzGetUnitAbility(unit, abilityId), field, 0)
end

local function GetUnitIntegerAbilityStat(unit, abilityId, field)
    return GetUnitAbilityStat(unit, abilityId, field, BlzGetAbilityIntegerLevelField)
end

local function GetUnitRealAbilityStat(unit, abilityId, field)
    return GetUnitAbilityStat(unit, abilityId, field, BlzGetAbilityRealLevelField)
end

function statFunctions.STRENGTH.set(unit, mode, value)
    if mode == STAT_TYPE.BASE then
        SetHeroStr(unit, value, true)
    elseif mode == STAT_TYPE.BONUS then
        SetUnitIntegerAbilityStat(unit, ABILITY_ATTRIBUTES, ABILITY_ILF_STRENGTH_BONUS_ISTR, value)
    end
end

function statFunctions.STRENGTH.get(unit, mode)
    if mode == STAT_TYPE.BASE then
        return GetHeroStr(unit, false)
    elseif mode == STAT_TYPE.BONUS then
        return GetHeroStr(unit, true) - GetHeroStr(unit, false)
    elseif mode == STAT_TYPE.ALL then
        return GetHeroStr(unit, true)
    end
end

function statFunctions.AGILITY.set(unit, mode, value)
    if mode == STAT_TYPE.BASE then
        SetHeroAgi(unit, value, true)
    elseif mode == STAT_TYPE.BONUS then
        SetUnitIntegerAbilityStat(unit, ABILITY_ATTRIBUTES, ABILITY_ILF_AGILITY_BONUS, value)
    end
end

function statFunctions.AGILITY.get(unit, mode)
    if mode == STAT_TYPE.BASE then
        return GetHeroAgi(unit, false)
    elseif mode == STAT_TYPE.BONUS then
        return GetHeroAgi(unit, true) - GetHeroAgi(unit, false)
    elseif mode == STAT_TYPE.ALL then
        return GetHeroAgi(unit, true)
    end
end

function statFunctions.INTELLIGENCE.set(unit, mode, value)
    if mode == STAT_TYPE.BASE then
        SetHeroInt(unit, value, true)
    elseif mode == STAT_TYPE.BONUS then
        SetUnitIntegerAbilityStat(unit, ABILITY_ATTRIBUTES, ABILITY_ILF_INTELLIGENCE_BONUS, value)
    end
end

function statFunctions.INTELLIGENCE.get(unit, mode)
    if mode == STAT_TYPE.BASE then
        return GetHeroInt(unit, false)
    elseif mode == STAT_TYPE.BONUS then
        return GetHeroInt(unit, true) - GetHeroInt(unit, false)
    elseif mode == STAT_TYPE.ALL then
        return GetHeroInt(unit, true)
    end
end

function statFunctions.ATTACK_DAMAGE.set(unit, mode, value)
    if mode == STAT_TYPE.BASE then
        BlzSetUnitBaseDamage(unit, value, 0)
    elseif mode == STAT_TYPE.BONUS then
        SetUnitIntegerAbilityStat(unit, ABILITY_ATTACK_DAMAGE, ABILITY_ILF_ATTACK_BONUS, value)
    end
end

function statFunctions.ATTACK_DAMAGE.get(unit, mode)
    if mode == STAT_TYPE.BASE then
        return BlzGetUnitBaseDamage(unit, 0)
    elseif mode == STAT_TYPE.BONUS then
        return GetUnitIntegerAbilityStat(unit, ABILITY_ATTACK_DAMAGE, ABILITY_ILF_ATTACK_BONUS)
    elseif mode == STAT_TYPE.ALL then
        return statFunctions.ATTACK_DAMAGE.get(unit, STAT_TYPE.BASE) + statFunctions.ATTACK_DAMAGE.get(unit, STAT_TYPE.BONUS)
    end
end

function statFunctions.ATTACK_SPEED.set(unit, mode, value)
    SetUnitRealAbilityStat(unit, ABILITY_ATTACK_SPEED, ABILITY_RLF_ATTACK_SPEED_INCREASE_ISX1, value)
end

function statFunctions.ATTACK_SPEED.get(unit, mode)
    return GetUnitIntegerAbilityStat(unit, ABILITY_ATTACK_SPEED, ABILITY_RLF_ATTACK_SPEED_INCREASE_ISX1)
end

function statFunctions.MOVE_SPEED.set(unit, mode, value)
    if mode == STAT_TYPE.BASE then
        SetUnitMoveSpeed(unit, value)
    elseif mode == STAT_TYPE.BONUS then
        SetUnitIntegerAbilityStat(unit, ABILITY_MOVE_SPEED, ABILITY_ILF_MOVEMENT_SPEED_BONUS, value)
    end
end

function statFunctions.MOVE_SPEED.get(unit, mode)
    if mode == STAT_TYPE.BASE then
        return statFunctions.MOVE_SPEED.get(unit, STAT_TYPE.ALL) - statFunctions.MOVE_SPEED.get(unit, STAT_TYPE.BONUS)
    elseif mode == STAT_TYPE.BONUS then
        return GetUnitIntegerAbilityStat(unit, ABILITY_MOVE_SPEED, ABILITY_ILF_MOVEMENT_SPEED_BONUS)
    elseif mode == STAT_TYPE.ALL then
        return GetUnitMoveSpeed(unit)
    end
end

function statFunctions.LIFE.set(unit, mode, value)
    if mode == STAT_TYPE.BASE then
        BlzSetUnitMaxHP(unit, value)
    elseif mode == STAT_TYPE.BONUS then
        SetUnitIntegerAbilityStat(unit, ABILITY_LIFE, ABILITY_ILF_MAX_LIFE_GAINED, value)
    end
end

function statFunctions.LIFE.get(unit, mode)
    if mode == STAT_TYPE.BASE then
        return statFunctions.LIFE.get(unit, STAT_TYPE.ALL) - statFunctions.LIFE.get(unit, STAT_TYPE.BONUS)
    elseif mode == STAT_TYPE.BONUS then
        return GetUnitIntegerAbilityStat(unit, ABILITY_LIFE, ABILITY_ILF_MAX_LIFE_GAINED)
    elseif mode == STAT_TYPE.ALL then
        return BlzGetUnitMaxHP(unit)
    end
end

function statFunctions.MANA.set(unit, mode, value)
    if mode == STAT_TYPE.BASE then
        BlzSetUnitMaxMana(unit, value)
    elseif mode == STAT_TYPE.BONUS then
        SetUnitIntegerAbilityStat(unit, ABILITY_MANA, ABILITY_ILF_MAX_MANA_GAINED, value)
    end
end

function statFunctions.MANA.get(unit, mode)
    if mode == STAT_TYPE.BASE then
        return statFunctions.MANA.get(unit, STAT_TYPE.ALL) - statFunctions.MANA.get(unit, STAT_TYPE.BONUS)
    elseif mode == STAT_TYPE.BONUS then
        return GetUnitIntegerAbilityStat(unit, ABILITY_MANA, ABILITY_ILF_MAX_MANA_GAINED)
    elseif mode == STAT_TYPE.ALL then
        return BlzGetUnitMaxMana(unit)
    end
end

function statFunctions.LIFE_REGEN.set(unit, mode, value)
    if mode == STAT_TYPE.BASE then
        BlzSetUnitRealField(unit, UNIT_RF_HIT_POINTS_REGENERATION_RATE, value)
    elseif mode == STAT_TYPE.BONUS then
        SetUnitIntegerAbilityStat(unit, ABILITY_LIFE_REGEN, ABILITY_ILF_HIT_POINTS_REGENERATED_PER_SECOND, value)
    end
end

function statFunctions.LIFE_REGEN.get(unit, mode)
    if mode == STAT_TYPE.BASE then
        return BlzGetUnitRealField(unit, UNIT_RF_HIT_POINTS_REGENERATION_RATE)
    elseif mode == STAT_TYPE.BONUS then
        return GetUnitIntegerAbilityStat(unit, ABILITY_LIFE_REGEN, ABILITY_ILF_HIT_POINTS_REGENERATED_PER_SECOND)
    elseif mode == STAT_TYPE.ALL then
        return statFunctions.LIFE_REGEN.get(unit, STAT_TYPE.BASE) + statFunctions.LIFE_REGEN.get(unit, STAT_TYPE.BONUS)
    end
end

function statFunctions.MANA_REGEN.set(unit, mode, value)
    if mode == STAT_TYPE.BASE then
        BlzSetUnitRealField(unit, UNIT_RF_MANA_REGENERATION, value)
    elseif mode == STAT_TYPE.BONUS then
        SetUnitIntegerAbilityStat(unit, ABILITY_MANA_REGEN, ABILITY_ILF_MAX_MANA_GAINED, value)
    end
end

function statFunctions.MANA_REGEN.get(unit, mode)
    if mode == STAT_TYPE.BASE then
        return BlzGetUnitRealField(unit, ABILITY_ILF_MAX_MANA_GAINED)
    elseif mode == STAT_TYPE.BONUS then
        return GetUnitIntegerAbilityStat(unit, ABILITY_MANA_REGEN, ABILITY_RLF_MANA_REGENERATION_BONUS_AS_FRACTION_OF_NORMAL)
    elseif mode == STAT_TYPE.ALL then
        return statFunctions.MANA_REGEN.get(unit, STAT_TYPE.BASE) + statFunctions.MANA_REGEN.get(unit, STAT_TYPE.BONUS)
    end
end

function statFunctions.LIFESTEAL.set(unit, mode, value)
    SetUnitRealAbilityStat(unit, ABILITY_LIFESTEAL, ABILITY_RLF_LIFE_STOLEN_PER_ATTACK, value)
end

function statFunctions.LIFESTEAL.get(unit, mode)
    return GetUnitRealAbilityStat(unit, ABILITY_LIFESTEAL, ABILITY_RLF_LIFE_STOLEN_PER_ATTACK)
end

function statFunctions.CRIT_CHANCE.set(unit, mode, value)
    SetUnitRealAbilityStat(unit, ABILITY_CRITSTRIKE_DODGE, ABILITY_RLF_CHANCE_TO_CRITICAL_STRIKE, value)
end

function statFunctions.CRIT_CHANCE.get(unit, mode)
    return GetUnitRealAbilityStat(unit, ABILITY_CRITSTRIKE_DODGE, ABILITY_RLF_CHANCE_TO_CRITICAL_STRIKE)
end

function statFunctions.CRIT_DAMAGE.set(unit, mode, value)
    SetUnitRealAbilityStat(unit, ABILITY_CRITSTRIKE_DODGE, ABILITY_RLF_DAMAGE_MULTIPLIER_OCR2, value)
end

function statFunctions.CRIT_DAMAGE.get(unit, mode)
    return GetUnitRealAbilityStat(unit, ABILITY_CRITSTRIKE_DODGE, ABILITY_RLF_DAMAGE_MULTIPLIER_OCR2)
end

function statFunctions.DODGE_CHANCE.set(unit, mode, value)
    SetUnitRealAbilityStat(unit, ABILITY_CRITSTRIKE_DODGE, ABILITY_RLF_CHANCE_TO_EVADE_OCR4, value)
end

function statFunctions.DODGE_CHANCE.get(unit, mode)
    return GetUnitRealAbilityStat(unit, ABILITY_CRITSTRIKE_DODGE, ABILITY_RLF_CHANCE_TO_EVADE_OCR4)
end

function GetUnitStat(unit, stat, mode)
    return statFunctions[stat].get(unit, mode)
end

function SetUnitStat(unit, stat, mode, value)
    statFunctions[stat].set(unit, mode, value)
end
