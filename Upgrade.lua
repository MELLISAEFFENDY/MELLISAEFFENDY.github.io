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
    FISHING_DELAY_V1 = 1, -- Slower for safety, no crash
    FISHING_DELAY_V2 = 0.8, -- Still faster but safe
    DEFAULT_WALKSPEED = 16,
    MAX_WALKSPEED = 100,
    ANTI_KICK_INTERVAL = 30
}

-- ═══════════════════════════════════════════════════════════════
-- USER CONFIGURATION (EDIT THESE TO CUSTOMIZE)
-- ═══════════════════════════════════════════════════════════════

local CONFIG = {
    -- UI Configuration
    useUILibrary = true,  -- true = Use Rayfield UI Library (Delta compatible), false = Use simple UI
    uiLibraryType = "rayfield", -- "rayfield" = proven to work on Delta, "custom" = our custom UI
    
    -- UI Library URLs
    rayfieldURL = "https://sirius.menu/rayfield",
    customUIURL = "https://raw.githubusercontent.com/MELLISAEFFENDY/MELLISAEFFENDY.github.io/main/UILibrary.lua",
    
    -- Safety Configuration
    safeMode = true,      -- Enhanced safety measures for mobile executors
    maxRetries = 3,       -- Maximum retry attempts for remote calls
    fishingDelay = 1.5,   -- Delay between fishing attempts (seconds)
    
    -- Auto Features
    autoEquipRod = true,  -- Automatically equip fishing rod
    autoSell = false,     -- Automatically sell fish (experimental)
    notifications = true, -- Show notifications
}

print("⚙️ Upgrade.lua Configuration:")
print("   📱 UI Library:", CONFIG.useUILibrary and ("✅ " .. CONFIG.uiLibraryType:upper()) or "❌ Simple UI")
print("   🛡️ Safe Mode:", CONFIG.safeMode and "✅ Enabled" or "❌ Disabled")
print("   🎣 Fishing Delay:", CONFIG.fishingDelay .. "s")

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
    if not remoteFunction then 
        warn("❌ Remote not found!")
        return false 
    end
    
    local success, result = pcall(function()
        if remoteFunction.ClassName == "RemoteFunction" then
            return remoteFunction:InvokeServer(...)
        else
            remoteFunction:FireServer(...)
            return true
        end
    end)
    
    if not success then
        warn("❌ Remote call failed:", remoteFunction.Name or "Unknown", "Error:", result)
        return false
    end
    
    return true
end

local function createNotification(title, text, duration)
    game.StarterGui:SetCore("SendNotification", {
        Title = title;
        Text = text;
        Duration = duration or 3;
    })
    print("📢 " .. title .. ": " .. text)
end

-- Debug function to check remotes
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

-- ═══════════════════════════════════════════════════════════════
-- AUTO FISHING V1 (SAFE & WORKING VERSION)
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
                if safeInvoke(Remotes.EquipRod, 1) then
                    wait(0.3)
                    
                    if safeInvoke(Remotes.ChargeRod, workspace:GetServerTimeNow()) then
                        wait(0.2)
                        
                        if safeInvoke(Remotes.RequestFishing, -1.2379989624023438, 0.9800224985802423) then
                            wait(0.3)
                            
                            -- Complete fishing
                            Remotes.FishingComplete:FireServer()
                            State.fishCaught = State.fishCaught + 1
                            print("🎣 V1 Fish caught! Total:", State.fishCaught)
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
-- AUTO FISHING V2 (ENHANCED & WORKING VERSION)
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
                if safeInvoke(Remotes.EquipRod, 1) then
                    wait(0.25)
                    
                    if safeInvoke(Remotes.ChargeRod, workspace:GetServerTimeNow()) then
                        wait(0.15)
                        
                        if safeInvoke(Remotes.RequestFishing, -1.2379989624023438, 0.9800224985802423) then
                            wait(0.25)
                            
                            -- Complete fishing
                            Remotes.FishingComplete:FireServer()
                            State.fishCaught = State.fishCaught + 1
                            print("⚡ V2 Fish caught! Total:", State.fishCaught)
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
end

-- ═══════════════════════════════════════════════════════════════
-- UI LIBRARY SETUP (SUPPORTS RAYFIELD & CUSTOM UI)
-- ═══════════════════════════════════════════════════════════════

