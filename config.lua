local langloader = require "lsys.langloader"
local json = require "dkjson"
local ran = false
local cfg
local function read(filename)
    local f, err = io.open(filename, "r")
    if not f then
        return nil, err
    end

    local content = f:read "*a"
    f:close()
    return content
end

local function write(filename, content)
    local f, err = io.open(filename, "w")
    if not f then
        error(err)
    end

    f:write(content)
    f:close()
end

local function check(value, ty)
    assert(value and type(value) == ty)
end
local function loadconfig()
    local content = read("config.json") or love.filesystem.read("config.json")
    local data = json.decode(content)
    check(data.language, "string")
    check(data.required_keys, "table")
    return data
end

local function configobject(config, loadedlangs)
    local methods = setmetatable({cfg=config}, {__index=config})
    if not loadedlangs then
        langloader.loadlangs()
    end
    local lang, err = langloader.resolvelanguage(config.language, config.required_keys)
    if not lang then
        error(err)
    end

    function methods.reload()
        print('LINGUAGEM', config.language)
        local lang2, err2 = langloader.resolvelanguage(methods.cfg.language, methods.cfg.required_keys)
        if not lang2 then
            error(err2)
        end
        return methods
    end

    function methods.reloadf()
        local config2 = loadconfig()
        local methods2 = configobject(config2, true)
        local lang2, err2 = langloader.resolvelanguage(config2.language, config2.required_keys)
        if not lang2 then
            error(err2)
        end
        return methods2
    end

    function methods.flush()
        local encoded = json.encode(methods.cfg)
        write("config.json", encoded)
    end

    return methods
end
local function loadall()
    if ran then
        return cfg
    end
    local config = loadconfig()
    local meths = configobject(config, false)
    ran = true
    cfg = meths
    return meths
end

return loadall()