local Stat = require "Stat"

---@class EquipmentClass
---@field public name string
---@field public prettyName string
---@field public WEAPON_RANGED EquipmentClass
---@field public WEAPON_MELEE EquipmentClass
---@field public WEAPON_MAGIC EquipmentClass
---@field public ARMOR EquipmentClass
---@field public OFFHAND EquipmentClass
---@field public SPECIAL EquipmentClass
---@field public RING EquipmentClass
---@field public mainStats Stat[]
local EquipmentParentClass = {}


---@param name string
---@param prettyName string
---@param mainStats Stat[]
function EquipmentParentClass:new(name, prettyName, mainStats)
    local instance = {
        name = name,
        prettyName = prettyName,
        mainStats = mainStats,
    }
    setmetatable(instance, self)
    self.__index = self
    return instance
end

EquipmentParentClass.WEAPON_RANGED = EquipmentParentClass:new(
        "WEAPON_RANGED",
        "Ranged weapon"
)

EquipmentParentClass.WEAPON_MELEE = EquipmentParentClass:new(
        "WEAPON_MELEE",
        "Melee weapon"
)

EquipmentParentClass.WEAPON_MAGIC = EquipmentParentClass:new(
        "WEAPON_MAGIC",
        "Magic weapon"
)

EquipmentParentClass.ARMOR = EquipmentParentClass:new(
        "ARMOR",
        "Armor"
)

EquipmentParentClass.OFFHAND = EquipmentParentClass:new(
        "OFFHAND",
        "Offhand"
)

EquipmentParentClass.SPECIAL = EquipmentParentClass:new(
        "SPECIAL",
        "Special"
)

EquipmentParentClass.RING = EquipmentParentClass:new(
        "RING",
        "Ring"
)

---@class EquipmentSubclass
---@field public parent EquipmentClass
---@field public BOW EquipmentSubclass
---@field public CROSSBOW EquipmentSubclass
---@field public AXE EquipmentSubclass
---@field public SWORD EquipmentSubclass
---@field public DAGGER EquipmentSubclass
---@field public STAFF EquipmentSubclass
---@field public ARMOR_HEAVY EquipmentSubclass
---@field public ARMOR_MEDIUM EquipmentSubclass
---@field public ARMOR_LIGHT EquipmentSubclass
---@field public SHIELD EquipmentSubclass
---@field public HELM EquipmentSubclass
---@field public CAPE EquipmentSubclass
---@field public TALISMAN EquipmentSubclass
---@field public RING EquipmentSubclass
local EquipmentClass = {}

---@param parent EquipmentClass
---@param name string
---@param prettyName string
---@param mainStats Stat[]
function EquipmentClass:new(parent, name, prettyName, mainStats)
    local instance = {
        parent = parent,
        name = name,
        prettyName = prettyName,
        mainStats = mainStats,
    }
    setmetatable(instance, self)
    self.__index = self
    return instance
end

EquipmentClass.BOW = EquipmentClass:new(
        EquipmentParentClass.WEAPON_RANGED,
        "BOW",
        "Bow",
        { Stat.ATTACK_DAMAGE, Stat.ATTACK_SPEED }
)

EquipmentClass.CROSSBOW = EquipmentClass:new(
        EquipmentParentClass.WEAPON_RANGED,
        "CROSSBOW",
        "Crossbow",
        { Stat.ATTACK_DAMAGE, Stat.ATTACK_SPEED }
)

EquipmentClass.AXE = EquipmentClass:new(
        EquipmentParentClass.WEAPON_MELEE,
        "AXE",
        "Axe",
        { Stat.ATTACK_DAMAGE, Stat.ATTACK_SPEED }
)

EquipmentClass.SWORD = EquipmentClass:new(
        EquipmentParentClass.WEAPON_MELEE,
        "SWORD",
        "Sword",
        { Stat.ATTACK_DAMAGE, Stat.ATTACK_SPEED }
)

EquipmentClass.DAGGER = EquipmentClass:new(
        EquipmentParentClass.WEAPON_MELEE,
        "DAGGER",
        "Dagger",
        { Stat.ATTACK_DAMAGE, Stat.ATTACK_SPEED }
)

EquipmentClass.STAFF = EquipmentClass:new(
        EquipmentParentClass.WEAPON_MAGIC,
        "STAFF",
        "Staff",
        { Stat.ATTACK_DAMAGE, Stat.ATTACK_SPEED }
)

EquipmentClass.ARMOR_HEAVY = EquipmentClass:new(
        EquipmentParentClass.ARMOR,
        "ARMOR_HEAVY",
        "Heavy",
        { Stat.ATTACK_DAMAGE, Stat.ATTACK_SPEED }
)

EquipmentClass.ARMOR_MEDIUM = EquipmentClass:new(
        EquipmentParentClass.ARMOR,
        "ARMOR_MEDIUM",
        "Medium",
        { Stat.ATTACK_DAMAGE, Stat.ATTACK_SPEED }
)

EquipmentClass.ARMOR_LIGHT = EquipmentClass:new(
        EquipmentParentClass.ARMOR,
        "ARMOR_LIGHT",
        "Light",
        { Stat.ATTACK_DAMAGE, Stat.ATTACK_SPEED }
)

EquipmentClass.SHIELD = EquipmentClass:new(
        EquipmentParentClass.OFFHAND,
        "SHIELD",
        "Shield",
        { Stat.ATTACK_DAMAGE, Stat.ATTACK_SPEED }
)

EquipmentClass.HELM = EquipmentClass:new(
        EquipmentParentClass.SPECIAL,
        "HELM",
        "Helmet",
        { Stat.ATTACK_DAMAGE, Stat.ATTACK_SPEED }
)

EquipmentClass.CAPE = EquipmentClass:new(
        EquipmentParentClass.SPECIAL,
        "CAPE",
        "Cape",
        { Stat.ATTACK_DAMAGE, Stat.ATTACK_SPEED }
)

EquipmentClass.TALISMAN = EquipmentClass:new(
        EquipmentParentClass.SPECIAL,
        "TALISMAN",
        "Talisman",
        { Stat.ATTACK_DAMAGE, Stat.ATTACK_SPEED }
)

EquipmentClass.RING = EquipmentClass:new(
        EquipmentParentClass.RING,
        "Ring",
        "Ring",
        { Stat.ATTACK_DAMAGE, Stat.ATTACK_SPEED }
)

return EquipmentClass