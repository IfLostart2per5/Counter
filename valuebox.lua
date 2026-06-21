local function valuebox(x)
    local value = x
    local listeners = {}
    return setmetatable({
        onchange=function (t, fn)
            table.insert(listeners, fn)
        end,
        map = function(t, fn)
            local mapped = valuebox(fn(value))
            mapped:onchange(function (v)
                rawset(mapped, "value", fn(v))
            end)
            return mapped
        end
    },{
        __newindex=function (t, k, v)
            if k == "value" then
                value = v
                for _, l in ipairs(listeners) do
                    l(v)
                end
            end
        end,
        __index=function (t, k)
            if k == "value" then
                return value
            end
        end
    })
end

return valuebox