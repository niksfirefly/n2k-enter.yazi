--- @since 25.5.31
--- @sync entry

return {
    entry = function()
        local hovered = cx.active.current.hovered
        if not hovered then return end

        if hovered.cha.is_dir then
            ya.emit("enter", {})
            return
        end

        local ext = hovered.name:match("%.([^.]+)$")
        ext = ext and ext:lower() or ""

        if ext == "md" then
            ya.emit("shell", { "glow -p %h", block = true })
        elseif ext == "pdf" then
            ya.emit("shell", { "zathura %h", orphan = true })
        elseif ext == "mp4" or ext == "mkv" or ext == "webm" or ext == "avi" then
            ya.emit("shell", { "mpv %h", block = true })
        else
            ya.emit("shell", { "${EDITOR:-vi} %h", block = true })
        end
    end,
}
