--- @since 25.5.31

local config = require(".config")

local get_hovered = ya.sync(function()
    local hovered = cx.active.current.hovered
    if not hovered then return nil end

    return {
        is_dir = hovered.cha.is_dir,
        name = hovered.name,
    }
end)

local function handler_for(extension)
    for _, handler in ipairs(config.handlers) do
        for _, configured_extension in ipairs(handler.extensions) do
            if extension == configured_extension:lower():gsub("^%.", "") then
                return handler
            end
        end
    end

    return config.fallback
end

local function run(handler)
    ya.emit("shell", {
        handler.command,
        block = handler.block,
        orphan = handler.orphan,
    })
end

return {
    entry = function()
        local hovered = get_hovered()
        if not hovered then return end

        if hovered.is_dir then
            ya.emit("enter", {})
            return
        end

        local ext = hovered.name:match("%.([^.]+)$")
        ext = ext and ext:lower() or ""

        run(handler_for(ext))
    end,
}
