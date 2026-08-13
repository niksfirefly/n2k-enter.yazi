--- @since 25.5.31

local default_config = require(".config")
local user_config_template = require(".user-config-template").content

local function normalize_extension(extension)
    return tostring(extension):lower():gsub("^%.", "")
end

local function normalize_mime(mime)
    local normalized = tostring(mime):lower():match("^%s*([^;%s]+)") or ""
    normalized = normalized:gsub("^(%a+/)x%-", "%1")
    normalized = normalized:gsub("^(%a+/)vnd%.", "%1")
    return normalized
end

local function expand_braces(pattern)
    local opening = pattern:find("{", 1, true)
    if not opening then return { pattern } end

    local closing = pattern:find("}", opening + 1, true)
    if not closing then return { pattern } end

    local expanded = {}
    local prefix = pattern:sub(1, opening - 1)
    local suffix = pattern:sub(closing + 1)

    for alternative in pattern:sub(opening + 1, closing - 1):gmatch("[^,]+") do
        for _, value in ipairs(expand_braces(prefix .. alternative .. suffix)) do
            table.insert(expanded, value)
        end
    end

    return expanded
end

local LUA_PATTERN_MAGIC = {
    ["^"] = true,
    ["$"] = true,
    ["("] = true,
    [")"] = true,
    ["%"] = true,
    ["."] = true,
    ["["] = true,
    ["]"] = true,
    ["+"] = true,
    ["-"] = true,
    ["?"] = true,
}

local function glob_to_lua_pattern(glob)
    local parts = { "^" }

    for index = 1, #glob do
        local character = glob:sub(index, index)
        if character == "*" then
            table.insert(parts, ".*")
        elseif LUA_PATTERN_MAGIC[character] then
            table.insert(parts, "%" .. character)
        else
            table.insert(parts, character)
        end
    end

    table.insert(parts, "$")
    return table.concat(parts)
end

local function mime_matches(mime, glob)
    mime = normalize_mime(mime)

    for _, expanded in ipairs(expand_braces(tostring(glob):lower())) do
        if mime:match(glob_to_lua_pattern(expanded)) then return true end
    end

    return false
end

local function user_config_path()
    local state_home = os.getenv("XDG_STATE_HOME")
    if state_home and state_home ~= "" then
        return state_home .. "/yazi/n2k-enter.lua"
    end

    local home = os.getenv("HOME")
    return home and home .. "/.local/state/yazi/n2k-enter.lua" or nil
end

local function ensure_user_config()
    local path = user_config_path()
    if not path then return nil end

    local url = Url(path)
    local directory_created, directory_error = fs.create("dir_all", url.parent)
    if not directory_created then
        ya.err("n2k-enter: nie można utworzyć katalogu konfiguracji: " .. tostring(directory_error))
        return path
    end

    local file, open_error = fs.access():write(true):create_new(true):open(url)
    if not file then
        if not open_error or open_error.kind ~= "AlreadyExists" then
            ya.err("n2k-enter: nie można utworzyć " .. path .. ": " .. tostring(open_error))
        end
        return path
    end

    local written, write_error = file:write_all(user_config_template)
    if not written then
        ya.err("n2k-enter: nie można zapisać " .. path .. ": " .. tostring(write_error))
        return path
    end

    local flushed, flush_error = file:flush()
    if not flushed then
        ya.err("n2k-enter: nie można zapisać " .. path .. ": " .. tostring(flush_error))
    end

    return path
end

local function load_user_config()
    local path = ensure_user_config()
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

    -- Compatibility with the broken template installed by version 0.5.0,
    -- which wrapped the actual configuration in a `content` string.
    if type(user_config.content) == "string" then
        local legacy_chunk, legacy_error = load(user_config.content, "@" .. path, "t", {})
        if not legacy_chunk then
            ya.err("n2k-enter: nie można wczytać starej konfiguracji: " .. tostring(legacy_error))
            return nil
        end

        local legacy_ok, legacy_config = pcall(legacy_chunk)
        if not legacy_ok or type(legacy_config) ~= "table" then
            ya.err("n2k-enter: nieprawidłowa stara konfiguracja w " .. path)
            return nil
        end

        user_config = legacy_config
    end

    return user_config
end

local function valid_handler(handler)
    return type(handler) == "table"
        and (type(handler.run) == "string" or type(handler.plugin) == "string")
end

local function copy_extensions(extensions)
    local result = {}

    for extension, handler in pairs(extensions or {}) do
        if valid_handler(handler) then
            result[normalize_extension(extension)] = handler
        end
    end

    return result
end

local function copy_mime_rules(rules)
    local result = {}

    for _, rule in ipairs(rules or {}) do
        if valid_handler(rule) and type(rule.mime) == "string" then
            table.insert(result, rule)
        end
    end

    return result
end

local function build_config()
    local config = {
        user_extensions = {},
        user_mime = {},
        default_extensions = copy_extensions(default_config.extensions),
        default_mime = copy_mime_rules(default_config.mime),
        fallback = valid_handler(default_config.fallback) and default_config.fallback or nil,
    }

    local user_config = load_user_config()
    if not user_config then return config end

    config.user_extensions = copy_extensions(user_config.extensions)
    config.user_mime = copy_mime_rules(user_config.mime)

    if valid_handler(user_config.fallback) then
        config.fallback = user_config.fallback
    end

    return config
end

local config

local get_hovered = ya.sync(function()
    local hovered = cx.active.current.hovered
    if not hovered then return nil end

    return {
        is_dir = hovered.cha.is_dir,
        mime = hovered:mime(),
        name = hovered.name,
        path = tostring(hovered.url.path),
    }
end)

local function detect_mime(hovered)
    local mime = normalize_mime(hovered.mime or "")
    if mime ~= "" then return mime end

    local file_command = os.getenv("YAZI_FILE_ONE")
    if not file_command or file_command == "" then file_command = "file" end

    local output = Command(file_command)
        :arg({ "-bL", "--mime-type", hovered.path })
        :stdout(Command.PIPED)
        :stderr(Command.PIPED)
        :output()

    return output and normalize_mime(output.stdout) or ""
end

local function handler_for_mime(rules, mime)
    for _, rule in ipairs(rules) do
        if mime_matches(mime, rule.mime) then return rule end
    end

    return nil
end

local function handler_for(hovered)
    local extension = hovered.name:match("%.([^.]+)$")
    extension = normalize_extension(extension or "")

    local handler = config.user_extensions[extension]
    if handler then return handler end

    local mime
    if #config.user_mime > 0 then
        mime = detect_mime(hovered)
        handler = handler_for_mime(config.user_mime, mime)
        if handler then return handler end
    end

    handler = config.default_extensions[extension]
    if handler then return handler end

    if #config.default_mime > 0 then
        mime = mime or detect_mime(hovered)
        handler = handler_for_mime(config.default_mime, mime)
        if handler then return handler end
    end

    return config.fallback
end

local function run(handler)
    if not handler then
        ya.emit("open", { hovered = true })
        return
    end

    if handler.plugin then
        ya.emit("plugin", { handler.plugin, handler.args })
    else
        ya.emit("shell", {
            handler.run,
            block = handler.block,
            orphan = handler.orphan,
        })
    end
end

return {
    entry = function()
        config = config or build_config()

        local hovered = get_hovered()
        if not hovered then return end

        if hovered.is_dir then
            ya.emit("enter", {})
            return
        end

        run(handler_for(hovered))
    end,
}
