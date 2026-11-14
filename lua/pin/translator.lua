-- 单字母输入的候选
-- 按 pin_cand_filter 的默认表出词，格式：字母<TAB>词条1 词条2 ……

local defaults = nil

local function load(env)
    local t = {}
    local list = env.engine.schema.config:get_list("pin_cand_filter")
    if not list then return t end

    for i = 0, list.size - 1 do
        local code, words = list:get_value_at(i).value:match("^(%S+)\t(.+)$")
        if code then
            t[code] = {}
            for word in words:gmatch("%S+") do
                t[code][#t[code] + 1] = word
            end
        end
    end
    return t
end

local function translator(input, seg, env)
    if #input ~= 1 or not env.engine.context:get_option("pin_cand") then return end

    defaults = defaults or load(env)
    local words = defaults[input]
    if not words then return end

    for _, word in ipairs(words) do
        yield(Candidate("pin_cand", seg.start, seg._end, word, ""))
    end
end

return translator
