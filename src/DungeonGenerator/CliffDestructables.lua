local CliffDestructables = compiletime(function()

    local cityCliffFilenames = {
        "doodads\\terrain\\citycliffs\\citycliffsaaab0",
        "doodads\\terrain\\citycliffs\\citycliffsaaab1",
        "doodads\\terrain\\citycliffs\\citycliffsaaab2",
        "doodads\\terrain\\citycliffs\\citycliffsaaac0",
        "doodads\\terrain\\citycliffs\\citycliffsaaac1",
        "doodads\\terrain\\citycliffs\\citycliffsaaba0",
        "doodads\\terrain\\citycliffs\\citycliffsaaba1",
        "doodads\\terrain\\citycliffs\\citycliffsaabb0",
        "doodads\\terrain\\citycliffs\\citycliffsaabb1",
        "doodads\\terrain\\citycliffs\\citycliffsaabb2",
        "doodads\\terrain\\citycliffs\\citycliffsaabb3",
        "doodads\\terrain\\citycliffs\\citycliffsaabc0",
        "doodads\\terrain\\citycliffs\\citycliffsaaca0",
        "doodads\\terrain\\citycliffs\\citycliffsaaca1",
        "doodads\\terrain\\citycliffs\\citycliffsaacb0",
        "doodads\\terrain\\citycliffs\\citycliffsaacc0",
        "doodads\\terrain\\citycliffs\\citycliffsaacc1",
        "doodads\\terrain\\citycliffs\\citycliffsaacc2",
        "doodads\\terrain\\citycliffs\\citycliffsaacc3",
        "doodads\\terrain\\citycliffs\\citycliffsabaa0",
        "doodads\\terrain\\citycliffs\\citycliffsabaa1",
        "doodads\\terrain\\citycliffs\\citycliffsabab0",
        "doodads\\terrain\\citycliffs\\citycliffsabab1",
        "doodads\\terrain\\citycliffs\\citycliffsabab2",
        "doodads\\terrain\\citycliffs\\citycliffsabac0",
        "doodads\\terrain\\citycliffs\\citycliffsabba0",
        "doodads\\terrain\\citycliffs\\citycliffsabba1",
        "doodads\\terrain\\citycliffs\\citycliffsabba2",
        "doodads\\terrain\\citycliffs\\citycliffsabba3",
        "doodads\\terrain\\citycliffs\\citycliffsabbb0",
        "doodads\\terrain\\citycliffs\\citycliffsabbc0",
        "doodads\\terrain\\citycliffs\\citycliffsabca0",
        "doodads\\terrain\\citycliffs\\citycliffsabcb0",
        "doodads\\terrain\\citycliffs\\citycliffsabcc0",
        "doodads\\terrain\\citycliffs\\citycliffsacaa0",
        "doodads\\terrain\\citycliffs\\citycliffsacaa1",
        "doodads\\terrain\\citycliffs\\citycliffsacab0",
        "doodads\\terrain\\citycliffs\\citycliffsacac0",
        "doodads\\terrain\\citycliffs\\citycliffsacac1",
        "doodads\\terrain\\citycliffs\\citycliffsacac2",
        "doodads\\terrain\\citycliffs\\citycliffsacba0",
        "doodads\\terrain\\citycliffs\\citycliffsacbb0",
        "doodads\\terrain\\citycliffs\\citycliffsacbc0",
        "doodads\\terrain\\citycliffs\\citycliffsacca0",
        "doodads\\terrain\\citycliffs\\citycliffsacca1",
        "doodads\\terrain\\citycliffs\\citycliffsacca2",
        "doodads\\terrain\\citycliffs\\citycliffsacca3",
        "doodads\\terrain\\citycliffs\\citycliffsaccb0",
        "doodads\\terrain\\citycliffs\\citycliffsaccc0",
        "doodads\\terrain\\citycliffs\\citycliffsaccc1",
        "doodads\\terrain\\citycliffs\\citycliffsbaaa0",
        "doodads\\terrain\\citycliffs\\citycliffsbaaa1",
        "doodads\\terrain\\citycliffs\\citycliffsbaab0",
        "doodads\\terrain\\citycliffs\\citycliffsbaab1",
        "doodads\\terrain\\citycliffs\\citycliffsbaab2",
        "doodads\\terrain\\citycliffs\\citycliffsbaab3",
        "doodads\\terrain\\citycliffs\\citycliffsbaac0",
        "doodads\\terrain\\citycliffs\\citycliffsbaba0",
        "doodads\\terrain\\citycliffs\\citycliffsbaba1",
        "doodads\\terrain\\citycliffs\\citycliffsbaba2",
        "doodads\\terrain\\citycliffs\\citycliffsbabb0",
        "doodads\\terrain\\citycliffs\\citycliffsbabc0",
        "doodads\\terrain\\citycliffs\\citycliffsbaca0",
        "doodads\\terrain\\citycliffs\\citycliffsbacb0",
        "doodads\\terrain\\citycliffs\\citycliffsbacc0",
        "doodads\\terrain\\citycliffs\\citycliffsbbaa0",
        "doodads\\terrain\\citycliffs\\citycliffsbbaa1",
        "doodads\\terrain\\citycliffs\\citycliffsbbaa2",
        "doodads\\terrain\\citycliffs\\citycliffsbbaa3",
        "doodads\\terrain\\citycliffs\\citycliffsbbab0",
        "doodads\\terrain\\citycliffs\\citycliffsbbab1",
        "doodads\\terrain\\citycliffs\\citycliffsbbac0",
        "doodads\\terrain\\citycliffs\\citycliffsbbba0",
        "doodads\\terrain\\citycliffs\\citycliffsbbba1",
        "doodads\\terrain\\citycliffs\\citycliffsbbca0",
        "doodads\\terrain\\citycliffs\\citycliffsbcaa0",
        "doodads\\terrain\\citycliffs\\citycliffsbcab0",
        "doodads\\terrain\\citycliffs\\citycliffsbcac0",
        "doodads\\terrain\\citycliffs\\citycliffsbcba0",
        "doodads\\terrain\\citycliffs\\citycliffsbcca0",
        "doodads\\terrain\\citycliffs\\citycliffscaaa0",
        "doodads\\terrain\\citycliffs\\citycliffscaaa1",
        "doodads\\terrain\\citycliffs\\citycliffscaab0",
        "doodads\\terrain\\citycliffs\\citycliffscaac0",
        "doodads\\terrain\\citycliffs\\citycliffscaac1",
        "doodads\\terrain\\citycliffs\\citycliffscaac2",
        "doodads\\terrain\\citycliffs\\citycliffscaac3",
        "doodads\\terrain\\citycliffs\\citycliffscaba0",
        "doodads\\terrain\\citycliffs\\citycliffscabb0",
        "doodads\\terrain\\citycliffs\\citycliffscabc0",
        "doodads\\terrain\\citycliffs\\citycliffscaca0",
        "doodads\\terrain\\citycliffs\\citycliffscaca1",
        "doodads\\terrain\\citycliffs\\citycliffscaca2",
        "doodads\\terrain\\citycliffs\\citycliffscacb0",
        "doodads\\terrain\\citycliffs\\citycliffscacc0",
        "doodads\\terrain\\citycliffs\\citycliffscacc1",
        "doodads\\terrain\\citycliffs\\citycliffscbaa0",
        "doodads\\terrain\\citycliffs\\citycliffscbab0",
        "doodads\\terrain\\citycliffs\\citycliffscbac0",
        "doodads\\terrain\\citycliffs\\citycliffscbba0",
        "doodads\\terrain\\citycliffs\\citycliffscbca0",
        "doodads\\terrain\\citycliffs\\citycliffsccaa0",
        "doodads\\terrain\\citycliffs\\citycliffsccaa1",
        "doodads\\terrain\\citycliffs\\citycliffsccaa2",
        "doodads\\terrain\\citycliffs\\citycliffsccaa3",
        "doodads\\terrain\\citycliffs\\citycliffsccab0",
        "doodads\\terrain\\citycliffs\\citycliffsccac0",
        "doodads\\terrain\\citycliffs\\citycliffsccac1",
        "doodads\\terrain\\citycliffs\\citycliffsccba0",
        "doodads\\terrain\\citycliffs\\citycliffsccca0",
        "doodads\\terrain\\citycliffs\\citycliffsccca1",
    }
    local regularCliffFilenames = {
        "doodads\\terrain\\cliffs\\cliffsaaab0",
        "doodads\\terrain\\cliffs\\cliffsaaab1",
        "doodads\\terrain\\cliffs\\cliffsaaab2",
        "doodads\\terrain\\cliffs\\cliffsaaac0",
        "doodads\\terrain\\cliffs\\cliffsaaac1",
        "doodads\\terrain\\cliffs\\cliffsaaba0",
        "doodads\\terrain\\cliffs\\cliffsaaba1",
        "doodads\\terrain\\cliffs\\cliffsaabb0",
        "doodads\\terrain\\cliffs\\cliffsaabb1",
        "doodads\\terrain\\cliffs\\cliffsaabb2",
        "doodads\\terrain\\cliffs\\cliffsaabb3",
        "doodads\\terrain\\cliffs\\cliffsaabc0",
        "doodads\\terrain\\cliffs\\cliffsaaca0",
        "doodads\\terrain\\cliffs\\cliffsaaca1",
        "doodads\\terrain\\cliffs\\cliffsaacb0",
        "doodads\\terrain\\cliffs\\cliffsaacc0",
        "doodads\\terrain\\cliffs\\cliffsaacc1",
        "doodads\\terrain\\cliffs\\cliffsaacc2",
        "doodads\\terrain\\cliffs\\cliffsaacc3",
        "doodads\\terrain\\cliffs\\cliffsabaa0",
        "doodads\\terrain\\cliffs\\cliffsabaa1",
        "doodads\\terrain\\cliffs\\cliffsabab0",
        "doodads\\terrain\\cliffs\\cliffsabab1",
        "doodads\\terrain\\cliffs\\cliffsabab2",
        "doodads\\terrain\\cliffs\\cliffsabac0",
        "doodads\\terrain\\cliffs\\cliffsabba0",
        "doodads\\terrain\\cliffs\\cliffsabba1",
        "doodads\\terrain\\cliffs\\cliffsabba2",
        "doodads\\terrain\\cliffs\\cliffsabba3",
        "doodads\\terrain\\cliffs\\cliffsabbb0",
        "doodads\\terrain\\cliffs\\cliffsabbc0",
        "doodads\\terrain\\cliffs\\cliffsabca0",
        "doodads\\terrain\\cliffs\\cliffsabcb0",
        "doodads\\terrain\\cliffs\\cliffsabcc0",
        "doodads\\terrain\\cliffs\\cliffsacaa0",
        "doodads\\terrain\\cliffs\\cliffsacaa1",
        "doodads\\terrain\\cliffs\\cliffsacab0",
        "doodads\\terrain\\cliffs\\cliffsacac0",
        "doodads\\terrain\\cliffs\\cliffsacac1",
        "doodads\\terrain\\cliffs\\cliffsacac2",
        "doodads\\terrain\\cliffs\\cliffsacba0",
        "doodads\\terrain\\cliffs\\cliffsacbb0",
        "doodads\\terrain\\cliffs\\cliffsacbc0",
        "doodads\\terrain\\cliffs\\cliffsacca0",
        "doodads\\terrain\\cliffs\\cliffsacca1",
        "doodads\\terrain\\cliffs\\cliffsacca2",
        "doodads\\terrain\\cliffs\\cliffsacca3",
        "doodads\\terrain\\cliffs\\cliffsaccb0",
        "doodads\\terrain\\cliffs\\cliffsaccc0",
        "doodads\\terrain\\cliffs\\cliffsaccc1",
        "doodads\\terrain\\cliffs\\cliffsbaaa0",
        "doodads\\terrain\\cliffs\\cliffsbaaa1",
        "doodads\\terrain\\cliffs\\cliffsbaab0",
        "doodads\\terrain\\cliffs\\cliffsbaab1",
        "doodads\\terrain\\cliffs\\cliffsbaab2",
        "doodads\\terrain\\cliffs\\cliffsbaab3",
        "doodads\\terrain\\cliffs\\cliffsbaac0",
        "doodads\\terrain\\cliffs\\cliffsbaba0",
        "doodads\\terrain\\cliffs\\cliffsbaba1",
        "doodads\\terrain\\cliffs\\cliffsbaba2",
        "doodads\\terrain\\cliffs\\cliffsbabb0",
        "doodads\\terrain\\cliffs\\cliffsbabc0",
        "doodads\\terrain\\cliffs\\cliffsbaca0",
        "doodads\\terrain\\cliffs\\cliffsbacb0",
        "doodads\\terrain\\cliffs\\cliffsbacc0",
        "doodads\\terrain\\cliffs\\cliffsbbaa0",
        "doodads\\terrain\\cliffs\\cliffsbbaa1",
        "doodads\\terrain\\cliffs\\cliffsbbaa2",
        "doodads\\terrain\\cliffs\\cliffsbbaa3",
        "doodads\\terrain\\cliffs\\cliffsbbab0",
        "doodads\\terrain\\cliffs\\cliffsbbab1",
        "doodads\\terrain\\cliffs\\cliffsbbac0",
        "doodads\\terrain\\cliffs\\cliffsbbba0",
        "doodads\\terrain\\cliffs\\cliffsbbba1",
        "doodads\\terrain\\cliffs\\cliffsbbca0",
        "doodads\\terrain\\cliffs\\cliffsbcaa0",
        "doodads\\terrain\\cliffs\\cliffsbcab0",
        "doodads\\terrain\\cliffs\\cliffsbcac0",
        "doodads\\terrain\\cliffs\\cliffsbcba0",
        "doodads\\terrain\\cliffs\\cliffsbcca0",
        "doodads\\terrain\\cliffs\\cliffscaaa0",
        "doodads\\terrain\\cliffs\\cliffscaaa1",
        "doodads\\terrain\\cliffs\\cliffscaab0",
        "doodads\\terrain\\cliffs\\cliffscaac0",
        "doodads\\terrain\\cliffs\\cliffscaac1",
        "doodads\\terrain\\cliffs\\cliffscaac2",
        "doodads\\terrain\\cliffs\\cliffscaac3",
        "doodads\\terrain\\cliffs\\cliffscaba0",
        "doodads\\terrain\\cliffs\\cliffscabb0",
        "doodads\\terrain\\cliffs\\cliffscabc0",
        "doodads\\terrain\\cliffs\\cliffscaca0",
        "doodads\\terrain\\cliffs\\cliffscaca1",
        "doodads\\terrain\\cliffs\\cliffscaca2",
        "doodads\\terrain\\cliffs\\cliffscacb0",
        "doodads\\terrain\\cliffs\\cliffscacc0",
        "doodads\\terrain\\cliffs\\cliffscacc1",
        "doodads\\terrain\\cliffs\\cliffscbaa0",
        "doodads\\terrain\\cliffs\\cliffscbab0",
        "doodads\\terrain\\cliffs\\cliffscbac0",
        "doodads\\terrain\\cliffs\\cliffscbba0",
        "doodads\\terrain\\cliffs\\cliffscbca0",
        "doodads\\terrain\\cliffs\\cliffsccaa0",
        "doodads\\terrain\\cliffs\\cliffsccaa1",
        "doodads\\terrain\\cliffs\\cliffsccaa2",
        "doodads\\terrain\\cliffs\\cliffsccaa3",
        "doodads\\terrain\\cliffs\\cliffsccab0",
        "doodads\\terrain\\cliffs\\cliffsccac0",
        "doodads\\terrain\\cliffs\\cliffsccac1",
        "doodads\\terrain\\cliffs\\cliffsccba0",
        "doodads\\terrain\\cliffs\\cliffsccca0",
        "doodads\\terrain\\cliffs\\cliffsccca1",
    }
    local tile4x4Filenames = {
        "war3mapImported\\tiles4x4\\tilecaaa0",
        "war3mapImported\\tiles4x4\\tilecaac0",
        "war3mapImported\\tiles4x4\\tilecaca0",
        "war3mapImported\\tiles4x4\\tilecacc0",
        "war3mapImported\\tiles4x4\\tileccaa0",
        "war3mapImported\\tiles4x4\\tileccac0",
        "war3mapImported\\tiles4x4\\tileccca0",
        "war3mapImported\\tiles4x4\\tilecccc0",
        "war3mapImported\\tiles4x4\\tilecccc1",
        "war3mapImported\\tiles4x4\\tileaaac0",
        "war3mapImported\\tiles4x4\\tileaaca0",
        "war3mapImported\\tiles4x4\\tileaacc0",
        "war3mapImported\\tiles4x4\\tileacaa0",
        "war3mapImported\\tiles4x4\\tileacac0",
        "war3mapImported\\tiles4x4\\tileacca0",
        "war3mapImported\\tiles4x4\\tileaccc0",
    }
    local tile4x8Filenames = {
        "war3mapImported\\tiles4x8\\tileacca0",
        "war3mapImported\\tiles4x8\\tileaccc0",
        "war3mapImported\\tiles4x8\\tilecaaa0",
        "war3mapImported\\tiles4x8\\tilecaac0",
        "war3mapImported\\tiles4x8\\tilecaca0",
        "war3mapImported\\tiles4x8\\tilecacc0",
        "war3mapImported\\tiles4x8\\tileccaa0",
        "war3mapImported\\tiles4x8\\tileccac0",
        "war3mapImported\\tiles4x8\\tileccca0",
        "war3mapImported\\tiles4x8\\tileaaac0",
        "war3mapImported\\tiles4x8\\tileaaca0",
        "war3mapImported\\tiles4x8\\tileaacc0",
        "war3mapImported\\tiles4x8\\tileacaa0",
        "war3mapImported\\tiles4x8\\tileacac0",
        "war3mapImported\\tiles4x8\\tilecccc0",
        "war3mapImported\\tiles4x8\\tilecccc1",
        "war3mapImported\\tiles4x8\\tilecccc2",
        "war3mapImported\\tiles4x8\\tilecccc3",
        "war3mapImported\\tiles4x8\\tilecccc4",
        "war3mapImported\\tiles4x8\\tilecccc5",
        "war3mapImported\\tiles4x8\\tilecccc6",
        "war3mapImported\\tiles4x8\\tilecccc7",
        "war3mapImported\\tiles4x8\\tilecccc8",
        "war3mapImported\\tiles4x8\\tilecccc9",
        "war3mapImported\\tiles4x8\\tilecccc10",
        "war3mapImported\\tiles4x8\\tilecccc11",
        "war3mapImported\\tiles4x8\\tilecccc12",
        "war3mapImported\\tiles4x8\\tilecccc13",
        "war3mapImported\\tiles4x8\\tilecccc14",
        "war3mapImported\\tiles4x8\\tilecccc15",
        "war3mapImported\\tiles4x8\\tilecccc16",
        "war3mapImported\\tiles4x8\\tilecccc17",
    }

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

    local function createCliffDestructable(namePrefix, filePrefix, texture, cliffFilenames)
        local cliffTemplates = {}
        for _, cliffFilename in ipairs(cliffFilenames) do
            local cliffFilenameNoSuffix = string.match(cliffFilename, "(.+" .. filePrefix .. "[abc]+)%d+")
            if not cliffTemplates[cliffFilenameNoSuffix] then
                cliffTemplates[cliffFilenameNoSuffix] = {fileName = cliffFilenameNoSuffix, variations = 1}
            else
                cliffTemplates[cliffFilenameNoSuffix].variations = cliffTemplates[cliffFilenameNoSuffix].variations + 1
            end
        end
        local cliffIDs = {}
        for key in pairs(cliffTemplates) do
            local template = cliffTemplates[key]
            local customDestructable = currentMap.objects.destructable["CTtr"]:clone()
            customDestructable:setField("fixedRot", -1)
            customDestructable:setField("fogVis", 1)
            customDestructable:setField("file", tostring(template.fileName) .. tostring(template.variations == 1 and "0.mdx" or ""))
            customDestructable:setField("lightweight", 0)
            customDestructable:setField("numVar", template.variations)
            customDestructable:setField("texFile", texture)
            customDestructable:setField("texID", 11)
            customDestructable:setField("cliffHeight", 2)
            customDestructable:setField("pathTex", "_")
            customDestructable:setField("shadow", "_")
            local cliffKey = string.match(template.fileName, ".+" .. filePrefix .. "([a,b,c]+)")
            print(cliffKey)
            customDestructable:setField("Name", tostring(namePrefix)  .. " " .. tostring(cliffKey))
            local rawCode = generateRawCode(" ")
            currentMap.objects.destructable:setObject(rawCode, customDestructable)
            cliffIDs[cliffKey] = { id = string.unpack(">I4", rawCode), name = cliffKey, variations = template.variations }
        end
        return cliffIDs
    end

    local cityCliffs = createCliffDestructable("City Cliff", "cliffs", "replaceabletextures\\cliff\\cliff0.blp", cityCliffFilenames)
    local regularCliffs = createCliffDestructable("Regular Cliff", "cliffs", "replaceabletextures\\cliff\\cliff1.blp", regularCliffFilenames)
    local tileIcecrownTiledBricks = createCliffDestructable("Tiles 4x4", "tile", "TerrainArt\\IceCrown\\Ice_TiledBricks.blp", tile4x4Filenames)
    local tileIcecrownRuneBricks = createCliffDestructable("Tiles 4x8", "tile", "TerrainArt\\Icecrown\\Ice_RuneBricks.blp", tile4x8Filenames)

    return {
        cityCliffs = cityCliffs,
        regularCliffs = regularCliffs,
        tileIcecrownTiledBricks = tileIcecrownTiledBricks,
        tileIcecrownRuneBricks = tileIcecrownRuneBricks
    }
end)

return CliffDestructables