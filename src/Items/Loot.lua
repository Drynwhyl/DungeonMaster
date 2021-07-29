require "StatSystem"
require "OrderSystem"
local ItemTypes = require "ItemTypes"
local Utils = require "Utils"
local WC3Math = require "WC3Math"

local UNIT_ID_DUMMY_ITEM = FourCC("n  !")
local MAX_DROPPED_ITEMS = 5
local ITEM_QUALITY = {
    POOR = { name = "POOR", color = 0xff808080 },
    COMMON = { name = "COMMON", color = 0xffffffff },
    UNCOMMON = { name = "UNCOMMON", color = 0xff40ff40 },
    RARE = { name = "RARE", color = 0xff3895ff },
    EPIC = { name = "EPIC", color = 0xffa335ee },
}

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

local function ChooseItemType(class)
    local classItemNumber = #ItemTypes[class]
    local randomTypeIndex = math.random(1, classItemNumber)
    return ItemTypes[class][randomTypeIndex]
end

local createLootTrigger = CreateTrigger()
TriggerRegisterPlayerUnitEvent(createLootTrigger, Player(PLAYER_NEUTRAL_AGGRESSIVE), EVENT_PLAYER_UNIT_DEATH)
TriggerAddAction(createLootTrigger, Utils.pcall(function()
    local itemCount = 1 --GetDropItemsCount()
    if itemCount == 0 then
        return
    end
    local unit = GetDyingUnit()
    for _ = 1, itemCount do
        local itemClass = ChooseItemClass()
        local itemType = ChooseItemType(itemClass)
        local quality = ChooseItemQuality()
        local level = GetUnitLevel(unit)
        Equipment:new(itemType, quality, level, GetUnitX(unit), GetUnitY(unit))
    end
end))

local pickupTrigger = CreateTrigger()
TriggerRegisterAnyUnitEventBJ(pickupTrigger, EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER)
TriggerAddAction(pickupTrigger, function()
    local unit = GetOrderedUnit()
    local dummyUnit = GetOrderTargetUnit()
    if GetIssuedOrderId() == ORDER_smart
    and GetUnitTypeId(dummyUnit) == UNIT_ID_DUMMY_ITEM
    and IsUnitInRange(unit, dummyUnit, 128) then
        -- Force unit to stop from moving directly into item, but since trigger events fires earlier than actual order is issued
        -- to unit we can't use "stop" order. "move" order puts it in queue and that will fire after current order
        -- Use polarProjection with small offset to prevent unit from turning around if we use his own position to move
        IssuePointOrderById(unit, ORDER_move, WC3Math.polarProjection(GetUnitX(unit), GetUnitY(unit), 0.01, GetUnitFacing(unit)))
        local item = Equipment:getByHandle(dummyUnit).item
        SetItemVisible(item, true)
        UnitAddItem(unit, item)
        ShowUnit(dummyUnit, false)
    end
end)

local equipTrigger = CreateTrigger()
TriggerRegisterAnyUnitEventBJ(equipTrigger, EVENT_PLAYER_UNIT_PICKUP_ITEM)
TriggerRegisterAnyUnitEventBJ(equipTrigger, EVENT_PLAYER_UNIT_DROP_ITEM)
TriggerAddAction(equipTrigger, Utils.pcall(function()
    local item = GetManipulatedItem()
    local unit = GetManipulatingUnit()
    local event = GetTriggerEventId()
    local thisTrigger = GetTriggeringTrigger()

    if event == EVENT_PLAYER_UNIT_PICKUP_ITEM then
        for statName, statData in pairs(Equipment:getByHandle(item).stats) do
            SetUnitStat(unit, statName, statData.type, GetUnitStat(unit, statName, statData.type) + statData.value)
        end
    elseif event == EVENT_PLAYER_UNIT_DROP_ITEM then
        Utils.doAfter(0, function()
            local dummyUnit = Equipment.map[item].unit
            local x, y = GetItemX(item), GetItemY(item)
            SetUnitPosition(dummyUnit, x, y)
            ShowUnit(dummyUnit, true)

            DisableTrigger(thisTrigger)
            SetItemPosition(item, x, y)
            SetItemVisible(item, true)
            SetItemVisible(item, false)
            --print("set item invisible", IsItemVisible(item), GetItemName(item))
            EnableTrigger(thisTrigger)

            for statName, statData in pairs(Equipment:getByHandle(item).stats) do
                SetUnitStat(unit, statName, statData.type, GetUnitStat(unit, statName, statData.type) - statData.value)
            end
        end)
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
    BlzFrameSetVisible(tooltip, false)

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
            BlzFrameSetVisible(BlzGetOriginFrame(ORIGIN_FRAME_UBERTOOLTIP, 0), false)
            local itemName = Equipment:getByHandle(item) ~= nil and Equipment:getByHandle(item).name or GetItemName(item)
            local itemDesc = Equipment:getByHandle(item) ~= nil and Equipment:getByHandle(item).desc or BlzGetItemExtendedTooltip(item)
            local descriptionSize = repeats(itemDesc, "\n")
            BlzFrameSetVisible(tooltip, true)
            BlzFrameSetSize(tooltip, 0.315, 0.012 * descriptionSize + 0.05)
            BlzFrameSetText(BlzGetFrameByName("BoxedTextTitle", 0), itemName)--BoxedText has a child showing the Title-text, set that childs
            BlzFrameSetText(BlzGetFrameByName("BoxedTextValue", 0), itemDesc)--BoxedText has a child showing the text, set that childs Text.
            BlzFrameSetText(BlzGetFrameByName("BoxedTextGoldValue", 0), "500")--BoxedText has a child showing the Title-text, set that childs
        end
    end
end