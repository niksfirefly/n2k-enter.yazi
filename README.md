# n2k-enter

Plugin dla menedżera plików [Yazi](https://yazi-rs.github.io/).

## Instalacja

```bash
ya pack -a niksfirefly/n2k-enter
```

## Konfiguracja rozszerzeń

Ustawienia domyślne znajdują się w `config.lua`. Własne ustawienia należy
umieścić w opcjonalnym pliku `~/.local/state/yazi/n2k-enter.lua` (lub
`$XDG_STATE_HOME/yazi/n2k-enter.lua`, gdy zmienna jest ustawiona):

```lua
return {
    extensions = {
        md = {
            run = "bat %h",
            block = true,
        },
        [".jpg"] = {
            run = "imv %h",
            orphan = true,
        },
    },
}
```

Rozszerzenia można podawać z kropką lub bez niej i bez względu na wielkość
liter. `%h` jest zastępowane przez Yazi bezpiecznie zacytowaną ścieżką pliku
pod kursorem.

Konfiguracja użytkownika jest sumowana z domyślną. Wpis użytkownika ma
pierwszeństwo tylko dla podanego rozszerzenia, więc niewymienione rozszerzenia
(np. `md`) nadal korzystają z ustawień domyślnych. Opcjonalnie można nadpisać
również akcję dla nierozpoznanych rozszerzeń:

```lua
return {
    extensions = {},
    fallback = {
        run = "${EDITOR:-vi} %h",
        block = true,
    },
}
```

Zmiany konfiguracji są wczytywane przy uruchomieniu Yazi.
