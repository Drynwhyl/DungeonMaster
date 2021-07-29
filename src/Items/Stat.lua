---@class Stat
---@field public name string
---@field public prettyName string
---@field public STRENGTH Stat
---@field public AGILITY Stat
---@field public INTELLIGENCE Stat
---@field public ATTACK_DAMAGE Stat
---@field public ATTACK_SPEED Stat
---@field public MOVE_SPEED Stat
---@field public LIFE Stat
---@field public MANA Stat
---@field public LIFE_REGEN Stat
---@field public MANA_REGEN Stat
---@field public LIFESTEAL Stat
---@field public CRIT_CHANCE Stat
---@field public CRIT_DAMAGE Stat
---@field public DODGE_CHANCE Stat
---@field private baseGetter fun(self:Stat,unit:unit)
---@field private bonusGetter fun(self:Stat,unit:unit)
---@field private percentGetter fun(self:Stat,unit:unit)
---@field private allGetter fun(self:Stat,unit:unit)
---@field private baseSetter fun(self:Stat,unit:unit)
---@field private bonusSetter fun(self:Stat,unit:unit)
---@field private percentSetter fun(self:Stat,unit:unit)
---@field private percentBonus table<unit,number>
local Stat = {
    statsByNameMap = {},
}

---@param name string
---@param prettyName string
---@param abilityId number
---@param abilityField any
---@param baseGetter fun(self:Stat,unit:unit)
---@param bonusGetter fun(self:Stat,unit:unit)
---@param percentGetter fun(self:Stat,unit:unit)
---@param allGetter fun(self:Stat,unit:unit)
---@param baseSetter fun(self:Stat,unit:unit)
---@param bonusSetter fun(self:Stat,unit:unit)
---@param percentSetter fun(self:Stat,unit:unit)
---@return Stat
function Stat:new(name, prettyName, abilityId, abilityField, baseGetter, bonusGetter, percentGetter, allGetter, baseSetter, bonusSetter, percentSetter)
    ---@type Stat
    local instance = {
        name = name,
        prettyName = prettyName,
        abilityId = abilityId,
        abilityField = abilityField,
        baseGetter = baseGetter or self.dummyBaseGetter,
        bonusGetter = bonusGetter or self.dummyBonusGetter,
        percentGetter = percentGetter or self.dummyPercentGetter,
        allGetter = allGetter or self.dummyAllGetter,
        baseSetter = baseSetter or self.dummyBaseSetter,
        bonusSetter = bonusSetter or self.dummyBonusSetter,
        percentSetter = percentSetter or self.dummyPercentSetter,
        percentBonus = {}
    }
    self.__index = self
    return setmetatable(instance, self)
end

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

Stat.STRENGTH = Stat:new("STRENGTH", "Strength", ABILITY_ATTRIBUTES, ABILITY_ILF_STRENGTH_BONUS_ISTR)
Stat.AGILITY = Stat:new("AGILITY", "Agility", ABILITY_ATTRIBUTES, ABILITY_ILF_AGILITY_BONUS)
Stat.INTELLIGENCE = Stat:new("INTELLIGENCE", "Intelligence", ABILITY_ATTRIBUTES, ABILITY_ILF_INTELLIGENCE_BONUS)
Stat.ATTACK_DAMAGE = Stat:new("ATTACK_DAMAGE", "Attack damage", ABILITY_ATTACK_DAMAGE, ABILITY_ILF_ATTACK_BONUS)
Stat.ATTACK_SPEED = Stat:new("ATTACK_SPEED", "Attack speed", ABILITY_ATTACK_SPEED, ABILITY_RLF_ATTACK_SPEED_INCREASE_ISX1)
Stat.MOVE_SPEED = Stat:new("MOVE_SPEED", "Move speed", ABILITY_MOVE_SPEED, ABILITY_ILF_MOVEMENT_SPEED_BONUS)
Stat.LIFE = Stat:new("LIFE", "Life", ABILITY_LIFE, ABILITY_ILF_MAX_LIFE_GAINED)
Stat.MANA = Stat:new("MANA", "Mana", ABILITY_MANA, ABILITY_ILF_MAX_MANA_GAINED)
Stat.LIFE_REGEN = Stat:new("LIFE_REGEN", "Life regen", ABILITY_LIFE_REGEN, ABILITY_ILF_HIT_POINTS_REGENERATED_PER_SECOND)
Stat.MANA_REGEN = Stat:new("MANA_REGEN", "Mana regen", ABILITY_MANA_REGEN, ABILITY_RLF_MANA_REGENERATION_BONUS_AS_FRACTION_OF_NORMAL)
Stat.LIFESTEAL = Stat:new("LIFESTEAL", "Lifesteal", ABILITY_LIFESTEAL, ABILITY_RLF_LIFE_STOLEN_PER_ATTACK)
Stat.CRIT_CHANCE = Stat:new("CRIT_CHANCE", "Crit chance", ABILITY_CRITSTRIKE_DODGE, ABILITY_RLF_CHANCE_TO_CRITICAL_STRIKE)
Stat.CRIT_DAMAGE = Stat:new("CRIT_DAMAGE", "Crit damage", ABILITY_CRITSTRIKE_DODGE, ABILITY_RLF_DAMAGE_MULTIPLIER_OCR2)
Stat.DODGE_CHANCE = Stat:new("DODGE_CHANCE", "Dodge chance", ABILITY_CRITSTRIKE_DODGE, ABILITY_RLF_CHANCE_TO_EVADE_OCR4)

