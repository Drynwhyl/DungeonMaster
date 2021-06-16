WM("Cheats", function(import, export, exportDefault)
    local Utils = import "Utils"

    Utils.onGameStart(function()
        --SetDayNightModels("", "")
        --SetAmbientDaySound()
        Cheat("iseedeadpeople")
        --Cheat("riseandshine")
        Cheat("thereisnospoon")
        Cheat("whosyourdaddy")
        --SetRandomSeed(534435)
        CameraSetupApply(gg_cam_Camera_001)
    end)
end)
