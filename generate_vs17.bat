@echo off
setlocal

set BUILD_DIR=vs17-win64-build
set GENERATOR=-G "Visual Studio 15 2017 Win64"

mkdir %BUILD_DIR%
cd %BUILD_DIR%

@echo on
cmake %GENERATOR%  ..\src
@if %ERRORLEVEL% NEQ 0 exit /B 1

:: Stay in folder if everything was successful
@endlocal & cd %cd%
