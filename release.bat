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

cd %~dp0\%BUILD_DIR%
tar -cvf %~dp0\%RELEASE_DIR%\%PROJECT%.tar *
%ZIP_DIR%\7z.exe a -t7z %~dp0\%RELEASE_DIR%\%PROJECT%.7z *
%ZIP_DIR%\7z.exe a -tzip %~dp0\%RELEASE_DIR%\%PROJECT%.zip *
cd %~dp0\%RELEASE_DIR%
%ZIP_DIR%\7z.exe a -tgzip %PROJECT%.tar.gz  %PROJECT%.tar
%ZIP_DIR%\7z.exe a -tbzip2 %PROJECT%.tar.bz2  %PROJECT%.tar