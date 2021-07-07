local Utils = require "Utils"

local CastSystem = {}

CastSystem.ANIMATION_MODE_NORMAL = 1
CastSystem.ANIMATION_MODE_FIT = 2

---@type AbilityData[]
local abilities = {}
local castData = {}

local trigger = CreateTrigger()
TriggerRegisterAnyUnitEventBJ(trigger, EVENT_PLAYER_UNIT_SPELL_CAST)
TriggerRegisterAnyUnitEventBJ(trigger, EVENT_PLAYER_UNIT_SPELL_CHANNEL)
TriggerRegisterAnyUnitEventBJ(trigger, EVENT_PLAYER_UNIT_SPELL_EFFECT)
TriggerRegisterAnyUnitEventBJ(trigger, EVENT_PLAYER_UNIT_SPELL_FINISH)
TriggerRegisterAnyUnitEventBJ(trigger, EVENT_PLAYER_UNIT_SPELL_ENDCAST)
TriggerAddAction(trigger, Utils.pcall(function()
    local abilityId = GetSpellAbilityId()
    local event = GetTriggerEventId()
    local caster = GetSpellAbilityUnit()

    if not abilities[abilityId] then
        return
    end

    if event == EVENT_PLAYER_UNIT_SPELL_CAST then

    elseif event == EVENT_PLAYER_UNIT_SPELL_CHANNEL then

    elseif event == EVENT_PLAYER_UNIT_SPELL_EFFECT then
        local castTime = BlzGetAbilityRealLevelField(GetSpellAbility(), ABILITY_RLF_FOLLOW_THROUGH_TIME, GetUnitAbilityLevel(caster, abilityId) - 1)
        local timeScale = 1.0
        if castTime > 0.001 then
            timeScale = abilities[abilityId].animationTime / castTime
            SetUnitTimeScale(caster, timeScale)
        end
        if type(abilities[abilityId].animation) == string then
            SetUnitAnimation(caster, abilities[abilityId].animation)
        else
            SetUnitAnimationByIndex(caster, abilities[abilityId].animation)
        end
        castData[abilityId][caster] = {
            abilityId = abilityId,
            ability = GetSpellAbility(),
            caster = caster,
            target = GetSpellTargetUnit() or GetSpellTargetItem() or GetSpellTargetDestructable() or { x = GetSpellTargetX(), y = GetSpellTargetY() },
            timer = CreateTimer()
        }
        abilities[abilityId].startHandler(castData[abilityId][caster])
        TimerStart(castData[abilityId][caster].timer, abilities[abilityId].animationDamagePoint / timeScale, false, function()
            Utils.pcall(function() abilities[abilityId].finishHandler(castData[abilityId][caster]) end)()
        end)
    elseif event == EVENT_PLAYER_UNIT_SPELL_FINISH then

    elseif event == EVENT_PLAYER_UNIT_SPELL_ENDCAST then
        DestroyTimer(castData[abilityId][caster].timer)
        SetUnitTimeScale(caster, 1.0)
    end
end))


---@param abilityData AbilityData
function CastSystem.registerAbility(abilityData)
    abilities[abilityData.abilityId] = abilityData
    abilities[abilityData.abilityId].startHandler = abilities[abilityData.abilityId].startHandler or DoNothing
    abilities[abilityData.abilityId].finishHandler = abilities[abilityData.abilityId].finishHandler or DoNothing
    castData[abilityData.abilityId] = {}
end

function CastSystem.castAbility(player, abilityId, order, target)
    local dummy = CreateUnit(player, FourCC("n!!!"), GetWidgetX(target), GetWidgetY(target), 0)
    UnitAddAbility(dummy, abilityId)
    IssueTargetOrderById(dummy, order, target)
    --RemoveUnit(dummy)
end

return CastSystem