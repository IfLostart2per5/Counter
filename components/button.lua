local component = require "component"
local textcomp = require "components.text"
local basicbutton = require "components.basicbutton"
local button = component.create(basicbutton)

function button:init(txtr, w, h, fixedsize)
    self.text = txtr
    local text = textcomp:new(self.text, nil, math.min(w, h) * 0.5)
    local tw, th = text:getsize()
    basicbutton.init(self, w + (fixedsize and 0 or tw), h + (fixedsize and 0 or th))
    self:addchild(text)
end

function button:update(dt)
    basicbutton.update(self, dt)
    local txt = self:getchild(1)
    local box = self:getbox()
    local w, h = self:getsize()
    txt:setpos(box:coord(w / 2, h / 2))
    txt:update(dt)
end

function button:draw()
    basicbutton.draw(self)
    self:getchild(1):draw()
end

return button