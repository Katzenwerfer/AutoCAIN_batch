@echo

:: CRF value
set crf="15"

:: Video Codec (libx264, libx265 or their nvenc version recommended)
set vcodec="libx264"

:: Codec preset
set preset="veryslow"

:: delete this later
set gif=n
set ftv=y

:: Processing
set input=%1
md %cd%\folder
ffprobe -v error -select_streams v -of default=noprint_wrappers=1:nokey=1 -show_entries stream=r_frame_rate -i "%input%" > rate 2>&1
set /p rate=<rate
set /a rate2x="%rate% * 2"
echo Frame extraction
md %cd%\folder\Original_frames
ffmpeg -loglevel quiet -i "%input%" "%cd%\folder\Original_frames\%%6d.png"
:: also need to state that if gif detected then (set gif=y)
timeout 2 >nul
echo.
echo 2x interpolation
md %cd%\folder\Interpolated_frames >nul
cain-ncnn-vulkan -i "%cd%\folder\Original_frames" -o "%cd%\folder\Interpolated_frames" -g 0 -t 2048
timeout 2>nul
echo.
echo Converting frames to video/gif
:: Temporary disabled--if %gif%==y (ffmpeg.exe -loglevel quiet -i "%cd%\folder\Interpolated_frames\%%6d.png" -i "%cd%\palette.png" -filter_complex "[0:v][1:v] paletteuse" -framerate %rate2x% "%cd%\folder\FinalGIF.gif" & del /q "%cd%\palette.png" & set ftv=null)
if %ftv%==y (ffmpeg -i "%cd%\folder\Interpolated_frames\%%6d.png" -c:v %vcodec% -preset %preset% -crf %crf% -framerate %rate2x% "%cd%\FinalVideo.mp4")
rd /s /q "%cd%\folder\" >nul
del /q "%cd%\rate" >nul
timeout 2 >nul

:: This part closes the batch
echo.
echo Thanks for wasting my time!
echo Script written by Katzenwerfer
echo.
echo Closing in 3 seconds
timeout 1 >nul
echo 2
timeout 1 >nul
echo 1
timeout 1 >nul

:: This batch requires
:: ffmpeg.exe
:: cain-ncnn-vulkan.exe
:: ffprobe.exe

pause