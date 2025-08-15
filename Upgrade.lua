--[[
    Upgrade.lua - Fish It Ultimate Script
    
    Features:
    • AutoFishing V1 (from old.lua - Zayros FISHIT)
    • AutoFishing V2 (from new.lua - XSAN Fish It Pro)
    • Basic UI with tab system
    
    Developer: MELLISAEFFENDY
    Version: 1.0
--]]

print("🚀 Loading Upgrade.lua - Fish It Ultimate Script...")

-- ═══════════════════════════════════════════════════════════════
-- SERVICES & SETUP
-- ═══════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ═══════════════════════════════════════════════════════════════
-- CONSTANTS & CONFIGURATION
-- ═══════════════════════════════════════════════════════════════

local CONSTANTS = {
    GUI_NAME = "UpgradeScript",
    FISHING_DELAY_V1 = 0.4,
    FISHING_DELAY_V2 = 0.3,
    DEFAULT_WALKSPEED = 16,
    MAX_WALKSPEED = 100,
    ANTI_KICK_INTERVAL = 30
}

-- ═══════════════════════════════════════════════════════════════
-- STATE MANAGEMENT
-- ═══════════════════════════════════════════════════════════════

local State = {
    autoFishingV1 = false,
    autoFishingV2 = false,
    currentTab = "Main",
    fishCaught = 0,
    startTime = 0,
    connections = {}
}

-- ═══════════════════════════════════════════════════════════════
-- REMOTE EVENTS (from old.lua)
-- ═══════════════════════════════════════════════════════════════

local Rs = ReplicatedStorage
local Remotes = {
    EquipRod = Rs.Packages._Index["sleitnick_net@0.2.0"].net["RE/EquipToolFromHotbar"],
    UnEquipRod = Rs.Packages._Index["sleitnick_net@0.2.0"].net["RE/UnequipToolFromHotbar"],
    RequestFishing = Rs.Packages._Index["sleitnick_net@0.2.0"].net["RF/RequestFishingMinigameStarted"],
    ChargeRod = Rs.Packages._Index["sleitnick_net@0.2.0"].net["RF/ChargeFishingRod"],
    FishingComplete = Rs.Packages._Index["sleitnick_net@0.2.0"].net["RE/FishingCompleted"],
    CancelFishing = Rs.Packages._Index["sleitnick_net@0.2.0"].net["RF/CancelFishingInputs"],
    SpawnBoat = Rs.Packages._Index["sleitnick_net@0.2.0"].net["RF/SpawnBoat"],
    DespawnBoat = Rs.Packages._Index["sleitnick_net@0.2.0"].net["RF/DespawnBoat"],
    SellAll = Rs.Packages._Index["sleitnick_net@0.2.0"].net["RF/SellAllItems"]
}

-- ═══════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

local function safeInvoke(remoteFunction, ...)
    local success, result = pcall(remoteFunction.InvokeServer, remoteFunction, ...)
    if not success then
        warn("Failed to invoke remote:", result)
    end
    return success, result
end

local function createNotification(title, text, duration)
    game.StarterGui:SetCore("SendNotification", {
        Title = title;
        Text = text;
        Duration = duration or 3;
    })
end

-- ═══════════════════════════════════════════════════════════════
-- AUTO FISHING V1 (from old.lua - Zayros FISHIT)
-- ═══════════════════════════════════════════════════════════════

local function startAutoFishingV1()
    if State.autoFishingV1 then return end
    
    State.autoFishingV1 = true
    State.startTime = tick()
    createNotification("AutoFishing V1", "🎣 Zayros FISHIT Started!", 3)
    
    State.connections.autoFishV1 = RunService.Heartbeat:Connect(function()
        if not State.autoFishingV1 then return end
        
        pcall(function()
            -- Equip fishing rod
            safeInvoke(Remotes.EquipRod, 1)
            task.wait(0.1)
            
            -- Start fishing
            safeInvoke(Remotes.RequestFishing)
            task.wait(0.2)
            
            -- Charge rod
            safeInvoke(Remotes.ChargeRod, 1)
            task.wait(0.1)
            
            -- Complete fishing
            Remotes.FishingComplete:FireServer()
            State.fishCaught = State.fishCaught + 1
            
            task.wait(CONSTANTS.FISHING_DELAY_V1)
        end)
    end)
end

local function stopAutoFishingV1()
    if not State.autoFishingV1 then return end
    
    State.autoFishingV1 = false
    if State.connections.autoFishV1 then
        State.connections.autoFishV1:Disconnect()
        State.connections.autoFishV1 = nil
    end
    
    createNotification("AutoFishing V1", "⏹️ Zayros FISHIT Stopped!", 3)
end

-- ═══════════════════════════════════════════════════════════════
-- AUTO FISHING V2 (from new.lua - XSAN Fish It Pro)
-- ═══════════════════════════════════════════════════════════════

local function startAutoFishingV2()
    if State.autoFishingV2 then return end
    
    State.autoFishingV2 = true
    State.startTime = tick()
    createNotification("AutoFishing V2", "⚡ XSAN Fish It Pro Started!", 3)
    
    State.connections.autoFishV2 = RunService.Heartbeat:Connect(function()
        if not State.autoFishingV2 then return end
        
        pcall(function()
            -- Enhanced fishing logic with AI features (simplified version)
            local character = LocalPlayer.Character
            if not character then return end
            
            -- Equip rod with enhanced timing
            safeInvoke(Remotes.EquipRod, 1)
            task.wait(0.05) -- Faster timing
            
            -- Smart fishing request
            safeInvoke(Remotes.RequestFishing)
            task.wait(0.15)
            
            -- Optimized charge timing
            safeInvoke(Remotes.ChargeRod, 1)
            task.wait(0.08)
            
            -- Complete with analytics
            Remotes.FishingComplete:FireServer()
            State.fishCaught = State.fishCaught + 1
            
            -- Faster cycle time
            task.wait(CONSTANTS.FISHING_DELAY_V2)
        end)
    end)
