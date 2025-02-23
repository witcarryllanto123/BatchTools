@echo off
setlocal enabledelayedexpansion

:: Check if running as administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrator privileges...
    powershell -Command "Start-Process cmd -ArgumentList '/c "%~fnx0"' -Verb RunAs"
    exit /b
)

:: Ensure the script is running in the correct working directory
cd /d "%~dp0"

:: Define installation directory
set "installPath=C:\ProgramData\BatchToolsData"
if not exist "%installPath%" mkdir "%installPath%" 2>nul
if not exist "%installPath%" (
    echo Failed to create directory in ProgramData. Using LocalAppData instead.
    set "installPath=%LocalAppData%\BatchToolsData"
    mkdir "%installPath%"
)

:: Ensure the installation path exists before proceeding
if not exist "%installPath%" (
    echo ERROR: Failed to create the installation directory!
    exit /b
)

:: Extract BatchTools.zip
if exist "BatchTools.zip" (
    echo Extracting files to "%installPath%"...
    powershell -Command "Expand-Archive -Path 'BatchTools.zip' -DestinationPath '%installPath%' -Force"
    if %errorlevel% neq 0 (
        echo ERROR: Failed to extract BatchTools.zip!
        exit /b
    ) else (
        echo Extraction completed successfully.
    )
) else (
    echo ERROR: BatchTools.zip not found!
    exit /b
)

:: Verify extracted files
if not exist "%installPath%\Tools.bat" (
    echo ERROR: The extraction failed! No main files were found.
    exit /b
)

:: Ensure Chocolatey is installed
where choco >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: Chocolatey is not installed. Please install Chocolatey first.
    exit /b
)

:: Install FFmpeg if not found
where ffmpeg >nul 2>nul
if %errorlevel% neq 0 (
    echo Installing FFmpeg...
    choco install ffmpeg -y
    where ffmpeg >nul 2>nul
    if %errorlevel% neq 0 (
        echo ERROR: FFmpeg installation failed!
        exit /b
    ) else (
        echo FFmpeg installed successfully.
    )
) else (
    echo FFmpeg is already installed.
)

:: Install yt-dlp
set "ytDlpPath=%installPath%\yt-dlp.exe"
if not exist "%ytDlpPath%" (
    echo Installing yt-dlp...
    pip install --upgrade yt-dlp
    set "pythonScripts=%LocalAppData%\Programs\Python\Python312\Scripts"
    if exist "%pythonScripts%\yt-dlp.exe" (
        copy "%pythonScripts%\yt-dlp.exe" "%ytDlpPath%" /Y
        echo yt-dlp installed successfully.
    ) else (
        echo ERROR: yt-dlp installation failed!
        exit /b
    )
) else (
    echo yt-dlp is already installed.
)

:: Detect actual Desktop path (OneDrive or Default)
for /f "usebackq tokens=2*" %%A in (`reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v Desktop 2^>nul`) do set "desktopPath=%%B"
if "%desktopPath%"=="" set "desktopPath=%UserProfile%\Desktop"

:: Create shortcut using PowerShell with icon support
powershell -ExecutionPolicy Bypass -NoProfile -Command " $s = (New-Object -ComObject WScript.Shell).CreateShortcut('%desktopPath%\Tools.lnk'); $s.TargetPath='%installPath%\Tools.bat'; $s.WorkingDirectory='%installPath%'; if (Test-Path '%installPath%\icon.ico') { $s.IconLocation='%installPath%\icon.ico' }; $s.Save()"

:: Verify shortcut was created
if exist "%desktopPath%\Tools.lnk" (
    echo Shortcut created successfully in %desktopPath%.
) else (
    echo ERROR: Failed to create shortcut!
)

echo Installation completed successfully.
pause
exit /b
