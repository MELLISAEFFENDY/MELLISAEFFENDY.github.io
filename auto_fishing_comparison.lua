--[[
    BOT FISH IT V1 - Modern UI (Android Compatible)
    Comparison Auto Fishing Script
    AFK V1 (old.lua) vs AFK V2 (new.lua)
    
    Features:
    - Modern table-based UI design
    - Android/Mobile optimized
    - Error handling & debugging
    - Fallback UI system
--]]

print("🔥 Loading BOT FISH IT V1 (Android Version)...")

-- ═══════════════════════════════════════════════════════════════
-- ANDROID COMPATIBILITY & ERROR HANDLING
-- ═══════════════════════════════════════════════════════════════

local success = true
local errorMessage = ""

-- Test basic Roblox services
local function testServices()
    local testResults = {}
    
    pcall(function()
        testResults.Players = game:GetService("Players") ~= nil
        testResults.LocalPlayer = game:GetService("Players").LocalPlayer ~= nil
        testResults.PlayerGui = game:GetService("Players").LocalPlayer.PlayerGui ~= nil
        testResults.StarterGui = game:GetService("StarterGui") ~= nil
        testResults.TweenService = game:GetService("TweenService") ~= nil
    end)
    
    print("� Service Test Results:")
    for service, result in pairs(testResults) do
        print("  ", service, ":", result and "✅" or "❌")
    end
    
    return testResults
end

-- Run service tests
local serviceTests = testServices()

-- ═══════════════════════════════════════════════════════════════
-- SERVICES & SETUP WITH ERROR HANDLING
-- ═══════════════════════════════════════════════════════════════

-- Safe service loading with error handling
local Players, ReplicatedStorage, UserInputService, TweenService, RunService, StarterGui
local LocalPlayer

local function safeGetService(serviceName)
    local success, service = pcall(function()
        return game:GetService(serviceName)
    end)
    return success and service or nil
end

-- Initialize services safely
Players = safeGetService("Players")
ReplicatedStorage = safeGetService("ReplicatedStorage")
UserInputService = safeGetService("UserInputService")
TweenService = safeGetService("TweenService")
RunService = safeGetService("RunService")
StarterGui = safeGetService("StarterGui")

-- Ensure basic services are available
if not Players then
    error("❌ Critical: Players service not available")
    return
end

LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    error("❌ Critical: LocalPlayer not found")
    return
end

-- Print service status
print("🔧 Service Status:")
print("  Players:", Players and "✅" or "❌")
print("  ReplicatedStorage:", ReplicatedStorage and "✅" or "❌")
print("  UserInputService:", UserInputService and "✅" or "❌")
print("  TweenService:", TweenService and "✅" or "❌")
print("  RunService:", RunService and "✅" or "❌")
print("  StarterGui:", StarterGui and "✅" or "❌")

-- Wait for character to load
if not LocalPlayer.Character then
    print("⏳ Waiting for character to load...")
    LocalPlayer.CharacterAdded:Wait()
    task.wait(2) -- Extra wait for stability
end

print("✅ Character loaded successfully!")

-- ═══════════════════════════════════════════════════════════════
-- UI CREATION WITH MULTIPLE FALLBACK METHODS
-- ═══════════════════════════════════════════════════════════════

-- UI State Management
local UIState = {
    isMinimized = false,
    isLoaded = false
}

-- Create ScreenGui with multiple parent attempts
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BotFishItV1"
ScreenGui.ResetOnSpawn = false

-- Try multiple parent methods for maximum compatibility
local function setupScreenGui()
    local success = false
    
    -- Method 1: Try PlayerGui (most common)
    if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
        success = pcall(function()
            ScreenGui.Parent = LocalPlayer.PlayerGui
        end)
        if success then
            print("✅ UI: Attached to PlayerGui")
            return true
        end
    end
    
    -- Method 2: Try CoreGui (for exploits)
    if not success then
        success = pcall(function()
            ScreenGui.Parent = game:GetService("CoreGui")
        end)
        if success then
            print("✅ UI: Attached to CoreGui")
            return true
        end
    end
    
    -- Method 3: Try StarterGui (fallback)
    if not success and StarterGui then
        success = pcall(function()
            ScreenGui.Parent = StarterGui
        end)
        if success then
            print("✅ UI: Attached to StarterGui")
            return true
        end
    end
    
    -- Method 4: Emergency - try Workspace
    if not success then
        success = pcall(function()
            ScreenGui.Parent = game.Workspace
        end)
        if success then
            print("⚠️ UI: Emergency attachment to Workspace")
            return true
        end
    end
    
    return false
end

-- Setup ScreenGui with error handling
local uiSetupSuccess = setupScreenGui()
if not uiSetupSuccess then
    error("❌ Critical: Cannot create UI - No valid parent found")
    return
end

-- ═══════════════════════════════════════════════════════════════
-- ENHANCED NOTIFICATION SYSTEM
-- ═══════════════════════════════════════════════════════════════

local function Notify(title, message)
    -- Method 1: Try StarterGui notification
    local success1 = false
    if StarterGui then
        success1 = pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = title,
                Text = message,
                Duration = 5,
                Icon = "rbxassetid://0"
            })
        end)
    end
    
    -- Method 2: Print to console (always works)
    print("📢 " .. title .. ": " .. message)
    
    -- Method 3: Try chat message as fallback
    if not success1 then
        pcall(function()
            game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync("🤖 " .. title .. ": " .. message)
        end)
    end
    
    -- Method 4: Force UI feedback
    pcall(function()
        if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
            -- Create temporary label for critical notifications
            local tempGui = Instance.new("ScreenGui")
            tempGui.Name = "TempNotification"
            tempGui.Parent = LocalPlayer.PlayerGui
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0, 300, 0, 60)
            label.Position = UDim2.new(0.5, -150, 0, 10)
            label.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextScaled = true
            label.Font = Enum.Font.SourceSansBold
            label.Text = title .. "
