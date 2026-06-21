local component = require "component"
local loader = {root=nil,focus=nil}
component.loader = loader
function loader:setrootnode(node)
    self.root = node
end

function loader:getrootnode()
    if not self.root then
        return
    end
    return self.root
end

function loader:setfocus(focus)
    self.focus = focus
end

function loader:setup()
    function love.load()
        love.keyboard.setKeyRepeat(true)
    end

    function love.update(dt)
        local root = loader:getrootnode()
        if not root then return end
        root:update(dt)
    end

    function love.draw()
        local root = loader:getrootnode()
        if not root then return end
        root:draw()
    end

    function love.keypressed(key, scancode, isrepeat)
        if loader.focus then
            loader.focus:emit("keydown", key, scancode, isrepeat)
        end
    end

    function love.keyreleased(key, scancode)
        if loader.focus then
            loader.focus:emit("keyup", key, scancode)
        end
    end

    function love.mousepressed(x, y, button, istouch)
        local root = loader:getrootnode()
        if not root then return end
        root:emit("click", button, x, y, istouch)
    end

    function love.mousemoved(x, y, dx, dy, istouch)
        local root = loader:getrootnode()
        if not root then return end
        root:emit("mousemoved", x, y, dx, dy, istouch)
    end
    function love.textinput(t)
        if loader.focus then
            loader.focus:emit("text", t)
        end
    end
end

return loader