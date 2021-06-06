WM("ConnectRooms", function(import, export, exportDefault)

    local CreateAutotable = import "CreateAutotable"
    local PriorityQueue = import "PriorityQueue"
    local Utils = import "Utils"

    local map

    local TILE_EMPTY = TILE_ICECROWN_DIRT
    local TILE_FLOOR = TILE_ICECROWN_RUNE_BRICKS
    local TILE_WALL = TILE_ICECROWN_BLACK_SQUARES
    local TILE_DOOR = TILE_ICECROWN_TILED_BRICKS
    local TILE_HALLWAY = TILE_ICECROWN_BLACK_BRICKS

    local function rectContainsPathing(rect, ...)
        local pathings = {}
        for _, value in ipairs(table.pack(...)) do
            pathings[value] = true
        end
        for i = GetRectMinX(rect), GetRectMaxX(rect), bj_CELLWIDTH do
            for j = GetRectMinY(rect), GetRectMaxY(rect), bj_CELLWIDTH do 
                if pathings[GetTerrainType(i, j)] == true then 
                    return true
                end
            end
        end
        return false
    end

    local function cellsContainsAllPathings(x, y, size, ...)
        local pathings = {}
        for _, value in ipairs(table.pack(...)) do
            pathings[value] = true
        end
        local firstPart = size // 2
        local secondPart = size // 2
        if (size % 2 == 0) then
            secondPart = secondPart - 1
        end
        firstPart = firstPart * bj_CELLWIDTH
        secondPart = secondPart * bj_CELLWIDTH
        for i = x - firstPart, x + secondPart do
            for j = y - firstPart, y + secondPart do
                if pathings[GetTerrainType(i, j)] ~= true then
                    return false
                end
            end
        end
        return true
    end

    local function getRectFromPoint(x, y, size)
        local firstPart = size // 2
        local secondPart = size // 2
        if (size % 2 == 0) then
            secondPart = secondPart - 1
        end
        firstPart = firstPart * bj_CELLWIDTH
        secondPart = secondPart * bj_CELLWIDTH
        local rect = Rect(x - firstPart, y - firstPart, x + secondPart, y + secondPart)

        if GetRectMinX(rect) < GetRectMinX(map)
        or GetRectMaxX(rect) > GetRectMaxX(map)
        or GetRectMinY(rect) < GetRectMinY(map)
        or GetRectMaxY(rect) > GetRectMaxY(map) 
        or rectContainsPathing(rect, TILE_WALL, TILE_FLOOR) then
            RemoveRect(rect)
            return nil
        end

        return rect
    end

    local function addNode(node, neighbour)
        if node ~= nil and neighbour ~= nil and not rectContainsPathing(neighbour.rect, TILE_WALL, TILE_FLOOR, TILE_DOOR) then
            table.insert(node.neighbours, neighbour)
        end
    end

    local function createGraph(map)
        local nodeSize = 5;
        local nodes = CreateAutotable(1)
        for i = GetRectMinX(map), GetRectMaxX(map), bj_CELLWIDTH do
            for j = GetRectMinY(map), GetRectMaxY(map), bj_CELLWIDTH do 
                local rect = getRectFromPoint(i, j, nodeSize)
                if rect == nil then
                    nodes[i][j] = nil
                else
                    nodes[i][j] = { neighbours = {}, rect = rect }
                end
            end
        end

        
        for i = GetRectMinX(map), GetRectMaxX(map), bj_CELLWIDTH do
            for j = GetRectMinY(map), GetRectMaxY(map), bj_CELLWIDTH do 
                if i > GetRectMinX(map) then 
                    addNode(nodes[i][j], nodes[i - bj_CELLWIDTH][j])
                end
                if i < GetRectMaxX(map) then 
                    addNode(nodes[i][j], nodes[i + bj_CELLWIDTH][j])
                end
                if j > GetRectMinY(map) then 
                    addNode(nodes[i][j], nodes[i][j - bj_CELLWIDTH])
                end
                if j < GetRectMaxY(map) then 
                    addNode(nodes[i][j], nodes[i][j + bj_CELLWIDTH])
                end
            end
        end

        return nodes
    end

    local function getDoorSize(door)
        return IMaxBJ(door.width, door.height)
    end

    local function getDoorCenter(door)
        if door.horizontal then
            return door.cells[door.width // 2][0]
        else
            return door.cells[0][door.height // 2]
        end
    end

    local function findNearestNodeToDoor(door, nodes)
        local center = getDoorCenter(door)
        local pathings = { [TILE_EMPTY] = true, [TILE_HALLWAY] = true }
        local size = getDoorSize(door) - getDoorSize(door) // 2
        if door.horizontal and pathings[GetTerrainType(center.x, center.y - bj_CELLWIDTH * size)] == true then
            return nodes[center.x][center.y - bj_CELLWIDTH * size]
        elseif door.horizontal and pathings[GetTerrainType(center.x, center.y + bj_CELLWIDTH * size)] == true then
            return nodes[center.x][center.y + bj_CELLWIDTH * size]
        elseif not door.horizontal and pathings[GetTerrainType(center.x - bj_CELLWIDTH * size, center.y)] == true then
            return nodes[center.x - bj_CELLWIDTH * size][center.y]
        elseif not door.horizontal and pathings[GetTerrainType(center.x + bj_CELLWIDTH * size, center.y)] == true then
            return nodes[center.x + bj_CELLWIDTH * size][center.y]
        end
        return nil
    end

    local function heuristic(x1, y1, x2, y2)
        return IAbsBJ(x1 - x2) + IAbsBJ(y1 - y2)
    end

    local counter = 0

    local function findPath(nodes, map, startDoor, finishDoor)
        local graph = PriorityQueue()

        local start = findNearestNodeToDoor(startDoor, nodes)
        local goal = findNearestNodeToDoor(finishDoor, nodes)

        if start == nil or goal == nil then
            print("ERROR: start/finish nodes are null!")
            return
        end

        graph:put(start, 0)
        local cameFrom = { [start] = start }
        local costSoFar = { [start] = 0 }

        local found = false
        while not graph:empty() do
            local current = graph:pop()

            if current == goal then
                print("FOUND!")
                found = true
                break
            end

            for _, next in pairs(current.neighbours) do
                if (counter % 100 == 0) then
                    TriggerSleepAction(0)
                    print("node processed: ", counter)
                end
                counter = counter + 1

                local prev = cameFrom[current]
                local moveCost = 0

                local prevMoveType
                if GetRectCenterX(prev.rect) - GetRectCenterX(current.rect) == 0 then
                    prevMoveType = 0
                else
                    prevMoveType = 1
                end

                local nextMoveType
                if GetRectCenterX(next.rect) - GetRectCenterX(current.rect) == 0 then
                    prevMoveType = 0
                else
                    prevMoveType = 1
                end

                if prevMoveType == nextMoveType then
                    moveCost = moveCost + 4
                else
                    moveCost = moveCost + 5
                end

                local x = GetRectCenterX(next.rect)
                local y = GetRectCenterY(next.rect)

                --  if not cellsContainsAllPathings(x, y, getDoorSize(startDoor), TILE_EMPTY, TILE_HALLWAY) then
                --     --moveCost = moveCost + 10
                -- end

                if next.hallway == true then
                    moveCost = moveCost - 3
                end

                local newCost = costSoFar[current] + moveCost
                if costSoFar[next] == nil or newCost < costSoFar[next] then
                    costSoFar[next] = newCost
                    local priority = newCost + heuristic(
                        GetRectCenterX(goal.rect), GetRectCenterY(goal.rect),
                        GetRectCenterX(next.rect), GetRectCenterY(next.rect)
                    )
                    graph:put(next, priority)
                    cameFrom[next] = current
                end
            end
        end

        if found then 
            local current = goal;
            local path = { current }
            while current ~= start do
                current = cameFrom[current]
                current.hallway = true
                table.insert(path, current)
                SetTerrainType(GetRectCenterX(current.rect), GetRectCenterY(current.rect), TILE_HALLWAY, -1, 3, 1)
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

    local function getRoomDoors(room)
        local visited = CreateAutotable(1)
        local doors = {}
        for i = 0, room.width do
            for j = 0, room.height do
                if GetTerrainType(room.cells[i][j].x, room.cells[i][j].y) == TILE_DOOR and visited[room.cells[i][j].x][room.cells[i][j].y] ~= true then
                    local door = getDoorCells(room, i, j)
                    table.insert(doors, door)
                    for k = 0, Utils.tableLength(door.cells) - 1 do
                        for v = 0, Utils.tableLength(door.cells[0]) - 1 do
                            visited[door.cells[k][v].x][door.cells[k][v].y] = true
                        end
                    end
                end
            end
        end
        return doors
    end

    local function ConnectRooms(rooms, _map)
        map = _map
        local connectedRooms = {}
        local roomCount = 0
        local nodes = createGraph(map)
        for _, room in pairs(rooms) do
            for _, otherRoom in pairs(rooms) do
                if (room ~= otherRoom and connectedRooms[room] ~= otherRoom and connectedRooms[otherRoom] ~= room) then
                    local startDoors = getRoomDoors(room)
                    local finishRooms = getRoomDoors(otherRoom)
                    
                    local start = startDoors[GetRandomInt(1, #startDoors)]
                    local finish = finishRooms[GetRandomInt(1, #finishRooms)]
                    findPath(nodes, map, start, finish)
                    connectedRooms[room] = otherRoom
                    connectedRooms[otherRoom] = room
                    roomCount = roomCount + 1
                    print("room count", roomCount)
                end
            end
        end
    end

    exportDefault(ConnectRooms)
end)