" .. message
            label.Parent = tempGui
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 8)
            corner.Parent = label
            
            -- Auto remove after 3 seconds
            game:GetService("Debris"):AddItem(tempGui, 3)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- ANDROID-OPTIMIZED UI CREATION
-- ═══════════════════════════════════════════════════════════════

print("🔨 Creating Android-optimized UI...")

-- Cleanup existing UI with better error handling
pcall(function()
    if LocalPlayer.PlayerGui:FindFirstChild("BotFishItV1") then
        LocalPlayer.PlayerGui.BotFishItV1:Destroy()
        task.wait(0.1) -- Give time for cleanup
    end
end)

-- Detect platform
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local screenSize = workspace.CurrentCamera.ViewportSize

print("📱 Platform Detection:")
print("  Mobile:", isMobile)
print("  Screen Size:", screenSize.X .. "x" .. screenSize.Y)
print("  Touch Enabled:", UserInputService.TouchEnabled)
print("  Keyboard Enabled:", UserInputService.KeyboardEnabled)

-- Create ScreenGui with Android-specific settings
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BotFishItV1"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true -- Important for Android
ScreenGui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets -- Important for Android

-- Try multiple parent methods for Android compatibility
local uiParented = false
pcall(function()
    ScreenGui.Parent = LocalPlayer.PlayerGui
    uiParented = true
    print("✅ UI parented to PlayerGui")
end)

if not uiParented then
    pcall(function()
        ScreenGui.Parent = game.CoreGui
        uiParented = true
        print("✅ UI parented to CoreGui (fallback)")
    end)
end

if not uiParented then
    error("❌ Failed to parent UI to any GUI container")
end

-- Calculate responsive sizes for Android
local baseWidth = isMobile and math.min(screenSize.X * 0.85, 350) or 400
local baseHeight = isMobile and math.min(screenSize.Y * 0.4, 220) or 250

print("📐 UI Dimensions:", baseWidth .. "x" .. baseHeight)

-- Main Frame with Android optimizations
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
MainFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BorderSizePixel = isMobile and 1 or 2
MainFrame.Position = UDim2.new(0.5, -baseWidth/2, 0.5, -baseHeight/2) -- Center position
MainFrame.Size = UDim2.new(0, baseWidth, 0, baseHeight)
MainFrame.Active = true

-- Make draggable only on desktop
if not isMobile then
    MainFrame.Draggable = true
end

-- Add corner radius
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, isMobile and 8 or 10)
MainCorner.Parent = MainFrame

-- Add gradient background
local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 50, 50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 35))
}
Gradient.Rotation = 45
Gradient.Parent = MainFrame

-- Title Bar (Android optimized)
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Parent = MainFrame
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, isMobile and 35 or 40)

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, isMobile and 8 or 10)
TitleCorner.Parent = TitleBar

-- Title Text (responsive font size)
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = TitleBar
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.Size = UDim2.new(1, -80, 1, 0)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Text = "BOT FISH IT V1"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = isMobile and 14 or 18
TitleLabel.TextScaled = isMobile -- Enable text scaling on mobile
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Minimize Button (larger for touch)
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Name = "MinimizeBtn"
MinimizeBtn.Parent = TitleBar
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.Position = UDim2.new(1, isMobile and -60 or -65, 0.5, isMobile and -12 or -10)
MinimizeBtn.Size = UDim2.new(0, isMobile and 30 or 25, 0, isMobile and 24 or 20)
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = isMobile and 16 or 14

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 4)
MinimizeCorner.Parent = MinimizeBtn

-- Close Button (larger for touch)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Parent = TitleBar
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.BorderSizePixel = 0
CloseBtn.Position = UDim2.new(1, isMobile and -28 or -35, 0.5, isMobile and -12 or -10)
CloseBtn.Size = UDim2.new(0, isMobile and 30 or 25, 0, isMobile and 24 or 20)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = isMobile and 18 or 16

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = CloseBtn

-- Table Container (responsive)
local TableContainer = Instance.new("Frame")
TableContainer.Name = "TableContainer"
TableContainer.Parent = MainFrame
TableContainer.BackgroundTransparency = 1
TableContainer.Position = UDim2.new(0, 10, 0, isMobile and 45 or 50)
TableContainer.Size = UDim2.new(1, -20, 1, isMobile and -55 or -60)

-- Success notification
Notify("UI Created", "✅ Android-optimized UI created successfully!")

print("✅ Basic UI structure created successfully!")
print("🔧 Next: Creating table components...")

-- ═══════════════════════════════════════════════════════════════
-- TABLE COMPONENTS (Android Optimized)
-- ═══════════════════════════════════════════════════════════════

-- Table Header
local HeaderFrame = Instance.new("Frame")
HeaderFrame.Name = "HeaderFrame"
HeaderFrame.Parent = TableContainer
HeaderFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
HeaderFrame.BorderSizePixel = 0
HeaderFrame.Size = UDim2.new(1, 0, 0, isMobile and 30 or 35)

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 6)
HeaderCorner.Parent = HeaderFrame

