# Lovely Screensaver
Made with [LÖVE2D](https://love2d.org)
In all distributions (releases), please check love-license.txt for the original, unmodified license of LÖVE2D and its components.

## What is this?

Lovely Screensaver is a very simple proof-of-concept screensaver made with LÖVE2D. It consists of squares bouncing across a black background when displayed. This is the second-ever LÖVE2D screensaver to support the Windows CLI for screensavers ([link the first I know](https://github.com/ORileyTan/OVKLToolSysSCR)). However, what sets apart Lovely-Screensaver is its implementation of the "/p" argument, making this the first ever 100% functional screensaver with showtime, config and preview all running.

The program handles Windows' standard screensaver arguments appropiately and displays either itself or a messagebox. 
The following table denotes what happens when an argument ("MODE") is passed by Windows into the screensaver.

|MODE        | RESULT|
|:---|                   :---|
|/s ("Show")|Displays the screensaver in fullscreen mode|
|/p: xxxxx ("Preview")|Displays the screensaver in a window borderless window in the same position and size as the real preview window.|
|/c:xxxxx ("Configure")|Opens a simple window with text instructions to change some parameters.|

Attempting to load any other argument or load with no argument results in an info message regarding arguments. This shouldn't be visible unless the program is executed outside the Windows Screensaver logic

## Installing in Windows
1) Download the screensaver software from the Relases tab.
2) Extract the contents into any folder you wish.
3) Right click the .scr to install. You may get a UAC warning. If you do not trust the .scr, you may check the code within the file with any zip software (such as 7zip)
    * If you move the contents later, you will need to restart from this step.
4) Check Windows' screensaver settings. You should be able to change the Settings or enable fullscreen Preview.
5) To uninstall, simply delete the folder the screensaver is in.

## Other OSs
Operating systems other than Windows are not planned for support. This is because the APIs vary too much between different systems to package in one proof-of-concept. 

Anyone is welcome to fork this project and port it to their own OS, but I'd humbly advise said persons to make their own version from the ground-up.