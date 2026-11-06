@echo off
rem Work in the folder where this .bat lives (no hardcoded path)
cd /d "%~dp0"

set PORT=5002

if "%~1"=="--relaunched" goto :run

echo [1/4] Stop Flask (port %PORT%)...
for /f "tokens=5" %%p in ('netstat -ano ^| findstr :%PORT% ^| findstr LISTENING') do taskkill /f /pid %%p 1>nul 2>nul
timeout /t 2 /nobreak >nul

echo [2/4] Git update (branch main)...
git checkout main
if errorlevel 1 goto :git_error
git fetch origin main
if errorlevel 1 goto :git_error
git merge --no-edit origin/main
if errorlevel 1 goto :git_error

rem git may have changed this .bat itself - relaunch as a new process
start "" "%~f0" --relaunched
exit /b

:git_error
echo.
echo *** Git update FAILED - the server was NOT started. ***
echo Check the messages above: local uncommitted changes or merge conflicts.
echo Run "git status" in %CD% to see details.
pause
exit /b 1

:run
echo [3/4] pip install...
pip install -r requirements.txt --quiet

echo [4/4] Start Flask...
start http://localhost:%PORT%
python app.py
pause
