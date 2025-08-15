--[[
    UILibrary_Rayfield.lua - Rayfield-powered UI Library
    
    A wrapper around Rayfield UI Library that provides our custom API
    while using Rayfield's proven Delta Android compatibility.
    
    Features:
    • Uses Rayfield as backend (Delta Android compatible)
    • Maintains our custom API for consistency
    • Automatic fallback to simple UI if Rayfield fails
    • Mobile optimized
    
    Developer: MELLISAEFFENDY
    Version: 2.0 (Rayfield Edition)
    
    Usage:
    local UILib = loadstring(game:HttpGet("RAW_GITHUB_URL"))()
    local window = UILib:CreateWindow({...})
--]]

-- ═══════════════════════════════════════════════════════════════
-- RAYFIELD-POWERED UI LIBRARY
-- ═══════════════════════════════════════════════════════════════

local UILibrary = {}
UILibrary.__index = UILibrary

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ═══════════════════════════════════════════════════════════════
-- RAYFIELD LOADING
-- ═══════════════════════════════════════════════════════════════

local Rayfield = nil
local RayfieldLoaded = false

-- Load Rayfield with error handling
print("🎨 UILibrary_Rayfield: Loading Rayfield...")
local success, err = pcall(function()
    Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield", true))()
    if Rayfield then
        RayfieldLoaded = true
        print("✅ UILibrary_Rayfield: Rayfield loaded successfully!")
    else
        error("Rayfield initialization failed")
    end
end)

if not success or not RayfieldLoaded then
    warn("❌ UILibrary_Rayfield: Failed to load Rayfield:", err or "Unknown error")
    warn("📱 UILibrary_Rayfield: Will use fallback simple UI")
end

-- ═══════════════════════════════════════════════════════════════
-- WINDOW CLASS
-- ═══════════════════════════════════════════════════════════════

local Window = {}
Window.__index = Window

function Window:CreateSection(name)
    local section = {
        Name = name,
        Window = self,
        Elements = {}
    }
    
    -- If using Rayfield, create a tab
    if self.RayfieldWindow and RayfieldLoaded then
        section.RayfieldTab = self.RayfieldWindow:CreateTab(name, nil)
    end
    
    return section
end

function Window:Destroy()
    if self.RayfieldWindow then
        -- Rayfield handles its own cleanup
        print("🗑️ UILibrary_Rayfield: Rayfield window closed")
    elseif self.SimpleGUI then
        self.SimpleGUI:Destroy()
        print("🗑️ UILibrary_Rayfield: Simple UI destroyed")
    end
end

-- ═══════════════════════════════════════════════════════════════
-- UI CREATION FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

function UILibrary:CreateWindow(config)
    local window = setmetatable({}, Window)
    
    window.Title = config.Title or "UILibrary Window"
    window.Size = config.Size or UDim2.new(0.4, 0, 0.5, 0)
    window.Position = config.Position or UDim2.new(0.3, 0, 0.25, 0)
    window.Theme = config.Theme or "Dark"
    window.Draggable = config.Draggable ~= false
    
    if RayfieldLoaded and Rayfield then
        -- Create Rayfield window
        print("✨ UILibrary_Rayfield: Creating Rayfield window...")
        window.RayfieldWindow = Rayfield:CreateWindow({
            Name = window.Title,
            LoadingTitle = "UILibrary",
            LoadingSubtitle = "Powered by Rayfield",
            ConfigurationSaving = {
                Enabled = false,
            },
            Discord = {
                Enabled = false,
            },
            KeySystem = false,
        })
        
        print("✅ UILibrary_Rayfield: Rayfield window created!")
        
    else
        -- Create simple fallback UI
        print("📱 UILibrary_Rayfield: Creating simple fallback UI...")
        window:CreateSimpleUI()
    end
    
    return window
end

