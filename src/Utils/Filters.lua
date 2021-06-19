local Filters = {}

Filters.isHero = Filter(function()
    return IsUnitType(GetFilterUnit(), UNIT_TYPE_HERO)
end)

Filters.isPlayerHero = Filter(function()
    return IsUnitType(GetFilterUnit(), UNIT_TYPE_HERO) and GetPlayerController(GetOwningPlayer(GetFilterUnit())) == MAP_CONTROL_USER
end)

return Filters
