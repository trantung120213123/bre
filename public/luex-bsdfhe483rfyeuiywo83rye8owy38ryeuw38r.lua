-- Luex UI ULTRA v3.1 | Sequential Multi Kill (Attack #1 until dead -> #2 until dead, cycle back to #1 if all dead, no remove on death, only on out/leave) + Immediate Attack on Select + Shared List + Neon Revert + Scrollable
-- ENHANCED: Multi kills SEQUENTIAL (đánh 1 chết mới đến 2nd, cycle quay lại 1 nếu hết, chỉ remove nếu out/leave) until <2 or off | Must enable Multi | Click select = attack IMMEDIATE if Multi ON | Auto-disable invalid | Rest unchanged 😈💥
-- FIXED: No remove on death (chỉ remove out/leave), cycle back to #1 if all dead & wait respawn, sequential skip dead, index management on insert/remove
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
    AutoSelectedOn = false, -- Single mode
    MultiOn = false, -- NEW: Multi mode
    PredictOn = false,
    ServerHopOn = false,
    SafeZoneOn = false,
    AutoRefreshOn = false,
    UIPosition = {0.05, 0, 0.12, 0},
    PositionMode = "Behind", -- Default position mode
    StealthOn = false, -- Stealth mode for ultra hidden
    SpeedBoostOn = false, -- Speed boost feature
    SelectedTargets = {} -- Shared list: 1 for single, >=2 for multi
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
-- main container (COMPACT: 550x380, sleeker)
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 550, 0, 380) -- Smaller & cooler
main.Position = UDim2.new(unpack(Config.UIPosition))
main.BackgroundColor3 = Color3.fromRGB(10,10,10)
main.BackgroundTransparency = 0.15
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Active = true
main.Parent = screen
-- enhanced neon border glow (outer, thicker)
local border = Instance.new("Frame", main)
border.Name = "BorderGlow"
border.AnchorPoint = Vector2.new(0.5,0.5)
border.Position = UDim2.new(0.5,0,0.5,0)
border.Size = UDim2.new(1,10,1,10)
border.BackgroundTransparency = 1
border.ZIndex = 0
local borderStroke = Instance.new("UIStroke", border)
borderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
borderStroke.Color = Color3.fromRGB(255,30,30)
borderStroke.Transparency = 0.5
borderStroke.Thickness = 3
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
-- Left column for controls (NOW SCROLLABLE)
local leftColumn = Instance.new("ScrollingFrame", content)
leftColumn.Name = "LeftColumn"
leftColumn.Size = UDim2.new(0.48, 0, 1, 0)
leftColumn.Position = UDim2.new(0, 0, 0, 0)
leftColumn.BackgroundColor3 = Color3.fromRGB(20, 5, 5)
leftColumn.BackgroundTransparency = 0.2
leftColumn.BorderSizePixel = 0
leftColumn.ScrollBarThickness = 6
leftColumn.AutomaticCanvasSize = Enum.AutomaticSize.Y
leftColumn.CanvasSize = UDim2.new(0, 0, 0, 0)
leftColumn.ScrollingDirection = Enum.ScrollingDirection.Y
-- Right column for player selection
local rightColumn = Instance.new("Frame", content)
rightColumn.Name = "RightColumn"
rightColumn.Size = UDim2.new(0.48, 0, 1, 0)
rightColumn.Position = UDim2.new(0.52, 0, 0, 0)
rightColumn.BackgroundTransparency = 1
-- Auto Kill Random
local btnAuto = Instance.new("TextButton", leftColumn)
btnAuto.Size = UDim2.new(1, 0, 0, 36)
btnAuto.Position = UDim2.new(0, 0, 0, 0)
btnAuto.BackgroundColor3 = Color3.fromRGB(35, 6, 6)
btnAuto.BorderSizePixel = 0
btnAuto.Text = "Auto Kill Random: "..(Config.AutoOn and "ON" or "OFF")
btnAuto.Font = Enum.Font.GothamBold
btnAuto.TextSize = 14
btnAuto.TextColor3 = Color3.fromRGB(240,240,240)
btnAuto.AutoButtonColor = false
local strokeAuto = Instance.new("UIStroke", btnAuto)
strokeAuto.Color = Color3.fromRGB(200,20,20)
strokeAuto.Transparency = 0.85
strokeAuto.Thickness = 1.5
-- Auto Kill Selected (SINGLE: max 1)
local btnAutoSelected = Instance.new("TextButton", leftColumn)
btnAutoSelected.Size = UDim2.new(1, 0, 0, 36)
btnAutoSelected.Position = UDim2.new(0, 0, 0, 40)
btnAutoSelected.BackgroundColor3 = Color3.fromRGB(35, 6, 6)
btnAutoSelected.BorderSizePixel = 0
btnAutoSelected.Text = "Auto Kill Selected (1): OFF"
btnAutoSelected.Font = Enum.Font.GothamBold
btnAutoSelected.TextSize = 14
btnAutoSelected.TextColor3 = Color3.fromRGB(240,240,240)
btnAutoSelected.AutoButtonColor = false
local strokeSelected = Instance.new("UIStroke", btnAutoSelected)
strokeSelected.Color = Color3.fromRGB(200,20,20)
strokeSelected.Transparency = 0.85
strokeSelected.Thickness = 1.5
-- NEW: Multi Kill Selected (>=2, right under single)
local btnMultiSelected = Instance.new("TextButton", leftColumn)
btnMultiSelected.Size = UDim2.new(1, 0, 0, 36)
btnMultiSelected.Position = UDim2.new(0, 0, 0, 80)
btnMultiSelected.BackgroundColor3 = Color3.fromRGB(35, 6, 6)
btnMultiSelected.BorderSizePixel = 0
btnMultiSelected.Text = "Multi Kill Selected: OFF"
btnMultiSelected.Font = Enum.Font.GothamBold
btnMultiSelected.TextSize = 14
btnMultiSelected.TextColor3 = Color3.fromRGB(240,240,240)
btnMultiSelected.AutoButtonColor = false
local strokeMulti = Instance.new("UIStroke", btnMultiSelected)
strokeMulti.Color = Color3.fromRGB(200,20,20)
strokeMulti.Transparency = 0.85
strokeMulti.Thickness = 1.5
-- Change Player button (shifted down)
local btnChangePlayer = Instance.new("TextButton", leftColumn)
btnChangePlayer.Size = UDim2.new(1, 0, 0, 36)
btnChangePlayer.Position = UDim2.new(0, 0, 0, 120)
btnChangePlayer.BackgroundColor3 = Color3.fromRGB(35, 6, 6)
btnChangePlayer.BorderSizePixel = 0
btnChangePlayer.Text = "Change Player"
btnChangePlayer.Font = Enum.Font.GothamBold
btnChangePlayer.TextSize = 14
btnChangePlayer.TextColor3 = Color3.fromRGB(240,240,240)
btnChangePlayer.AutoButtonColor = false
local stroke2 = Instance.new("UIStroke", btnChangePlayer)
stroke2.Color = Color3.fromRGB(200,20,20)
stroke2.Transparency = 0.85
stroke2.Thickness = 1.5
-- Position Mode button (shifted)
local btnPositionMode = Instance.new("TextButton", leftColumn)
btnPositionMode.Size = UDim2.new(1, 0, 0, 36)
btnPositionMode.Position = UDim2.new(0, 0, 0, 160)
btnPositionMode.BackgroundColor3 = Color3.fromRGB(35, 6, 6)
btnPositionMode.BorderSizePixel = 0
btnPositionMode.Text = "Position Mode: "..Config.PositionMode
btnPositionMode.Font = Enum.Font.GothamBold
btnPositionMode.TextSize = 14
btnPositionMode.TextColor3 = Color3.fromRGB(240,240,240)
btnPositionMode.AutoButtonColor = false
local strokePosMode = Instance.new("UIStroke", btnPositionMode)
strokePosMode.Color = Color3.fromRGB(200,20,20)
strokePosMode.Transparency = 0.85
strokePosMode.Thickness = 1.5
-- Stealth Mode button (shifted)
local btnStealth = Instance.new("TextButton", leftColumn)
btnStealth.Size = UDim2.new(1, 0, 0, 36)
btnStealth.Position = UDim2.new(0, 0, 0, 200)
btnStealth.BackgroundColor3 = Color3.fromRGB(35, 6, 6)
btnStealth.BorderSizePixel = 0
btnStealth.Text = "Stealth Mode: "..(Config.StealthOn and "ON" or "OFF")
btnStealth.Font = Enum.Font.GothamBold
btnStealth.TextSize = 14
btnStealth.TextColor3 = Color3.fromRGB(240,240,240)
btnStealth.AutoButtonColor = false
local strokeStealth = Instance.new("UIStroke", btnStealth)
strokeStealth.Color = Color3.fromRGB(200,20,20)
strokeStealth.Transparency = 0.85
strokeStealth.Thickness = 1.5
-- Speed Boost button (shifted)
local btnSpeedBoost = Instance.new("TextButton", leftColumn)
btnSpeedBoost.Size = UDim2.new(1, 0, 0, 36)
btnSpeedBoost.Position = UDim2.new(0, 0, 0, 240)
btnSpeedBoost.BackgroundColor3 = Color3.fromRGB(35, 6, 6)
btnSpeedBoost.BorderSizePixel = 0
btnSpeedBoost.Text = "Speed Boost: "..(Config.SpeedBoostOn and "ON" or "OFF")
btnSpeedBoost.Font = Enum.Font.GothamBold
btnSpeedBoost.TextSize = 14
btnSpeedBoost.TextColor3 = Color3.fromRGB(240,240,240)
btnSpeedBoost.AutoButtonColor = false
local strokeSpeed = Instance.new("UIStroke", btnSpeedBoost)
strokeSpeed.Color = Color3.fromRGB(200,20,20)
strokeSpeed.Transparency = 0.85
strokeSpeed.Thickness = 1.5
-- Predict Direction button (shifted)
local btnPredict = Instance.new("TextButton", leftColumn)
btnPredict.Size = UDim2.new(1, 0, 0, 36)
btnPredict.Position = UDim2.new(0, 0, 0, 280)
btnPredict.BackgroundColor3 = Color3.fromRGB(35, 6, 6)
btnPredict.BorderSizePixel = 0
btnPredict.Text = hasPremium and "Predict Direction: "..(Config.PredictOn and "ON" or "OFF") or "Predict Direction: PREMIUM"
btnPredict.Font = Enum.Font.GothamBold
btnPredict.TextSize = 14
btnPredict.TextColor3 = Color3.fromRGB(240,240,240)
btnPredict.AutoButtonColor = false
local stroke3 = Instance.new("UIStroke", btnPredict)
stroke3.Color = Color3.fromRGB(200,20,20)
stroke3.Transparency = 0.85
stroke3.Thickness = 1.5
-- Auto Server Hop button (shifted)
local btnServerHop = Instance.new("TextButton", leftColumn)
btnServerHop.Size = UDim2.new(1, 0, 0, 36)
btnServerHop.Position = UDim2.new(0, 0, 0, 320)
btnServerHop.BackgroundColor3 = Color3.fromRGB(35, 6, 6)
btnServerHop.BorderSizePixel = 0
btnServerHop.Text = "Auto Server Hop: "..(Config.ServerHopOn and "ON" or "OFF")
btnServerHop.Font = Enum.Font.GothamBold
btnServerHop.TextSize = 14
btnServerHop.TextColor3 = Color3.fromRGB(240,240,240)
btnServerHop.AutoButtonColor = false
local stroke5 = Instance.new("UIStroke", btnServerHop)
stroke5.Color = Color3.fromRGB(200,20,20)
stroke5.Transparency = 0.85
stroke5.Thickness = 1.5
-- Auto Safe Zone button (shifted)
local btnSafeZone = Instance.new("TextButton", leftColumn)
btnSafeZone.Size = UDim2.new(1, 0, 0, 36)
btnSafeZone.Position = UDim2.new(0, 0, 0, 360)
btnSafeZone.BackgroundColor3 = Color3.fromRGB(35, 6, 6)
btnSafeZone.BorderSizePixel = 0
btnSafeZone.Text = hasPremium and "Auto Safe Zone: "..(Config.SafeZoneOn and "ON" or "OFF") or "Auto Safe Zone: PREMIUM"
btnSafeZone.Font = Enum.Font.GothamBold
btnSafeZone.TextSize = 14
btnSafeZone.TextColor3 = Color3.fromRGB(240,240,240)
btnSafeZone.AutoButtonColor = false
local stroke6 = Instance.new("UIStroke", btnSafeZone)
stroke6.Color = Color3.fromRGB(200,20,20)
stroke6.Transparency = 0.85
stroke6.Thickness = 1.5
-- small hint text (updated) - now below scrolling frame
local hint = Instance.new("TextLabel", content)
hint.Size = UDim2.new(0.48,0,0,24)
hint.Position = UDim2.new(0,0,1,-24)
hint.BackgroundTransparency = 1
hint.TextColor3 = Color3.fromRGB(200,200,200)
hint.TextSize = 11
hint.Font = Enum.Font.Gotham
hint.Text = "Luex ULTRA v3.1 | Sequential Multi (đánh 1 chết mới đến 2nd, cycle quay lại 1 nếu hết, chỉ remove out) + Immediate Attack + Shared List + Neon Revert + Scrollable"
hint.TextWrapped = true
-- Player Selection Title
local playerTitle = Instance.new("TextLabel", rightColumn)
playerTitle.Size = UDim2.new(1, 0, 0, 28)
playerTitle.Position = UDim2.new(0, 0, 0, 0)
playerTitle.BackgroundTransparency = 1
playerTitle.TextColor3 = Color3.fromRGB(255, 150, 150)
playerTitle.TextSize = 14
playerTitle.Font = Enum.Font.GothamBold
playerTitle.Text = "PLAYER SELECTION (Click to Toggle - Shared for Single/Multi)"
playerTitle.TextXAlignment = Enum.TextXAlignment.Left
-- Player List Container
local playerListContainer = Instance.new("ScrollingFrame", rightColumn)
playerListContainer.Name = "PlayerList"
playerListContainer.Size = UDim2.new(1, 0, 0, 220)
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
refreshBtn.Size = UDim2.new(1, 0, 0, 32)
refreshBtn.Position = UDim2.new(0, 0, 1, -64)
refreshBtn.BackgroundColor3 = Color3.fromRGB(35, 6, 6)
refreshBtn.BorderSizePixel = 0
refreshBtn.Text = "🔄 Refresh Players"
refreshBtn.Font = Enum.Font.GothamBold
refreshBtn.TextSize = 14
refreshBtn.TextColor3 = Color3.fromRGB(240,240,240)
refreshBtn.AutoButtonColor = false
local stroke7 = Instance.new("UIStroke", refreshBtn)
stroke7.Color = Color3.fromRGB(200,20,20)
stroke7.Transparency = 0.85
stroke7.Thickness = 1.5
-- Auto Refresh Toggle
local autoRefreshToggle = Instance.new("TextButton", rightColumn)
autoRefreshToggle.Size = UDim2.new(1, 0, 0, 32)
autoRefreshToggle.Position = UDim2.new(0, 0, 1, -32)
autoRefreshToggle.BackgroundColor3 = Color3.fromRGB(35, 6, 6)
autoRefreshToggle.BorderSizePixel = 0
autoRefreshToggle.Text = "Auto Refresh: "..(Config.AutoRefreshOn and "ON" or "OFF")
autoRefreshToggle.Font = Enum.Font.GothamBold
autoRefreshToggle.TextSize = 14
autoRefreshToggle.TextColor3 = Color3.fromRGB(240,240,240)
autoRefreshToggle.AutoButtonColor = false
local stroke8 = Instance.new("UIStroke", autoRefreshToggle)
stroke8.Color = Color3.fromRGB(200,20,20)
stroke8.Transparency = 0.85
stroke8.Thickness = 1.5
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
    MultiSelectedBtn = btnMultiSelected, -- NEW
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
                SaveConfig()
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
        TweenService:Create(main, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0,550,0,380)}):Play()
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
local autoSelectedOn = Config.AutoSelectedOn -- Single
local multiOn = Config.MultiOn -- NEW: Multi
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
-- Multi-select vars (FIXED: added index & no remove on death, cycle back)
local selectedTargets = Config.SelectedTargets
local currentMultiIndex = 1
local lastTargetCheck = 0
local targetCheckRate = 0.1
local lastSwitchNotify = 0
local switchNotifyCooldown = 2
-- Safe Zone variables
local safePlatform = nil
local wasAutoKillOn = false
-- Tool list
local toolList = {
    "Normal Punch", "Consecutive Punches", "Shove", "Uppercut", "Table Flip",
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
-- IMPROVED: Player button cache for smoother updates (no full recreate)
local playerButtons = {} -- {player = button}
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
-- Toggle select (shared list, smooth color tween) - FIXED: Insert at FRONT for sequential priority (new = next after current), manage index if multi
local function isSelected(player)
    for _, p in ipairs(selectedTargets) do
        if p == player then return true end
    end
    return false
end
local function updateButtonColors(button, isSel, playerName)
    local targetBg = isSel and Color3.fromRGB(80, 5, 5) or Color3.fromRGB(30, 8, 8)
    local targetTextColor = isSel and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(240,240,240)
    local targetText = playerName .. (isSel and " ✓" or "")
    TweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = targetBg}):Play()
    TweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = targetTextColor}):Play()
    button.Text = targetText
    -- Handle neon stroke
    local existingStroke = button:FindFirstChild("NeonStroke")
    if isSel then
        if not existingStroke then
            local neonStroke = Instance.new("UIStroke", button)
            neonStroke.Name = "NeonStroke"
            neonStroke.Color = Color3.fromRGB(255, 0, 0)
            neonStroke.Transparency = 0.4
            neonStroke.Thickness = 2.5
            existingStroke = neonStroke
        end
        spawn(function()
            while existingStroke and existingStroke.Parent do
                TweenService:Create(existingStroke, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Transparency = 0.7}):Play()
                wait(0.8)
            end
        end)
    else
        if existingStroke then
            TweenService:Create(existingStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = 1}):Play()
            game:GetService("Debris"):AddItem(existingStroke, 0.3)
        end
    end
