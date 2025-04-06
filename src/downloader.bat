@echo off
setlocal enabledelayedexpansion
echo.
echo Download Video from Websites
echo.

:: Check if FFmpeg and yt-dlp are installed
where ffmpeg >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] FFmpeg is not installed. Please install FFmpeg and add it to your PATH.
    exit /b
)

where yt-dlp >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] yt-dlp is not installed. Please install yt-dlp and add it to your PATH.
    exit /b
)

:: Prompt for video URL and output file name
echo Enter video URL:
set /p "URL=>> "
echo.
echo Enter output name (without extension):
set /p "Outname=>> "
echo.
echo Press A to set output path manually (e.g., C:\Downloads)
echo Press B to use default path (%USERPROFILE%\Downloads)
echo.

choice /c AB /n /m "Enter your choice (A/B): "
echo.
if %errorlevel%==1 (
    set /p "outpath=Enter output path: "
) else (
    set "outpath=%USERPROFILE%\Downloads"
)
echo.

:: Ask for resolution
echo [INFO] Fetching available video resolutions...
echo ------------------------------------------------------------------------------
yt-dlp -F %URL% | findstr /R "^[0-9]+ .* video"
echo ------------------------------------------------------------------------------
set /p res="Enter the resolution code: "
echo.

:: Ask for audio quality
echo [INFO] Fetching available audio qualities...
echo ------------------------------------------------------------------------------
yt-dlp -F %URL% | findstr "audio only" | find /V "video only"
echo ------------------------------------------------------------------------------
set /p audio="Enter the audio quality code: "
echo.


:: Define output paths
set "TempFile=%outpath%\%Outname%_temp"
set "downloadFolder=%outpath%"
set "outfile=%outpath%\%Outname%"

:: Download the video
echo [INFO] Downloading video from %URL%...
echo ------------------------------------------------------------------------------
yt-dlp --no-check-certificate -f %res%+%audio% -o "%TempFile%" "%URL%"
echo ------------------------------------------------------------------------------
echo [SUCCESS] Video download complete.

:: Detect downloaded file extension
set "fileExtension="
set "downloadFile="

for %%F in ("%downloadFolder%\%Outname%_temp.*") do (
    set "fileExtension=%%~xF"
    set "downloadFile=%%~dpnxF"
)
echo Debug: Detected file = "!downloadFile!"
pause

if not defined fileExtension (
    echo [ERROR] Could not detect file extension.
    goto final
)

:: Check if file is already in MP4 format
if /i "!fileExtension!"==".mp4" (
    echo [INFO] File is already in MP4 format.
    ren "!downloadFile!" "%Outname%.mp4"
    goto final
)

set "downloadFile=%outpath%\%Outname%_temp!fileExtension!"

:: Ask user if they want to keep the unconverted file
echo Keep the unconverted file? (!downloadFile!)
choice /c YN /n /m "Press Y to keep, N to convert: "
if %errorlevel%==1 ( 
    goto final
)
:convert
:: Detect GPU for Hardware Acceleration
echo [INFO] Detecting hardware acceleration support...
set "hwaccel=software"
set "videoCodec=-c:v libx264 -preset fast -crf 23 -c:a aac"
timeout /t 3 >nul

:: Detect Intel QSV
for /f "tokens=*" %%G in ('wmic path win32_videocontroller get name ^| find /I "Intel"') do (
    set "hwaccel=qsv"
    set "videoCodec=-c:v h264_qsv -c:a aac"
    echo [INFO] Intel GPU detected - Using Quick Sync Video [QSV]
)

:: Detect NVIDIA NVENC
for /f "tokens=*" %%G in ('wmic path win32_videocontroller get name ^| find /I "NVIDIA"') do (
    set "hwaccel=nvenc"
    set "videoCodec=-c:v h264_nvenc -c:a aac"
    echo [INFO] NVIDIA GPU detected - Using NVENC
)

:: Detect AMD AMF
for /f "tokens=*" %%G in ('wmic path win32_videocontroller get name ^| find /I "AMD"') do (
    set "hwaccel=amf"
    set "videoCodec=-c:v h264_amf -c:a aac"
    echo [INFO] AMD GPU detected - Using AMF
)
timeout /t 3 >nul
:: Ensure file exists before converting
if not exist "!downloadFile!" (
    echo [ERROR] File not found - "!downloadFile!"
    echo [DEBUG] FILE:
    echo         Location: %outpath%
    echo         Name: %Outname%
    echo         Extension: %fileExtension%
    echo You might report this emmidiately to my e-mail or facebook account. 
    echo [FB-account: https://www.facebook.com/profile.php?id=61554846134169] 
    echo [E-mail: witcarryllanto@gmail.com]
    pause
    goto final
)

:: Convert using FFmpeg
echo [INFO] Converting the file to MP4...
ffmpeg -i "!downloadFile!" !videoCodec! "!outfile!.mp4"
if %errorlevel% neq 0 (
    echo [ERROR] FFmpeg conversion failed. Keeping original file.
    echo [DEBUG] FILE:
    echo         Location: %outpath%
    echo         Name: %Outname%
    echo         Extension: %fileExtension%
    echo You might report this emmidiately to my e-mail or facebook account. 
    echo [FB-account: https://www.facebook.com/profile.php?id=61554846134169] 
    echo [E-mail: witcarryllanto@gmail.com]
    goto final
)

:: Ensure file exists before deleting
if not exist "!downloadFile!" (
    echo [ERROR] File not found - "!downloadFile!"
    echo [DEBUG] FILE:
    echo         Location: %outpath%
    echo         Name: %Outname%
    echo         Extension: %fileExtension%
    echo You might report this emmidiately to my e-mail or facebook account. 
    echo [FB-account: https://www.facebook.com/profile.php?id=61554846134169] 
    echo [E-mail: witcarryllanto@gmail.com]
    pause
    goto final
)

:: Remove hidden/system attributes
attrib -h -s "!downloadFile!"

:: Delete the file with retry option
echo Deleting: "!downloadFile!"
del /q "!downloadFile!"

:: Confirm deletion
if exist "!downloadFile!" (
    pause
    del /q "!downloadFile!"
)

:: Check if conversion was successful
if exist "!outfile!" (
    echo [SUCCESS] Conversion complete. The video is saved as: "!outfile!"
) else (
    echo [ERROR] Conversion failed. Keeping original file: "!downloadFile!"
    echo [DEBUG] FILE:
    echo         Location: %outpath%
    echo         Name: %Outname%
    echo         Extension: %fileExtension%
    echo You might report this emmidiately to my e-mail or facebook account. 
    echo [FB-account: https://www.facebook.com/profile.php?id=61554846134169] 
    echo [E-mail: witcarryllanto@gmail.com]
)

:final
pause
