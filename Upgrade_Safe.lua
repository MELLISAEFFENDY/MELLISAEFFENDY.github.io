--[[
    Upgrade.lua - Fish It Ultimate Script (DELTA SAFE VERSION)
    
    Features:
    • AutoFishing V1 (Simple & Safe)
    • AutoFishing V2 (Enhanced & Safe)
    • Delta Executor optimized
    • No crash protection
    
    Developer: MELLISAEFFENDY
    Version: 1.1 (Delta Safe)
--]]

print("🚀 Loading Upgrade.lua - Delta Safe Version...")

-- ═══════════════════════════════════════════════════════════════
-- SERVICES & SETUP
-- ═══════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ═══════════════════════════════════════════════════════════════
-- CONSTANTS & CONFIGURATION
-- ═══════════════════════════════════════════════════════════════

local CONSTANTS = {
    GUI_NAME = "UpgradeScriptSafe",
    FISHING_DELAY_V1 = 1, -- Slower for safety
    FISHING_DELAY_V2 = 0.8, -- Still faster but safe
    DEFAULT_WALKSPEED = 16
}

-- ═══════════════════════════════════════════════════════════════
-- STATE MANAGEMENT
-- ═══════════════════════════════════════════════════════════════

local State = {
    autoFishingV1 = false,
    autoFishingV2 = false,
    fishCaught = 0,
    startTime = 0,
    connections = {}
}

-- ═══════════════════════════════════════════════════════════════
-- REMOTE EVENTS SETUP
-- ═══════════════════════════════════════════════════════════════

local Rs = ReplicatedStorage
local Remotes = {}

-- Safe remote finding
local function findRemote(path)
    local success, remote = pcall(function()
        return Rs.Packages._Index["sleitnick_net@0.2.0"].net[path]
    end)
    return success and remote or nil
end

Remotes.EquipRod = findRemote("RE/EquipToolFromHotbar")
Remotes.RequestFishing = findRemote("RF/RequestFishingMinigameStarted")
Remotes.ChargeRod = findRemote("RF/ChargeFishingRod")
Remotes.FishingComplete = findRemote("RE/FishingCompleted")

-- ═══════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

local function createNotification(title, text, duration)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = text;
            Duration = duration or 3;
        })
    end)
    print("📢 " .. title .. ": " .. text)
end

local function safeRemoteCall(remote, ...)
    if not remote then 
        warn("❌ Remote not found!")
        return false 
    end
    
    local success, result = pcall(function()
        if remote.ClassName == "RemoteFunction" then
            return remote:InvokeServer(...)
        else
            remote:FireServer(...)
            return true
        end
    end)
    
    if not success then
        warn("❌ Remote call failed:", result)
        return false
    end
    
    return true
end

-- ═══════════════════════════════════════════════════════════════
-- SIMPLE AUTO FISHING V1
-- ═══════════════════════════════════════════════════════════════

local fishingThreadV1

local function startAutoFishingV1()
    if State.autoFishingV1 then return end
    
    State.autoFishingV1 = true
    State.startTime = tick()
    createNotification("AutoFishing V1", "🎣 Starting Simple Fishing...", 3)
    
    fishingThreadV1 = coroutine.create(function()
        while State.autoFishingV1 do
            pcall(function()
                -- Simple fishing sequence
                if safeRemoteCall(Remotes.EquipRod, 1) then
                    wait(0.3)
                    
                    if safeRemoteCall(Remotes.ChargeRod, workspace:GetServerTimeNow()) then
                        wait(0.2)
                        
                        if safeRemoteCall(Remotes.RequestFishing, -1.2379989624023438, 0.9800224985802423) then
                            wait(0.3)
                            
                            if safeRemoteCall(Remotes.FishingComplete) then
                                State.fishCaught = State.fishCaught + 1
                                print("🎣 V1 Fish caught! Total:", State.fishCaught)
                            end
                        end
                    end
                end
            end)
            
            wait(CONSTANTS.FISHING_DELAY_V1) -- Safe delay
        end
    end)
    
    coroutine.resume(fishingThreadV1)
