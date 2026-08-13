--- @since 25.5.31

local default_config = require(".config")

local function normalize_extension(extension)
    return tostring(extension):lower():gsub("^%.", "")
end

local function user_config_path()
    local state_home = os.getenv("XDG_STATE_HOME")
    if state_home and state_home ~= "" then
        return state_home .. "/yazi/n2k-enter.lua"
    end

    local home = os.getenv("HOME")
    return home and home .. "/.local/state/yazi/n2k-enter.lua" or nil
end

local function load_user_config()
    local path = user_config_path()
    if not path then return nil end

    local file = io.open(path, "r")
    if not file then return nil end
    file:close()

    local chunk, load_error = loadfile(path, "t", {})
    if not chunk then
        ya.err("n2k-enter: nie można wczytać " .. path .. ": " .. tostring(load_error))
        return nil
    end

    local ok, user_config = pcall(chunk)
    if not ok or type(user_config) ~= "table" then
        ya.err("n2k-enter: nieprawidłowa konfiguracja w " .. path)
        return nil
    end

    return user_config
end

local function merged_config()
    local merged = {
        extensions = {},
        fallback = default_config.fallback,
    }

    for extension, handler in pairs(default_config.extensions or {}) do
        merged.extensions[normalize_extension(extension)] = handler
    end

    local user_config = load_user_config()
    if not user_config then return merged end

    for extension, handler in pairs(user_config.extensions or {}) do
        if type(handler) == "table" and type(handler.run) == "string" then
            merged.extensions[normalize_extension(extension)] = handler
        end
    end

    if type(user_config.fallback) == "table" and type(user_config.fallback.run) == "string" then
        merged.fallback = user_config.fallback
    end

    return merged
end

local config = merged_config()

local get_hovered = ya.sync(function()
    local hovered = cx.active.current.hovered
    if not hovered then return nil end

    return {
        is_dir = hovered.cha.is_dir,
        name = hovered.name,
    }
end)

local function handler_for(extension)
    return config.extensions[normalize_extension(extension)] or config.fallback
end

local function run(handler)
    ya.emit("shell", {
        handler.run,
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
