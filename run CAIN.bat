@echo off

echo NOTES: This thing doesn't supports audio exporting since I'm to lazy to do it on the first version
timeout 1 >null
echo It's not perfect but it does the job
timeout 1 >null

rem Frame extraction

set /p videopath="Enter your video path: "
echo Initialazing frame extraction...
timeout 2 >nul
md Original_frames >nul
ffmpeg -loglevel quiet -i %videopath% "%cd%\Original_frames\%%06d.png"
echo Frame extraction completed...
timeout 2 >nul

rem Frame Interpolation

echo Starting frame interpolation...
timeout 2 >nul
md Interpolated_frames >nul
cain-ncnn-vulkan -i "%cd%\Original_frames" -o "%cd%\Interpolated_frames" -t 2048 -g 0
echo Frame interpolation completed...
timeout 2 >nul

rem Frame to video

set /p ftv="Want to convert the frames to video (yes or no): "
if %ftv%==yes (set /p framerate="Please specify the framerate: " & set /p crf="Please specify a CRF value: " & echo Generating video, please wait)
ffmpeg -loglevel quiet -framerate %framerate% -i "%cd%\Interpolated_frames\%%6d.png" -c:v libx264 -preset veryslow -crf %crf% "%cd%\FinalVideo.mp4"
echo Done
timeout 1 >nul

rem Delete cache

set /p cache="Want to delete the cache (yes or no): "
If %cache%==yes (echo OK, deleting cache & del /q "%cd%\Interpolated_frames" & del /q "%cd%\Original_frames" & echo Cache deleted)
echo Done
timeout 1 >nul

echo "OK, thanks for wasting my time"
echo "Script written by Katzenwerfer"
timeout 3 >nul
del /q "%cd%\null"
pause