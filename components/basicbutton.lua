local component = require "component"
local mouse, hover = require "enums.mouse", require "enums.hover"
local color = require "color"

local basicbutton = component.create()
basicbutton.STANDARDCOLOR = color.new(1, 1, 1, 1)
function basicbutton:init(weight, height)
    self.clickfunc = function()end
    self.hovered = false
    self.pressed = false
    self:setsize(weight, height)
    self.basiccolor = basicbutton.STANDARDCOLOR
    self:addcolor("neutralcolor", color.new(0.5, 0.5, 0.5, 1))
    self:addcolor("hovercolor", color.new(0.2, 0.2, 0.2, 0.91))
    self:addcolor("presscolor", color.new(0.25, 0.25, 0.25, 1))
    self.color = basicbutton.STANDARDCOLOR
    self.clicktimer = 0
end

function basicbutton:onclick(func)
    self.clickfunc = func
end

function basicbutton.on:click(button, x, y)
    if button == mouse.LEFT then
        local box = self:getbox()
        if box:isinside(x, y) then
            self.clicktimer = 0.3
            self.clickfunc()
        end
    end
end

function basicbutton.on:hover(side)
    print("siiim")
    self.hovered = side == hover.IN
end

function basicbutton:update(dt)
    if self.clicktimer > 0 then
        self.pressed = true
        self.color = self:getcolor("presscolor") * self.basiccolor
        self.clicktimer = self.clicktimer - dt
    else
        self.pressed = false
        self.color = self.hovered and self:getcolor("hovercolor") * self.basiccolor or self:getcolor("neutralcolor") * self.basiccolor
    end
end

function basicbutton:draw()
    local box = self:getbox()
    self:colored(self.color, function ()
        love.graphics.rectangle("fill", box.x1, box.y1, self:getsize())
    end)
end

return basicbutton