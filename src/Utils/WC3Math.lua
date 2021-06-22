local WC3Math = {}

function WC3Math.getRectArea(rect)
    return (GetRectMaxX(rect) - GetRectMinX(rect)) * (GetRectMaxY(rect) - GetRectMinY(rect))
end

function WC3Math.distanceBetweenPoints(ax, ay, bx, by)
    local dx = bx - ax
    local dy = by - ay
    return math.sqrt(dx * dx + dy * dy)
end

function WC3Math.angleBetweenPoints(ax, ay, bx, by)
    return math.deg(math.atan(by - ay, bx - ax))
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
        num = floor(num / base)
        insert(t, 1, digits:sub(d, d))
    until num == 0
    return sign .. table.concat(t, "")
end

return WC3Math