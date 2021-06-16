WM('HeroPick', function(import, export, exportDefault)

    local Utils = import 'Utils'

    local UNIT_ID_HERO_PICKER = FourCC('n   ')
    local UNIT_ID_TAVERN = FourCC('ntav')

    local RECT_HERO_PICK = gg_rct_HeroPick
    local RECT_START = gg_rct_Base

    Utils.onGameStart(Utils.pcall(function()
        local location = GetRectCenter(RECT_HERO_PICK)
        ForForce(bj_FORCE_ALL_PLAYERS, function()
            local unit = CreateUnitAtLoc(GetEnumPlayer(), UNIT_ID_HERO_PICKER, location, 0)
            --SetCameraTargetController(unit, 0, 0, false)
        end)
        GroupEnumUnitsOfPlayer(CreateGroup(), Player(PLAYER_NEUTRAL_PASSIVE), Filter(function()
            if GetUnitTypeId(GetFilterUnit()) == UNIT_ID_TAVERN then
                SelectUnitSingle(GetFilterUnit())
            end
        end))
        local trigger = CreateTrigger()
        TriggerRegisterPlayerUnitEvent(trigger, Player(PLAYER_NEUTRAL_PASSIVE), EVENT_PLAYER_UNIT_SELL, nil)
        TriggerAddAction(trigger, function()
            if GetUnitTypeId(GetSellingUnit()) == UNIT_ID_TAVERN then
                local hero = GetSoldUnit()
                RemoveUnit(GetBuyingUnit())
                --SetCameraTargetController(GetSoldUnit(), 0, 0, false)
                SelectUnitForPlayerSingle(hero, GetOwningPlayer(hero))
                SetUnitPosition(hero, GetRectCenterX(RECT_START), GetRectCenterY(RECT_START))
                PanCameraToTimed(GetUnitX(hero), GetUnitY(hero), 0)
            end
        end)
        RemoveLocation(location)
    end))
end)
