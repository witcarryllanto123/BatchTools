@echo off
setlocal enabledelayedexpansion

:: Check if running as administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrator privileges...
    powershell -Command "Start-Process cmd -ArgumentList '/c \"%~fnx0\"' -Verb RunAs"
    exit /b
)

:: Ensure script is in the correct working directory
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

:: Detect installed Python (including C:\Python312)
set "pythonExec="
for /f "delims=" %%P in ('where python 2^>nul') do (
    if /i not "%%P"=="%UserProfile%\AppData\Local\Microsoft\WindowsApps\python.exe" (
        set "pythonExec=%%P"
    )
)

:: If Python isn't found, check common install locations
if not defined pythonExec (
    if exist "C:\Python312\python.exe" set "pythonExec=C:\Python312\python.exe"
)

:: If Python still isn't found, install portable version
if not defined pythonExec (
    echo Python is not installed or is using Microsoft Store alias. Installing portable Python...
    set "pythonPath=%installPath%\Python"

    :: Download and extract Python
    if not exist "%pythonPath%\python.exe" (
        echo Downloading Python...
        powershell -Command "& {Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.12.0/python-3.12.0-embed-amd64.zip' -OutFile '%installPath%\python.zip'}"

        if not exist "%installPath%\python.zip" (
            echo ERROR: Failed to download Python!
            exit /b
        )

        echo Extracting Python...
        powershell -Command "& {Expand-Archive -Path '%installPath%\python.zip' -DestinationPath '%pythonPath%' -Force}"
        del "%installPath%\python.zip"

        if not exist "%pythonPath%\python.exe" (
            echo ERROR: Python extraction failed!
            exit /b
        )

        echo Python installed successfully.
    )
    set "pythonExec=%pythonPath%\python.exe"
) else (
    echo Python is already installed at "%pythonExec%".
)

:: ✅ Debugging: Check if python.exe actually exists
if not exist "%pythonExec%" (
    echo ERROR: Python installation failed or is not recognized.
    echo Ensure Python is installed in "%installPath%\Python" or "C:\Python312".
    echo.
    echo Debug Info:
    dir "%installPath%\Python"
    exit /b
)

:: ✅ Verify Python runs correctly
"%pythonExec%" --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Python is installed but not working!
    echo Ensure "%pythonExec%" can be executed.
    exit /b
)

:: Manually set yt-dlp expected locations
set "defaultYtDlpPath=C:\Users\%USERNAME%\AppData\Roaming\Python\Python312\Scripts\yt-dlp.exe"
set "ytDlpPath=%installPath%\yt-dlp.exe"

:: Check if yt-dlp is already installed in the expected folder
if exist "%defaultYtDlpPath%" (
    echo Found yt-dlp in "%defaultYtDlpPath%".
    copy "%defaultYtDlpPath%" "%ytDlpPath%" /Y
    if exist "%ytDlpPath%" (
        echo yt-dlp copied successfully to "%ytDlpPath%".
    ) else (
        echo ERROR: Failed to copy yt-dlp.
        exit /b
    )
) else (
    echo yt-dlp is not found in the default installation folder. Installing...
    "%pythonExec%" -m pip install --no-warn-script-location --upgrade yt-dlp

    if exist "%defaultYtDlpPath%" (
        copy "%defaultYtDlpPath%" "%ytDlpPath%" /Y
        echo yt-dlp installed successfully.
    ) else (
        echo ERROR: yt-dlp installation failed!
        exit /b
    )
)

:: ✅ Debugging: Show installed yt-dlp path
if exist "%ytDlpPath%" (
    echo yt-dlp is installed at "%ytDlpPath%".
) else (
    echo ERROR: yt-dlp installation failed!
    exit /b
)

:: Check if FFmpeg is installed
where ffmpeg >nul 2>nul
if %errorlevel% neq 0 (
    echo FFmpeg is not installed. Installing portable version...
    set "ffmpegPath=%installPath%\FFmpeg"

    :: Download and extract FFmpeg portable if not already present
    if not exist "%ffmpegPath%\bin\ffmpeg.exe" (
        powershell -Command "$url='https://github.com/BtbN/FFmpeg-Builds/releases/latest/download/ffmpeg-n5.1-latest-win64-lgpl.zip'; $output='%installPath%\ffmpeg.zip'; Invoke-WebRequest -Uri $url -OutFile $output"
        
        if exist "%installPath%\ffmpeg.zip" (
            echo Extracting FFmpeg...
            powershell -Command "Expand-Archive -Path '%installPath%\ffmpeg.zip' -DestinationPath '%ffmpegPath%' -Force"
            del "%installPath%\ffmpeg.zip"
            echo FFmpeg installed successfully.
        ) else (
            echo ERROR: Failed to download FFmpeg!
            exit /b
        )
    )
    
    :: Verify FFmpeg installation
    if not exist "%ffmpegPath%\bin\ffmpeg.exe" (
        echo ERROR: FFmpeg installation failed or missing!
        exit /b
    ) else (
        echo FFmpeg installed at "%ffmpegPath%\bin\ffmpeg.exe".
    )
) else (
    echo FFmpeg is already installed on this system.
)


:: Detect actual Desktop path (OneDrive or Default)
for /f "usebackq tokens=2*" %%A in (`reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v Desktop 2^>nul`) do set "desktopPath=%%B"
if "%desktopPath%"=="" set "desktopPath=%UserProfile%\Desktop"

:: Detect Start Menu path
set "startMenuPath=%APPDATA%\Microsoft\Windows\Start Menu\Programs"

:: Ensure paths use correct syntax for PowerShell
set "desktopPath=%desktopPath:\=\\%"
set "installPath=%installPath:\=\\%"
set "startMenuPath=%startMenuPath:\=\\%"

:: Create Desktop Shortcut
echo Creating desktop shortcut...
powershell -ExecutionPolicy Bypass -NoProfile -Command ^
    "$s = (New-Object -ComObject WScript.Shell).CreateShortcut('%desktopPath%\\Tools.lnk');" ^
    "$s.TargetPath = '%installPath%\\Tools.bat';" ^
    "$s.WorkingDirectory = '%installPath%';" ^
    "if (Test-Path '%installPath%\\icon.ico') { $s.IconLocation = '%installPath%\\icon.ico' };" ^
    "$s.Save();"

:: Check if desktop shortcut was created
if exist "%desktopPath%\Tools.lnk" (
    echo Desktop shortcut created successfully.
) else (
    echo ERROR: Failed to create desktop shortcut!
)

:: Create Start Menu Shortcut
echo Creating Start Menu shortcut...
powershell -ExecutionPolicy Bypass -NoProfile -Command ^
    "$s = (New-Object -ComObject WScript.Shell).CreateShortcut('%startMenuPath%\\Tools.lnk');" ^
    "$s.TargetPath = '%installPath%\\Tools.bat';" ^
    "$s.WorkingDirectory = '%installPath%';" ^
    "if (Test-Path '%installPath%\\icon.ico') { $s.IconLocation = '%installPath%\\icon.ico' };" ^
    "$s.Save();"

:: Check if Start Menu shortcut was created
if exist "%startMenuPath%\Tools.lnk" (
    echo Start Menu shortcut created successfully.
) else (
    echo ERROR: Failed to create Start Menu shortcut!
)

echo Installation completed successfully.
pause
exit /b
