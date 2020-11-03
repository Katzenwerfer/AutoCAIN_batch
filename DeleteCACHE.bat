@echo off

echo This deletes all cache made by any of the CAIN batchs
timeout 1 >nul
set /p cache="Are you sure you want to delete the cache (y/n): "
If %cache%==y (echo OK, deleting cache & rd /s /q "%cd%\Original_frames" >nul & rd /s /q "%cd%\Interpolated_frames_2x" >nul & rd /s /q "%cd%\Interpolated_frames_4x" >nul & rd /s /q "%cd%\Interpolated_frames_8x" >nul & rd /s /q "%cd%\Interpolated_frames_8x" >nul & rd /s /q "%cd%\Interpolated_frames_16x" >nul & del /q "%cd%\Audio.wav" >nul & del /q "%cd%\palette.png" >nul & del /q "%cd%\rate" >nul & timeout 1 >nul & echo Cache deleted) else (echo Ok...)
timeout 1 >nul

echo.
echo Thanks for wasting my time
timeout 1 >nul
echo.
echo Script written by Katzenwerfer
timeout 1 >nul
pause
