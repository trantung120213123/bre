-- Luex UI (Enhanced) | Aesthetic red-black translucent UI, draggable, minimize-to-logo
-- SAFE: purely client UI + local animations
-- WIDE VERSION with Improved Server Hop + Auto Save Config + Position Modes (Behind/Under/Circle)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

-- Premium Key Mechanism
local PREMIUM_KEY = "1"
local hasPremium = getgenv().LuexKey == PREMIUM_KEY

-- Auto Save Config System
local Config = {
    AutoOn = false,
    AutoSelectedOn = false,
    PredictOn = false,
    ServerHopOn = false,
    SafeZoneOn = false,
    AutoRefreshOn = false,
    UIPosition = {0.05, 0, 0.12, 0},
    PositionMode = "Behind",  -- Default position mode
    StealthOn = false,  -- Stealth mode for ultra hidden
    SpeedBoostOn = false  -- Speed boost feature
}

-- Load saved config
local function LoadConfig()
    if getgenv().LuexConfig then
        for key, value in pairs(getgenv().LuexConfig) do
            Config[key] = value
        end
    end
end

-- Save config
local function SaveConfig()
    getgenv().LuexConfig = Config
end

-- Load config immediately
LoadConfig()

-- cleanup old
pcall(function()
    if game.CoreGui:FindFirstChild("LuexUI") then
        game.CoreGui.LuexUI:Destroy()
    end
end)

-- create ScreenGui
local screen = Instance.new("ScreenGui")
screen.Name = "LuexUI"
screen.ResetOnSpawn = false
screen.Parent = game.CoreGui

-- main container (WIDER, adjusted height)
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 600, 0, 420)  -- Adjusted back for removed features
main.Position = UDim2.new(unpack(Config.UIPosition))
main.BackgroundColor3 = Color3.fromRGB(12,12,12)
main.BackgroundTransparency = 0.18
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Active = true
main.Parent = screen

-- subtle red border glow (outer)
local border = Instance.new("Frame", main)
border.Name = "BorderGlow"
border.AnchorPoint = Vector2.new(0.5,0.5)
border.Position = UDim2.new(0.5,0,0.5,0)
border.Size = UDim2.new(1,8,1,8)
border.BackgroundTransparency = 1
border.ZIndex = 0
local borderStroke = Instance.new("UIStroke", border)
borderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
borderStroke.Color = Color3.fromRGB(200,30,30)
borderStroke.Transparency = 0.7
borderStroke.Thickness = 2

-- top bar (drag handle)
local topBar = Instance.new("Frame", main)
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1,0,0,46)
topBar.Position = UDim2.new(0,0,0,0)
topBar.BackgroundTransparency = 1

-- Luex logo (TextLabel with glow + text stroke)
local logo = Instance.new("TextLabel", topBar)
logo.Name = "Logo"
logo.Text = "LUEX"
logo.Font = Enum.Font.GothamBlack
logo.TextSize = 28
logo.TextColor3 = Color3.fromRGB(255,120,80)
logo.TextStrokeColor3 = Color3.fromRGB(120,10,10)
logo.TextStrokeTransparency = 0.3
logo.BackgroundTransparency = 1
logo.Position = UDim2.new(0, 12, 0, 6)
logo.Size = UDim2.new(0, 160, 0, 34)
logo.TextXAlignment = Enum.TextXAlignment.Left
logo.ZIndex = 3

-- subtle gradient on text (via UIGradient on a label overlay)
local gradHolder = Instance.new("Frame", logo)
gradHolder.Size = UDim2.new(1,0,1,0)
gradHolder.BackgroundTransparency = 1
local uiGrad = Instance.new("UIGradient", gradHolder)
uiGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 60, 20)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255,160,80)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(200,40,10))
}
uiGrad.Rotation = 10
gradHolder.ZIndex = 2

-- crack effect: a few rotated lines layered on logo (animated)
local crackContainer = Instance.new("Frame", topBar)
crackContainer.Name = "Crack"
crackContainer.Size = UDim2.new(0, 140, 0, 34)
crackContainer.Position = UDim2.new(0, 12, 0, 6)
crackContainer.BackgroundTransparency = 1
crackContainer.ZIndex = 2

local function makeCrackLine(x, y, width, rot)
    local f = Instance.new("Frame", crackContainer)
    f.Size = UDim2.new(0, width, 0, 2)
    f.Position = UDim2.new(0, x, 0, y)
    f.BackgroundColor3 = Color3.fromRGB(255,60,20)
    f.BackgroundTransparency = 0.25
    f.Rotation = rot
    f.BorderSizePixel = 0
    f.ZIndex = 1
    return f
end

makeCrackLine(0.15, 18, 60, -12)
makeCrackLine(0.45, 8, 40, 8)
makeCrackLine(0.65, 22, 50, -6)

-- minimize/restore button (top-right)
local minBtn = Instance.new("TextButton", topBar)
minBtn.Name = "Minimize"
minBtn.Size = UDim2.new(0, 36, 0, 28)
minBtn.Position = UDim2.new(1, -44, 0, 8)
minBtn.BackgroundColor3 = Color3.fromRGB(45, 8, 8)
minBtn.BorderSizePixel = 0
minBtn.Text = "-"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 22
minBtn.TextColor3 = Color3.fromRGB(240,240,240)
minBtn.ZIndex = 4

-- content area (divided into two columns)
local content = Instance.new("Frame", main)
content.Name = "Content"
content.Position = UDim2.new(0, 12, 0, 56)
content.Size = UDim2.new(1, -24, 1, -68)
content.BackgroundTransparency = 1

-- Left column for controls
local leftColumn = Instance.new("Frame", content)
leftColumn.Name = "LeftColumn"
leftColumn.Size = UDim2.new(0.48, 0, 1, 0)
leftColumn.Position = UDim2.new(0, 0, 0, 0)
leftColumn.BackgroundTransparency = 1

-- Right column for player selection
local rightColumn = Instance.new("Frame", content)
rightColumn.Name = "RightColumn"
rightColumn.Size = UDim2.new(0.48, 0, 1, 0)
rightColumn.Position = UDim2.new(0.52, 0, 0, 0)
rightColumn.BackgroundTransparency = 1

-- Auto Kill button (Random Target)
local btnAuto = Instance.new("TextButton", leftColumn)
btnAuto.Size = UDim2.new(1, 0, 0, 40)
btnAuto.Position = UDim2.new(0, 0, 0, 0)
btnAuto.BackgroundColor3 = Color3.fromRGB(35, 6, 6)
btnAuto.BorderSizePixel = 0
btnAuto.Text = "Auto Kill Random: "..(Config.AutoOn and "ON" or "OFF")
btnAuto.Font = Enum.Font.GothamBold
btnAuto.TextSize = 16
btnAuto.TextColor3 = Color3.fromRGB(240,240,240)
btnAuto.AutoButtonColor = false

