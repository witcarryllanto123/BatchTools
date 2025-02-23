@echo off
title BatchTools Menu

REM Check where BatchToolsData is installed
set "BATCHTOOLS=C:\ProgramData\BatchToolsData"
if not exist "%BATCHTOOLS%" set "BATCHTOOLS=%LocalAppData%\BatchToolsData"

REM If BatchToolsData does not exist in both locations, show an error
if not exist "%BATCHTOOLS%" (
    echo Error: BatchToolsData folder not found in C:\ProgramData or %LocalAppData%.
    echo The installation may have failed. Please reinstall the tools.
    pause
    exit /b
)

cd /d "%BATCHTOOLS%"

REM Display welcome message
echo -----------------------Creators message--------------------
echo Welcome to my BatchTools menu!
echo If you have any questions, suggestions, or you found a problem or bug,
echo feel free to contact me on my FaceBook account:
echo (https://www.facebook.com/profile.php?id=61554846134169)
echo or email me: witcarryllanto@gmail.com
echo -----------------------------------------------------------
echo -----------------------If there are errors-----------------
echo - If it says "ffmpeg is not recognized," you need to install FFmpeg.
echo   Download: https://ffmpeg.org/download.html
echo - If it says "yt-dlp is not recognized," you need to install yt-dlp.
echo   Download: https://github.com/yt-dlp/yt-dlp/releases
echo - You can also install yt-dlp using:
echo   curl -L -o yt-dlp.exe https://github.com/yt-dlp/yt-dlp/releases/download/2025.02.18/yt-dlp.exe
echo -----------------------------------------------------------
echo You can uninstall BatchTools by selecting pressing number 6.
echo -----------------------------------------------------------

:menu
echo Which tool would you like to run?
echo 1. Downloader Tool - Download videos from supported websites.
echo 2. Converter Tool  - Convert HEVC or non-MP4 videos into MP4.
echo 3. Extractor Tool  - Extract audio from videos.
echo 4. Command Prompt  - Open CMD in BatchToolsData.
echo 5. Exit

echo.
echo More tools coming soon! maybe on the next update. Just tell me what tool you want to add.
echo.

echo.
set /p "choice=Enter the number of the tool you want to run: "

REM Validate user input
if "%choice%"=="1" goto downloader
if "%choice%"=="2" goto converter
if "%choice%"=="3" goto extractor
if "%choice%"=="4" goto cmd
if "%choice%"=="5" goto exit
if "%choice%"=="6" goto uninstaller

echo Invalid choice. Please enter a valid number (1-7).
pause
goto menu

:: Sections for running tools
:downloader
echo.
echo ------------------- Downloader Tool ------------------------
echo Welcome to my video downloader tool! Hope you like it.
call "%BATCHTOOLS%\downloader.bat"
echo ------------------------------------------------------------
goto menu

:converter
echo.
echo ------------------- Converter Tool -------------------------
echo Welcome to my non-MP4 to MP4 converter tool! Hope you like it.
call "%BATCHTOOLS%\converter.bat"
echo ------------------------------------------------------------
goto menu

:extractor
echo.
echo ----------------- Audio Extractor Tool ---------------------
echo Extracting audio from video...
call "%BATCHTOOLS%\extractor.bat"
pause
echo ------------------------------------------------------------
goto menu


:cmd
echo.
echo -------------------- Command Prompt ------------------------
cd /d "%BATCHTOOLS%"
cmd
echo ------------------------------------------------------------
goto menu

:uninstaller
echo.
echo ------------------ Screen Recorder -------------------------
echo Uninstalling BatchTools...
call "%BATCHTOOLS%\uninstaller.bat"
pause
echo ------------------------------------------------------------
goto menu

:exit
echo Exiting BatchTools. Goodbye!
exit
