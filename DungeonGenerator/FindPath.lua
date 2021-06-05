WM("FindPath", function(import, export, exportDefault)

    local CreateAutotable = import "CreateAutotable"
    local PriorityQueue = import "PriorityQueue"

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
            for j = GetRectMinX(rect), GetRectMaxX(rect), bj_CELLWIDTH do 
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
        local halfsize = size / 2
        for i = x - halfsize, x + halfsize - 1 do
            for j = y - halfsize, y + halfsize - 1 do
                if pathings[GetTerrainType(i * bj_CELLWIDTH, j * bj_CELLWIDTH)] ~= true then
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
        if node ~= nil and neighbour ~= nil and not rectContainsPathing(neighbour.rect, TILE_WALL, TILE_FLOOR) then
            table.insert(node.neighbours, neighbour)
        end
    end

    local function createGraph(_map)
        map = _map
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
                if j > GetRectMaxY(map) then 
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
        if door.horizontal and pathings[GetTerrainType(center.x, center.y - bj_CELLWIDTH * 2)] == true then
            return nodes[center.x][center.y - bj_CELLWIDTH * 2]
        elseif door.horizontal and pathings[GetTerrainType(center.x, center.y + bj_CELLWIDTH * 2)] == true then
            return nodes[center.x][center.y + bj_CELLWIDTH * 2]
        elseif not door.horizontal and pathings[GetTerrainType(center.x - bj_CELLWIDTH * 2, center.y)] == true then
            return nodes[center.x - bj_CELLWIDTH * 2][center.y]
        elseif not door.horizontal and pathings[GetTerrainType(center.x + bj_CELLWIDTH * 2, center.y)] == true then
            return nodes[center.x + bj_CELLWIDTH * 2][center.y]
        end
        return nil
    end

    local function heuristic(x1, y1, x2, y2)
        return IAbsBJ(x1 - x2) + IAbsBJ(y1 - y2)
    end

    local counter = 0

    local function FindPath(map, startDoor, finishDoor)
        local nodes = createGraph(map)
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

        while not graph:empty() do
            local current = graph:pop()

            if current == goal then
                print("FOUND!")
                break
            end

            for _, next in pairs(current.neighbours) do
                print("node processed: ", counter)
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
                    moveCost = 4
                else
                    moveCost = 5
                end

                local x = GetRectCenterX(next.rect)
                local y = GetRectCenterY(next.rect)

                if not cellsContainsAllPathings(x, y, getDoorSize(startDoor), TILE_EMPTY, TILE_HALLWAY) then
                    moveCost = moveCost + 10
                end

                if not cellsContainsAllPathings(x, y, getDoorSize(startDoor), TILE_HALLWAY) then
                    moveCost = moveCost - 1
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

        local current = goal;
        local path = { current }
        while current ~= start do
            current = cameFrom[current]
            table.insert(path, current)
            SetTerrainType(GetRectCenterX(current.rect), GetRectCenterY(current.rect), TILE_HALLWAY, -1, 3, 1)
        end
    end

    exportDefault(FindPath)
end)