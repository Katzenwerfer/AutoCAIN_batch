@echo off

set /p cache="Are you sure you want to delete the cache (y/n): "
If %cache%==y (echo OK, deleting cache & rd /s /q "%cd%\Interpolated_frames" >nul & rd /s /q "%cd%\Original_frames" >nul & del /q "%cd%\Audio.wav" >nul & del /q "%cd%\palette.png" >nul & timeout 1 >nul & echo Cache deleted) else (echo Ok...)
timeout 2 >nul

echo.
echo Thanks for wasting my time
timeout 1 >nul
echo.
echo Script written by Katzenwerfer
timeout 2 >nul
pause