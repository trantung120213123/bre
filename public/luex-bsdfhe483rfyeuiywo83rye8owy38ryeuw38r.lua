local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local PROTECTED_USER = "tung1202222222"
local Config = {
    AutoOn = false,
    AutoSelectedOn = false,
    MultiOn = false,
    PredictOn = false,
    ServerHopOn = false,
    SafeZoneOn = false,
    VoidCheckOn = true,
    AutoRefreshOn = false,
    UIPosition = {0.05, 0, 0.12, 0},
    PositionMode = "Behind",
    SpeedBoostOn = false,
    SelectedTargets = {},
    BlacklistedPlayers = {PROTECTED_USER}
}
local function LoadConfig()
    if getgenv().LuexConfig then
        for key, value in pairs(getgenv().LuexConfig) do
            Config[key] = value
        end
        if not Config.BlacklistedPlayers then
            Config.BlacklistedPlayers = {PROTECTED_USER}
        elseif not table.find(Config.BlacklistedPlayers, PROTECTED_USER) then
            table.insert(Config.BlacklistedPlayers, PROTECTED_USER)
        end
    end
end
local function SaveConfig()
    getgenv().LuexConfig = Config
end
LoadConfig()
Config.StealthOn = nil
pcall(function()
    if game.CoreGui:FindFirstChild("LuexUI") then
        game.CoreGui.LuexUI:Destroy()
    end
end)
local screen = Instance.new("ScreenGui")
screen.Name = "LuexUI"
screen.ResetOnSpawn = false
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screen.Parent = game.CoreGui
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 550, 0, 380)
main.Position = UDim2.new(unpack(Config.UIPosition))
main.BackgroundColor3 = Color3.fromRGB(10,10,10)
main.BackgroundTransparency = 0.15
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Active = true
main.ZIndex = 1
main.Parent = screen
local border = Instance.new("Frame", main)
border.Name = "BorderGlow"
border.AnchorPoint = Vector2.new(0.5,0.5)
border.Position = UDim2.new(0.5,0,0.5,0)
border.Size = UDim2.new(1,10,1,10)
border.BackgroundTransparency = 1
border.ZIndex = 0
border.Active = false
border.Selectable = false
local borderStroke = Instance.new("UIStroke", border)
borderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
borderStroke.Color = Color3.fromRGB(255,30,30)
borderStroke.Transparency = 0.5
borderStroke.Thickness = 3
local topBar = Instance.new("Frame", main)
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1,0,0,46)
topBar.Position = UDim2.new(0,0,0,0)
topBar.BackgroundTransparency = 1
topBar.Active = true
topBar.ZIndex = 25
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
logo.Active = false
local gradHolder = Instance.new("Frame", logo)
gradHolder.Size = UDim2.new(1,0,1,0)
gradHolder.BackgroundTransparency = 1
gradHolder.Active = false
local uiGrad = Instance.new("UIGradient", gradHolder)
uiGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 60, 20)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255,160,80)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(200,40,10))
}
uiGrad.Rotation = 10
gradHolder.ZIndex = 2
local crackContainer = Instance.new("Frame", topBar)
crackContainer.Name = "Crack"
crackContainer.Size = UDim2.new(0, 140, 0, 34)
crackContainer.Position = UDim2.new(0, 12, 0, 6)
crackContainer.BackgroundTransparency = 1
crackContainer.ZIndex = 2
crackContainer.Active = false
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
minBtn.Active = true
minBtn.ZIndex = 35
local content = Instance.new("Frame", main)
content.Name = "Content"
content.Position = UDim2.new(0, 12, 0, 92)
content.Size = UDim2.new(1, -24, 1, -104)
content.BackgroundTransparency = 1
content.ZIndex = 1
local tabBar = Instance.new("Frame", main)
tabBar.Name = "TabBar"
tabBar.Position = UDim2.new(0, 12, 0, 54)
tabBar.Size = UDim2.new(1, -24, 0, 30)
tabBar.BackgroundTransparency = 1
tabBar.Active = true
tabBar.ZIndex = 20
local btnCombatTab = Instance.new("TextButton", tabBar)
btnCombatTab.Size = UDim2.new(0.33, -4, 1, 0)
btnCombatTab.Position = UDim2.new(0, 0, 0, 0)
btnCombatTab.BackgroundColor3 = Color3.fromRGB(120, 20, 20)
btnCombatTab.BorderSizePixel = 0
btnCombatTab.Text = "Combat"
btnCombatTab.Font = Enum.Font.GothamBold
btnCombatTab.TextSize = 13
btnCombatTab.TextColor3 = Color3.fromRGB(255,255,255)
btnCombatTab.Active = true
btnCombatTab.ZIndex = 21
local btnSafetyTab = Instance.new("TextButton", tabBar)
btnSafetyTab.Size = UDim2.new(0.34, -4, 1, 0)
btnSafetyTab.Position = UDim2.new(0.33, 2, 0, 0)
btnSafetyTab.BackgroundColor3 = Color3.fromRGB(35, 6, 6)
btnSafetyTab.BorderSizePixel = 0
btnSafetyTab.Text = "Safety"
btnSafetyTab.Font = Enum.Font.GothamBold
btnSafetyTab.TextSize = 13
btnSafetyTab.TextColor3 = Color3.fromRGB(240,240,240)
btnSafetyTab.Active = true
btnSafetyTab.ZIndex = 21
local btnSettingsTab = Instance.new("TextButton", tabBar)
btnSettingsTab.Size = UDim2.new(0.33, -4, 1, 0)
btnSettingsTab.Position = UDim2.new(0.67, 4, 0, 0)
btnSettingsTab.BackgroundColor3 = Color3.fromRGB(35, 6, 6)
btnSettingsTab.BorderSizePixel = 0
btnSettingsTab.Text = "Settings"
btnSettingsTab.Font = Enum.Font.GothamBold
btnSettingsTab.TextSize = 13
btnSettingsTab.TextColor3 = Color3.fromRGB(240,240,240)
btnSettingsTab.Active = true
btnSettingsTab.ZIndex = 21
local combatTab = Instance.new("Frame", content)
combatTab.Name = "CombatTab"
combatTab.Size = UDim2.new(1, 0, 1, 0)
combatTab.BackgroundTransparency = 1
combatTab.ZIndex = 2
local safetyTab = Instance.new("ScrollingFrame", content)
safetyTab.Name = "SafetyTab"
safetyTab.Size = UDim2.new(1, 0, 1, 0)
safetyTab.BackgroundTransparency = 1
safetyTab.BorderSizePixel = 0
safetyTab.ScrollBarThickness = 6
safetyTab.AutomaticCanvasSize = Enum.AutomaticSize.Y
safetyTab.CanvasSize = UDim2.new(0, 0, 0, 0)
safetyTab.ZIndex = 2
safetyTab.Visible = false
local settingsTab = Instance.new("ScrollingFrame", content)
settingsTab.Name = "SettingsTab"
settingsTab.Size = UDim2.new(1, 0, 1, 0)
settingsTab.BackgroundTransparency = 1
settingsTab.BorderSizePixel = 0
settingsTab.ScrollBarThickness = 6
settingsTab.AutomaticCanvasSize = Enum.AutomaticSize.Y
settingsTab.CanvasSize = UDim2.new(0, 0, 0, 0)
settingsTab.ZIndex = 2
settingsTab.Visible = false
local leftColumn = Instance.new("ScrollingFrame", combatTab)
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
local rightColumn = Instance.new("Frame", combatTab)
rightColumn.Name = "RightColumn"
rightColumn.Size = UDim2.new(0.48, 0, 1, 0)
rightColumn.Position = UDim2.new(0.52, 0, 0, 0)
rightColumn.BackgroundTransparency = 1
local function addButtonStroke(button)
    local stroke = Instance.new("UIStroke", button)
    stroke.Color = Color3.fromRGB(200,20,20)
    stroke.Transparency = 0.85
    stroke.Thickness = 1.5
    return stroke
end
local function activateButton(button, zIndex)
    button.Active = true
    button.ZIndex = zIndex or 10
