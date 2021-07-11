local TextUtils = {}

---@param str string
---@param color number
function TextUtils.colorText(str, color, i, j)
    i = i or 1
    j = j or str:len()
    local prefix = i == 1 and "" or str:sub(1, i - 1)
    local suffix = j == str:len() and "" or str:sub(j + 1)
    local substr = str:sub(i, j)
    return string.format("%s|c%x%s|r%s", prefix, color, substr, suffix)
end

---@param int number
function TextUtils.intToARGB(int)
    return int >> 24, (int >> 16) & 0xff, (int >> 8) & 0xff, int & 0xff
end

return TextUtils