-- Header Columns with responsive sizing
local AutoFishingHeader = Instance.new("TextLabel")
AutoFishingHeader.Name = "AutoFishingHeader"
AutoFishingHeader.Parent = HeaderFrame
AutoFishingHeader.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
AutoFishingHeader.BorderSizePixel = 0
AutoFishingHeader.Position = UDim2.new(0, 3, 0, 3)
AutoFishingHeader.Size = UDim2.new(0, isMobile and 110 or 120, 1, -6)
AutoFishingHeader.Font = Enum.Font.SourceSansBold
AutoFishingHeader.Text = "AUTO FISHING"
AutoFishingHeader.TextColor3 = Color3.fromRGB(0, 0, 0)
AutoFishingHeader.TextSize = isMobile and 12 or 14
AutoFishingHeader.TextScaled = isMobile
AutoFishingHeader.TextXAlignment = Enum.TextXAlignment.Center

local AutoHeaderCorner = Instance.new("UICorner")
AutoHeaderCorner.CornerRadius = UDim.new(0, 4)
AutoHeaderCorner.Parent = AutoFishingHeader

-- Method Header
local MethodHeader = Instance.new("TextLabel")
MethodHeader.Name = "MethodHeader"
MethodHeader.Parent = HeaderFrame
MethodHeader.BackgroundTransparency = 1
MethodHeader.Position = UDim2.new(0, isMobile and 120 or 130, 0, 0)
MethodHeader.Size = UDim2.new(0, isMobile and 80 or 100, 1, 0)
MethodHeader.Font = Enum.Font.SourceSansBold
MethodHeader.Text = "METHOD"
MethodHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
MethodHeader.TextSize = isMobile and 12 or 14
MethodHeader.TextScaled = isMobile
MethodHeader.TextXAlignment = Enum.TextXAlignment.Center

-- Status Header
local StatusHeader = Instance.new("TextLabel")
StatusHeader.Name = "StatusHeader"
StatusHeader.Parent = HeaderFrame
StatusHeader.BackgroundTransparency = 1
StatusHeader.Position = UDim2.new(0, isMobile and 210 or 240, 0, 0)
StatusHeader.Size = UDim2.new(1, isMobile and -210 or -240, 1, 0)
StatusHeader.Font = Enum.Font.SourceSansBold
StatusHeader.Text = "STATUS"
StatusHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusHeader.TextSize = isMobile and 12 or 14
StatusHeader.TextScaled = isMobile
StatusHeader.TextXAlignment = Enum.TextXAlignment.Center

-- Rows Container
local RowsContainer = Instance.new("Frame")
RowsContainer.Name = "RowsContainer"
RowsContainer.Parent = TableContainer
RowsContainer.BackgroundTransparency = 1
RowsContainer.Position = UDim2.new(0, 0, 0, isMobile and 38 or 43)
RowsContainer.Size = UDim2.new(1, 0, 1, isMobile and -38 or -43)

-- AFK 1 Row
local AFK1Row = Instance.new("Frame")
AFK1Row.Name = "AFK1Row"
AFK1Row.Parent = RowsContainer
AFK1Row.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
AFK1Row.BorderSizePixel = 0
AFK1Row.Position = UDim2.new(0, 0, 0, 5)
AFK1Row.Size = UDim2.new(1, 0, 0, isMobile and 35 or 40)

local AFK1Corner = Instance.new("UICorner")
AFK1Corner.CornerRadius = UDim.new(0, 6)
AFK1Corner.Parent = AFK1Row

-- AFK 1 Label
local AFK1Label = Instance.new("TextLabel")
AFK1Label.Name = "AFK1Label"
AFK1Label.Parent = AFK1Row
AFK1Label.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
AFK1Label.BorderSizePixel = 0
AFK1Label.Position = UDim2.new(0, 3, 0, 3)
AFK1Label.Size = UDim2.new(0, isMobile and 110 or 120, 1, -6)
AFK1Label.Font = Enum.Font.SourceSansBold
AFK1Label.Text = "AFK 1"
AFK1Label.TextColor3 = Color3.fromRGB(0, 0, 0)
AFK1Label.TextSize = isMobile and 14 or 16
AFK1Label.TextScaled = isMobile

local AFK1LabelCorner = Instance.new("UICorner")
AFK1LabelCorner.CornerRadius = UDim.new(0, 4)
AFK1LabelCorner.Parent = AFK1Label

-- AFK 1 Method
local AFK1Method = Instance.new("TextLabel")
AFK1Method.Name = "AFK1Method"
AFK1Method.Parent = AFK1Row
AFK1Method.BackgroundTransparency = 1
AFK1Method.Position = UDim2.new(0, isMobile and 120 or 130, 0, 0)
AFK1Method.Size = UDim2.new(0, isMobile and 80 or 100, 1, 0)
AFK1Method.Font = Enum.Font.SourceSans
AFK1Method.Text = "Simple"
AFK1Method.TextColor3 = Color3.fromRGB(200, 200, 200)
AFK1Method.TextSize = isMobile and 12 or 14
AFK1Method.TextScaled = isMobile
AFK1Method.TextXAlignment = Enum.TextXAlignment.Center

