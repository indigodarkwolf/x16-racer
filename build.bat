@echo off

set PROJECT=x16-racer
set EMU_DIR=..\..\vs2019\x16-bin

set SRC_DIR=src
set OBJ_DIR=obj
set BUILD_DIR=build

set ASM=bin\cc65\bin\ca65.exe
set LNK=bin\cc65\bin\cl65.exe

:: Raw binaries

%ASM% -o %OBJ_DIR%/math_tables.o %SRC_DIR%/tables/math_tables.asm
%LNK% -o %BUILD_DIR%/math_tables.seq %OBJ_DIR%/math_tables.o --target none

%ASM% -o %OBJ_DIR%/graphics_tables.o %SRC_DIR%/tables/graphics_tables.asm
%LNK% -o %BUILD_DIR%/graphics_tables.seq %OBJ_DIR%/graphics_tables.o --target none

:: Executable

%ASM% -o %OBJ_DIR%/%PROJECT%.o %SRC_DIR%/%PROJECT%.asm --cpu 65C02
%LNK% -o %BUILD_DIR%/%PROJECT%.prg -DC64 %OBJ_DIR%/%PROJECT%.o

copy %BUILD_DIR%\*.* %EMU_DIR%\