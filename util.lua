local mod = {}
function mod.check(obj, type)
    return obj.type == type
end

function mod.path(...)
    local separator = package.config:sub(1, 1)
    local paths = {...}
    local pth = table.remove(paths, 1)
    while #paths > 0 do
        local p = table.remove(paths, 1)
        if not p then
            break
        end
        pth = pth .. separator .. p
    end
    return pth
end

return mod