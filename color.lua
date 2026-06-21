local color = {}


local color_mt = {
    __mul=function(t, o)
        return color.new(t[1] * o[1], t[2] * o[2], t[3] * o[3], t[4] * o[4])
    end,
    __index=color
}
function color.new(r, g, b, a)
    return setmetatable({r, g, b, a}, color_mt)
end

function color.new255(r, g, b, a)
    return color.new(r/255, g/255, b/255, a/255)
end
function color:unpack()
    return self[1], self[2], self[3], self[4]
end

return color