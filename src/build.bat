@echo off
rem Builds SW2FrenchFont.asi with Zig 0.17 (pip install ziglang==0.17.0)
python -m ziglang cc -target x86-windows-gnu -O2 -s -shared -o SW2FrenchFont.asi sw2font.c version.rc -lkernel32 -luser32 -Wl,--subsystem,windows
