return { content = [[return {
    extensions = {
        -- Wpis użytkownika zastępuje ustawienie domyślne dla rozszerzenia.
        -- md = {
        --     run = "bat %h",
        --     block = true,
        -- },

        -- Nowe rozszerzenie jest dodawane do ustawień domyślnych.
        -- [".jpg"] = {
        --     run = "imv %h",
        --     orphan = true,
        -- },
    },

    -- Reguły MIME są sprawdzane od góry; wygrywa pierwsze dopasowanie.
    mime = {
        -- {
        --     mime = "application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}",
        --     plugin = "augment-command.open",
        -- },
        -- {
        --     mime = "image/*",
        --     run = "imv %h",
        --     orphan = true,
        -- },
    },

    -- Opcjonalne nadpisanie akcji dla nierozpoznanych rozszerzeń:
    -- fallback = {
    --     run = "${EDITOR:-vi} %h",
    --     block = true,
    -- },
}
]], }
