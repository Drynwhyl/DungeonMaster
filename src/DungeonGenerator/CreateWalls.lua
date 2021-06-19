require 'TerrainTypeCodes'

local CreateAutotable = require "CreateAutotable"
local WALL_Z = 60.0
local PATH_BLOCK_ID = FourCC("Ytlc")

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

local function placeCliff(x, y, visitedWalls)
    local cliff = {
        { "a", "a", "a", "a" },
        { "a", "c", "c", "a" },
        { "a", "c", "c", "a" },
        { "a", "a", "a", "a" },
    }

    -- Check left
    if GetTerrainType(x - bj_CELLWIDTH, y) == TILE_WALL then
        cliff[2][1] = "c"
        cliff[3][1] = "c"
    end
    -- Check right
    if GetTerrainType(x + bj_CELLWIDTH, y) == TILE_WALL then
        cliff[2][4] = "c"
        cliff[3][4] = "c"
    end
    -- Check up
    if GetTerrainType(x, y + bj_CELLWIDTH) == TILE_WALL then
        cliff[1][2] = "c"
        cliff[1][3] = "c"
    end
    -- Check down
    if GetTerrainType(x, y - bj_CELLWIDTH) == TILE_WALL then
        cliff[4][2] = "c"
        cliff[4][3] = "c"
    end

    -- Check down-left
    if GetTerrainType(x - bj_CELLWIDTH, y - bj_CELLWIDTH) == TILE_WALL then
        cliff[4][1] = "c"
    end
    -- Check up-left
    if GetTerrainType(x - bj_CELLWIDTH, y + bj_CELLWIDTH) == TILE_WALL then
        cliff[1][1] = "c"
    end
    -- Check up-right
    if GetTerrainType(x + bj_CELLWIDTH, y + bj_CELLWIDTH) == TILE_WALL then
        cliff[1][4] = "c"
    end
    -- Check down-right
    if GetTerrainType(x + bj_CELLWIDTH, y - bj_CELLWIDTH) == TILE_WALL then
        cliff[4][4] = "c"
    end

    function repeats(str, char)
        local _, n = str:gsub(char, "")
        return n
    end

    local strUpLeft = cliff[1][1] .. cliff[1][2] .. cliff[2][2] .. cliff[2][1];
    local strDownLeft = cliff[3][1] .. cliff[3][2] .. cliff[4][2] .. cliff[4][1]
    local strUpRight = cliff[1][3] .. cliff[1][4] .. cliff[2][4] .. cliff[2][3]
    local strDownRight = cliff[3][3] .. cliff[3][4] .. cliff[4][4] .. cliff[4][3]

    local varUpLeft = GetRandomInt(0, repeats(strUpLeft, "c"))
    local varDownLeft = GetRandomInt(0, repeats(strDownLeft, "c"))
    local varUpRight = GetRandomInt(0, repeats(strUpRight, "c"))
    local varDownRight = GetRandomInt(0, repeats(strDownRight, "c"))

    local cellUpLeft = WALLS[cliff[1][1] .. cliff[1][2] .. cliff[2][2] .. cliff[2][1]]
    local cellDownLeft = WALLS[cliff[3][1] .. cliff[3][2] .. cliff[4][2] .. cliff[4][1]]
    local cellUpRight = WALLS[cliff[1][3] .. cliff[1][4] .. cliff[2][4] .. cliff[2][3]]
    local cellDownRight = WALLS[cliff[3][3] .. cliff[3][4] .. cliff[4][4] .. cliff[4][3]]

    if not visitedWalls[x - bj_CELLWIDTH][y] then
        visitedWalls[x - bj_CELLWIDTH][y] = CreateDestructableZ(cellUpLeft, x - bj_CELLWIDTH, y, WALL_Z, 270.0, 1.0, varUpLeft)
    end
    if not visitedWalls[x - bj_CELLWIDTH][y - bj_CELLWIDTH] then
        visitedWalls[x - bj_CELLWIDTH][y - bj_CELLWIDTH] = CreateDestructableZ(cellDownLeft, x - bj_CELLWIDTH, y - bj_CELLWIDTH, WALL_Z, 270.0, 1.0, varDownLeft)
    end
    if not visitedWalls[x][y] then
        visitedWalls[x][y] = CreateDestructableZ(cellUpRight, x, y, WALL_Z, 270.0, 1.0, varUpRight)
    end
    if not visitedWalls[x][y - bj_CELLWIDTH] then
        BlzGetItemIntegerField()
        visitedWalls[x][y - bj_CELLWIDTH] = CreateDestructableZ(cellDownRight, x, y - bj_CELLWIDTH, WALL_Z, 270.0, 1.0, varDownRight)
    end

    CreateDestructable(PATH_BLOCK_ID, x, y, 270.0, 1.0, 0)
end

local function CreateWalls(map)
    local visitedWalls = CreateAutotable(1)
    for x = GetRectMinX(map), GetRectMaxX(map), bj_CELLWIDTH do
        for y = GetRectMinY(map), GetRectMaxY(map), bj_CELLWIDTH do
            if GetTerrainType(x, y) == TILE_WALL then
                placeCliff(x, y, visitedWalls)
            end
        end
    end
end

return CreateWalls