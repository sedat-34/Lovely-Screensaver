Object = require "lib.classic"
require "square"

local border_x
local border_y
local desktop_width

local dpi = love.graphics.getDPIScale()
local squares = {}

--Default values for user configurations, doubles as failsaves.
local squarecount = 40
local squarelength = 150
local displayWallpaper = 0
local savefile = "savefile.txt"
local configfont
local savedata = {}

local squarecounttimer = 0

local actuallydisplay = false
local configtime = false
local previewmodescale = 1/2.5

local mode

local starttime = os.time()
--Fair assumption. Real FPS gets checked after first update.
local deltatime = 1/60

local realWallPaper

function love.load(args)

    love.mouse.setVisible(false)

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
    end

    border_x, border_y = love.window.getDesktopDimensions()
    desktop_width = border_x --border_x is initially the screen width, it's the same value

    for i = 1, squarecount do
        squares[i] = Square(border_x, border_y, squarelength)
    end

    mode = args[1]
    if mode then
        mode = string.lower(mode)
        mode = string.sub(mode, 1, 2) --Windows passes a longer string for "/c:....", only the first 2 characters are relevant.
    end

    if mode == "/s" then --Actual screensaver mode
        love.window.setFullscreen(true)
        actuallydisplay = true

    elseif mode == "/p" then --Preview mode, gets called by windows when the screensaver is selected and/or the screensavers menu is loaded.
        actuallydisplay = true

        --Disable fullscreen, resize window and borders to be small
        love.window.updateMode(border_x * previewmodescale, border_y * previewmodescale)
        border_x, border_y = love.graphics.getPixelDimensions()

        --Position window at the left of the screen and center it for height
        local __, y = love.window.getPosition()
        love.window.setPosition(desktop_width/2, y)

        love.window.setTitle("Lovely Screensaver: Windows-Called Preview")

    elseif mode == "/c" then
        configtime = true
        love.window.updateMode(border_x * previewmodescale, border_y * previewmodescale)
        --Position window at the left of the screen and center it for height
        local __, y = love.window.getPosition()
        love.window.setPosition(desktop_width/2, y)

        love.window.setTitle("Lovely Wallpaper: Configuration \"Menu\"")

    end

    --Grab user wallpaper (only on demand!)
    if displayWallpaper == 1 then
            local getWp = assert(io.popen('powershell -Command "Get-ItemPropertyValue -Path \\"HKCU:\\Control Panel\\Desktop\\" -Name \\"WallPaper\\""'))
            if getWp then
            local wallpaperpath = getWp:read("L")
            getWp:close()
            local ext = wallpaperpath:match("^.+(%..+)$") --Match the file extension.

            wallpaperpath = wallpaperpath:sub(1, -2)
            local wallpaperfile = assert(io.open(wallpaperpath, "rb"))
            if wallpaperfile then
                local str = wallpaperfile:read("a")
                wallpaperfile:close()

                local filedata = love.filesystem.newFileData(str, "wallpaper"..ext)

                realWallPaper = love.graphics.newImage(filedata)
            end
        end
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

    love.graphics.setColor(1,1,1)

    love.graphics.push()

    --Handle scaling per mode.
    if mode == "/p" then
        love.graphics.scale(1/dpi * previewmodescale, 1/dpi * previewmodescale)
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
        love.graphics.setColor(1,0,0)
        love.graphics.print("Leaving this on may cause screen burn-in on OLEDs and CRTs.", 0, step*8)
        love.graphics.setColor(0,1,1)
        love.graphics.print("Exiting auto-saves your preferences.", 0, step*10)

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
            elseif displayWallpaper == 1 then displayWallpaper = 0
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
        love.filesystem.write(savefile, squarecount.."\r\n"..squarelength.."\r\n"..displayWallpaper)
    end
end