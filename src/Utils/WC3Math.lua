local WC3Math = {}

function WC3Math.getRectArea(rect)
    return (GetRectMaxX(rect) - GetRectMinX(rect)) * (GetRectMaxY(rect) - GetRectMinY(rect))
end

function WC3Math.distanceBetweenPoints(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return math.sqrt(dx * dx + dy * dy)
end

function WC3Math.angleBetweenPoints(x1, y1, x2, y2)
    return math.deg(math.atan(y2 - y1, x2 - x1))
end

function WC3Math.angleBetweenUnits(u1, u2)
    return math.deg(math.atan(GetUnitY( u2) - GetUnitY(u1), GetUnitX(u2) - GetUnitX(u1)))
end

function WC3Math.polarProjection(sourceX, sourceY, dist, angle)
    local x = sourceX + dist * math.cos(math.rad(angle))
    local y = sourceY + dist * math.sin(math.rad(angle))
    return x, y
end

local floor, insert = math.floor, table.insert
---@param num number @Number to convert
---@param base number @Base from 2 to 36
function WC3Math.baseN(num, base)
    num = math.floor(num)
    if not base or base == 10 then
        return tostring(num)
    end
    local digits = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!#$%&()*+,-./:;<=>?[\\]^_{|}~"
    local t = {}
    local sign = ""
    if num < 0 then
        sign = "-"
        num = -num
    end
    repeat
        local d = (num % base) + 1
        num = num // base
        insert(t, 1, digits:sub(d, d))
    until num == 0
    return sign .. table.concat(t, "")
end

---@param numStr string
---@param base number
function WC3Math.decodeBaseN(numStr, base)
    local digits = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!#$%&()*+,-./:;<=>?[\\]^_{|}~"
    local result = 0
    local currentPow = 1
    for i = numStr:len(), 1, -1 do
        local digit = numStr:sub(i, i)
        local decimalNumber = digits:find(digit, 1, true) - 1
        result = result + decimalNumber * currentPow
        currentPow = currentPow * base
    end
    return result
end

return WC3Math