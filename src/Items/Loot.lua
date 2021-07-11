require "StatSystem"
local ItemTypes = require "ItemTypes"
local Utils = require "Utils"
local TextUtils = require "TextUtils"

local MAX_DROPPED_ITEMS = 5
local ITEM_QUALITY = {
    POOR = { name = "POOR", color = 0xffc0c0c0 },
    COMMON = { name = "COMMON", color = 0xffffffff },
    UNCOMMON = { name = "UNCOMMON", color = 0xff80ff80 },
    RARE = { name = "RARE", color = 0xff3895ff },
    EPIC = { name = "EPIC", color = 0xffa335ee },
}

local itemStats = {}

local function GetDropItemsCount()
    RandomDistReset()
    for i = 0, MAX_DROPPED_ITEMS do
        RandomDistAddItem(i, MAX_DROPPED_ITEMS - i + 1)
    end
    return RandomDistChoose()
end

local function ChooseItemClass()
    local itemClasses = {}
    for itemClass, _ in pairs(ItemTypes) do
        table.insert(itemClasses, itemClass)
    end
    local randomClassIndex = math.random(1, #itemClasses)
    return itemClasses[randomClassIndex]
end

local function ChooseItemQuality()
    local qualityName = {
        "POOR",
        "COMMON",
        "UNCOMMON",
        "RARE",
        "EPIC",
    }
    RandomDistReset()
    for i = 1, #qualityName do
        RandomDistAddItem(i, #qualityName - i + 1)
    end
    return ITEM_QUALITY[qualityName[RandomDistChoose()]]
end

--local function CountItemsInTable(tab)
--    local count = 0
--    for _ in pairs(tab) do
--        count = count + 1
--    end
--    return count
--end

local function ChooseItemType(class)
    local classItemNumber = #ItemTypes[class]
    local randomTypeIndex = math.random(1, classItemNumber)
    return ItemTypes[class][randomTypeIndex]
end

local function ApplyQuality(item, quality)
    local itemName = GetItemName(item)
    BlzSetItemName(item, "1")
    BlzSetItemDescription(item, "2")
    BlzSetItemTooltip(item, "3")
    BlzSetItemExtendedTooltip(item, "4")
    print("colored text", BlzGetItemTooltip(item))
    local a, r, g, b = TextUtils.intToARGB(quality.color)
    BlzSetItemIntegerField(item, ITEM_IF_TINTING_COLOR_ALPHA, a)
    BlzSetItemIntegerField(item, ITEM_IF_TINTING_COLOR_RED, r)
    BlzSetItemIntegerField(item, ITEM_IF_TINTING_COLOR_GREEN, g)
    BlzSetItemIntegerField(item, ITEM_IF_TINTING_COLOR_BLUE, b)
end

local function InitItemStats(item, itemType, level)
    BlzSetItemIntegerField(item, ITEM_IF_LEVEL, level)
    itemStats[item] = {}
    for statName, statData in pairs(itemType.data.stats) do
        itemStats[item][statName] = { type = statData.type, value = statData.value }
    end
end

local function GetItemStats(item)
    return itemStats[item]
end

local dropTrigger = CreateTrigger()
TriggerRegisterPlayerUnitEvent(dropTrigger, Player(PLAYER_NEUTRAL_AGGRESSIVE), EVENT_PLAYER_UNIT_DEATH)
TriggerAddAction(dropTrigger, Utils.pcall(function()
    local itemCount = GetDropItemsCount()
    if itemCount == 0 then
        return
    end
    local unit = GetDyingUnit()
    for i = 1, itemCount do
        local itemClass = ChooseItemClass()
        local itemType = ChooseItemType(itemClass)
        local level = GetUnitLevel(unit)
        local item = CreateItem(itemType.id, GetUnitX(unit), GetUnitY(unit))
        InitItemStats(item, itemType, level)
        local quality = ChooseItemQuality()
        ApplyQuality(item, quality)
    end
end))

local equipTrigger = CreateTrigger()
TriggerRegisterAnyUnitEventBJ(equipTrigger, EVENT_PLAYER_UNIT_PICKUP_ITEM)
TriggerRegisterAnyUnitEventBJ(equipTrigger, EVENT_PLAYER_UNIT_DROP_ITEM)
TriggerAddAction(equipTrigger, Utils.pcall(function()
    local item = GetManipulatedItem()
    local unit = GetManipulatingUnit()
    local event = GetTriggerEventId()

    if event == EVENT_PLAYER_UNIT_PICKUP_ITEM then
        for statName, statData in pairs(GetItemStats(item)) do
            SetUnitStat(unit, statName, statData.type, GetUnitStat(unit, statName, statData.type) + statData.value)
        end
    elseif event == EVENT_PLAYER_UNIT_DROP_ITEM then
        for statName, statData in pairs(GetItemStats(item)) do
            SetUnitStat(unit, statName, statData.type, GetUnitStat(unit, statName, statData.type) - statData.value)
        end
    end
end))

-- creates tooltip frames (for command buttons) which are checked 32 times a second when a different tooltip is visible function HoversCommandButton is called with the new index, beaware this is async
Utils.onGameStart(Utils.pcall(function()
    local commandButtonTooltip = {}
    local frame
    local button

    -- saves the last selected Button, async
    CurrentSelectedButtonIndex = nil
    --create one tooltip frame for each command button
    for int = 0, 11 do
        button = BlzGetOriginFrame(ORIGIN_FRAME_ITEM_BUTTON, int)
        frame = BlzCreateFrameByType("SIMPLEFRAME", "", button, "", 0)
        BlzFrameSetTooltip(button, frame)
        BlzFrameSetVisible(frame, false)
        commandButtonTooltip[int] = frame
    end

    TimerStart(CreateTimer(), 1.0 / 32, true, function()
        local selectedAnything = false
        -- loop all tooltips and check for the visible one
        for int = 0, 11 do
            if BlzFrameIsVisible(commandButtonTooltip[int]) then
                selectedAnything = true
                -- the new selected is not the same as the current one?
                if CurrentSelectedButtonIndex ~= int then
                    HoversCommandButton(int)
                end
                CurrentSelectedButtonIndex = int
            end
        end
        -- now selects nothing?
        if not selectedAnything and CurrentSelectedButtonIndex then
            HoversCommandButton(nil)
            CurrentSelectedButtonIndex = nil
        end
    end)
    print("done")

    tooltip = BlzCreateFrame("BoxedText", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0, 0)--Create the BoxedText Frame
    --faceHover would be unneeded if face would support events/tooltip

    BlzFrameSetAbsPoint(tooltip, FRAMEPOINT_BOTTOMRIGHT, 0.825, 0.16)
    BlzFrameSetSize(tooltip, 0.315, 0.09)

    BlzFrameSetText(BlzGetFrameByName("BoxedTextValue", 0), "Human Paladin Face, but it is not uther.")--BoxedText has a child showing the text, set that childs Text.
    BlzFrameSetText(BlzGetFrameByName("BoxedTextTitle", 0), "Paladin")--BoxedText has a child showing the Title-text, set that childs
end))

local function repeats(s,c)
    local _,n = s:gsub(c,"")
    return n
end

function HoversCommandButton(commandButtonindex)
    if not commandButtonindex then
        --print("Now points at nothing")
        BlzFrameSetVisible(tooltip, false)
        --BlzFrameSetVisible(BlzGetOriginFrame(ORIGIN_FRAME_UBERTOOLTIP, 0), true)
    else
        --print("Now points at Button:", commandButtonindex)
        GroupEnumUnitsSelected(bj_lastCreatedGroup, Player(0), nil)
        local unit = FirstOfGroup(bj_lastCreatedGroup)
        local item = UnitItemInSlot(unit, commandButtonindex)
        if item ~= nil then
            --BlzFrameSetVisible(BlzGetOriginFrame(ORIGIN_FRAME_UBERTOOLTIP, 0), false)
            local desc = BlzGetItemExtendedTooltip(item)
            local leng = repeats(desc, "\n")
            BlzFrameSetVisible(tooltip, true)
            print("leng", leng)
            BlzFrameSetSize(tooltip, 0.315, 0.0120 * leng)
            BlzFrameSetText(BlzGetFrameByName("BoxedTextValue", 0), desc)--BoxedText has a child showing the text, set that childs Text.
            BlzFrameSetText(BlzGetFrameByName("BoxedTextTitle", 0), GetItemName(item))--BoxedText has a child showing the Title-text, set that childs
        end
    end
end