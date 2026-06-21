---Component system
local enums = require "enums"
--that will be defined by loader
local component = {loader=nil}
local compmark = {}
component.mt = {__index=component}
component.mark = compmark
local function eventregisterer(parent)
    return setmetatable({}, {__index=parent})
end
component.on = eventregisterer()


local boxmeths = {
    isinside = function (self, x, y)
        return (self.x1 <= x and x <= self.x2)
        and (self.y1 <= y and y <= self.y2)
    end,
    coord = function (self, x, y)
        return self.x1 + x, self.y1 + y
    end
}
local boxmt = {
    __index=boxmeths
}

function component:new(...)
    local obj = {
            children={},
            colors={},
            pos = {x=0, y=0},
            states={
                hover=enums.hover.OUT,
                focused=false
            },
            size={w=0,h=0, ancx=enums.anchor.CENTER,ancy=enums.anchor.CENTER},
            box = setmetatable({
            x1 = 0,
            x2 = 0,
            y1 = 0,
            y2 = 0
        }, boxmt)
    }
    local trueobj = setmetatable(obj, self.mt)
    self.init(trueobj, ...)
    return trueobj
end
function component:_runonchildren(fname, ...)
    for _, v in ipairs(self.children) do
        v[fname](v, ...)
    end
end
function component:init(name)
    self.name = name
end

local stdfunc = function(...)end
function component:emit(evname, ...)
    local f = self.on[evname] or stdfunc
    local canpropagate = not f(self, ...)
    if canpropagate then self:_runonchildren("emit", evname, ...) end
    --[[if #self.children > 0 then
        for _, child in ipairs(self.children) do
            child:emit(evname, ...)
        end
    end]]
end


function component:hasevent(evname)
    return self.on[evname] and true or false
end

function component.create(parent)
    parent = parent or component
    local comp = setmetatable({}, {__index=parent})
    comp.mt = {__index=comp}
    comp.on = eventregisterer(parent.on)
    return comp
end

function component:focuse()
    if component.loader.focus and component.loader.focus.mark == compmark
     and component.loader.focus ~= self then
        component.loader.focus:unfocuse()
    end

    component.loader:setfocus(self)
    self.states.focused = true
end

function component:unfocuse()
    component.loader:setfocus()
    self.states.focused = false
end

function component:update(dt)
   self:_runonchildren("update", dt)
end

function component:draw()
    self:_runonchildren("draw")
end

function component:addcolor(index, color)
    if not color then
        color = index
        index = #self.colors + 1
    end

    self.colors[index] = color
end

function component:getcolor(index)
    return self.colors[index]
end

function component:colored(color, func)
    local r, g, b, a = love.graphics.getColor()
    local nr, ng, nb, na
    if type(color) == "table" then
        nr, ng, nb, na = color:unpack()
    else
        nr, ng, nb, na = self:getcolor(color):unpack()
    end

    love.graphics.setColor(nr, ng, nb, na)
    func()
    love.graphics.setColor(r, g, b, a)
end
function component:setpos(x, y)
    if self.pos.x ~= x then
        self.box.x1 = x - self.size.w * self.size.ancx
        self.box.x2 = x - self.size.w * self.size.ancx + self.size.w
    end
    if self.pos.y ~= y then
        self.box.y1 = y - self.size.h * self.size.ancy
        self.box.y2 = y - self.size.h * self.size.ancy + self.size.h
    end
    self.pos.x, self.pos.y = x, y
end

function component:setsize(w, h)
    if self.size.w ~= w then
        self.box.x1 = self.pos.x - w * self.size.ancx
        self.box.x2 = self.pos.x - w * self.size.ancx + w
    end
    if self.size.h ~= h then
        self.box.y1 = self.pos.y -h * self.size.ancy
        self.box.y2 = self.pos.y - h * self.size.ancy + h
    end
    self.size.w, self.size.h = w, h
end

function component:getsize()
    return self.size.w, self.size.h
end

function component:setanchor(x, y)
    if x == enums.anchor.CENTER or x == enums.anchor.START or x == enums.anchor.END then
        self.size.ancx = x
        self.box.x1 = self.pos.x - self.size.w * self.size.ancx
        self.box.x2 = self.pos.x - self.size.w * self.size.ancx + self.size.w
    end
    if y == enums.anchor.CENTER or y == enums.anchor.START or y == enums.anchor.END then
        self.size.ancy = y
        self.box.y1 = self.pos.y - self.size.h * self.size.ancy
        self.box.y2 = self.pos.y - self.size.h * self.size.ancy + self.size.h
    end
end

function component:addchild(child)
    table.insert(self.children, child)
end

function component:popchild(index)
    if not index then
        return table.remove(self.children, #self.children)
    else
        return table.remove(self.children, index)
    end
end

function component:getchild(index)
    return self.children[index]
end

function component:getpos()
    return self.pos.x, self.pos.y
end
function component:getbox()
    return self.box
end


function component.on:mousemoved(x, y, dx, dy, istouch)
    local compbox = self:getbox()
    if self.on.hover then
        if compbox:isinside(x, y) then
            if self.states.hover == enums.hover.OUT then
                self:emit("hover", enums.hover.IN)
                self.states.hover = enums.hover.IN
            end
        else
            if self.states.hover == enums.hover.IN then
                self:emit("hover", enums.hover.OUT)
                self.states.hover = enums.hover.OUT
            end
        end
    end
end
return component