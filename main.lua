Object = require "lib.classic"

--FFI's only purpose here is to grab the id of the preview window so thee screensaver pretends to display within it.
local ffi = require("ffi")

ffi.cdef[[

    typedef void* HWND;
    typedef int BOOL;

    typedef struct {
        int left;
        int top;
        int right;
        int bottom;
    } RECT, *LPRECT;

    BOOL GetWindowRect(HWND hWnd, LPRECT lpRect);

]]

local user32 = ffi.load("user32")

require "square"

local border_x
local border_y
local desktop_width
local desktop_height

local dpi = love.graphics.getDPIScale()
local squares = {}

--Default values for user configurations, doubles as failsaves.
local squarecount = 40
local squarelength = 150
local displayWallpaper = 0
local truewallpaperpath = ""
local wallpaperextension = ""
local savefile = "savefile.txt"
local configfont
local savedata = {}

local squarecounttimer = 0

local actuallydisplay = false
local configtime = false
local previewmodescale = 1/2.5 --legacy variable, kept for /c mode.
local previewmodescaleX
local previewmodescaleY

local mode
local arguments
local ProvidedHWND

local starttime = os.time()
--Fair assumption. Real FPS gets checked after first update.
local deltatime = 1/60

local realWallPaper

local function getWindowRect(hwnd)
    --Convert hwnd from string to void*
    local fakeHWND = tonumber(hwnd)
    local trueHWND = ffi.cast("HWND", fakeHWND)
    local rect = ffi.new("RECT") --init blank rect object
    local success = user32.GetWindowRect(trueHWND, rect) --rect now carries the info from the window of the HWND
    if success ~= 0 then
        return {
            x = rect.left,
            y = rect.top,
            width = rect.right - rect.left,
            height = rect.bottom - rect.top
        }
    end
end

function love.load(args)

    arguments = args

    local font = love.graphics.newFont(30)
    love.graphics.setFont(font)

    --Read and interpret the saved configurations. This method is not ideal for many customizations.
    if love.filesystem.read(savefile) then

        local iterator = 1
        for line in love.filesystem.lines(savefile) do
            savedata[iterator] = line
            iterator = iterator + 1
        end
        if savedata[1] then squarecount = tonumber(savedata[1], 10) end
        if savedata[2] then squarelength = tonumber(savedata[2], 10) end
        if savedata[3] then displayWallpaper = tonumber(savedata[3], 10) end
        if savedata[4] then truewallpaperpath = savedata[4] end
        if savedata[5] then wallpaperextension = savedata[5] end
        for i, c in ipairs(savedata) do
            print(c)
        end
    end

    border_x, border_y = love.window.getDesktopDimensions()
    love.window.setPosition(-border_x-1,-border_y-1)
    desktop_width, desktop_height = border_x, border_y

    for i = 1, squarecount do
        squares[i] = Square(border_x, border_y, squarelength)
    end

    mode = arguments[1]
    if mode then
        mode = string.lower(mode)
        mode = string.sub(mode, 1, 2) --Windows passes a longer string for "/c:....", only the first 2 characters are relevant.
    end
    if arguments[2] then ProvidedHWND = arguments[2] end

    if mode == "/s" then --Actual screensaver mode
        love.window.setPosition(0,0)
        love.window.setFullscreen(true)
        love.mouse.setVisible(false)
        actuallydisplay = true

    elseif mode == "/p" then --Preview mode, gets called by windows when the screensaver is selected and/or the screensavers menu is loaded.
        actuallydisplay = true

        --Can't run a preview when not previewing. Shocker.
        if not ProvidedHWND then assert(nil, "No ProvidedHWND!") end
        local newWindowInfo = getWindowRect(ProvidedHWND) --Returns a table generated from a C struct.
        if not newWindowInfo then assert(nil, ProvidedHWND) end

        --The image is warped in a screen ratio mismatch scenario, but there is no clean solution to this.
        previewmodescaleX = newWindowInfo.width/border_x
        previewmodescaleY = newWindowInfo.height/border_y

        --Pretend the tiny window is used, actually put a small window where the window is of it like a boss.
        love.window.updateMode(newWindowInfo.width, newWindowInfo.height, {borderless = true})
        love.window.setPosition(newWindowInfo.x, newWindowInfo.y)
        border_x, border_y = love.graphics.getPixelDimensions()

        love.window.setTitle("Lovely Screensaver: Windows-Called Preview")

    elseif mode == "/c" then
        configtime = true
        love.window.updateMode(border_x * previewmodescale, border_y * previewmodescale)
        --Center the configuration window on the screen.
        local windowWidth, windowHeight = love.graphics.getPixelDimensions()
        love.window.setPosition(desktop_width/2 - windowWidth/2 , desktop_height/2 - windowHeight/2)

        love.window.setTitle("Lovely Wallpaper: Configuration \"Menu\"")

    end

    --Grab user wallpaper (only on demand!)
    --Some of these conditions are for compatibility with old version save files. The images don't get loaded.
    if mode ~= "/c" and displayWallpaper == 1 and truewallpaperpath and truewallpaperpath ~= "" and wallpaperextension and wallpaperextension ~= "" then
        local wpFile = assert(io.open(truewallpaperpath, "rb"), "Your background was not found. Please toggle wallpaper display in the configuration menu (Settings button in the windows screensaver UI.). If that doesn't work, please raise an issue on github.")
        print(wpFile)
        local wpFileContents = wpFile:read("a")
        wpFile:close()
        local wpFileData = love.filesystem.newFileData(wpFileContents, "wallpaper"..wallpaperextension)
        realWallPaper = love.graphics.newImage(wpFileData)
    end

    if not (actuallydisplay or configtime) then
        print("The program chose not to be displayed!")
        love.window.setFullscreen(false)
        love.window.setMode(1, 1, {borderless = true})
        love.window.setPosition(-1, -1)
        --If the string doesn't end with long space, the error message is only partially displayed
        love.window.showMessageBox("Lovely Screensaver", "No correct argument was called! Try calling with /s!             ", "info")
        love.event.quit()
    end

