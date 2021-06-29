local Utils = require "Utils"
local RoomTemplate = require "RoomTemplate"

local roomTemplateRects = {
    common = {
        roomTemplateRects = {
            gg_rct_Region_000,
            gg_rct_Region_001,
            gg_rct_Room000,
            gg_rct_Room001,
            gg_rct_Room002,
            gg_rct_Room003,
            gg_rct_Room004,
        },
        startRoomTemplateRects = {
            gg_rct_StartRoom_001,
        },
        bossRoomTemplateRects = {
            gg_rct_BossRoom_001,
        }
    }
}

local RoomTemplateDefinitions = {}

Utils.onGameStart(function()
    print("parsing room templates...")
    for type, rects in pairs(roomTemplateRects) do
        RoomTemplateDefinitions[type] = {}
        RoomTemplateDefinitions[type].roomTemplates = RoomTemplate:batchParse(rects.roomTemplateRects)
        RoomTemplateDefinitions[type].startRoomTemplates = RoomTemplate:batchParse(rects.startRoomTemplateRects)
        RoomTemplateDefinitions[type].bossRoomTemplates = RoomTemplate:batchParse(rects.bossRoomTemplateRects)
        RoomTemplateDefinitions[type].leverRoomTemplates = RoomTemplateDefinitions[type].roomTemplates
    end
    print("parsing room templates end")
end)

return RoomTemplateDefinitions