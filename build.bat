@echo off

set PROJECT=x16-racer
set EMU_DIR=..\..\vs2019\x16-bin

set OBJ_DIR=obj

set ASM=bin\cc65\bin\ca65.exe
set LNK=bin\cc65\bin\cl65.exe

:: Raw binaries

%ASM% -o tables/math_tables.o tables/math_tables.asm
%LNK% -o math_tables.seq tables/math_tables.o --target none

:: Executable

%ASM% -o %PROJECT%.o %PROJECT%.asm --cpu 65C02
%LNK% -o %PROJECT%.prg -DC64 %PROJECT%.o

copy math_tables.seq %EMU_DIR%
copy %PROJECT%.prg %EMU_DIR%
