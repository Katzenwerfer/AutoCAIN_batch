@echo off
cd /d "%~dp0"
if not defined in_subprocess (cmd /k set in_subprocess=y ^& %0 %*) & exit )
timeout 1 >nul
echo Version 5
timeout 1 >nul
echo Changelog: Added 4x and 8x interpolation...there is also 16x but it is disabled
echo            Added option to choose split size (default=2048)
echo            Now you can drag and drop your video into the batch
echo            Added png sequence support
echo            Added DAIN vulkan support (only 2x)
timeout 1 >nul
echo.
echo It's not perfect but it does the job
timeout 2 >nul
echo.
set videopath=%1
set input=n & set /p input="Want to use png sequence instead?(y/n): "
if %input%==y (goto :Sequence) else (goto :VideoInput)
timeout 1 >nul

:Sequence

echo.
echo Make sure the png sequence don't have alpha channel
timeout 1 >nul
set /p OGframes="Specify the png sequence directory: "
echo Assigning png sequence folder...
timeout 2 >nul
goto :Processing

:VideoInput

:: Frame extraction
set /p videopath="Specify video directory(Skip if drag and droped): "
ffprobe -v error -select_streams v -of default=noprint_wrappers=1:nokey=1 -show_entries stream=r_frame_rate -i %videopath% > rate 2>&1
set /p rate=<rate
set alphan=n & set /p alphan="Is input a gif?(y/n): "
echo.
echo Initializing frame extraction...
md Original_frames >nul
if %alphan%==y (ffmpeg -loglevel quiet -i %videopath% -c:v libx264 -preset veryslow -crf 0 %cd%\gif.mp4 & ffmpeg -loglevel quiet -i %cd%\gif.mp4 "%cd%\Original_frames\%%06d.png" & del /q %cd%\gif.mp4) else (ffmpeg -loglevel quiet -i %videopath% "%cd%\Original_frames\%%06d.png")
set OGframes="%cd%\Original_frames"
echo Frame extraction completed...
timeout 2 >nul

:Processing

:: Frame Interpolation
echo.
:: NOTE--Will probably change the engine selection with a doskey dropdown menu
set engineselect=n & set /p engineselect="Want to use dain instead of cain?(y/n): "
if %engineselect%==y (set engine=dain & echo Using DAIN engine & 2x only) else (set engine=cain & echo Using CAIN engine)
if %engine%==cain (set interpCAIN=2x & set /p interpCAIN="2x, 4x or 8x: " & set interpDAIN=null)
if %engine%==dain (set interpDAIN=2x & set interpCAIN=null)
:: NOTE--Might be a good idea to make doskey for this, not priority though
if %engine%==cain (set splitsize=2048 & set /p splitsize="Split size (default=2048): ")
echo Starting frame interpolation...
:: 2x interpolation
if %interpCAIN%==2x (set /a framerate="%rate% * 2" & echo 2x interpolation & md Interpolated_frames_2x >nul & cain-ncnn-vulkan -i %OGframes% -o "%cd%\Interpolated_frames_2x" -t %splitsize% & set IFrames=Interpolated_frames_2x)
if %interpDAIN%==2x (set /a framerate="%rate% * 2" & echo 2x interpolation & md Interpolated_frames_2x >nul & dain-ncnn-vulkan -i %OGframes% -o "%cd%\Interpolated_frames_2x" -j 3:3:3 & set IFrames=Interpolated_frames_2x)
:: 4x interpolation...you are gonna need some storage
if %interpCAIN%==4x (set /a framerate="%rate% * 4" & echo 4x interpolation, make sure to have enough storage & md Interpolated_frames_2x >nul & cain-ncnn-vulkan -i %OGframes% -o "%cd%\Interpolated_frames_2x" -t %splitsize% & md Interpolated_frames_4x & cain-ncnn-vulkan -i "%cd%\Interpolated_frames_2x" -o "%cd%\Interpolated_frames_4x" -t %splitsize% & set IFrames=Interpolated_frames_4x)
:: 8x interpolation...why?
if %interpCAIN%==8x (set /a framerate="%rate% * 8" & echo 8x interpolation, make sure to have a lot of storage & md Interpolated_frames_2x >nul & cain-ncnn-vulkan -i %OGframes% -o "%cd%\Interpolated_frames_2x" -t %splitsize% & md Interpolated_frames_4x & cain-ncnn-vulkan -i "%cd%\Interpolated_frames_2x" -o "%cd%\Interpolated_frames_4x" -t %splitsize% & md Interpolated_frames_8x & cain-ncnn-vulkan -i "%cd%\Interpolated_frames_4x" -o "%cd%\Interpolated_frames_8x" -t %splitsize% & set IFrames=Interpolated_frames_8x)
echo Frame interpolation completed...
timeout 2 >nul

:: Frame to video
echo.
:: NOTE--tbh most of this part might be better if replaced with doskey
set ftv=y & set /p ftv="Want to convert the frames to video (y/n): "
if %ftv%==y (set audio=n & set /p audio="Does input has audio?(y/n): ")
if %ftv%==y (set gif=n & set /p gif="Want gif instead of video?(y/n): ")
if %gif%==y (ffmpeg -loglevel quiet -i %videopath% -vf palettegen "%cd%\palette.png" & set audio=null & set ftv=n)
if %ftv%==y (echo. & echo Output fps estimated to be %framerate%fps & set /p framerate="Please specify the output framerate (skip if detection is correct): " & set crf=15 & set /p crf="Please specify a CRF value (default=15): " & echo Generating video, please wait) else (echo Ok... & set audio=null)
if %gif%==y (echo. & echo Output fps estimated to be %framerate%fps & set /p framerate="Please specify the output framerate (skip if detection is correct): " & echo Generating gif, please wait)
if %audio%==y (ffmpeg.exe -loglevel quiet -framerate %framerate% -i "%cd%\%IFrames%\%%6d.png" -i %videopath% -map 0:v -map 1:a -c:v libx264 -preset veryslow -crf %crf% "%cd%\FinalVideo.mp4" & echo Video finished, check out the folder for the result)
if %audio%==n (ffmpeg.exe -loglevel quiet -framerate %framerate% -i "%cd%\%IFrames%\%%6d.png" -c:v libx264 -preset veryslow -crf %crf% "%cd%\FinalVideo.mp4" & echo Video finished, check out the folder for the result)
if %gif%==y (ffmpeg.exe -loglevel quiet -framerate %framerate% -i "%cd%\%IFrames%\%%6d.png" -i "%cd%\palette.png" -filter_complex "[0:v][1:v] paletteuse" "%cd%\FinalGIF.gif")
timeout 2 >nul

:: Delete cache
echo.
set cache=n & set /p cache="Want to delete the cache (y/n): "
If %cache%==y (echo OK, deleting cache & timeout 1 >nul)
If %cache%==y (rd /s /q "%cd%\Original_frames" >nul & rd /s /q "%cd%\Interpolated_frames_2x" >nul & rd /s /q "%cd%\Interpolated_frames_4x" >nul & rd /s /q "%cd%\Interpolated_frames_8x" >nul & del /q "%cd%\Audio.wav" >nul & del /q "%cd%\palette.png" >nul & timeout 1 >nul & del /q "%cd%\rate" >nul & echo Cache deleted) else (echo Ok... & timeout 1 >nul)
echo.
echo Thanks for wasting my time
timeout 1 >nul
echo.
echo Script written by Katzenwerfer
timeout 2 >nul

:: This batch requires
:: ffmpeg.exe
:: ffprobe.exe
:: cain-ncnn-vulkan.exe
:: dain-ncnn-vulkan.exe (optional)

pause
