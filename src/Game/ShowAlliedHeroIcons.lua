local Utils = require "Utils"

Utils.onGameStart(function()
    local players = {}
    ForForce(bj_FORCE_ALL_PLAYERS, function()
        players[GetPlayerId(GetEnumPlayer())] = GetEnumPlayer()
    end)

    for i = 0, 3 do
        for j = 0, 3 do
            SetPlayerAllianceBJ(Player(j), ALLIANCE_SHARED_ADVANCED_CONTROL, true, Player(i))
            SetPlayerAllianceBJ(Player(j), ALLIANCE_SHARED_CONTROL, false, Player(i))
        end
    end

    CreateMultiboardBJ(1, 1, "TRIGSTR_040")
    MultiboardDisplayBJ(true, GetLastCreatedMultiboard())
    MultiboardDisplayBJ(false, GetLastCreatedMultiboard())
    DestroyMultiboardBJ(GetLastCreatedMultiboard())
end)