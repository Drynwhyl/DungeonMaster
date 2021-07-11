---@class ItemTypes
local ItemTypes = compiletime(function()

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

    local function createItem(base, fields)
        local item = currentMap.objects.item[base]:clone()
        for fieldName, fieldValue in pairs(fields) do
            item:setField(fieldName, fieldValue)
        end
        item:setField("stockRegen", 1.0)
        item:setField("abilList", "")
        local rawCode = generateRawCode("#")
        currentMap.objects.item:setObject(rawCode, item)
        return string.unpack(">I4", rawCode)
    end

    local WEAPON_BASE_ID = "ratc" -- Claws of attack ID

    local configWeapons = {
        {
            fields = {
                Art = "ReplaceableTextures/CommandButtons/BTNSteelMelee.blp",
                Name = "",
            },
            data = {
                stats = {
                    ["ATTACK_DAMAGE"] = {
                        type = "BONUS",
                        value = 5,
                    },
                }
            }
        }
    }

    local items = {}

    items.weapons = {}
    -- Create weapons
    for _, config in pairs(configWeapons) do
        local id = createItem(WEAPON_BASE_ID, config.fields)
        table.insert(items.weapons, { id = id, data = config.data })
    end

    return items
end)

return ItemTypes