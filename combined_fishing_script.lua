--[[
    Combined Fish It Pro - Ultimate Edition
    
    Menggabungkan fitur terbaik dari old.lua dan new.lua:
    
    Dari old.lua (Zayros FISHIT):
    • Security system yang canggih (anti-detection)
    • Sistem fishing yang stabil dengan random delays
    • Anti-kick system dan human simulation
    • State management yang baik
    
    Dari new.lua (XSAN Fish It Pro):
    • UI yang modern dan responsif (Rayfield)
    • Mobile optimization
    • Advanced notification system
    • Quick start presets
    • Better configuration management
    
    @author: Combined by Assistant
    @version: 1.0 (Hybrid)
--]]

print("🔥 Loading Combined Fish It Pro Ultimate...")

-- ═══════════════════════════════════════════════════════════════
-- SERVICES & CORE SETUP
-- ═══════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ═══════════════════════════════════════════════════════════════
-- CONSTANTS & CONFIGURATION
-- ═══════════════════════════════════════════════════════════════

local CONSTANTS = {
    -- From old.lua - Security focused
    FISHING_DELAY = 0.4,
    DEFAULT_WALKSPEED = 16,
    MAX_WALKSPEED = 100,
    ANTI_KICK_INTERVAL = 30,
    AUTO_SELL_THRESHOLD = 0.8,
    
    -- Security Constants (from old.lua)
    MIN_FISHING_DELAY = 0.3,
    MAX_FISHING_DELAY = 0.8,
    MIN_ANTI_KICK_INTERVAL = 25,
    MAX_ANTI_KICK_INTERVAL = 45,
    MAX_ACTIONS_PER_MINUTE = 120,
    DETECTION_COOLDOWN = 5,
    
    -- UI Constants (from new.lua)
    GUI_NAME = "CombinedFishItPro",
    BUTTON_COOLDOWN = 0.5
}

local CONFIG = {
    branding = {
        title = "Combined Fish It Pro Ultimate v1.0",
        subtitle = "Best features from Zayros FISHIT + XSAN Fish It Pro",
        developer = "Combined Script",
        support_message = "Combining the best of both worlds!"
    },
    
    -- Quick start presets (from new.lua)
    presets = {
        Beginner = {purpose = "safe and easy fishing", autosell = 5, delay = 0.6},
        Speed = {purpose = "maximum fishing speed", autosell = 20, delay = 0.4},
        Ultra = {purpose = "maximum earnings", autosell = 15, delay = 0.5},
        AFK = {purpose = "long AFK sessions", autosell = 25, delay = 0.7},
        Safe = {purpose = "ultra secure fishing", autosell = 18, delay = 0.8},
        Hybrid = {purpose = "balanced performance + security", autosell = 20, delay = 0.5}
    }
}

-- ═══════════════════════════════════════════════════════════════
-- STATE MANAGEMENT (from old.lua - improved)
-- ═══════════════════════════════════════════════════════════════

local State = {
    -- Core states
    autoFishing = false,
    noOxygen = false,
    currentPage = "Main",
    walkSpeed = CONSTANTS.DEFAULT_WALKSPEED,
    isMinimized = false,
    
    -- Advanced features
    antiKick = false,
    autoSell = false,
    smartLocation = false,
    currentPreset = "None",
    
    -- Statistics
    fishCaught = 0,
    startTime = 0,
    totalProfit = 0,
    lastAntiKickTime = 0,
    
    -- Security features (from old.lua)
    lastActionTime = 0,
    actionsThisMinute = 0,
    lastMinuteReset = 0,
    suspicionLevel = 0,
    isInCooldown = false,
    randomSeed = math.random(1000, 9999)
}

-- ═══════════════════════════════════════════════════════════════
-- REMOTE EVENTS SETUP (from old.lua)
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
-- SECURITY FUNCTIONS (from old.lua - enhanced)
-- ═══════════════════════════════════════════════════════════════

local function getRandomDelay(min, max)
    math.randomseed(tick() + State.randomSeed)
    return min + (math.random() * (max - min))
end