end

local function stopAutoFishingV1()
    State.autoFishingV1 = false
    if fishingThreadV1 then
        fishingThreadV1 = nil
    end
    createNotification("AutoFishing V1", "⏹️ Simple Fishing Stopped!", 3)
end

-- ═══════════════════════════════════════════════════════════════
-- ENHANCED AUTO FISHING V2
-- ═══════════════════════════════════════════════════════════════

local fishingThreadV2

local function startAutoFishingV2()
    if State.autoFishingV2 then return end
    
    State.autoFishingV2 = true
    State.startTime = tick()
    createNotification("AutoFishing V2", "⚡ Starting Enhanced Fishing...", 3)
    
    fishingThreadV2 = coroutine.create(function()
        while State.autoFishingV2 do
            pcall(function()
                -- Enhanced fishing sequence
                if safeRemoteCall(Remotes.EquipRod, 1) then
                    wait(0.25)
                    
                    if safeRemoteCall(Remotes.ChargeRod, workspace:GetServerTimeNow()) then
                        wait(0.15)
                        
                        if safeRemoteCall(Remotes.RequestFishing, -1.2379989624023438, 0.9800224985802423) then
                            wait(0.25)
                            
                            if safeRemoteCall(Remotes.FishingComplete) then
                                State.fishCaught = State.fishCaught + 1
                                print("⚡ V2 Fish caught! Total:", State.fishCaught)
                            end
                        end
                    end
                end
                
                -- Random human pause
                if math.random(1, 25) == 1 then
                    wait(math.random() * 1.5 + 0.5)
                end
            end)
            
            wait(CONSTANTS.FISHING_DELAY_V2) -- Faster but safe
        end
    end)
    
    coroutine.resume(fishingThreadV2)
end

local function stopAutoFishingV2()
    State.autoFishingV2 = false
    if fishingThreadV2 then
        fishingThreadV2 = nil
    end
    createNotification("AutoFishing V2", "⏹️ Enhanced Fishing Stopped!", 3)
end

-- ═══════════════════════════════════════════════════════════════
-- SIMPLE UI SYSTEM
-- ═══════════════════════════════════════════════════════════════

-- Cleanup existing GUI
if PlayerGui:FindFirstChild(CONSTANTS.GUI_NAME) then
    PlayerGui[CONSTANTS.GUI_NAME]:Destroy()
end

-- Create main GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = CONSTANTS.GUI_NAME
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.35, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0.3, 0, 0.4, 0)
MainFrame.Active = true
MainFrame.Draggable = true

