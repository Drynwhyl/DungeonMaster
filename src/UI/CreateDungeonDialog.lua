local Utils = require "Utils"

---@class PlayerData
---@field public opened boolean
---@field public loadMode boolean
---@field public bloodOffering boolean
---@field public rottedOffering boolean
---@field public cursedOffering boolean
---@field public level number
---@field public glyph string
local PlayerData = {}

function PlayerData:new()
    local instance = {
        opened = false,
        loadMode = false,
        bloodOffering = false,
        rottedOffering = false,
        cursedOffering = false,
        level = 1,
        glyph = "",
    }

    setmetatable(instance, self)
    self.__index = self

    return instance
end

---@class CreateDungeonDialog
---@field public playerData table<player, PlayerData>
---@field private frame framehandle
---@field private createHandler fun(dialog:CreateDungeonDialog)
local CreateDungeonDialog = {}

local function playerDataTableIndex(self, key)
    local playerData = PlayerData:new()
    self[key] = playerData
    return playerData
end

---@param createHandler fun(dialog:CreateDungeonDialog, player:player):void
function CreateDungeonDialog:new(createHandler)
    ---@type CreateDungeonDialog
    local instance = {
        createHandler = createHandler,
        playerData = setmetatable({}, { __index = playerDataTableIndex })
    }

    setmetatable(instance, self)
    self.__index = self

    instance.frame = instance:createFrame()

    return instance
end

---@param player player
function CreateDungeonDialog:open(player)
    if GetLocalPlayer() == player then
        self.playerData[player].opened = true
        BlzFrameSetVisible(self.frame, true)
    end
end

---@param player player
function CreateDungeonDialog:close(player)
    if GetLocalPlayer() == player then
        self.playerData[player].opened = false
        BlzFrameSetVisible(self.frame, false)
    end
end

local function doForChildren(parentFrame, func, ...)
    for i = 0, BlzFrameGetChildrenCount(parentFrame) - 1 do
        func(BlzFrameGetChild(parentFrame, i), ...)
    end
end

