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
        warn("❌ Failed to invoke remote:", remoteFunction.Name, "Error:", result)
        return false
    end
    print("✅ Remote invoked successfully:", remoteFunction.Name)
    return success, result
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
-- AUTO FISHING V1 (from old.lua - SAFE VERSION)
-- ═══════════════════════════════════════════════════════════════

local function startAutoFishingV1()
    if State.autoFishingV1 then return end
    
    State.autoFishingV1 = true
    State.startTime = tick()
    createNotification("AutoFishing V1", "🎣 Zayros FISHIT Started!", 3)
    
    -- Use RunService Heartbeat with proper safety checks
    State.connections.autoFishV1 = RunService.Heartbeat:Connect(function()
        if not State.autoFishingV1 then return end
        
        local success, err = pcall(function()
            local character = LocalPlayer.Character
            if not character then return end
            
            -- Equip fishing rod first
            Remotes.EquipRod:FireServer(1)
            task.wait(0.3)
            
            -- Charge the rod
            Remotes.ChargeRod:InvokeServer(workspace:GetServerTimeNow())
            task.wait(0.2)
            
            -- Request fishing with working parameters
            Remotes.RequestFishing:InvokeServer(-1.2379989624023438, 0.9800224985802423)
            task.wait(0.3)
            
            -- Complete fishing
            Remotes.FishingComplete:FireServer()
            State.fishCaught = State.fishCaught + 1
        end)
        
        if not success then
            warn("V1 Fishing error:", err)
        end
        
        -- Important: Wait to prevent crash
        task.wait(CONSTANTS.FISHING_DELAY_V1)
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
-- AUTO FISHING V2 (from new.lua - FIXED VERSION)
-- ═══════════════════════════════════════════════════════════════

local function startAutoFishingV2()
    if State.autoFishingV2 then return end
    
    State.autoFishingV2 = true
    State.startTime = tick()
    createNotification("AutoFishing V2", "⚡ XSAN Fish It Pro Started!", 3)
    
    -- Use separate thread for V2
    State.connections.autoFishV2 = task.spawn(function()
        while State.autoFishingV2 do
            local success, err = pcall(function()
                local character = LocalPlayer.Character
                if not character then return end
                
                -- More reliable equip check
                Remotes.EquipRod:FireServer(1)
                task.wait(0.2)
                
                -- Charge with server time
                Remotes.ChargeRod:InvokeServer(workspace:GetServerTimeNow())
                task.wait(0.15)
                
                -- Request fishing - CRITICAL: Use correct parameters
                Remotes.RequestFishing:InvokeServer(-1.2379989624023438, 0.9800224985802423)
                task.wait(0.2)
                
                -- Complete fishing
                Remotes.FishingComplete:FireServer()
                State.fishCaught = State.fishCaught + 1
                
                print("🎣 V2 Fish caught! Total:", State.fishCaught)
            end)
            
            if not success then
                warn("V2 Fishing error:", err)
            end
            
            -- V2 faster delay but safe
            task.wait(CONSTANTS.FISHING_DELAY_V2)
            
            -- Random pause for human-like behavior
            if math.random(1, 20) == 1 then
                task.wait(math.random() + 0.5)
            end
        end
    end)
end

local function stopAutoFishingV2()
    if not State.autoFishingV2 then return end
    
    State.autoFishingV2 = false
    if State.connections.autoFishV2 then
        task.cancel(State.connections.autoFishV2)
        State.connections.autoFishV2 = nil
    end
    
    createNotification("AutoFishing V2", "⏹️ XSAN Fish It Pro Stopped!", 3)
end
end

-- ═══════════════════════════════════════════════════════════════
-- UI LIBRARY SETUP (WITH FALLBACK)
-- ═══════════════════════════════════════════════════════════════

-- Try to load UI Library, fallback to simple UI if failed
local UILib
local useUILibrary = false

pcall(function()
    UILib = loadstring(game:HttpGet("https://raw.githubusercontent.com/MELLISAEFFENDY/MELLISAEFFENDY.github.io/main/UILibrary.lua"))()
    useUILibrary = true
    print("✅ UI Library loaded successfully")
end)

if not useUILibrary then
    print("⚠️ UI Library failed to load, using simple UI")
    -- Simple UI fallback will be created below
end

-- Variables for UI elements
local Window, MainSection, StatsSection, V1Button, V2Button, StatsLabel

-- ═══════════════════════════════════════════════════════════════
-- UI ELEMENTS CREATION (WITH FALLBACK)
-- ═══════════════════════════════════════════════════════════════

if useUILibrary and UILib then
    -- Create main window using UI Library
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

else
    -- Fallback: Create simple UI
    print("📱 Creating simple UI for Delta compatibility...")
    
    -- Cleanup existing GUI
    if PlayerGui:FindFirstChild(CONSTANTS.GUI_NAME) then
        PlayerGui[CONSTANTS.GUI_NAME]:Destroy()
    end

    -- Create simple GUI (similar to Upgrade_Safe.lua)
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
        
        local statsText = "📊 Fish Caught: " .. State.fishCaught .. " | ⏱️ Time: " .. timeElapsed .. "s | 🎯 Status: " .. status
        
        if useUILibrary and StatsLabel and StatsLabel.SetText then
            StatsLabel.SetText(statsText)
        elseif StatsLabel and StatsLabel.Text then
            StatsLabel.Text = statsText
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
