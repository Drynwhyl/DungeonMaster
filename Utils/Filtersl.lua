WM("Filters", function(import, export, exportDefault)

    local Filters = {}

    Filters.isHero = Filter(function()
        return IsUnitType(GetFilterUnit(), UNIT_TYPE_HERO)
    end)

    exportDefault(Filters)
end)
