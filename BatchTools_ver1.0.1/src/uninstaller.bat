@echo off
setlocal enabledelayedexpansion

:: Ensure script runs as administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrator privileges...
    powershell -Command "Start-Process cmd -ArgumentList '/c \"%~fnx0\"' -Verb RunAs"
    exit /b
)

:: Detect actual Desktop path (OneDrive or Default)
for /f "usebackq tokens=2*" %%A in (`reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v Desktop 2^>nul`) do set "desktopPath=%%B"
if "%desktopPath%"=="" set "desktopPath=%UserProfile%\Desktop"

:: Detect Start Menu path
for /f "usebackq tokens=2*" %%A in (`reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "Programs" 2^>nul`) do set "startMenuPath=%%B"
if "%startMenuPath%"=="" set "startMenuPath=%APPDATA%\Microsoft\Windows\Start Menu\Programs"

:: Define paths
set "installPath=C:\ProgramData\BatchToolsData"
set "shortcutPath=%desktopPath%\Tools.lnk"
set "shortcutProgPath=%startMenuPath%\Tools.lnk"

:: Remove desktop shortcut
if exist "%shortcutPath%" (
    del "%shortcutPath%"
    echo Removed desktop shortcut.
) else (
    echo No desktop shortcut found.
)

:: Remove Start Menu shortcut
if exist "%shortcutProgPath%" (
    del "%shortcutProgPath%"
    echo Removed Start Menu shortcut.
) else (
    echo No Start Menu shortcut found.
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