function Window:CreateSimpleUI()
    -- Cleanup existing GUI
    if PlayerGui:FindFirstChild("UILibrary_Simple") then
        PlayerGui.UILibrary_Simple:Destroy()
    end

    -- Create simple GUI
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "UILibrary_Simple"
    ScreenGui.Parent = PlayerGui
    ScreenGui.ResetOnSpawn = false

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = self.Position
    MainFrame.Size = self.Size
    MainFrame.Active = true
    MainFrame.Draggable = self.Draggable

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Parent = MainFrame
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.Size = UDim2.new(1, 0, 0.15, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = self.Title
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextScaled = true

    self.SimpleGUI = ScreenGui
    self.SimpleFrame = MainFrame
    self.ElementCount = 0
    
    print("✅ UILibrary_Rayfield: Simple UI created!")
end

function UILibrary:CreateButton(section, config)
    local button = {
        Text = config.Text or "Button",
        Color = config.Color or Color3.fromRGB(100, 150, 255),
        Height = config.Height or 40,
        Callback = config.Callback or function() end
    }
    
    if section.RayfieldTab and RayfieldLoaded then
        -- Create Rayfield button
        return section.RayfieldTab:CreateButton({
            Name = button.Text,
            Callback = button.Callback,
        })
        
    else
        -- Create simple button fallback
        if section.Window.SimpleFrame then
            local window = section.Window
            window.ElementCount = window.ElementCount or 0
            
            local Button = Instance.new("TextButton")
            Button.Parent = window.SimpleFrame
            Button.BackgroundColor3 = button.Color
            Button.BorderSizePixel = 0
            Button.Position = UDim2.new(0.05, 0, 0.2 + (window.ElementCount * 0.15), 0)
            Button.Size = UDim2.new(0.9, 0, 0.12, 0)
            Button.Font = Enum.Font.GothamBold
            Button.Text = button.Text
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
            Button.TextScaled = true

            local ButtonCorner = Instance.new("UICorner")
            ButtonCorner.CornerRadius = UDim.new(0, 8)
            ButtonCorner.Parent = Button

            Button.MouseButton1Click:Connect(button.Callback)
            
            window.ElementCount = window.ElementCount + 1
            return Button
        end
    end
end

function UILibrary:CreateToggle(section, config)
    local toggle = {
        Text = config.Text or "Toggle",
        Default = config.Default or false,
        Callback = config.Callback or function() end
    }
    
    if section.RayfieldTab and RayfieldLoaded then
        -- Create Rayfield toggle
        return section.RayfieldTab:CreateToggle({
            Name = toggle.Text,
            CurrentValue = toggle.Default,
            Flag = toggle.Text:gsub("%s+", ""),
            Callback = toggle.Callback,
        })
        
    else
        -- Create simple toggle fallback
        if section.Window.SimpleFrame then
            local window = section.Window
            window.ElementCount = window.ElementCount or 0
            
            local toggleState = toggle.Default
            
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Parent = window.SimpleFrame
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            ToggleFrame.BorderSizePixel = 0
            ToggleFrame.Position = UDim2.new(0.05, 0, 0.2 + (window.ElementCount * 0.15), 0)
            ToggleFrame.Size = UDim2.new(0.9, 0, 0.12, 0)

            local ToggleCorner = Instance.new("UICorner")
            ToggleCorner.CornerRadius = UDim.new(0, 8)
            ToggleCorner.Parent = ToggleFrame

            local ToggleLabel = Instance.new("TextLabel")
            ToggleLabel.Parent = ToggleFrame
            ToggleLabel.BackgroundTransparency = 1
            ToggleLabel.Position = UDim2.new(0.05, 0, 0, 0)
            ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
            ToggleLabel.Font = Enum.Font.Gotham
            ToggleLabel.Text = toggle.Text
            ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            ToggleLabel.TextScaled = true
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left

            local ToggleButton = Instance.new("TextButton")
            ToggleButton.Parent = ToggleFrame
            ToggleButton.BackgroundColor3 = toggleState and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(60, 60, 70)
            ToggleButton.BorderSizePixel = 0
            ToggleButton.Position = UDim2.new(0.8, 0, 0.2, 0)
            ToggleButton.Size = UDim2.new(0.15, 0, 0.6, 0)
            ToggleButton.Font = Enum.Font.GothamBold
            ToggleButton.Text = toggleState and "ON" or "OFF"
            ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            ToggleButton.TextScaled = true

            local ButtonCorner = Instance.new("UICorner")
            ButtonCorner.CornerRadius = UDim.new(0, 4)
            ButtonCorner.Parent = ToggleButton

            ToggleButton.MouseButton1Click:Connect(function()
                toggleState = not toggleState
                ToggleButton.BackgroundColor3 = toggleState and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(60, 60, 70)
                ToggleButton.Text = toggleState and "ON" or "OFF"
                toggle.Callback(toggleState)
            end)
            
            window.ElementCount = window.ElementCount + 1
            return {
                SetValue = function(value)
                    toggleState = value
                    ToggleButton.BackgroundColor3 = toggleState and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(60, 60, 70)
                    ToggleButton.Text = toggleState and "ON" or "OFF"
                end
            }
        end
    end
end

function UILibrary:CreateLabel(section, config)
    local label = {
        Text = config.Text or "Label",
        Height = config.Height or 30
    }
    
    if section.RayfieldTab and RayfieldLoaded then
        -- Create Rayfield paragraph (similar to label)
        return section.RayfieldTab:CreateParagraph({
            Title = "Info",
            Content = label.Text
        })
        
    else
        -- Create simple label fallback
        if section.Window.SimpleFrame then
            local window = section.Window
            window.ElementCount = window.ElementCount or 0
            
            local Label = Instance.new("TextLabel")
            Label.Parent = window.SimpleFrame
            Label.BackgroundTransparency = 1
            Label.Position = UDim2.new(0.05, 0, 0.2 + (window.ElementCount * 0.15), 0)
            Label.Size = UDim2.new(0.9, 0, 0.12, 0)
            Label.Font = Enum.Font.Gotham
            Label.Text = label.Text
            Label.TextColor3 = Color3.fromRGB(200, 200, 200)
            Label.TextScaled = true
            Label.TextXAlignment = Enum.TextXAlignment.Left

            window.ElementCount = window.ElementCount + 1
            
            return {
                SetText = function(text)
                    Label.Text = text
                end,
                Text = Label.Text
            }
        end
    end
end

-- ═══════════════════════════════════════════════════════════════
-- NOTIFICATIONS (Using Rayfield if available)
-- ═══════════════════════════════════════════════════════════════

function UILibrary:CreateNotification(config)
    local notification = {
        Title = config.Title or "Notification",
        Content = config.Content or "No content",
        Duration = config.Duration or 3,
        Image = config.Image
    }
    
    if RayfieldLoaded and Rayfield then
        Rayfield:Notify({
            Title = notification.Title,
            Content = notification.Content,
            Duration = notification.Duration,
            Image = notification.Image
        })
    else
        -- Simple notification fallback
        print("📢 " .. notification.Title .. ": " .. notification.Content)
    end
end

-- ═══════════════════════════════════════════════════════════════
-- RETURN LIBRARY
-- ═══════════════════════════════════════════════════════════════

print("✅ UILibrary_Rayfield: Library loaded successfully!")
print("   🎨 Backend:", RayfieldLoaded and "Rayfield" or "Simple UI")
print("   📱 Delta Compatible:", RayfieldLoaded and "✅ Yes" or "⚠️ Fallback")

return UILibrary
