# Lovely Screensaver
Made with [LÖVE2D](https://love2d.org)

## What is this?

Lovely Screensaver is a very simple proof-of-concept screensaver made with LÖVE2D. It consists of squares bouncing across a black background when displayed. This is the second-ever LÖVE2D screensaver to support the Windows CLI for screensavers ([link to the first one I know of](https://github.com/ORileyTan/OVKLToolSysSCR)). However, what sets apart Lovely-Screensaver is its implementation of the "/p" argument, making this the first ever 100% functional screensaver with showtime, config and preview all running.

The program handles Windows' standard screensaver arguments appropiately and displays either itself or a messagebox. 
The following table denotes what happens when an argument ("MODE") is passed by Windows into the screensaver.

|MODE        | RESULT|
|:---|                   :---|
|/s ("Show")|Displays the screensaver in fullscreen mode|
|/p: xxxxx ("Preview")|Displays the screensaver in a borderless window in the same position and size as the real preview window.|
|/c:xxxxx ("Configure")|Opens a simple window with text instructions to change some parameters.|

Attempting to load any other argument or load with no argument results in an info message regarding arguments. This shouldn't be visible unless the program is executed outside the Windows Screensaver logic

## Compiling and installing in Windows
1) Install or download LÖVE 11.5.
2) Add LÖVE to your path. The screensaver does not work otherwise as of now.
3) Package main.lua, conf.lua, square.lua and the lib folder into an executable following [this official guide](https://love2d.org/wiki/Game_Distribution#Creating_a_Windows_Executable). Name it as you desire, but make sure to change the extension to .scr after fusing the executable.
4) Place only your .scr file into C:\Windows\System32. Do not place any of the other files mentioned in the love2d guide there. You will need administrator permissions.
5) In your screensaver settings, this screensaver will now appear! Be warned that it may appear as an unsigned app.
6) To delete the screensaver, simply delete the .scr file from System32.

## Other OSs
Operating systems other than Windows are not planned for support. This is because the APIs vary too much between different systems to package in one proof-of-concept. 

Anyone is welcome to fork this project and port it to their own OS, but I'd humbly advise said persons to make their own version from the ground-up.
