# Lovely Screensaver
Made with [LÖVE2D](https://love2d.org)

## What is this?

Lovely Screensaver is a very simple proof-of-concept screensaver made with LÖVE2D. It consists of a single square bouncing across a black background.

The program parses Windows' standard screensaver arguments and displays either itself or a messagebox. The following table denotes what happens in each mode

|MODE        | RESULT|
|:---|                   :---|
|/s ("Show")|Displays the screensaver in fullscreen mode|
|/p ("Preview")|Displays an error box messaging that preview is not supported|
|/c ("Configure")|Displays an info box messaging that there is nothing to configure|

## Compling and installing in Windows
1) Install or download LÖVE 11.5.
2) Add LÖVE to your path. The screensaver does not work otherwise as of now.
3) Package main.lua and conf.lua into an executable following [this official guide](https://love2d.org/wiki/Game_Distribution#Creating_a_Windows_Executable). Name it as you desire, but make sure to change the extension to .scr after fusing the executable.
4) Place the .scr into C:\Windows\System32
5) In your screensaver settings, this screensaver will now appear!

## Other OSs
Operating systems other than Windows are not planned for support. This is because the APIs vary too much between different systems to package in one proof-of-concept. 

Anyone is welcome to fork this project and port it to their own OS, but I'd humbly advise said persons to make their own version from the ground-up.