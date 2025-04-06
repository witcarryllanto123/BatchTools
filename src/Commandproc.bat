@echo off
title BatchTools Command Panel

:: Find and use the BatchTools directory as default.
if exist "C:\ProgramData\BatchToolsData" (
    cd /d "C:\ProgramData\BatchToolsData"
    echo Found BatchTools data's Path. (C:\ProgramData\BatchToolsData)
    goto main
)
if exist "%localappdata%\BatchToolsData" (
    echo -----------------------------------
    echo Found BatchTools data's alternative path (%localappdata%\BatchToolsData)
    echo -----------------------------------
    cd /d "%localappdata%\BatchToolsData"
) else (
    echo.
    echo Looks like both installation paths do not exist.
    echo The BatchTools installation may have failed.
    pause
    exit /b
)

:main
cls
echo BatchTools Command Panel
echo --------------------------------
echo Running computer:
echo %ComputerName%\%username%
echo --------------------------------
echo Working Directory:
echo %CD%
echo --------------------------------

:Command
echo.
set /p "comd=-$ "

:: Exit if user types 'exit'
if /I "%comd%"=="exit" (
    cd /d C:\
   exit /b
)    

:: Execute command
timeout /t 1 >nul 2>nul
echo.
echo System_Response: 
echo Command executed..
echo.
%comd%
timeout /t 2 >nul 2>nul
goto Command

:exit
pause
