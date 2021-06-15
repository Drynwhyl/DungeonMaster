WM("InitWaygates", function(import, export, exportDefault)

    local Utils = import "Utils"
    local CreateDungeon = import "DungeonGenerator"

    local WAYGATE_UNIT_ID = FourCC("nwgt")
    local GENERATE_COMMAND_PREFIX = "-g"

    local playerCurrentWaygate = {}
    local waygateRegions = {}

    Utils.onGameStart(function()
        local waygates = CreateGroup()
        GroupEnumUnitsInRect(waygates, GetPlayableMapRect(), Filter(function()
            if GetUnitTypeId(GetFilterUnit()) ~= WAYGATE_UNIT_ID then
                return false
            end
            print("for group")
            local waygate = GetFilterUnit()
            local position = GetUnitLoc(waygate)
            local rect = RectFromCenterSizeBJ(position, 2 * bj_CELLWIDTH, 2 * bj_CELLWIDTH)
            local region = CreateRegion()
            RegionAddRect(region, rect)
            waygateRegions[waygate] = region

            print("create trig 1")
            local trigger = CreateTrigger()
            TriggerRegisterEnterRegion(trigger, region, Filter(function()
                local unit = GetFilterUnit()
                print("trig 1")
                print(IsUnitType(unit) == UNIT_TYPE_HERO, GetPlayerController(GetOwningPlayer(unit)) == MAP_CONTROL_USER)
                if IsUnitType(unit, UNIT_TYPE_HERO) and GetPlayerController(GetOwningPlayer(unit)) == MAP_CONTROL_USER then
                    print("trig 1 passed")
                    playerCurrentWaygate[GetOwningPlayer(unit)] = waygate
                    --AddUnitAnimationProperties(waygate, "Alternate", true)
                    print("trig 1 ok")
                end
            end))
            print("create trig 2")
            TriggerRegisterLeaveRegion(trigger, region, Filter(function()
                local unit = GetFilterUnit()
                print("trig 2")
                if IsUnitType(unit, UNIT_TYPE_HERO) and GetPlayerController(GetOwningPlayer(unit)) == MAP_CONTROL_USER then
                    print("trig 2 passed")
                    playerCurrentWaygate[GetOwningPlayer(unit)] = nil
                    --AddUnitAnimationProperties(waygate, "Alternate", false)
                    print("trig 2 ok")
                end
            end))
        end))

        print("group size", CountUnitsInGroup(waygates))

        local trigger = CreateTrigger()
        TriggerRegisterPlayerChatEvent(trigger, Player(0), GENERATE_COMMAND_PREFIX, false)
        TriggerAddAction(trigger, Utils.pcall(function()
            local command = GetEventPlayerChatString()
            local argument = SubString(command, StringLength(GENERATE_COMMAND_PREFIX) + 1, StringLength(command))
            local seed
            if seed == "r" then
                seed = GetRandomInt(-2147483648, 2147483647)
            else
                seed = S2I(argument)
            end
            local start = CreateDungeon(seed)
            local waygate = playerCurrentWaygate[GetTriggerPlayer()]
            WaygateActivate(waygate, true)
            WaygateSetDestination(waygate, start.x, start.y)
        end))
    end)
end)