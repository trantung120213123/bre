--====================================================
-- AUTO REJOIN PRO | PREMIUM EDITION v3.0
-- Advanced Event System + Rich Embeds + Analytics
-- By ngố
--====================================================

if getgenv().AUTO_REJOIN_V3_RUNNING then return end
getgenv().AUTO_REJOIN_V3_RUNNING = true

repeat task.wait() until game:IsLoaded()

-- ===== HTTP AUTO =====
local http_request =
    http_request or request or
    (syn and syn.request) or
    (fluxus and fluxus.request) or
    (krnl and krnl.request)

-- ===== SERVICES =====
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ===== CONFIG =====
local CONFIG = {
    ICON = "https://files.catbox.moe/wwspl0.jpg",
    WEBHOOK_URL = "https://discord.com/api/webhooks/1462052174891585752/Uzfid7IsNdsTfyEM1ao0uOcqGKqvmA0Ca7FFmxkSCx3IE0C5lJFNiQwTIBlbgTCE7uEc",
    REJOIN_DELAY = 2,
    SAVE_INTERVAL = 30
}

-- ===== FILE =====
local FILE = "AutoRejoin_Data.json"

-- ===== DATA FUNCTIONS =====
local function LoadData()
    if not isfile(FILE) then 
        return {
            totalKicks = 0,
            totalDeaths = 0,
            totalRejoins = 0,
            totalTime = 0
        }
    end
    local success, data = pcall(function()
        return HttpService:JSONDecode(readfile(FILE))
    end)
    return success and data or {totalKicks=0, totalDeaths=0, totalRejoins=0, totalTime=0}
end

local function SaveData(data)
    pcall(function()
        writefile(FILE, HttpService:JSONEncode(data))
    end)
end

-- ===== INIT DATA =====
local Data = LoadData()
local SessionStart = os.time()
local rejoining = false
local deathConn

-- ===== UTILITY =====
local function GetPing()
    return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
end

local function FormatTime(sec)
    local h = math.floor(sec/3600)
    local m = math.floor((sec%3600)/60)
    local s = sec%60
    return string.format("%02d:%02d:%02d", h,m,s)
end

local function GetRealTime()
    return "<t:" .. os.time() .. ":T>"
end

local function GetRealDate()
    return "<t:" .. os.time() .. ":d>"
end

-- ===== WEBHOOK =====
local function SendWebhook(title, desc, fields, color)
    if not http_request or CONFIG.WEBHOOK_URL == "" or CONFIG.WEBHOOK_URL == "PASTE_WEBHOOK_HERE" then 
        return 
    end

    local embed = {
        title = title,
        description = desc,
        color = color,
        fields = fields,
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ", os.time() + 7*3600),
        thumbnail = {url = "https://files.catbox.moe/49x28e.jpg"},
        footer = {
            text = "Auto Rejoin PRO v3.0",
            icon_url = "https://files.catbox.moe/49x28e.jpg"
        }
    }

    pcall(function()
        http_request({
            Url = CONFIG.WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"]="application/json"},
            Body = HttpService:JSONEncode({
                username = "Auto Rejoin PRO",
                avatar_url = "https://files.catbox.moe/49x28e.jpg",
                embeds = {embed}
            })
        })
    end)
end

-- ===== EVENTS =====
local function OnStart()
    SendWebhook(
        "🟢 STARTED",
        "Script khởi động",
        {
            {name="👤 Player", value=LocalPlayer.Name, inline=true},
            {name="🎮 Place", value=tostring(game.PlaceId), inline=true},
            {name="🕐 Time", value=GetRealTime().." "..GetRealDate(), inline=false},
            {name="📊 Stats", value="Kicks: "..Data.totalKicks.." | Deaths: "..Data.totalDeaths, inline=false}
        },
        65280
    )
end

local function OnKick(reason)
    Data.totalKicks = Data.totalKicks + 1
    local uptime = os.time() - SessionStart
    
    SendWebhook(
        "🔴 KICKED",
        "Bị kick - Đang rejoin",
        {
            {name="❌ Reason", value=reason, inline=false},
            {name="⏱️ Uptime", value=FormatTime(uptime), inline=true},
            {name="💀 Total Kicks", value=tostring(Data.totalKicks), inline=true},
            {name="🕐 Time", value=GetRealTime().." "..GetRealDate(), inline=false}
        },
        16711680
    )
end

