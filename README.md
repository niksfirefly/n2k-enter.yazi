# n2k-enter

Plugin dla menedżera plików [Yazi](https://yazi-rs.github.io/).

## Instalacja

```bash
ya pack -a niksfirefly/n2k-enter
```

## Konfiguracja rozszerzeń i MIME

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
    mime = {
        {
            mime = "application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}",
            plugin = "augment-command.open",
        },
        {
            mime = "image/*",
            run = "imv %h",
            orphan = true,
        },
    },
}
```

Rozszerzenia można podawać z kropką lub bez niej i bez względu na wielkość
liter. Wzorce MIME obsługują dokładne wartości, `*` oraz alternatywy
`{a,b,c}`. Reguły MIME są sprawdzane od góry i wygrywa pierwsze dopasowanie.
Prefiksy podtypów `x-` i `vnd.` są normalizowane tak jak w
`augment-command`, np. `application/x-7z-compressed` pasuje do
`application/7z*`.
`%h` jest zastępowane przez Yazi bezpiecznie zacytowaną ścieżką pliku pod
kursorem.

Akcja może wskazywać polecenie powłoki przez `run` albo inny plugin Yazi przez
`plugin`. Opcjonalne `args` są przekazywane jako argumenty pluginu:

```lua
{
    mime = "application/zip",
    plugin = "augment-command.open",
    -- args = "--interactive",
}
```

Delegowanie archiwów do `augment-command.open` zachowuje jego pełny mechanizm:
dobór extractora, unikalny katalog docelowy, obsługę kolizji i haseł,
rekurencyjne rozpakowywanie oraz przejście do rozpakowanego katalogu. Wymaga
zainstalowanego i skonfigurowanego pluginu `augment-command.yazi` z opcją
`enter_archives = true`.

Konfiguracja użytkownika jest sumowana z domyślną. Wpis użytkownika ma
pierwszeństwo, ale niewymienione reguły nadal korzystają z ustawień
domyślnych. Kolejność dopasowania to:

1. rozszerzenie użytkownika,
2. MIME użytkownika,
3. rozszerzenie domyślne,
4. MIME domyślne,
5. `fallback` lub natywne `open` Yazi.

Plugin najpierw korzysta z MIME obliczonego przez Yazi. Jeśli nie jest ono
jeszcze dostępne, uruchamia `${YAZI_FILE_ONE:-file} -bL --mime-type`. Program
`file` nie jest uruchamiany, gdy wcześniejsza reguła rozszerzenia wystarczy do
wyboru akcji lub nie ma żadnych reguł MIME do sprawdzenia.

Jeśli plik nie pasuje do żadnej reguły, wykonywana jest natywna akcja `open`
Yazi dla pliku pod kursorem. Yazi dobiera wtedy program na podstawie reguł
`[open]` i `[opener]` z `yazi.toml`. Opcjonalnie można zastąpić to zachowanie
własnym poleceniem `fallback`:

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
