@echo off
setlocal enabledelayedexpansion

:: Ensure script runs as administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrator privileges...
    powershell -Command "Start-Process '%~fnx0' -Verb RunAs -Wait"
    exit /b
)

:: Change directory to script location
cd /d "%~dp0"

:: Define installation directory
set "installPath=C:\Program Files\BatchTools"
if not exist "%installPath%" mkdir "%installPath%" 2>nul
if not exist "%installPath%" (
    echo Failed to create directory in ProgramData. Using LocalAppData instead.
    set "installPath=%LocalAppData%\BatchToolsData"
    mkdir "%installPath%"
)

:: Extract BatchTools.zip
if not exist "%~dp0\Package.pkg" (
    echo Package.pkg not found. Please ensure the file is in the same directory as the installer. Or dont delete it.
    pause
    exit /b
) else (
    copy "%~dp0\Package.pkg" "BatchTools.zip"
    echo Extracting Package.pkg...
    powershell -Command "Expand-Archive -Path '%~dp0\BatchTools.zip' -DestinationPath '%installPath%' -Force"
    del /f /q "%~dp0\BatchTools.zip"
    echo Package extracted successfully.
)


:: Ensure dependencies folder exists
set "rembgdeppath=%installPath%\rembg-dependencies"
if not exist "%rembgdeppath%" mkdir "%rembgdeppath%"

:: Set Paths
set "pythonURL=https://www.python.org/ftp/python/3.12.2/python-3.12.2-embed-amd64.zip"
set "ffmpegURL=https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip"
set "chocoURL=https://community.chocolatey.org/install.ps1"
set "ytDlpURL=https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe"

:: Install Python if not found
where python >nul 2>nul
if %errorlevel% neq 0 (
    echo [INFO] Python not found. Installing...
    if exist "%~dp0\Package2.pkg" (
        copy "%~dp0\Package2.pkg" "%~dp0\python-installer.exe"
        start /wait "%~dp0\python-installer.exe" /quiet InstallAllUsers=1 PrependPath=1 TargetDir="C:\Python312"
        if %errorlevel% neq 0 (
            echo [ERROR] Failed to install Python.
            pause
            exit /b
        )
    ) else (
        echo [INFO] Downloading Python...
        winget install python.python
        if %errorlevel% neq 0 (
            echo [ERROR] Python install failed.
            pause
            exit /b
        )
    )
) ELSE (
    echo [INFO] Python already installed.
)


:: Ensure pip is installed
where pip >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] pip not found. Attempting to reinstall...
    python -m ensurepip
    python -m pip install --upgrade pip
) ELSE (
    echo [INFO] pip already installed.
)


:: Check and Install FFmpeg
where ffmpeg >nul 2>nul
if %errorlevel% neq 0 (
    set "ffpath=C:\FFmpeg-standalone"
    if not exist "%ffpath%" mkdir "%ffpath%"
    if exist "%~dp0\Package3.pkg" (
        copy "%~dp0\Package3.pkg" "%ffpath%\ffmpeg.exe"
    ) else (
        echo [INFO] Downloading FFmpeg...
        set "ffinstpath=C:\Ffmpeg"
        powershell -Command "Invoke-WebRequest -Uri '%ffmpegURL%' -OutFile '%ffpath%\ffmpeg.zip'"
        echo [INFO] Extracting FFmpeg...
        powershell -Command "Expand-Archive -Path '%ffpath%\ffmpeg.zip' -DestinationPath '%ffpath%' -Force"
        del /f /q "%ffpath%\ffmpeg.zip"
        if exist "%ffpath%\bin\ffmpeg.exe" (
            echo [INFO] FFmpeg extracted successfully.
            set "ffpath=%ffpath%\bin"
            setx PATH "%ffpath%;%PATH%" /m
        ) else (
            echo [ERROR] Failed to extract FFmpeg.
            pause
            exit /b
        )
    )
    powershell -command "Expand-Archive -Path '%ffpath%\ffmpeg.zip' -DestinationPath '%ffpath%' -Force"
    del /f /q "%ffpath%\ffmpeg.zip"
    setx PATH "%ffpath%\bin;%PATH%" /m"
) ELSE (
    echo [INFO] FFmpeg already installed.
)



:: Install Chocolatey if not found
where choco >nul 2>nul
if %errorlevel% neq 0 (
    if not exist "%~dp0\Package4.pkg" (
        echo [ERROR] Chocolatey package not found. Please ensure the file is in the same directory as the installer.
        pause
        goto online_installation_choco
    ) else (
        copy "%~dp0\Package4.pkg" "%installPath%\chocolatey.zip"
        echo [INFO] Extracting Chocolatey...
        if not exist "C:\Chocolatey" mkdir "C:\Chocolatey"
        set "chocoinstapath=C:\Chocolatey"
        powershell -Command "Expand-Archive -Path '%~dp0\chocolatey.zip' -DestinationPath '%chocoinstapath%' -Force"
        del /f /q "%installPath%\chocolatey.zip"
        setx PATH "%chocoinstapath%\bin;%PATH%"
    )
    :online_installation_choco
    echo [INFO] Installing Chocolatey from online source...
    echo [INFO] Installing Chocolatey...
    winget install Chocolatey
    if %errorlevel% neq 0 (
        echo [ERROR] Chocolatey install failed.
        pause
        exit /b
    )
) ELSE (
    echo [INFO] Chocolatey already installed.
)



:: Install yt-dlp
where yt-dlp >nul 2>nul
if %errorlevel% neq 0 (
    if exist "%~dp0\PackagedExe.pkg" (
        copy "%~dp0\PackagedExe.pkg" "%installPath%\yt-dlp.exe"
    ) else (
        echo [INFO] Downloading yt-dlp...
        powershell -Command "Invoke-WebRequest -Uri '%ytDlpURL%' -OutFile '%installPath%\yt-dlp.exe'"
    )
    setx PATH "%installPath%;%PATH%"
) ELSE (
    echo [INFO] yt-dlp already installed.
)


