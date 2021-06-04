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
    local MIN_CORIDOR_WIDTH = 4
    local ROOM_NUMBER = 5

    local roomTemplateRects = {
        gg_rct_Region_000,
        gg_rct_Region_001,
    }
    
    local rooms = {}
    local map = gg_rct_Dungeon --GetPlayableMapRect()

    local function parseRoomTemplates()
        for _, rect in ipairs(roomTemplateRects) do
            local width = GetRectWidthBJ(rect) / bj_CELLWIDTH
            local height = GetRectHeightBJ(rect) / bj_CELLWIDTH
            local minX = GetRectMinX(rect)
            local minY = GetRectMinY(rect)
            room = { width = width, height = height, cells = CreateAutotable(2) }
            for i = 0, width do
                for j = 0, height do
                    room.cells[i][j] = GetTerrainType(minX + i * bj_CELLWIDTH, minY + j * bj_CELLWIDTH);
                    if (room.cells[i][j] == TILE_EMPTY) then
                        print("EMPTY!")
                    end
                    SetTerrainType(minX + i * bj_CELLWIDTH, minY + j * bj_CELLWIDTH, TILE_EMPTY, RANDOM_VARIATION, 1, SHAPE_CIRCLE)
                end
            end
            table.insert(rooms, room)
        end 
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
                if (not allNearestCellsIsEmpty(x + i, y + j, MIN_CORIDOR_WIDTH)) then
                    return false
                end
            end
        end
        return true
    end

    local function placeRoom(room, x, y)
        for i = 0, room.width do
            for j = 0, room.height do
                SetTerrainType((x + i) * bj_CELLWIDTH, (y + j) * bj_CELLWIDTH, room.cells[i][j], RANDOM_VARIATION,  1, SHAPE_SQUARE)
            end
        end
    end

    local function placeRandomRoom(room)
        local mapWidth = GetRectWidthBJ(map) / bj_CELLWIDTH
        local mapHeight = GetRectHeightBJ(map) / bj_CELLWIDTH
        local mapMinX = GetRectMinX(map) / bj_CELLWIDTH
        local mapMinY = GetRectMinY(map) / bj_CELLWIDTH
        local mapMaxX = GetRectMaxX(map) / bj_CELLWIDTH
        local mapMaxY = GetRectMaxY(map) / bj_CELLWIDTH
        for i = 1, ROOM_PLACEMENT_ATTEMPS do
            local x = GetRandomInt(mapMinX + 1, mapMaxX - room.width - 1)   -- Add 1 extra cell to avoid placing rooms at edges of map
            local y = GetRandomInt(mapMinY + 1, mapMaxY - room.height - 1)
            print(string.format("map: %d %d room: %d %d x: %d y: %d", mapWidth, mapHeight, room.width, room.height, x, y))
            if (isRoomPlaceable(room, x, y)) then
                placeRoom(room, x, y)
                print("place room sucess, attemps: " .. i)
                return true
            end
        end
        print("place room failed ")
        return false
    end

    local function placeRooms()
        local placedRooms = {}
        for i = 1, ROOM_NUMBER do
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
            
            -- for i = GetRectMinX(map), GetRectMaxX(map) do
            --     SetTerrainType(i, GetRectMinY(map), TILE_ICECROWN_SNOW, -1, 1, SHAPE_CIRCLE)
            --     SetTerrainType(i, GetRectMaxY(map), TILE_ICECROWN_SNOW, -1, 1, SHAPE_CIRCLE)
            -- end
            -- for i = GetRectMinY(map), GetRectMaxY(map) do
            --     SetTerrainType(GetRectMinX(map), i, TILE_ICECROWN_SNOW, -1, 1, SHAPE_CIRCLE)
            --     SetTerrainType(GetRectMaxX(map), i, TILE_ICECROWN_SNOW, -1, 1, SHAPE_CIRCLE)
            -- end

            CameraSetupApplyForceDuration(gg_cam_Camera_001, true, 3.0)
            print("invoke generation")
            parseRoomTemplates()
            print("rooms read")
            placeRooms()
            print("rooms placed")
        end)()
    end)

end)