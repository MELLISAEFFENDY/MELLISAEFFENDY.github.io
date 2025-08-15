--[[
    UILibrary.lua - Custom UI Library for Upgrade.lua
    
    A lightweight, modern UI library designed specifically for Roblox scripts
    Features:
    • Modern design with smooth animations
    • Easy-to-use API
    • Customizable themes
    • Auto-cleanup system
    • Mobile responsive
    
    Developer: MELLISAEFFENDY
    Version: 1.0
    
    Usage:
    local UILib = loadstring(game:HttpGet("RAW_GITHUB_URL"))()
    local window = UILib:CreateWindow({...})
--]]

-- ═══════════════════════════════════════════════════════════════
-- UI LIBRARY CORE
-- ═══════════════════════════════════════════════════════════════

local UILibrary = {}
UILibrary.__index = UILibrary

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ═══════════════════════════════════════════════════════════════
-- THEMES & CONFIGURATION
-- ═══════════════════════════════════════════════════════════════

local Themes = {
    Dark = {
        Background = Color3.fromRGB(25, 25, 30),
        Secondary = Color3.fromRGB(35, 35, 40),
        Accent = Color3.fromRGB(45, 45, 55),
        Primary = Color3.fromRGB(100, 150, 255),
        Success = Color3.fromRGB(80, 200, 120),
        Warning = Color3.fromRGB(255, 180, 60),
        Danger = Color3.fromRGB(255, 100, 100),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(200, 200, 200),
        Border = Color3.fromRGB(60, 60, 70)
    },
    Light = {
        Background = Color3.fromRGB(240, 240, 245),
        Secondary = Color3.fromRGB(230, 230, 235),
        Accent = Color3.fromRGB(220, 220, 225),
        Primary = Color3.fromRGB(50, 100, 200),
        Success = Color3.fromRGB(40, 150, 80),
        Warning = Color3.fromRGB(200, 140, 20),
        Danger = Color3.fromRGB(200, 50, 50),
        Text = Color3.fromRGB(20, 20, 25),
        TextSecondary = Color3.fromRGB(80, 80, 85),
        Border = Color3.fromRGB(180, 180, 190)
    }
}

local DefaultConfig = {
    Theme = "Dark",
    AnimationSpeed = 0.3,
    CornerRadius = 8,
    Padding = 10,
    ButtonHeight = 35,
    SectionSpacing = 10
}

-- ═══════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

local function createTween(instance, properties, duration)
    duration = duration or DefaultConfig.AnimationSpeed
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    return TweenService:Create(instance, tweenInfo, properties)
end

local function addCornerRadius(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or DefaultConfig.CornerRadius)
    corner.Parent = instance
    return corner
end

local function addPadding(instance, padding)
    local uiPadding = Instance.new("UIPadding")
    local paddingValue = padding or DefaultConfig.Padding
    uiPadding.PaddingTop = UDim.new(0, paddingValue)
    uiPadding.PaddingBottom = UDim.new(0, paddingValue)
    uiPadding.PaddingLeft = UDim.new(0, paddingValue)
    uiPadding.PaddingRight = UDim.new(0, paddingValue)
    uiPadding.Parent = instance
    return uiPadding
end

local function createNotification(title, message, duration, notifType)
    game.StarterGui:SetCore("SendNotification", {
        Title = title or "Notification";
        Text = message or "";
        Duration = duration or 3;
        Icon = notifType == "Success" and "rbxassetid://6031302932" or 
               notifType == "Warning" and "rbxassetid://6031154871" or
               notifType == "Error" and "rbxassetid://6031075938" or nil;
    })
end

-- ═══════════════════════════════════════════════════════════════
-- WINDOW CLASS
-- ═══════════════════════════════════════════════════════════════

local Window = {}
Window.__index = Window

function Window:new(config)
    local self = setmetatable({}, Window)
    
    -- Configuration
    self.config = config or {}
    self.title = self.config.Title or "UI Library"
    self.size = self.config.Size or UDim2.new(0.4, 0, 0.5, 0)
    self.position = self.config.Position or UDim2.new(0.3, 0, 0.25, 0)
    self.theme = Themes[self.config.Theme or "Dark"]
    self.draggable = self.config.Draggable ~= false
    
    -- State
    self.isVisible = true
    self.isMinimized = false
    self.sections = {}
    self.connections = {}
    
    -- Create GUI
    self:createMainGui()
    self:setupEvents()
    
    return self
end

