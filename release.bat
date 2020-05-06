@echo off

set PROJECT=x16-racer
set EMU_DIR=..\..\vs2019\x16-bin

set OBJ_DIR=obj
set BUILD_DIR=build
set RELEASE_DIR=release

set ZIP_DIR="B:\Program Files\7-zip"

:: Cleanup

del %RELEASE_DIR%\%PROJECT%.tar
del %RELEASE_DIR%\%PROJECT%.7z
del %RELEASE_DIR%\%PROJECT%.zip
del %RELEASE_DIR%\%PROJECT%.tar.gz
del %RELEASE_DIR%\%PROJECT%.tar.bz2

:: Archives

tar -cvf %RELEASE_DIR%\%PROJECT%.tar %BUILD_DIR%\*
%ZIP_DIR%\7z.exe a -t7z %RELEASE_DIR%\%PROJECT%.7z %BUILD_DIR%\*
%ZIP_DIR%\7z.exe a -tzip %RELEASE_DIR%\%PROJECT%.zip %BUILD_DIR%\*
%ZIP_DIR%\7z.exe a -tgzip %RELEASE_DIR%\%PROJECT%.tar.gz %RELEASE_DIR%\%PROJECT%.tar
%ZIP_DIR%\7z.exe a -tbzip2 %RELEASE_DIR%\%PROJECT%.tar.bz2 %RELEASE_DIR%\%PROJECT%.tar
