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
for /f "tokens=2*" %%A in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v Desktop 2^>nul') do set "desktopPath=%%B"
if not defined desktopPath set "desktopPath=%UserProfile%\Desktop"

:: Detect Start Menu path
for /f "tokens=2*" %%A in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "Programs" 2^>nul') do set "startMenuPath=%%B"
if not defined startMenuPath set "startMenuPath=%APPDATA%\Microsoft\Windows\Start Menu\Programs"

:: Define paths
set "installPath=C:\Program Files\BatchTools"
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

:: Remove yt-dlp from BatchToolsData (confirm with user)
if exist "%installPath%\yt-dlp.exe" (
    echo Found yt-dlp in BatchToolsData. Do you want to remove it? (Y/N)
    choice /c YN /n /m "Enter choice: "
    if errorlevel 2 (
        echo Skipping yt-dlp removal.
        if not exist "C:\\Program Files\\YTDLP" (
            mkdir "C:\\Program Files\\YTDLP"
            copy "%installPath%\yt-dlp.exe" "C:\\Program Files\\YTDLP"
            echo Copied yt-dlp to C:\progtram files\YTDLP
            setx PATH "%PATH%;C:\Progarm Files\YTDLP" /M
            echo Added yt-dlp to system PATH.
            echo Yt-dlp will be available on the command line.
        )
    ) else (
        del "%installPath%\yt-dlp.exe"
        echo Removed yt-dlp from BatchToolsData.
    )
)

:: Remove the BatchToolsData directory (confirm with user)
if exist "%installPath%" (
    echo WARNING: This will delete BatchToolsData permanently. Proceed? (Y/N)
    choice /c YN /n /m "Enter choice: "
    if errorlevel 2 (
        echo Skipping BatchTools removal.
    ) else (
        rmdir /s /q "%installPath%"
        echo Removed BatchTool folder.
    )
) else (
    echo No BatchToolsData folder found.
)

:: Keep FFmpeg installed
echo Uninstallation complete. FFmpeg and Python-installed yt-dlp remain installed.
pause
exit /b
