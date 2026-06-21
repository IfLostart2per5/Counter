local component = require "component"
local input = require "components.input"

local dynamicinput = component.create(input)

function dynamicinput:init(labelreceiver, receiver, w, h)
    input.init(self, labelreceiver.value, receiver, w, h)
    self.labelreceiver = labelreceiver
    labelreceiver:onchange(function (v)
        if self.label ~= v then
            self.label = v
        end
    end)
end

function dynamicinput:update(dt)
    input.update(self, dt)
    self.label = self.labelreceiver.value
end

return dynamicinput