local function isActionSafe()
    local currentTime = tick()
    
    -- Reset actions counter every minute
    if currentTime - State.lastMinuteReset > 60 then
        State.actionsThisMinute = 0
        State.lastMinuteReset = currentTime
    end
    
    -- Check if we're exceeding action limit
    if State.actionsThisMinute >= CONSTANTS.MAX_ACTIONS_PER_MINUTE then
        State.isInCooldown = true
        return false
    end
    
    -- Check minimum delay between actions
    if currentTime - State.lastActionTime < 0.1 then
        return false
    end
    
    return true
end

local function incrementSuspicion(amount)
    State.suspicionLevel = State.suspicionLevel + (amount or 1)
    if State.suspicionLevel > 10 then
        State.isInCooldown = true
        task.wait(CONSTANTS.DETECTION_COOLDOWN)
        State.suspicionLevel = 0
        State.isInCooldown = false
    end
end

local function safeInvokeWithSecurity(remoteFunction, ...)
    if not isActionSafe() or State.isInCooldown then
        return false, "Action blocked for security"
    end
    
    local currentTime = tick()
    State.lastActionTime = currentTime
    State.actionsThisMinute = State.actionsThisMinute + 1
    
    -- Add random micro-delay to humanize
    local microDelay = getRandomDelay(0.01, 0.05)
    task.wait(microDelay)
    
    local success, result = pcall(remoteFunction.InvokeServer, remoteFunction, ...)
    if not success then
        incrementSuspicion(2)
        warn("Failed to invoke remote:", result)
    end
    return success, result
end

-- Human simulation (from old.lua)
local function simulateHumanInput()
    if not LocalPlayer.Character then return end
    
    local camera = Workspace.CurrentCamera
    if camera then
        local randomX = getRandomDelay(-0.1, 0.1)
        local randomY = getRandomDelay(-0.05, 0.05)
        
        pcall(function()
            camera.CFrame = camera.CFrame * CFrame.Angles(math.rad(randomY), math.rad(randomX), 0)
        end)
    end
end

-- ═══════════════════════════════════════════════════════════════
-- NOTIFICATION SYSTEM (from new.lua - enhanced)
-- ═══════════════════════════════════════════════════════════════

local function Notify(title, text, duration)
    duration = duration or 3
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Combined Fish It Pro",
            Text = text or "Notification", 
            Duration = duration,
            Icon = "rbxassetid://6023426923"
        })
    end)
    print("🔔", title, "-", text)
end

local function NotifySuccess(title, message)
    Notify("✅ " .. title, message, 3)
end

local function NotifyError(title, message)
    Notify("❌ " .. title, message, 4)
end

local function NotifyInfo(title, message)
    Notify("ℹ️ " .. title, message, 3)
end

-- ═══════════════════════════════════════════════════════════════
-- UI LIBRARY LOADING (from new.lua)
-- ═══════════════════════════════════════════════════════════════

print("🔧 Loading UI Library...")

local Rayfield
local success, error = pcall(function()
    local uiContent = game:HttpGet("https://sirius.menu/rayfield", true)
    if uiContent then
        Rayfield = loadstring(uiContent)()
        print("✅ UI Library loaded successfully!")
    end
end)

if not success or not Rayfield then
    NotifyError("UI Error", "Failed to load UI library!")
    return
end

-- Mobile detection (from new.lua)
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local screenSize = Workspace.CurrentCamera.ViewportSize

-- ═══════════════════════════════════════════════════════════════
-- MAIN WINDOW CREATION
-- ═══════════════════════════════════════════════════════════════

local Window = Rayfield:CreateWindow({
    Name = isMobile and "Combined Fish It Pro Mobile" or "Combined Fish It Pro Ultimate v1.0",
    LoadingTitle = "Combined Fish It Pro",
    LoadingSubtitle = "Combining the best features from both scripts",
    Theme = "Default",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "CombinedFishItPro",
        FileName = "Config"
    },
    DisableRayfieldPrompts = false,
    KeySystem = false
})

-- ═══════════════════════════════════════════════════════════════
-- FISHING FUNCTIONS (from old.lua - enhanced)
-- ═══════════════════════════════════════════════════════════════

