return {
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

    -- Opcjonalne nadpisanie akcji dla nierozpoznanych rozszerzeń:
    -- fallback = {
    --     run = "${EDITOR:-vi} %h",
    --     block = true,
    -- },
}
