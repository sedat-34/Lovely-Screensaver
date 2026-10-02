local border_x
local border_y
local desktop_width

local dpi = love.graphics.getDPIScale()
local square
local color_channels = {255, 255, 255}
local changecolor = false
local actuallydisplay = false
local previewmodescale = 1/2.5
local mode

function love.load(args)

    border_x, border_y = love.graphics.getPixelDimensions()
    desktop_width = border_x --Since the program inits as fullscreen there's no difference as of yet.

    square = {
        x = 0,
        y = 0,
        vx = 350,
        vy = 350,
        len = 150
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
        for key, value in pairs(square) do
            square[key] = value * previewmodescale
        end

        love.window.setTitle("Lovely Screensaver: Preview Mode!")

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
            love.window.showMessageBox("Lovely Screensaver", "No correct argument was called!             ", "info")
        end
        love.event.quit()
    end

end

function love.update(dt)

    print("Ooh, an update loop!")

    if square.x > border_x - square.len or square.x < 0 then
        square.vx = -square.vx
        changecolor = true
    end

    if square.y > border_y - square.len or square.y < 0 then
        square.vy = -square.vy
        changecolor = true
    end

    square.y = square.y + (square.vy * dt)

    square.x = square.x + (square.vx * dt)

    print(border_x, border_y)

end

function love.draw()

    love.graphics.push()
    love.graphics.scale(1/dpi, 1/dpi)

    if changecolor then
        color_channels[1] = love.math.random(63,255)
        color_channels[2] = love.math.random(63,255)
        color_channels[3] = love.math.random(63,255)
        love.graphics.setColor(color_channels[1]/255, color_channels[2]/255, color_channels[3]/255)
        changecolor = false
    end

    love.graphics.rectangle("fill", square.x, square.y, square.len, square.len)

    love.graphics.pop()

end

function love.keypressed(key)
    if key and mode ~= "/p" then
        love.event.quit()
    end
end

function love.mousepressed(key)
    if key and mode ~= "/p" then
        love.event.quit()
    end
end

function love.mousemoved(__, __, dx, dy)
    if (dx > 2 or dy > 2) and mode ~= "/p" then
        love.event.quit()
    end
end