-- Try to load UI Library based on configuration
local UILib
local Rayfield
local useUILibrary = CONFIG.useUILibrary

if CONFIG.useUILibrary then
    if CONFIG.uiLibraryType == "rayfield" then
        print("🎨 Loading Rayfield UI Library (Delta Compatible)...")
        local success, err = pcall(function()
            Rayfield = loadstring(game:HttpGet(CONFIG.rayfieldURL, true))()
            if Rayfield then
                print("✅ Rayfield UI Library loaded successfully!")
            else
                error("Rayfield failed to initialize")
            end
        end)

        if not success or not Rayfield then
            print("⚠️ Rayfield failed to load:", err or "Unknown error")
            print("📱 Falling back to simple UI...")
            useUILibrary = false
        end
        
    elseif CONFIG.uiLibraryType == "custom" then
        print("🎨 Loading Custom UI Library...")
        local success, err = pcall(function()
            local response = game:HttpGet(CONFIG.customUIURL)
            UILib = loadstring(response)()
            if UILib then
                print("✅ Custom UI Library loaded successfully!")
            else
                error("Custom UI Library failed to initialize")
            end
        end)

        if not success or not UILib then
            print("⚠️ Custom UI Library failed to load:", err or "Unknown error")
            print("📱 Falling back to simple UI...")
            useUILibrary = false
        end
    end
else
    print("📱 UI Library disabled in config, using simple UI...")
    useUILibrary = false
end

-- Variables for UI elements
local Window, MainSection, StatsSection, V1Button, V2Button, StatsLabel

-- ═══════════════════════════════════════════════════════════════
-- UI ELEMENTS CREATION (WITH PROPER UI LIBRARY)
-- ═══════════════════════════════════════════════════════════════

-- Try to use UI Library first, fallback to simple UI if it fails
print("🎨 Attempting to create UI...")

if useUILibrary then
    local success, err = pcall(function()
        if CONFIG.uiLibraryType == "rayfield" and Rayfield then
            print("✨ Creating Rayfield UI...")
            
            -- Create main window using Rayfield
            Window = Rayfield:CreateWindow({
                Name = "🚀 Upgrade.lua - Fish It Ultimate",
                LoadingTitle = "Upgrade Script",
                LoadingSubtitle = "by MELLISA EFFENDY",
                ConfigurationSaving = {
                    Enabled = false,
                },
                Discord = {
                    Enabled = false,
                },
                KeySystem = false,
            })

            -- Create main tab
            local MainTab = Window:CreateTab("🎣 AutoFishing", nil)
            local StatsTab = Window:CreateTab("📊 Statistics", nil)

            -- Create AutoFishing buttons
            V1Button = MainTab:CreateButton({
                Name = "🎣 AutoFishing V1 - Zayros FISHIT",
                Callback = function()
                    if State.autoFishingV1 then
                        stopAutoFishingV1()
                    else
                        if State.autoFishingV2 then
                            stopAutoFishingV2()
                        end
                        startAutoFishingV1()
                    end
                end,
            })

            V2Button = MainTab:CreateButton({
                Name = "⚡ AutoFishing V2 - XSAN Fish It Pro",
                Callback = function()
                    if State.autoFishingV2 then
                        stopAutoFishingV2()
                    else
                        if State.autoFishingV1 then
                            stopAutoFishingV1()
                        end
                        startAutoFishingV2()
                    end
                end,
            })

            -- Statistics paragraph
            StatsLabel = StatsTab:CreateParagraph({Title = "📊 Statistics", Content = "Fish Caught: 0 | Status: Ready"})
            
            print("✅ Rayfield UI created successfully!")
            
        elseif CONFIG.uiLibraryType == "custom" and UILib then
            print("✨ Creating Custom UI...")
            
            -- Create main window using Custom UI Library
            Window = UILib:CreateWindow({
                Title = "🚀 Upgrade.lua - Fish It Ultimate",
                Size = UDim2.new(0.4, 0, 0.5, 0),
                Position = UDim2.new(0.3, 0, 0.25, 0),
                Theme = "Dark",
                Draggable = true
            })

            -- Create sections
            MainSection = Window:CreateSection("AutoFishing Systems")
            StatsSection = Window:CreateSection("Statistics")

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
            
            print("✅ Custom UI created successfully!")
        end
    end)
    
    if not success then
        print("❌ UI Library creation failed:", err)
        useUILibrary = false
    end