end
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
activateButton(btnAuto)
addButtonStroke(btnAuto)
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
activateButton(btnAutoSelected)
addButtonStroke(btnAutoSelected)
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
activateButton(btnMultiSelected)
addButtonStroke(btnMultiSelected)
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
activateButton(btnChangePlayer)
addButtonStroke(btnChangePlayer)
local btnBlacklist = Instance.new("TextButton", leftColumn)
btnBlacklist.Size = UDim2.new(1, 0, 0, 36)
btnBlacklist.Position = UDim2.new(0, 0, 0, 160)
btnBlacklist.BackgroundColor3 = Color3.fromRGB(80, 5, 5)
btnBlacklist.BorderSizePixel = 0
btnBlacklist.Text = "🛡️ Blacklist (" .. #Config.BlacklistedPlayers .. ") ✓"
btnBlacklist.Font = Enum.Font.GothamBold
btnBlacklist.TextSize = 14
btnBlacklist.TextColor3 = Color3.fromRGB(255, 50, 50)
btnBlacklist.AutoButtonColor = false
activateButton(btnBlacklist)
addButtonStroke(btnBlacklist)
local btnPositionMode = Instance.new("TextButton", leftColumn)
btnPositionMode.Size = UDim2.new(1, 0, 0, 36)
btnPositionMode.Position = UDim2.new(0, 0, 0, 200)
btnPositionMode.BackgroundColor3 = Color3.fromRGB(35, 6, 6)
btnPositionMode.BorderSizePixel = 0
btnPositionMode.Text = "Position Mode: "..Config.PositionMode
btnPositionMode.Font = Enum.Font.GothamBold
btnPositionMode.TextSize = 14
btnPositionMode.TextColor3 = Color3.fromRGB(240,240,240)
btnPositionMode.AutoButtonColor = false
activateButton(btnPositionMode)
addButtonStroke(btnPositionMode)
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
activateButton(btnSpeedBoost)
addButtonStroke(btnSpeedBoost)
local btnPredict = Instance.new("TextButton", leftColumn)
btnPredict.Size = UDim2.new(1, 0, 0, 36)
btnPredict.Position = UDim2.new(0, 0, 0, 280)
btnPredict.BackgroundColor3 = Color3.fromRGB(35, 6, 6)
btnPredict.BorderSizePixel = 0
btnPredict.Text = "Predict Direction: "..(Config.PredictOn and "ON" or "OFF")
btnPredict.Font = Enum.Font.GothamBold
btnPredict.TextSize = 14
btnPredict.TextColor3 = Color3.fromRGB(240,240,240)
btnPredict.AutoButtonColor = false
activateButton(btnPredict)
addButtonStroke(btnPredict)
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
activateButton(btnServerHop)
addButtonStroke(btnServerHop)
local btnSafeZone = Instance.new("TextButton", leftColumn)
btnSafeZone.Size = UDim2.new(1, 0, 0, 36)
btnSafeZone.Position = UDim2.new(0, 0, 0, 360)
btnSafeZone.BackgroundColor3 = Color3.fromRGB(35, 6, 6)
btnSafeZone.BorderSizePixel = 0
btnSafeZone.Text = "Auto Safe Zone: "..(Config.SafeZoneOn and "ON" or "OFF")
btnSafeZone.Font = Enum.Font.GothamBold
btnSafeZone.TextSize = 14
btnSafeZone.TextColor3 = Color3.fromRGB(240,240,240)
btnSafeZone.AutoButtonColor = false
activateButton(btnSafeZone)
addButtonStroke(btnSafeZone)
local btnVoidCheck = Instance.new("TextButton", leftColumn)
btnVoidCheck.Size = UDim2.new(1, 0, 0, 36)
btnVoidCheck.Position = UDim2.new(0, 0, 0, 400)
btnVoidCheck.BackgroundColor3 = Color3.fromRGB(35, 6, 6)
btnVoidCheck.BorderSizePixel = 0
btnVoidCheck.Text = "Void Check: "..(Config.VoidCheckOn and "ON" or "OFF")
btnVoidCheck.Font = Enum.Font.GothamBold
btnVoidCheck.TextSize = 14
btnVoidCheck.TextColor3 = Color3.fromRGB(240,240,240)
btnVoidCheck.AutoButtonColor = false
activateButton(btnVoidCheck)
addButtonStroke(btnVoidCheck)
btnSafeZone.Parent = safetyTab
btnSafeZone.Position = UDim2.new(0, 0, 0, 0)
btnSafeZone.Size = UDim2.new(1, -6, 0, 36)
btnVoidCheck.Parent = safetyTab
btnVoidCheck.Position = UDim2.new(0, 0, 0, 40)
btnVoidCheck.Size = UDim2.new(1, -6, 0, 36)
btnServerHop.Parent = settingsTab
btnServerHop.Position = UDim2.new(0, 0, 0, 0)
btnServerHop.Size = UDim2.new(1, -6, 0, 36)
btnBlacklist.Parent = settingsTab
btnBlacklist.Position = UDim2.new(0, 0, 0, 40)
btnBlacklist.Size = UDim2.new(1, -6, 0, 36)

local safetyStatusBox = Instance.new("TextLabel", safetyTab)
safetyStatusBox.Size = UDim2.new(1, -6, 0, 116)
safetyStatusBox.Position = UDim2.new(0, 0, 0, 86)
safetyStatusBox.BackgroundColor3 = Color3.fromRGB(20, 5, 5)
safetyStatusBox.BackgroundTransparency = 0.15
safetyStatusBox.BorderSizePixel = 0
safetyStatusBox.TextColor3 = Color3.fromRGB(255, 220, 220)
safetyStatusBox.TextSize = 12
safetyStatusBox.Font = Enum.Font.Gotham
safetyStatusBox.TextWrapped = true
safetyStatusBox.TextXAlignment = Enum.TextXAlignment.Left
safetyStatusBox.TextYAlignment = Enum.TextYAlignment.Top
safetyStatusBox.Text = "Anti-void status: Ready\nCurrent safe point: Waiting\nTarget protection: Active"

local updateBox = Instance.new("TextLabel", settingsTab)
updateBox.Size = UDim2.new(1, -6, 0, 130)
updateBox.Position = UDim2.new(0, 0, 0, 86)
updateBox.BackgroundColor3 = Color3.fromRGB(20, 5, 5)
updateBox.BackgroundTransparency = 0.15
updateBox.BorderSizePixel = 0
updateBox.TextColor3 = Color3.fromRGB(255, 220, 220)
updateBox.TextSize = 12
updateBox.Font = Enum.Font.Gotham
updateBox.TextWrapped = true
updateBox.TextXAlignment = Enum.TextXAlignment.Left
updateBox.TextYAlignment = Enum.TextYAlignment.Top
updateBox.Text = "Updates: loading..."

local hint = Instance.new("TextLabel", content)
hint.Size = UDim2.new(0.48,0,0,24)
hint.Position = UDim2.new(0,0,1,-24)
hint.BackgroundTransparency = 1
hint.TextColor3 = Color3.fromRGB(200,200,200)
hint.TextSize = 11
hint.Font = Enum.Font.Gotham
hint.Text = "Luex ULTRA v3.2 | Blacklist Protection + Sequential Multi"
hint.TextWrapped = true

local playerTitle = Instance.new("TextLabel", rightColumn)
playerTitle.Size = UDim2.new(1, 0, 0, 28)
playerTitle.Position = UDim2.new(0, 0, 0, 0)
playerTitle.BackgroundTransparency = 1
playerTitle.TextColor3 = Color3.fromRGB(255, 150, 150)
playerTitle.TextSize = 14
playerTitle.Font = Enum.Font.GothamBold
playerTitle.Text = "PLAYER SELECTION (Click to Toggle)"
playerTitle.TextXAlignment = Enum.TextXAlignment.Left

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
activateButton(refreshBtn)
addButtonStroke(refreshBtn)

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
activateButton(autoRefreshToggle)
addButtonStroke(autoRefreshToggle)

local glowFrame = Instance.new("Frame", logo)
glowFrame.Size = UDim2.new(1.6, 0, 1.6, 0)
glowFrame.Position = UDim2.new(-0.3, 0, -0.3, 0)
glowFrame.BackgroundColor3 = Color3.fromRGB(255, 60, 20)
glowFrame.BackgroundTransparency = 0.95
glowFrame.ZIndex = 1
glowFrame.Active = false
local glowStroke = Instance.new("UIStroke", glowFrame)
glowStroke.Color = Color3.fromRGB(255, 80, 20)
glowStroke.Transparency = 0.9
glowStroke.Thickness = 6

-- Blacklist UI
local blacklistFrame = Instance.new("Frame")
blacklistFrame.Name = "BlacklistFrame"
blacklistFrame.Size = UDim2.new(0, 400, 0, 450)
blacklistFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
blacklistFrame.AnchorPoint = Vector2.new(0.5, 0.5)
blacklistFrame.BackgroundColor3 = Color3.fromRGB(30, 10, 10)
blacklistFrame.BackgroundTransparency = 0.1
blacklistFrame.BorderSizePixel = 0
blacklistFrame.Visible = false
blacklistFrame.ZIndex = 10
blacklistFrame.Parent = screen
local blacklistBorder = Instance.new("UIStroke", blacklistFrame)
blacklistBorder.Color = Color3.fromRGB(255, 30, 30)
blacklistBorder.Thickness = 3
blacklistBorder.Transparency = 0.3
local blacklistTopBar = Instance.new("Frame", blacklistFrame)
blacklistTopBar.Size = UDim2.new(1, 0, 0, 40)
blacklistTopBar.BackgroundColor3 = Color3.fromRGB(50, 10, 10)
blacklistTopBar.BorderSizePixel = 0
local blacklistTitle = Instance.new("TextLabel", blacklistTopBar)
blacklistTitle.Size = UDim2.new(1, -80, 1, 0)
blacklistTitle.Position = UDim2.new(0, 10, 0, 0)
blacklistTitle.BackgroundTransparency = 1
blacklistTitle.Text = "🛡️ BLACKLIST MANAGER"
blacklistTitle.Font = Enum.Font.GothamBlack
blacklistTitle.TextSize = 18
blacklistTitle.TextColor3 = Color3.fromRGB(255, 100, 100)
blacklistTitle.TextXAlignment = Enum.TextXAlignment.Left
local blacklistCloseBtn = Instance.new("TextButton", blacklistTopBar)
blacklistCloseBtn.Size = UDim2.new(0, 60, 0, 30)
blacklistCloseBtn.Position = UDim2.new(1, -70, 0, 5)
blacklistCloseBtn.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
blacklistCloseBtn.BorderSizePixel = 0
blacklistCloseBtn.Text = "✕"
blacklistCloseBtn.Font = Enum.Font.GothamBold
blacklistCloseBtn.TextSize = 20
blacklistCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
local blacklistInfo = Instance.new("TextLabel", blacklistFrame)
blacklistInfo.Size = UDim2.new(1, -20, 0, 50)
blacklistInfo.Position = UDim2.new(0, 10, 0, 45)
blacklistInfo.BackgroundTransparency = 1
blacklistInfo.Text = "Protected: " .. PROTECTED_USER .. " (Cannot be removed)\nClick player to toggle blacklist"
blacklistInfo.Font = Enum.Font.Gotham
blacklistInfo.TextSize = 12
blacklistInfo.TextColor3 = Color3.fromRGB(255, 200, 100)
blacklistInfo.TextWrapped = true
blacklistInfo.TextYAlignment = Enum.TextYAlignment.Top
local blacklistPlayerList = Instance.new("ScrollingFrame", blacklistFrame)
blacklistPlayerList.Name = "BlacklistPlayerList"
blacklistPlayerList.Size = UDim2.new(1, -20, 1, -105)
blacklistPlayerList.Position = UDim2.new(0, 10, 0, 95)
blacklistPlayerList.BackgroundColor3 = Color3.fromRGB(40, 10, 10)
blacklistPlayerList.BackgroundTransparency = 0.3
blacklistPlayerList.BorderSizePixel = 0
blacklistPlayerList.ScrollBarThickness = 6
blacklistPlayerList.AutomaticCanvasSize = Enum.AutomaticSize.Y
blacklistPlayerList.CanvasSize = UDim2.new(0, 0, 0, 0)