-- AFK 1 Toggle Button (larger for touch)
local AFK1Toggle = Instance.new("TextButton")
AFK1Toggle.Name = "AFK1Toggle"
AFK1Toggle.Parent = AFK1Row
AFK1Toggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
AFK1Toggle.BorderSizePixel = 0
AFK1Toggle.Position = UDim2.new(0, isMobile and 215 or 245, 0.5, isMobile and -15 or -12)
AFK1Toggle.Size = UDim2.new(0, isMobile and 70 or 80, 0, isMobile and 30 or 24)
AFK1Toggle.Font = Enum.Font.SourceSansBold
AFK1Toggle.Text = "OFF"
AFK1Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
AFK1Toggle.TextSize = isMobile and 12 or 14
AFK1Toggle.TextScaled = isMobile

local AFK1ToggleCorner = Instance.new("UICorner")
AFK1ToggleCorner.CornerRadius = UDim.new(0, 5)
AFK1ToggleCorner.Parent = AFK1Toggle

-- AFK 2 Row
local AFK2Row = Instance.new("Frame")
AFK2Row.Name = "AFK2Row"
AFK2Row.Parent = RowsContainer
AFK2Row.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
AFK2Row.BorderSizePixel = 0
AFK2Row.Position = UDim2.new(0, 0, 0, isMobile and 50 or 55)
AFK2Row.Size = UDim2.new(1, 0, 0, isMobile and 35 or 40)

local AFK2Corner = Instance.new("UICorner")
AFK2Corner.CornerRadius = UDim.new(0, 6)
AFK2Corner.Parent = AFK2Row

-- AFK 2 Label
local AFK2Label = Instance.new("TextLabel")
AFK2Label.Name = "AFK2Label"
AFK2Label.Parent = AFK2Row
AFK2Label.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
AFK2Label.BorderSizePixel = 0
AFK2Label.Position = UDim2.new(0, 3, 0, 3)
AFK2Label.Size = UDim2.new(0, isMobile and 110 or 120, 1, -6)
AFK2Label.Font = Enum.Font.SourceSansBold
AFK2Label.Text = "AFK 2"
AFK2Label.TextColor3 = Color3.fromRGB(0, 0, 0)
AFK2Label.TextSize = isMobile and 14 or 16
AFK2Label.TextScaled = isMobile

local AFK2LabelCorner = Instance.new("UICorner")
AFK2LabelCorner.CornerRadius = UDim.new(0, 4)
AFK2LabelCorner.Parent = AFK2Label

-- AFK 2 Method
local AFK2Method = Instance.new("TextLabel")
AFK2Method.Name = "AFK2Method"
AFK2Method.Parent = AFK2Row
AFK2Method.BackgroundTransparency = 1
AFK2Method.Position = UDim2.new(0, isMobile and 120 or 130, 0, 0)
AFK2Method.Size = UDim2.new(0, isMobile and 80 or 100, 1, 0)
AFK2Method.Font = Enum.Font.SourceSans
AFK2Method.Text = "Advanced"
AFK2Method.TextColor3 = Color3.fromRGB(200, 200, 200)
AFK2Method.TextSize = isMobile and 12 or 14
AFK2Method.TextScaled = isMobile
AFK2Method.TextXAlignment = Enum.TextXAlignment.Center

-- AFK 2 Toggle Button (larger for touch)
local AFK2Toggle = Instance.new("TextButton")
AFK2Toggle.Name = "AFK2Toggle"
AFK2Toggle.Parent = AFK2Row
AFK2Toggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
AFK2Toggle.BorderSizePixel = 0
AFK2Toggle.Position = UDim2.new(0, isMobile and 215 or 245, 0.5, isMobile and -15 or -12)
AFK2Toggle.Size = UDim2.new(0, isMobile and 70 or 80, 0, isMobile and 30 or 24)
AFK2Toggle.Font = Enum.Font.SourceSansBold
AFK2Toggle.Text = "OFF"
AFK2Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
AFK2Toggle.TextSize = isMobile and 12 or 14
AFK2Toggle.TextScaled = isMobile

local AFK2ToggleCorner = Instance.new("UICorner")
AFK2ToggleCorner.CornerRadius = UDim.new(0, 5)
AFK2ToggleCorner.Parent = AFK2Toggle

-- Floating Button (Android optimized)
local FloatingBtn = Instance.new("TextButton")
FloatingBtn.Name = "FloatingBtn"
FloatingBtn.Parent = ScreenGui
FloatingBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
FloatingBtn.BorderSizePixel = 0
FloatingBtn.Position = UDim2.new(0, isMobile and 15 or 20, 0.5, isMobile and -30 or -25)
FloatingBtn.Size = UDim2.new(0, isMobile and 60 or 50, 0, isMobile and 60 or 50)
FloatingBtn.Font = Enum.Font.SourceSansBold
FloatingBtn.Text = "🎣"
FloatingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatingBtn.TextSize = isMobile and 24 or 20
FloatingBtn.Visible = false

local FloatingCorner = Instance.new("UICorner")
FloatingCorner.CornerRadius = UDim.new(0, isMobile and 30 or 25)
FloatingCorner.Parent = FloatingBtn

print("✅ Table components created successfully!")
print("🔧 Next: Setting up functionality...")

-- ═══════════════════════════════════════════════════════════════
-- FISHING SYSTEMS & STATE MANAGEMENT
-- ═══════════════════════════════════════════════════════════════

local FishingState = {
    AFK1 = {
        active = false,
        fishCount = 0,
        startTime = 0,
        connection = nil
    },
    AFK2 = {
        active = false,
        fishCount = 0,
        startTime = 0,
        connection = nil,
        perfectCasts = 0,
        normalCasts = 0
    }
}

-- ═══════════════════════════════════════════════════════════════
-- REMOTE EVENTS SETUP (Android Compatible)
-- ═══════════════════════════════════════════════════════════════

