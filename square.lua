Square = Object:extend()

function Square:new(border_x, border_y, length)
    self.len = tonumber(length)
    self.x = love.math.random(1, border_x - (self.len + 1))
    self.y = love.math.random(1, border_y - (self.len + 1))
    self.vx = love.math.random(200, 350)
    self.vy = love.math.random(200, 350)
    self.vx = self.vx * ((-1) ^ love.math.random(1,2))
    self.vy = self.vy * ((-1) ^ love.math.random(1,2))
    self.color_channels = {
        love.math.random(100, 255)/255,
        love.math.random(100, 255)/255,
        love.math.random(100, 255)/255,
    }
    self.border_x = border_x
    self.border_y = border_y
end

function Square:update(dt)

    if self.x > self.border_x - self.len or self.x < 0 then
        self.vx = -self.vx
        self.color_channels = {
            love.math.random(100, 255)/255,
            love.math.random(100, 255)/255,
            love.math.random(100, 255)/255,
        }
    end

    if self.y > self.border_y - self.len or self.y < 0 then
        self.vy = -self.vy
        self.color_channels = {
            love.math.random(100, 255)/255,
            love.math.random(100, 255)/255,
            love.math.random(100, 255)/255,
        }
    end

    self.y = self.y + (self.vy * dt)

    self.x = self.x + (self.vx * dt)
end

function Square:draw()
    love.graphics.setColor(self.color_channels[1], self.color_channels[2], self.color_channels[3])
    love.graphics.rectangle("fill", self.x, self.y, self.len, self.len)
end

function Square:scaleparams(scale)
    for k, v in pairs(self) do
        if type(self[k]) == "number" then
            self[k] = v * scale
        end
    end
end