-- Add corner radius
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 0, 0, 0)
Title.Size = UDim2.new(1, 0, 0.2, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "🚀 Upgrade.lua - Delta Safe"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true

-- V1 Button
local V1Button = Instance.new("TextButton")
V1Button.Name = "V1Button"
V1Button.Parent = MainFrame
V1Button.BackgroundColor3 = Color3.fromRGB(80, 160, 80)
V1Button.BorderSizePixel = 0
V1Button.Position = UDim2.new(0.05, 0, 0.25, 0)
V1Button.Size = UDim2.new(0.9, 0, 0.25, 0)
V1Button.Font = Enum.Font.GothamBold
V1Button.Text = "🎣 AutoFishing V1 - Simple"
V1Button.TextColor3 = Color3.fromRGB(255, 255, 255)
V1Button.TextScaled = true

local V1Corner = Instance.new("UICorner")
V1Corner.CornerRadius = UDim.new(0, 8)
V1Corner.Parent = V1Button

-- V2 Button
local V2Button = Instance.new("TextButton")
V2Button.Name = "V2Button"
V2Button.Parent = MainFrame
V2Button.BackgroundColor3 = Color3.fromRGB(255, 140, 60)
V2Button.BorderSizePixel = 0
V2Button.Position = UDim2.new(0.05, 0, 0.55, 0)
V2Button.Size = UDim2.new(0.9, 0, 0.25, 0)
V2Button.Font = Enum.Font.GothamBold
V2Button.Text = "⚡ AutoFishing V2 - Enhanced"
V2Button.TextColor3 = Color3.fromRGB(255, 255, 255)
V2Button.TextScaled = true

local V2Corner = Instance.new("UICorner")
V2Corner.CornerRadius = UDim.new(0, 8)
V2Corner.Parent = V2Button

-- Stats Label
local StatsLabel = Instance.new("TextLabel")
StatsLabel.Name = "StatsLabel"
StatsLabel.Parent = MainFrame
StatsLabel.BackgroundTransparency = 1
StatsLabel.Position = UDim2.new(0.05, 0, 0.85, 0)
StatsLabel.Size = UDim2.new(0.9, 0, 0.1, 0)
StatsLabel.Font = Enum.Font.Gotham
StatsLabel.Text = "📊 Fish: 0 | Status: Ready"
StatsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatsLabel.TextScaled = true

-- ═══════════════════════════════════════════════════════════════
-- EVENT CONNECTIONS
-- ═══════════════════════════════════════════════════════════════

-- V1 Button Click
V1Button.MouseButton1Click:Connect(function()
    if State.autoFishingV1 then
        stopAutoFishingV1()
        V1Button.Text = "🎣 AutoFishing V1 - Simple"
        V1Button.BackgroundColor3 = Color3.fromRGB(80, 160, 80)
    else
        -- Stop V2 if running
        if State.autoFishingV2 then
            stopAutoFishingV2()
            V2Button.Text = "⚡ AutoFishing V2 - Enhanced"
            V2Button.BackgroundColor3 = Color3.fromRGB(255, 140, 60)
        end
        
        startAutoFishingV1()
        V1Button.Text = "⏹️ STOP V1"
        V1Button.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
    end
end)

-- V2 Button Click
V2Button.MouseButton1Click:Connect(function()
    if State.autoFishingV2 then
        stopAutoFishingV2()
        V2Button.Text = "⚡ AutoFishing V2 - Enhanced"
        V2Button.BackgroundColor3 = Color3.fromRGB(255, 140, 60)
    else
        -- Stop V1 if running
        if State.autoFishingV1 then
            stopAutoFishingV1()
            V1Button.Text = "🎣 AutoFishing V1 - Simple"
            V1Button.BackgroundColor3 = Color3.fromRGB(80, 160, 80)
        end
        
        startAutoFishingV2()
        V2Button.Text = "⏹️ STOP V2"
        V2Button.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
    end
end)

-- Stats Update
spawn(function()
    while ScreenGui and ScreenGui.Parent do
        if State.startTime > 0 then
            local timeElapsed = math.floor(tick() - State.startTime)
            local status = "Ready"
            if State.autoFishingV1 then
                status = "V1 Active"
            elseif State.autoFishingV2 then
                status = "V2 Active"
            end
            
            StatsLabel.Text = "📊 Fish: " .. State.fishCaught .. " | Time: " .. timeElapsed .. "s | " .. status
        end
        wait(1)
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- INITIALIZATION
-- ═══════════════════════════════════════════════════════════════

-- Check remotes
local function checkRemotes()
    print("🔍 Checking Remote Events:")
    for name, remote in pairs(Remotes) do
        if remote then
            print("✅ " .. name .. ": Found")
        else
            warn("❌ " .. name .. ": Missing!")
        end
    end
end

checkRemotes()

createNotification("Upgrade.lua", "🚀 Delta Safe Version Loaded!\n📋 Choose AutoFishing version", 5)

print("✅ Upgrade.lua (Delta Safe) loaded!")
print("🎣 AutoFishing V1: Simple & Safe")
print("⚡ AutoFishing V2: Enhanced & Safe")
print("📱 Delta Executor: OPTIMIZED")
print("🛡️ Crash protection: ENABLED")