local Rs = ReplicatedStorage
local Remotes = {}

-- Enhanced remote detection with better error handling
local function findRemotes()
    if not Rs then
        print("⚠️ ReplicatedStorage not available - using demo mode")
        return false
    end
    
    local success = pcall(function()
        -- Method 1: Try sleitnick_net path
        local packages = Rs:FindFirstChild("Packages")
        if packages then
            local index = packages:FindFirstChild("_Index")
            if index then
                local netPackage = index:FindFirstChild("sleitnick_net@0.2.0")
                if netPackage then
                    local net = netPackage:FindFirstChild("net")
                    if net then
                        Remotes = {
                            EquipRod = net:FindFirstChild("RE/EquipToolFromHotbar"),
                            UnEquipRod = net:FindFirstChild("RE/UnequipToolFromHotbar"),
                            RequestFishing = net:FindFirstChild("RF/RequestFishingMinigameStarted"),
                            ChargeRod = net:FindFirstChild("RF/ChargeFishingRod"),
                            FishingComplete = net:FindFirstChild("RE/FishingCompleted"),
                            CancelFishing = net:FindFirstChild("RF/CancelFishingInputs"),
                            SellAll = net:FindFirstChild("RF/SellAllItems")
                        }
                        return true
                    end
                end
            end
        end
        
        -- Method 2: Try direct ReplicatedStorage children
        Remotes = {
            RequestFishing = Rs:FindFirstChild("RequestFishing"),
            ChargeRod = Rs:FindFirstChild("ChargeRod"),
            FishingComplete = Rs:FindFirstChild("FishingComplete")
        }
        
        return Remotes.RequestFishing ~= nil
    end)
    
    return success
end

local remotesFound = findRemotes()

-- Count available remotes
local remoteCount = 0
for name, remote in pairs(Remotes) do
    if remote then
        remoteCount = remoteCount + 1
    end
end

if remotesFound and remoteCount > 0 then
    print("🌐 Remote Events: ✅ Found " .. remoteCount .. " remotes")
else
    print("🌐 Remote Events: ⚠️ Demo mode active (no remotes found)")
    
    -- Create demo remotes that just print
    Remotes = {
        RequestFishing = {
            InvokeServer = function() 
                print("🎣 [DEMO] RequestFishing called")
                return true
            end
        },
        ChargeRod = {
            InvokeServer = function(power) 
                print("⚡ [DEMO] ChargeRod called with power:", power)
                return true
            end
        },
        FishingComplete = {
            FireServer = function() 
                print("✅ [DEMO] FishingComplete called")
                return true
            end
        }
    }
    
    Notify("Demo Mode", "⚠️ Game remotes not detected\nDemo mode enabled for testing")
end

-- ═══════════════════════════════════════════════════════════════
-- UI FUNCTIONALITY (Android Optimized)
-- ═══════════════════════════════════════════════════════════════

-- Smooth animation function
local function animateButton(button, targetColor, targetSize)
    if not button or not button.Parent then return end
    
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    pcall(function()
        if targetColor then
            local colorTween = TweenService:Create(button, tweenInfo, {BackgroundColor3 = targetColor})
            colorTween:Play()
        end
        
        if targetSize then
            local sizeTween = TweenService:Create(button, tweenInfo, {Size = targetSize})
            sizeTween:Play()
        end
    end)
end

-- Toggle UI visibility with smooth animation
local function toggleUI()
    UIState.isMinimized = not UIState.isMinimized
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    pcall(function()
        if UIState.isMinimized then
            -- Hide main frame
            local hideTween = TweenService:Create(MainFrame, tweenInfo, {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0)
            })
            hideTween:Play()
            
            hideTween.Completed:Connect(function()
                MainFrame.Visible = false
                FloatingBtn.Visible = true
                
                -- Animate floating button entrance
                FloatingBtn.Size = UDim2.new(0, 0, 0, 0)
                local showFloating = TweenService:Create(FloatingBtn, tweenInfo, {
                    Size = UDim2.new(0, isMobile and 60 or 50, 0, isMobile and 60 or 50)
                })
                showFloating:Play()
            end)
        else
            -- Show main frame
            FloatingBtn.Visible = false
            MainFrame.Visible = true
            MainFrame.Size = UDim2.new(0, 0, 0, 0)
            MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
            
            local showTween = TweenService:Create(MainFrame, tweenInfo, {
                Size = UDim2.new(0, baseWidth, 0, baseHeight),
                Position = UDim2.new(0.5, -baseWidth/2, 0.5, -baseHeight/2)
            })
            showTween:Play()
        end
    end)
end

