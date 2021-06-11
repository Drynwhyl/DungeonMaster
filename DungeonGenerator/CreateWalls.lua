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
        cccc = FourCC("ZTtw"), -- mark full cell
        aaaa = FourCC("OTtw"), -- mark empty cell
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

        local down_left = GetTerrainType(point.x - bj_CELLWIDTH, point.y - bj_CELLWIDTH)
        local up_left = GetTerrainType(point.x - bj_CELLWIDTH, point.y + bj_CELLWIDTH)
        local down_right = GetTerrainType(point.x + bj_CELLWIDTH, point.y - bj_CELLWIDTH)
        local up_right = GetTerrainType(point.x + bj_CELLWIDTH, point.y + bj_CELLWIDTH)

        local diagonal = 0
        if down_left == TILE_EMPTY then
            diagonal = diagonal + 1
        end
        if up_left == TILE_EMPTY then
            diagonal = diagonal + 1
        end
        if down_right == TILE_EMPTY then
            diagonal = diagonal + 1
        end
        if up_right == TILE_EMPTY then
            diagonal = diagonal + 1
        end

        return up == TILE_EMPTY or down == TILE_EMPTY or left == TILE_EMPTY or right == TILE_EMPTY-- or diagonal == 1
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
        return { x = current.x + delta.x, y = current.y + delta.y }
    end

    local function checkDirection(direction, current, visited)
        local next = getNextCell(direction, current)

        print(direction, GetTerrainType(next.x, next.y) ~= TILE_EMPTY, visited[next.x][next.y] ~= true, isHallwayCellOnEdge(next))
        if GetTerrainType(next.x, next.y) ~= TILE_EMPTY
                and visited[next.x][next.y] ~= true
                and isHallwayCellOnEdge(next) then
            return next
        end
        return nil
    end

    local function placeWall(current, visitedWalls)
        local cliff = {
            { "a", "a", "a", "a" },
            { "a", "c", "c", "a" },
            { "a", "c", "c", "a" },
            { "a", "a", "a", "a" },
        }

        -- Check left
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
        if GetTerrainType(current.x - bj_CELLWIDTH, current.y + bj_CELLWIDTH) == TILE_WALL then
            cliff[1][1] = "c"
        end
        -- Check up-right 
        if GetTerrainType(current.x + bj_CELLWIDTH, current.y + bj_CELLWIDTH) == TILE_WALL then
            cliff[1][4] = "c"
        end
        -- Check down-right 
        if GetTerrainType(current.x + bj_CELLWIDTH, current.y - bj_CELLWIDTH) == TILE_WALL then
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

        if not visitedWalls[current.x - bj_CELLWIDTH][current.y] then
            visitedWalls[current.x - bj_CELLWIDTH][current.y] = CreateDestructableZ(cellUpLeft, current.x - bj_CELLWIDTH, current.y, WALL_Z, 270.0, 1.0, -1)
        end
        if not visitedWalls[current.x - bj_CELLWIDTH][current.y - bj_CELLWIDTH] then
            visitedWalls[current.x - bj_CELLWIDTH][current.y - bj_CELLWIDTH] = CreateDestructableZ(cellDownLeft, current.x - bj_CELLWIDTH, current.y - bj_CELLWIDTH, WALL_Z, 270.0, 1.0, -1)
        end
        if not visitedWalls[current.x][current.y] then
            visitedWalls[current.x][current.y] = CreateDestructableZ(cellUpRight, current.x, current.y, WALL_Z, 270.0, 1.0, -1)
        end
        if not visitedWalls[current.x][current.y - bj_CELLWIDTH] then
            visitedWalls[current.x][current.y - bj_CELLWIDTH] = CreateDestructableZ(cellDownRight, current.x, current.y - bj_CELLWIDTH, WALL_Z, 270.0, 1.0, -1)
        end
    end

    local function CreateWalls(map)
        local visitedWalls = CreateAutotable(1)
        for x = GetRectMinX(map), GetRectMaxX(map), bj_CELLWIDTH do
            for y = GetRectMinY(map), GetRectMaxY(map), bj_CELLWIDTH do
                if GetTerrainType(x, y) == TILE_WALL then
                    placeWall({ x = x, y = y }, visitedWalls)
                end
            end
        end
    end

    exportDefault(CreateWalls)
end)