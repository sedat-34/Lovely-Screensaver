Object = require "lib.classic"
require "square"

local border_x
local border_y
local desktop_width

local dpi = love.graphics.getDPIScale()
local squares
local actuallydisplay = false
local previewmodescale = 1/2.5
local mode

function love.load(args)

    border_x, border_y = love.graphics.getPixelDimensions()
    desktop_width = border_x --Since the program inits as fullscreen there's no difference as of yet.

    squares = {
        Square(border_x, border_y),
        Square(border_x, border_y),
    }

    mode = args[1]
    if mode then
        mode = string.lower(mode)
        mode = string.sub(mode, 1, 2) --Windows passes a longer string for "/c:....", only the first 2 characters are relevant.
    end

    if mode == "/s" then --Actual screensaver mode
        actuallydisplay = true

    elseif mode == "/p" then --Preview mode, gets called by windows when the screensaver is selected and/or the screensavers menu is loaded.
        actuallydisplay = true

        --Disable fullscreen, resize window and borders to be small
        love.window.setFullscreen(false)
        love.window.updateMode(border_x * previewmodescale, border_y * previewmodescale)
        border_x, border_y = love.graphics.getPixelDimensions()

        --Position window at the left of the screen and center it for height
        local __, y = love.window.getPosition()
        love.window.setPosition(desktop_width/2, y)

        --Resize and re-speed the square based on the preview mode scale
        for key, __ in pairs(squares) do
            for param, value in pairs(squares[key]) do
                if type(value) ~= "number" then break end
                squares[key][param] = value * previewmodescale
            end
        end

        love.window.setTitle("Lovely Screensaver: Windows-Called Preview")

    end

    if not actuallydisplay then
        print("The program chose not to be displayed!")
        love.window.setFullscreen(false)
        love.window.setMode(1, 1, {borderless = true})
        love.window.setPosition(-1, -1)
        --If the string doesn't end with long space, the error message is only partially displayed
        if mode == "/c" then
            love.window.showMessageBox("Lovely Screensaver", "This screensaver has no configuration settings.             ", "info")
        else
            love.window.showMessageBox("Lovely Screensaver", "No correct argument was called! Try calling with /s!             ", "info")
        end
        love.event.quit()
    end

end

function love.update(dt)

    for square, __ in ipairs(squares) do
        squares[square]:update(dt)
    end

end

function love.draw()

    love.graphics.push()
    love.graphics.scale(1/dpi, 1/dpi)

    --Display info regarding the "preview" button.
    if mode == "/p" then
        love.graphics.setColor(1,1,1)
        love.graphics.print("Windows-called preview mode.\nNot to be confused with the \"Preview\" button.")
    end

    for square, __ in ipairs(squares) do
        squares[square]:draw()
    end

    love.graphics.pop()

end

function love.keypressed(key)
    if key and mode == "/s" then
        love.event.quit()
    end
end

function love.mousepressed(key)
    if key and mode == "/s" then
        love.event.quit()
    end
end

function love.mousemoved(__, __, dx, dy)
    if (dx > 2 or dy > 2) and mode == "/s" then
        love.event.quit()
    end
end