-- Button click effects for Android
local function addClickEffect(button)
    button.MouseButton1Click:Connect(function()
        pcall(function()
            animateButton(button, nil, UDim2.new(button.Size.X.Scale, button.Size.X.Offset + 5, 
                                                button.Size.Y.Scale, button.Size.Y.Offset + 2))
            task.wait(0.1)
            animateButton(button, nil, UDim2.new(button.Size.X.Scale, button.Size.X.Offset - 5, 
                                                button.Size.Y.Scale, button.Size.Y.Offset - 2))
        end)
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- FISHING LOGIC (Android Compatible)
-- ═══════════════════════════════════════════════════════════════

-- AFK 1 System (Simple)
local function startAFK1()
    if FishingState.AFK1.active then return end
    
    FishingState.AFK1.active = true
    FishingState.AFK1.startTime = tick()
    FishingState.AFK1.fishCount = 0
    
    Notify("AFK 1 Started", "🎣 Simple fishing mode activated!")
    
    -- Update UI
    AFK1Toggle.Text = "ON"
    animateButton(AFK1Toggle, Color3.fromRGB(50, 200, 50))
    
    -- Simple fishing loop
    FishingState.AFK1.connection = task.spawn(function()
        while FishingState.AFK1.active do
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                
                local success = pcall(function()
                    if remotesFound and Remotes.RequestFishing then
                        Remotes.RequestFishing:InvokeServer()
                        task.wait(0.1)
                        
                        if Remotes.ChargeRod then
                            Remotes.ChargeRod:InvokeServer(100)
                        end
                        
                        task.wait(0.5)
                        
                        if Remotes.FishingComplete then
                            Remotes.FishingComplete:FireServer()
                        end
                        
                        FishingState.AFK1.fishCount = FishingState.AFK1.fishCount + 1
                    else
                        -- Demo mode - simulate fishing
                        FishingState.AFK1.fishCount = FishingState.AFK1.fishCount + 1
                        print("🎣 AFK1 Demo: Fish caught #" .. FishingState.AFK1.fishCount)
                    end
                end)
                
                if not success then
                    print("❌ AFK1: Fishing attempt failed")
                end
            end
            
            task.wait(remotesFound and 0.4 or 1) -- Slower in demo mode
        end
    end)
end

local function stopAFK1()
    if not FishingState.AFK1.active then return end
    
    FishingState.AFK1.active = false
    
    if FishingState.AFK1.connection then
        task.cancel(FishingState.AFK1.connection)
        FishingState.AFK1.connection = nil
    end
    
    local sessionTime = tick() - FishingState.AFK1.startTime
    
    -- Update UI
    AFK1Toggle.Text = "OFF"
    animateButton(AFK1Toggle, Color3.fromRGB(200, 50, 50))
    
    Notify("AFK 1 Stopped", 
        string.format("🎣 Session: %.1f min\n🐟 Fish: %d", 
        sessionTime / 60, FishingState.AFK1.fishCount))
end

-- AFK 2 System (Advanced)
local function getRandomDelay(min, max)
    return min + (math.random() * (max - min))
end

local function startAFK2()
    if FishingState.AFK2.active then return end
    
    FishingState.AFK2.active = true
    FishingState.AFK2.startTime = tick()
    FishingState.AFK2.fishCount = 0
    FishingState.AFK2.perfectCasts = 0
    FishingState.AFK2.normalCasts = 0
    
    Notify("AFK 2 Started", "⚡ Advanced fishing activated!\n🤖 AI systems online")
    
    -- Update UI
    AFK2Toggle.Text = "ON"
    animateButton(AFK2Toggle, Color3.fromRGB(50, 200, 50))
    
    -- Advanced fishing loop
    FishingState.AFK2.connection = task.spawn(function()
        while FishingState.AFK2.active do
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                
                local success = pcall(function()
                    if remotesFound and Remotes.RequestFishing then
                        Remotes.RequestFishing:InvokeServer()
                        
                        -- Smart delay
                        local delay = getRandomDelay(0.3, 0.7)
                        task.wait(delay)
                        
                        -- Smart casting (70% perfect, 30% random)
                        if math.random(100) <= 70 then
                            -- Perfect cast
                            if Remotes.ChargeRod then
                                Remotes.ChargeRod:InvokeServer(100)
                            end
                            FishingState.AFK2.perfectCasts = FishingState.AFK2.perfectCasts + 1
                        else
                            -- Random cast
                            if Remotes.ChargeRod then
                                Remotes.ChargeRod:InvokeServer(math.random(60, 95))
                            end
                            FishingState.AFK2.normalCasts = FishingState.AFK2.normalCasts + 1
                        end
                        
                        task.wait(0.5)
                        
                        if Remotes.FishingComplete then
                            Remotes.FishingComplete:FireServer()
                        end
                        
                        FishingState.AFK2.fishCount = FishingState.AFK2.fishCount + 1
                    else
                        -- Demo mode - simulate advanced fishing
                        if math.random(100) <= 70 then
                            FishingState.AFK2.perfectCasts = FishingState.AFK2.perfectCasts + 1
                        else
                            FishingState.AFK2.normalCasts = FishingState.AFK2.normalCasts + 1
                        end
                        FishingState.AFK2.fishCount = FishingState.AFK2.fishCount + 1
                        print("⚡ AFK2 Demo: Advanced fish caught #" .. FishingState.AFK2.fishCount)
                    end
                end)
                
                if not success then
                    print("❌ AFK2: Advanced fishing attempt failed")
                end
            end
            
            -- Variable delay for humanization
            local nextDelay = remotesFound and getRandomDelay(0.8, 1.2) or 1.5
            task.wait(nextDelay)
        end
    end)
end

local function stopAFK2()
    if not FishingState.AFK2.active then return end
    
    FishingState.AFK2.active = false
    
    if FishingState.AFK2.connection then
        task.cancel(FishingState.AFK2.connection)
        FishingState.AFK2.connection = nil
    end
    
    local sessionTime = tick() - FishingState.AFK2.startTime
    local perfectRate = FishingState.AFK2.perfectCasts + FishingState.AFK2.normalCasts > 0 and 
        (FishingState.AFK2.perfectCasts / (FishingState.AFK2.perfectCasts + FishingState.AFK2.normalCasts) * 100) or 0
    
    -- Update UI
    AFK2Toggle.Text = "OFF"
    animateButton(AFK2Toggle, Color3.fromRGB(200, 50, 50))
    
    Notify("AFK 2 Stopped", 
        string.format("⚡ Session: %.1f min\n🐟 Fish: %d\n⭐ Perfect: %.1f%%", 
        sessionTime / 60, FishingState.AFK2.fishCount, perfectRate))
end

print("✅ Fishing systems configured!")
print("🔧 Next: Setting up event handlers...")

-- ═══════════════════════════════════════════════════════════════
-- EVENT HANDLERS (Android Compatible)
-- ═══════════════════════════════════════════════════════════════

-- Close button functionality
CloseBtn.MouseButton1Click:Connect(function()
    animateButton(CloseBtn, Color3.fromRGB(255, 100, 100))
    
    Notify("Closing UI", "👋 Thanks for using BOT FISH IT V1!")
    
    task.wait(0.5)
    
    pcall(function()
        -- Stop all fishing activities
        if FishingState.AFK1.active then stopAFK1() end
        if FishingState.AFK2.active then stopAFK2() end
        
        -- Destroy UI
        ScreenGui:Destroy()
    end)
end)

-- Minimize button functionality
MinimizeBtn.MouseButton1Click:Connect(function()
    animateButton(MinimizeBtn, Color3.fromRGB(90, 90, 90))
    toggleUI()
end)

-- Floating button functionality
FloatingBtn.MouseButton1Click:Connect(function()
    animateButton(FloatingBtn, Color3.fromRGB(60, 60, 60))
    toggleUI()
end)

-- AFK 1 Toggle with enhanced feedback
AFK1Toggle.MouseButton1Click:Connect(function()
    addClickEffect(AFK1Toggle)
    
    if FishingState.AFK1.active then
        stopAFK1()
    else
        -- Stop AFK2 if running (mutual exclusive)
        if FishingState.AFK2.active then
            stopAFK2()
        end
        startAFK1()
    end
end)

-- AFK 2 Toggle with enhanced feedback
AFK2Toggle.MouseButton1Click:Connect(function()
    addClickEffect(AFK2Toggle)
    
    if FishingState.AFK2.active then
        stopAFK2()
    else
        -- Stop AFK1 if running (mutual exclusive)
        if FishingState.AFK1.active then
            stopAFK1()
        end
        startAFK2()
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- STATUS DISPLAY & LIVE UPDATES
-- ═══════════════════════════════════════════════════════════════

-- Status display in the method column
local function updateStatus()
    pcall(function()
        -- Update AFK1 status
        if FishingState.AFK1.active then
            AFK1Method.Text = "Running..."
            AFK1Method.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            AFK1Method.Text = "Simple"
            AFK1Method.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        
        -- Update AFK2 status
        if FishingState.AFK2.active then
            AFK2Method.Text = "AI Active"
            AFK2Method.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            AFK2Method.Text = "Advanced"
            AFK2Method.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end)
end

-- Live statistics update
task.spawn(function()
    while ScreenGui and ScreenGui.Parent do
        task.wait(1)
        updateStatus()
        
        -- Update fish counts in labels (visual enhancement)
        pcall(function()
            if FishingState.AFK1.active and FishingState.AFK1.fishCount > 0 then
                AFK1Label.Text = "AFK 1 (" .. FishingState.AFK1.fishCount .. ")"
            else
                AFK1Label.Text = "AFK 1"
            end
            
            if FishingState.AFK2.active and FishingState.AFK2.fishCount > 0 then
                AFK2Label.Text = "AFK 2 (" .. FishingState.AFK2.fishCount .. ")"
            else
                AFK2Label.Text = "AFK 2"
            end
        end)
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- INITIALIZATION & FINAL SETUP
-- ═══════════════════════════════════════════════════════════════

-- Initial UI state
updateStatus()

-- Add click effects to all buttons
addClickEffect(AFK1Toggle)
addClickEffect(AFK2Toggle)
addClickEffect(MinimizeBtn)
addClickEffect(CloseBtn)
addClickEffect(FloatingBtn)

-- Android-specific optimizations
if isMobile then
    -- Disable some animations for better performance on mobile
    print("📱 Mobile optimizations applied")
    
    -- Add touch feedback
    local function addTouchFeedback(button)
        button.TouchTap:Connect(function()
            pcall(function()
                local originalSize = button.Size
                button.Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset + 3, 
                                       originalSize.Y.Scale, originalSize.Y.Offset + 3)
                task.wait(0.1)
                button.Size = originalSize
            end)
        end)
    end
    
    -- Apply touch feedback to interactive elements
    addTouchFeedback(AFK1Toggle)
    addTouchFeedback(AFK2Toggle)
    addTouchFeedback(MinimizeBtn)
    addTouchFeedback(CloseBtn)
    addTouchFeedback(FloatingBtn)
end

-- Final success notification
Notify("BOT FISH IT V1 Ready!", 
    string.format("✅ UI loaded successfully!\n\n" ..
    "📱 Platform: %s\n" ..
    "🎣 AFK 1: Simple & Fast\n" ..
    "⚡ AFK 2: Advanced AI\n" ..
    "%s\n\n" ..
    "👆 Click toggles to start fishing!",
    isMobile and "Mobile/Android" or "Desktop",
    remotesFound and "🎮 Game remotes: Connected" or "🔧 Demo mode: Active"))

-- Console output
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("✅ BOT FISH IT V1 - SUCCESSFULLY LOADED!")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("📱 Platform:", isMobile and "Mobile/Android" or "Desktop")
print("🖥️ Screen Size:", screenSize.X .. "x" .. screenSize.Y)
print("🎮 Game Remotes:", remotesFound and "Connected" or "Demo Mode")
print("🔧 Features:")
print("  • Modern table-based UI")
print("  • Android touch optimization")
print("  • Minimize & floating button")
print("  • Two AFK fishing modes")
print("  • Live statistics")
print("  • Smooth animations")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("🎣 Ready to fish! Click AFK 1 or AFK 2 to start!")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            Icon = "rbxassetid://6023426923"
        })
    end)
    print("📢", title, "-", text)