end

function love.update(dt)

    if actuallydisplay then
        for square, __ in ipairs(squares) do
            squares[square]:update(dt)
        end

    elseif configtime then
        if love.keyboard.isDown("down") and squarecount > 1 then
            squarecounttimer = squarecounttimer - dt * 3
            if math.abs(squarecounttimer) >= 1 then
                squarecounttimer = 0
                squarecount = squarecount - 1
            end
        elseif love.keyboard.isDown("up") then
            squarecounttimer = squarecounttimer - dt * 3
            if math.abs(squarecounttimer) >= 1 then
                squarecounttimer = 0
                squarecount = squarecount + 1
            end
        end

        if love.keyboard.isDown("w") then
            squarecounttimer = squarecounttimer - dt * 6
            if math.abs(squarecounttimer) >= 1 then
                squarecounttimer = 0
                squarelength = squarelength + 1
            end
        elseif love.keyboard.isDown("s") then
            squarecounttimer = squarecounttimer + dt * 6
            if math.abs(squarecounttimer) >= 1 then
                squarecounttimer = 0
                squarelength = squarelength - 1
            end
        end

    end
    deltatime = dt
end

function love.draw()
    love.graphics.setColor(1,1,0)

    love.graphics.setColor(1,1,1)

    love.graphics.push()

    --Handle scaling per mode.
    if mode == "/p" then
        love.graphics.scale(1/dpi * previewmodescaleX, 1/dpi * previewmodescaleY)
    else
        love.graphics.scale(1/dpi, 1/dpi)
    end

    --Display the wallpaper (or not).
    if mode ~= "/c" and displayWallpaper == 1 and realWallPaper then
        if mode == "/s" then
            love.graphics.draw(realWallPaper)

        elseif mode =="/p" then
            love.graphics.draw(realWallPaper)

        end
    end

    if actuallydisplay then
        love.graphics.setColor(1,1,1)
        for square, __ in ipairs(squares) do
            squares[square]:draw()
        end

    elseif configtime then
        love.graphics.setColor(0,1,1)
        local step = love.graphics.getHeight()/15
        if not configfont then
            configfont = love.graphics.newFont(step)
        end
        love.graphics.setFont(configfont)
        love.graphics.print("Number of squares: "..squarecount)
        love.graphics.print("Hold up or down to change!", 0, step)
        love.graphics.print("Length of squares (pixels): "..squarelength, 0, step*3)
        love.graphics.print("Hold w to increase, s to decrease!", 0, step*4)
        love.graphics.print("Display desktop wallpaper behind the squares: "..displayWallpaper, 0, step*6)
        love.graphics.print("Press space to toggle. 0 = off, 1 = on", 0, step*7)
        love.graphics.print("Toggle this whenever you change or delete your wallpaper or its file.", 0, step*8)
        love.graphics.setColor(1,0,0)
        love.graphics.print("Leaving this on may cause screen burn-in on OLEDs and CRTs.", 0, step*9)
        love.graphics.setColor(0,1,0)
        love.graphics.print("Exiting auto-saves your preferences.", 0, step*11)
        love.graphics.setColor(1,0,1)
        love.graphics.print("Lovely-Screensaver (c) 2026 Sedat Ariturk", 0, step*15)
        love.graphics.print("See LICENSE, README, love-license", 0, step*16)

    end

    love.graphics.pop()

end

function love.keypressed(key)

    if key and mode == "/s" then
        collectgarbage("collect")
        love.event.quit()

    --Toggle whether the wallpaper will be displayed next time the wp runs.
    elseif key and mode == "/c" then
        if key == "space" then
                if displayWallpaper == 0 then displayWallpaper = 1
                    local getWp = assert(io.popen('powershell -Command "Get-ItemPropertyValue -Path \\"HKCU:\\Control Panel\\Desktop\\" -Name \\"WallPaper\\""'))
                    if getWp then
                    truewallpaperpath = getWp:read("L")
                    getWp:close()
                    wallpaperextension = truewallpaperpath:match("^.+(%..+)$") --Match the file extension.
                    truewallpaperpath = string.gsub(truewallpaperpath, "[\r\n]", "") --The newlines created by the Powershell output
                    print(truewallpaperpath)
                    end
                elseif displayWallpaper == 1 then displayWallpaper = 0
                    truewallpaperpath = ""
                    wallpaperextension = ""
                end
        end
    end

end

function love.mousepressed(key)
    if key and mode == "/s" then
        collectgarbage("collect")
        love.event.quit()
    end
end

function love.mousemoved(__, __, dx, dy)
    if (dx > 2 or dy > 2) and mode == "/s" and os.time() - starttime >= 3*deltatime then
        collectgarbage("collect")
        love.event.quit()
    end
end

function love.focus(focus)
    if mode == "/p" and not focus then
        love.event.quit()
    end
end

function love.quit()
    if mode == "/c" then
        love.filesystem.write(savefile, squarecount.."\r\n"..squarelength.."\r\n"..displayWallpaper.."\r\n"..truewallpaperpath.."\r\n"..wallpaperextension)
        print(savefile, squarecount.."\r\n"..squarelength.."\r\n"..displayWallpaper.."\r\n"..truewallpaperpath.."\r\n"..wallpaperextension)
    end
end