end
local function immediateAttack(player)
    currentTarget = player
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local tchar = player.Character
    if not tchar then return end
    local targetRoot = tchar:FindFirstChild("HumanoidRootPart")
    if hrp and targetRoot then
        teleportToPosition(targetRoot, hrp)
        faceTargetStep()
        spamAttack()
    end
    makeHighlight(player)
end
local function toggleSelect(player)
    if not player.Character or not player.Character:FindFirstChild("Humanoid") or player.Character:FindFirstChild("Humanoid").Health <= 0 then
        notify(player.Name .. " is not a valid target", 2)
        return
    end
    local foundIndex = nil
    for i, p in ipairs(selectedTargets) do
        if p == player then
            foundIndex = i
            break
        end
    end
    local oldCount = #selectedTargets
    if foundIndex then
        table.remove(selectedTargets, foundIndex)
        notify("Deselected: " .. player.Name .. " (" .. #selectedTargets .. " left)", 1.5)
        -- FIXED: Manage index if multiOn
        if multiOn and foundIndex then
            if foundIndex < currentMultiIndex then
                currentMultiIndex = currentMultiIndex - 1
            elseif foundIndex == currentMultiIndex then
                currentMultiIndex = math.fmod(currentMultiIndex - 1, #selectedTargets) + 1
                lastTargetCheck = 0  -- Force check
            end
            if currentMultiIndex > #selectedTargets then currentMultiIndex = 1 end
        end
    else
        -- FIXED: Insert at FRONT for priority (new target = next kill after current)
        table.insert(selectedTargets, 1, player)
        notify("Selected: " .. player.Name .. " (" .. #selectedTargets .. " total)", 1.5)
        -- FIXED: Immediate attack if Multi ON, reset index to 1
        if multiOn then
            currentMultiIndex = 1
            immediateAttack(player)
            notify("Multi ON: Đánh ngay target mới! 💥", 1.5)
            lastTargetCheck = 0
        end
    end
    Config.SelectedTargets = selectedTargets
    SaveConfig()
    -- Update button smoothly
    local button = playerButtons[player]
    if button then
        local isSel = isSelected(player)
        updateButtonColors(button, isSel, player.Name)
    end
    -- NEW: Auto-disable invalid modes after toggle
    if autoSelectedOn and #selectedTargets ~= 1 then
        autoSelectedOn = false
        UI.AutoSelectedBtn.Text = "Auto Kill Selected (1): OFF"
        Config.AutoSelectedOn = false
        SaveConfig()
        notify("Single mode disabled - Select exactly 1 target.", 2)
    end
    if multiOn and #selectedTargets < 2 then
        multiOn = false
        UI.MultiSelectedBtn.Text = "Multi Kill Selected: OFF"
        Config.MultiOn = false
        SaveConfig()
        notify("Multi mode disabled - Select at least 2 targets.", 2)
    end
    updateSelectedBtnsText()
end
local function updateSelectedBtnsText()
    UI.AutoSelectedBtn.Text = "Auto Kill Selected (1): " .. (autoSelectedOn and "ON" or "OFF")
    UI.MultiSelectedBtn.Text = "Multi Kill Selected: " .. (multiOn and "ON (" .. #selectedTargets .. ")" or "OFF")
end
-- highlight target (updated for modes) - FIXED: Pass multiIndex for [MULTI X/N]
local function makeHighlight(player, multiIndex)
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
        local modeText
        if multiOn and multiIndex then
            modeText = " [MULTI " .. multiIndex .. "/" .. #selectedTargets .. " " .. positionMode .. "]"
        elseif autoSelectedOn then
            modeText = " [SINGLE " .. positionMode .. "]"
        elseif autoOn then
            modeText = " [RANDOM " .. positionMode .. "]"
        else
            modeText = " [" .. positionMode .. "]"
        end
        modeText = modeText .. (stealthOn and " [STEALTH]" or "")
        label.Text = "TARGET: "..player.Name..modeText
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
-- Position mode functions (unchanged)
local function teleportToPosition(targetRoot, hrp)
    local targetPos = predictTargetPosition(targetRoot)
    local radius = 5
    local underOffset = Vector3.new(0, -6, 0)
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
-- Stealth function (unchanged)
local function toggleStealth()
    local char = LocalPlayer.Character
    if not char then return end
    if stealthOn then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0.7
                part.CanCollide = false
            elseif part:IsA("Decal") or part:IsA("Texture") then
                part.Transparency = 0.7
            end
        end
        if positionMode == "Under" then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = hrp.CFrame + Vector3.new(0, -3, 0)
            end
        end
        notify("Stealth ON: Semi-transparent + No-Clip!", 2)
    else
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
-- Speed Boost function (unchanged)
local function speedBoostStep()
    local char = LocalPlayer.Character
    if not char or not speedBoostOn then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = 50
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
    wasAutoKillOn = autoOn or autoSelectedOn or multiOn
    autoOn = false
    autoSelectedOn = false
    multiOn = false
    UI.AutoBtn.Text = "Auto Kill Random: OFF"
    UI.AutoSelectedBtn.Text = "Auto Kill Selected (1): OFF"
    UI.MultiSelectedBtn.Text = "Multi Kill Selected: OFF"
    Config.AutoOn = false
    Config.AutoSelectedOn = false
    Config.MultiOn = false
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
                multiOn = wasAutoKillOn
                UI.AutoBtn.Text = "Auto Kill Random: "..(autoOn and "ON" or "OFF")
                UI.AutoSelectedBtn.Text = "Auto Kill Selected (1): "..(autoSelectedOn and "ON" or "OFF")
                UI.MultiSelectedBtn.Text = "Multi Kill Selected: "..(multiOn and "ON" or "OFF")
                Config.AutoOn = autoOn
                Config.AutoSelectedOn = autoSelectedOn
                Config.MultiOn = multiOn
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
-- FIXED: Player Selection Functions (update existing buttons for smooth colors/status)
local function createPlayerButton(player, yPosition)
    -- Clean up if exists
    if playerButtons[player] then
        playerButtons[player]:Destroy()
    end
    local button = Instance.new("TextButton")
    button.Name = player.Name
    button.Size = UDim2.new(1, -10, 0, 36)
    button.Position = UDim2.new(0, 5, 0, yPosition)
    local isSel = isSelected(player)
    button.BackgroundColor3 = isSel and Color3.fromRGB(80, 5, 5) or Color3.fromRGB(30, 8, 8)
    button.BorderSizePixel = 0
    button.Text = player.Name .. (isSel and " ✓" or "")
    button.Font = Enum.Font.Gotham
    button.TextSize = 13
    button.TextColor3 = isSel and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(240,240,240)
    button.AutoButtonColor = false
    button.Parent = UI.PlayerList
    -- Neon stroke for selected (pulsing)
    if isSel then
        local neonStroke = Instance.new("UIStroke", button)
        neonStroke.Name = "NeonStroke"
        neonStroke.Color = Color3.fromRGB(255, 0, 0)
        neonStroke.Transparency = 0.4
        neonStroke.Thickness = 2.5
        spawn(function()
            while button.Parent do
                TweenService:Create(neonStroke, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Transparency = 0.7}):Play()
                wait(0.8)
            end
        end)
    end
    -- Status indicator
    local statusIndicator = Instance.new("Frame", button)
    statusIndicator.Name = "StatusIndicator"
    statusIndicator.Size = UDim2.new(0, 8, 0, 8)
    statusIndicator.Position = UDim2.new(1, -14, 0.5, -4)
    statusIndicator.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    statusIndicator.BorderSizePixel = 0
    local function updateStatus()
        if player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then
                local targetColor = humanoid.Health <= 0 and Color3.fromRGB(200, 30, 30) or Color3.fromRGB(30, 200, 30)
                TweenService:Create(statusIndicator, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = targetColor}):Play()
            else
                TweenService:Create(statusIndicator, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(100, 100, 100)}):Play()
            end
        end
    end
    updateStatus()
    -- Hover effect
    button.MouseEnter:Connect(function()
        local currentSel = isSelected(player)
        if not currentSel then
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 12, 12)}):Play()
        end
    end)
    button.MouseLeave:Connect(function()
        local currentSel = isSelected(player)
        if not currentSel then
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 8, 8)}):Play()
        end
    end)
    -- Toggle select on click
    button.MouseButton1Click:Connect(function()
        toggleSelect(player)
    end)
    -- Cache button
    playerButtons[player] = button
    return button
