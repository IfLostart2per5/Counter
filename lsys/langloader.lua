local langselector = require "lsys.tsle.langselector"
local path = require("util").path
local mod = {}
local ROOT = love.filesystem.getSourceBaseDirectory()
local LANGS = path(ROOT, "langs")

local paths = {

}
local function trim(s)
    return s:match("^%s*(.-)%s*$")
end

local function ghostobject()
    local ghost = {}
    local function ghostfunc()
        return ghost
    end
    local function ghostcompfunc()
        return false
    end
    return setmetatable(ghost, {
        __index=ghostfunc,
        __add=ghostfunc,
        __call=ghostfunc,
        __div=ghostfunc,
        __mul=ghostfunc,
        __sub=ghostfunc,
        __pow=ghostfunc,
        __mod=ghostfunc,
        __concat=ghostfunc,
        __unm=ghostfunc,
        __len=ghostfunc,
        __tostring=function ()
            return ""
        end,
        __eq=ghostcompfunc,
        __le=ghostcompfunc,
        __lt=ghostcompfunc
    })
end

local ghost = ghostobject()
function mod.loadlangs()
    local f, err = io.open(path(ROOT, "langsfile.txt"), "r")
    if not f then
        f, err = love.filesystem.newFile("langsfile.txt", "r")
        if not f then
            error(err)
        end
    end
    for line in f:lines() do
        local langname = trim(line)
        local langpath = path(LANGS, langname)
        local filepath = langpath .. ".lua"
        local env = setmetatable({}, {__index=function ()
            return ghost
        end})
        local func, errfunc = loadfile(filepath, "t", env)
        if not func then
            if not love.filesystem.getInfo(LANGS) then
                langpath = path("langs", langname)
                func, errfunc = load(love.filesystem.read(langpath .. ".lua"), nil, "t", env)
            end

            if not func then
                error(errfunc)
            end
        end

        func()
        assert(env.name ~= ghost, "Expected a name")
        assert(env.code ~= ghost, "Expected an ISO code")
        local country = env.country ~= ghost and "-"..env.country or ""
        local name = env.code .. country
        paths[name] = langpath
    end
    f:close()
end

function mod.resolvelanguage(code, reqkeys)
    if langselector.haslanguage(code) then
        return langselector.language(code)
    end
    if not paths[code] then
        return nil, "Language not " .. code .. " registered"
    end
    local status, result = pcall(langselector.importlanguage, paths[code])
    if not status then
        return nil, result
    end
    local lang = result
    
    for _, key in ipairs(reqkeys) do
        local def = lang.engine:string(key) or lang.engine:rule(key)
        if not def then
            return nil, "missing "..key
        end
    end

    return lang
end

return mod