getgenv().LuexUI = {
    Screen = screen,
    Main = main,
    Logo = logo,
    MinBtn = minBtn,
    CombatTabBtn = btnCombatTab,
    SafetyTabBtn = btnSafetyTab,
    SettingsTabBtn = btnSettingsTab,
    CombatTab = combatTab,
    SafetyTab = safetyTab,
    SettingsTab = settingsTab,
    AutoBtn = btnAuto,
    AutoSelectedBtn = btnAutoSelected,
    MultiSelectedBtn = btnMultiSelected,
    ChangePlayerBtn = btnChangePlayer,
    BlacklistBtn = btnBlacklist,
    PositionModeBtn = btnPositionMode,
    SpeedBoostBtn = btnSpeedBoost,
    PredictBtn = btnPredict,
    ServerHopBtn = btnServerHop,
    SafeZoneBtn = btnSafeZone,
    VoidCheckBtn = btnVoidCheck,
    PlayerList = playerListContainer,
    RefreshBtn = refreshBtn,
    AutoRefreshToggle = autoRefreshToggle,
    BlacklistFrame = blacklistFrame,
    BlacklistPlayerList = blacklistPlayerList,
    SafetyStatusBox = safetyStatusBox,
    UpdateBox = updateBox,
    Glow = glowFrame,
    Crack = crackContainer
}

local langBtn = Instance.new("TextButton", topBar)
langBtn.Name = "LangToggle"
langBtn.Size = UDim2.new(0, 50, 0, 24)
langBtn.Position = UDim2.new(1, -102, 0, 11)
langBtn.BackgroundColor3 = Color3.fromRGB(80, 10, 10)
langBtn.BorderSizePixel = 0
langBtn.Text = "ENG"
langBtn.Font = Enum.Font.GothamBold
langBtn.TextSize = 12
langBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
langBtn.Active = true
langBtn.ZIndex = 35

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
local minimized = false
minBtn.MouseButton1Click:Connect(function()
    if minimized then
        TweenService:Create(main, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0,550,0,380)}):Play()
        content.Visible = true
        tabBar.Visible = true
        logo.TextTransparency = 0
        langBtn.Visible = true
    else
        local targetSize = UDim2.new(0,150,0,46)
        TweenService:Create(main, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetSize}):Play()
        content.Visible = false
        tabBar.Visible = false
        logo.TextTransparency = 0
        langBtn.Visible = false
    end
    minimized = not minimized
end)

local activeTab = "Combat"
local refreshPlayerList
local updateSafetyStatus
local function setActiveTab(tabName)
    activeTab = tabName
    combatTab.Visible = tabName == "Combat"
    safetyTab.Visible = tabName == "Safety"
    settingsTab.Visible = tabName == "Settings"
    btnCombatTab.BackgroundColor3 = combatTab.Visible and Color3.fromRGB(120, 20, 20) or Color3.fromRGB(35, 6, 6)
    btnSafetyTab.BackgroundColor3 = safetyTab.Visible and Color3.fromRGB(120, 20, 20) or Color3.fromRGB(35, 6, 6)
    btnSettingsTab.BackgroundColor3 = settingsTab.Visible and Color3.fromRGB(120, 20, 20) or Color3.fromRGB(35, 6, 6)
    if tabName == "Combat" and refreshPlayerList then
        refreshPlayerList()
    elseif tabName == "Safety" and updateSafetyStatus then
        updateSafetyStatus()
    end
end
btnCombatTab.MouseButton1Click:Connect(function()
    setActiveTab("Combat")
end)
btnSafetyTab.MouseButton1Click:Connect(function()
    setActiveTab("Safety")
end)
btnSettingsTab.MouseButton1Click:Connect(function()
    setActiveTab("Settings")
end)

local UI = getgenv().LuexUI
local autoOn = Config.AutoOn
local autoSelectedOn = Config.AutoSelectedOn
local multiOn = Config.MultiOn
local predictOn = Config.PredictOn
local serverHopOn = Config.ServerHopOn
local safeZoneOn = Config.SafeZoneOn
local voidCheckOn = Config.VoidCheckOn
local autoRefreshOn = Config.AutoRefreshOn
local positionMode = Config.PositionMode
local speedBoostOn = Config.SpeedBoostOn
local currentTarget = nil
local highlightGui = nil
local highlightTarget = nil
local highlightText = nil
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
local selectedTargets = Config.SelectedTargets
local blacklistedPlayers = Config.BlacklistedPlayers
local currentMultiIndex = 1
local lastTargetCheck = 0
local targetCheckRate = 0.1
local lastSwitchNotify = 0
local switchNotifyCooldown = 2
local safePlatform = nil
local savedSafeZoneModes = {
    auto = false,
    selected = false,
    multi = false
}
local safeZoneGui = nil
local safeZoneNowBtn = nil
local voidSpawnCFrame = nil
local voidSafeHeight = nil
local lastVoidSafeCFrame = nil
local lastVoidNotify = 0
local voidDangerTargets = {}
local voidDangerCooldown = 6
-- Đã giảm ngưỡng để không bị kéo lên quá sớm
local voidWarnOffset = 100   -- bỏ qua target khi rơi sâu 40 đơn vị
local voidRescueOffset = 55 -- cứu bạn khi rơi sâu 55 đơn vị
local removeSafePlatform
local manualSafeMode = false
local complimentDialog = nil
local complimentVisible = false
local mainReady = true
local mainStarted = false
local toolList = {
    "Normal Punch", "Consecutive Punches", "Shove", "Uppercut", "Serious Punch",
    "Flowing Water", "Lethal Whirlwind Stream", "Hunter's Grasp", "Prey's Peril",
    "Water Stream Cutting Fist", "The Final Hunt", "Rock Splitting Fist", "Crushed Rock",
    "Machine Gun Blows", "Ignition Burst", "Blitz Shot", "Jet Dive",
    "Thunder Kick", "Speedblitz Dropkick", "Flamewave Cannon", "Incinerate",
    "Flash Strike", "Whirlwind Kick", "Scatter", "Explosive Shuriken",
    "Twinblade Rush", "Straight On", "Carnage", "Fourfold Flashstrike",
    "Homerun", "Beatdown", "Grand Slam", "Foul Ball",
    "Savage Tornado", "Brutual Beatdown", "Strength Difference", "Death Blow",
    "Quick Slice", "Atmos Cleave", "Pinpoint Cut", "Split Second Counter",
    "Sunset", "Solar Cleave", "Sunrise", "Atomic Slash",
    "Crushing Pull", "Windstorm Fury", "Stone Coffin", "Expulsive Push",
    "Cosmic Strike", "Psychic Ricochet", "Terrible Tornado", "Sky Snatcher",
    "Bullet Barrage", "Vanishing Kick", "Head First", "Grand Fissure",
    "Twin Fangs", "Earth Splitting Strike", "Last Breath",
    "Weboom", "Plasma Cannon", "Trinity Tear", "Twin Burst",
    "Photon Edge", "Photon Dive", "Conquest", "Missiles",
    "Railgun", "Tactical Storm",
    "Grave Maker", "Blast Breaker", "Point Blank", "Cross Fire"
}

local playerButtons = {}
local blacklistButtons = {}
local selectedBlacklistPlayers = {}
local applyLang
local startMain
local teleportToPosition
local faceTargetStep
local spamAttack

-- Blacklist Functions
local function isBlacklisted(player)
    return table.find(blacklistedPlayers, player.Name) ~= nil
end
local function toggleBlacklist(player)
    if player.Name == PROTECTED_USER then
        notify("❌ Cannot modify " .. PROTECTED_USER .. " - Protected user!", 2)
        return
    end
    local index = table.find(blacklistedPlayers, player.Name)
    if index then
        table.remove(blacklistedPlayers, index)
        notify("✅ Removed from blacklist: " .. player.Name, 1.5)
    else
        table.insert(blacklistedPlayers, player.Name)
        notify("🛡️ Added to blacklist: " .. player.Name, 1.5)
        local selectedIndex = table.find(selectedTargets, player)
        if selectedIndex then
            table.remove(selectedTargets, selectedIndex)
            notify("Removed from selected targets", 1)
        end
        if currentTarget == player then
            currentTarget = nil
            clearHighlight()
        end
    end
    Config.BlacklistedPlayers = blacklistedPlayers
    SaveConfig()
    applyLang()
end
local function updateBlacklistButton(button, player)
    local isBlack = isBlacklisted(player)
    local isProtected = player.Name == PROTECTED_USER
    local isSelected = selectedBlacklistPlayers[player] ~= nil
    local targetBg = isProtected and Color3.fromRGB(100, 20, 20) or (isSelected and Color3.fromRGB(80, 5, 5) or (isBlack and Color3.fromRGB(60, 10, 10) or Color3.fromRGB(30, 8, 8)))
    local targetTextColor = isProtected and Color3.fromRGB(255, 200, 100) or (isSelected and Color3.fromRGB(255, 50, 50) or (isBlack and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(240, 240, 240)))
    local icon = isProtected and "🔒 " or (isBlack and "🛡️ " or "")
    local checkmark = isSelected and " ✓" or ""
    TweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundColor3 = targetBg}):Play()
    TweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {TextColor3 = targetTextColor}):Play()
    button.Text = icon .. player.Name .. checkmark
