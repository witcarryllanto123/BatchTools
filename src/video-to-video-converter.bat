@echo off
setlocal enabledelayedexpansion

:: Check if FFmpeg is installed
where ffmpeg >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: FFmpeg is not installed or not in PATH.
    echo Please install FFmpeg and make sure it is accessible from the command line.
    pause
    exit /b
)

:: Ask for input video file
echo Enter the full path of the video file you want to convert:
set /p "input_video=>> "

:: Check if the file exists
if not exist "%input_video%" (
    echo ERROR: The file does not exist.
    pause
    exit /b
)

:: Ask for output format
echo Choose output format:
echo 1) Convert to MP4
echo 2) Convert to MKV
echo 3) Convert to AVI
echo 4) Convert to MOV
echo 5) Convert to WebM
echo 6) Convert to FLV
set /p "choice=Enter choice (1-6): "

:: Determine the output extension
set "output_ext="
if "%choice%"=="1" set "output_ext=mp4"
if "%choice%"=="2" set "output_ext=mkv"
if "%choice%"=="3" set "output_ext=avi"
if "%choice%"=="4" set "output_ext=mov"
if "%choice%"=="5" set "output_ext=webm"
if "%choice%"=="6" set "output_ext=flv"

if "%output_ext%"=="" (
    echo ERROR: Invalid choice.
    pause
    exit /b
)

:: Ask for output filename
echo Enter output file name (without extension):
set /p "output_name=>> "

:: Ask for output location
echo Choose where to save the output file:
echo [A] Custom path
echo [B] Default (%USERPROFILE%\Videos)
set /p "path_choice=Enter choice (A/B): "

:: Set output path
if /i "%path_choice%"=="A" (
    echo Enter the full path where you want to save the output file:
    set /p "output_path=>> "
) else (
    set "output_path=%USERPROFILE%\Videos"
)

:: Ensure output path exists
if not exist "%output_path%" mkdir "%output_path%"

:: Construct final output file path
set "output_file=%output_path%\%output_name%.%output_ext%"

:: Convert using FFmpeg
ffmpeg -i "%input_video%" -c:v libx264 -preset medium -crf 23 -c:a aac -b:a 192k "%output_file%"

:: Check if conversion was successful
if exist "%output_file%" (
    echo Conversion successful! File saved at: %output_file%
) else (
    echo ERROR: Conversion failed.
)

pause
exit /b