end
local function refreshPlayerList()
    local yPosition = 0
    local visiblePlayers = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            visiblePlayers[player] = true
            if not playerButtons[player] then
                createPlayerButton(player, yPosition)
                yPosition = yPosition + 40
            else
                -- Update position if needed (for new joins or order changes)
                playerButtons[player].Position = UDim2.new(0, 5, 0, yPosition)
                -- Update status smoothly
                local status = playerButtons[player]:FindFirstChild("StatusIndicator")
                if status then
                    spawn(function()
                        local function updateStatusForButton()
                            if player and player.Character then
                                local humanoid = player.Character:FindFirstChild("Humanoid")
                                if humanoid then
                                    local targetColor = humanoid.Health <= 0 and Color3.fromRGB(200, 30, 30) or Color3.fromRGB(30, 200, 30)
                                    TweenService:Create(status, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = targetColor}):Play()
                                end
                            end
                        end
                        updateStatusForButton()
                    end)
                end
                -- Ensure color is correct and smooth
                local isSel = isSelected(player)
                updateButtonColors(playerButtons[player], isSel, player.Name)
                yPosition = yPosition + 40
            end
        end
    end
    -- Remove buttons for left players
    for player, button in pairs(playerButtons) do
        if not visiblePlayers[player] then
            button:Destroy()
            playerButtons[player] = nil
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
-- Character respawn handler (unchanged)
local function onCharacterAdded(char)
    wait(1)
    if stealthOn then
        toggleStealth()
    end
    if speedBoostOn then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 50
        end
    end
    if autoOn then
        currentTarget = chooseRandom()
        if currentTarget then
            makeHighlight(currentTarget)
            notify("Respawned! New target: "..currentTarget.Name, 2)
        end
    end
    refreshPlayerList()
