local Utils = require("Utils")

local trigger = CreateTrigger()
TriggerRegisterPlayerChatEvent(trigger, Player(0), "-s1", true)
TriggerRegisterPlayerChatEvent(trigger, Player(0), "-s2", true)
TriggerAddAction(trigger, function()
    if GetEventPlayerChatString() == "-s1" then
        SetDayNightModels("", "")
    else
        SetDayNightModels("Environment\\DNC\\DNCLordaeron\\DNCLordaeronTerrain\\DNCLordaeronTerrain.mdl", "Environment\\DNC\\DNCLordaeron\\DNCLordaeronUnit\\DNCLordaeronUnit.mdl")
    end
end)

function InitModules()
    BlzLoadTOCFile("war3mapImported/ui/templates.toc")
    require("CliffDestructables")
    require("InitWaygates")
    require("HeroPick")
    require("Cheats")
    require("TestUI")
    require("randomlua")
end