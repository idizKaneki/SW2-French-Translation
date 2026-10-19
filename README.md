# Samurai Warriors 2 (PC) - French Translation

Source of the Nexus Mods release
[Traduction française complète](https://www.nexusmods.com/samuraiwarriors2/mods/6).

The mod contains no game files. The translation is a set of binary patches (xdelta3) applied
by `INSTALL.bat` to the user's own copy of the game; the original files are backed up and put
back by `UNINSTALL.bat`.

## Files

| Path | Role |
|---|---|
| `INSTALL.bat`, `UNINSTALL.bat` | Installer / uninstaller (plain text) |
| `readme.txt` | User readme (English / French) |
| `src/sw2font.c`, `src/version.rc` | Source of `SW2FrenchFont.asi` (accent spacing) |

In the release zip, `tools/xdelta3.exe` is the unmodified
[xdelta3](https://github.com/jmacd/xdelta) binary, and `files/dinput8.dll` is the unmodified
[Ultimate ASI Loader](https://github.com/ThirteenAG/Ultimate-ASI-Loader) by ThirteenAG (MIT).

## SW2FrenchFont.asi

Loaded by the ASI loader. Works **in memory only** (sw2.exe is never modified): once the game
is running, it finds the advance-width table of the game's text font (96 bytes) and, if it
matches the original table, gives each sign used for a French accented letter the width of
its base letter (e.g. the '<' slot used for "î" gets the width of "i").
No hooks, no network access; the only file written is `SW2FrenchFont.log`.

### Build

32-bit Windows DLL renamed `.asi`, built with [Zig](https://ziglang.org) 0.17
(`pip install ziglang==0.17.0`):

```
cd src
build.bat      (Windows)
./build.sh     (Linux / macOS)
```

## License

MIT (see `LICENSE`) for the scripts and the plugin source.
Samurai Warriors 2 (c) Koei Tecmo / Omega Force. Unofficial fan project.
