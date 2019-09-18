@echo off

set EMU_DIR=..\..\vs2019\bin
set ASM=bin\acme\acme.exe
set ASM_OPTS=-f cbm -DMACHINE_C64=0
set SYMBOLS=..\..\tools\acmesym\bin\Debug\acmesym.exe

::set LINK=bin\cc65\bin\cl65.exe
::set LINK_OPTS=

%ASM% %ASM_OPTS% -o x16-racer.prg x16-racer.asm
%SYMBOLS% x16-racer.sym

::%LINK% %LINK_OPTS -o x16-racer.prg x16-racer.obj

copy x16-racer.prg %EMU_DIR%