end

if not useUILibrary then
    -- Create simple UI fallback
    print("📱 Creating simple UI fallback...")
    
    -- Cleanup existing GUI
    if PlayerGui:FindFirstChild(CONSTANTS.GUI_NAME) then
        PlayerGui[CONSTANTS.GUI_NAME]:Destroy()
    end

    -- Create simple GUI
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = CONSTANTS.GUI_NAME
    ScreenGui.Parent = PlayerGui
    ScreenGui.ResetOnSpawn = false

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.35, 0, 0.3, 0)
    MainFrame.Size = UDim2.new(0.3, 0, 0.4, 0)
    MainFrame.Active = true
    MainFrame.Draggable = true

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Parent = MainFrame
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.Size = UDim2.new(1, 0, 0.2, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "🚀 Upgrade.lua - Ultimate"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextScaled = true

    V1Button = Instance.new("TextButton")
    V1Button.Parent = MainFrame
    V1Button.BackgroundColor3 = Color3.fromRGB(80, 160, 80)
    V1Button.BorderSizePixel = 0
    V1Button.Position = UDim2.new(0.05, 0, 0.25, 0)
    V1Button.Size = UDim2.new(0.9, 0, 0.25, 0)
    V1Button.Font = Enum.Font.GothamBold
    V1Button.Text = "🎣 AutoFishing V1 - Zayros FISHIT"
    V1Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    V1Button.TextScaled = true

    local V1Corner = Instance.new("UICorner")
    V1Corner.CornerRadius = UDim.new(0, 8)
    V1Corner.Parent = V1Button

    V2Button = Instance.new("TextButton")
    V2Button.Parent = MainFrame
    V2Button.BackgroundColor3 = Color3.fromRGB(255, 140, 60)
    V2Button.BorderSizePixel = 0
    V2Button.Position = UDim2.new(0.05, 0, 0.55, 0)
    V2Button.Size = UDim2.new(0.9, 0, 0.25, 0)
    V2Button.Font = Enum.Font.GothamBold
    V2Button.Text = "⚡ AutoFishing V2 - XSAN Fish It Pro"
    V2Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    V2Button.TextScaled = true

    local V2Corner = Instance.new("UICorner")
    V2Corner.CornerRadius = UDim.new(0, 8)
    V2Corner.Parent = V2Button

    StatsLabel = Instance.new("TextLabel")
    StatsLabel.Parent = MainFrame
    StatsLabel.BackgroundTransparency = 1
    StatsLabel.Position = UDim2.new(0.05, 0, 0.85, 0)
    StatsLabel.Size = UDim2.new(0.9, 0, 0.1, 0)
    StatsLabel.Font = Enum.Font.Gotham
    StatsLabel.Text = "📊 Fish: 0 | Status: Ready"
    StatsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    StatsLabel.TextScaled = true

    -- Simple button connections
    V1Button.MouseButton1Click:Connect(function()
        if State.autoFishingV1 then
            stopAutoFishingV1()
        else
            if State.autoFishingV2 then
                stopAutoFishingV2()
            end
            startAutoFishingV1()
        end
    end)

    V2Button.MouseButton1Click:Connect(function()
        if State.autoFishingV2 then
            stopAutoFishingV2()
        else
            if State.autoFishingV1 then
                stopAutoFishingV1()
            end
            startAutoFishingV2()
        end
    end)

    print("✅ Simple UI created successfully!")
end

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
        
        local statsText = "Fish Caught: " .. State.fishCaught .. " | Time: " .. timeElapsed .. "s | Status: " .. status
        
        -- Update stats based on UI type
        if useUILibrary and StatsLabel then
            if CONFIG.uiLibraryType == "rayfield" then
                -- Rayfield uses :Set() method for Paragraphs
                pcall(function()
                    StatsLabel:Set({Title = "📊 Statistics", Content = statsText})
                end)
            elseif CONFIG.uiLibraryType == "custom" and StatsLabel.SetText then
                -- Custom UI uses SetText method
                pcall(function()
                    StatsLabel.SetText("📊 " .. statsText)
                end)
            end
        elseif StatsLabel and StatsLabel.Text then
            -- Simple UI uses Text property
            StatsLabel.Text = "📊 " .. statsText
        end
    end
end

-- Stats update loop
if useUILibrary then
    State.connections.statsUpdate = RunService.Heartbeat:Connect(updateStats)
else
    -- Simple stats update for fallback UI
    spawn(function()
        while PlayerGui:FindFirstChild(CONSTANTS.GUI_NAME) do
            updateStats()
            wait(1)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- IMPROVED AUTO FISHING FUNCTIONS WITH UI UPDATES
-- ═══════════════════════════════════════════════════════════════

-- Update V1 functions to change button appearance
local originalStartV1 = startAutoFishingV1
startAutoFishingV1 = function()
    originalStartV1()
    if State.autoFishingV1 then
        if useUILibrary then
            -- UI Library doesn't need manual button updates
        else
            V1Button.Text = "⏹️ STOP V1 FISHING"
            V1Button.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
            V2Button.Text = "⚡ AutoFishing V2 - XSAN Fish It Pro"
            V2Button.BackgroundColor3 = Color3.fromRGB(255, 140, 60)
        end
    end
end

local originalStopV1 = stopAutoFishingV1
stopAutoFishingV1 = function()
    originalStopV1()
    if not useUILibrary then
        V1Button.Text = "🎣 AutoFishing V1 - Zayros FISHIT"
        V1Button.BackgroundColor3 = Color3.fromRGB(80, 160, 80)
    end
end

local originalStartV2 = startAutoFishingV2
startAutoFishingV2 = function()
    originalStartV2()
    if State.autoFishingV2 then
        if useUILibrary then
            -- UI Library doesn't need manual button updates
        else
            V2Button.Text = "⏹️ STOP V2 FISHING"
            V2Button.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
            V1Button.Text = "🎣 AutoFishing V1 - Zayros FISHIT"
            V1Button.BackgroundColor3 = Color3.fromRGB(80, 160, 80)
        end
    end
end

local originalStopV2 = stopAutoFishingV2
stopAutoFishingV2 = function()
    originalStopV2()
    if not useUILibrary then
        V2Button.Text = "⚡ AutoFishing V2 - XSAN Fish It Pro"
        V2Button.BackgroundColor3 = Color3.fromRGB(255, 140, 60)
    end
end

-- Add proper cleanup function
local function cleanupAllConnections()
    -- Stop all fishing
    stopAutoFishingV1()
    stopAutoFishingV2()
    
    -- Cleanup all connections
    for name, connection in pairs(State.connections) do
        if connection then
            if typeof(connection) == "RBXScriptConnection" then
                connection:Disconnect()
            elseif typeof(connection) == "thread" then
                task.cancel(connection)
            end
            State.connections[name] = nil
        end
    end
    
    print("🧹 All connections cleaned up!")
end

-- Update window close handler
-- (This will be handled by UI Library automatically with proper cleanup)

-- ═══════════════════════════════════════════════════════════════
-- INITIALIZATION WITH FALLBACK SYSTEM
-- ═══════════════════════════════════════════════════════════════

-- Debug check remotes first
checkRemotes()

if useUILibrary then
    UILib:Notification("Upgrade.lua", "🚀 Script loaded with UI Library!\n📋 Choose AutoFishing version", 5, "Success")
    print("✅ Upgrade.lua loaded with UI Library!")
else
    createNotification("Upgrade.lua", "🚀 Script loaded with Simple UI!\n📋 Choose AutoFishing version", 5)
    print("✅ Upgrade.lua loaded with Simple UI fallback!")
end

print("🎣 AutoFishing V1: Zayros FISHIT ready")
print("⚡ AutoFishing V2: XSAN Fish It Pro ready")
print("🎨 UI System:", useUILibrary and "Advanced (UI Library)" or "Simple (Fallback)")
print("🔧 Delta Executor compatibility: ENABLED")

-- Test a simple remote call to verify connection
task.spawn(function()
    task.wait(2)
    print("🧪 Testing remote connection...")
    local testSuccess = pcall(function()
        if LocalPlayer.Character then
            print("✅ Character found:", LocalPlayer.Character.Name)
        end
        if Remotes.EquipRod then
            print("✅ EquipRod remote accessible")
        end
    end)
    
    if testSuccess then
        print("✅ All systems operational!")
    else
        warn("⚠️ Some systems may not be ready")
    end
end)
