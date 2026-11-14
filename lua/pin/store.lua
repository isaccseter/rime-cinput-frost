-- 置顶数据的存取
-- 存在用户目录的 pin_cand.txt，每行「编码<TAB>词条」
-- 读写都直接走文件：量很小，省掉跨组件共享缓存的麻烦

local M = {}

local path = rime_api.get_user_data_dir() .. "/pin_cand.txt"

local function read()
    local pins = {}
    local f = io.open(path, "r")
    if not f then return pins end

    for line in f:lines() do
        local code, text = line:match("^(%S+)\t(.+)$")
        if code then pins[code] = text end
    end
    f:close()
    return pins
end

local function write(pins)
    local out = io.open(path, "w")
    if not out then return end

    local codes = {}
    for code in pairs(pins) do codes[#codes + 1] = code end
    table.sort(codes)

    for _, code in ipairs(codes) do
        out:write(code, "\t", pins[code], "\n")
    end
    out:close()
end

function M.get(code)
    return read()[code]
end

function M.set(code, text)
    local pins = read()
    pins[code] = text
    write(pins)
end

function M.clear(code)
    local pins = read()
    pins[code] = nil
    write(pins)
end

return M