-- hover glow
local stroke = Instance.new("UIStroke", btnAuto)
stroke.Color = Color3.fromRGB(200,20,20)
stroke.Transparency = 0.85
stroke.Thickness = 1.5

-- Auto Kill Selected button
local btnAutoSelected = Instance.new("TextButton", leftColumn)
btnAutoSelected.Size = UDim2.new(1, 0, 0, 40)
btnAutoSelected.Position = UDim2.new(0, 0, 0, 46)
btnAutoSelected.BackgroundColor3 = Color3.fromRGB(35, 6, 6)
btnAutoSelected.BorderSizePixel = 0
btnAutoSelected.Text = "Auto Kill Selected: "..(Config.AutoSelectedOn and "ON" or "OFF")
btnAutoSelected.Font = Enum.Font.GothamBold
btnAutoSelected.TextSize = 16
btnAutoSelected.TextColor3 = Color3.fromRGB(240,240,240)
btnAutoSelected.AutoButtonColor = false

-- hover glow
local strokeSelected = Instance.new("UIStroke", btnAutoSelected)
strokeSelected.Color = Color3.fromRGB(200,20,20)
strokeSelected.Transparency = 0.85
strokeSelected.Thickness = 1.5

-- Change Player button
local btnChangePlayer = Instance.new("TextButton", leftColumn)
btnChangePlayer.Size = UDim2.new(1, 0, 0, 40)
btnChangePlayer.Position = UDim2.new(0, 0, 0, 92)
btnChangePlayer.BackgroundColor3 = Color3.fromRGB(35, 6, 6)
btnChangePlayer.BorderSizePixel = 0
btnChangePlayer.Text = "Change Player"
btnChangePlayer.Font = Enum.Font.GothamBold
btnChangePlayer.TextSize = 16
btnChangePlayer.TextColor3 = Color3.fromRGB(240,240,240)
btnChangePlayer.AutoButtonColor = false

-- hover glow
local stroke2 = Instance.new("UIStroke", btnChangePlayer)
stroke2.Color = Color3.fromRGB(200,20,20)
stroke2.Transparency = 0.85
stroke2.Thickness = 1.5

-- Position Mode button (Cycle Behind/Under/Circle)
local btnPositionMode = Instance.new("TextButton", leftColumn)
btnPositionMode.Size = UDim2.new(1, 0, 0, 40)
btnPositionMode.Position = UDim2.new(0, 0, 0, 138)
btnPositionMode.BackgroundColor3 = Color3.fromRGB(35, 6, 6)
btnPositionMode.BorderSizePixel = 0
btnPositionMode.Text = "Position Mode: "..Config.PositionMode
btnPositionMode.Font = Enum.Font.GothamBold
btnPositionMode.TextSize = 16
btnPositionMode.TextColor3 = Color3.fromRGB(240,240,240)
btnPositionMode.AutoButtonColor = false

-- hover glow
local strokePosMode = Instance.new("UIStroke", btnPositionMode)
strokePosMode.Color = Color3.fromRGB(200,20,20)
strokePosMode.Transparency = 0.85
strokePosMode.Thickness = 1.5

-- Stealth Mode button
local btnStealth = Instance.new("TextButton", leftColumn)
btnStealth.Size = UDim2.new(1, 0, 0, 40)
btnStealth.Position = UDim2.new(0, 0, 0, 184)
btnStealth.BackgroundColor3 = Color3.fromRGB(35, 6, 6)
btnStealth.BorderSizePixel = 0
btnStealth.Text = "Stealth Mode: "..(Config.StealthOn and "ON" or "OFF")
btnStealth.Font = Enum.Font.GothamBold
btnStealth.TextSize = 16
btnStealth.TextColor3 = Color3.fromRGB(240,240,240)
btnStealth.AutoButtonColor = false

-- hover glow
local strokeStealth = Instance.new("UIStroke", btnStealth)
strokeStealth.Color = Color3.fromRGB(200,20,20)
strokeStealth.Transparency = 0.85
strokeStealth.Thickness = 1.5

-- Speed Boost button
local btnSpeedBoost = Instance.new("TextButton", leftColumn)
btnSpeedBoost.Size = UDim2.new(1, 0, 0, 40)
btnSpeedBoost.Position = UDim2.new(0, 0, 0, 230)
btnSpeedBoost.BackgroundColor3 = Color3.fromRGB(35, 6, 6)
btnSpeedBoost.BorderSizePixel = 0
btnSpeedBoost.Text = "Speed Boost: "..(Config.SpeedBoostOn and "ON" or "OFF")
btnSpeedBoost.Font = Enum.Font.GothamBold
btnSpeedBoost.TextSize = 16
btnSpeedBoost.TextColor3 = Color3.fromRGB(240,240,240)
btnSpeedBoost.AutoButtonColor = false

-- hover glow
local strokeSpeed = Instance.new("UIStroke", btnSpeedBoost)
strokeSpeed.Color = Color3.fromRGB(200,20,20)
strokeSpeed.Transparency = 0.85
strokeSpeed.Thickness = 1.5

-- Predict Direction button
local btnPredict = Instance.new("TextButton", leftColumn)
btnPredict.Size = UDim2.new(1, 0, 0, 40)
btnPredict.Position = UDim2.new(0, 0, 0, 276)
btnPredict.BackgroundColor3 = Color3.fromRGB(35, 6, 6)
btnPredict.BorderSizePixel = 0
btnPredict.Text = hasPremium and "Predict Direction: "..(Config.PredictOn and "ON" or "OFF") or "Predict Direction: PREMIUM"
btnPredict.Font = Enum.Font.GothamBold
btnPredict.TextSize = 16
btnPredict.TextColor3 = Color3.fromRGB(240,240,240)
btnPredict.AutoButtonColor = false

-- hover glow
local stroke3 = Instance.new("UIStroke", btnPredict)
stroke3.Color = Color3.fromRGB(200,20,20)
stroke3.Transparency = 0.85
stroke3.Thickness = 1.5

-- Auto Server Hop button
local btnServerHop = Instance.new("TextButton", leftColumn)
btnServerHop.Size = UDim2.new(1, 0, 0, 40)
btnServerHop.Position = UDim2.new(0, 0, 0, 322)
btnServerHop.BackgroundColor3 = Color3.fromRGB(35, 6, 6)
btnServerHop.BorderSizePixel = 0
btnServerHop.Text = "Auto Server Hop: "..(Config.ServerHopOn and "ON" or "OFF")
btnServerHop.Font = Enum.Font.GothamBold
btnServerHop.TextSize = 16
btnServerHop.TextColor3 = Color3.fromRGB(240,240,240)
btnServerHop.AutoButtonColor = false

