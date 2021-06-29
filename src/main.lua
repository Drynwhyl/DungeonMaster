local Utils = require("Utils")

function InitModules()
    BlzLoadTOCFile("war3mapImported/ui/templates.toc")
    require("CliffDestructables")
    require("InitWaygates")
    require("HeroPick")
    require("Cheats")
    require("TestUI")
    require("randomlua")
end