:: Install rembg
echo [INFO] Checking if rembg is installed...
pip show rembg >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] rembg not found. Installing...
    if exist "%~dp0\Package5.pkg" (
        if not exist "%~dp0\Rembg" mkdir "%~dp0\Rembg"
        copy "%~dp0\Package5.pkg" "%~dp0\Rembg.zip"
        set "rembgdeppath=%~dp0\Rembg"
        echo [INFO] Extracting rembg dependencies...
        powershell -Command "Expand-Archive -Path '%~dp0\Rembg.zip' -DestinationPath '%rembgdeppath%' -Force"
        del /f /q "%~dp0\Rembg.zip"

        if not exist "%~dp0\rembginst.py" (
            echo [ERROR] Python installer script (rembginst.py^) not found.
            pause 
            exit /b
        ) ELSE (
            echo [INFO] Found installer script. Running it now...
        )

        python rembginst.py "%rembgdeppath%"
        
        :: ✅ Re-check rembg installation
        pip show rembg >nul 2>&1
        if %errorlevel% neq 0 (
            echo [ERROR] rembg NOT installed.
            pause
            exit /b
        ) ELSE (
            echo [SUCCESS] rembg installed successfully!
        )

    ) else (
        echo [INFO] Downloading rembg from pip...
        pip install rembg
        if %errorlevel% neq 0 (
            echo [ERROR] rembg install failed from pip.
            pause
            exit /b
        ) ELSE (
            echo [SUCCESS] rembg installed successfully from pip.
        )
    )
) ELSE (
    echo [INFO] rembg already installed.
)

:: Verify and update PATH
for %%v in ("C:\Program Files\BatchTools" "C:\Python312" "C:\Program Files\nodejs") do (
    reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path | findstr /i "%%~v" 1>nul
    if errorlevel 1 (
        echo [ERROR] Failed to add %%~v to PATH. Attempting to add...
        setx PATH "%%~v;C:\Python312\Scripts\;C:\Python312\;C:\WINDOWS\system32;C:\WINDOWS;C:\WINDOWS\System32\Wbem;C:\WINDOWS\System32\WindowsPowerShell\v1.0\;C:\WINDOWS\System32\OpenSSH\;C:\Program Files\nodejs\;C:\ProgramData\chocolatey\bin;C:\Program Files\Git\cmd;C:\Program Files\dotnet\;L:\BatchTools;L:\Custom Cmd ui;C:\Users\Witcarry\AppData\Roaming\Python\Python312\Scripts;C:\Users\Witcarry\AppData\Local\Microsoft\WindowsApps;C:\Users\Witcarry\AppData\Local\Programs\Microsoft VS Code\bin;C:\Users\Witcarry\AppData\Local\Programs\Ollama;C:\Program Files (x86)\Rembg"
        echo [INFO] Restart the command prompt to reflect the changes.
        exit /b
    )
)


:: Create Desktop & Start Menu Shortcuts
:: Check if OneDrive exists and if Desktop is in OneDrive
set "desktopPath=%UserProfile%\Desktop"

:: Check if OneDrive is installed (checking for OneDrive folder existence)
if exist "%UserProfile%\OneDrive" (
    :: Check if the Desktop is in the OneDrive folder by checking for the specific Desktop subfolder
    if exist "%UserProfile%\OneDrive\Desktop" (
        set "desktopPath=%UserProfile%\OneDrive\Desktop"
    )
) 

set "startMenuPath=%APPDATA%\Microsoft\Windows\Start Menu\Programs"
if not exist "%startMenuPath%" mkdir "%startMenuPath%"

echo Creating shortcuts for the current user...
powershell -ExecutionPolicy Bypass -NoProfile -Command ^
    "$s=(New-Object -ComObject WScript.Shell).CreateShortcut('%desktopPath%\BatchTools.lnk');" ^
    "$s.TargetPath='%installPath%\Tools.bat';" ^
    "$s.WorkingDirectory='%installPath%';" ^
    "if (Test-Path '%~dp0\icon.ico') { $s.IconLocation='%~dp0\icon.ico' };" ^
    "$s.Save();" >nul 2>&1
if "%errorlevel%"=="0" (
    echo Desktop shortcut has been made.
)
powershell -ExecutionPolicy Bypass -NoProfile -Command ^
    "$s=(New-Object -ComObject WScript.Shell).CreateShortcut('%startMenuPath%\BatchTools.lnk');" ^
    "$s.TargetPath='%installPath%\Tools.bat';" ^
    "$s.WorkingDirectory='%installPath%';" ^
    "if (Test-Path '%~dp0\icon.ico') { $s.IconLocation='%~dp0\icon.ico' };" ^
    "$s.Save();" >nul 2>&1
if "%errorlevel%"=="0" (
    echo Start Menu shortcut has been made.
)
:: Create Uninstaller shortcut
powershell -ExecutionPolicy Bypass -NoProfile -Command ^
    "$s=(New-Object -ComObject WScript.Shell).CreateShortcut('%startMenuPath%\BatchTools-Uninstaller.lnk');" ^
    "$s.TargetPath='%installPath%\uninstaller.bat';" ^
    "$s.WorkingDirectory='%installPath%';" ^
    "if (Test-Path '%~dp0\uninstico.ico') { $s.IconLocation='%~dp0\uninstico.ico' };" ^
    "$s.Save();" >nul 2>&1


echo Installation and updates completed successfully.
pause
exit /b