function Window:createMainGui()
    -- Cleanup existing
    local existing = PlayerGui:FindFirstChild("UILibrary_" .. self.title:gsub("%s+", ""))
    if existing then existing:Destroy() end
    
    -- Screen GUI
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "UILibrary_" .. self.title:gsub("%s+", "")
    self.screenGui.Parent = PlayerGui
    self.screenGui.ResetOnSpawn = false
    self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Frame
    self.mainFrame = Instance.new("Frame")
    self.mainFrame.Name = "MainFrame"
    self.mainFrame.Parent = self.screenGui
    self.mainFrame.BackgroundColor3 = self.theme.Background
    self.mainFrame.BorderSizePixel = 0
    self.mainFrame.Position = self.position
    self.mainFrame.Size = self.size
    self.mainFrame.Active = true
    self.mainFrame.ClipsDescendants = true
    
    if self.draggable then
        self.mainFrame.Draggable = true
    end
    
    addCornerRadius(self.mainFrame, 12)
    
    -- Title Bar
    self.titleBar = Instance.new("Frame")
    self.titleBar.Name = "TitleBar"
    self.titleBar.Parent = self.mainFrame
    self.titleBar.BackgroundColor3 = self.theme.Secondary
    self.titleBar.BorderSizePixel = 0
    self.titleBar.Size = UDim2.new(1, 0, 0, 45)
    
    addCornerRadius(self.titleBar, 12)
    
    -- Title fix for rounded bottom
    local titleFix = Instance.new("Frame")
    titleFix.Parent = self.titleBar
    titleFix.BackgroundColor3 = self.theme.Secondary
    titleFix.BorderSizePixel = 0
    titleFix.Position = UDim2.new(0, 0, 0.7, 0)
    titleFix.Size = UDim2.new(1, 0, 0.3, 0)
    
    -- Title Text
    self.titleText = Instance.new("TextLabel")
    self.titleText.Name = "TitleText"
    self.titleText.Parent = self.titleBar
    self.titleText.BackgroundTransparency = 1
    self.titleText.Position = UDim2.new(0, 15, 0, 0)
    self.titleText.Size = UDim2.new(0.7, 0, 1, 0)
    self.titleText.Font = Enum.Font.GothamBold
    self.titleText.Text = self.title
    self.titleText.TextColor3 = self.theme.Text
    self.titleText.TextScaled = true
    self.titleText.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Control Buttons Container
    local controlsFrame = Instance.new("Frame")
    controlsFrame.Name = "ControlsFrame"
    controlsFrame.Parent = self.titleBar
    controlsFrame.BackgroundTransparency = 1
    controlsFrame.Position = UDim2.new(0.75, 0, 0.15, 0)
    controlsFrame.Size = UDim2.new(0.23, 0, 0.7, 0)
    
    local controlsLayout = Instance.new("UIListLayout")
    controlsLayout.Parent = controlsFrame
    controlsLayout.FillDirection = Enum.FillDirection.Horizontal
    controlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    controlsLayout.Padding = UDim.new(0, 5)
    
    -- Minimize Button
    self.minimizeButton = Instance.new("TextButton")
    self.minimizeButton.Name = "MinimizeButton"
    self.minimizeButton.Parent = controlsFrame
    self.minimizeButton.BackgroundColor3 = self.theme.Warning
    self.minimizeButton.BorderSizePixel = 0
    self.minimizeButton.Size = UDim2.new(0, 30, 1, 0)
    self.minimizeButton.Font = Enum.Font.GothamBold
    self.minimizeButton.Text = "−"
    self.minimizeButton.TextColor3 = self.theme.Text
    self.minimizeButton.TextScaled = true
    
    addCornerRadius(self.minimizeButton, 6)
    
    -- Close Button
    self.closeButton = Instance.new("TextButton")
    self.closeButton.Name = "CloseButton"
    self.closeButton.Parent = controlsFrame
    self.closeButton.BackgroundColor3 = self.theme.Danger
    self.closeButton.BorderSizePixel = 0
    self.closeButton.Size = UDim2.new(0, 30, 1, 0)
    self.closeButton.Font = Enum.Font.GothamBold
    self.closeButton.Text = "✕"
    self.closeButton.TextColor3 = self.theme.Text
    self.closeButton.TextScaled = true
    
    addCornerRadius(self.closeButton, 6)
    
    -- Content Frame
    self.contentFrame = Instance.new("ScrollingFrame")
    self.contentFrame.Name = "ContentFrame"
    self.contentFrame.Parent = self.mainFrame
    self.contentFrame.BackgroundTransparency = 1
    self.contentFrame.Position = UDim2.new(0, 0, 0, 50)
    self.contentFrame.Size = UDim2.new(1, 0, 1, -50)
    self.contentFrame.ScrollBarThickness = 4
    self.contentFrame.ScrollBarImageColor3 = self.theme.Primary
    self.contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.contentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    addPadding(self.contentFrame, 15)
    
    -- Content Layout
    self.contentLayout = Instance.new("UIListLayout")
    self.contentLayout.Parent = self.contentFrame
    self.contentLayout.Padding = UDim.new(0, DefaultConfig.SectionSpacing)
    self.contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
