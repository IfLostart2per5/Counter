local component = require "component"

local text = component.create()
local printed = {}
function printonce(...)
    local tbl = {...}
    for i = 1, #tbl do
        tbl[i] = tostring(tbl[i])
    end
    local res = table.concat(tbl, "   ")
    if not printed[res] then
        print(res)
        printed[res] = true
    end
end
function text:init(receiver, font, size)
    component.init(self, "text")
    self.text = receiver
    self.oldtext = receiver.value
    self.font = font or love.graphics.newFont(size or 50, "mono")
    self.comp = love.graphics.newText(self.font, self.text.value)
    self:setsize(self.comp:getDimensions())
end


function text:update(dt)
    printonce("estou a ser chamado", self.swap, self.text)
    if self.oldtext ~= self.text.value then
        self.comp:set(self.text.value)
        self:setsize(self.comp:getDimensions())
        self.oldtext = self.text.value
    end
end
function text:draw()
    local box = self:getbox()
    love.graphics.draw(self.comp, box.x1, box.y1)
end

return text