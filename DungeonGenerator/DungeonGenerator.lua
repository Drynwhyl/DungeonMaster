WM("DungeonGenerator", function(import, export, exportDefault)

    print("lib loaded")
    local Utils = import "Utils"
    local CreateAutotable = import "CreateAutotable"
    local FindPath = import "FindPath"

    local TILE_EMPTY = TILE_ICECROWN_DIRT
    local TILE_FLOOR = TILE_ICECROWN_RUNE_BRICKS
    local TILE_WALL = TILE_ICECROWN_BLACK_SQUARES
    local TILE_DOOR = TILE_ICECROWN_TILED_BRICKS
    
    local SHAPE_CIRCLE = 0
    local SHAPE_SQUARE = 1

    local RANDOM_VARIATION = -1
    local ROOM_PLACEMENT_ATTEMPS = 10
    local MIN_CORIDOR_WIDTH = 4
    local ROOM_NUMBER = 5

    local roomTemplateRects = {
        gg_rct_Region_000,
        gg_rct_Region_001,
    }
    
    local roomTemplates = {}
    local rooms = {}
    local map = gg_rct_Dungeon --GetPlayableMapRect()

    local function parseRoomTemplates()
        for _, rect in ipairs(roomTemplateRects) do
            local width = GetRectWidthBJ(rect) / bj_CELLWIDTH
            local height = GetRectHeightBJ(rect) / bj_CELLWIDTH
            local minX = GetRectMinX(rect)
            local minY = GetRectMinY(rect)
            room = { width = width, height = height, cells = CreateAutotable() }
            for i = 0, width do
                for j = 0, height do
                    room.cells[i][j] = GetTerrainType(minX + i * bj_CELLWIDTH, minY + j * bj_CELLWIDTH);
                    if (room.cells[i][j] == TILE_EMPTY) then
                        print("EMPTY!")
                    end
                    SetTerrainType(minX + i * bj_CELLWIDTH, minY + j * bj_CELLWIDTH, TILE_EMPTY, RANDOM_VARIATION, 1, SHAPE_CIRCLE)
                end
            end
            table.insert(roomTemplates, room)
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
        local placedRoom = { width = room.width, height = room.height, cells = CreateAutotable() }
        for i = 0, room.width do
            for j = 0, room.height do
                print("i " .. i .. " j " .. j)
                placedRoom.cells[i][j] = { x = (x + i) * bj_CELLWIDTH, y = (y + j) * bj_CELLWIDTH, tile = room.cells[i][j] }
                SetTerrainType((x + i) * bj_CELLWIDTH, (y + j) * bj_CELLWIDTH, room.cells[i][j], RANDOM_VARIATION,  1, SHAPE_SQUARE)
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
        for i = 1, ROOM_NUMBER do
            local roomTemplate = roomTemplates[GetRandomInt(1, #roomTemplates)]
            local placedRoom = placeRandomRoom(roomTemplate)
            if placedRoom ~= nil then
                table.insert(rooms, placedRoom)
                print("placed room number " .. i)
            end
        end
    end

local roomCount = 0

    local function getDoorCells(room, x, y)
        local cells = {}
        table.insert(cells, { x = room.cells[x][y].x, y = room.cells[x][y].y })

        local dirX = 0
        local dirY = 0
        local horizontal

        if x + 1 <= room.width and GetTerrainType(room.cells[x + 1][y].x, room.cells[x + 1][y].y) == TILE_DOOR then
            dirX = 1
            horizontal = true
        elseif x - 1 >= 0 and GetTerrainType(room.cells[x - 1][y].x, room.cells[x - 1][y].y) == TILE_DOOR then
            dirX = -1
            horizontal = true
        elseif y + 1 <= room.height and GetTerrainType(room.cells[x][y + 1].x, room.cells[x][y + 1].y) == TILE_DOOR then
            dirY = 1
            horizontal = false
        elseif y - 1 >= 0 and GetTerrainType(room.cells[x][y - 1].x, room.cells[x][y - 1].y) == TILE_DOOR then
            dirY = -1
            horizontal = false
        else
            print("ERROR single cell room!!!")
            CreateDestructable(FourCC("LTcr"), room.cells[x][y].x, room.cells[x][y].y, 0, 1, -1)
            dirX = 1
            horizontal = false
        end

        local i = x
        local j = y
        repeat
            i = i + dirX
            j = j + dirY
            if i > room.width or i < 0 or j > room.height or j < 0 or  GetTerrainType(room.cells[i][j].x, room.cells[i][j].y) ~= TILE_DOOR then
                break
            end
            if dirX < 0 or dirY > 0 then
                table.insert(cells, 1, { x = room.cells[i][j].x, y = room.cells[i][j].y })
            else
                table.insert(cells, {  x = room.cells[i][j].x, y = room.cells[i][j].y })
            end
        until false

        print("cell # in door " .. #cells)

        local doorCellsArray = CreateAutotable()
        if horizontal then
            for index, cell in ipairs(cells) do
                doorCellsArray[index - 1][0] = cell
            end
        else
            for index, cell in ipairs(cells) do
                doorCellsArray[0][index - 1] = cell
            end
        end

        
        roomCount = roomCount + 1

        return { horizontal = horizontal, cells = doorCellsArray, width = horizontal and #cells or 1, height = horizontal and 1 or #cells }
    end

    local function tableLength(table)
        local i = 0
        for _ in pairs(table) do
            i = i + 1
        end
        return i
    end

    local function printTableElements(myTable)
        for key, value in pairs(myTable) do
            print(key, value)
        end
    end

    local function tableContains(myTable, x, y)
        for key, value in pairs(myTable) do
            if (value.x == x and value.y == y) then
                return true
            end
        end
    end

    local function getRoomDoors(room)
        local visited = CreateAutotable(1)
        local doors = {}
        for i = 0, room.width do
            for j = 0, room.height do
                --print("i " .. i .. " j " .. j .. " cells " .. room[i][j])
                if GetTerrainType(room.cells[i][j].x, room.cells[i][j].y) == TILE_DOOR and visited[room.cells[i][j].x][room.cells[i][j].y] ~= true then
                    print("start coords", room.cells[i][j].x, room.cells[i][j].y)
                    local door = getDoorCells(room, i, j)
                    table.insert(doors, door)
                    for k = 0, tableLength(door.cells) - 1 do
                        for v = 0, tableLength(door.cells[0]) - 1 do
                            print("checking i " .. k .. " j " .. v .. " x " .. door.cells[k][v].x .. " y " .. door.cells[k][v].y)
                            visited[door.cells[k][v].x][door.cells[k][v].y] = true
                        end
                    end
                end
            end
        end
        return doors
    end

    local function connectRooms()
        local connectedRooms = {}
        for _, room in pairs(rooms) do
            for _, otherRoom in pairs(rooms) do
                roomCount = 0
                if (room ~= otherRoom and connectedRooms[room] ~= otherRoom and connectedRooms[otherRoom] ~= room) then
                    local startDoors = getRoomDoors(room)
                    local finishRooms = getRoomDoors(otherRoom)
                    
                    local start = startDoors[GetRandomInt(1, #startDoors)]
                    local finish = finishRooms[GetRandomInt(1, #finishRooms)]
                    FindPath(map, start, finish)
                    return
                end
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
            connectRooms()
        end)()
    end)

end)