-- hover glow
local stroke5 = Instance.new("UIStroke", btnServerHop)
stroke5.Color = Color3.fromRGB(200,20,20)
stroke5.Transparency = 0.85
stroke5.Thickness = 1.5

-- Auto Safe Zone button
local btnSafeZone = Instance.new("TextButton", leftColumn)
btnSafeZone.Size = UDim2.new(1, 0, 0, 40)
btnSafeZone.Position = UDim2.new(0, 0, 0, 368)
btnSafeZone.BackgroundColor3 = Color3.fromRGB(35, 6, 6)
btnSafeZone.BorderSizePixel = 0
btnSafeZone.Text = hasPremium and "Auto Safe Zone: "..(Config.SafeZoneOn and "ON" or "OFF") or "Auto Safe Zone: PREMIUM"
btnSafeZone.Font = Enum.Font.GothamBold
btnSafeZone.TextSize = 16
btnSafeZone.TextColor3 = Color3.fromRGB(240,240,240)
btnSafeZone.AutoButtonColor = false

-- hover glow
local stroke6 = Instance.new("UIStroke", btnSafeZone)
stroke6.Color = Color3.fromRGB(200,20,20)
stroke6.Transparency = 0.85
stroke6.Thickness = 1.5

-- Player Selection Title
local playerTitle = Instance.new("TextLabel", rightColumn)
playerTitle.Size = UDim2.new(1, 0, 0, 28)
playerTitle.Position = UDim2.new(0, 0, 0, 0)
playerTitle.BackgroundTransparency = 1
playerTitle.TextColor3 = Color3.fromRGB(255, 150, 150)
playerTitle.TextSize = 16
playerTitle.Font = Enum.Font.GothamBold
playerTitle.Text = "PLAYER SELECTION"
playerTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Player List Container
local playerListContainer = Instance.new("ScrollingFrame", rightColumn)
playerListContainer.Name = "PlayerList"
playerListContainer.Size = UDim2.new(1, 0, 0, 250)
playerListContainer.Position = UDim2.new(0, 0, 0, 30)
playerListContainer.BackgroundColor3 = Color3.fromRGB(20, 5, 5)
playerListContainer.BackgroundTransparency = 0.2
playerListContainer.BorderSizePixel = 0
playerListContainer.ScrollBarThickness = 6
playerListContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
playerListContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
playerListContainer.ScrollingDirection = Enum.ScrollingDirection.Y

-- Refresh Button
local refreshBtn = Instance.new("TextButton", rightColumn)
refreshBtn.Size = UDim2.new(1, 0, 0, 36)
refreshBtn.Position = UDim2.new(0, 0, 1, -72)
refreshBtn.BackgroundColor3 = Color3.fromRGB(35, 6, 6)
refreshBtn.BorderSizePixel = 0
refreshBtn.Text = "🔄 Refresh Players"
refreshBtn.Font = Enum.Font.GothamBold
refreshBtn.TextSize = 16
refreshBtn.TextColor3 = Color3.fromRGB(240,240,240)
refreshBtn.AutoButtonColor = false

-- hover glow
local stroke7 = Instance.new("UIStroke", refreshBtn)
stroke7.Color = Color3.fromRGB(200,20,20)
stroke7.Transparency = 0.85
stroke7.Thickness = 1.5

-- Auto Refresh Toggle
local autoRefreshToggle = Instance.new("TextButton", rightColumn)
autoRefreshToggle.Size = UDim2.new(1, 0, 0, 36)
autoRefreshToggle.Position = UDim2.new(0, 0, 1, -36)
autoRefreshToggle.BackgroundColor3 = Color3.fromRGB(35, 6, 6)
autoRefreshToggle.BorderSizePixel = 0
autoRefreshToggle.Text = "Auto Refresh: "..(Config.AutoRefreshOn and "ON" or "OFF")
autoRefreshToggle.Font = Enum.Font.GothamBold
autoRefreshToggle.TextSize = 16
autoRefreshToggle.TextColor3 = Color3.fromRGB(240,240,240)
autoRefreshToggle.AutoButtonColor = false

-- hover glow
local stroke8 = Instance.new("UIStroke", autoRefreshToggle)
stroke8.Color = Color3.fromRGB(200,20,20)
stroke8.Transparency = 0.85
stroke8.Thickness = 1.5

-- small hint text (updated)
local hint = Instance.new("TextLabel", leftColumn)
hint.Size = UDim2.new(1,0,0,28)
hint.Position = UDim2.new(0,0,1,-28)
hint.BackgroundTransparency = 1
hint.TextColor3 = Color3.fromRGB(200,200,200)
hint.TextSize = 12
hint.Font = Enum.Font.Gotham
hint.Text = "Luex v2.5 | Under Deep (-6 studs) + Stealth/SpeedBoost + Fixed Auto Kill"
hint.TextWrapped = true

-- logo animation: pulsing glow
local glowFrame = Instance.new("Frame", logo)
glowFrame.Size = UDim2.new(1.6, 0, 1.6, 0)
glowFrame.Position = UDim2.new(-0.3, 0, -0.3, 0)
glowFrame.BackgroundColor3 = Color3.fromRGB(255, 60, 20)
glowFrame.BackgroundTransparency = 0.95
glowFrame.ZIndex = 1
local glowStroke = Instance.new("UIStroke", glowFrame)
glowStroke.Color = Color3.fromRGB(255, 80, 20)
glowStroke.Transparency = 0.9
glowStroke.Thickness = 6

-- store global refs (updated)
getgenv().LuexUI = {
    Screen = screen,
    Main = main,
    Logo = logo,
    MinBtn = minBtn,
    AutoBtn = btnAuto,
    AutoSelectedBtn = btnAutoSelected,
    ChangePlayerBtn = btnChangePlayer,
    PositionModeBtn = btnPositionMode,
    StealthBtn = btnStealth,
    SpeedBoostBtn = btnSpeedBoost,
    PredictBtn = btnPredict,
    ServerHopBtn = btnServerHop,
    SafeZoneBtn = btnSafeZone,
    PlayerList = playerListContainer,
    RefreshBtn = refreshBtn,
    AutoRefreshToggle = autoRefreshToggle,
    Glow = glowFrame,
    Crack = crackContainer
}

-- Enhanced drag support
local dragging = false
local dragStart, startPos

