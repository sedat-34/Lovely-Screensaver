local deskw
local deskh
deskw, deskh = love.graphics.getPixelDimensions()
local dpi = love.graphics.getDPIScale()
local square
local r = 255
local g = 255
local b = 255
local changecolor = false

function love.load()

    square = {
        x = 0,
        y = 0,
        vx = 350,
        vy = 350,
        len = 150
    }

end

function love.update(dt)

    if square.x > deskw - square.len or square.x < 0 then
        square.vx = -square.vx
        changecolor = true
    end

    if square.y > deskh - square.len or square.y < 0 then
        square.vy = -square.vy
        changecolor = true
    end

    square.y = square.y + (square.vy * dt)

    square.x = square.x + (square.vx * dt)

    print(deskw, deskh)

end

function love.draw()

    love.graphics.push()
    love.graphics.scale(1/dpi, 1/dpi)

    if changecolor then
        r = love.math.random(63,255)/255
        g = love.math.random(63,255)/255
        b = love.math.random(63,255)/255
        love.graphics.setColor(r, g, b)
        changecolor = false
    end

    love.graphics.rectangle("fill", square.x, square.y, square.len, square.len)

    love.graphics.pop()

end