local component = require "component"
local button = require "components.button"
local vbox = require "valuebox"
local basicbutton = require "components.basicbutton"
local langbutton = component.create(button)
local mouse = require "enums.mouse"
function langbutton:init(code, w, h)
    button.init(self, vbox(code), w, h, true)
    self:addcolor("selected", {1, 0, 0, 1})
end

function langbutton:select(boolean)
    self.selected = boolean
end


function langbutton.on:click(buttn, x, y)
    if buttn == mouse.LEFT then
        local box = self:getbox()
        if box:isinside(x, y) then
            self:select(true)
            basicbutton.on.click(self, buttn, x, y)
        end
    end
end

function langbutton:update(dt)
    button.update(self, dt)
    self.basiccolor = self.selected and self:getcolor "selected" or basicbutton.STANDARDCOLOR
end

return langbutton