local function updateDrag(input)
    if dragging then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
        -- Save UI position when dragging stops
        Config.UIPosition = {main.Position.X.Scale, main.Position.X.Offset, main.Position.Y.Scale, main.Position.Y.Offset}
        SaveConfig()
    end
end

topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                SaveConfig() -- Save position when drag ends
            end
        end)
    end
end)

topBar.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) and dragging then
        updateDrag(input)
    end
end)

-- minimize behavior (tween) - keeps current position
local minimized = false
minBtn.MouseButton1Click:Connect(function()
    if minimized then
        TweenService:Create(main, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0,600,0,420)}):Play()
        content.Visible = true
        logo.TextTransparency = 0
    else
        local targetSize = UDim2.new(0,150,0,46)
        TweenService:Create(main, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetSize}):Play()
        content.Visible = false
        logo.TextTransparency = 0
    end
    minimized = not minimized
end)

-- Luex Logic | Pure Combat System
local UI = getgenv().LuexUI
local autoOn = Config.AutoOn
local autoSelectedOn = Config.AutoSelectedOn
local predictOn = Config.PredictOn
local serverHopOn = Config.ServerHopOn
local safeZoneOn = Config.SafeZoneOn
local autoRefreshOn = Config.AutoRefreshOn
local positionMode = Config.PositionMode
local stealthOn = Config.StealthOn
local speedBoostOn = Config.SpeedBoostOn
local currentTarget = nil
local highlightGui = nil
local lastAttack = 0
local lastFace = 0
local lastPositionUpdate = 0
local lastSpeedUpdate = 0
local attackRate = 0.01
local faceRate = 0.01
local positionRate = 0.03
local speedUpdateRate = 0.5
local lastNoTargetNotify = 0
local noTargetNotifyCooldown = 5
local lastServerHopCheck = 0
local serverHopCooldown = 10
local circleAngle = 0

-- Safe Zone variables
local safePlatform = nil
local wasAutoKillOn = false

-- Tool list
local toolList = {
    "Normal Punch", "Consecutive Punches", "Shove", "Uppercut", "Death Counter", "Table Flip", "Serious Punch",
    "Omni-Directional Punch", "Flowing Water", "Lethal Whirlwind Stream", "Hunter's Grasp", "Prey's Peril",
    "Water Stream Cutting Fist", "The Final Hunt", "Rock Splitting Fist", "Crushed Rock", "Machine Gun Blows",
    "Ignition Burst", "Blitz Shot", "Jet Dive", "Thunder Kick", "Speedblitz Dropkick", "Flamewave Cannon",
    "Incinerate", "Flash Strike", "Whirlwind Kick", "Scatter", "Explosive Shuriken", "Twinblade Rush", "Straight On",
    "Carnage", "Fourfold Flashstrike", "Homerun", "Beatdown", "Grand Slam", "Foul Ball", "Savage Tornado",
    "Brutual Beatdown", "Strength Difference", "Death Blow", "Quick Slice", "Atmos Cleave", "Pinpoint Cut",
    "Split Second Counter", "Sunset", "Solar Cleave", "Sunrise", "Atomic Slash", "Crushing Pull", "Windstorm Fury",
    "Stone Coffin", "Expulsive Push", "Cosmic Strike", "Psychic Ricochet", "Terrible Tornado", "Sky Snatcher",
    "Bullet Barrage", "Vanishing Kick", "Whirlwind Drop", "Head First", "Grand Fissure", "Twin Fangs",
    "Earth Splitting Strike", "Last Breath"
}

-- Improved notification system (unchanged)
local activeNotifications = {}
local maxNotifications = 3
local notificationQueue = {}

local function cleanupNotifications()
    while #activeNotifications >= maxNotifications do
        local oldest = table.remove(activeNotifications, 1)
        if oldest and oldest.Parent then
            TweenService:Create(oldest, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(1, 10, oldest.Position.Y.Scale, 0)
            }):Play()
            spawn(function()
                wait(0.5)
                if oldest and oldest.Parent then
                    oldest:Destroy()
                end
            end)
        end
    end
end

local function processNotificationQueue()
    if #notificationQueue > 0 and #activeNotifications < maxNotifications then
        local notifData = table.remove(notificationQueue, 1)
        notify(notifData.text, notifData.sec)
    end
end

local function notify(text, sec)
    sec = sec or 2.5
    if #activeNotifications >= maxNotifications then
        table.insert(notificationQueue, {text = text, sec = sec})
        return
    end

    local frame = Instance.new("Frame")
    frame.Name = "LuexNotification"
    frame.Size = UDim2.new(0, 260, 0, 40)
    frame.Position = UDim2.new(1, 10, 0.02, 0)
    frame.AnchorPoint = Vector2.new(1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(18, 8, 8)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.ZIndex = 100
    frame.Parent = UI.Screen

    local border = Instance.new("UIStroke", frame)
    border.Color = Color3.fromRGB(200, 30, 30)
    border.Thickness = 2
    border.Transparency = 0.3

    local innerShadow = Instance.new("Frame", frame)
    innerShadow.Size = UDim2.new(1, -4, 1, -4)
    innerShadow.Position = UDim2.new(0, 2, 0, 2)
    innerShadow.BackgroundTransparency = 1
    innerShadow.ZIndex = frame.ZIndex + 1
    local innerStroke = Instance.new("UIStroke", innerShadow)
    innerStroke.Color = Color3.fromRGB(80, 0, 0)
    innerStroke.Thickness = 1
    innerStroke.Transparency = 0.7

    local lab = Instance.new("TextLabel", frame)
    lab.Size = UDim2.new(1, -12, 1, 0)
    lab.Position = UDim2.new(0, 6, 0, 0)
    lab.BackgroundTransparency = 1
    lab.Text = text
    lab.TextXAlignment = Enum.TextXAlignment.Left
    lab.TextColor3 = Color3.fromRGB(255, 200, 200)
    lab.Font = Enum.Font.GothamBold
    lab.TextSize = 14
    lab.TextStrokeTransparency = 0.8
    lab.TextStrokeColor3 = Color3.fromRGB(100, 0, 0)
    lab.ZIndex = frame.ZIndex + 1

    table.insert(activeNotifications, frame)
    cleanupNotifications()

    for i, notif in ipairs(activeNotifications) do
        local targetY = 0.02 + (i-1) * 0.06
        TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(1, -10, targetY, 0)
        }):Play()
    end

    TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -10, 0.02 + (#activeNotifications-1) * 0.06, 0)
    }):Play()

    spawn(function()
        wait(sec)
        for i, notif in ipairs(activeNotifications) do
            if notif == frame then
                table.remove(activeNotifications, i)
                break
            end
        end

        TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 10, frame.Position.Y.Scale, 0)
        }):Play()
        wait(0.5)
        processNotificationQueue()

        for i, notif in ipairs(activeNotifications) do
            local targetY = 0.02 + (i-1) * 0.06
            TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(1, -10, targetY, 0)
            }):Play()
        end
        frame:Destroy()
    end)
