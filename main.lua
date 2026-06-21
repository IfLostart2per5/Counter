local vbox = require "valuebox"
package.path = "C:\\Users\\ed\\luajit\\src\\lua\\?.lua;"..package.path
package.cpath = "C:\\Users\\ed\\luajit\\src\\?.dll;"..package.cpath
local cfg = require "config"
local translator = require("lsys.tsle.langselector").translator()
translator:setcurrentlanguage(cfg.language)
local curname = vbox(translator:getcurrentlanguage().name)
local lang = vbox(translator.lang)

local function changelang(code)
    cfg.cfg.language = code
    cfg.reload()
    cfg.flush()

    translator:setcurrentlanguage(code)
    curname.value = translator:getcurrentlanguage().name
    lang.value = translator.lang
end



local width, height = love.window.getMode()

local loader = require "componentloader"


local box = require "components.container"
local text = require "components.text"
local button = require "components.button"
local langbutton = require "components.langbutton"
local list = require "components.list"

local keys = {}
local function translate(key)
    if not keys[key] then
        keys[key] = vbox(lang.value[key])
        lang:onchange(function (s)
            keys[key].value = s[key]
        end)
    end
    
    return keys[key]
end
local countstring, click = translate("counter"), translate("click")
local function language(code, selected)
    local btn = langbutton:new(code, 100, 30)
    btn:onclick(function()
        if btn ~= selected.value then
            changelang(code)
            selected.value:select(false)
            selected.value = btn
        end
    end)
    return btn
end

local function languages()
    local selected = vbox(1)
    local f, err = io.open("langsfile.txt", "r")
    if not f then
        error(err)
    end
    local langs = {}
    for l in f:lines() do
        local tongue = language(l, selected)
        langs[#langs + 1] = tongue
        if l == cfg.cfg.language then
            selected.value = tongue
            tongue:select(true)
        end
    end

    return list.fromtable(langs)
end
local main = box:new()

local counter = vbox(0)
local scounter = vbox(countstring.value(0))
counter:onchange(function(v)
    scounter.value = countstring.value(v)
end)
countstring:onchange(function (v)
    scounter.value = v(counter.value)
end)
local txt = text:new(scounter)
txt:setpos(width / 2, height / 2)
local btn = button:new(click, 50, 50)
btn:onclick(function()
    counter.value = counter.value + 1
end)
btn:setpos(width / 2, width / 2 + 75)

local langs = languages()
langs:setpos(300, 100)

main:addchild(txt)
main:addchild(btn)
main:addchild(langs)
loader:setrootnode(main)
loader:setup()
