@echo off
cd /d "%~dp0"
set "GODOT=%~dp0tools\godot\Godot_v4.7-stable_win64.exe"
if not exist "%GODOT%" (
  echo.
  echo ERROR: Godot engine not found at:
  echo   %GODOT%
  echo.
  pause
  exit /b 1
)
start "" "%GODOT%" --path "%~dp0" --rendering-method gl_compatibility res://scenes/character_creator.tscn
