@echo off
setlocal enabledelayedexpansion
echo.
echo Download Video from websites?
echo.
:: Check if FFmpeg and yt-dlp are installed
where ffmpeg >nul 2>nul
if %errorlevel% neq 0 (
    echo FFmpeg is not installed. Please install FFmpeg and add it to your PATH.
    exit /b
)

where yt-dlp >nul 2>nul
if %errorlevel% neq 0 (
    echo yt-dlp is not installed. Please install yt-dlp and add it to your PATH.
    exit /b
)

:: Prompt for video URL and output file name
echo Enter video URL:
set /p "URL=>> "
echo.
echo Enter output name (without extension):
set /p "Outname=>> "
echo.
echo Press A to set output path manually (include drive letter, e.g., C:, E:, D:)
echo Press B to set output path to default (%USERPROFILE%\Downloads)
echo.
choice /c AB /n /m "Enter your choice (A/B): "
echo.
if %errorlevel%==2 (
    set "outpath=%USERPROFILE%\Downloads"
) else (
    set /p "outpath=Enter output path>> "
)
echo.

:: Extras
set "TempFile=%Outname%_temp.%%(ext)s"
set "downloadFolder=%outpath%"
set "outfile=%outpath%\%Outname%.mp4"

:: Download the video using yt-dlp and save the file with the correct extension
echo Downloading video from %URL%...
yt-dlp %URL% -o "%downloadFolder%\%TempFile%"
echo.
echo Video download complete.

:: Check the file extension of the downloaded file
set "fileExtension="
set "downloadFile="
for %%F in ("%downloadFolder%\%Outname%_temp.*") do (
    set "fileExtension=%%~xF"
    set "downloadFile=%%~dpnxF"
)
echo Debug: Detected file = "!downloadFile!"
pause

if not defined fileExtension (
    echo Error: Could not detect file extension.
    goto final
)

:: Check if file is already in the desired format
if /i "!fileExtension!"==".mp4" (
    echo The file is already in MP4 format. No conversion needed.
    echo Reminder: If the file has "_temp" in its name, it is unconverted.
    echo Just remove the "_temp" text manually if needed.
    echo This will be fixed in the next update.
    
    set /p "outfile=Enter the name of the file without '_temp' (without extension): "
    set "outfile=%outpath%\%outfile%.mp4"

    REM Rename the file
    pushd "%outpath%"
    rename "!downloadFile!" "%Outname%.mp4"
    popd

    goto final
)

:: Ask user if they want to keep the unconverted file
echo Keep the unconverted file? (!downloadFile!)
choice /c YN /n /m "Press Y to keep, N to convert: "
if "%errorlevel%"=="1" goto final

:convert
:: Detect GPU for Hardware Acceleration
echo Detecting hardware acceleration support...
set "hwaccel=software"
set "videoCodec=-c:v libx264 -preset fast -crf 23 -c:a aac"

:: Check for Intel QSV support
wmic path win32_videocontroller get name | find /i "Intel" >nul
if %errorlevel%==0 (
    set "hwaccel=qsv"
    set "videoCodec=-c:v h264_qsv -c:a aac"
    echo Intel GPU detected - Using Quick Sync Video [QSV]
)

:: Check for NVIDIA NVENC support
wmic path win32_videocontroller get name | find /i "NVIDIA" >nul
if %errorlevel%==0 (
    set "hwaccel=nvenc"
    set "videoCodec=-c:v h264_nvenc -c:a aac"
    echo NVIDIA GPU detected - Using NVENC
)

:: Check for AMD AMF support
wmic path win32_videocontroller get name | find /i "AMD" >nul
if %errorlevel%==0 (
    set "hwaccel=amf"
    set "videoCodec=-c:v h264_amf -c:a aac"
    echo AMD GPU detected - Using AMF
)

:: Convert using FFmpeg
echo Converting the file into an MP4...
ffmpeg -i "!downloadFile!" !videoCodec! "!outfile!"
if %errorlevel% neq 0 (
    echo FFmpeg conversion failed. Keeping original file.
    goto final
)

:: Ensure file exists before deleting
if not exist "!downloadFile!" (
    echo Error: File not found - "!downloadFile!"
    pause
    goto final
)

echo.
:: Remove any hidden/system attributes
attrib -h -s "!downloadFile!"

:: Wait before deletion (optional)
timeout /t 5 >nul

:: Delete the file
echo Deleting: "!downloadFile!"
del /q "!downloadFile!"

:: Confirm deletion
if exist "!downloadFile!" (
    echo Error: Failed to delete "!downloadFile!".
) else (
    echo File successfully deleted.
)
echo.

:: Check if conversion was successful
if exist "!outfile!" (
    echo Conversion complete. The video is saved as: "!outfile!"
) else (
    echo Conversion failed. Keeping original file: "!downloadFile!"
)

:final
pause
