@echo off

set PROJECT=x16-racer
set EMU_DIR=..\..\vs2019\x16-bin
set ASM=bin\cc65\bin\cl65.exe

%ASM% -o %PROJECT%.prg -DC64 %PROJECT%.asm -m %PROJECT%.map -g -l %PROJECT%.list

copy %PROJECT%.prg %EMU_DIR%
