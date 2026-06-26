@echo off
cd /d "%~dp0"
set "GODOT=%~dp0tools\godot\Godot_v4.3-stable_win64_console.exe"
if not exist "%GODOT%" (
  echo ERROR: Godot not found at %GODOT%
  pause
  exit /b 1
)
echo Running game — errors will show below...
echo.
"%GODOT%" --path "%~dp0" --rendering-method gl_compatibility res://scenes/character_creator.tscn
echo.
echo Game exited.
pause
