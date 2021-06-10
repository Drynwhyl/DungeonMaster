WM("CreateWalls", function(import, export, exportDefault)

    local CreateAutotable = import "CreateAutotable"
    local WALL_STRAIGHT_2 = FourCC("B007")
    local WALL_OUTER_CORNER_2 = FourCC("B001")
    local WALL_INNER_CORNER_2 = FourCC("B00A")
    local WALL_DIAGONAL_2 = FourCC("B00B")
    local WALL_Z = 60.0

    local WALLS = {
        aaac = FourCC("B001"),
        aaca = FourCC("B005"),
        aacc = FourCC("B007"),
        acaa = FourCC("B002"),
        acac = FourCC("B003"),
        acca = FourCC("B004"),
        accc = FourCC("B00A"),
        caaa = FourCC("B006"),
        caac = FourCC("B008"),
        caca = FourCC("B00B"),
        cacc = FourCC("B000"),
        ccaa = FourCC("B009"),
        ccac = FourCC("B00C"),
        ccca = FourCC("B00D"),
    }

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

    local function placeWall(current)
        local cliff = {
            { "a", "a", "a", "a" },
            { "a", "c", "c", "a" },
            { "a", "c", "c", "a" },
            { "a", "a", "a", "a" },
        }

        -- Check left
                print("receive", current)
        if GetTerrainType(current.x - bj_CELLWIDTH, current.y) == TILE_WALL then
            cliff[2][1] = "c"
            cliff[3][1] = "c"
        end
        -- Check right
        if GetTerrainType(current.x + bj_CELLWIDTH, current.y) == TILE_WALL then
            cliff[2][4] = "c"
            cliff[3][4] = "c"
        end
        -- Check up
        if GetTerrainType(current.x, current.y + bj_CELLWIDTH) == TILE_WALL then
            cliff[1][2] = "c"
            cliff[1][3] = "c"
        end
        -- Check down
        if GetTerrainType(current.x, current.y - bj_CELLWIDTH) == TILE_WALL then
            cliff[4][2] = "c"
            cliff[4][3] = "c"
        end

        -- Check down-left 
        if GetTerrainType(current.x - bj_CELLWIDTH, current.y - bj_CELLWIDTH) == TILE_WALL then
            cliff[4][1] = "c"
        end
        -- Check up-left 
        if GetTerrainType(current.x - bj_CELLWIDTH, current.y - bj_CELLWIDTH) == TILE_WALL then
            cliff[1][1] = "c"
        end
        -- Check up-right 
        if GetTerrainType(current.x - bj_CELLWIDTH, current.y - bj_CELLWIDTH) == TILE_WALL then
            cliff[1][4] = "c"
        end
        -- Check down-right 
        if GetTerrainType(current.x - bj_CELLWIDTH, current.y - bj_CELLWIDTH) == TILE_WALL then
            cliff[4][4] = "c"
        end

        print(
            cliff[1][1] .. cliff[1][2] .. cliff[2][2] .. cliff[2][1],
            cliff[3][1] .. cliff[3][2] .. cliff[4][2] .. cliff[4][1],
            cliff[1][3] .. cliff[1][4] .. cliff[2][4] .. cliff[2][3],
            cliff[3][3] .. cliff[3][4] .. cliff[4][4] .. cliff[4][3]
         )
        local cellUpLeft = WALLS[cliff[1][1] .. cliff[1][2] .. cliff[2][2] .. cliff[2][1]]
        local cellDownLeft = WALLS[cliff[3][1] .. cliff[3][2] .. cliff[4][2] .. cliff[4][1]]
        local cellUpRight = WALLS[cliff[1][3] .. cliff[1][4] .. cliff[2][4] .. cliff[2][3]]
        local cellDownRight = WALLS[cliff[3][3] .. cliff[3][4] .. cliff[4][4] .. cliff[4][3]]

        CreateDestructableZ(cellUpLeft, current.x - bj_CELLWIDTH, current.y, WALL_Z, 270.0, 1.0, -1)
        CreateDestructableZ(cellDownLeft, current.x - bj_CELLWIDTH, current.y - bj_CELLWIDTH, WALL_Z, 270.0, 1.0, -1)
        CreateDestructableZ(cellUpRight, current.x, current.y, WALL_Z, 270.0, 1.0, -1)
        CreateDestructableZ(cellDownRight, current.x, current.y - bj_CELLWIDTH , WALL_Z, 270.0, 1.0, -1)
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
            if current ~= nil and (GetTerrainType(current.x, current.y) == TILE_HALLWAY or true) then
                SetTerrainType(current.x, current.y, TILE_WALL, -1, 1, 1)
            end
            if prev ~= nil then
                print("pass current", prev)
                placeWall(prev)
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
                --placeWall(prev, current, next, prevMoveType, currentMoveType, nextMoveType)
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