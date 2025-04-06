@echo off
title Background Remover

:: Check if Python is installed
where python >nul 2>nul
if %errorlevel% neq 0 (
    echo Python is not installed. Installing Python...
    winget install Python.Python -e --silent
    echo Python installation complete. Restarting script...
    timeout /t 3 >nul
    exit /b
)
@echo off
setlocal enabledelayedexpansion

:: Set the RemBG app executable name
set "exeName=rembg.exe"

:: Check if rembg.exe exists in common installation paths
if exist "C:\Program Files\rembg\%exeName%" (
    echo [!] RemBG found in Program Files.
    goto installed
)

if exist "C:\Program Files (x86)\rembg\%exeName%" (
    echo [!] RemBG found in Program Files [x86]
    goto installed
)

if exist "%LocalAppData%\Programs\rembg\%exeName%" (
    echo [!] RemBG found in Local AppData.
    goto installed
)

:: Check if rembg is installed globally (if in PATH^)
where %exeName% >nul 2>nul
if %errorlevel%==0 (
    echo [!] RemBG found in system PATH.
    goto installed
)

:: Check if RemBG is installed as a Python module
python -m pip list | findstr /I "rembg" >nul 2>nul
if %errorlevel%==0 (
    echo [!] RemBG is installed as a Python module.
    goto installed
)

:: Check if RemBG was installed via Winget
winget list | findstr /I "rembg" >nul 2>nul
if %errorlevel%==0 (
    echo [!] RemBG found via Winget.
    goto installed
)

:: If none of the checks found RemBG
echo [Error] RemBG is NOT installed.
echo.
echo You didnt install Rembg During the BatchTools Installation, or you set the install path to a custom location.
echo Please re-install BatchTools and dont install RemBg on a custom path. 
pause & goto exit

:installed
echo [!] RemBG is installed.
echo.
echo Reminder: All dependencies like rembg is installed during BatchTools installation.
echo If you have installed Rembg on a Custom path during BatchTools installation, you may have to Re-install BatchTools, because it is required for this script to work.
echo Otherwise, you cant remove image backgrounds. By: Witcarry L. Llanto (Author, developer)
echo.
echo Background remover - powered by Python
echo.
echo Enter the Full path and name of the image you want to remove the Background.
set /p "inputimgpath=>> "

echo Enter your preferred output name (without extension).
set /p "outputimgname=>> "

echo Enter your desired output path.
set /p "outputimgpath=>> "

:: Move to the working directory
cd /d %~dp0

:: Create input and output folders
mkdir "%~dp0\rembg-input" 2>nul
mkdir "%~dp0\rembg-output" 2>nul

:: Copy the image to be processed
copy "%inputimgpath%" "%~dp0\rembg-input\input_image.png" >nul
if not exist "%~dp0\rembg-input\input_image.png" (
    echo Error: Failed to copy input image!
    pause
    exit /b
)

:: Run Python script
rembg "%~dp0\rembg-input\input_image.png" "%~dp0\rembg-output\output_image.png"

:: Check if output file was created
if not exist "%~dp0\rembg-output\output_image.png" (
    echo Error: Failed to generate output image.
    pause
    exit /b
)

echo Output file created successfully.

:: Move output image to the desired location
copy "%~dp0\rembg-output\output_image.png" "%outputimgpath%\%outputimgname%.png" >nul
if not exist "%outputimgpath%\%outputimgname%.png" (
    echo Error: Failed to move output file!
    pause
    exit /b
)

echo Process completed successfully!
timeout /t 5 >nul

:: Clean up
rmdir /s /q "%~dp0\rembg-input" 2>nul
rmdir /s /q "%~dp0\rembg-output" 2>nul

pause
exit /b

:exit
exit /b