function CreateDungeonDialog:createFrame()
    -- create a hidden Frame a container for all
    local windowContainerFrame = BlzCreateFrameByType("FRAME", "", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "", 0)

    -- create a box as child of the container
    local boxFrame = BlzCreateFrameByType("BACKDROP", "", windowContainerFrame, "EscMenuBackdrop", 0)
    BlzFrameSetSize(boxFrame, 0.4, 0.3)
    BlzFrameSetAbsPoint(boxFrame, FRAMEPOINT_CENTER, 0.4, 0.35)

    local newDungeonFrame = BlzCreateFrameByType("FRAME", "", boxFrame, "", 0)
    local loadDungeonFrame = BlzCreateFrameByType("FRAME", "", boxFrame, "", 0)

    -- CREATE DUNGEON
    -- Radiobutton
    local newDungeonRadioButtonActive = BlzCreateFrame("CustomRadioButtonActive", windowContainerFrame, 0, 0)
    BlzFrameSetPoint(newDungeonRadioButtonActive, FRAMEPOINT_TOPLEFT, boxFrame, FRAMEPOINT_TOPLEFT, 0.04, -0.04)
    BlzFrameSetVisible(newDungeonRadioButtonActive, false)
    local newDungeonRadioButtonNotActive = BlzCreateFrame("CustomRadioButtonNotActive", windowContainerFrame, 0, 0)
    BlzFrameSetPoint(newDungeonRadioButtonNotActive, FRAMEPOINT_TOPLEFT, boxFrame, FRAMEPOINT_TOPLEFT, 0.04, -0.04)
    -- Label
    local generateDungeonLabel = BlzCreateFrame("EscMenuMainPanelDialogTextTemplate", windowContainerFrame, 0, 0)
    BlzFrameSetText(generateDungeonLabel, "New dungeon")
    BlzFrameSetPoint(generateDungeonLabel, FRAMEPOINT_TOPLEFT, boxFrame, FRAMEPOINT_TOPLEFT, 0.06125, -0.041875)
    -- END CREATE DUNGEON

    -- LOAD DUNGEON
    -- Radiobutton
    local loadDungeonRadioButtonActive = BlzCreateFrame("CustomRadioButtonActive", windowContainerFrame, 0, 0)
    BlzFrameSetPoint(loadDungeonRadioButtonActive, FRAMEPOINT_TOPLEFT, boxFrame, FRAMEPOINT_TOPLEFT, 0.04 + 0.16, -0.04)
    BlzFrameSetVisible(loadDungeonRadioButtonActive, false)
    local loadDungeonRadioButtonNotActive = BlzCreateFrame("CustomRadioButtonNotActive", windowContainerFrame, 0, 0)
    BlzFrameSetPoint(loadDungeonRadioButtonNotActive, FRAMEPOINT_TOPLEFT, boxFrame, FRAMEPOINT_TOPLEFT, 0.04 + 0.16, -0.04)
    -- Label
    local loadDungeonLabel = BlzCreateFrame("EscMenuMainPanelDialogTextTemplate", windowContainerFrame, 0, 0)
    BlzFrameSetText(loadDungeonLabel, "Load dungeon")
    BlzFrameSetPoint(loadDungeonLabel, FRAMEPOINT_TOPLEFT, boxFrame, FRAMEPOINT_TOPLEFT, 0.06125 + 0.16, -0.041875)
    -- END LOAD DUNGEON

    -- GLYPH
    -- Label
    local glyphLabel = BlzCreateFrame("EscMenuMainPanelDialogTextTemplate", loadDungeonFrame, 0, 0)
    BlzFrameSetText(glyphLabel, "Glyph:")
    BlzFrameSetPoint(glyphLabel, FRAMEPOINT_TOPLEFT, boxFrame, FRAMEPOINT_TOPLEFT, 0.2, -0.08)
    --BlzFrameSetVisible(glyphLabel, false)
    -- Editbox
    local glyphEditBox = BlzCreateFrame("CustomEditBox", loadDungeonFrame, 0, 0)
    BlzFrameSetSize(glyphEditBox, 0.1, 0.03) --set the boxs size
    BlzFrameSetPoint(glyphEditBox, FRAMEPOINT_TOPLEFT, boxFrame, FRAMEPOINT_TOPLEFT, 0.25, -0.0725)
    BlzFrameSetTextSizeLimit(glyphEditBox, 10)
    -- END GLYPH

    -- OFFERINGS
    -- Label
    local bloodOfferingLabel = BlzCreateFrame("EscMenuMainPanelDialogTextTemplate", newDungeonFrame, 0, 0)
    BlzFrameSetText(bloodOfferingLabel, "Blood Offering")
    BlzFrameSetPoint(bloodOfferingLabel, FRAMEPOINT_TOPLEFT, boxFrame, FRAMEPOINT_TOPLEFT, 0.06, -0.08)
    -- Checkbox
    local bloodOfferingCheckbox = BlzCreateFrame("QuestCheckBox", newDungeonFrame, 0, 0)
    BlzFrameSetPoint(bloodOfferingCheckbox, FRAMEPOINT_TOPLEFT, boxFrame, FRAMEPOINT_TOPLEFT, 0.05625, -0.11125)
    BlzFrameSetScale(bloodOfferingCheckbox, 0.7)

    -- Label
    local rottedOfferingLabel = BlzCreateFrame("EscMenuMainPanelDialogTextTemplate", newDungeonFrame, 0, 0)
    BlzFrameSetText(rottedOfferingLabel, "Rotted Offering")
    BlzFrameSetPoint(rottedOfferingLabel, FRAMEPOINT_TOPLEFT, boxFrame, FRAMEPOINT_TOPLEFT, 0.06, -0.1)
    -- Checkbox
    local rottedOfferingCheckbox = BlzCreateFrame("QuestCheckBox", newDungeonFrame, 0, 0)
    BlzFrameSetPoint(rottedOfferingCheckbox, FRAMEPOINT_TOPLEFT, boxFrame, FRAMEPOINT_TOPLEFT, 0.05625, -0.14)
    BlzFrameSetScale(rottedOfferingCheckbox, 0.7)

    -- Label
    local cursedOfferingLabel = BlzCreateFrame("EscMenuMainPanelDialogTextTemplate", newDungeonFrame, 0, 0)
    BlzFrameSetText(cursedOfferingLabel, "Cursed Offering")
    BlzFrameSetPoint(cursedOfferingLabel, FRAMEPOINT_TOPLEFT, boxFrame, FRAMEPOINT_TOPLEFT, 0.06, -0.12)
    -- Checkbox
    local cursedOfferingCheckbox = BlzCreateFrame("QuestCheckBox", newDungeonFrame, 0, 0)
    BlzFrameSetPoint(cursedOfferingCheckbox, FRAMEPOINT_TOPLEFT, boxFrame, FRAMEPOINT_TOPLEFT, 0.05625, -0.16875)
    BlzFrameSetScale(cursedOfferingCheckbox, 0.7)
    -- END OFFERINGS

    -- LEVEL
    -- Slider
    local levelSlider = BlzCreateFrame("EscMenuSliderTemplate", newDungeonFrame, 0, 0)
    BlzFrameSetMinMaxValue(levelSlider, 1, 100)
    BlzFrameSetStepSize(levelSlider, 1)
    BlzFrameSetValue(levelSlider, 1)
    BlzFrameSetPoint(levelSlider, FRAMEPOINT_TOPLEFT, boxFrame, FRAMEPOINT_TOPLEFT, 0.0375, -0.18)
    -- label
    local levelLabel = BlzCreateFrame("EscMenuMainPanelDialogTextTemplate", newDungeonFrame, 0, 0)
    BlzFrameSetText(levelLabel, "Dungeon level: 100")
    BlzFrameSetPoint(levelLabel, FRAMEPOINT_TOPLEFT, boxFrame, FRAMEPOINT_TOPLEFT, 0.04, -0.16)
    -- END LEVEL

    -- BUTTONS
    --local createButton = BlzCreateFrameByType("GLUETEXTBUTTON", "MyScriptDialogButton", boxFrame, "EscMenuButtonTemplate", 0)
    local createButton = BlzCreateFrame("CustomTextButton", boxFrame, 0, 0)
    -- place the Button to the center of the Screen
    BlzFrameSetSize(createButton, 0.15, 0.035)
    BlzFrameSetText(createButton, "Create")
    BlzFrameSetPoint(createButton, FRAMEPOINT_TOPLEFT, boxFrame, FRAMEPOINT_TOPLEFT, 0.0375, -0.22)

    local cancelButton = BlzCreateFrame("CustomTextButton", boxFrame, 0, 0)
    -- place the Button to the center of the Screen
    BlzFrameSetSize(cancelButton, 0.15, 0.035)
    BlzFrameSetText(cancelButton, "Cancel")
    BlzFrameSetPoint(cancelButton, FRAMEPOINT_TOPRIGHT, boxFrame, FRAMEPOINT_TOPRIGHT, -0.04, -0.22)
    -- END BUTTONS

    -- The option to close (hide) the box
    local closeButton = BlzCreateFrame("CustomTextButton", boxFrame, 0, 0)
    BlzFrameSetSize(closeButton, 0.03, 0.03)
    BlzFrameSetText(closeButton, "X")
    BlzFrameSetPoint(closeButton, FRAMEPOINT_TOPRIGHT, boxFrame, FRAMEPOINT_TOPRIGHT, 0, 0)

    -- this trigger handles clicking the close Button, it hides the Logical super Parent when the close Button is clicked for the clicking Player.
    local closeTrigger = CreateTrigger()
    BlzTriggerRegisterFrameEvent(closeTrigger, closeButton, FRAMEEVENT_CONTROL_CLICK)
    BlzTriggerRegisterFrameEvent(closeTrigger, cancelButton, FRAMEEVENT_CONTROL_CLICK)
    TriggerAddAction(closeTrigger, function()
        if GetLocalPlayer() == GetTriggerPlayer() then
            BlzFrameSetVisible(windowContainerFrame, false)
        end
    end)

    local createButtonTrigger = CreateTrigger()
    BlzTriggerRegisterFrameEvent(createButtonTrigger, createButton, FRAMEEVENT_CONTROL_CLICK)
    TriggerAddAction(createButtonTrigger, function()
        print("click")
        self.createHandler(self, GetTriggerPlayer())
    end)

    local offeringTrigger = CreateTrigger()
    BlzTriggerRegisterFrameEvent(offeringTrigger, bloodOfferingCheckbox, FRAMEEVENT_CHECKBOX_CHECKED)
    BlzTriggerRegisterFrameEvent(offeringTrigger, rottedOfferingCheckbox, FRAMEEVENT_CHECKBOX_CHECKED)
    BlzTriggerRegisterFrameEvent(offeringTrigger, cursedOfferingCheckbox, FRAMEEVENT_CHECKBOX_CHECKED)
    BlzTriggerRegisterFrameEvent(offeringTrigger, bloodOfferingCheckbox, FRAMEEVENT_CHECKBOX_UNCHECKED)
    BlzTriggerRegisterFrameEvent(offeringTrigger, rottedOfferingCheckbox, FRAMEEVENT_CHECKBOX_UNCHECKED)
    BlzTriggerRegisterFrameEvent(offeringTrigger, cursedOfferingCheckbox, FRAMEEVENT_CHECKBOX_UNCHECKED)
    TriggerAddAction(offeringTrigger, function()
        local frame = BlzGetTriggerFrame()
        local checkboxValue = BlzGetTriggerFrameEvent() == FRAMEEVENT_CHECKBOX_CHECKED
        local player = GetTriggerPlayer()
        if frame == bloodOfferingCheckbox then
            self.playerData[player].bloodOffering = checkboxValue
        elseif frame == rottedOfferingCheckbox then
            self.playerData[player].rottedOffering = checkboxValue
        elseif frame == cursedOfferingCheckbox then
            self.playerData[player].cursedOffering = checkboxValue
        end
    end)

    local switchModeTrigger = CreateTrigger()
    BlzTriggerRegisterFrameEvent(switchModeTrigger, newDungeonRadioButtonNotActive, FRAMEEVENT_CONTROL_CLICK)
    BlzTriggerRegisterFrameEvent(switchModeTrigger, loadDungeonRadioButtonNotActive, FRAMEEVENT_CONTROL_CLICK)
    TriggerAddAction(switchModeTrigger, function()
        local frame = BlzGetTriggerFrame()
        local player = GetTriggerPlayer()
        if frame == newDungeonRadioButtonNotActive then
            -- Switch to NEW_DUNGEON mode
            self.playerData[player].loadMode = false
            if GetLocalPlayer() == player then
                BlzFrameSetVisible(newDungeonRadioButtonNotActive, false)
                BlzFrameSetVisible(newDungeonRadioButtonActive, true)
                BlzFrameSetVisible(loadDungeonRadioButtonNotActive, true)
                BlzFrameSetVisible(loadDungeonRadioButtonActive, false)
                doForChildren(newDungeonFrame, BlzFrameSetEnable, true)
                doForChildren(loadDungeonFrame, BlzFrameSetEnable, false)
            end
        elseif frame == loadDungeonRadioButtonNotActive then
            -- Switch to LOAD_DUNGEON mode
            self.playerData[player].loadMode = true
            if GetLocalPlayer() == player then
                BlzFrameSetVisible(loadDungeonRadioButtonNotActive, false)
                BlzFrameSetVisible(loadDungeonRadioButtonActive, true)
                BlzFrameSetVisible(newDungeonRadioButtonNotActive, true)
                BlzFrameSetVisible(newDungeonRadioButtonActive, false)
                doForChildren(newDungeonFrame, BlzFrameSetEnable, false)
                doForChildren(loadDungeonFrame, BlzFrameSetEnable, true)
            end
        end
    end)

    local levelSliderTrigger = CreateTrigger()
    BlzTriggerRegisterFrameEvent(levelSliderTrigger, levelSlider, FRAMEEVENT_SLIDER_VALUE_CHANGED)
    TriggerAddAction(levelSliderTrigger, function()
        local newLevelValue = math.floor(BlzGetTriggerFrameValue())
        self.level = newLevelValue
        BlzFrameSetText(levelLabel, "Dungeon level: " .. newLevelValue)
    end)

    local editBoxTrigger = CreateTrigger()
    BlzTriggerRegisterFrameEvent(editBoxTrigger, glyphEditBox, FRAMEEVENT_EDITBOX_TEXT_CHANGED)
    TriggerAddAction(editBoxTrigger, function()
        self.glyph = BlzGetTriggerFrameText()
    end)

    -- Because one can close (hide) the box, one also should be able to show it again, this is done with an button that is only visible while the player is in Menu (F10)
    local showButton = BlzCreateFrameByType("GLUETEXTBUTTON", "", BlzGetFrameByName("InsideMainPanel", 0), "ScriptDialogButton", 0)
    BlzFrameSetSize(showButton, 0.08, 0.04)
    BlzFrameSetText(showButton, "show Info Frame")
    BlzFrameSetAbsPoint(showButton, FRAMEPOINT_BOTTOMLEFT, 0, 0.2)

    local showTrigger = CreateTrigger()
    BlzTriggerRegisterFrameEvent(showTrigger, showButton, FRAMEEVENT_CONTROL_CLICK)
    TriggerAddAction(showTrigger, function()
        if GetLocalPlayer() == GetTriggerPlayer() then
            BlzFrameSetVisible(windowContainerFrame, true)
        end
    end)

    BlzFrameSetVisible(windowContainerFrame, false)
    TimerStart(CreateTimer(), 0, false, function()
        BlzFrameClick(newDungeonRadioButtonNotActive)
        DestroyTimer(GetExpiredTimer())
    end)
    return windowContainerFrame
end

return CreateDungeonDialog