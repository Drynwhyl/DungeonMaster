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

    local function rotate(source, angle, objectList)
        local resultList = {}
        local sourceLoc = Location(source.x, source.y)
        local objectLoc = Location(0, 0)
        for _, object in ipairs(objectList) do
            MoveLocation(objectLoc, object.x, object.y)
            local dist = DistanceBetweenPoints(sourceLoc, objectLoc)
            local currentAngle = AngleBetweenPoints(sourceLoc, objectLoc)
            local newLoc = PolarProjectionBJ(sourceLoc, dist, currentAngle + angle)
            table.insert(resultList, { id = object.id, x = GetLocationX(newLoc), y = GetLocationY(newLoc), angle = object.angle + angle})
            RemoveLocation(newLoc)
        end
        RemoveLocation(objectLoc)
        RemoveLocation(sourceLoc)
        return resultList
    end

    local function createWallWithRotation(current, rotation, base)
        local rotated = rotate(current, rotation, base)
        for _, object in ipairs(rotated) do
            CreateDestructableZ(object.id, object.x, object.y, WALL_Z, object.angle, 1.0, -1)
        end
    end

    local function placeWall(prev, current, next, prevMoveType, currentMoveType, nextMoveType)
        if currentMoveType == prevMoveType and prevMoveType ~= nextMoveType then
            local base = {
                { id = WALL_OUTER_CORNER_2,x = current.x, y = current.y, angle = 90.0 },
                { id = WALL_INNER_CORNER_2,x = current.x, y = current.y + bj_CELLWIDTH, angle = 180.0 },
                { id = WALL_STRAIGHT_2,x = current.x + bj_CELLWIDTH, y = current.y, angle = 90.0 },
                { id = WALL_STRAIGHT_2,x = current.x, y = current.y, angle = 0.0 },
            }
            if currentMoveType == "LEFT" and nextMoveType == "UP" or currentMoveType == "DOWN" and nextMoveType == "RIGHT"  then
                createWallWithRotation(current, 0, base)
            elseif currentMoveType == "UP" and nextMoveType == "RIGHT" or currentMoveType == "LEFT" and nextMoveType == "DOWN" then
                createWallWithRotation(current, 270, base)
            elseif currentMoveType == "RIGHT" and nextMoveType == "DOWN" or currentMoveType == "UP" and nextMoveType == "LEFT"  then
                createWallWithRotation(current, 180, base)
            elseif currentMoveType == "DOWN" and nextMoveType == "LEFT" or currentMoveType == "RIGHT" and nextMoveType == "UP"  then
                createWallWithRotation(current, 90, base)
            end
        elseif currentMoveType == nextMoveType and currentMoveType == prevMoveType then
            local base = {
                { id = WALL_STRAIGHT_2,x = current.x, y = current.y, angle = 180.0 },
                { id = WALL_STRAIGHT_2,x = current.x, y = current.y - bj_CELLWIDTH, angle = 0.0 },
            }
            if currentMoveType == "UP" then
                createWallWithRotation(current, 0, base)
            elseif currentMoveType == "DOWN" then
                createWallWithRotation(current, 180, base)
            elseif currentMoveType == "RIGHT" then
                createWallWithRotation(current, 270, base)
            elseif currentMoveType == "LEFT" then
                createWallWithRotation(current, 90, base)
            end
        elseif true then
            if prevMoveType == "UP" and currentMoveType == "UP_LEFT" and nextMoveType == "LEFT" then
                CreateDestructableZ(WALL_DIAGONAL_2, current.x, current.y - bj_CELLWIDTH, WALL_Z, 270.0, 1.0, -1)

                CreateDestructableZ(WALL_OUTER_CORNER_2, current.x, current.y, WALL_Z, 270.0, 1.0, -1)
                CreateDestructableZ(WALL_OUTER_CORNER_2, current.x + bj_CELLWIDTH, current.y - bj_CELLWIDTH, WALL_Z, 270.0, 1.0, -1)

                CreateDestructableZ(WALL_STRAIGHT_2, current.x, current.y, WALL_Z, 90.0, 1.0, -1)
                CreateDestructableZ(WALL_STRAIGHT_2, current.x - bj_CELLWIDTH, current.y, WALL_Z, 270.0, 1.0, -1)

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