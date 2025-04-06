@echo off

SET FIRST_RUN_FILE=%APPDATA%\MyScript\first_run_marker.txt

REM Check if it's the first time running
IF NOT EXIST "%FIRST_RUN_FILE%" (
    echo First run detected.

    REM Download .pkg file using PowerShell
    powershell -Command "Invoke-WebRequest -Uri 'https://example.com/yourfile.pkg' -OutFile '%APPDATA%\MyScript\yourfile.pkg'"

    REM Install the package silently (example for a .pkg file, you would need the proper installer for your package)
    REM Example assumes you have a command to install the package without interaction
    REM Example: install_pkg "%APPDATA%\MyScript\yourfile.pkg"

    REM Mark the system as having run the script
    echo "done" > "%FIRST_RUN_FILE%"
    
    REM Optionally, re-run the script after installation (or trigger another task)
    start "" "L:\\Git Repository\\test.bat"
) ELSE (
    echo Not the first run.
)

exit