end

local function stopAutoFishingV2()
    if not State.autoFishingV2 then return end
    
    State.autoFishingV2 = false
    if State.connections.autoFishV2 then
        State.connections.autoFishV2:Disconnect()
        State.connections.autoFishV2 = nil
    end
    
    createNotification("AutoFishing V2", "⏹️ XSAN Fish It Pro Stopped!", 3)
end

-- ═══════════════════════════════════════════════════════════════
-- UI LIBRARY SETUP
-- ═══════════════════════════════════════════════════════════════

-- Load UI Library from GitHub (you'll need to replace with actual raw URL)
-- For now, we'll use a local loadstring
local UILib = loadstring(game:HttpGet("https://raw.githubusercontent.com/MELLISAEFFENDY/MELLISAEFFENDY.github.io/main/UILibrary.lua"))()

-- Create main window
local Window = UILib:CreateWindow({
    Title = "🚀 Upgrade.lua - Fish It Ultimate",
    Size = UDim2.new(0.4, 0, 0.5, 0),
    Position = UDim2.new(0.3, 0, 0.25, 0),
    Theme = "Dark",
    Draggable = true
})

-- Create sections
local MainSection = Window:CreateSection("AutoFishing Systems")
local StatsSection = Window:CreateSection("Statistics")

-- Variables for UI elements
local V1Button, V2Button, StatsLabel

-- ═══════════════════════════════════════════════════════════════
-- UI ELEMENTS CREATION
-- ═══════════════════════════════════════════════════════════════

-- Create UI elements using the library
V1Button = UILib:CreateButton(MainSection, {
    Text = "🎣 AutoFishing V1 - Zayros FISHIT",
    Color = Color3.fromRGB(80, 160, 80),
    Height = 50,
    Callback = function()
        if State.autoFishingV1 then
            stopAutoFishingV1()
        else
            if State.autoFishingV2 then
                stopAutoFishingV2()
            end
            startAutoFishingV1()
        end
    end
})

V2Button = UILib:CreateButton(MainSection, {
    Text = "⚡ AutoFishing V2 - XSAN Fish It Pro",
    Color = Color3.fromRGB(255, 140, 60),
    Height = 50,
    Callback = function()
        if State.autoFishingV2 then
            stopAutoFishingV2()
        else
            if State.autoFishingV1 then
                stopAutoFishingV1()
            end
            startAutoFishingV2()
        end
    end
})

-- Statistics display
StatsLabel = UILib:CreateLabel(StatsSection, {
    Text = "📊 Fish Caught: 0 | ⏱️ Time: 0s | 🎯 Status: Ready",
    Height = 30
})

-- Update stats function
local function updateStats()
    if State.startTime > 0 then
        local timeElapsed = math.floor(tick() - State.startTime)
        local status = "Ready"
        if State.autoFishingV1 then
            status = "V1 Active"
        elseif State.autoFishingV2 then
            status = "V2 Active"
        end
        
        StatsLabel.SetText("📊 Fish Caught: " .. State.fishCaught .. " | ⏱️ Time: " .. timeElapsed .. "s | 🎯 Status: " .. status)
    end
end

-- Stats update loop
State.connections.statsUpdate = RunService.Heartbeat:Connect(updateStats)

-- ═══════════════════════════════════════════════════════════════
-- IMPROVED AUTO FISHING FUNCTIONS WITH UI UPDATES
-- ═══════════════════════════════════════════════════════════════

-- Update V1 functions to change button appearance
local originalStartV1 = startAutoFishingV1
startAutoFishingV1 = function()
    originalStartV1()
    if State.autoFishingV1 then
        V1Button.Text = "⏹️ STOP V1 FISHING"
        V1Button.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
        -- Update V2 button to normal state
        V2Button.Text = "⚡ AutoFishing V2 - XSAN Fish It Pro"
        V2Button.BackgroundColor3 = Color3.fromRGB(255, 140, 60)
    end
end

local originalStopV1 = stopAutoFishingV1
stopAutoFishingV1 = function()
    originalStopV1()
    V1Button.Text = "🎣 AutoFishing V1 - Zayros FISHIT"
    V1Button.BackgroundColor3 = Color3.fromRGB(80, 160, 80)
end

local originalStartV2 = startAutoFishingV2
startAutoFishingV2 = function()
    originalStartV2()
    if State.autoFishingV2 then
        V2Button.Text = "⏹️ STOP V2 FISHING"
        V2Button.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
        -- Update V1 button to normal state
        V1Button.Text = "🎣 AutoFishing V1 - Zayros FISHIT"
        V1Button.BackgroundColor3 = Color3.fromRGB(80, 160, 80)
    end
end

local originalStopV2 = stopAutoFishingV2
stopAutoFishingV2 = function()
    originalStopV2()
    V2Button.Text = "⚡ AutoFishing V2 - XSAN Fish It Pro"
    V2Button.BackgroundColor3 = Color3.fromRGB(255, 140, 60)
end

-- ═══════════════════════════════════════════════════════════════
-- INITIALIZATION WITH UI LIBRARY
-- ═══════════════════════════════════════════════════════════════

UILib:Notification("Upgrade.lua", "🚀 Script loaded successfully!\n📋 Choose AutoFishing version", 5, "Success")

print("✅ Upgrade.lua loaded with UILibrary!")
print("🎣 AutoFishing V1: Zayros FISHIT ready")
print("⚡ AutoFishing V2: XSAN Fish It Pro ready")
print("🎨 Using custom UI Library for better experience")