-- DEFAULT FUNCTIONS
---@private
function Stat:defaultIntegerGetter(unit)
    return BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(unit, self.abilityId), self.abilityField, 0)
end
---@private
function Stat:defaultRealGetter(unit)
    return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, self.abilityId),  self.abilityField, 0)
end
---@private
function Stat:defaultIntegerSetter(unit, value)
    BlzSetAbilityIntegerLevelField(BlzGetUnitAbility(unit, self.abilityId), self.abilityField, 0, value)
    IncUnitAbilityLevel(unit, self.abilityId)
    DecUnitAbilityLevel(unit, self.abilityId)
end
---@private
function Stat:defaultRealSetter(unit, value)
    BlzSetAbilityRealLevelField(BlzGetUnitAbility(unit, self.abilityId), self.abilityField, 0, value)
    IncUnitAbilityLevel(unit, self.abilityId)
    DecUnitAbilityLevel(unit, self.abilityId)
end

---@private
function Stat:defaultPercentGetter(unit)
    return self.percentBonus[unit] or 0.0
end

---@private
function Stat:defaultPercentSetter(unit, value)
    local currentPercentValue = self:percentGetter(unit)
    local baseValue = self:baseGetter(unit)
    local currentPercentBonusValue =  baseValue * currentPercentValue
    local result = self:bonusGetter(unit) - currentPercentBonusValue + value * baseValue
    self:bonusSetter(unit, result)
end

-- BASE GETTERS
function Stat.STRENGTH:baseGetter(unit)
    return GetHeroStr(unit, false)
end
function Stat.AGILITY:baseGetter(unit)
    return GetHeroAgi(unit, false)
end
function Stat.INTELLIGENCE:baseGetter(unit)
    return GetHeroInt(unit, false)
end
function Stat.ATTACK_DAMAGE:baseGetter(unit)
    return BlzGetUnitBaseDamage(unit, 0)
end
-- Skip attack speed
function Stat.MOVE_SPEED.baseGetter(unit)
    return GetUnitMoveSpeed(unit) - self:bonusGetter(unit)
end
function Stat.LIFE.baseGetter(unit)
    return BlzGetUnitMaxHP(unit) - self:bonusGetter(unit)
end
function Stat.MANA.baseGetter(unit)
    return BlzGetUnitMaxMana(unit) - self:bonusGetter(unit)
end
function Stat.LIFE_REGEN.baseGetter(unit)
    return BlzGetUnitRealField(unit, UNIT_RF_HIT_POINTS_REGENERATION_RATE)
end
function Stat.MANA_REGEN.baseGetter(unit)
    return BlzGetUnitRealField(unit, UNIT_RF_MANA_REGENERATION)
end
-- Skip lifesteal
-- Skip crit chance
-- Skip crit damage
-- Skip dodge change


-- BONUS GETTERS
Stat.STRENGTH.bonusGetter = Stat.defaultIntegerGetter
Stat.AGILITY.bonusGetter = Stat.defaultIntegerGetter
Stat.INTELLIGENCE.bonusGetter = Stat.defaultIntegerGetter
Stat.ATTACK_DAMAGE.bonusGetter = Stat.defaultIntegerGetter
-- Stat.ATTACK_SPEED.bonusGetter = Stat.defaultIntegerGetter
Stat.MOVE_SPEED.bonusGetter = Stat.defaultIntegerGetter
Stat.LIFE.bonusGetter = Stat.defaultIntegerGetter
Stat.MANA.bonusGetter = Stat.defaultIntegerGetter
Stat.LIFE_REGEN.bonusGetter = Stat.defaultIntegerGetter
Stat.MANA_REGEN.bonusGetter = Stat.defaultRealGetter
Stat.LIFESTEAL.bonusGetter = Stat.defaultRealGetter
Stat.CRIT_CHANCE.bonusGetter = Stat.defaultRealGetter
Stat.CRIT_DAMAGE.bonusGetter = Stat.defaultRealGetter
Stat.DODGE_CHANCE.bonusGetter = Stat.defaultRealGetter

-- PERCENT GETTERS
-- Skip everything except for

-- DUMMY FUNCTIONS
function Stat:dummyGetter(unit, getterType)
    print("ERROR: ", self.name, "has no", getterType, "getter")
    return 0
end
function Stat:dummyBaseGetter(unit)
    return self:dummyGetter(unit, "base");
end
function Stat:dummyBonusGetter(unit)
    return self:dummyGetter(unit, "bonus");
end
function Stat:dummyPercentGetter(unit)
    return self:dummyGetter(unit, "percent");
end

function Stat:dummySetter(unit, setterType)
    print("ERROR: ", self.name, "has no", setterType, "setter")
end
function Stat:dummyBaseGetter(unit)
    self:dummySetter(unit, "base");
end
function Stat:dummyBonusGetter(unit)
    self:dummySetter(unit, "bonus");
end
function Stat:dummyPercentGetter(unit)
    self:dummySetter(unit, "percent");
end

return Stat