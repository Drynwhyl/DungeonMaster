WM("DungeonGenerator", function(import, export, exportDefault)

    local Utils = import "Utils"
    local CreateAutotable = import "CreateAutotable"
    local ConnectRooms = import "ConnectRooms"
    local CreateWalls = import "CreateWalls"
    local CreateCreeps = import "CreateCreeps"

    local SHAPE_CIRCLE = 0
    local SHAPE_SQUARE = 1

    local RANDOM_VARIATION = -1
    local ROOM_PLACEMENT_ATTEMPTS = 200
    local MIN_CORRIDOR_WIDTH = 5
    local ROOM_NUMBER = 100

    local roomTemplateRects = {
        gg_rct_Region_000,
        gg_rct_Region_001,
        gg_rct_Room000,
        gg_rct_Room001,
        gg_rct_Room002,
        gg_rct_Room003,
        gg_rct_Room004,
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
        print("wh", width, height)
        for i = 0, width do
            for j = 0, height do
                room.cells[i][j] = GetTerrainType(minX + i * bj_CELLWIDTH, minY + j * bj_CELLWIDTH);
                --if (room.cells[i][j] == TILE_EMPTY) then
                --    print("EMPTY!")
                --end
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

    local function allNearestCellsAreEmpty(x, y, size)
        local halfsize = size / 2
        for i = x - size, x + size do
            for j = y - size, y + size do
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
                if (not allNearestCellsAreEmpty(x + i, y + j, MIN_CORRIDOR_WIDTH)) then
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
                newMatrix[j][i] = matrix[i][j]
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
                cells = reverseCols(
                        reverseRows(roomTemplate.cells, roomTemplate.width, roomTemplate.height),
                        roomTemplate.width, roomTemplate.height
                )
            }
        else
            return roomTemplate
        end
    end

    local function placeRoom(room, x, y)
        local placedRoom = { width = room.width, height = room.height, cells = CreateAutotable(1) }
        for i = 0, room.width do
            for j = 0, room.height do
                --print("i " .. i .. " j " .. j)
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
        for _ = 1, ROOM_PLACEMENT_ATTEMPTS do
            --print("room wh: ", room.width, room.height)
            local x = GetRandomInt(mapMinX + MIN_CORRIDOR_WIDTH, mapMaxX - room.width - MIN_CORRIDOR_WIDTH)   -- Add 1 extra cell to avoid placing rooms at edges of map
            local y = GetRandomInt(mapMinY + MIN_CORRIDOR_WIDTH, mapMaxY - room.height - MIN_CORRIDOR_WIDTH)
            if (isRoomPlaceable(room, x, y)) then
                return placeRoom(room, x, y)
            end
        end
        --print("place room failed ")
        return nil
    end

    local farthestRoomFromStart
    local function placeRooms()
        local attempts = 0
        while startRoom == nil do
            local randomAngle = GetRandomInt(0, 3) * 90;
            print("start random angle", randomAngle)
            startRoom = placeRandomRoom(rotateRoomTemplate(startRoomTemplate, randomAngle))
            print("attemps start room", attempts)
            attempts = attempts + 1
        end
        --table.insert(rooms, startRoom)
        attempts = 0
        while bossRoom == nil do
            local randomAngle = GetRandomInt(0, 3) * 90;
            print("boss random angle", randomAngle)
            bossRoom = placeRandomRoom(rotateRoomTemplate(bossRoomTemplate, randomAngle))
            print("attemps start room", attempts)
            attempts = attempts + 1
        end
        local roomLoc = Location(0, 0)
        local startRoomCenter = startRoom.cells[startRoom.width // 2][startRoom.height // 2]
        local startRoomLoc = Location(startRoomCenter.x, startRoomCenter.y)
        local startRoomDistance = 0
        --table.insert(rooms, bossRoom)

        for i = 1, 9999 do --ROOM_NUMBER do
            local roomTemplate = roomTemplates[GetRandomInt(1, #roomTemplates)]
            local randomAngle = GetRandomInt(0, 3) * 90;
            print("random angle", randomAngle)
            local rotatedTemplate = rotateRoomTemplate(roomTemplate, randomAngle)
            local placedRoom = placeRandomRoom(rotatedTemplate)
            if placedRoom then
                local center = placedRoom.cells[placedRoom.width // 2][placedRoom.height // 2]
                MoveLocation(roomLoc, center.x, center.y)
                local dist = DistanceBetweenPoints(roomLoc, startRoomLoc)
                if dist > startRoomDistance then
                    startRoomDistance = dist
                    farthestRoomFromStart = placedRoom
                end
                table.insert(rooms, placedRoom)
                print("placed room number " .. i)
            else
                break
            end
        end

        RemoveLocation(roomLoc)
        RemoveLocation(startRoomLoc)

        -- Generate boss room gate and gate opening button
    end

    Utils.onGameStart(Utils.pcall(function()
        if true then
            return
        end
        CameraSetupApplyForceDuration(gg_cam_Camera_001, true, 3.0)
        print("invoke generation")
        parseRoomTemplates()
        print("rooms read")
        placeRooms()
        print("rooms placed")
        local trigger = CreateTrigger()
        TriggerAddAction(trigger, Utils.pcall(function()
            ConnectRooms(map, rooms, startRoom, bossRoom, farthestRoomFromStart)
            CreateWalls(map)
        end))
        TriggerExecute(trigger)
    end))

    local function CreateDungeon(seed)
        SetRandomSeed(seed)
        --print("invoke generation")
        parseRoomTemplates()
        --print("rooms read")
        placeRooms()
        --print("rooms placed")
        ConnectRooms(map, rooms, startRoom, bossRoom, farthestRoomFromStart)
        CreateWalls(map)

        CreateCreeps(map, rooms, farthestRoomFromStart, bossRoom)

        return { start = startRoom.cells[startRoom.width // 2][startRoom.height // 2] }
    end

    exportDefault(CreateDungeon)
end)