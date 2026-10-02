Object = require "lib.classic"
require "square"

local border_x
local border_y
local desktop_width

local dpi = love.graphics.getDPIScale()
local squares = {}
local squarecount = 40
local squarelength = 150
local savefile = "savefile.txt"
local savedata = {}

local squarecounttimer = 0

local actuallydisplay = false
local configtime = false
local previewmodescale = 1/2.5

local mode

function love.load(args)

    love.mouse.setVisible(false)

    local font = love.graphics.newFont(30)
    love.graphics.setFont(font)

    if love.filesystem.read(savefile) then

        local iterator = 1
        for line in love.filesystem.lines(savefile) do
            savedata[iterator] = line
            iterator = iterator + 1
        end
        if savedata[1] then squarecount = tonumber(savedata[1]) end
        if savedata[2] then squarelength = tonumber(savedata[2]) end
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

        --Resize and re-speed the square based on the preview mode scale
        for key, __ in ipairs(squares) do
            squares[key]:scaleparams(previewmodescale)
        end

        love.window.setTitle("Lovely Screensaver: Windows-Called Preview")

    elseif mode == "/c" then
        configtime = true
        love.window.updateMode(border_x * previewmodescale, border_y * previewmodescale)
        --Position window at the left of the screen and center it for height
        local __, y = love.window.getPosition()
        love.window.setPosition(desktop_width/2, y)

        love.window.setTitle("Lovely Wallpaper: Configuration \"Menu\"")

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
end

function love.draw()

    love.graphics.push()
    love.graphics.scale(1/dpi, 1/dpi)

    if actuallydisplay then
        if mode == "/p" then
            love.graphics.setColor(0,0,0)
            love.graphics.rectangle("fill", 0, 0, border_x, border_y)
        end
        --Display info regarding the "preview" button.
        love.graphics.setColor(1,1,1)
        for square, __ in ipairs(squares) do
            squares[square]:draw()
        end
        if mode == "/p" then
            love.graphics.setColor(1,0,0)
            love.graphics.print("Windows-called preview mode.")
        end

    elseif configtime then
        love.graphics.setColor(0,1,1)
        love.graphics.print("Number of squares: "..squarecount)
        love.graphics.print("Hold up or down to change!", 0, 30)
        love.graphics.print("Length of squares (pixels): "..squarelength, 0, 60)
        love.graphics.print("Hold w to increase, s to decrease!", 0, 90)
        love.graphics.print("Exiting auto-saves your preferences.", 0, 120)

    end

    love.graphics.pop()

end

function love.keypressed(key)

    if key and mode == "/s" then
        collectgarbage("collect")
        love.event.quit()
    end

end

function love.mousepressed(key)
    if key and mode == "/s" then
        collectgarbage("collect")
        love.event.quit()
    end
end

function love.mousemoved(__, __, dx, dy)
    if (dx > 2 or dy > 2) and mode == "/s" then
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
        love.filesystem.write(savefile, squarecount.."\r\n"..squarelength)
    end
end