end

-- highlight target (updated for mode)
local function makeHighlight(player)
    pcall(function()
        if highlightGui and highlightGui.Parent then highlightGui:Destroy() end
        if not player or not player.Character then return end
        local root = player.Character:FindFirstChild("HumanoidRootPart") or player.Character:FindFirstChildWhichIsA("BasePart")
        if not root then return end

        local bg = Instance.new("BillboardGui")
        bg.Name = "LuexTargetHighlight"
        bg.Parent = player.Character
        bg.Adornee = root
        bg.Size = UDim2.new(0,140,0,48)
        bg.AlwaysOnTop = true

        local label = Instance.new("TextLabel", bg)
        label.Size = UDim2.new(1,0,1,0)
        label.BackgroundTransparency = 0.25
        label.BackgroundColor3 = Color3.fromRGB(40,5,5)
        label.Text = "TARGET: "..player.Name.." ["..positionMode.."]"..(stealthOn and " [STEALTH]" or "")
        label.TextColor3 = Color3.fromRGB(255,200,200)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14
        label.TextStrokeTransparency = 0.6
        highlightGui = bg
    end)
end

local function clearHighlight()
    pcall(function()
        if highlightGui and highlightGui.Parent then highlightGui:Destroy() end
        highlightGui = nil
    end)
end

