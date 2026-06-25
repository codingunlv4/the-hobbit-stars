@echo off
REM Launches the game directly (no editor) — use this if the editor shows a blank screen.
start "" "%~dp0tools\godot\Godot_v4.3-stable_win64.exe" --path "%~dp0" --rendering-method gl_compatibility res://scenes/character_creator.tscn
