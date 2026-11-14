-- Ctrl+P：置顶 / 取消置顶当前高亮候选
-- 按在已置顶的词上 = 取消；按在别的词上 = 改置顶它
-- 只在候选窗开着时生效；同一编码只留一个置顶

local store = require("pin.store")

-- 把高亮拉回第一项。置顶项被移到第一位后，光标若留在原地，
-- 下次按 Ctrl+P 就会指到别的词上，看起来像「取消不了」
local function focus_first(context)
    pcall(function() context.menu:select(0) end)
end

local function processor(key, env)
    local repr = key:repr():lower()
    if key:release() or not key:ctrl() or not repr:match("p$") then
        return 2 -- kNoop
    end

    local context = env.engine.context
    if not context:is_composing() then return 2 end

    local cand = context:get_selected_candidate()
    if not cand then return 2 end

    local code, text = context.input, cand.text
    local pinned = store.get(code)
    print(string.format("[pin] code=%s cand=%s pinned=%s", code, text, tostring(pinned)))

    if pinned == text then
        store.clear(code)
    else
        store.set(code, text)
    end

    pcall(function() context:refresh_non_confirmed_composition() end)
    focus_first(context)
    return 1 -- kAccepted
end

return processor
