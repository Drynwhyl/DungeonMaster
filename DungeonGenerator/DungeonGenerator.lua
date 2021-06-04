WM("DungeonGenerator", function(import, export, exportDefault)

    print("lib loaded")
    local Utils = import "Utils"
    local CreateAutotable = import "CreateAutotable"

    local TILE_EMPTY = TILE_ICECROWN_DIRT
    local TILE_FLOOR = TILE_ICECROWN_RUNE_BRICKS
    local TILE_WALL = TILE_ICECROWN_BLACK_SQUARES
    local TILE_DOOR = TILE_ICECROWN_BLACK_SQUARES

    local SHAPE_SQUARE = 0
    local SHAPE_CIRCLE = 1

    local RANDOM_VARIATION = -1
    local ROOM_PLACEMENT_ATTEMPS = 10
    local MIN_CORIDOR_WIDTH = 5

    local roomTemplateRects = {
        gg_rct_Region_000,
        gg_rct_Region_001,
    }
    
    local rooms = {}
    local map = GetPlayableMapRect()

    local function parseRoomTemplates()
        for _, rect in ipairs(roomTemplateRects) do
            local width = GetRectWidthBJ(rect) / bj_CELLWIDTH
            local height = GetRectHeightBJ(rect) / bj_CELLWIDTH
            local minX = GetRectMinX(rect)
            local minY = GetRectMinY(rect)
            room = { width = width, height = height, cells = CreateAutotable(2) }
            for i = 1, width do
                for j = 1, height do
                    room.cells[i][j] = GetTerrainType(minX + (i - 1) * bj_CELLWIDTH, minY + (j - 1) * bj_CELLWIDTH);
                    SetTerrainType(minX + (i - 1) * bj_CELLWIDTH, minY + (j - 1) * bj_CELLWIDTH, TILE_EMPTY, RANDOM_VARIATION, 1, SHAPE_CIRCLE)
                end
            end
            table.insert(rooms, room)
        end 
    end

    local function allNearestCellsHavePathing(x, y, size, ...)
        local pathings = table.pack(...)
        local pathingSet = {}
        for _, value in pairs(pathings) do
            pathingSet[value] = true
        end
        for i = x - size, x + size - 1 do
            for j = y - size, y + size - 1 do
                if (pathingSet[GetTerrainType((x + i) * bj_CELLWIDTH, (y + j) * bj_CELLWIDTH)] == nil) then
                    return false
                end
            end
        end
        return true
    end

    local function isRoomPlaceable(room, x, y)
        for i = 1, room.width do
            for j = 1, room.height do
                if (not allNearestCellsHavePathing(x + i, y + j, MIN_CORIDOR_WIDTH, TILE_EMPTY)) then
                    return false
                end
            end
        end
        return true
    end

    local function placeRoom(room, x, y)
        for i = 1, room.width do
            for j = 1, room.height do
                SetTerrainType((x + i) * bj_CELLWIDTH, (y + j) * bj_CELLWIDTH, room.cells[i][j], RANDOM_VARIATION,  1, SHAPE_CIRCLE)
            end
        end
    end

    local function placeRandomRoom(room)
        local mapWidth = GetRectWidthBJ(map) / bj_CELLWIDTH
        local mapHeight = GetRectHeightBJ(map) / bj_CELLWIDTH
        for i = 1, ROOM_PLACEMENT_ATTEMPS do
            local x = GetRandomInt(0, mapWidth - room.width)
            local y = GetRandomInt(0, mapWidth - room.height)
            if (isRoomPlaceable(room, x, y)) then
                placeRoom(room, x, y)
                return true
                print("place room sucess, attemps: " .. i)
            end
        end
        print("place room failed ")
        return false
    end

    local function placeRooms()
        local placedRooms = {}
        for i = 1, 4 do
            local room = rooms[GetRandomInt(1, #rooms)]
            local success = placeRandomRoom(room)
            if (success) then
                table.insert(placedRooms, room)
                print("placed room number " .. i)
            end
        end
    end

    print("on game start")
    Utils.onGameStart(function()
        print("on game start running")
        Utils.pcall(function()
            
            CameraSetupApplyForceDuration(gg_cam_Camera_001, true, 3.0)
            print("invoke generation")
            parseRoomTemplates()
            print("rooms read")
            placeRooms()
            print("rooms placed")
        end)()
    end)

end)