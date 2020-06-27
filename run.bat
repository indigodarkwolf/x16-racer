@echo off

set PROJECT=x16-racer
set EMU_DIR=..\..\vs2019\x16-bin

set EMU=.\x16emu_Release.exe

cd %EMU_DIR%
%EMU% -prg "%PROJECT%.prg" -debug -scale 2 -quality nearest