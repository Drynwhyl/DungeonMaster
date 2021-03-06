local Utils = require "Utils"

local UNIT_ID_HERO_PICKER = FourCC("n   ")
local UNIT_ID_TAVERN = FourCC("ntav")

local RECT_HERO_PICK = gg_rct_HeroPick
local RECT_START = gg_rct_Base

local PlayerHero = {}

Utils.onGameStart(Utils.pcall(function()
    local location = GetRectCenter(RECT_HERO_PICK)
    ForForce(bj_FORCE_ALL_PLAYERS, function()
        print("unit ", GetLocationY(location), GetLocationY(location), RECT_HERO_PICK == nil)
        local unit = CreateUnitAtLoc(GetEnumPlayer(), UNIT_ID_HERO_PICKER, location, 0)
        --SetCameraTargetController(unit, 0, 0, false)
    end)

    local tavern = CreateUnitAtLoc(Player(PLAYER_NEUTRAL_PASSIVE), UNIT_ID_TAVERN, location, bj_UNIT_FACING)
    SetUnitColor(tavern, PLAYER_COLOR_MAROON)
    SelectUnit(tavern, true)

    local trigger = CreateTrigger()
    TriggerRegisterPlayerUnitEvent(trigger, Player(PLAYER_NEUTRAL_PASSIVE), EVENT_PLAYER_UNIT_SELL, nil)
    TriggerAddAction(trigger, function()
        if GetUnitTypeId(GetSellingUnit()) == UNIT_ID_TAVERN then
            local hero = GetSoldUnit()
            local player = GetOwningPlayer(hero)
            PlayerHero[player] = hero
            RemoveUnit(GetBuyingUnit())
            --SetCameraTargetController(GetSoldUnit(), 0, 0, false)
            SelectUnitForPlayerSingle(hero, player)
            SetUnitPosition(hero, GetRectCenterX(RECT_START), GetRectCenterY(RECT_START))
            PanCameraToTimed(GetUnitX(hero), GetUnitY(hero), 0)
        end
    end)
    RemoveLocation(location)
end))

return PlayerHero

