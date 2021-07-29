local TextUtils = require "TextUtils"

local UNIT_ID_DUMMY_ITEM = FourCC("n  !")

---@class Equipment
---@field public name string
---@field public desc string
---@field public type ItemType
---@field public stats table<string,ItemStat>
---@field private map table<any, Equipment> @Static member
local Equipment = {
    map = {},
}

---@param handle item|unit
---@return Equipment
function Equipment:getByHandle(handle)
    return self.map[handle]
end

---@private
function Equipment:applyQuality()
    local name = TextUtils.colorText(GetItemName(self.item), self.quality.color)
    local a, r, g, b = TextUtils.intToARGB(self.quality.color)
    SetUnitVertexColor(self.unit, r, g, b, a)
    BlzSetUnitName(self.unit, name)
    self.name = name
    self.desc = self:createDescription()
end

---@private
function Equipment:applyStats()
    for statName, statData in pairs(self.type.data.stats) do
        self.stats[statName] = { type = statData.type, value = statData.value }
    end
end

---@private
function Equipment:createDescription()
    local desc = ""
    for statName, stat in pairs(self.stats) do
        desc = string.format("%s%s: %+d", desc, statName, stat.value)
    end
    return desc
end

---@private
function Equipment:initPickupTrigger()
    local trigger = CreateTrigger()
    TriggerRegisterUnitInRange(trigger, self.unit, 128, nil)
    TriggerAddAction(trigger, function()
        local unitInRange = GetTriggerUnit()
        if IsUnitType(unitInRange, UNIT_TYPE_HERO)
                and GetUnitCurrentOrder(unitInRange) == ORDER_smart
                and GetUnitCurrentOrderTarget(unitInRange) == self.unitunit then
            SetItemVisible(self.item, true)
            UnitAddItem(unitInRange, self.item)
            IssueImmediateOrderById(unitInRange, ORDER_stop)
            ShowUnit(self.unit, false)
        end
    end)
end

---@private
---@param itemType ItemType
---@param quality any
---@param level number
---@param x number
---@param y number
function Equipment:init(itemType, quality, level, x, y)

    local item = CreateItem(itemType.id, x, y)
    local unit = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), UNIT_ID_DUMMY_ITEM, x, y, bj_UNIT_FACING)

    self.stats = {}
    self.type = itemType
    self.quality = quality
    self.level = level
    self.item = item
    self.unit = unit
    self.map[item] = self
    self.map[unit] = self

    self:initPickupTrigger()
    self:applyStats()
    self:applyQuality()

    SetItemVisible(item, false)
end

---@param itemType ItemType
---@param level number
---@param x number
---@param y number
function Equipment:new(itemType, quality, level, x, y)
    ---@type Equipment
    local instance = setmetatable({}, self)
    self.__index = self

    instance:init(itemType, quality, level, x, y)

    return instance
end

return Equipment