local desktop_width
local desktop_height
desktop_width, desktop_height = love.graphics.getPixelDimensions()
local dpi = love.graphics.getDPIScale()
local square
local color_channels = {255, 255, 255}
local changecolor = false
local actuallydisplay = false

function love.load(args)

    square = {
        x = 0,
        y = 0,
        vx = 350,
        vy = 350,
        len = 150
    }

    local mode = args[1]
    mode = string.sub(mode, 1, 2) --Windows passes a longer string for "/c:....", only the first 2 characters are relevant.

    if mode == "/s" then
        actuallydisplay = true
    end

    if not actuallydisplay then
        love.window.setFullscreen(false)
        love.window.setMode(1, 1, {borderless = true})
        love.window.setPosition(-1, -1)
        --If the string doesn't end with long space, the error message is only partially displayed
        if mode == "/p" then
            love.window.showMessageBox("Whoops!", "Windows called \"/p\".\nPreview mode is unsupported.\nThis shows up a lot, sorry.                  ", "error")
        elseif mode == "/c" then
            love.window.showMessageBox("Lovely Screensaver", "This screensaver has no configuration settings.             ", "info")
        end
        love.event.quit()
    end

end

function love.update(dt)

    if square.x > desktop_width - square.len or square.x < 0 then
        square.vx = -square.vx
        changecolor = true
    end

    if square.y > desktop_height - square.len or square.y < 0 then
        square.vy = -square.vy
        changecolor = true
    end

    square.y = square.y + (square.vy * dt)

    square.x = square.x + (square.vx * dt)

    print(desktop_width, desktop_height)

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
    if key then
        love.event.quit()
    end
end

function love.mousepressed(key)
    if key then
        love.event.quit()
    end
end

function love.mousemoved(__, __, dx, dy)
    if dx ~= 0 or dy ~= 0 then
        love.event.quit()
    end
end