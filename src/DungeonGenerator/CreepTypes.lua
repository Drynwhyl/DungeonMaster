---@class CreepTypes
---@field public tier1 number[]
local CreepTypes = compiletime(function()

    local asciiStartChar = 32
    local asciiEndChar = 126
    local asciiCurrentChar = { asciiStartChar, asciiStartChar, asciiStartChar, asciiStartChar }

    local function generateRawCode(prefix)
        prefix = prefix or " "
        asciiCurrentChar[1] = string.byte(prefix)
        local result = string.char(table.unpack(asciiCurrentChar))
        if asciiCurrentChar[4] == asciiEndChar then
            if asciiCurrentChar[3] == asciiEndChar then
                if asciiCurrentChar[2] == asciiEndChar then
                    print("ERROR: prefix changed due to to many raw codes")
                    asciiCurrentChar[1] = asciiCurrentChar[1] + 1
                    asciiCurrentChar[2] = asciiStartChar
                else
                    asciiCurrentChar[2] = asciiCurrentChar[2] + 1
                end
                asciiCurrentChar[3] = asciiStartChar
            else
                asciiCurrentChar[3] = asciiCurrentChar[3] + 1
            end
            asciiCurrentChar[4] = asciiStartChar
        else
            asciiCurrentChar[4] = asciiCurrentChar[4] + 1
        end
        return result
    end

    local function createCreep(base, config)
        local creep = currentMap.objects.unit[base]:clone()
        for fieldName, fieldValue in pairs(config) do
            creep:setField(fieldName, fieldValue)
        end
        local rawCode = generateRawCode("!")
        currentMap.objects.unit:setObject(rawCode, creep)
        return string.unpack(">I4", rawCode)
    end

    local DALARAN_MUTANT_ID = "ndmu"
    local DEMONOLOGIST_ID = "ners"

    local zombieConfig = {
        -- Art
        ["modelScale"] = 1.15,
        ["shadowX"] = 50,
        ["shadowY"] = 40,
        ["shadowH"] = 100,
        ["shadowW"] = 100,

        -- Combat
        ["def"] = 1,
        ["defType"] = "divine",
        ["HP"] = 10,

        ["dmgplus1"] = 1,
        ["dice1"] = 1,
        ["sides1"] = 3,
        ["cool1"] = 1.0,

        -- Movement
        ["spd"] = 200,
        ["collision"] = 15,

        --Text
        ["Name"] = "Rotting zombie",
    }

    local chaosCultistConfig = {
        -- Art
        ["file"] = "units\\Sorceror\\ChaosCultist.mdx",
        ["scale"] = 1.3, -- Selection circle
        ["modelScale"] = 1.0,
        ["shadowX"] = 65,
        ["shadowY"] = 65,
        ["shadowH"] = 140,
        ["shadowW"] = 140,

        -- Abilities
        ["abilList"] = "ACrd",
        ["auto"] = "ACrd",

        -- Combat
        ["def"] = 1,
        ["defType"] = "divine",
        ["HP"] = 15,

        ["impactZ"] = 80,
        ["launchZ"] = 100,
        ["Missileart"] = "Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl",

        ["Missilespeed"] = 500,
        ["MissileHoming"] = 0,
        ["atkType1"] = "magic",
        ["dmgplus1"] = 1,
        ["dice1"] = 1,
        ["sides1"] = 5,
        ["cool1"] = 1.1,

        -- Movement
        ["spd"] = 200,
        ["collision"] = 20,
        ["turnRate"] = 3,

        --Text
        ["Name"] = "Chaos Cultist",
    }

    local zombie = createCreep(DALARAN_MUTANT_ID, zombieConfig)
    local chaosCultist = createCreep(DEMONOLOGIST_ID, chaosCultistConfig)

    return {
        tier1 = {
            zombie,
        },
        tier2 = {
            chaosCultist,
        }
    }
end)

return CreepTypes