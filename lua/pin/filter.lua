-- 置顶候选的排序与标记
-- 单字母：只留 pin_cand_filter 默认表里的候选
-- 其它：把该编码的置顶候选提到第一位，并在注释末尾打上 📌

local store = require("pin.store")

local MARK = "📌"

-- 生成带标记的替身，不改原候选：候选对象会被复用，改了就擦不掉
local function marked(cand)
    local comment = cand.comment or ""
    return Candidate(cand.type, cand.start, cand._end, cand.text,
                     comment == "" and MARK or comment .. " " .. MARK)
end

local function filter(input, env)
    local ctx = env.engine.context
    local code = ctx.input
    local target = ctx:get_option("pin_cand") and store.get(code)

    -- 常见的按键：没有置顶、也不是单字母，直接透传，不建表
    if not target and #code ~= 1 then
        for cand in input:iter() do yield(cand) end
        return
    end

    local list = {}
    for cand in input:iter() do list[#list + 1] = cand end

    -- 单字母：只留默认表里的词，挡掉自动补全的单字
    if #code == 1 then
        local hit = false
        for _, cand in ipairs(list) do
            if cand.type == "pin_cand" then
                if cand.text == target then
                    yield(marked(cand))
                else
                    yield(cand)
                end
                hit = true
            end
        end
        if hit then return end
    end

    -- 置顶的提到第一位
    for i, cand in ipairs(list) do
        if cand.text == target then
            yield(marked(cand))
            table.remove(list, i)
            break
        end
    end

    for _, cand in ipairs(list) do yield(cand) end
end

return filter
