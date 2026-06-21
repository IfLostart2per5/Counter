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
Add "en-RM" at the end, and save it. If you made all correctly, you will see the "en-RM" available and usable. You can see the other language files to see what you can add.