end

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
local function trimText(value)
    if type(value) ~= "string" then return "" end
    return (value:gsub("^%s+", ""):gsub("%s+$", ""))
end
local function isSelected(player)
    for _, p in ipairs(selectedTargets) do
        if p == player then return true end
    end
    return false
end
local function clearHighlight()
    pcall(function()
        if highlightGui and highlightGui.Parent then highlightGui:Destroy() end
        highlightGui = nil
        highlightTarget = nil
        highlightText = nil
    end)
end
local function updateButtonColors(button, isSel, playerName)
    local targetBg = isSel and Color3.fromRGB(80, 5, 5) or Color3.fromRGB(30, 8, 8)
    local targetTextColor = isSel and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(240,240,240)
    local targetText = playerName .. (isSel and " ✓" or "")
    TweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = targetBg}):Play()
    TweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = targetTextColor}):Play()
    button.Text = targetText
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
        if not existingStroke:GetAttribute("PulseRunning") then
            existingStroke:SetAttribute("PulseRunning", true)
            spawn(function()
                while existingStroke and existingStroke.Parent do
                    TweenService:Create(existingStroke, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Transparency = 0.7}):Play()
                    wait(0.8)
                end
            end)
        end
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
    if isBlacklisted(player) then
        notify("❌ " .. player.Name .. " is blacklisted! Cannot select.", 2)
        return
    end
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
    if foundIndex then
        table.remove(selectedTargets, foundIndex)
        notify("Deselected: " .. player.Name .. " (" .. #selectedTargets .. " left)", 1.5)
        if multiOn and foundIndex then
            if foundIndex < currentMultiIndex then
                currentMultiIndex = currentMultiIndex - 1
            elseif foundIndex == currentMultiIndex then
                currentMultiIndex = (#selectedTargets > 0) and (math.fmod(currentMultiIndex - 1, #selectedTargets) + 1) or 1
                lastTargetCheck = 0
            end
            if currentMultiIndex > #selectedTargets then currentMultiIndex = 1 end
        end
    else
        table.insert(selectedTargets, 1, player)
        notify("Selected: " .. player.Name .. " (" .. #selectedTargets .. " total)", 1.5)
        if multiOn then
            currentMultiIndex = 1
            immediateAttack(player)
            notify("Multi ON: Đánh ngay target mới! 💥", 1.5)
            lastTargetCheck = 0
        end
    end
    Config.SelectedTargets = selectedTargets
    SaveConfig()
    local button = playerButtons[player]
    if button then
        local isSel = isSelected(player)
        updateButtonColors(button, isSel, player.Name)
    end
    if autoSelectedOn and #selectedTargets ~= 1 then
        autoSelectedOn = false
        Config.AutoSelectedOn = false
        SaveConfig()
        applyLang()
        notify("Single mode disabled - Select exactly 1 target.", 2)
    end
    if multiOn and #selectedTargets < 2 then
        multiOn = false
        Config.MultiOn = false
        SaveConfig()
        applyLang()
        notify("Multi mode disabled - Select at least 2 targets.", 2)
    end
    updateSelectedBtnsText()
end
local function updateSelectedBtnsText()
    applyLang()
end
local function makeHighlight(player, multiIndex)
    pcall(function()
        if not player or not player.Character then return end
        local root = player.Character:FindFirstChild("HumanoidRootPart") or player.Character:FindFirstChildWhichIsA("BasePart")
        if not root then return end
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
        local targetText = "TARGET: "..player.Name..modeText
        if highlightGui and highlightGui.Parent and highlightTarget == player and highlightText == targetText then
            highlightGui.Adornee = root
            return
        end
        if highlightGui and highlightGui.Parent then highlightGui:Destroy() end
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
        label.Text = targetText
        label.TextColor3 = Color3.fromRGB(255,200,200)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14
        label.TextStrokeTransparency = 0.6
        highlightGui = bg
        highlightTarget = player
        highlightText = targetText
    end)
end
local isVoidDangerTarget
local function chooseRandom()
    local pls = {}
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and
            not isBlacklisted(p) and
            not (isVoidDangerTarget and isVoidDangerTarget(p)) and
            p.Character and
            p.Character:FindFirstChild("Humanoid") and
            p.Character:FindFirstChild("Humanoid").Health > 0 then
            table.insert(pls, p)
        end
    end
    if #pls == 0 then return nil end
    return pls[math.random(1,#pls)]
end
local function chooseWeakest()
    local weakest = nil
    local lowestHp = math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and
            not isBlacklisted(p) and
            not (isVoidDangerTarget and isVoidDangerTarget(p)) and
            p.Character and
            p.Character:FindFirstChild("Humanoid") and
            p.Character.Humanoid.Health > 0 then
            local hp = p.Character.Humanoid.Health
            if hp < lowestHp then
                lowestHp = hp
                weakest = p
            end
        end
    end
    return weakest
end
local function rememberVoidSafePoint(humanoidRootPart, forceSpawn)
    if not humanoidRootPart then return end
    if forceSpawn or not voidSpawnCFrame then
        voidSpawnCFrame = humanoidRootPart.CFrame
        voidSafeHeight = humanoidRootPart.Position.Y
    end
    local baseY = voidSafeHeight or humanoidRootPart.Position.Y
    if humanoidRootPart.Position.Y >= baseY - 8 then
        lastVoidSafeCFrame = humanoidRootPart.CFrame
    end
end
isVoidDangerTarget = function(player)
    local expires = voidDangerTargets[player]
    if expires and expires > tick() then
        return true
    end
    voidDangerTargets[player] = nil
    local baseY = voidSafeHeight
    local root = player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    return baseY and root and root.Position.Y < (baseY - voidWarnOffset)
end
local function isValidVoidReplacement(player, skipPlayer)
    if not player or player == LocalPlayer or player == skipPlayer or isBlacklisted(player) or isVoidDangerTarget(player) then
        return false
    end
    local character = player.Character
    local humanoid = character and character:FindFirstChild("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    return humanoid and humanoid.Health > 0 and root ~= nil
end
local function switchVoidTarget(skipPlayer)
    if multiOn and #selectedTargets >= 2 then
        for i = 1, #selectedTargets do
            local index = math.fmod(currentMultiIndex + i - 1, #selectedTargets) + 1
            local candidate = selectedTargets[index]
            if isValidVoidReplacement(candidate, skipPlayer) then
                currentMultiIndex = index
                currentTarget = candidate
                lastTargetCheck = tick()
                makeHighlight(currentTarget, currentMultiIndex)
                notify("Void target skipped. Switched to: " .. currentTarget.Name, 2)
                return true
            end
        end
        return false
    end
    local weakest = nil
    local lowestHp = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if isValidVoidReplacement(player, skipPlayer) then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid.Health < lowestHp then
                lowestHp = humanoid.Health
                weakest = player
            end
        end
    end
    if weakest then
        currentTarget = weakest
        lastTargetCheck = 0
        makeHighlight(currentTarget)
        notify("Void target skipped. Switched to: " .. currentTarget.Name, 2)
        return true
    end
    return false
end
local lang = "ENG"
local LANG_FILE = "luex/laun.json"
local UPDATE_FILE = "luex/updates.json"
local UPDATE_VERSION = "v3.3-tabs-safety"
local UPDATE_NOTES = {
    "Added Combat/Safety/Settings tabs",
    "Added smart Void Check with safe height",
    "Added update notification history"
}
local LANG_TEXT = {
    ENG = {
        auto = "Auto Kill Random: ",
        single = "Auto Kill Selected (1): ",
        multi = "Multi Kill Selected: ",
        change = "Change Player",
        blacklist = "🛡️ Blacklist (%d) ✓",
        pos = "Position Mode: ",
        speed = "Speed Boost: ",
        predict = "Predict Direction: ",
        hop = "Auto Server Hop: ",
        safe = "Auto Safe Zone: ",
        void = "Void Check: ",
        safeNow = "SAFEZONE NOW",
        refresh = "🔄 Refresh Players",
        autoRefresh = "Auto Refresh: ",
        playerTitle = "PLAYER SELECTION (Click to Toggle)",
        hint = "Luex ULTRA v3.2 | Blacklist Protection + Sequential Multi",
        blTitle = "🛡️ BLACKLIST MANAGER",
        blInfo = "Protected: %s (Cannot be removed)\nClick player to toggle blacklist"
    },
    VN = {
        auto = "Auto Kill Ngẫu Nhiên: ",
        single = "Auto Kill Đã Chọn (1): ",
        multi = "Multi Kill Đã Chọn: ",
        change = "Đổi Người Chơi",
        blacklist = "🛡️ Blacklist (%d) ✓",
        pos = "Chế Độ Vị Trí: ",
        speed = "Tăng Tốc: ",
        predict = "Dự Đoán Hướng: ",
        hop = "Auto Đổi Server: ",
        safe = "Auto Safe Zone: ",
        void = "Check Void: ",
        safeNow = "SAFEZONE NGAY",
        refresh = "🔄 Làm Mới DS",
        autoRefresh = "Tự Động Làm Mới: ",
        playerTitle = "CHỌN MỤC TIÊU (Bấm để bật/tắt)",
        hint = "Luex ULTRA v3.2 | Bảo vệ Blacklist + Multi tuần tự",
        blTitle = "🛡️ QUẢN LÝ BLACKLIST",
        blInfo = "Bảo vệ: %s (Không thể gỡ)\nBấm tên để bật/tắt blacklist"
    }
}
local function loadLang()
    if readfile and isfile and isfile(LANG_FILE) then
        local ok, data = pcall(function() return readfile(LANG_FILE) end)
        if ok and data and data ~= "" then
            local okDecode, decoded = pcall(function()
                return HttpService:JSONDecode(data)
            end)
            if okDecode and decoded and (decoded.lang == "ENG" or decoded.lang == "VN") then
                lang = decoded.lang
            end
        end
    end
end
local function saveLang()
    if writefile and makefolder then
        pcall(function() makefolder("luex") end)
        local payload = HttpService:JSONEncode({lang = lang})
        pcall(function() writefile(LANG_FILE, payload) end)
    end
end
local function getRealTimestamp()
    local ok, value = pcall(function()
        return os.date("%Y-%m-%d %H:%M:%S")
    end)
    return (ok and value) or tostring(DateTime.now():ToUniversalTime())
end
local function loadUpdates()
    if readfile and isfile and isfile(UPDATE_FILE) then
        local ok, data = pcall(function() return readfile(UPDATE_FILE) end)
        if ok and data and data ~= "" then
            local okDecode, decoded = pcall(function()
                return HttpService:JSONDecode(data)
            end)
            if okDecode and type(decoded) == "table" and type(decoded.entries) == "table" then
                return decoded
            end
        end
    end
    return {entries = {}}
end
local function saveUpdates(data)
    if writefile and makefolder then
        pcall(function() makefolder("luex") end)
        pcall(function() writefile(UPDATE_FILE, HttpService:JSONEncode(data)) end)
    end
end
local function refreshUpdateBox(data)
    if not updateBox then return end
    local lines = {"Updates"}
    for i = math.min(#data.entries, 5), 1, -1 do
        local entry = data.entries[i]
        table.insert(lines, tostring(entry.time or "?") .. " - " .. tostring(entry.title or "Update"))
        if type(entry.notes) == "table" then
            for _, note in ipairs(entry.notes) do
                table.insert(lines, "  - " .. tostring(note))
            end
        end
    end
    updateBox.Text = table.concat(lines, "\n")
end
local function recordUpdateNotice()
    local data = loadUpdates()
    local alreadyRecorded = false
    for _, entry in ipairs(data.entries) do
        if entry.version == UPDATE_VERSION then
            alreadyRecorded = true
            break
        end
    end
    if not alreadyRecorded then
        table.insert(data.entries, {
            version = UPDATE_VERSION,
            title = "Luex UI/Safety update",
            time = getRealTimestamp(),
            notes = UPDATE_NOTES
        })
        saveUpdates(data)
    end
    refreshUpdateBox(data)
end

local COMPLIMENT_TARGET = "werop4543"
local COMPLIMENT_DONE = "luex/donee.json"
local COMPLIMENT_MP3 = "luex/phaichiu.mp3"
local COMPLIMENT_URL = "https://files.catbox.moe/b1ei1c.mp3"

local function isComplimentDone()
    if isfile and isfile(COMPLIMENT_DONE) then
        return true
    end
    return false
end

local function markComplimentDone()
    if writefile and makefolder then
        pcall(function() makefolder("luex") end)
        pcall(function() writefile(COMPLIMENT_DONE, HttpService:JSONEncode({done = true})) end)
    end
end

local function ensureComplimentAudio()
    if not writefile or not isfile then return false end
    if isfile(COMPLIMENT_MP3) then return true end
    local body = nil
    if syn and syn.request then
        local res = syn.request({Url = COMPLIMENT_URL, Method = "GET"})
        if res and res.Body then body = res.Body end
    elseif http_request then
        local res = http_request({Url = COMPLIMENT_URL, Method = "GET"})
        if res and res.Body then body = res.Body end
    elseif request then
        local res = request({Url = COMPLIMENT_URL, Method = "GET"})
        if res and res.Body then body = res.Body end
    end
    if body then
        pcall(function() writefile(COMPLIMENT_MP3, body) end)
        return isfile(COMPLIMENT_MP3)
    end
    return false
end

local function playComplimentAudio()
    if not isfile or not isfile(COMPLIMENT_MP3) then return end
    local getAsset = getsynasset or getcustomasset
    if not getAsset then return end
    local sound = Instance.new("Sound")
    sound.SoundId = getAsset(COMPLIMENT_MP3)
    sound.Volume = 10
    sound.Parent = workspace
    sound:Play()
    game:GetService("Debris"):AddItem(sound, 10)
end

local function fadeAndDestroy(frame, duration)
    local t = TweenInfo.new(duration or 0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    for _, obj in ipairs(frame:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            TweenService:Create(obj, t, {TextTransparency = 1, BackgroundTransparency = 1}):Play()
        elseif obj:IsA("Frame") then
            TweenService:Create(obj, t, {BackgroundTransparency = 1}):Play()
        elseif obj:IsA("UIStroke") then
            TweenService:Create(obj, t, {Transparency = 1}):Play()
        end
    end
    TweenService:Create(frame, t, {BackgroundTransparency = 1}):Play()
    task.delay((duration or 0.6) + 0.05, function()
        if frame and frame.Parent then frame:Destroy() end
    end)
end

local function buildComplimentDialog()
    if complimentDialog and complimentDialog.Parent then
        return complimentDialog
    end
    local frame = Instance.new("Frame")
    frame.Name = "ComplimentDialog"
    frame.Size = UDim2.new(0, 420, 0, 200)
    frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.BackgroundColor3 = Color3.fromRGB(25, 10, 10)
    frame.BorderSizePixel = 0
    frame.ZIndex = 50
    frame.Parent = UI.Screen

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(255, 60, 60)
    stroke.Thickness = 2
    stroke.Transparency = 0.2

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 90)
    label.Position = UDim2.new(0, 10, 0, 15)
    label.BackgroundTransparency = 1
    label.Text = "bạn là 1 đẹp trai"
    label.TextColor3 = Color3.fromRGB(255, 220, 220)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.TextWrapped = true
    label.ZIndex = 51
    label.Parent = frame

    local btnYes = Instance.new("TextButton")
    btnYes.Size = UDim2.new(0, 170, 0, 36)
    btnYes.Position = UDim2.new(0, 25, 1, -55)
    btnYes.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
    btnYes.BorderSizePixel = 0
    btnYes.Text = "Đúng vậy"
    btnYes.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnYes.Font = Enum.Font.GothamBold
    btnYes.TextSize = 14
    btnYes.ZIndex = 51
    btnYes.Parent = frame

    local btnNo = Instance.new("TextButton")
    btnNo.Size = UDim2.new(0, 170, 0, 36)
    btnNo.Position = UDim2.new(1, -195, 1, -55)
    btnNo.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btnNo.BorderSizePixel = 0
    btnNo.Text = "Không phải"
    btnNo.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnNo.Font = Enum.Font.GothamBold
    btnNo.TextSize = 14
    btnNo.ZIndex = 51
    btnNo.Parent = frame

    btnYes.MouseButton1Click:Connect(function()
        if ensureComplimentAudio() then
            playComplimentAudio()
        end
        markComplimentDone()
        fadeAndDestroy(frame, 0.6)
        complimentVisible = false
        mainReady = true
        startMain()
        minimized = false
        if main then
            TweenService:Create(main, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0,550,0,380)}):Play()
        end
        if content then content.Visible = true end
        if tabBar then tabBar.Visible = true end
        if langBtn then langBtn.Visible = true end
    end)

    btnNo.MouseButton1Click:Connect(function()
        local temp = Instance.new("TextLabel")
        temp.Size = UDim2.new(1, -20, 0, 28)
        temp.Position = UDim2.new(0, 10, 1, -95)
        temp.BackgroundTransparency = 1
        temp.Text = "Được rồi"
        temp.TextColor3 = Color3.fromRGB(200, 200, 200)
        temp.Font = Enum.Font.Gotham
        temp.TextSize = 14
        temp.ZIndex = 52
        temp.Parent = frame
        TweenService:Create(temp, TweenInfo.new(0.6, Enum.EasingStyle.Quad), {TextTransparency = 1}):Play()
        task.delay(0.7, function()
            if temp and temp.Parent then temp:Destroy() end
        end)
        fadeAndDestroy(frame, 0.4)
        complimentVisible = false
        task.delay(1.0, function()
            if not isComplimentDone() then
                complimentDialog = nil
                showComplimentDialog()
            end
        end)
    end)

    complimentDialog = frame
    return frame
end

function showComplimentDialog()
    if complimentVisible or isComplimentDone() then return end
    complimentVisible = true
    mainReady = false
    if content then content.Visible = false end
    if tabBar then tabBar.Visible = false end
    buildComplimentDialog()
end

applyLang = function()
    local t = LANG_TEXT[lang] or LANG_TEXT.ENG
    btnAuto.Text = t.auto .. (autoOn and "ON" or "OFF")
    btnAutoSelected.Text = t.single .. (autoSelectedOn and "ON" or "OFF")
    btnMultiSelected.Text = t.multi .. (multiOn and ("ON (" .. #selectedTargets .. ")") or "OFF")
    btnChangePlayer.Text = t.change
    btnBlacklist.Text = string.format(t.blacklist, #Config.BlacklistedPlayers)
    btnPositionMode.Text = t.pos .. positionMode
    btnSpeedBoost.Text = t.speed .. (speedBoostOn and "ON" or "OFF")
    btnPredict.Text = t.predict .. (predictOn and "ON" or "OFF")
    btnServerHop.Text = t.hop .. (serverHopOn and "ON" or "OFF")
    btnSafeZone.Text = t.safe .. (safeZoneOn and "ON" or "OFF")
    btnVoidCheck.Text = t.void .. (voidCheckOn and "ON" or "OFF")
    refreshBtn.Text = t.refresh
    autoRefreshToggle.Text = t.autoRefresh .. (autoRefreshOn and "ON" or "OFF")
    playerTitle.Text = t.playerTitle
    hint.Text = t.hint
    blacklistTitle.Text = t.blTitle
    blacklistInfo.Text = string.format(t.blInfo, PROTECTED_USER)
    langBtn.Text = lang
    if safeZoneNowBtn and safeZoneNowBtn.Parent then
        safeZoneNowBtn.Text = t.safeNow
    end
end
langBtn.MouseButton1Click:Connect(function()
    lang = (lang == "ENG") and "VN" or "ENG"
    applyLang()
    saveLang()
end)
local function canRunMain()
    return mainReady
end
local function checkComplimentTarget()
    if isComplimentDone() then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p.Name == COMPLIMENT_TARGET then
            mainReady = false
            showComplimentDialog()
            return
        end
    end
end
local function getPing()
    local ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
    return math.clamp(ping, 0.05, 0.5)
end
local function predictTargetPosition(targetRoot)
    if not predictOn or not targetRoot then return targetRoot.Position end
    local ping = getPing()
    local extraOffset = 0.08
    if targetRoot.Velocity.Magnitude > 1 then
        return targetRoot.Position + (targetRoot.Velocity * (ping + extraOffset))
    end
    return targetRoot.Position
end
teleportToPosition = function(targetRoot, hrp)
    if not currentTarget or isBlacklisted(currentTarget) then return end
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
local function speedBoostStep()
    local char = LocalPlayer.Character
    if not char or not speedBoostOn then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = 50
    end
end
faceTargetStep = function()
    if not currentTarget or isBlacklisted(currentTarget) or not currentTarget.Character then return end
    local targetRoot = currentTarget.Character:FindFirstChild("HumanoidRootPart")
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not targetRoot or not hrp then return end
    hrp.CFrame = CFrame.lookAt(hrp.Position, predictTargetPosition(targetRoot))
end
spamAttack = function()
    if not currentTarget or isBlacklisted(currentTarget) or not LocalPlayer.Character then return end
    local remote = LocalPlayer.Character:FindFirstChild("Communicate")
    if not remote then return end

    -- Gửi phím G (giữ nguyên)
    remote:FireServer({
        MoveDirection = Vector3.zero,
        Goal = "KeyPress",
        Key = Enum.KeyCode.G
    })

    -- Gửi phím Q giống hệt cấu trúc của G
    remote:FireServer({
        MoveDirection = Vector3.zero,
        Goal = "KeyPress",
        Key = Enum.KeyCode.Q
    })

    -- Click chuột trái
    remote:FireServer({
        Goal = "LeftClick",
        Mobile = true
    })

    -- Quét tool
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

local function createSafePlatform(manual)
    if safePlatform then return end
    manualSafeMode = manual or false
    local character = LocalPlayer.Character
    if not character then return end
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    savedSafeZoneModes.auto = autoOn
    savedSafeZoneModes.selected = autoSelectedOn
    savedSafeZoneModes.multi = multiOn
    autoOn = false
    autoSelectedOn = false
    multiOn = false
    Config.AutoOn = false
    Config.AutoSelectedOn = false
    Config.MultiOn = false
    SaveConfig()
    applyLang()
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
    if manual then
        notify("Safe Zone activated manually (bypass auto removal)!", 3)
    else
        notify("Safe Zone activated! Teleported to safety.", 3)
    end
end
local function enforceSafePlatformBounds(humanoidRootPart)
    if not safePlatform or not humanoidRootPart then return end
    local pos = humanoidRootPart.Position
    local platformPos = safePlatform.Position
    local halfX = safePlatform.Size.X * 0.5 - 3
    local halfZ = safePlatform.Size.Z * 0.5 - 3
    local minY = platformPos.Y + safePlatform.Size.Y * 0.5 + 3
    local clampedX = math.clamp(pos.X, platformPos.X - halfX, platformPos.X + halfX)
    local clampedZ = math.clamp(pos.Z, platformPos.Z - halfZ, platformPos.Z + halfZ)
    local clampedY = math.max(pos.Y, minY)
    if clampedX ~= pos.X or clampedY ~= pos.Y or clampedZ ~= pos.Z then
        local rotationOnly = humanoidRootPart.CFrame - pos
        humanoidRootPart.CFrame = CFrame.new(clampedX, clampedY, clampedZ) * rotationOnly
        if clampedY ~= pos.Y then
            local velocity = humanoidRootPart.AssemblyLinearVelocity
            humanoidRootPart.AssemblyLinearVelocity = Vector3.new(velocity.X, math.max(velocity.Y, 0), velocity.Z)
        end
    end
end
local function checkVoid(humanoidRootPart)
    if not voidCheckOn or not humanoidRootPart then return end
    local pos = humanoidRootPart.Position
    rememberVoidSafePoint(humanoidRootPart, false)
    local baseY = voidSafeHeight or pos.Y
    if pos.Y > baseY - voidRescueOffset then return false end
    local skippedTarget = currentTarget
    if skippedTarget then
        voidDangerTargets[skippedTarget] = tick() + voidDangerCooldown
        currentTarget = nil
        clearHighlight()
        if switchVoidTarget(skippedTarget) then
            local targetRoot = currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                teleportToPosition(targetRoot, humanoidRootPart)
                humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
            end
            return true
        end
    end
    local targetCFrame = nil
    if safePlatform then
        targetCFrame = safePlatform.CFrame + Vector3.new(0, 5, 0)
    elseif lastVoidSafeCFrame then
        local safePos = lastVoidSafeCFrame.Position
        targetCFrame = CFrame.new(safePos.X, baseY + 5, safePos.Z) * (lastVoidSafeCFrame - safePos)
    elseif voidSpawnCFrame then
        local spawnPos = voidSpawnCFrame.Position
        targetCFrame = CFrame.new(spawnPos.X, baseY + 5, spawnPos.Z) * (voidSpawnCFrame - spawnPos)
    end
    if targetCFrame then
        humanoidRootPart.CFrame = targetCFrame
        humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
        if tick() - lastVoidNotify > 2 then
            notify("Void detected! Returned to safe height.", 2)
            lastVoidNotify = tick()
        end
        return true
    end
    return false
end
updateSafetyStatus = function()
    if not safetyStatusBox then return end
    local safeText = "Waiting"
    if safePlatform then
        safeText = "Safe Platform" .. (manualSafeMode and " (MANUAL)" or "")
    elseif lastVoidSafeCFrame then
        local pos = lastVoidSafeCFrame.Position
        safeText = string.format("X %.0f | Y %.0f | Z %.0f", pos.X, pos.Y, pos.Z)
    elseif voidSpawnCFrame then
        local pos = voidSpawnCFrame.Position
        safeText = string.format("Spawn X %.0f | Y %.0f | Z %.0f", pos.X, pos.Y, pos.Z)
    end
    local dangerCount = 0
    for player, expires in pairs(voidDangerTargets) do
        if expires > tick() then
            dangerCount = dangerCount + 1
        else
            voidDangerTargets[player] = nil
        end
    end
    safetyStatusBox.Text = table.concat({
        "Anti-void status: " .. (voidCheckOn and "ON" or "OFF"),
        "Current safe point: " .. safeText,
        "Target protection: " .. (dangerCount > 0 and (dangerCount .. " skipped") or "Active"),
        "Safe Platform: " .. (safePlatform and (manualSafeMode and "🔒 MANUAL" or "AUTO") or "OFF")
    }, "\n")
end
local function destroySafeZoneGui()
    if safeZoneGui and safeZoneGui.Parent then
        safeZoneGui:Destroy()
    end
    safeZoneGui = nil
    safeZoneNowBtn = nil
end
local function createSafeZoneGui()
    if safeZoneGui and safeZoneGui.Parent then return end
    local gui = Instance.new("ScreenGui")
    gui.Name = "LuexSafeZoneUI"
    gui.ResetOnSpawn = false
    gui.Parent = game.CoreGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 160, 0, 42)
    frame.Position = UDim2.new(0, 20, 0, 140)
    frame.BackgroundColor3 = Color3.fromRGB(35, 10, 10)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Parent = gui

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
    button.BorderSizePixel = 0
    button.Text = (LANG_TEXT[lang] or LANG_TEXT.ENG).safeNow
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 14
    button.Parent = frame
    safeZoneNowBtn = button

    local dragging = false
    local dragStart
    local startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
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
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if dragging then
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end
    end)

    button.MouseButton1Click:Connect(function()
        if safePlatform then
            removeSafePlatform()
            notify("Safe Zone deactivated", 2)
        else
            createSafePlatform(true)
            notify("Safe Zone activated manually (bypass auto removal)!", 2)
        end
    end)

    safeZoneGui = gui
end
function removeSafePlatform()
    if safePlatform then
        safePlatform:Destroy()
        safePlatform = nil
        manualSafeMode = false
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                autoOn = savedSafeZoneModes.auto
                autoSelectedOn = savedSafeZoneModes.selected
                multiOn = savedSafeZoneModes.multi
                Config.AutoOn = autoOn
                Config.AutoSelectedOn = autoSelectedOn
                Config.MultiOn = multiOn
                SaveConfig()
                applyLang()
                local restoredAny = autoOn or autoSelectedOn or multiOn
                notify("Safe Zone deactivated! Auto Kill "..(restoredAny and "restored" or "disabled")..".", 3)
            else
                notify("Safe Zone deactivated!", 3)
            end
        end
    end
end
startMain = function()
    if mainStarted then
        if content then
            content.Visible = not minimized
        end
        if tabBar then
            tabBar.Visible = not minimized
        end
        return
    end
    mainStarted = true
    loadLang()
    applyLang()
    setActiveTab(activeTab)
    recordUpdateNotice()
    refreshPlayerList()
    updateSelectedBtnsText()
    if safeZoneOn then
        createSafeZoneGui()
    end
    if content then
        content.Visible = not minimized
    end
    if tabBar then
        tabBar.Visible = not minimized
    end
end

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

-- Player button creation
local function createPlayerButton(player, yPosition)
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
    button.Active = true
    button.ZIndex = 10
    button.Parent = UI.PlayerList
    if isSel then
        local neonStroke = Instance.new("UIStroke", button)
        neonStroke.Name = "NeonStroke"
        neonStroke.Color = Color3.fromRGB(255, 0, 0)
        neonStroke.Transparency = 0.4
        neonStroke.Thickness = 2.5
        neonStroke:SetAttribute("PulseRunning", true)
        spawn(function()
            while button.Parent do
                TweenService:Create(neonStroke, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Transparency = 0.7}):Play()
                wait(0.8)
            end
        end)
    end
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
    button.MouseButton1Click:Connect(function()
        toggleSelect(player)
    end)
    playerButtons[player] = button
    return button
end

local function createBlacklistButton(player, yPosition)
    if blacklistButtons[player] then
        blacklistButtons[player]:Destroy()
    end
    local button = Instance.new("TextButton")
    button.Name = player.Name
    button.Size = UDim2.new(1, -10, 0, 36)
    button.Position = UDim2.new(0, 5, 0, yPosition)
    button.BorderSizePixel = 0
    button.Font = Enum.Font.Gotham
    button.TextSize = 13
    button.AutoButtonColor = false
    button.Active = true
    button.ZIndex = 10
    button.Parent = UI.BlacklistPlayerList
    updateBlacklistButton(button, player)
    button.MouseEnter:Connect(function()
        if player.Name ~= PROTECTED_USER and not isBlacklisted(player) and not selectedBlacklistPlayers[player] then
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 12, 12)}):Play()
        end
    end)
    button.MouseLeave:Connect(function()
        if player.Name ~= PROTECTED_USER and not isBlacklisted(player) and not selectedBlacklistPlayers[player] then
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 8, 8)}):Play()
        end
    end)
    button.MouseButton1Click:Connect(function()
        if selectedBlacklistPlayers[player] then
            selectedBlacklistPlayers[player] = nil
        else
            selectedBlacklistPlayers[player] = true
        end
        updateBlacklistButton(button, player)
    end)
    blacklistButtons[player] = button
    return button
end

refreshPlayerList = function()
    local yPosition = 0
    local visiblePlayers = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            visiblePlayers[player] = true
            if not playerButtons[player] then
                createPlayerButton(player, yPosition)
                yPosition = yPosition + 40
            else
                playerButtons[player].Position = UDim2.new(0, 5, 0, yPosition)
                local status = playerButtons[player]:FindFirstChild("StatusIndicator")
                if status then
                    if player and player.Character then
                        local humanoid = player.Character:FindFirstChild("Humanoid")
                        if humanoid then
                            local targetColor = humanoid.Health <= 0 and Color3.fromRGB(200, 30, 30) or Color3.fromRGB(30, 200, 30)
                            TweenService:Create(status, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = targetColor}):Play()
                        end
                    end
                end
                local isSel = isSelected(player)
                updateButtonColors(playerButtons[player], isSel, player.Name)
                yPosition = yPosition + 40
            end
        end
    end
    for player, button in pairs(playerButtons) do
        if not visiblePlayers[player] then
            button:Destroy()
            playerButtons[player] = nil
        end
    end
    UI.PlayerList.CanvasSize = UDim2.new(0, 0, 0, yPosition)
