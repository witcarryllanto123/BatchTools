@echo off
setlocal enabledelayedexpansion

:: Ensure script runs as administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrator privileges...
    powershell -Command "Start-Process '%~fnx0' -Verb RunAs -Wait"
    exit /b
)

:: Ensure script runs in the correct working directory
cd /d "%~dp0"

:: Proceed with installation...
echo Installing BatchTools...
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

:: Check if Python is installed system-wide
where python >nul 2>nul
if %errorlevel% neq 0 (
    echo Python is not installed. Installing Python system-wide...
    winget install Python.Python.3
    where python >nul 2>nul
    if %errorlevel% neq 0 (
        echo ERROR: Python installation failed!
        exit /b
    ) else (
        echo Python installed successfully.
    )
) else (
    echo Python is already installed.
)

:: Install yt-dlp using Python
set "ytDlpPackagePath=C:\Users\%USERNAME%\AppData\Roaming\Python\Python312\site-packages\yt_dlp"
set "ytDlpScriptsPath=C:\Users\%USERNAME%\AppData\Roaming\Python\Python312\Scripts\yt-dlp.exe"
set "ytDlpDestPath=%installPath%\yt-dlp.exe"

:: Check if yt-dlp is already installed in site-packages
if exist "%ytDlpPackagePath%" (
    echo yt-dlp package found in site-packages.
) else (
    echo yt-dlp is not installed. Installing...
    "%pythonExec%" -m pip install --no-warn-script-location --upgrade yt-dlp
)

:: Check if yt-dlp.exe is in Scripts and copy it
if exist "%ytDlpScriptsPath%" (
    echo yt-dlp.exe found in Scripts folder.
    copy "%ytDlpScriptsPath%" "%ytDlpDestPath%" /Y
    if exist "%ytDlpDestPath%" (
        echo yt-dlp installed successfully in BatchToolsData.
    ) else (
        echo ERROR: Failed to copy yt-dlp.exe to BatchToolsData.
        exit /b
    )
) else (
    echo ERROR: yt-dlp.exe not found after installation!
    echo Please check Python installation and manually install yt-dlp.
    exit /b
)


:: Check if Chocolatey is installed
where choco >nul 2>nul
if %errorlevel% neq 0 (
    echo Chocolatey is not installed. Installing Chocolatey...
    winget install chocolatey
    where choco >nul 2>nul
    if %errorlevel% neq 0 (
        echo ERROR: Chocolatey installation failed!
        exit /b
    ) else (
        echo Chocolatey installed successfully.
    )
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

:: Detect actual Desktop path for current user (OneDrive or Default)
for /f "usebackq tokens=2*" %%A in (`reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v Desktop 2^>nul`) do set "desktopPath=%%B"
if "%desktopPath%"=="" set "desktopPath=%UserProfile%\Desktop"

:: Detect Start Menu path for current user
set "startMenuPath=%APPDATA%\Microsoft\Windows\Start Menu\Programs"

:: Ensure Start Menu path exists
if not exist "%startMenuPath%" mkdir "%startMenuPath%"

:: Create Desktop and Start Menu shortcuts for current user
echo Creating shortcuts for the current user...
powershell -ExecutionPolicy Bypass -NoProfile -Command ^
    "$s=(New-Object -ComObject WScript.Shell).CreateShortcut('%desktopPath%\BatchTools.lnk');" ^
    "$s.TargetPath='%installPath%\Tools.bat';" ^
    "$s.WorkingDirectory='%installPath%';" ^
    "if (Test-Path '%installPath%\icon.ico') { $s.IconLocation='%installPath%\icon.ico' };" ^
    "$s.Save();" >nul 2>&1

powershell -ExecutionPolicy Bypass -NoProfile -Command ^
    "$s=(New-Object -ComObject WScript.Shell).CreateShortcut('%startMenuPath%\BatchTools.lnk');" ^
    "$s.TargetPath='%installPath%\Tools.bat';" ^
    "$s.WorkingDirectory='%installPath%';" ^
    "if (Test-Path '%installPath%\icon.ico') { $s.IconLocation='%installPath%\icon.ico' };" ^
    "$s.Save();" >nul 2>&1

:: Verify shortcut creation
if exist "%desktopPath%\BatchTools.lnk" echo Desktop shortcut created successfully.
if exist "%startMenuPath%\BatchTools.lnk" echo Start Menu shortcut created successfully.

:: Detect Other User Profiles and Skip System Accounts
echo Checking for other user profiles...
for /d %%U in ("C:\Users\*") do (
    set "otherUser=%%~nxU"
    
    :: Skip system users like DefaultAppPool, Public, etc.
    if /i not "!otherUser!"=="Public" if /i not "!otherUser!"=="DefaultAppPool" (
        set "otherUserDesktop=%%U\Desktop"
        set "otherUserStartMenu=%%U\AppData\Roaming\Microsoft\Windows\Start Menu\Programs"

        if exist "%%U" (
            echo Do you want to install BatchTools shortcuts for "!otherUser!"? (Y/N)
            set /p "installForOtherUser="
            if /i "!installForOtherUser!"=="Y" (
                echo Creating shortcuts for user "!otherUser!"...
                
                :: Ensure the Start Menu path exists
                if not exist "!otherUserStartMenu!" mkdir "!otherUserStartMenu!"

                powershell -ExecutionPolicy Bypass -NoProfile -Command ^
                    "$s=(New-Object -ComObject WScript.Shell).CreateShortcut('!otherUserDesktop!\BatchTools.lnk');" ^
                    "$s.TargetPath='%installPath%\Tools.bat';" ^
                    "$s.WorkingDirectory='%installPath%';" ^
                    "if (Test-Path '%installPath%\icon.ico') { $s.IconLocation='%installPath%\icon.ico' };" ^
                    "$s.Save();" >nul 2>&1

                powershell -ExecutionPolicy Bypass -NoProfile -Command ^
                    "$s=(New-Object -ComObject WScript.Shell).CreateShortcut('!otherUserStartMenu!\BatchTools.lnk');" ^
                    "$s.TargetPath='%installPath%\Tools.bat';" ^
                    "$s.WorkingDirectory='%installPath%';" ^
                    "if (Test-Path '%installPath%\icon.ico') { $s.IconLocation='%installPath%\icon.ico' };" ^
                    "$s.Save();" >nul 2>&1

                echo Shortcuts created for "!otherUser!".
            ) else (
                echo Skipped creating shortcuts for "!otherUser!".
            )
        )
    )
)

echo Shortcut setup complete.

:: Verify shortcuts
if exist "%desktopPath%\BatchTools.lnk" (
    echo Desktop shortcut created successfully.
) else (
    echo ERROR: Failed to create desktop shortcut!
)
if exist "%startMenuPath%\BatchTools.lnk" (
    echo Start Menu shortcut created successfully.
) else (
    echo ERROR: Failed to create Start Menu shortcut!
)
echo.
echo Completing installation...
echo ====================================================================================================
:: Define total progress length
set "progressBarLength=100"

:: Start progress
for /l %%i in (1,1,%progressBarLength%) do (
    set /p "=#" <nul
    timeout /nobreak /t 0.1 >nul 2>&1
)
echo.
echo ====================================================================================================
echo.
echo Installation completed successfully.
pause
exit /b
