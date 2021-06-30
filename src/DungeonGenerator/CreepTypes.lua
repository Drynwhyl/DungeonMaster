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

    local zombieConfig = {
        ["spd"] = 200,
        ["HP"] = 10,
        ["dmgplus1"] = 4,
        ["dice1"] = 1,
        ["sides1"] = 6,
        ["Name"] = "Rotting zombie",
    }

    local zombie = createCreep("ndmu", zombieConfig)

    return {
        tier1 = {
            zombie,
        }
    }
end)

return CreepTypes