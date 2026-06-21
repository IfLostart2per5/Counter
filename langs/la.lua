name = "Lingua Latina (Antiqua Roma)"
code = "la"
numerals = {
     {1000, "M"},
    {900,  "CM"},
    {500,  "D"},
    {400,  "CD"},
    {100,  "C"},
    {90,   "XC"},
    {50,   "L"},
    {40,   "XL"},
    {10,   "X"},
    {9,    "IX"},
    {5,    "V"},
    {4,    "IV"},
    {1,    "I"}
}
local function romannumeral(n)
    local str = ""
    if n < 0 then
        str = "-"
        n = -n
    end

    for _, pair in ipairs(numerals) do
        local k, v = pair[1], pair[2]
        while n >= k do
            str = str .. v
            n = n - k
        end
    end

    return str
end
definitions = {
    click = "Clica",
    counter = {{"n"}, {
        {{"n", 0}, "Clicauisti nulla uice."},
        {{"n", 1}, "Clicauisti I uice."},
        {{"n", DEFAULT}, function(n) return "Clicauisti " .. romannumeral(n) .. " uicibus." end}
    }},
}