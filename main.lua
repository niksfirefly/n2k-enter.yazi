local get_target = ya.sync(function()
    local h = cx.active.current.hovered
    if not h then return nil end
    return {
        is_dir = h.cha.is_dir,
        name = h.name,
    }
end)

return {
    entry = function(self, job)
        local target = get_target()
        if not target then return end

        -- 1. Przejście do katalogu
        if target.is_dir then
            ya.manager_emit("enter", {})
            return
        end

        -- 2. Wyciągnięcie rozszerzenia
        local ext = target.name:match("%.([^.]+)$")
        ext = ext and ext:lower() or ""

        -- 3. Akcje dla konkretnych rozszerzeń
        if ext == "md" then
            ya.manager_emit("shell", { 'glow -p "$@"', block = true })
        elseif ext == "pdf" then
            ya.manager_emit("shell", { 'zathura "$@"', orphan = true })
        elseif ext == "mp4" or ext == "mkv" or ext == "webm" or ext == "avi" then
            ya.manager_emit("shell", { 'mpv "$@"', block = true })
        else
            -- Domyślny edytor dla pozostałych plików
            ya.manager_emit("shell", { '$EDITOR "$@"', block = true })
        end
    end,
}
