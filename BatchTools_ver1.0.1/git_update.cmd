@echo off
setlocal enabledelayedexpansion

:: Check if Git is installed
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: Git is not installed or not in PATH.
    pause
    exit /b
)

:: Change to the repository directory (update the path if needed)
cd /d "%~dp0"

:: Check if required files exist
set "missing_files="
if not exist "BatchTools.zip" set "missing_files=!missing_files! BatchTools.zip"
if not exist "src\tools.bat" set "missing_files=!missing_files! src\tools.bat"
if not exist "installer.bat" set "missing_files=!missing_files! installer.bat"

:: If missing files are found, display a warning
if not "!missing_files!"=="" (
    echo ERROR: The following required files are missing:
    echo !missing_files!
    echo Please check your repository before committing.
    pause
    exit /b
)

:: Check if there are unstaged changes
git status --porcelain > changes.txt
set /p "status_check=" < changes.txt
del changes.txt
if "!status_check!"=="" (
    echo No changes detected. Nothing to commit.
    pause
    exit /b
)

:: Get commit message from user
set /p "commit_msg=Enter commit message: "
if "%commit_msg%"=="" set "commit_msg=Updated files"

:: Ask user for detailed changelog entry
echo Enter detailed changelog entry (Type 'DONE' on a new line to finish):
set "changelog_entry="
:changelog_loop
set /p "line=> "
if /i "%line%"=="DONE" goto save_changelog
set "changelog_entry=!changelog_entry!!line!^n"
goto changelog_loop

:save_changelog
:: Get the current date and time
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set "date_stamp=%datetime:~0,4%-%datetime:~4,2%-%datetime:~6,2% %datetime:~8,2%:%datetime:~10,2%"

:: Append the changelog entry to CHANGELOG.md
echo ## %date_stamp% - %commit_msg% >> CHANGELOG.md
echo !changelog_entry! >> CHANGELOG.md
echo ---------------------------------------- >> CHANGELOG.md

:: Add files to Git
echo Adding changes...
git add .

echo Committing changes...
git commit -m "%commit_msg%"

echo Pushing to GitHub...
git push origin main

:: Check for errors
if %errorlevel% neq 0 (
    echo ERROR: Failed to push changes! Please check your Git settings.
    pause
    exit /b
)

echo Update successfully pushed to GitHub and CHANGELOG.md updated!
pause
exit /b
