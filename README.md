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

Yazi nie obsługuje skryptów wykonywanych bezpośrednio podczas `ya pkg add` ani
`ya pkg upgrade`. Plugin automatycznie tworzy ten plik z przykładowym szkieletem
przy pierwszym użyciu po instalacji lub aktualizacji, jeśli plik jeszcze nie
istnieje. Istniejąca konfiguracja użytkownika nigdy nie jest nadpisywana.

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
(np. `md`) nadal korzystają z ustawień domyślnych.

Jeśli rozszerzenie nie występuje ani w konfiguracji użytkownika, ani w
domyślnej konfiguracji pluginu, wykonywana jest natywna akcja `open` Yazi dla
pliku pod kursorem. Yazi dobiera wtedy program na podstawie reguł `[open]` i
`[opener]` z `yazi.toml`. Opcjonalnie można zastąpić to zachowanie własnym
poleceniem `fallback`:

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
