WM("Cheats", function(import, export, exportDefault)
    local Utils = import "Utils"

    Utils.onGameStart(function()
        SetAmbientDaySound()
        Cheat("iseedeadpeople")
        --Cheat("riseandshine")
        Cheat("thereisnospoon")
        Cheat("whosyourdaddy")
        SetRandomSeed(534435)
        SetDayNightModels("", "")
    end)
end)