local function startFishing()
    if State.autoFishing then return end
    
    State.autoFishing = true
    State.startTime = tick()
    State.fishCaught = 0
    
    NotifySuccess("Auto Fishing", "🎣 Starting fishing with security protocols!")
    
    task.spawn(function()
        while State.autoFishing do
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                -- Security check
                if not isActionSafe() then
                    task.wait(0.1)
                    continue
                end
                
                -- Start fishing with security
                local success = safeInvokeWithSecurity(Remotes.RequestFishing)
                if success then
                    State.fishCaught = State.fishCaught + 1
                    
                    -- Charge rod
                    task.wait(getRandomDelay(0.1, 0.3))
                    safeInvokeWithSecurity(Remotes.ChargeRod, 100)
                    
                    -- Complete fishing
                    task.wait(getRandomDelay(0.5, 1.0))
                    Remotes.FishingComplete:FireServer()
                    
                    -- Simulate human behavior
                    if math.random() < 0.3 then -- 30% chance
                        simulateHumanInput()
                    end
                end
                
                -- Dynamic delay based on preset
                local delay = CONFIG.presets[State.currentPreset] and CONFIG.presets[State.currentPreset].delay or CONSTANTS.FISHING_DELAY
                local randomDelay = getRandomDelay(delay, delay + 0.2)
                task.wait(randomDelay)
                
                -- Auto sell check
                if State.autoSell and State.fishCaught > 0 and State.fishCaught % 20 == 0 then
                    safeInvokeWithSecurity(Remotes.SellAll)
                    NotifyInfo("Auto Sell", "🏪 Sold all items automatically!")
                end
            else
                task.wait(1)
            end
        end
    end)
end

local function stopFishing()
    if not State.autoFishing then return end
    
    State.autoFishing = false
    local sessionTime = tick() - State.startTime
    
    NotifySuccess("Session Complete", 
        string.format("🎣 Fished for %.1f minutes\n🐟 Caught %d fish", 
        sessionTime / 60, State.fishCaught))
end

-- ═══════════════════════════════════════════════════════════════
-- PRESET SYSTEM (from new.lua - enhanced)
-- ═══════════════════════════════════════════════════════════════

local function applyPreset(presetName)
    local preset = CONFIG.presets[presetName]
    if not preset then return end
    
    State.currentPreset = presetName
    
    -- Apply preset settings
    if preset.autosell then
        State.autoSell = true
    end
    
    NotifySuccess("Preset Applied", 
        string.format("🎯 %s Mode Activated!\n📊 %s\n🏪 Auto-sell: %ds", 
        presetName, preset.purpose, preset.autosell))
end

-- ═══════════════════════════════════════════════════════════════
-- TELEPORT SYSTEM (simplified from both)
-- ═══════════════════════════════════════════════════════════════

local function teleportTo(location)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        NotifyError("Teleport", "Character not found!")
        return
    end
    
    local success = pcall(function()
        LocalPlayer.Character.HumanoidRootPart.CFrame = location
    end)
    
    if success then
        NotifySuccess("Teleport", "🚀 Teleported successfully!")
    else
        NotifyError("Teleport", "Failed to teleport!")
    end
end

-- ═══════════════════════════════════════════════════════════════
-- UI TABS CREATION
-- ═══════════════════════════════════════════════════════════════

-- Main Tab
local MainTab = Window:CreateTab("🏠 Main", 4483362458)

MainTab:CreateParagraph({
    Title = "🔥 Combined Fish It Pro Ultimate",
    Content = "Menggabungkan fitur terbaik dari Zayros FISHIT dan XSAN Fish It Pro untuk memberikan pengalaman fishing terbaik dengan keamanan maksimal."
})

-- Auto Fishing Toggle
MainTab:CreateToggle({
    Name = "🎣 Auto Fishing",
    CurrentValue = false,
    Flag = "AutoFishing",
    Callback = function(Value)
        if Value then
            startFishing()
        else
            stopFishing()
        end
    end,
})

