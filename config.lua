local video = {
    run = "smplayer %h",
    orphan = true,
}

local image = {
    run = "nomacs %h",
    orphan = true,
}

return {
    extensions = {
        mdbb = {
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
    mime = {},
}
