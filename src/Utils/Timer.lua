local Timer = {}
Timer.PERIOD = 0.03125

local trigger = CreateTrigger()
TriggerRegisterTimerEventPeriodic(trigger, Timer.PERIOD)

function Timer.register(func)
    return TriggerAddAction(trigger, func)
end

function Timer.unregister(action)
    TriggerRemoveAction(trigger, action)
end

return Timer