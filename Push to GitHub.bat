@echo off
setlocal EnableDelayedExpansion
cd /d "%~dp0"

set "GIT="
for %%G in (
  "C:\Program Files\Git\cmd\git.exe"
  "C:\Program Files (x86)\Git\cmd\git.exe"
  "%LOCALAPPDATA%\Programs\Git\cmd\git.exe"
  "%~dp0tools\git\cmd\git.exe"
) do (
  if exist %%~G set "GIT=%%~G"
)

if not defined GIT (
  where git >nul 2>&1
  if not errorlevel 1 set "GIT=git"
)

if not defined GIT (
  echo Git was not found on this PC.
  echo.
  echo Install from: https://git-scm.com/download/win
  echo Then RESTART your computer and run this file again.
  pause
  exit /b 1
)

echo Using Git: %GIT%
set "PATH=%PATH%;C:\Program Files\Git\cmd"

where gh >nul 2>&1
if errorlevel 1 (
  echo GitHub CLI ^(gh^) is not installed.
  echo.
  echo Option A - Install gh: https://cli.github.com/
  echo Option B - Create a repo on github.com manually, then run:
  echo   git remote add origin https://github.com/YOUR_USERNAME/the-hobbit-syars.git
  echo   git push -u origin main
  echo.
)

if not exist .git (
  echo Initializing git repository...
  git init -b main
)

echo.
echo Staging files...
"%GIT%" add .

echo.
echo Creating commit...
"%GIT%" commit -m "Initial commit: the hobbit syars Godot game" 2>nul
if errorlevel 1 (
  echo Nothing new to commit, or commit already exists.
)

echo.
if exist .git\config (
  findstr /C:"[remote \"origin\"]" .git\config >nul 2>&1
  if errorlevel 1 (
    echo Adding GitHub remote...
    "%GIT%" remote add origin "https://github.com/codingunlv4/the-hobbit-stars.git"
  )
)

"%GIT%" remote -v 2>nul | findstr origin >nul 2>&1
if errorlevel 1 (
  echo.
  echo Create a repo on GitHub first:
  echo   1. Go to https://github.com/new
  echo   2. Name it: the-hobbit-syars
  echo   3. Do NOT add README/license ^(we already have code^)
  echo   4. Copy the repo URL and run:
  echo      git remote add origin YOUR_URL
  echo      git push -u origin main
  pause
  exit /b 1
)

echo Pushing to GitHub...
"%GIT%" push -u origin main
if errorlevel 1 (
  echo.
  echo Push failed. You may need to sign in:
  echo   gh auth login
  echo or use a Personal Access Token when prompted for password.
  pause
  exit /b 1
)

echo.
echo Done! Your code is on GitHub.
pause
