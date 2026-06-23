# Counter app
A simple app made for testing TSLE

# How to build it
Install Python (3.12 or above) then run `build.py`. It will generate an executable at root folder, and  
a folder named `Counter` that contains the executable and the language configuration files.

# How to use it
It's a counter. You click on a button, and the counter grows. Simple. But it can swap languages, as some are available to test.

# How to add new languages
Create a file called `languagecode-COUNTRYCODE.lua` in the `langs/` folder (replace language code and country code by a ISO language code and its code. Country is optional, if you don't put it on the file). For this example, lets use a modified. Let's use a modified english as an example.
en-RM.lua:
```lua
name = "English"
code = "en"
country = "RM" --Roma
definitions = {
    counter = {{"n"}, {
        {{"n", 0}, "You clicked non-una vece"},
        {{"n", 1}, "You clicked una vece"},
        {{"n", DEFAULT}, "You clicked {n} veces"}
    }},
    click = "Clickare"
}
```
Done it, now edit `langsfile.txt`. If you haven't edited it, it may be like this:
```
la
pt
en
pt-TS
```
Add "en-RM" at the end, and save it. If you made all correctly, you will see the "en-RM" available and usable.

# The Language DSL
Here are all you need to know about the DSL used for programming a language (That's actually Lua, but with a special and restricted enviroment).
## Strings
You can define a simple and static string that will be used by the program:
```lua
name = "English"
code="en"
definitions = {
    hello = "Hello!",
    bye = "Bye!",
    okay = "Are you okay?"
}
```
For the app, we just have one: `click`
```lua
--...name and code
definitions = {
    click="Click"
}
```
## Rules
Maybe it's the most powerful thing in this DSL. You can declare a pattern, which produces a dynamic string. For example:
```lua
definitions = {
    counter = {{"n"}, "You have clicked {n} times."}
}
```
This `counter` rule is a list, where the first element is a list of parameters, and the second element
is a formattable string.
It's processed into a function that produces it:
```
counter(2) -> "You have clicked 2 times."
counter(5) -> "You have clicked 5 times."
counter(5043) -> "You have clicked 5043 times."
```
We can distinguish singular and plural also:
```lua
definitions = {
    counter = {{"n"},{
        {{"n", 1}, "You have clicked 1 time."},
        {{"n", DEFAULT}, "You have clicked {n} times."}
    }}
}
```
The second element of the maim list can be also a list itself, which contains **cases**. Cases are lists composed by a condition list, and a formattable string (or a function 👀).
In order to be more readable, you can alternatively write this:
```lua
definitions = {
    counter = {{"n"},{
        case{"n", 1} "You have clicked 1 time.",
        case{"n", DEFAULT} "You have clicked {n} times."
    }}
}
```
### More cases
You can add how many cases you want:
```lua
definitions = {
    counter = {{"n"},{
        case{"n", 1} "You have clicked 1 time.",
        case{"n", 2} "You have clicked twice",
        case{"n", 3} "You have clicked thrice",
        case{"n", 99} "ALMOST THERE!",
        case{"n", 100} "YEAHH ONE HUNDRED CLICKS!",
        case{"n", DEFAULT} "You have clicked {n} times."
    }}
}
```
It will work fine, as in other cases.
### Multiple cases
You can also match multiple conditions at same time. For example, we can have something like this:
```lua
definitions = {
    counter = {{"n", "voice"},{
        case{"n", 1, "voice", "boring"} "Wow, at least you clicked right?",
        case{"n", 1, "voice", "excited"} "YOU'VE CLICKED? WOW :DDDD",
        case{"n", 1, "voice", DEFAULT} "You have clicked 1 time.",
        case{"n", DEFAULT, "voice", "boring"} "Meh... My cousin did it {n*30} times.", --yeah, it supports expressions inside it
        case{"n", DEFAULT, "voice", "excited"} "{n} CLICKS? CONTINUE!",
        case{"n", DEFAULT, "voice", DEFAULT} "You have clicked {n} times."
    }}
}
```
This example is harder to understand, but you will see it's simple.
Note that it can have any qunatity of cases. But, at translating, you probably won't use more than 2 or 5.
### Functions
Lua functions can be used there.
You can use it at the conditions (as predicates) or at the results (as processors).
Taking this from `langs/` folder, we have Latin, which uses processors for showing roman numerals:
```lua
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
```
There is an algorithm to convert indo-arabian numbers to roman numbers, and then show it.
Showing some outputs of it, we have:
counter(0) -> "Clicauisti nulla uice."
counter(1) -> "Clicauisti I uice."
counter(5) -> "Clicauisti V uicibus."
counter(25) -> "Clicauisti XXV uicibus.".

We can modify it, to show you the predicates (changing it with the simple syntax):
```lua
definitions = {
    click = "Clica",
    counter = {{"n"}, {
        case{"n", 0} "Clicauisti nulla uice.",
        case{"n", 1} "Clicauisti I uice.",
        case{"n", function(n) return n % 2 == 0 end} function(n) "Hm... Clicauisti... " .. tostring(n * 2 + 1) .. " uicibus." end,
        case{"n", DEFAULT} function(n) return "Clicauisti " .. romannumeral(n) .. " uicibus." end
    }},
}
```
Here, if the count of clicks is even, he shows a "hm, clicauisti..." with a higher quantity, in indo-arabian numbers.
### Advice about functions use
It's the most powerful (and dengerous) characteristic of this DSL, because it can run arbitrary code. Its enviroment is heavily restricted, but nothing holds you to dont something like:
```lua
definitions = {
    counter = {{"n"},{
        case{"n", DEFAULT} function() while true do end end 
    }}
}
```
So avoid using any translation file that you see ou people give to you.
