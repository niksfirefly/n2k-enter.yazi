local video = {
    run = "mpv %h",
    block = true,
}

return {
    extensions = {
        md = {
            run = "glow -p %h",
            block = true,
        },
        pdf = {
            run = "zathura %h",
            orphan = true,
        },
        mp4 = video,
        mkv = video,
        webm = video,
        avi = video,
    },
    fallback = {
        run = "${EDITOR:-vi} %h",
        block = true,
    },
}