end

function Window:setupEvents()
    -- Close button
    self.connections.close = self.closeButton.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
    
    -- Minimize button
    self.connections.minimize = self.minimizeButton.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    -- Hover effects
    self:addHoverEffect(self.closeButton, self.theme.Danger, Color3.fromRGB(255, 120, 120))
    self:addHoverEffect(self.minimizeButton, self.theme.Warning, Color3.fromRGB(255, 200, 100))
end

function Window:addHoverEffect(button, normalColor, hoverColor)
    self.connections[button.Name .. "_hover"] = button.MouseEnter:Connect(function()
        createTween(button, {BackgroundColor3 = hoverColor}, 0.2):Play()
    end)
    
    self.connections[button.Name .. "_leave"] = button.MouseLeave:Connect(function()
        createTween(button, {BackgroundColor3 = normalColor}, 0.2):Play()
    end)
end

function Window:CreateSection(title)
    local section = {}
    
    -- Section Frame
    local sectionFrame = Instance.new("Frame")
    sectionFrame.Name = "Section_" .. title:gsub("%s+", "")
    sectionFrame.Parent = self.contentFrame
    sectionFrame.BackgroundColor3 = self.theme.Secondary
    sectionFrame.BorderSizePixel = 0
    sectionFrame.Size = UDim2.new(1, 0, 0, 40) -- Will auto-resize
    sectionFrame.AutomaticSize = Enum.AutomaticSize.Y
    sectionFrame.LayoutOrder = #self.sections + 1
    
    addCornerRadius(sectionFrame, 8)
    addPadding(sectionFrame, 12)
    
    -- Section Layout
    local sectionLayout = Instance.new("UIListLayout")
    sectionLayout.Parent = sectionFrame
    sectionLayout.Padding = UDim.new(0, 8)
    sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- Section Title
    if title and title ~= "" then
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Name = "SectionTitle"
        titleLabel.Parent = sectionFrame
        titleLabel.BackgroundTransparency = 1
        titleLabel.Size = UDim2.new(1, 0, 0, 25)
        titleLabel.Font = Enum.Font.GothamSemibold
        titleLabel.Text = title
        titleLabel.TextColor3 = self.theme.Primary
        titleLabel.TextScaled = true
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.LayoutOrder = 0
    end
    
    section.frame = sectionFrame
    section.layout = sectionLayout
    section.theme = self.theme
    
    table.insert(self.sections, section)
    return section
end

function Window:Toggle()
    self.isMinimized = not self.isMinimized
    
    local targetSize = self.isMinimized and 
        UDim2.new(self.size.X.Scale, self.size.X.Offset, 0, 45) or 
        self.size
    
    createTween(self.mainFrame, {Size = targetSize}):Play()
    self.minimizeButton.Text = self.isMinimized and "+" or "−"
end

function Window:Show()
    self.isVisible = true
    self.mainFrame.Visible = true
    createTween(self.mainFrame, {Size = self.size}):Play()
end

function Window:Hide()
    self.isVisible = false
    createTween(self.mainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.2):Play()
    task.wait(0.2)
    self.mainFrame.Visible = false
end

function Window:Destroy()
    -- Cleanup connections
    for _, connection in pairs(self.connections) do
        if connection then
            connection:Disconnect()
        end
    end
    
    -- Animate out
    createTween(self.mainFrame, {
        Size = UDim2.new(0, 0, 0, 0),
        Position = self.mainFrame.Position + UDim2.new(0, self.mainFrame.AbsoluteSize.X/2, 0, self.mainFrame.AbsoluteSize.Y/2)
    }, 0.3):Play()
    
    task.wait(0.3)
    self.screenGui:Destroy()
end

-- ═══════════════════════════════════════════════════════════════
-- UI COMPONENTS
-- ═══════════════════════════════════════════════════════════════

