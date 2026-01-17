
local scripts = {
    "https://raw.githubusercontent.com/trantung120213123/Hackroblox/refs/heads/main/autorj.lua",
    "https://raw.githubusercontent.com/trantung120213123/Hackroblox/refs/heads/main/autocheck.lua"
}

for _, url in ipairs(scripts) do
    pcall(function()
        loadstring(game:HttpGet(url))()
    end)
end
