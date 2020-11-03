@echo off
cd /d "%~dp0"
echo This will test if the batch can detect the framerate and multiply it
echo.
:: This sets the variable to the file opened with it
set input="%1"
echo Input is: %input%
echo.
:: This prints the variable in the cmd
ffprobe -v error -select_streams v -of default=noprint_wrappers=1:nokey=1 -show_entries stream=r_frame_rate -i "%input%" > rate 2>&1
set /p rate=<rate
set /a rate2x="%rate% * 2"
echo Original framerate: %rate%
echo Multiplied framerate: %rate2x%
del /q "%cd%\rate"
echo.
pause