-- Anti-Kick Toggle
MainTab:CreateToggle({
    Name = "🛡️ Anti-Kick Protection",
    CurrentValue = false,
    Flag = "AntiKick",
    Callback = function(Value)
        State.antiKick = Value
        if Value then
            NotifySuccess("Anti-Kick", "🛡️ Protection enabled!")
            task.spawn(function()
                while State.antiKick do
                    task.wait(getRandomDelay(CONSTANTS.MIN_ANTI_KICK_INTERVAL, CONSTANTS.MAX_ANTI_KICK_INTERVAL))
                    if State.antiKick then
                        -- Send random movement
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                            LocalPlayer.Character.Humanoid:Move(Vector3.new(0, 0, 0), false)
                        end
                    end
                end
            end)
        else
            NotifyInfo("Anti-Kick", "🛡️ Protection disabled")
        end
    end,
})

-- Auto Sell Toggle
MainTab:CreateToggle({
    Name = "🏪 Auto Sell",
    CurrentValue = false,
    Flag = "AutoSell",
    Callback = function(Value)
        State.autoSell = Value
        NotifyInfo("Auto Sell", Value and "🏪 Enabled!" or "🏪 Disabled")
    end,
})

-- Presets Tab
local PresetsTab = Window:CreateTab("⚡ Presets", 4483362458)

PresetsTab:CreateParagraph({
    Title = "🎯 Quick Start Presets",
    Content = "Pilih preset yang sesuai dengan gaya bermain Anda. Setiap preset sudah dioptimalkan untuk keamanan dan performa."
})

for presetName, presetData in pairs(CONFIG.presets) do
    PresetsTab:CreateButton({
        Name = string.format("🎯 %s Mode", presetName),
        Callback = function()
            applyPreset(presetName)
        end,
    })
end

-- Utility Tab
local UtilityTab = Window:CreateTab("🔧 Utility", 4483362458)

-- Speed controls
UtilityTab:CreateSlider({
    Name = "🏃 Walk Speed",
    Range = {16, 100},
    Increment = 1,
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Value
            State.walkSpeed = Value
        end
    end,
})

-- Sell All Button
UtilityTab:CreateButton({
    Name = "🏪 Sell All Items",
    Callback = function()
        local success = safeInvokeWithSecurity(Remotes.SellAll)
        if success then
            NotifySuccess("Sell All", "🏪 All items sold!")
        else
            NotifyError("Sell All", "Failed to sell items!")
        end
    end,
})

-- Stats Tab
local StatsTab = Window:CreateTab("📊 Statistics", 4483362458)

StatsTab:CreateParagraph({
    Title = "📈 Session Statistics",
    Content = "Statistik sesi fishing Anda akan ditampilkan di sini."
})

-- Update stats periodically
task.spawn(function()
    while true do
        task.wait(5)
        if State.autoFishing then
            local sessionTime = tick() - State.startTime
            local fishPerMin = State.fishCaught > 0 and (State.fishCaught / (sessionTime / 60)) or 0
            
            pcall(function()
                StatsTab:CreateParagraph({
                    Title = "📊 Live Stats",
                    Content = string.format(
                        "🎣 Fish Caught: %d\n⏰ Session Time: %.1f min\n📈 Fish/Min: %.1f\n🛡️ Security Level: %s",
                        State.fishCaught,
                        sessionTime / 60,
                        fishPerMin,
                        State.suspicionLevel < 5 and "Safe" or "Elevated"
                    )
                })
            end)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- INITIALIZATION & CLEANUP
-- ═══════════════════════════════════════════════════════════════

-- Cleanup existing instances
if playerGui:FindFirstChild(CONSTANTS.GUI_NAME) then
    playerGui[CONSTANTS.GUI_NAME]:Destroy()
end

-- Final notification
NotifySuccess("Combined Fish It Pro", 
    "🔥 Script loaded successfully!\n" ..
    "🛡️ Security systems active\n" ..
    "📱 " .. (isMobile and "Mobile optimized" or "Desktop ready"))

print("✅ Combined Fish It Pro Ultimate v1.0 loaded successfully!")
print("🔒 Security protocols active")
print("📊 Analytics enabled")
print("🎣 Happy fishing!")
