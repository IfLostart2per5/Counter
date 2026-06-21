local component = require "component"

local container = component.create()

function container:init()
    component.init(self, "container")
end

return container

