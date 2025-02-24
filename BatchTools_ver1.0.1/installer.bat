@echo off
setlocal enabledelayedexpansion

:: Check if running as administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrator privileges...
    powershell -Command "Start-Process cmd -ArgumentList '/c \"%~fnx0\"' -Verb RunAs"
    exit /b
)

:: Ensure script is in the correct directory
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

:: Check if Python is installed
where python >nul 2>nul
if %errorlevel% neq 0 (
    echo Python is not installed. Installing portable Python...
    set "pythonPath=%installPath%\Python"

    :: Download and extract Python
    if not exist "%pythonPath%\python.exe" (
        powershell -Command "$url='https://www.python.org/ftp/python/3.12.0/python-3.12.0-embed-amd64.zip'; $output='%installPath%\python.zip'; Invoke-WebRequest -Uri $url -OutFile $output"
        
        if exist "%installPath%\python.zip" (
            powershell -Command "Expand-Archive -Path '%installPath%\python.zip' -DestinationPath '%pythonPath%' -Force"
            del "%installPath%\python.zip"
            echo Python installed successfully.
        ) else (
            echo ERROR: Failed to download Python!
            exit /b
        )
    )
    set "pythonExec=%pythonPath%\python.exe"
) else (
    echo Python is already installed on the system.
    for /f "delims=" %%P in ('where python') do set "pythonExec=%%P"
)

:: Install yt-dlp using the detected Python
set "ytDlpPath=%installPath%\yt-dlp.exe"
if not exist "%ytDlpPath%" (
    echo Installing yt-dlp...
    "%pythonExec%" -m pip install yt-dlp --no-warn-script-location
    set "pythonScripts=%installPath%\Python\Scripts"
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

:: Ensure paths use correct syntax
set "desktopPath=%desktopPath:\=/%"
set "installPath=%installPath:\=/%"

:: Create shortcut using PowerShell with icon support
powershell -ExecutionPolicy Bypass -NoProfile -Command ^
    "$s = (New-Object -ComObject WScript.Shell).CreateShortcut('%desktopPath%/Tools.lnk');" ^
    "$s.TargetPath = '%installPath%/Tools.bat';" ^
    "$s.WorkingDirectory = '%installPath%';" ^
    "if (Test-Path '%installPath%/icon.ico') { $s.IconLocation = '%installPath%/icon.ico' };" ^
    "$s.Save();"

:: Verify shortcut was created
if exist "%desktopPath%\Tools.lnk" (
    echo Shortcut created successfully in "%desktopPath%".
) else (
    echo ERROR: Failed to create shortcut! Try creating it manually.
)

echo Installation completed successfully.
pause
exit /b