end

local function refreshBlacklistList()
    for _, button in pairs(blacklistButtons) do
        button:Destroy()
    end
    blacklistButtons = {}
    local yPosition = 0
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            createBlacklistButton(player, yPosition)
            yPosition = yPosition + 40
        end
    end
    UI.BlacklistPlayerList.CanvasSize = UDim2.new(0, 0, 0, yPosition)
end

spawn(function()
    while true do
        if autoRefreshOn then
            if canRunMain() then
                refreshPlayerList()
            else
                wait(1)
            end
        end
        wait(5)
    end
end)

local function onCharacterAdded(char)
    local player = Players:GetPlayerFromCharacter(char)
    if player then
        voidDangerTargets[player] = nil
    end
    if not canRunMain() then
        return
    end
    wait(1)
    local root = char:FindFirstChild("HumanoidRootPart")
    rememberVoidSafePoint(root, true)
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

spawn(function()
    while true do
        RunService.Heartbeat:Wait()
        if canRunMain() then
            if tick() - lastSpeedUpdate > speedUpdateRate then
                speedBoostStep()
                updateSafetyStatus()
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
            if safeZoneOn then
                local character = LocalPlayer.Character
                if character then
                    local humanoid = character:FindFirstChild("Humanoid")
                    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                    if humanoid and humanoid.Health > 0 and humanoidRootPart then
                        local healthPercent = (humanoid.Health / humanoid.MaxHealth) * 100
                        if healthPercent < 35 and not safePlatform then
                            createSafePlatform(false)
                        elseif healthPercent > 80 and safePlatform and not manualSafeMode then
                            removeSafePlatform()
                        end
                        enforceSafePlatformBounds(humanoidRootPart)
                    end
                end
            end
            local char = LocalPlayer.Character
            local humanoid = char and char:FindFirstChild("Humanoid")
            if not (humanoid and humanoid.Health > 0) then
                -- skip processing
            else
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if checkVoid(hrp) then
                    -- void handled
                else
                    if multiOn and #selectedTargets < 2 then
                        multiOn = false
                        Config.MultiOn = false
                        SaveConfig()
                        applyLang()
                        notify("Multi mode disabled - Less than 2 targets left. Hoàn tất kill! 💀", 2)
                        clearHighlight()
                        currentTarget = nil
                        currentMultiIndex = 1
                    end
                    if autoOn and not safePlatform then
                        if not currentTarget or not currentTarget.Character or not currentTarget.Character:FindFirstChild("Humanoid") or currentTarget.Character:FindFirstChild("Humanoid").Health <= 0 or isBlacklisted(currentTarget) or isVoidDangerTarget(currentTarget) then
                            currentTarget = chooseWeakest()
                            if currentTarget then
                                notify("Selected weakest: "..currentTarget.Name.." ["..positionMode.."]", 1.8)
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
                    if autoSelectedOn and not safePlatform and #selectedTargets == 1 then
                        currentTarget = selectedTargets[1]
                        if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("Humanoid") and currentTarget.Character:FindFirstChild("Humanoid").Health > 0 and not isBlacklisted(currentTarget) and not isVoidDangerTarget(currentTarget) then
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
                    if multiOn and not safePlatform and #selectedTargets >= 2 then
                        if tick() - lastTargetCheck > targetCheckRate then
                            local target = selectedTargets[currentMultiIndex]
                            local isValid = target and target.Character and target.Character:FindFirstChild("Humanoid") and target.Character.Humanoid.Health > 0 and not isBlacklisted(target) and not isVoidDangerTarget(target)
                            if not isValid then
                                local targetName = target and target.Name or "Unknown"
                                local attempts = 0
                                repeat
                                    currentMultiIndex = math.fmod(currentMultiIndex, #selectedTargets) + 1
                                    target = selectedTargets[currentMultiIndex]
                                    attempts = attempts + 1
                                    isValid = target and target.Character and target.Character:FindFirstChild("Humanoid") and target.Character.Humanoid.Health > 0 and not isBlacklisted(target) and not isVoidDangerTarget(target)
                                until isValid or attempts >= #selectedTargets
                                lastTargetCheck = tick()
                                if attempts >= #selectedTargets then
                                    currentMultiIndex = 1
                                    currentTarget = nil
                                    clearHighlight()
                                    if tick() - lastSwitchNotify > switchNotifyCooldown then
                                        notify("All targets dead! Waiting for respawn & cycle back to #1... 🔄💀", 3)
                                        lastSwitchNotify = tick()
                                    end
                                else
                                    currentTarget = target
                                    makeHighlight(currentTarget, currentMultiIndex)
                                    if tick() - lastSwitchNotify > switchNotifyCooldown then
                                        notify("Target '" .. targetName .. "' chết. Tiếp theo #" .. currentMultiIndex .. " (" .. #selectedTargets .. " total) 🔄", 1.5)
                                        lastSwitchNotify = tick()
                                    end
                                end
                            else
                                currentTarget = target
                                makeHighlight(currentTarget, currentMultiIndex)
                                lastTargetCheck = tick()
                            end
                        end
                        if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("Humanoid") and currentTarget.Character.Humanoid.Health > 0 and not isBlacklisted(currentTarget) and not isVoidDangerTarget(currentTarget) then
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
                            lastTargetCheck = 0
                        end
                    end
                end
            end
        end
    end
end)

-- Button handlers
UI.AutoBtn.MouseButton1Click:Connect(function()
    if not canRunMain() then return end
    if safePlatform then
        notify("Cannot enable Auto Kill while in Safe Zone!", 2)
        return
    end
    autoOn = not autoOn
    Config.AutoOn = autoOn
    SaveConfig()
    applyLang()
    if autoOn then
        autoSelectedOn = false
        multiOn = false
        Config.AutoSelectedOn = false
        Config.MultiOn = false
        SaveConfig()
        applyLang()
        notify("Auto Kill Random enabled ["..positionMode.."]. Selecting target...", 2)
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
    if not canRunMain() then return end
    if safePlatform then
        notify("Cannot enable Auto Kill while in Safe Zone!", 2)
        return
    end
    if #selectedTargets == 1 then
        autoSelectedOn = not autoSelectedOn
        Config.AutoSelectedOn = autoSelectedOn
        SaveConfig()
        applyLang()
        if autoSelectedOn then
            autoOn = false
            multiOn = false
            Config.AutoOn = false
            Config.MultiOn = false
            SaveConfig()
            applyLang()
            currentTarget = selectedTargets[1]
            notify("Auto Kill Single enabled ["..positionMode.."]. Target: "..currentTarget.Name, 2)
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
UI.MultiSelectedBtn.MouseButton1Click:Connect(function()
    if not canRunMain() then return end
    if safePlatform then
        notify("Cannot enable Auto Kill while in Safe Zone!", 2)
        return
    end
    if #selectedTargets >= 2 then
        multiOn = not multiOn
        Config.MultiOn = multiOn
        SaveConfig()
        applyLang()
        if multiOn then
            autoOn = false
            autoSelectedOn = false
            Config.AutoOn = false
            Config.AutoSelectedOn = false
            SaveConfig()
            applyLang()
            currentMultiIndex = 1
            lastTargetCheck = 0
            currentTarget = selectedTargets[1]
            notify("Multi Kill enabled ["..positionMode.."]. Sequential mode ("..#selectedTargets.." targets)", 2.5)
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
    if not canRunMain() then return end
    local currentTargetName = currentTarget and currentTarget.Name or nil
    local players = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and
            not isBlacklisted(player) and
            player.Character and
            player.Character:FindFirstChild("Humanoid") and
            player.Character:FindFirstChild("Humanoid").Health > 0 and
            player.Name ~= currentTargetName then
            table.insert(players, player)
        end
    end
    if #players > 0 then
        currentTarget = players[math.random(1, #players)]
        notify("Changed target to: "..currentTarget.Name.." ["..positionMode.."]", 2)
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
UI.BlacklistBtn.MouseButton1Click:Connect(function()
    if not canRunMain() then return end
    UI.BlacklistFrame.Visible = not UI.BlacklistFrame.Visible
    if UI.BlacklistFrame.Visible then
        refreshBlacklistList()
        notify("Blacklist Manager opened", 1.5)
    end
end)
blacklistCloseBtn.MouseButton1Click:Connect(function()
    UI.BlacklistFrame.Visible = false
end)
UI.PositionModeBtn.MouseButton1Click:Connect(function()
    if not canRunMain() then return end
    if positionMode == "Behind" then
        positionMode = "Under"
    elseif positionMode == "Under" then
        positionMode = "Circle"
    else
        positionMode = "Behind"
    end
    Config.PositionMode = positionMode
    SaveConfig()
    applyLang()
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
UI.SpeedBoostBtn.MouseButton1Click:Connect(function()
    if not canRunMain() then return end
    speedBoostOn = not speedBoostOn
    Config.SpeedBoostOn = speedBoostOn
    SaveConfig()
    applyLang()
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
UI.PredictBtn.MouseButton1Click:Connect(function()
    if not canRunMain() then return end
    predictOn = not predictOn
    Config.PredictOn = predictOn
    SaveConfig()
    applyLang()
    if predictOn then
        notify("Direction Prediction enabled (Beta)", 2)
    else
        notify("Direction Prediction disabled", 1.5)
    end
end)
UI.ServerHopBtn.MouseButton1Click:Connect(function()
    if not canRunMain() then return end
    serverHopOn = not serverHopOn
    Config.ServerHopOn = serverHopOn
    SaveConfig()
    applyLang()
    if serverHopOn then
        notify("Auto Server Hop enabled (min 5 players)", 2)
    else
        notify("Auto Server Hop disabled", 1.5)
    end
end)
UI.SafeZoneBtn.MouseButton1Click:Connect(function()
    if not canRunMain() then return end
    safeZoneOn = not safeZoneOn
    Config.SafeZoneOn = safeZoneOn
    SaveConfig()
    applyLang()
    if safeZoneOn then
        notify("Auto Safe Zone enabled", 2)
        createSafeZoneGui()
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid and (humanoid.Health / humanoid.MaxHealth) < 0.35 then
                createSafePlatform(false)
            end
        end
    else
        notify("Auto Safe Zone disabled", 1.5)
        destroySafeZoneGui()
        if safePlatform then
            removeSafePlatform()
        end
    end
end)
UI.VoidCheckBtn.MouseButton1Click:Connect(function()
    if not canRunMain() then return end
    voidCheckOn = not voidCheckOn
    Config.VoidCheckOn = voidCheckOn
    SaveConfig()
    applyLang()
    if voidCheckOn then
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        lastVoidSafeCFrame = hrp and hrp.CFrame or lastVoidSafeCFrame
        notify("Void Check enabled", 1.5)
    else
        notify("Void Check disabled", 1.5)
    end
end)
UI.RefreshBtn.MouseButton1Click:Connect(function()
    if not canRunMain() then return end
    refreshPlayerList()
    notify("Player list refreshed", 1.5)
end)
UI.AutoRefreshToggle.MouseButton1Click:Connect(function()
    if not canRunMain() then return end
    autoRefreshOn = not autoRefreshOn
    Config.AutoRefreshOn = autoRefreshOn
    SaveConfig()
    applyLang()
    if autoRefreshOn then
        notify("Auto Refresh enabled", 1.5)
        refreshPlayerList()
    else
        notify("Auto Refresh disabled", 1.5)
    end
end)

Players.PlayerRemoving:Connect(function(p)
    if not canRunMain() then return end
    voidDangerTargets[p] = nil
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
        notify("Target " .. p.Name .. " left. Removed from list (" .. #selectedTargets .. " left)", 2)
        updateSelectedBtnsText()
        if multiOn then
            if removedIndex < currentMultiIndex then
                currentMultiIndex = currentMultiIndex - 1
            elseif removedIndex == currentMultiIndex then
                currentMultiIndex = (#selectedTargets > 0) and (math.fmod(currentMultiIndex - 1, #selectedTargets) + 1) or 1
            end
            if currentMultiIndex > #selectedTargets then currentMultiIndex = 1 end
            lastTargetCheck = 0
            if #selectedTargets >= 2 then
                local tempTarget = selectedTargets[currentMultiIndex]
                local isTempValid = tempTarget and tempTarget.Character and tempTarget.Character:FindFirstChild("Humanoid") and tempTarget.Character.Humanoid.Health > 0 and not isBlacklisted(tempTarget)
                if isTempValid then
                    currentTarget = tempTarget
                    makeHighlight(currentTarget, currentMultiIndex)
                    notify("Multi: Next target after player left.", 1.5)
                end
            else
                multiOn = false
                Config.MultiOn = false
                SaveConfig()
                applyLang()
                notify("Multi mode disabled - Less than 2 targets left.", 2)
                clearHighlight()
                currentTarget = nil
                currentMultiIndex = 1
            end
        end
        if autoSelectedOn and #selectedTargets ~= 1 then
            autoSelectedOn = false
            Config.AutoSelectedOn = false
            SaveConfig()
            applyLang()
            notify("Single mode disabled - Select exactly 1 target.", 2)
        end
    end
    if playerButtons[p] then
        playerButtons[p]:Destroy()
        playerButtons[p] = nil
    end
    if blacklistButtons[p] then
        blacklistButtons[p]:Destroy()
        blacklistButtons[p] = nil
    end
    if autoOn then
        spawn(function()
            wait(1)
            currentTarget = chooseWeakest()
            if currentTarget then
                notify("New target: "..currentTarget.Name.." ["..positionMode.."]", 2)
                makeHighlight(currentTarget)
            end
        end)
    end
    refreshPlayerList()
end)

Players.PlayerAdded:Connect(function(p)
    voidDangerTargets[p] = nil
    wait(2)
    if canRunMain() then
        refreshPlayerList()
        if UI.BlacklistFrame.Visible then
            refreshBlacklistList()
        end
    end
    if p.Name == COMPLIMENT_TARGET then
        checkComplimentTarget()
    end
end)

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
        TweenService:Create(UI.Glow, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.95}):Play()
        wait(1.2)
    end
end)

checkComplimentTarget()
if mainReady then
    startMain()
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if not canRunMain() then return end
    if input.KeyCode == Enum.KeyCode.F8 then
        hopServer()
    elseif input.KeyCode == Enum.KeyCode.F9 then
        safeZoneOn = not safeZoneOn
        Config.SafeZoneOn = safeZoneOn
        SaveConfig()
        applyLang()
        if safeZoneOn then
            createSafeZoneGui()
            createSafePlatform(false)
            notify("Emergency Safe Zone Activated!", 2)
        else
            destroySafeZoneGui()
            removeSafePlatform()
            notify("Safe Zone Deactivated", 2)
        end
    end
end)

getgenv().LuexHopServer = hopServer
getgenv().LuexToggleAuto = function()
    UI.AutoBtn.MouseButton1Click()
end
getgenv().LuexToggleMulti = function()
    UI.MultiSelectedBtn.MouseButton1Click()
end
getgenv().LuexGetTarget = function()
    return currentTarget and currentTarget.Name or "No target"
end
getgenv().LuexSelectTarget = function(playerName)
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name == playerName and player ~= LocalPlayer then
            if isBlacklisted(player) then
                notify("Player is blacklisted!", 2)
                return false
            end
            if not isSelected(player) then
                toggleSelect(player)
                return true
            else
                notify("Player already selected", 2)
                return true
            end
        end
    end
    notify("Player not found", 2)
    return false
end

game:BindToClose(function()
    SaveConfig()
    notify("Config saved. Goodbye!", 1)
    wait(0.5)
end)

print("Luex ULTRA v3.2: Blacklist Protection + Sequential Multi loaded - Cực xịn cực mạnh xịn sò 😈💥")
notify("Luex ULTRA v3.2 Loaded! Protected user: " .. PROTECTED_USER .. " | Blacklist enabled!", 4)

spawn(function()
    wait(3)
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name == PROTECTED_USER then
            notify("🛡️ PROTECTED USER DETECTED: " .. PROTECTED_USER .. " (Auto-protected)", 3)
            break
        end
    end
end)
