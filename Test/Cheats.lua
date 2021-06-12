WM("Cheats", function(import, export, exportDefault)
    local Utils = import "Utils"

    Utils.onGameStart(function()
        Cheat("iseedeadpeople")
        --Cheat("riseandshine")
        Cheat("thereisnospoon")
        Cheat("whosyourdaddy")
        SetRandomSeed(534435)
    end)
end)
