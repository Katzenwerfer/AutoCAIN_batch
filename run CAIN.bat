@echo off
timeout 2 >nul
echo Version 3
timeout 2 >nul
echo Changelog: added support for gif (No alpha channel)
echo            Moved some commands here and there
timeout 2 >nul
echo.
echo It's not perfect but it does the job
timeout 2 >nul

rem Frame extraction

echo.
set /p videopath="Enter your video directory: "
set /p alphan="Is input a gif?(y/n): "
echo.
echo Initializing frame extraction...
md Original_frames >nul
if %alphan%==y (ffmpeg -loglevel quiet -i %videopath% -c:v libx264 -preset veryslow -crf 0 %cd%\gif.mp4 & ffmpeg -loglevel quiet -i %cd%\gif.mp4 "%cd%\Original_frames\%%06d.png" & del /q %cd%\gif.mp4) else (ffmpeg -loglevel quiet -i %videopath% "%cd%\Original_frames\%%06d.png")
echo Frame extraction completed...
timeout 2 >nul

rem Frame Interpolation

echo.
echo Starting frame interpolation...
md Interpolated_frames >nul
cain-ncnn-vulkan -i "%cd%\Original_frames" -o "%cd%\Interpolated_frames" -t 2048 -g 0
echo Frame interpolation completed...
timeout 2 >nul

rem Frame to video

echo.
set /p ftv="Want to convert the frames to video (y/n): "
if %ftv%==y (set /p audio="Does input has audio?(y/n): ")
if %ftv%==y (set /p gif="Want gif instead of video?(y/n): ")
if %gif%==y (ffmpeg -loglevel quiet -i %videopath% -vf palettegen "%cd%\palette.png" & set audio=null & set ftv=n)
if %audio%==y (ffmpeg -loglevel quiet -i %videopath% "%cd%\Audio.wav")
if %ftv%==y (set /p framerate="Please specify the framerate: " & set /p crf="Please specify a CRF value: " & echo Generating video, please wait) else (echo Ok... & set audio=null)
if %gif%==y (set /p framerate="Please specify the framerate: " & echo Generating gif, please wait)
if %audio%==y (ffmpeg.exe -loglevel quiet -framerate %framerate% -i "%cd%\Interpolated_frames\%%6d.png" -i "%cd%\Audio.wav" -c:v libx264 -preset veryslow -crf %crf% -c:a aac "%cd%\FinalVideo.mp4" & echo Video finished, check out the folder for the result)
if %audio%==n (ffmpeg.exe -loglevel quiet -framerate %framerate% -i "%cd%\Interpolated_frames\%%6d.png" -c:v libx264 -preset veryslow -crf %crf% "%cd%\FinalVideo.mp4" & echo Video finished, check out the folder for the result)
if %gif%==y (ffmpeg.exe -loglevel quiet -framerate %framerate% -i "%cd%\Interpolated_frames\%%6d.png" -i "%cd%\palette.png" -filter_complex "[0:v][1:v] paletteuse" "%cd%\FinalGIF.gif")
timeout 2 >nul
rem Delete cache

echo.
set /p cache="Want to delete the cache (y/n): "
If %cache%==y (echo OK, deleting cache & rd /s /q "%cd%\Interpolated_frames" >nul & rd /s /q "%cd%\Original_frames" >nul & del /q "%cd%\Audio.wav" >nul & del /q "%cd%\palette.png" >nul & timeout 1 >nul & echo Cache deleted) else (echo Ok...)
timeout 2 >nul

rem end

echo.
echo Thanks for wasting my time
timeout 1 >nul
echo.
echo Script written by Katzenwerfer
timeout 2 >nul
pause
