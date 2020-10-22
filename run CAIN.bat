@echo off

echo NOTES: This thing doesn't supports audio exporting since I'm to lazy to do it on the first version
timeout 2 >null
echo It's not perfect but it does the job
timeout 2 >null

rem Frame extraction

set /p videopath="Enter your video directory: "
echo Initialazing frame extraction...
timeout 1 >nul
md Original_frames >nul
ffmpeg -loglevel quiet -i %videopath% "%cd%\Original_frames\%%06d.png"
echo Frame extraction completed...
timeout 2 >nul

rem Frame Interpolation

echo Starting frame interpolation...
timeout 1 >nul
md Interpolated_frames >nul
cain-ncnn-vulkan -i "%cd%\Original_frames" -o "%cd%\Interpolated_frames" -t 2048 -g 0
echo Frame interpolation completed...
timeout 2 >nul

rem Frame to video

set /p ftv="Want to convert the frames to video (y/n): "
if %ftv%==y (set /p framerate="Please specify the framerate: " & set /p crf="Please specify a CRF value: " & echo Generating video, please wait & set ffmpegstart=y)
if %ffmpegstart%==y (ffmpeg -loglevel quiet -framerate %framerate% -i "%cd%\Interpolated_frames\%%6d.png" -c:v libx264 -preset veryslow -crf %crf% "%cd%\FinalVideo.mp4")
if %ftv%==n (echo Ok)
echo Done
timeout 2 >nul

rem Delete cache

set /p cache="Want to delete the cache (y/n): "
If %cache%==y (echo OK, deleting cache & rd /s /q "%cd%\Interpolated_frames" & rd /s /q "%cd%\Original_frames" & echo Cache deleted) else (echo Ok...)
timeout 1 >nul

rem end

echo "Thanks for wasting my time"
echo "Script written by Katzenwerfer"
timeout 3 >nul
del /q "%cd%\null"
pause