end

-- ═══════════════════════════════════════════════════════════════
-- MODERN UI CREATION
-- ═══════════════════════════════════════════════════════════════

-- Cleanup existing UI
if LocalPlayer.PlayerGui:FindFirstChild("BotFishItV1") then
    LocalPlayer.PlayerGui.BotFishItV1:Destroy()
end

-- Create main ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BotFishItV1"
ScreenGui.Parent = LocalPlayer.PlayerGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

-- Main Frame (Table Container)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
MainFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BorderSizePixel = 2
MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 400, 0, 250)
MainFrame.Active = true
MainFrame.Draggable = true

-- Add corner radius
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Add gradient background
local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 50, 50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 35))
}
Gradient.Rotation = 45
Gradient.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Parent = MainFrame
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, 40)

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

-- Title gradient
local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 25))
}
TitleGradient.Rotation = 90
TitleGradient.Parent = TitleBar

-- Title Text
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = TitleBar
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.Size = UDim2.new(1, -80, 1, 0)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Text = "BOT FISH IT V1"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 18
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Minimize Button
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Name = "MinimizeBtn"
MinimizeBtn.Parent = TitleBar
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.Position = UDim2.new(1, -65, 0.5, -10)
MinimizeBtn.Size = UDim2.new(0, 25, 0, 20)
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 14

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 4)
MinimizeCorner.Parent = MinimizeBtn

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Parent = TitleBar
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.BorderSizePixel = 0
CloseBtn.Position = UDim2.new(1, -35, 0.5, -10)
CloseBtn.Size = UDim2.new(0, 25, 0, 20)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 16

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = CloseBtn