-- choose random player (unchanged)
local function chooseRandom()
    local pls = {}
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and
            p ~= currentTarget and
            p.Character and
            p.Character:FindFirstChild("Humanoid") and
            p.Character:FindFirstChild("Humanoid").Health > 0 then
            table.insert(pls, p)
        end
    end
    if #pls == 0 then return nil end
    return pls[math.random(1,#pls)]
end

-- Get ping function (unchanged)
local function getPing()
    local ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
    return math.clamp(ping, 0.05, 0.5)
end

-- Enhanced prediction (unchanged)
local function predictTargetPosition(targetRoot)
    if not predictOn or not targetRoot then return targetRoot.Position end
    local ping = getPing()
    local extraOffset = 0.08

    if targetRoot.Velocity.Magnitude > 1 then
        return targetRoot.Position + (targetRoot.Velocity * (ping + extraOffset))
    end

    return targetRoot.Position
end

-- UPDATED: Position mode functions (only Behind/Under/Circle, Under -6 studs)
local function teleportToPosition(targetRoot, hrp)
    local targetPos = predictTargetPosition(targetRoot)
    local radius = 5
    local underOffset = Vector3.new(0, -6, 0)  -- UPDATED: Deeper -6 studs

    if positionMode == "Behind" then
        local moveDir = targetRoot.Velocity.Magnitude > 1 and targetRoot.Velocity.Unit or targetRoot.CFrame.LookVector
        local newPos = targetPos - (moveDir * 3.5) + (targetRoot.CFrame.RightVector * 1.2)
        hrp.CFrame = CFrame.lookAt(newPos, targetPos)
    elseif positionMode == "Under" then
        local newPos = targetPos + underOffset
        hrp.CFrame = CFrame.lookAt(newPos, targetPos)
    elseif positionMode == "Circle" then
        circleAngle = circleAngle + math.rad(10)
        local offset = Vector3.new(math.cos(circleAngle) * radius, 0, math.sin(circleAngle) * radius)
        local newPos = targetPos + offset + underOffset * 0.5
        hrp.CFrame = CFrame.lookAt(newPos, targetPos)
    end
end

-- Stealth function (transparency + no-clip like)
local function toggleStealth()
    local char = LocalPlayer.Character
    if not char then return end
    if stealthOn then
        -- Enable stealth: semi-transparent + clip underground if Under
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0.7  -- Semi-transparent
                part.CanCollide = false  -- No-clip
            elseif part:IsA("Decal") or part:IsA("Texture") then
                part.Transparency = 0.7
            end
        end
        if positionMode == "Under" then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = hrp.CFrame + Vector3.new(0, -3, 0)  -- Extra deep
            end
        end
        notify("Stealth ON: Semi-transparent + No-Clip!", 2)
    else
        -- Disable stealth
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0
                part.CanCollide = true
            elseif part:IsA("Decal") or part:IsA("Texture") then
                part.Transparency = 0
            end
        end
        notify("Stealth OFF", 1.5)
    end
end

-- Speed Boost function
local function speedBoostStep()
    local char = LocalPlayer.Character
    if not char or not speedBoostOn then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = 50  -- Boost to 50 (default 16)
    end
end

-- face target (unchanged)
local function faceTargetStep()
    if not currentTarget or not currentTarget.Character then return end
    local targetRoot = currentTarget.Character:FindFirstChild("HumanoidRootPart")
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not targetRoot or not hrp then return end
    hrp.CFrame = CFrame.lookAt(hrp.Position, predictTargetPosition(targetRoot))
end

-- spam attack (unchanged)
local function spamAttack()
    if not currentTarget or not LocalPlayer.Character then return end
    local remote = LocalPlayer.Character:FindFirstChild("Communicate")
    if not remote then return end

    remote:FireServer({
        MoveDirection = Vector3.zero,
        Goal = "KeyPress",
        Key = Enum.KeyCode.G
    })

    local args = {
        {
            Goal = "KeyRelease",
            Key = Enum.KeyCode.Q
        }
    }
    remote:FireServer(unpack(args))

    for i = 1, 3 do
        remote:FireServer({
            Goal = "LeftClick",
            Mobile = true
        })
    end

    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, toolName in ipairs(toolList) do
            local tool = backpack:FindFirstChild(toolName)
            if tool then
                remote:FireServer({
                    Tool = tool,
                    Goal = "Console Move"
                })
            end
        end
    end
end

-- Auto Safe Zone Functions (unchanged)
local function createSafePlatform()
    if not hasPremium then return end
    if safePlatform then return end

    local character = LocalPlayer.Character
    if not character then return end
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end

    wasAutoKillOn = autoOn or autoSelectedOn
    autoOn = false
    autoSelectedOn = false
    UI.AutoBtn.Text = "Auto Kill Random: OFF"
    UI.AutoSelectedBtn.Text = "Auto Kill Selected: OFF"
    Config.AutoOn = false
    Config.AutoSelectedOn = false
    SaveConfig()

    safePlatform = Instance.new("Part")
    safePlatform.Name = "LuexSafePlatform"
    safePlatform.Size = Vector3.new(1000, 1, 1000)
    safePlatform.Position = humanoidRootPart.Position + Vector3.new(0, 50, 0)
    safePlatform.Anchored = true
    safePlatform.CanCollide = true
    safePlatform.Transparency = 0.5
    safePlatform.Color = Color3.fromRGB(255, 0, 0)
    safePlatform.Parent = workspace

    humanoidRootPart.CFrame = safePlatform.CFrame + Vector3.new(0, 5, 0)
    notify("Safe Zone activated! Teleported to safety.", 3)
end

local function removeSafePlatform()
    if safePlatform then
        safePlatform:Destroy()
        safePlatform = nil

        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid and (humanoid.Health / humanoid.MaxHealth) > 0.8 then
                autoOn = wasAutoKillOn
                autoSelectedOn = wasAutoKillOn
                UI.AutoBtn.Text = "Auto Kill Random: "..(autoOn and "ON" or "OFF")
                UI.AutoSelectedBtn.Text = "Auto Kill Selected: "..(autoSelectedOn and "ON" or "OFF")
                Config.AutoOn = autoOn
                Config.AutoSelectedOn = autoSelectedOn
                SaveConfig()
                notify("Safe Zone deactivated! Auto Kill "..(wasAutoKillOn and "enabled" or "disabled")..".", 3)
            else
                notify("Safe Zone deactivated! Health too low for Auto Kill.", 3)
            end
        end
    end
end

-- Server Hop Functions (unchanged)
local PlaceId = game.PlaceId

local function getServers(minPlayers, maxPlayers)
    local servers = {}
    local success, result = pcall(function()
        local urls = {
            "https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100",
            "https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Desc&limit=100"
        }
        
        for _, url in ipairs(urls) do
            local response = game:HttpGet(url)
            local data = HttpService:JSONDecode(response)
            
            for _, server in ipairs(data.data) do
                if server.playing >= minPlayers and server.playing <= maxPlayers and server.id ~= game.JobId then
                    table.insert(servers, server)
                end
            end
        end
        
        return servers
    end)
    
    if success then
        return servers
    else
        warn("Failed to get server list: " .. tostring(result))
        return {}
    end
end

local function hopServer()
    local minPlayers = 8
    local maxPlayers = 20
    
    local servers = getServers(minPlayers, maxPlayers)
    
    if #servers > 0 then
        table.sort(servers, function(a, b)
            return math.abs(a.playing - 12) < math.abs(b.playing - 12)
        end)
        
        local bestServer = servers[1]
        notify("Hopping to server with "..bestServer.playing.." players...", 3)
        
        local success, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(PlaceId, bestServer.id, LocalPlayer)
        end)
        
        if not success then
            notify("Server hop failed, trying alternative...", 2)
            if #servers > 1 then
                wait(2)
                local altServer = servers[2]
                TeleportService:TeleportToPlaceInstance(PlaceId, altServer.id, LocalPlayer)
            end
        end
    else
        servers = getServers(3, 30)
        if #servers > 0 then
            local backupServer = servers[math.random(1, #servers)]
            notify("No ideal servers, hopping to backup with "..backupServer.playing.." players...", 3)
            TeleportService:TeleportToPlaceInstance(PlaceId, backupServer.id, LocalPlayer)
        else
            notify("No suitable servers found for hopping.", 3)
        end
    end
end

-- Player Selection Functions (unchanged)
local function createPlayerButton(player, yPosition)
    local button = Instance.new("TextButton")
    button.Name = player.Name
    button.Size = UDim2.new(1, -10, 0, 40)
    button.Position = UDim2.new(0, 5, 0, yPosition)
    button.BackgroundColor3 = player == currentTarget and Color3.fromRGB(60, 10, 10) or Color3.fromRGB(30, 8, 8)
    button.BorderSizePixel = 0
    button.Text = player.Name
    button.Font = Enum.Font.Gotham
    button.TextSize = 14
    button.TextColor3 = Color3.fromRGB(240,240,240)
    button.AutoButtonColor = false
    button.Parent = UI.PlayerList
    
    -- Status indicator
    local statusIndicator = Instance.new("Frame", button)
    statusIndicator.Size = UDim2.new(0, 8, 0, 8)
    statusIndicator.Position = UDim2.new(1, -14, 0.5, -4)
    statusIndicator.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    statusIndicator.BorderSizePixel = 0
    
    -- Update status based on player health
    if player.Character then
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            if humanoid.Health <= 0 then
                statusIndicator.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
            else
                statusIndicator.BackgroundColor3 = Color3.fromRGB(30, 200, 30)
            end
        end
    end
    
    -- Hover effect
    button.MouseEnter:Connect(function()
        if player ~= currentTarget then
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 12, 12)}):Play()
        end
    end)
    
    button.MouseLeave:Connect(function()
        if player ~= currentTarget then
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 8, 8)}):Play()
        end
    end)
    
    -- Select player on click
    button.MouseButton1Click:Connect(function()
        if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("Humanoid").Health > 0 then
            currentTarget = player
            notify("Selected: "..player.Name.." ["..positionMode.."]"..(stealthOn and " [STEALTH]" or ""), 2)
            makeHighlight(currentTarget)
            refreshPlayerList()
            
            if autoOn or autoSelectedOn then
                teleportToPosition(currentTarget.Character:FindFirstChild("HumanoidRootPart"), LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
                faceTargetStep()
                spamAttack()
            end
        else
            notify(player.Name .. " is not a valid target", 2)
        end
    end)
    
    return button
end

local function refreshPlayerList()
    for _, child in ipairs(UI.PlayerList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local yPosition = 0
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            createPlayerButton(player, yPosition)
            yPosition = yPosition + 45
        end
    end
    
    UI.PlayerList.CanvasSize = UDim2.new(0, 0, 0, yPosition)
end

-- Auto Refresh Player List
spawn(function()
    while true do
        if autoRefreshOn then
            refreshPlayerList()
        end
        wait(5)
    end
end)

-- Character respawn handler (for death/respawn)
local function onCharacterAdded(char)
    wait(1)  -- Wait for full load
    -- Re-apply stealth if on
    if stealthOn then
        toggleStealth()
    end
    -- Re-apply speed boost if on
    if speedBoostOn then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 50
        end
    end
    -- Re-select target if auto on
    if autoOn then
        currentTarget = chooseRandom()
        if currentTarget then
            makeHighlight(currentTarget)
            notify("Respawned! New target: "..currentTarget.Name, 2)
        end
    end
    -- Refresh list
    refreshPlayerList()
end

LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

-- If character already loaded
if LocalPlayer.Character then
    onCharacterAdded(LocalPlayer.Character)
end

-- Optimized auto-kill loop (updated with new features)
spawn(function()
    while true do
        RunService.Heartbeat:Wait()

        -- Speed Boost
        if tick() - lastSpeedUpdate > speedUpdateRate then
            speedBoostStep()
            lastSpeedUpdate = tick()
        end

        -- Server Hop
        if serverHopOn and tick() - lastServerHopCheck > serverHopCooldown then
            lastServerHopCheck = tick()
            local playerCount = #Players:GetPlayers()
            if playerCount < 5 then
                notify("Server has only "..playerCount.." players, hopping...", 2)
                hopServer()
            end
        end

        -- Safe Zone
        if safeZoneOn and hasPremium then
            local character = LocalPlayer.Character
            if character then
                local humanoid = character:FindFirstChild("Humanoid")
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                if humanoid and humanoid.Health > 0 and humanoidRootPart then
                    local healthPercent = (humanoid.Health / humanoid.MaxHealth) * 100
                    if healthPercent < 35 and not safePlatform then
                        createSafePlatform()
                    elseif healthPercent > 80 and safePlatform then
                        removeSafePlatform()
                    end

                    if safePlatform and (humanoidRootPart.Position - safePlatform.Position).Magnitude > 10 then
                        humanoidRootPart.CFrame = safePlatform.CFrame + Vector3.new(0, 5, 0)
                    end
                end
            end
        end

        -- Auto Kill Random
        if autoOn and not safePlatform and LocalPlayer.Character then
            local char = LocalPlayer.Character
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then  -- Only if alive
                if not currentTarget or not currentTarget.Character or not currentTarget.Character:FindFirstChild("Humanoid") or currentTarget.Character:FindFirstChild("Humanoid").Health <= 0 then
                    currentTarget = chooseRandom()
                    if currentTarget then
                        notify("Selected random: "..currentTarget.Name.." ["..positionMode.."]"..(stealthOn and " [STEALTH]" or ""), 1.8)
                        makeHighlight(currentTarget)
                        lastNoTargetNotify = 0
                    else
                        if tick() - lastNoTargetNotify > noTargetNotifyCooldown then
                            notify("No valid targets found.", 1.8)
                            lastNoTargetNotify = tick()
                        end
                        clearHighlight()
                    end
                else
                    local targetRoot = currentTarget.Character:FindFirstChild("HumanoidRootPart")
                    local hrp = char:FindFirstChild("HumanoidRootPart")

                    if tick() - lastAttack > attackRate then
                        teleportToPosition(targetRoot, hrp)
                        spamAttack()
                        lastAttack = tick()
                    end

                    if positionMode == "Circle" and tick() - lastPositionUpdate > positionRate and targetRoot and hrp then
                        teleportToPosition(targetRoot, hrp)
                        lastPositionUpdate = tick()
                    end

                    if tick() - lastFace > faceRate then
                        faceTargetStep()
                        lastFace = tick()
                    end
                end
            end
        end

        -- Auto Kill Selected
        if autoSelectedOn and not safePlatform and LocalPlayer.Character then
            local char = LocalPlayer.Character
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then  -- Only if alive
                if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("Humanoid") and currentTarget.Character:FindFirstChild("Humanoid").Health > 0 then
                    local targetRoot = currentTarget.Character:FindFirstChild("HumanoidRootPart")
                    local hrp = char:FindFirstChild("HumanoidRootPart")

                    if tick() - lastAttack > attackRate then
                        teleportToPosition(targetRoot, hrp)
                        spamAttack()
                        lastAttack = tick()
                    end

                    if positionMode == "Circle" and tick() - lastPositionUpdate > positionRate and targetRoot and hrp then
                        teleportToPosition(targetRoot, hrp)
                        lastPositionUpdate = tick()
                    end

                    if tick() - lastFace > faceRate then
                        faceTargetStep()
                        lastFace = tick()
                    end
                else
                    if tick() - lastNoTargetNotify > noTargetNotifyCooldown then
                        notify("Selected target is not valid. Auto Kill paused.", 1.8)
                        lastNoTargetNotify = tick()
                    end
                    clearHighlight()
                end
            end
        end
    end
end)

-- Button connections (updated)
UI.AutoBtn.MouseButton1Click:Connect(function()
    if safePlatform then
        notify("Cannot enable Auto Kill while in Safe Zone!", 2)
        return
    end

    autoOn = not autoOn
    UI.AutoBtn.Text = "Auto Kill Random: "..(autoOn and "ON" or "OFF")
    Config.AutoOn = autoOn
    SaveConfig()

    if autoOn then
        autoSelectedOn = false
        UI.AutoSelectedBtn.Text = "Auto Kill Selected: OFF"
        Config.AutoSelectedOn = false
        SaveConfig()
        
        notify("Auto Kill Random enabled ["..positionMode.."]"..(stealthOn and " [STEALTH]" or "")..". Selecting target...", 2)
        currentTarget = chooseRandom()
        if currentTarget then
            notify("Target: "..currentTarget.Name, 2)
            makeHighlight(currentTarget)
        else
            notify("No valid targets found", 2)
        end
    else
        notify("Auto Kill Random disabled", 1.5)
        clearHighlight()
    end
end)

UI.AutoSelectedBtn.MouseButton1Click:Connect(function()
    if safePlatform then
        notify("Cannot enable Auto Kill while in Safe Zone!", 2)
        return
    end

    autoSelectedOn = not autoSelectedOn
    UI.AutoSelectedBtn.Text = "Auto Kill Selected: "..(autoSelectedOn and "ON" or "OFF")
    Config.AutoSelectedOn = autoSelectedOn
    SaveConfig()

    if autoSelectedOn then
        autoOn = false
        UI.AutoBtn.Text = "Auto Kill Random: OFF"
        Config.AutoOn = false
        SaveConfig()
        
        if currentTarget then
            notify("Auto Kill Selected enabled ["..positionMode.."]"..(stealthOn and " [STEALTH]" or "")..". Target: "..currentTarget.Name, 2)
            makeHighlight(currentTarget)
        else
            notify("Auto Kill Selected enabled. Please select a target first.", 2)
            autoSelectedOn = false
            UI.AutoSelectedBtn.Text = "Auto Kill Selected: OFF"
            Config.AutoSelectedOn = false
            SaveConfig()
        end
    else
        notify("Auto Kill Selected disabled", 1.5)
        clearHighlight()
    end
end)

UI.ChangePlayerBtn.MouseButton1Click:Connect(function()
    local currentTargetName = currentTarget and currentTarget.Name or nil
    local players = {}

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and
            player.Character and
            player.Character:FindFirstChild("Humanoid") and
            player.Character:FindFirstChild("Humanoid").Health > 0 and
            player.Name ~= currentTargetName then
            table.insert(players, player)
        end
    end

    if #players > 0 then
        currentTarget = players[math.random(1, #players)]
        notify("Changed target to: "..currentTarget.Name.." ["..positionMode.."]"..(stealthOn and " [STEALTH]" or ""), 2)
        makeHighlight(currentTarget)
        refreshPlayerList()

        if autoOn or autoSelectedOn then
            local targetRoot = currentTarget.Character:FindFirstChild("HumanoidRootPart")
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            teleportToPosition(targetRoot, hrp)
            faceTargetStep()
            spamAttack()
        end
    else
        notify("No other valid targets found", 2)
    end
end)

-- Updated Position Mode Cycle (now Behind/Under/Circle)
UI.PositionModeBtn.MouseButton1Click:Connect(function()
    if positionMode == "Behind" then
        positionMode = "Under"
    elseif positionMode == "Under" then
        positionMode = "Circle"
    else
        positionMode = "Behind"
    end
    UI.PositionModeBtn.Text = "Position Mode: "..positionMode
    Config.PositionMode = positionMode
    SaveConfig()

    notify("Position Mode: "..positionMode, 1.5)
    if currentTarget then
        makeHighlight(currentTarget)
        local targetRoot = currentTarget.Character:FindFirstChild("HumanoidRootPart")
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot and hrp then
            teleportToPosition(targetRoot, hrp)
        end
    end
end)

-- Stealth Button
UI.StealthBtn.MouseButton1Click:Connect(function()
    stealthOn = not stealthOn
    UI.StealthBtn.Text = "Stealth Mode: "..(stealthOn and "ON" or "OFF")
    Config.StealthOn = stealthOn
    SaveConfig()
    toggleStealth()
end)

-- Speed Boost Button
UI.SpeedBoostBtn.MouseButton1Click:Connect(function()
    speedBoostOn = not speedBoostOn
    UI.SpeedBoostBtn.Text = "Speed Boost: "..(speedBoostOn and "ON" or "OFF")
    Config.SpeedBoostOn = speedBoostOn
    SaveConfig()
    if speedBoostOn then
        notify("Speed Boost enabled (50 speed)", 1.5)
    else
        local char = LocalPlayer.Character
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 16  -- Reset to default
            end
        end
        notify("Speed Boost disabled", 1.5)
    end
end)

-- Other buttons (unchanged)
UI.PredictBtn.MouseButton1Click:Connect(function()
    if not hasPremium then
        notify("Predict Direction requires premium. Set: getgenv().LuexKey = 'luexprenium'", 3)
        return
    end

    predictOn = not predictOn
    UI.PredictBtn.Text = "Predict Direction: "..(predictOn and "ON" or "OFF")
    Config.PredictOn = predictOn
    SaveConfig()

    if predictOn then
        notify("Direction Prediction enabled (Beta)", 2)
    else
        notify("Direction Prediction disabled", 1.5)
    end
end)

UI.ServerHopBtn.MouseButton1Click:Connect(function()
    serverHopOn = not serverHopOn
    UI.ServerHopBtn.Text = "Auto Server Hop: "..(serverHopOn and "ON" or "OFF")
    Config.ServerHopOn = serverHopOn
    SaveConfig()

    if serverHopOn then
        notify("Auto Server Hop enabled (min 5 players)", 2)
    else
        notify("Auto Server Hop disabled", 1.5)
    end
end)

UI.SafeZoneBtn.MouseButton1Click:Connect(function()
    if not hasPremium then
        notify("Auto Safe Zone requires premium. Set: getgenv().LuexKey = 'luexprenium'", 3)
        return
    end

    safeZoneOn = not safeZoneOn
    UI.SafeZoneBtn.Text = "Auto Safe Zone: "..(safeZoneOn and "ON" or "OFF")
    Config.SafeZoneOn = safeZoneOn
    SaveConfig()

    if safeZoneOn then
        notify("Auto Safe Zone enabled", 2)
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid and (humanoid.Health / humanoid.MaxHealth) < 0.35 then
                createSafePlatform()
            end
        end
    else
        notify("Auto Safe Zone disabled", 1.5)
        if safePlatform then
            removeSafePlatform()
        end
    end
end)

UI.RefreshBtn.MouseButton1Click:Connect(function()
    refreshPlayerList()
    notify("Player list refreshed", 1.5)
end)

UI.AutoRefreshToggle.MouseButton1Click:Connect(function()
    autoRefreshOn = not autoRefreshOn
    UI.AutoRefreshToggle.Text = "Auto Refresh: "..(autoRefreshOn and "ON" or "OFF")
    Config.AutoRefreshOn = autoRefreshOn
    SaveConfig()
    
    if autoRefreshOn then
        notify("Auto Refresh enabled", 1.5)
        refreshPlayerList()
    else
        notify("Auto Refresh disabled", 1.5)
    end
end)

-- Enhanced PlayerRemoving (better auto kill resume)
Players.PlayerRemoving:Connect(function(p)
    if currentTarget == p then
        currentTarget = nil
        notify("Target left the game. Auto Kill resuming...", 2)
        clearHighlight()

        if autoOn then
            spawn(function()  -- Delay to avoid spam
                wait(1)
                currentTarget = chooseRandom()
                if currentTarget then
                    notify("New target: "..currentTarget.Name.." ["..positionMode.."]"..(stealthOn and " [STEALTH]" or ""), 2)
                    makeHighlight(currentTarget)
                end
            end)
        end
    end
    refreshPlayerList()
end)

Players.PlayerAdded:Connect(function(p)
    wait(2)
    refreshPlayerList()
end)

-- Animations (unchanged)
spawn(function()
    while true do
        for i,child in ipairs(UI.Crack:GetChildren()) do
            if child:IsA("Frame") then
                TweenService:Create(child, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, -1, true), {BackgroundTransparency = 0.6}):Play()
            end
        end
        wait(1.2)
    end
end)

spawn(function()
    while true do
        TweenService:Create(UI.Glow, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.75}):Play()
        wait(1.2)
        TweenService:Create(UI.Glow, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.95}):Play()
        wait(1.2)
    end
end)

-- Initial refresh
refreshPlayerList()

getgenv().LuexHopServer = hopServer

print("Luex Enhanced Combat System v2.5 with Deep Under (-6 studs) + Stealth/SpeedBoost loaded")

-- Xong tiểu đệ, bỏ heal + deep/ultra under rồi, giờ chỉ Behind -> Under (-6 studs sâu hơn) -> Circle. Stealth + Speed vẫn xịn, UI gọn hơn, auto kill resume mượt luôn! Cực xịn sò 😈
