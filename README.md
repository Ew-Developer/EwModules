# EwModules
EwModules is a Module for Roblox. It has a variety of other libraries in it.
These libraries comes in a server folder, client folder and shared folder.

Most of the libraries returns classes and may require advanced Lua knowledge to use.
# Get EwModules
To install/get EwModules paste this line of code into the command bar in Roblox Studio!
```lua
local a = game:GetService("HttpService") local b = a.HttpEnabled or true local c = "https://raw.githubusercontent.com/Ew-Developer/EwModules/main/Install.lua" pcall(function() a.HttpEnabled = true end) loadstring(a:GetAsync(tostring(c)))() pcall(function() a.HttpEnabled = b end)
```
