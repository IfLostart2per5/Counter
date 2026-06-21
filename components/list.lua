local component = require "component"

local list = component.create()

function list:init(orientation)
    component.init(self, "list")
    self.height = 0
end

function list.fromtable(tbl)
    local l = list:new()
    for _, v in ipairs(tbl) do
        l:push(v)
    end
    return l
end

function list:push(element)
    self:addchild(element)
    local _, h = element:getsize()
    local box = self:getbox()
    element:setpos(box:coord(0, self.height))
    self.height = self.height + h
end

function list:setpos(x, y)
    component.setpos(self, x, y)
    local height = 0
    local box = self:getbox()
    for _, node in ipairs(self.children) do
        local _, h = node:getsize()
        node:setpos(box:coord(0, height))
        height = height + h
    end
end

return list