local component = require "component"
local utf8 = require("utf8")
local input = component.create()
local hover, mouse = require "enums.hover", require "enums.mouse"
function input:init(label, receiver, w, h)
    w = w or 100
    h = h or 30
    component.init(self, "input")
    self.active = false
    self.timer = 0
    self.label = label
    self.input = receiver
    self.cursor = true
    self.bar = false
    self.sendf = nil
    self:setsize(w, h)
    --self:setanchor(component.START, component.END)
end

function input:deletechar()
    local byteoffset = utf8.offset(self.input.value, -1)
    if byteoffset then
        self.input.value = self.input.value:sub(1, byteoffset - 1)
    end
end

function input.on:keydown(key)
        
            if key == "backspace" then
                self:deletechar()
            elseif key == "return" then
                self.active = false
                if self.sendf then
                    self.sendf(self.input)
                end
            end
end

function input.on:hover(side)
    self.bar = side == hover.IN
end

function input.on:click(button, x, y)
    print(button, mouse.LEFT)
    if button == mouse.LEFT then
        if self:getbox():isinside(x, y) then
            self:focuse()
        else
            self:unfocuse()
        end
    end
end
function input.on:text(t)
    --print("endereço recebido do self", self, t)
    self.input.value = self.input.value .. t
end

function input:onsend(func)
    self.sendf = func
end

function input:update(dt)
    if self.states.focused then
        self.timer = self.timer + dt
        if self.timer >= 0.5 then
            self.cursor = not self.cursor
            self.timer = 0
        end
    end
end

function input:draw()
    local box = self:getbox()
    local r, g, b, a
    local str = self.input.value..((self.cursor and self.states.focused) and "|" or "")
    local w, h = self:getsize()
    love.graphics.setScissor(box.x1, box.y1, w, h)
    love.graphics.printf(str, box.x1 + 5, box.y1 + 3, w - 5, "left")
    love.graphics.setScissor()
    r, g, b, a = love.graphics.getColor()
    if self.input.value == "" then
        love.graphics.setColor(r, g, b, 0.5)
        love.graphics.printf(self.label, box.x1 + 5, box.y1 + 3, w - 5, "left")
        love.graphics.setColor(r, g, b, a)
    end
    if self.bar then
        love.graphics.setColor(1, 1, 1)
    else
        love.graphics.setColor(1, 1, 1, 0.6)
    end
    love.graphics.line(box.x1, box.y2, box.x2, box.y2, box.x2, box.y1, box.x1, box.y1, box.x1, box.y2)
    love.graphics.setColor(r, g, b, a)
end

return input