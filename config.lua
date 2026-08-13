return {
    handlers = {
        {
            extensions = { "md" },
            command = "glow -p %h",
            block = true,
        },
        {
            extensions = { "pdf" },
            command = "zathura %h",
            orphan = true,
        },
        {
            extensions = { "mp4", "mkv", "webm", "avi" },
            command = "mpv %h",
            block = true,
        },
    },

    fallback = {
        command = "${EDITOR:-vi} %h",
        block = true,
    },
}
