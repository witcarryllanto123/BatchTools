@echo off
:: Ask for URL
set /p url="Enter the URL: "

:: Ask for output name
set /p outname="Enter the output name: "

:: Ask for output path
set /p outpath="Enter the output path: "

:: Ensure output path exists
if not exist "%outpath%" mkdir "%outpath%"

:: List available video resolutions
echo Available resolutions:
yt-dlp -F %url% | findstr /I "video"

:: Ask for resolution
set /p res="Enter the resolution: "

:: List available audio qualities
echo Available audio qualities:
yt-dlp -F %url% | findstr /I "audio"

:: Ask for audio quality
set /p audio="Enter the audio quality: "

:: Download the video with selected format
yt-dlp %url% -f %res%+%audio% -o "%outpath%\%outname%.mp4"

:: Pause before exit
pause
