@echo off
set EMU_DIR=..\..\vs2019\x16-bin
::set EMU=.\x16emu_Release.exe
set EMU=.\x16emu_Release_YM2151.exe

cd %EMU_DIR%
%EMU% -prg "x16-racer.prg" -debug -scale 2 -quality nearest