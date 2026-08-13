# n2k-enter

Plugin dla menedżera plików [Yazi](https://yazi-rs.github.io/).

## Instalacja

```bash
ya pack -a niksfirefly/n2k-enter
```

## Konfiguracja rozszerzeń

Obsługiwane rozszerzenia i przypisane do nich programy znajdują się w
`config.lua`. Aby dodać kolejne rozszerzenia, dopisz nową regułę do
`handlers`:

```lua
{
    extensions = { "jpg", "jpeg", "png" },
    command = "imv %h",
    orphan = true,
},
```

Rozszerzenia można podawać z kropką lub bez niej i bez względu na wielkość
liter. `%h` jest zastępowane przez Yazi bezpiecznie zacytowaną ścieżką pliku
pod kursorem. Reguła `fallback` jest używana dla plików bez pasującej
konfiguracji.
