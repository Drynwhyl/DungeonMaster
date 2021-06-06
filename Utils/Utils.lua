WM("Utils", function(import, export, exportDefault)

    local Utils = {}

    function Utils.id2String(id)
        return string.pack(">I4", id)
    end

    function Utils.ehandler(err)
        print("ERROR:", err)
    end

    function Utils.pcall(func)
        return function()
            xpcall(func, Utils.ehandler)
        end
    end

    function Utils.doAfter(duration, callback)
        TimerStart(CreateTimer(), duration, false, function ()
            Utils.pcall(callback)()
            DestroyTimer(GetExpiredTimer())
        end)  
    end

    function Utils.tableLength(table)
        local i = 0
        for _ in pairs(table) do
            i = i + 1
        end
        return i
    end

    function Utils.tableGetRandom(myTable)
        local keys = {}
        for key, _ in pairs(myTable) do
            table.insert(keys, key)
        end
        return myTable[keys[GetRandomInt(1, #keys)]]
    end

    -- On Game Start Function
    do
        local trigger = CreateTrigger()
        local actions = {}
        TriggerRegisterTimerEvent(trigger, 0, false)

        function Utils.onGameStart(func)
            table.insert(actions, TriggerAddAction(trigger, func))
        end

        Utils.doAfter(1, function()
            for _, action in pairs(actions) do
                TriggerRemoveAction(trigger, action)
            end
            DestroyTrigger(trigger)
        end)
    end

    function Utils.enumUnits(func, ...)
        local group = CreateGroup()
        local list = {}
        func(group, ...)
        while true do
            local u = FirstOfGroup(group)
            if u == nil then break end
            table.insert(list, u)
            GroupRemoveUnit(group, u)
        end
        return list
    end

    

    exportDefault(Utils)
end)