end
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
if LocalPlayer.Character then
    onCharacterAdded(LocalPlayer.Character)
end
-- Optimized auto-kill loop (FIXED: Multi sequential cycle - attack current until dead, skip to next alive, cycle back to 1 if all dead, no remove on death, only check every 0.1s to avoid spam)
spawn(function()
    while true do
        RunService.Heartbeat:Wait()
        if tick() - lastSpeedUpdate > speedUpdateRate then
            speedBoostStep()
            lastSpeedUpdate = tick()
        end
        if serverHopOn and tick() - lastServerHopCheck > serverHopCooldown then
            lastServerHopCheck = tick()
            local playerCount = #Players:GetPlayers()
            if playerCount < 5 then
                notify("Server has only "..playerCount.." players, hopping...", 2)
                hopServer()
            end
        end
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
        local char = LocalPlayer.Character
        local humanoid = char and char:FindFirstChild("Humanoid")
        if not (humanoid and humanoid.Health > 0) then
            RunService.Heartbeat:Wait()
            continue
        end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        -- Check for multi disable if <2
        if multiOn and #selectedTargets < 2 then
            multiOn = false
            UI.MultiSelectedBtn.Text = "Multi Kill Selected: OFF"
            Config.MultiOn = false
            SaveConfig()
            notify("Multi mode disabled - Less than 2 targets left. Hoàn tất kill! 💀", 2)
            clearHighlight()
            currentTarget = nil
            currentMultiIndex = 1
        end
        -- Auto Kill Random
        if autoOn and not safePlatform then
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
                if tick() - lastAttack > attackRate then
                    teleportToPosition(targetRoot, hrp)
                    spamAttack()
                    lastAttack = tick()
                end
                if positionMode == "Circle" and tick() - lastPositionUpdate > positionRate and targetRoot then
                    teleportToPosition(targetRoot, hrp)
                    lastPositionUpdate = tick()
                end
                if tick() - lastFace > faceRate then
                    faceTargetStep()
                    lastFace = tick()
                end
            end
        end
        -- UPDATED: Auto Kill Single (uses selectedTargets[1])
        if autoSelectedOn and not safePlatform and #selectedTargets == 1 then
            currentTarget = selectedTargets[1]
            if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("Humanoid") and currentTarget.Character:FindFirstChild("Humanoid").Health > 0 then
                local targetRoot = currentTarget.Character:FindFirstChild("HumanoidRootPart")
                if tick() - lastAttack > attackRate then
                    teleportToPosition(targetRoot, hrp)
                    spamAttack()
                    lastAttack = tick()
                end
                if positionMode == "Circle" and tick() - lastPositionUpdate > positionRate and targetRoot then
                    teleportToPosition(targetRoot, hrp)
                    lastPositionUpdate = tick()
                end
                if tick() - lastFace > faceRate then
                    faceTargetStep()
                    lastFace = tick()
                end
                makeHighlight(currentTarget)
            else
                if tick() - lastNoTargetNotify > noTargetNotifyCooldown then
                    notify("Single target invalid. Mode paused.", 1.8)
                    lastNoTargetNotify = tick()
                end
                clearHighlight()
            end
        end
        -- FIXED: Multi Kill (SEQUENTIAL: attack current until dead/invalid, skip to next alive (no remove), cycle back to 1 if all dead, check every 0.1s)
        if multiOn and not safePlatform and #selectedTargets >= 2 then
            -- Target management (slow check)
            if tick() - lastTargetCheck > targetCheckRate then
                local target = selectedTargets[currentMultiIndex]
                local isValid = target and target.Character and target.Character:FindFirstChild("Humanoid") and target.Character.Humanoid.Health > 0
                if not isValid then
                    local oldIndex = currentMultiIndex
                    local oldTarget = target
                    local targetName = target and target.Name or "Unknown"
                    local attempts = 0
                    repeat
                        currentMultiIndex = math.fmod(currentMultiIndex, #selectedTargets) + 1
                        target = selectedTargets[currentMultiIndex]
                        attempts = attempts + 1
                        isValid = target and target.Character and target.Character:FindFirstChild("Humanoid") and target.Character.Humanoid.Health > 0
                    until isValid or attempts >= #selectedTargets
                    lastTargetCheck = tick()
                    local switched = false
                    if attempts >= #selectedTargets then
                        -- All dead, cycle back to 1, wait respawn
                        currentMultiIndex = 1
                        currentTarget = nil
                        clearHighlight()
                        if tick() - lastSwitchNotify > switchNotifyCooldown then
                            notify("All targets dead! Waiting for respawn & cycle back to #1... 🔄💀", 3)
                            lastSwitchNotify = tick()
                        end
                    else
                        -- Switched to valid
                        currentTarget = target
                        makeHighlight(currentTarget, currentMultiIndex)
                        switched = true
                        if tick() - lastSwitchNotify > switchNotifyCooldown then
                            notify("Target '" .. targetName .. "' chết. Tiếp theo #" .. currentMultiIndex .. " (" .. #selectedTargets .. " total) 🔄", 1.5)
                            lastSwitchNotify = tick()
                        end
                    end
                else
                    -- Still valid
                    currentTarget = target
                    makeHighlight(currentTarget, currentMultiIndex)
                    lastTargetCheck = tick()
                end
            end
            -- Attack if valid target
            if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("Humanoid") and currentTarget.Character.Humanoid.Health > 0 then
                local targetRoot = currentTarget.Character:FindFirstChild("HumanoidRootPart")
                if targetRoot and hrp then
                    if tick() - lastAttack > attackRate then
                        teleportToPosition(targetRoot, hrp)
                        spamAttack()
                        lastAttack = tick()
                    end
                    if positionMode == "Circle" and tick() - lastPositionUpdate > positionRate then
                        teleportToPosition(targetRoot, hrp)
                        lastPositionUpdate = tick()
                    end
                end
                if tick() - lastFace > faceRate then
                    faceTargetStep()
                    lastFace = tick()
                end
            else
                -- Quick invalid check, force next management
                lastTargetCheck = 0
            end
        end
    end
end)
-- Button connections (updated for single/multi)
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
        multiOn = false
        UI.AutoSelectedBtn.Text = "Auto Kill Selected (1): OFF"
        UI.MultiSelectedBtn.Text = "Multi Kill Selected: OFF"
        Config.AutoSelectedOn = false
        Config.MultiOn = false
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
    if #selectedTargets == 1 then
        autoSelectedOn = not autoSelectedOn
        UI.AutoSelectedBtn.Text = "Auto Kill Selected (1): "..(autoSelectedOn and "ON" or "OFF")
        Config.AutoSelectedOn = autoSelectedOn
        SaveConfig()
        if autoSelectedOn then
            autoOn = false
            multiOn = false
            UI.AutoBtn.Text = "Auto Kill Random: OFF"
            UI.MultiSelectedBtn.Text = "Multi Kill Selected: OFF"
            Config.AutoOn = false
            Config.MultiOn = false
            SaveConfig()
       
            currentTarget = selectedTargets[1]
            notify("Auto Kill Single enabled ["..positionMode.."]"..(stealthOn and " [STEALTH]" or "")..". Target: "..currentTarget.Name, 2)
            makeHighlight(currentTarget)
        else
            notify("Auto Kill Single disabled", 1.5)
            clearHighlight()
            currentTarget = nil
        end
    else
        notify("Select exactly 1 target for Single mode.", 2)
    end
end)
-- NEW: Multi Kill Selected Button - FIXED: Must enable, starts sequential on [1] (đánh 1 chết mới 2nd, cycle back)
UI.MultiSelectedBtn.MouseButton1Click:Connect(function()
    if safePlatform then
        notify("Cannot enable Auto Kill while in Safe Zone!", 2)
        return
    end
    if #selectedTargets >= 2 then
        multiOn = not multiOn
        UI.MultiSelectedBtn.Text = "Multi Kill Selected: "..(multiOn and "ON ("..#selectedTargets..")" or "OFF")
        Config.MultiOn = multiOn
        SaveConfig()
        if multiOn then
            autoOn = false
            autoSelectedOn = false
            UI.AutoBtn.Text = "Auto Kill Random: OFF"
            UI.AutoSelectedBtn.Text = "Auto Kill Selected (1): OFF"
            Config.AutoOn = false
            Config.AutoSelectedOn = false
            SaveConfig()
       
            -- FIXED: Start sequential on [1], reset index
            currentMultiIndex = 1
            lastTargetCheck = 0
            currentTarget = selectedTargets[1]
            notify("Multi Kill enabled ["..positionMode.."]"..(stealthOn and " [STEALTH]" or "")..". Sequential: đánh 1 chết mới đến 2nd, cycle quay lại 1 nếu hết ("..#selectedTargets.." targets)", 2.5)
            makeHighlight(currentTarget, currentMultiIndex)
        else
            notify("Multi Kill disabled", 1.5)
            clearHighlight()
            currentTarget = nil
            currentMultiIndex = 1
        end
    else
        notify("Select at least 2 targets for Multi mode.", 2)
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
        if autoOn or autoSelectedOn or multiOn then
            local targetRoot = currentTarget.Character:FindFirstChild("HumanoidRootPart")
            local localHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot and localHrp then
                teleportToPosition(targetRoot, localHrp)
                faceTargetStep()
                spamAttack()
            end
        end
    else
        notify("No other valid targets found", 2)
    end
end)
-- Updated Position Mode Cycle
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
                humanoid.WalkSpeed = 16
            end
        end
        notify("Speed Boost disabled", 1.5)
    end
end)
-- Predict Button (unchanged)
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
-- Server Hop Button (unchanged)
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
-- Safe Zone Button (unchanged)
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
-- Enhanced PlayerRemoving - FIXED: After remove, manage index, force check if multi
Players.PlayerRemoving:Connect(function(p)
    if currentTarget == p then
        currentTarget = nil
        clearHighlight()
    end
    local found = false
    local removedIndex = nil
    for i, sel in ipairs(selectedTargets) do
        if sel == p then
            removedIndex = i
            table.remove(selectedTargets, i)
            found = true
            break
        end
    end
    if found then
        Config.SelectedTargets = selectedTargets
        SaveConfig()
        notify("Target " .. p.Name .. " out/left. Removed from list (" .. #selectedTargets .. " left)", 2)
        updateSelectedBtnsText()
        -- FIXED: If multiOn, adjust index & force check
        if multiOn then
            if removedIndex < currentMultiIndex then
                currentMultiIndex = currentMultiIndex - 1
            elseif removedIndex == currentMultiIndex then
                currentMultiIndex = math.fmod(currentMultiIndex - 1, #selectedTargets) + 1
            end
            if currentMultiIndex > #selectedTargets then currentMultiIndex = 1 end
            lastTargetCheck = 0  -- Force next check
            if #selectedTargets >= 2 then
                local tempTarget = selectedTargets[currentMultiIndex]
                local isTempValid = tempTarget and tempTarget.Character and tempTarget.Character:FindFirstChild("Humanoid") and tempTarget.Character.Humanoid.Health > 0
                if isTempValid then
                    currentTarget = tempTarget
                    makeHighlight(currentTarget, currentMultiIndex)
                    notify("Multi: Tiếp theo target sau out.", 1.5)
                end
            else
                multiOn = false
                UI.MultiSelectedBtn.Text = "Multi Kill Selected: OFF"
                Config.MultiOn = false
                SaveConfig()
                notify("Multi mode disabled - Less than 2 targets left.", 2)
                clearHighlight()
                currentTarget = nil
                currentMultiIndex = 1
            end
        end
        -- Auto-disable invalid modes
        if autoSelectedOn and #selectedTargets ~= 1 then
            autoSelectedOn = false
            UI.AutoSelectedBtn.Text = "Auto Kill Selected (1): OFF"
            Config.AutoSelectedOn = false
            SaveConfig()
            notify("Single mode disabled - Select exactly 1 target.", 2)
        end
    end
    -- Clean up button
    if playerButtons[p] then
        playerButtons[p]:Destroy()
        playerButtons[p] = nil
    end
    if autoOn then
        spawn(function()
            wait(1)
            currentTarget = chooseRandom()
            if currentTarget then
                notify("New target: "..currentTarget.Name.." ["..positionMode.."]"..(stealthOn and " [STEALTH]" or ""), 2)
                makeHighlight(currentTarget)
            end
        end)
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
updateSelectedBtnsText()
getgenv().LuexHopServer = hopServer
print("Luex ULTRA v3.1: Sequential Multi (đánh 1 chết mới đến 2nd, cycle quay lại 1 nếu hết, chỉ remove out) + Immediate Attack + Shared List + Neon Revert + Scrollable loaded - Cực xịn cực mạnh xịn sò 😈💥")
notify("Luex ULTRA v3.1 Loaded! Multi: Enable -> Đánh sequential 1 chết mới 2nd, cycle back nếu hết | Ấn target = Đánh ngay if Multi ON! Scroll left!", 4)
