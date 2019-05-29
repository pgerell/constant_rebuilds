@echo off
setlocal

set BUILD_DIR=vs19-win64-build
set GENERATOR=-G "Visual Studio 16 2019" -A x64

mkdir %BUILD_DIR%
cd %BUILD_DIR%

@echo on
cmake %GENERATOR% ..\src
@if %ERRORLEVEL% NEQ 0 exit /B 1

:: Stay in folder if everything was successful
@endlocal & cd %cd%