function UILibrary:CreateButton(section, config)
    local button = Instance.new("TextButton")
    button.Name = "Button_" .. (config.Text or "Button"):gsub("%s+", "")
    button.Parent = section.frame
    button.BackgroundColor3 = config.Color or section.theme.Primary
    button.BorderSizePixel = 0
    button.Size = UDim2.new(1, 0, 0, config.Height or DefaultConfig.ButtonHeight)
    button.Font = Enum.Font.GothamSemibold
    button.Text = config.Text or "Button"
    button.TextColor3 = section.theme.Text
    button.TextScaled = true
    button.LayoutOrder = 999
    
    addCornerRadius(button, 6)
    
    -- Hover effect
    local originalColor = button.BackgroundColor3
    local hoverColor = Color3.new(
        math.min(originalColor.R + 0.1, 1),
        math.min(originalColor.G + 0.1, 1),
        math.min(originalColor.B + 0.1, 1)
    )
    
    button.MouseEnter:Connect(function()
        createTween(button, {BackgroundColor3 = hoverColor}, 0.2):Play()
    end)
    
    button.MouseLeave:Connect(function()
        createTween(button, {BackgroundColor3 = originalColor}, 0.2):Play()
    end)
    
    if config.Callback then
        button.MouseButton1Click:Connect(config.Callback)
    end
    
    return button
end

function UILibrary:CreateToggle(section, config)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = "Toggle_" .. (config.Text or "Toggle"):gsub("%s+", "")
    toggleFrame.Parent = section.frame
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Size = UDim2.new(1, 0, 0, 35)
    toggleFrame.LayoutOrder = 999
    
    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Parent = toggleFrame
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Position = UDim2.new(0, 0, 0, 0)
    toggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    toggleLabel.Font = Enum.Font.Gotham
    toggleLabel.Text = config.Text or "Toggle"
    toggleLabel.TextColor3 = section.theme.Text
    toggleLabel.TextScaled = true
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Parent = toggleFrame
    toggleButton.BackgroundColor3 = config.Default and section.theme.Success or section.theme.Accent
    toggleButton.BorderSizePixel = 0
    toggleButton.Position = UDim2.new(0.75, 0, 0.1, 0)
    toggleButton.Size = UDim2.new(0.2, 0, 0.8, 0)
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.Text = config.Default and "ON" or "OFF"
    toggleButton.TextColor3 = section.theme.Text
    toggleButton.TextScaled = true
    
    addCornerRadius(toggleButton, 4)
    
    local isToggled = config.Default or false
    
    toggleButton.MouseButton1Click:Connect(function()
        isToggled = not isToggled
        
        local newColor = isToggled and section.theme.Success or section.theme.Accent
        local newText = isToggled and "ON" or "OFF"
        
        createTween(toggleButton, {BackgroundColor3 = newColor}, 0.2):Play()
        toggleButton.Text = newText
        
        if config.Callback then
            config.Callback(isToggled)
        end
    end)
    
    return {
        Frame = toggleFrame,
        Button = toggleButton,
        GetValue = function() return isToggled end,
        SetValue = function(value)
            isToggled = value
            local newColor = isToggled and section.theme.Success or section.theme.Accent
            local newText = isToggled and "ON" or "OFF"
            toggleButton.BackgroundColor3 = newColor
            toggleButton.Text = newText
        end
    }
end

function UILibrary:CreateLabel(section, config)
    local label = Instance.new("TextLabel")
    label.Name = "Label_" .. (config.Text or "Label"):gsub("%s+", "")
    label.Parent = section.frame
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, config.Height or 25)
    label.Font = Enum.Font.Gotham
    label.Text = config.Text or "Label"
    label.TextColor3 = config.Color or section.theme.TextSecondary
    label.TextScaled = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.LayoutOrder = 999
    
    return {
        Label = label,
        SetText = function(text) label.Text = text end,
        SetColor = function(color) label.TextColor3 = color end
    }
end

-- ═══════════════════════════════════════════════════════════════
-- MAIN LIBRARY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

function UILibrary:CreateWindow(config)
    return Window:new(config)
end

function UILibrary:Notification(title, message, duration, notifType)
    createNotification(title, message, duration, notifType)
end

function UILibrary:SetTheme(themeName)
    if Themes[themeName] then
        DefaultConfig.Theme = themeName
        return true
    end
    return false
end

function UILibrary:GetThemes()
    local themeList = {}
    for name, _ in pairs(Themes) do
        table.insert(themeList, name)
    end
    return themeList
end

-- ═══════════════════════════════════════════════════════════════
-- INITIALIZATION
-- ═══════════════════════════════════════════════════════════════

print("📦 UILibrary.lua loaded successfully!")
print("🎨 Available themes:", table.concat(UILibrary:GetThemes(), ", "))
print("⚡ Ready for use!")

return UILibrary
