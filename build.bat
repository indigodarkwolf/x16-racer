@echo off

set PROJECT=x16-racer
set EMU_DIR=..\..\vs2019\x16-bin
set ASM=bin\cc65\bin\cl65.exe
set DEBUG_OPTS=-vm -m %PROJECT%.map -g -l %PROJECT%.list -Wl --dbgfile,%PROJECT%.dbg

%ASM% -o %PROJECT%.prg -DC64 %PROJECT%.asm

copy %PROJECT%.prg %EMU_DIR%
