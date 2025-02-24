@echo off
title Audio Extractor with Hardware Acceleration
echo Extract audio from a video file using FFmpeg with hardware acceleration.
echo.

:: Check if FFmpeg is installed
where ffmpeg >nul 2>nul
if %errorlevel% neq 0 (
    echo FFmpeg is not installed. Please install it and add it to your PATH.
    pause
    exit /b
)

:: Detect GPU for Hardware Acceleration
echo Detecting hardware acceleration support...
set "hwaccel=none"

:: Check for Intel QSV support
wmic path win32_videocontroller get name | find /i "Intel" >nul
if %errorlevel%==0 (
    set "hwaccel=qsv"
    echo Intel GPU detected - Using Quick Sync Video [QSV]
)

:: Check for NVIDIA NVENC support
wmic path win32_videocontroller get name | find /i "NVIDIA" >nul
if %errorlevel%==0 (
    set "hwaccel=nvenc"
    echo NVIDIA GPU detected - Using NVENC
)

:: Check for AMD AMF support
wmic path win32_videocontroller get name | find /i "AMD" >nul
if %errorlevel%==0 (
    set "hwaccel=amf"
    echo AMD GPU detected - Using AMF
)

:: Ask for directory path where videos are located
echo.
echo Enter the full path of the folder containing video files:
set /p "videoFolder=>> "

:: Check if folder exists
if not exist "%videoFolder%" (
    echo Folder not found! Please check the path and try again.
    pause
    exit /b
)

:: Change directory to the folder
cd /d "%videoFolder%"

:: List all video files in the directory
echo.
echo Available video files:
echo -------------------------------------------------------------------
for %%F in (*.mp4 *.mkv *.avi *.mov *.webm) do echo %%F
echo -------------------------------------------------------------------

:: Ask the user to select a file
echo Enter the full filename (including extension) of the video you want to extract audio from:
set /p "videoFile=>> "

:: Check if the selected file exists
if not exist "%videoFile%" (
    echo File not found! Please check the name and try again.
    pause
    exit /b
)

:: Extract filename without extension
for %%F in ("%videoFile%") do set "videoName=%%~nF"

:: Prompt for output format
echo Select audio format:
echo 1 - MP3
echo 2 - AAC
echo 3 - WAV
echo 4 - FLAC
set /p "format=Enter choice (1-4): "

:: Set the corresponding output format
if "%format%"=="1" set "audioExt=mp3" & set "codec=-c:a libmp3lame -q:a 2"
if "%format%"=="2" set "audioExt=aac" & set "codec=-c:a aac -b:a 192k"
if "%format%"=="3" set "audioExt=wav" & set "codec=-c:a pcm_s16le"
if "%format%"=="4" set "audioExt=flac" & set "codec=-c:a flac"

:: If the user enters an invalid choice, default to MP3
if not defined audioExt set "audioExt=mp3" & set "codec=-c:a libmp3lame -q:a 2"

:: Set output path (same directory as the video file)
set "audioPath=%videoFolder%\%videoName%.%audioExt%"

:: Extract audio using FFmpeg with hardware acceleration
echo Extracting audio from %videoFile%...

if "%hwaccel%"=="qsv" (
    ffmpeg -hwaccel qsv -i "%videoFile%" %codec% "%audioPath%" -y
) else if "%hwaccel%"=="nvenc" (
    ffmpeg -hwaccel cuda -i "%videoFile%" %codec% "%audioPath%" -y
) else if "%hwaccel%"=="amf" (
    ffmpeg -hwaccel dxva2 -i "%videoFile%" %codec% "%audioPath%" -y
) else (
    echo No supported GPU found, using software processing.
    ffmpeg -i "%videoFile%" %codec% "%audioPath%" -y
)

:: Check if extraction was successful
if exist "%audioPath%" (
    echo Audio extraction complete! Saved as: %audioPath%
) else (
    echo Audio extraction failed.
)
pause