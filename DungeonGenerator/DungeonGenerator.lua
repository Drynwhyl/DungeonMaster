WM("DungeonGenerator", function(import, export, exportDefault)

    local Utils = import "Utils"
    local CreateAutotable = import "CreateAutotable"
    local ConnectRooms = import "ConnectRooms"
    local CreateWalls = import "CreateWalls"

    local SHAPE_CIRCLE = 0
    local SHAPE_SQUARE = 1

    local RANDOM_VARIATION = -1
    local ROOM_PLACEMENT_ATTEMPS = 10
    local MIN_CORRIDOR_WIDTH = 4
    local ROOM_NUMBER = 10

    local roomTemplateRects = {
        gg_rct_Region_000,
        gg_rct_Region_001,
    }

    local startRoomTemplateRect = gg_rct_StartRoom_001
    local startRoomTemplate
    local startRoom
    local bossRoomTemplateRect = gg_rct_BossRoom_001
    local bossRoomTemplate
    local bossRoom

    local roomTemplates = {}
    local rooms = {}
    local map = gg_rct_Dungeon --GetPlayableMapRect()

    local function parseRoomTemplate(rect)
        local width = GetRectWidthBJ(rect) / bj_CELLWIDTH
        local height = GetRectHeightBJ(rect) / bj_CELLWIDTH
        local minX = GetRectMinX(rect)
        local minY = GetRectMinY(rect)
        local room = { width = width, height = height, cells = CreateAutotable(1) }
        for i = 0, width do
            for j = 0, height do
                room.cells[i][j] = GetTerrainType(minX + i * bj_CELLWIDTH, minY + j * bj_CELLWIDTH);
                if (room.cells[i][j] == TILE_EMPTY) then
                    print("EMPTY!")
                end
                SetTerrainType(minX + i * bj_CELLWIDTH, minY + j * bj_CELLWIDTH, TILE_EMPTY, RANDOM_VARIATION, 1, SHAPE_CIRCLE)
            end
        end
        return room
    end

    local function parseRoomTemplates()
        for _, rect in ipairs(roomTemplateRects) do
            table.insert(roomTemplates, parseRoomTemplate(rect))
        end
        startRoomTemplate = parseRoomTemplate(startRoomTemplateRect)
        bossRoomTemplate = parseRoomTemplate(bossRoomTemplateRect)
    end

    local function allNearestCellsIsEmpty(x, y, size)
        local halfsize = size / 2
        for i = x - halfsize, x + halfsize - 1 do
            for j = y - halfsize, y + halfsize - 1 do
                if (GetTerrainType(i * bj_CELLWIDTH, j * bj_CELLWIDTH) ~= TILE_EMPTY) then
                    return false
                end
            end
        end
        return true
    end

    local function isRoomPlaceable(room, x, y)
        for i = 0, room.width do
            for j = 0, room.height do
                if (not allNearestCellsIsEmpty(x + i, y + j, MIN_CORRIDOR_WIDTH)) then
                    return false
                end
            end
        end
        return true
    end

    local function transpose(matrix, width, height)
        local newMatrix = CreateAutotable(1)
        for i = 0, width do
            for j = 0, height do
                newMatrix[i][j] = matrix[j][i]
            end
        end
        return newMatrix
    end

    local function reverseRows(matrix, width, height)
        local newMatrix = CreateAutotable(1)
        for i = 0, width do
            for j = 0, height do
                newMatrix[i][j] = matrix[i][height - j]
            end
        end
        return newMatrix
    end

    local function reverseCols(matrix, width, height)
        local newMatrix = CreateAutotable(1)
        for i = 0, width do
            for j = 0, height do
                newMatrix[i][j] = matrix[width - i][j]
            end
        end
        return newMatrix
    end

    local function rotateRoomTemplate(roomTemplate, angle)
        if angle == 90 then
            return {
                width = roomTemplate.height,
                height = roomTemplate.width,
                cells = reverseCols(
                        transpose(roomTemplate.cells, roomTemplate.width, roomTemplate.height),
                        roomTemplate.height, roomTemplate.width
                )
            }
        elseif angle == 270 then
            return {
                width = roomTemplate.height,
                height = roomTemplate.width,
                cells = reverseRows(
                        transpose(roomTemplate.cells, roomTemplate.width, roomTemplate.height),
                        roomTemplate.height, roomTemplate.width
                )
            }
        elseif angle == 180 then
            return {
                width = roomTemplate.width,
                height = roomTemplate.height,
                cells = reverseCols(reverseRows(roomTemplate.cells, roomTemplate.width, roomTemplate.height), roomTemplate.width, roomTemplate.height)
            }
        else
            return roomTemplate
        end
    end

    local function placeRoom(room, x, y)
        local placedRoom = { width = room.width, height = room.height, cells = CreateAutotable(1) }
        for i = 0, room.width do
            for j = 0, room.height do
                print("i " .. i .. " j " .. j)
                placedRoom.cells[i][j] = { x = (x + i) * bj_CELLWIDTH, y = (y + j) * bj_CELLWIDTH, tile = room.cells[i][j] }
                SetTerrainType((x + i) * bj_CELLWIDTH, (y + j) * bj_CELLWIDTH, room.cells[i][j], RANDOM_VARIATION, 1, SHAPE_SQUARE)
            end
        end
        return placedRoom
    end

    local function placeRandomRoom(room)
        local mapMinX = GetRectMinX(map) / bj_CELLWIDTH
        local mapMinY = GetRectMinY(map) / bj_CELLWIDTH
        local mapMaxX = GetRectMaxX(map) / bj_CELLWIDTH
        local mapMaxY = GetRectMaxY(map) / bj_CELLWIDTH
        for i = 1, ROOM_PLACEMENT_ATTEMPS do
            print("room wh: ", room.width, room.height)
            local x = GetRandomInt(mapMinX + 1, mapMaxX - room.width - 1)   -- Add 1 extra cell to avoid placing rooms at edges of map
            local y = GetRandomInt(mapMinY + 1, mapMaxY - room.height - 1)
            if (isRoomPlaceable(room, x, y)) then
                return placeRoom(room, x, y)
            end
        end
        print("place room failed ")
        return nil
    end

    local function placeRooms()
        local attempts = 0
        while startRoom == nil do
            startRoom = placeRandomRoom(rotateRoomTemplate(startRoomTemplate, GetRandomInt(0, 3) * 90))
            print("attemps start room", attempts)
            attempts = attempts + 1
        end
        table.insert(rooms, startRoom)
        attempts = 0
        while bossRoom == nil do
            bossRoom = placeRandomRoom(rotateRoomTemplate(bossRoomTemplate, GetRandomInt(0, 3) * 90))
            print("attemps start room", attempts)
            attempts = attempts + 1
        end
        table.insert(rooms, bossRoom)

        for i = 1, ROOM_NUMBER do
            local roomTemplate = roomTemplates[GetRandomInt(1, #roomTemplates)]
            local rotatedTemplate = rotateRoomTemplate(roomTemplate, GetRandomInt(0, 3) * 90)
            local placedRoom = placeRandomRoom(rotatedTemplate)
            if placedRoom ~= nil then
                table.insert(rooms, placedRoom)
                print("placed room number " .. i)
            end
        end

        --if startRoom == nil then
        --    print("Error! cannot place start room!")
        --
        --end
        --if bossRoom == nil then
        --    print("Error! cannot place boss room!")
        --end
    end

    Utils.onGameStart(Utils.pcall(function()
        CameraSetupApplyForceDuration(gg_cam_Camera_001, true, 3.0)
        print("invoke generation")
        parseRoomTemplates()
        print("rooms read")
        placeRooms()
        print("rooms placed")
        local trigger = CreateTrigger()
        TriggerAddAction(trigger, Utils.pcall(function()
            ConnectRooms(rooms, map)
            CreateWalls(map)
        end))
        TriggerExecute(trigger)
    end))

end)