-- ═══════════════════════════════════════════════════════════════
-- FINAL INITIALIZATION & STATUS REPORTING
-- ═══════════════════════════════════════════════════════════════

-- Force UI visibility check
task.wait(0.5) -- Give UI time to load

local function verifyUIVisible()
    local isVisible = false
    
    -- Check if ScreenGui is properly attached and visible
    if ScreenGui and ScreenGui.Parent then
        print("✅ ScreenGui parent:", ScreenGui.Parent.Name)
        
        if MainFrame and MainFrame.Parent then
            print("✅ MainFrame created and attached")
            isVisible = true
            MainFrame.Visible = true -- Force visible
            
            -- Force bring to front
            pcall(function()
                if ScreenGui.Parent == LocalPlayer.PlayerGui then
                    ScreenGui.DisplayOrder = 999999
                end
            end)
        else
            print("❌ MainFrame not properly created")
        end
    else
        print("❌ ScreenGui not properly attached")
    end
    
    return isVisible
end

-- Verify UI is visible
local uiVisible = verifyUIVisible()

-- Mark UI as loaded
UIState.isLoaded = uiVisible

-- Check Android/Mobile environment
local isMobile = UserInputService and UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
if isMobile then
    print("📱 Android/Mobile environment detected - UI optimized")
    Notify("Mobile UI Ready", "📱 Android-compatible UI loaded!")
else
    print("🖥️ Desktop environment detected")
    Notify("Desktop UI Ready", "🖥️ Desktop UI loaded!")
end

-- Final comprehensive status report
print("\n🔧 COMPLETE SYSTEM STATUS:")
print("  ▪ Players:", Players and "✅" or "❌")
print("  ▪ ReplicatedStorage:", ReplicatedStorage and "✅" or "❌")
print("  ▪ UserInputService:", UserInputService and "✅" or "❌")
print("  ▪ TweenService:", TweenService and "✅" or "❌")
print("  ▪ UI Visible:", uiVisible and "✅" or "❌")
print("  ▪ Mobile Device:", isMobile and "✅" or "❌")

-- Report remote events status with count
local remoteCount = 0
for name, remote in pairs(Remotes) do
    if remote then remoteCount = remoteCount + 1 end
end

if remoteCount > 0 then
    print("  ▪ Remote Events: ✅ " .. remoteCount .. " connected")
else
    print("  ▪ Remote Events: ⚠️ Demo mode active")
end

-- Final success/failure report
if uiVisible then
    print("\n✅ BOT FISH IT V1 - Successfully loaded and ready!")
    print("🎣 Features: Modern table UI, minimize/floating button, dual AFK systems")
    print("📱 Android optimized with responsive sizing and touch controls")
    print("� Ready to use on all platforms including mobile exploits!")
    
    -- Show welcome message
    task.wait(1)
    Notify("BOT FISH IT V1", 
        "🔥 Successfully loaded!\n\n" ..
        "🎣 AFK 1: Simple & Fast\n" ..
        "⚡ AFK 2: Advanced & AI\n\n" ..
        "Click minimize (➖) to use floating button\n" ..
        "Toggle ON/OFF to start fishing!")
else
    print("\n❌ BOT FISH IT V1 - UI loading failed!")
    print("Please check console for errors and try reloading the script")
    
    -- Try emergency notification
    Notify("UI Load Failed", "❌ UI could not be displayed\nCheck console for details")
end
