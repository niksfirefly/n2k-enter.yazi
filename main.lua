return {
    entry = function()
        local h = cx.active.current.hovered
        if not h then return end

        -- 1. Wejście do katalogu
        if h.cha.is_dir then
            ya.manager_emit("enter", {})
            return
        end

        -- Pobranie rozszerzenia pliku
        local ext = h.name:match("%.([^.]+)$")
        ext = ext and ext:lower() or ""

        -- 2. Akcje według rozszerzenia
        if ext == "md" then
            ya.manager_emit("shell", { "glow -p \"$@\"", block = true })

        elseif ext == "pdf" then
            ya.manager_emit("shell", { "zathura \"$@\"", orphan = true })

        elseif ext == "mp4" or ext == "mkv" or ext == "webm" or ext == "avi" then
            ya.manager_emit("shell", { "mpv \"$@\"", block = true })

        else
            -- Domyślne otwarcie w edytorze
            ya.manager_emit("shell", { "$EDITOR \"$@\"", block = true })
        end
    end,
}
