    local Utils = require "Utils"

    Utils.onGameStart(function()
        --SetDayNightModels("", "")
        --SetAmbientDaySound()
        Cheat("iseedeadpeople")
        --Cheat("riseandshine")
        Cheat("thereisnospoon")
        --Cheat("whosyourdaddy")
        --SetRandomSeed(534435)
        CameraSetupApply(gg_cam_Camera_001)
        --SetCameraField(CAMERA_FIELD_FARZ, 3000, 1)
        --ResetToGameCamera(0)
        --local testUnit = CreateUnit(Player(0), FourCC("H   "), 0, 0, 0)
    end)

    local function scanChild(frame, str, name)
        local text = BlzFrameGetText(frame)
        local foundIndex = text:find(str, 1, true)
        if text ~= nil and text:len() > 0 then
            print("frame:", name, text)
        end
        if foundIndex ~= nil then
            return foundIndex
        end
        for i = 0, BlzFrameGetChildrenCount(frame) - 1 do
            local child = BlzFrameGetChild(frame, i)
            local idx = scanChild(child, str, name .. "." .. i)
            if idx ~= nil then
                return idx
            end
        end
        return nil
    end

    Utils.onGameStart(function()
        local t = CreateTrigger()
        TriggerRegisterPlayerChatEvent(t, Player(0), "w", true)
        TriggerAddAction(t, Utils.pcall(function()
            --local frame = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
            --print("idx", scanChild(frame, "Broad sword", "gameui"))
            local frame2 =  BlzGetOriginFrame(ORIGIN_FRAME_SIMPLE_UI_PARENT, 0)
            print("idx", scanChild(frame2, "Broad sword", "simpleui"))
            local frame3=  BlzGetFrameByName("ConsoleUIBackdrop", 0)
            print("idx", scanChild(frame3, "Broad sword", "console"))
            local frame4=  BlzGetOriginFrame(ORIGIN_FRAME_UBERTOOLTIP, 0)
            local frame5 = BlzFrameGetParent(frame4)
            print("idx", scanChild(frame5, "Broad sword", "ubertip"))
        end))
    end)

    Utils.onGameStart(Utils.pcall(function()
        local TextTag = require("TextTag")
        local tt = TextTag.XY(0, 0, "Test", 255, 255, 255, true)


        local t = CreateTrigger()
        TriggerRegisterPlayerEvent(t, Player(0), EVENT_PLAYER_MOUSE_MOVE)
        TriggerAddAction(t, Utils.pcall(function()
            local mouseX, mouseY = BlzGetTriggerPlayerMouseX(), BlzGetTriggerPlayerMouseY()
            local mousePos = BlzGetTriggerPlayerMousePosition()
            local rect = RectFromCenterSizeBJ(mousePos, 128, 128)
            local dist = 999
            local item
            EnumItemsInRect(rect, nil, function()
                local enumItem = GetEnumItem()
                local newDist = DistanceBetweenPoints(GetItemLoc(enumItem), mousePos)
                if newDist >= dist then
                    return
                end
                item = enumItem
                dist = newDist
            end)
            if item ~= nil then
                SetTextTagPos(tt, GetItemX(item), GetItemY(item), 32.0)
                SetTextTagText(tt, GetItemName(item), 0.024)
            end
        end))
    end))


