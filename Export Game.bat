@echo off
cd /d "%~dp0"
set "GODOT=%~dp0tools\godot\Godot_v4.7-stable_win64.exe"
set "PRESET=Windows Desktop"
set "OUT=%~dp0build\The Hobbit Stars.exe"

if not exist "%GODOT%" (
  echo.
  echo ERROR: Godot 4.7 not found at:
  echo   %GODOT%
  echo.
  echo Run this script again after the first-time download completes,
  echo or download Godot 4.7 from https://godotengine.org/download
  echo and place Godot_v4.7-stable_win64.exe in tools\godot\
  echo.
  pause
  exit /b 1
)

if not exist "%APPDATA%\Godot\export_templates\4.7.stable\windows_release_x86_64.exe" (
  echo.
  echo ERROR: Godot 4.7 export templates are not installed.
  echo.
  echo In Godot: Editor ^> Manage Export Templates ^> Download and Install
  echo Or re-run this script after the automatic template download finishes.
  echo.
  pause
  exit /b 1
)

if not exist "%~dp0build" mkdir "%~dp0build"

echo.
echo Exporting "%PRESET%" ...
echo Output: %OUT%
echo.

"%GODOT%" --headless --path "%~dp0" --export-release "%PRESET%" "%OUT%"
set "ERR=%ERRORLEVEL%"

if not "%ERR%"=="0" (
  echo.
  echo Export failed with error code %ERR%.
  pause
  exit /b %ERR%
)

echo.
echo Done! Your game is ready:
echo   %OUT%
echo.
echo Double-click that file to play. You can copy the whole build folder
echo to share the game with others.
echo.
pause
