@echo off
setlocal enabledelayedexpansion

:: Ensure script runs as administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrator privileges...
    powershell -Command "Start-Process cmd -ArgumentList '/c "%~fnx0"' -Verb RunAs"
    exit /b
)

:: Define installation directory
set "installPath=C:\ProgramData\BatchToolsData"
set "shortcutPath=%UserProfile%\OneDrive\Desktop\Tools.lnk"

:: Remove desktop shortcut
if exist "%shortcutPath%" (
    del "%shortcutPath%"
    echo Removed desktop shortcut.
) else (
    echo No desktop shortcut found.
)

:: Remove yt-dlp from BatchToolsData (but NOT from Python Scripts)
if exist "%installPath%\yt-dlp.exe" (
    del "%installPath%\yt-dlp.exe"
    echo Removed yt-dlp from BatchToolsData.
)

:: Remove the BatchToolsData directory
if exist "%installPath%" (
    rmdir /s /q "%installPath%"
    echo Removed BatchToolsData folder.
) else (
    echo No BatchToolsData folder found.
)

:: Keep FFmpeg installed

echo Uninstallation complete. FFmpeg and Python-installed yt-dlp remain installed.
pause
exit /b
