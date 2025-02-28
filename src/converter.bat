@echo off
title Video to MP4 Converter with Hardware Acceleration
echo Convert a file to MP4 format with hardware acceleration.
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
set "hwaccel=software"

:: Check for Intel QSV support
wmic path win32_videocontroller get name | find /i "Intel" >nul
if %errorlevel%==0 (
    set "hwaccel=qsv"
    set "videoCodec=h264_qsv"
    echo Intel GPU detected - Using Quick Sync Video [QSV]
)

:: Check for NVIDIA NVENC support
wmic path win32_videocontroller get name | find /i "NVIDIA" >nul
if %errorlevel%==0 (
    set "hwaccel=nvenc"
    set "videoCodec=h264_nvenc"
    echo NVIDIA GPU detected - Using NVENC
)

:: Check for AMD AMF support
wmic path win32_videocontroller get name | find /i "AMD" >nul
if %errorlevel%==0 (
    set "hwaccel=amf"
    set "videoCodec=h264_amf"
    echo AMD GPU detected - Using AMF
)

:: If no hardware acceleration is found, use software encoding
if "%hwaccel%"=="software" (
    set "videoCodec=libx264"
    echo No supported GPU found - Using software encoding.
)

echo.
:: Ask for directory path where the file is located
echo Enter the full path of the folder containing the video file:
set /p "videoFolder=>> "

:: Check if folder exists
if not exist "%videoFolder%" (
    echo Folder not found! Please check the path and try again.
    pause
    exit /b
)

:: Change directory to the folder
cd /d "%videoFolder%"

:: Ask for file name with extension
echo Enter file name with extension (e.g., video.mkv):
set /p "videoFile=>> "

:: Check if file exists
if not exist "%videoFile%" (
    echo File not found! Please check the name and try again.
    pause
    exit /b
)

:: Extract filename without extension
for %%F in ("%videoFile%") do set "videoName=%%~nF"

:: Ask for output name
echo Enter output name (without extension):
set /p "outputName=>> "

:: Extract drive letter from the input path
set "Edrive=%videoFolder:~0,2%"

:: Set output path
set "outpath=%Edrive%\Converted"

:: Ensure output directory exists
if not exist "%outpath%" mkdir "%outpath%"

echo.
echo Converting: %videoFile% to %outputName%.mp4 using %videoCodec%...
ffmpeg -hwaccel %hwaccel% -i "%videoFile%" -c:v %videoCodec% -preset fast -b:v 5000k -c:a aac -b:a 192k "%outpath%\%outputName%.mp4" -y

:: Check if conversion was successful
if exist "%outpath%\%outputName%.mp4" (
    echo Conversion complete. The video is saved as:
    echo %outpath%\%outputName%.mp4
) else (
    echo Conversion failed.
)

pause

