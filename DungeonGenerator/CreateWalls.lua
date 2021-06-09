WM("CreateWalls", function(import, export, exportDefault)

    local CreateAutotable = import "CreateAutotable"
    local WALL_STRAIGHT_2 = FourCC("B007")
    local WALL_OUTER_CORNER_2 = FourCC("B001")
    local WALL_INNER_CORNER_2 = FourCC("B00A")
    local WALL_DIAGONAL_2 = FourCC("B00B")
    local WALL_Z = 60.0

    local function findHallwayCell(map)
        for i = GetRectMinX(map), GetRectMaxX(map), bj_CELLWIDTH do  
            for j = GetRectMinY(map), GetRectMaxY(map), bj_CELLWIDTH do 
                if GetTerrainType(i, j) == TILE_HALLWAY then
                    return { x = i, y = j }
                end
            end
        end
        print("ERROR! Hallways not found!")
    end

    local function isHallwayCellOnEdge(point)
        local up = GetTerrainType(point.x, point.y + bj_CELLWIDTH)
        local down = GetTerrainType(point.x, point.y - bj_CELLWIDTH)
        local left = GetTerrainType(point.x - bj_CELLWIDTH, point.y)
        local right = GetTerrainType(point.x + bj_CELLWIDTH, point.y)
        return up == TILE_EMPTY or down == TILE_EMPTY or left == TILE_EMPTY or right == TILE_EMPTY
    end

    local function getNextCell(direction, current)
        local directionDelta = { 
            RIGHT = { x = bj_CELLWIDTH, y = 0 },
            LEFT = { x = -bj_CELLWIDTH, y = 0 },
            UP = { x = 0, y = bj_CELLWIDTH },
            DOWN = { x = 0, y = -bj_CELLWIDTH },
            DOWN_LEFT = { x = -bj_CELLWIDTH, y = -bj_CELLWIDTH },
            UP_LEFT = { x = -bj_CELLWIDTH, y = bj_CELLWIDTH },
            UP_RIGHT = { x = bj_CELLWIDTH, y = bj_CELLWIDTH },
            DOWN_RIGHT = { x = bj_CELLWIDTH, y = -bj_CELLWIDTH },
        }
        
        local delta = directionDelta[direction]
        local next = { 
            x = current.x + delta.x,
            y = current.y + delta.y
        }
        return next
    end

    local function checkDirection(direction, current, visited) 
        local next = getNextCell(direction, current)
        if GetTerrainType(next.x, next.y) ~= TILE_EMPTY
        and visited[next.x][next.y] ~= true
        and isHallwayCellOnEdge(next) then
            return next
        end
        return nil
    end

    local function placeWall(prev, current, next, prevMoveType, currentMoveType, nextMoveType)
        if currentMoveType == nextMoveType and currentMoveType == prevMoveType then
            if currentMoveType == "UP" then
                CreateDestructableZ(WALL_STRAIGHT_2, current.x, current.y - bj_CELLWIDTH, WALL_Z, 0.0, 1.0, -1)
                CreateDestructableZ(WALL_STRAIGHT_2, current.x, current.y, WALL_Z, 180.0, 1.0, -1)
            elseif currentMoveType == "DOWN" then
                CreateDestructableZ(WALL_STRAIGHT_2, current.x, current.y, WALL_Z, 0.0, 1.0, -1)
                CreateDestructableZ(WALL_STRAIGHT_2, current.x, current.y + bj_CELLWIDTH, WALL_Z, 180.0, 1.0, -1)
            elseif currentMoveType == "RIGHT" then
                CreateDestructableZ(WALL_STRAIGHT_2, current.x, current.y, WALL_Z, 90.0, 1.0, -1)
                CreateDestructableZ(WALL_STRAIGHT_2, current.x - bj_CELLWIDTH, current.y, WALL_Z, 270.0, 1.0, -1)
            elseif currentMoveType == "LEFT" then
                CreateDestructableZ(WALL_STRAIGHT_2, current.x + bj_CELLWIDTH, current.y, WALL_Z, 90.0, 1.0, -1)
                CreateDestructableZ(WALL_STRAIGHT_2, current.x, current.y, WALL_Z, 270.0, 1.0, -1)
            end
        elseif currentMoveType == prevMoveType and prevMoveType ~= nextMoveType then
            if currentMoveType == "LEFT" and nextMoveType == "UP" then
                CreateDestructableZ(WALL_OUTER_CORNER_2, current.x, current.y, WALL_Z, 90.0, 1.0, -1)
                CreateDestructableZ(WALL_INNER_CORNER_2, current.x, current.y + bj_CELLWIDTH, WALL_Z, 180.0, 1.0, -1)
                CreateDestructableZ(WALL_STRAIGHT_2, current.x + bj_CELLWIDTH, current.y, WALL_Z, 90.0, 1.0, -1)
                CreateDestructableZ(WALL_STRAIGHT_2, current.x, current.y, WALL_Z, 0.0, 1.0, -1)
            elseif currentMoveType == "UP" and nextMoveType == "RIGHT" then
                CreateDestructableZ(WALL_OUTER_CORNER_2, current.x, current.y, WALL_Z, 0.0, 1.0, -1)
                CreateDestructableZ(WALL_INNER_CORNER_2, current.x + bj_CELLWIDTH, current.y, WALL_Z, 90.0, 1.0, -1)
                CreateDestructableZ(WALL_STRAIGHT_2, current.x, current.y - bj_CELLWIDTH, WALL_Z, 0.0, 1.0, -1)
                CreateDestructableZ(WALL_STRAIGHT_2, current.x, current.y, WALL_Z, 270.0, 1.0, -1)
            elseif currentMoveType == "RIGHT" and nextMoveType == "DOWN" then
                CreateDestructableZ(WALL_OUTER_CORNER_2, current.x, current.y, WALL_Z, 270.0, 1.0, -1)
                CreateDestructableZ(WALL_INNER_CORNER_2, current.x, current.y - bj_CELLWIDTH, WALL_Z, 0.0, 1.0, -1)
                CreateDestructableZ(WALL_STRAIGHT_2, current.x - bj_CELLWIDTH, current.y, WALL_Z, 270.0, 1.0, -1)
                CreateDestructableZ(WALL_STRAIGHT_2, current.x, current.y, WALL_Z, 180.0, 1.0, -1)
            elseif currentMoveType == "DOWN" and nextMoveType == "LEFT" then
                CreateDestructableZ(WALL_OUTER_CORNER_2, current.x, current.y, WALL_Z, 180.0, 1.0, -1)
                CreateDestructableZ(WALL_INNER_CORNER_2, current.x - bj_CELLWIDTH, current.y, WALL_Z, 270.0, 1.0, -1)
                CreateDestructableZ(WALL_STRAIGHT_2, current.x, current.y + bj_CELLWIDTH, WALL_Z, 180.0, 1.0, -1)
                CreateDestructableZ(WALL_STRAIGHT_2, current.x, current.y, WALL_Z, 90.0, 1.0, -1)
            end
        elseif true then
            if prevMoveType == "UP" and currentMoveType == "UP_LEFT" and nextMoveType == "LEFT" then
                CreateDestructableZ(WALL_DIAGONAL_2, current.x, current.y - bj_CELLWIDTH, WALL_Z, 270.0, 1.0, -1)

                CreateDestructableZ(WALL_OUTER_CORNER_2, current.x, current.y, WALL_Z, 270.0, 1.0, -1)
                CreateDestructableZ(WALL_OUTER_CORNER_2, current.x + bj_CELLWIDTH, current.y - bj_CELLWIDTH, WALL_Z, 270.0, 1.0, -1)

                CreateDestructableZ(WALL_STRAIGHT_2, current.x, current.y, WALL_Z, 90.0, 1.0, -1)
                CreateDestructableZ(WALL_STRAIGHT_2, current.x - bj_CELLWIDTH, current.y, WALL_Z, 270.0, 1.0, -1)
                
                CreateDestructableZ(WALL_STRAIGHT_2, current.x + bj_CELLWIDTH, current.y - 2 * bj_CELLWIDTH, WALL_Z, 0.0, 1.0, -1)
                CreateDestructableZ(WALL_STRAIGHT_2, current.x + bj_CELLWIDTH, current.y - bj_CELLWIDTH, WALL_Z, 180.0, 1.0, -1)
            elseif prevMoveType == "UP" and currentMoveType == "UP_RIGHT" and nextMoveType == "RIGHT" then
                CreateDestructableZ(WALL_DIAGONAL_2, current.x, current.y - bj_CELLWIDTH, WALL_Z, 0.0, 1.0, -1)

                CreateDestructableZ(WALL_OUTER_CORNER_2, current.x, current.y, WALL_Z, 0.0, 1.0, -1)
                CreateDestructableZ(WALL_OUTER_CORNER_2, current.x - bj_CELLWIDTH, current.y - bj_CELLWIDTH, WALL_Z, 0.0, 1.0, -1)
                
                CreateDestructableZ(WALL_STRAIGHT_2, current.x, current.y, WALL_Z, 270.0, 1.0, -1)
                CreateDestructableZ(WALL_STRAIGHT_2, current.x + bj_CELLWIDTH, current.y, WALL_Z, 90.0, 1.0, -1)
                
                CreateDestructableZ(WALL_STRAIGHT_2, current.x - bj_CELLWIDTH, current.y - 2 * bj_CELLWIDTH, WALL_Z, 0.0, 1.0, -1)
                CreateDestructableZ(WALL_STRAIGHT_2, current.x - bj_CELLWIDTH, current.y - bj_CELLWIDTH, WALL_Z, 180.0, 1.0, -1)
            elseif prevMoveType == "LEFT" and currentMoveType == "UP_LEFT" and nextMoveType == "UP" then
                CreateDestructableZ(WALL_DIAGONAL_2, current.x, current.y - bj_CELLWIDTH, WALL_Z, 270.0, 1.0, -1)

                CreateDestructableZ(WALL_OUTER_CORNER_2, current.x, current.y, WALL_Z, 90.0, 1.0, -1)
                CreateDestructableZ(WALL_OUTER_CORNER_2, current.x + bj_CELLWIDTH, current.y - bj_CELLWIDTH, WALL_Z, 90.0, 1.0, -1)
                
                CreateDestructableZ(WALL_STRAIGHT_2, current.x, current.y, WALL_Z, 0.0, 1.0, -1)
                CreateDestructableZ(WALL_STRAIGHT_2, current.x, current.y + bj_CELLWIDTH, WALL_Z, 180.0, 1.0, -1)
                
                CreateDestructableZ(WALL_STRAIGHT_2, current.x + 2 * bj_CELLWIDTH, current.y - bj_CELLWIDTH, WALL_Z, 90.0, 1.0, -1)
                CreateDestructableZ(WALL_STRAIGHT_2, current.x + bj_CELLWIDTH, current.y - bj_CELLWIDTH, WALL_Z, 270.0, 1.0, -1)
            elseif prevMoveType == "DOWN" and currentMoveType == "DOWN_LEFT" and nextMoveType == "LEFT" then
                -- CreateDestructableZ(WALL_DIAGONAL_2, current.x, current.y - bj_CELLWIDTH, WALL_Z, 270.0, 1.0, -1)

                -- CreateDestructableZ(WALL_OUTER_CORNER_2, current.x, current.y, WALL_Z, 90.0, 1.0, -1)
                -- CreateDestructableZ(WALL_OUTER_CORNER_2, current.x + bj_CELLWIDTH, current.y - bj_CELLWIDTH, WALL_Z, 90.0, 1.0, -1)
                
                -- CreateDestructableZ(WALL_STRAIGHT_2, current.x, current.y, WALL_Z, 0.0, 1.0, -1)
                -- CreateDestructableZ(WALL_STRAIGHT_2, current.x, current.y + bj_CELLWIDTH, WALL_Z, 180.0, 1.0, -1)
                
                -- CreateDestructableZ(WALL_STRAIGHT_2, current.x + 2 * bj_CELLWIDTH, current.y - bj_CELLWIDTH, WALL_Z, 90.0, 1.0, -1)
                -- CreateDestructableZ(WALL_STRAIGHT_2, current.x + bj_CELLWIDTH, current.y - bj_CELLWIDTH, WALL_Z, 270.0, 1.0, -1)
            end
        end
    end

    local counter = 0
    local function CreateWalls(map)
        local prevMoveType
        local currentMoveType
        local nextMoveType
        local prev
        local current = findHallwayCell(map)
        local next
        local visited = CreateAutotable(1)
        local moveTypes = { "DOWN", "DOWN_LEFT", "LEFT", "UP_LEFT", "UP", "UP_RIGHT", "RIGHT", "DOWN_RIGHT" }

        while true do
            PanCameraToTimed(current.x, current.y, 0)
            if GetTerrainType(current.x, current.y) == TILE_HALLWAY then
                SetTerrainType(current.x, current.y, TILE_WALL, -1, 1, 1)
            end
            if counter % 4 == 0 then
                TriggerSleepAction(0)
            end
            counter = counter + 1
            visited[current.x][current.y] = true

            for _, direction in ipairs(moveTypes) do
                next = checkDirection(direction, current, visited)
                if next then
                    nextMoveType = direction
                    break
                end
            end
            if next then
                placeWall(prev, current, next, prevMoveType, currentMoveType, nextMoveType)
                prev = current
                current = next
                prevMoveType = currentMoveType
                currentMoveType = nextMoveType
            else
                CreateDestructable(FourCC("OTtw"), current.x, current.y, 0, 1, -1)
                PanCameraTo(current.x, current.y)
                print("ERROR: next cell not found!")
                break;
            end
        end
    end

    exportDefault(CreateWalls)
end)