local function OnRejoin()
    Data.totalRejoins = Data.totalRejoins + 1
    SendWebhook(
        "🔄 REJOINING",
        "Đang tìm server mới",
        {
            {name="🔄 Rejoins", value=tostring(Data.totalRejoins), inline=true},
            {name="🕐 Time", value=GetRealTime().." "..GetRealDate(), inline=true}
        },
        16744192
    )
end

local function OnDeath()
    Data.totalDeaths = Data.totalDeaths + 1
    SendWebhook(
        "☠️ DIED",
        "Nhân vật chết",
        {
            {name="💀 Deaths", value=tostring(Data.totalDeaths), inline=true},
            {name="⏱️ Uptime", value=FormatTime(os.time()-SessionStart), inline=true},
            {name="🕐 Time", value=GetRealTime().." "..GetRealDate(), inline=false}
        },
        10038562
    )
end

-- ===== REJOIN =====
local function Rejoin(reason)
    if rejoining then return end
    rejoining = true
    
    OnKick(reason or "Unknown")
    OnRejoin()
    
    task.wait(CONFIG.REJOIN_DELAY)
    SaveData(Data)
    
    local success, servers = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(
            "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?limit=100"
        ))
    end)
    
    if success then
        for _, s in pairs(servers.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                pcall(function()
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                end)
                return
            end
        end
    end
    
    pcall(function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)
    
    -- Reset flag if teleport fails
    task.delay(10, function()
        rejoining = false
    end)
end

-- ===== MINI GUI =====
pcall(function() CoreGui.AutoRejoinMini:Destroy() end)

local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "AutoRejoinMini"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,180,0,140)
frame.Position = UDim2.new(0,10,0,10)
frame.BackgroundColor3 = Color3.fromRGB(15,15,20)
frame.BorderSizePixel = 0
frame.Active = true

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0,10)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(80,50,120)
stroke.Thickness = 2

-- Modern Drag System
local dragging, dragInput, dragStart, startPos

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Avatar
local avatar = Instance.new("ImageLabel", frame)
avatar.Size = UDim2.new(0,40,0,40)
avatar.Position = UDim2.new(0.5,-20,0,8)
avatar.BackgroundTransparency = 1
avatar.Image = CONFIG.ICON
Instance.new("UICorner", avatar).CornerRadius = UDim.new(1,0)

-- Title
local title = Instance.new("TextLabel", frame)
title.Position = UDim2.new(0,0,0,52)
title.Size = UDim2.new(1,0,0,20)
title.BackgroundTransparency = 1
title.Text = "AUTO REJOIN"
title.Font = Enum.Font.GothamBold
title.TextSize = 11
title.TextColor3 = Color3.fromRGB(150,120,200)

-- Stats
local function MiniStat(y, txt, col)
    local l = Instance.new("TextLabel", frame)
    l.Position = UDim2.new(0,8,0,y)
    l.Size = UDim2.new(1,-16,0,18)
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.Gotham
    l.TextSize = 10
    l.TextColor3 = col
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Text = txt
    return l
end

local kickLbl = MiniStat(76, "💀 0", Color3.fromRGB(255,100,100))
local timeLbl = MiniStat(94, "⏱️ 00:00:00", Color3.fromRGB(100,200,255))
local deathLbl = MiniStat(112, "☠️ 0", Color3.fromRGB(200,100,255))

-- Update loop
task.spawn(function()
    while task.wait(1) do
        local t = os.time() - SessionStart
        kickLbl.Text = "💀 "..Data.totalKicks
        timeLbl.Text = "⏱️ "..FormatTime(t)
        deathLbl.Text = "☠️ "..Data.totalDeaths
    end
end)

-- ===== AUTO SAVE =====
task.spawn(function()
    while task.wait(CONFIG.SAVE_INTERVAL) do
        Data.totalTime = Data.totalTime + CONFIG.SAVE_INTERVAL
        SaveData(Data)
    end
end)

-- ===== EVENTS =====
GuiService.ErrorMessageChanged:Connect(function(msg)
    if msg ~= "" then
        Rejoin(msg)
    end
end)

LocalPlayer.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Failed then
        task.wait(2)
        Rejoin("Teleport Failed")
    end
end)

-- Death detection with disconnect fix
LocalPlayer.CharacterAdded:Connect(function(char)
    if deathConn then deathConn:Disconnect() end
    deathConn = char:WaitForChild("Humanoid").Died:Connect(function()
        OnDeath()
        SaveData(Data)
    end)
end)

game:BindToClose(function()
    Data.totalTime = Data.totalTime + (os.time() - SessionStart)
    SaveData(Data)
end)

OnStart()
print("[AUTO REJOIN PRO v3] Loaded!")
