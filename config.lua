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
        lua = {
            run = "${EDITOR:-micro} %h",
            block = true,
        },
        toml = {
            run = "${EDITOR:-micro} %h",
            block = true,
        },
        mdbb = {
            run = "glow -p %h",
            block = true,
        },
        pdf = {
            run = "zathura %h",
            orphan = true,
        },
        mp4 = microdeo,
        mkv = microdeo,
        webm = microdeo,
        amicro = microdeo,
    },
    mime = {
        {
            mime = "text/*",
            run = "${EDITOR:-micro} %h",
            block = true,
        },
    },
}
