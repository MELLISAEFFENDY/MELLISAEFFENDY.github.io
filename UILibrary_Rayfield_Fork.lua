--[[
    UILibrary_Rayfield_Fork.lua - Our Own Rayfield Wrapper
    
    This is NOT a copy of Rayfield - it's our own wrapper/interface
    that uses Rayfield as the backend but provides our own API layer.
    
    Benefits:
    • We can control the interface/API
    • We can add our own features/modifications  
    • We can ensure consistency across all our scripts
    • We maintain control while respecting original Rayfield
    
    Developer: MELLISAEFFENDY
    Version: 1.0
    Backend: Rayfield UI Library (loaded from official source)
--]]

-- ═══════════════════════════════════════════════════════════════
-- RAYFIELD LOADER (Official Source)
-- ═══════════════════════════════════════════════════════════════

local RayfieldCore = nil
local RayfieldLoaded = false

print("🔧 UILibrary_Rayfield_Fork: Loading official Rayfield...")
local success, err = pcall(function()
    RayfieldCore = loadstring(game:HttpGet("https://sirius.menu/rayfield", true))()
    if RayfieldCore then
        RayfieldLoaded = true
        print("✅ UILibrary_Rayfield_Fork: Official Rayfield loaded!")
    else
        error("Official Rayfield failed to initialize")
    end
end)

if not success or not RayfieldLoaded then
    warn("❌ UILibrary_Rayfield_Fork: Failed to load official Rayfield:", err or "Unknown error")
    warn("📱 UILibrary_Rayfield_Fork: Will return fallback functions")
end

-- ═══════════════════════════════════════════════════════════════
-- OUR CUSTOM WRAPPER API
-- ═══════════════════════════════════════════════════════════════

local UILibrary_Fork = {}
UILibrary_Fork.__index = UILibrary_Fork

-- Our custom configuration for Fish It scripts
local DEFAULT_CONFIG = {
    WindowTitle = "🚀 MELLISA EFFENDY - Fish It Ultimate",
    LoadingTitle = "Fish It Ultimate",
    LoadingSubtitle = "by MELLISA EFFENDY",
    Theme = "Ocean", -- Our preferred theme
    ConfigSaving = false,
    KeySystem = false,
    Discord = false
}

-- ═══════════════════════════════════════════════════════════════
-- WINDOW CREATION (Our Custom API)
-- ═══════════════════════════════════════════════════════════════

function UILibrary_Fork:CreateWindow(config)
    if not RayfieldLoaded then
        warn("⚠️ UILibrary_Rayfield_Fork: Rayfield not loaded, returning dummy window")
        return {
            CreateTab = function() return { CreateButton = function() end, CreateParagraph = function() end } end,
            Destroy = function() end
        }
    end
    
    -- Merge user config with our defaults
    local windowConfig = {
        Name = config.Title or DEFAULT_CONFIG.WindowTitle,
        LoadingTitle = config.LoadingTitle or DEFAULT_CONFIG.LoadingTitle,
        LoadingSubtitle = config.LoadingSubtitle or DEFAULT_CONFIG.LoadingSubtitle,
        ConfigurationSaving = {
            Enabled = config.ConfigSaving or DEFAULT_CONFIG.ConfigSaving
        },
        Discord = {
            Enabled = config.Discord or DEFAULT_CONFIG.Discord
        },
        KeySystem = config.KeySystem or DEFAULT_CONFIG.KeySystem
    }
    
    print("🎨 UILibrary_Rayfield_Fork: Creating window with our config...")
    local rayfieldWindow = RayfieldCore:CreateWindow(windowConfig)
    
    -- Return our wrapped window with additional methods
    local wrappedWindow = {
        _rayfield = rayfieldWindow,
        _tabs = {},
        
        CreateTab = function(self, name, icon)
            print("📂 UILibrary_Rayfield_Fork: Creating tab:", name)
            local rayfieldTab = self._rayfield:CreateTab(name, icon)
            
            -- Wrap the tab with our custom methods
            local wrappedTab = {
                _rayfield = rayfieldTab,
                _name = name,
                
                CreateButton = function(self, config)
                    print("🔘 UILibrary_Rayfield_Fork: Creating button:", config.Name or config.Text)
                    return self._rayfield:CreateButton({
                        Name = config.Name or config.Text or "Button",
                        Callback = config.Callback or function() end
                    })
                end,
                
                CreateToggle = function(self, config)
                    print("🔄 UILibrary_Rayfield_Fork: Creating toggle:", config.Name or config.Text)
                    return self._rayfield:CreateToggle({
                        Name = config.Name or config.Text or "Toggle",
                        CurrentValue = config.Default or false,
                        Callback = config.Callback or function() end
                    })
                end,
                
                CreateParagraph = function(self, config)
                    print("📝 UILibrary_Rayfield_Fork: Creating paragraph:", config.Title)
                    return self._rayfield:CreateParagraph({
                        Title = config.Title or "Info",
                        Content = config.Content or config.Text or "No content"
                    })
                end,
                
                CreateSlider = function(self, config)
                    print("🎚️ UILibrary_Rayfield_Fork: Creating slider:", config.Name or config.Text)
                    return self._rayfield:CreateSlider({
                        Name = config.Name or config.Text or "Slider",
                        Range = config.Range or {1, 100},
                        Increment = config.Increment or 1,
                        Suffix = config.Suffix or "",
                        CurrentValue = config.Default or 1,
                        Callback = config.Callback or function() end
                    })
                end
            }
            
            self._tabs[name] = wrappedTab
            return wrappedTab
        end,
        
        GetTab = function(self, name)
            return self._tabs[name]
        end,
        
        Destroy = function(self)
            print("🗑️ UILibrary_Rayfield_Fork: Destroying window")
            if self._rayfield and self._rayfield.Destroy then
                self._rayfield:Destroy()
            end
        end
    }
    
    print("✅ UILibrary_Rayfield_Fork: Window created successfully!")
    return wrappedWindow
end

-- ═══════════════════════════════════════════════════════════════
-- NOTIFICATION SYSTEM (Our Custom API)
-- ═══════════════════════════════════════════════════════════════

function UILibrary_Fork:Notify(config)
    if RayfieldLoaded and RayfieldCore then
        RayfieldCore:Notify({
            Title = config.Title or "Notification",
            Content = config.Content or config.Text or "No content",
            Duration = config.Duration or 3,
            Image = config.Image
        })
    else
        -- Fallback to Roblox notification
        game.StarterGui:SetCore("SendNotification", {
            Title = config.Title or "Notification",
            Text = config.Content or config.Text or "No content",
            Duration = config.Duration or 3
        })
    end
    print("📢 UILibrary_Rayfield_Fork:", config.Title or "Notification")
end

-- ═══════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS (Our Custom Extensions)
-- ═══════════════════════════════════════════════════════════════

function UILibrary_Fork:IsLoaded()
    return RayfieldLoaded
end

function UILibrary_Fork:GetVersion()
    return "1.0 (Rayfield Fork by MELLISA EFFENDY)"
end

function UILibrary_Fork:SetTheme(themeName)
    -- Future: Custom theme switching
    print("🎨 UILibrary_Rayfield_Fork: Theme switching not implemented yet")
end

-- Fish It specific helper functions
function UILibrary_Fork:CreateFishingWindow(title)
    local window = self:CreateWindow({
        Title = title or "🎣 Fish It Ultimate",
        LoadingTitle = "Fish It Ultimate",
        LoadingSubtitle = "Automated Fishing System"
    })
    
    -- Pre-create common tabs for fishing scripts
    local mainTab = window:CreateTab("🎣 AutoFishing", nil)
    local statsTab = window:CreateTab("📊 Statistics", nil)
    local settingsTab = window:CreateTab("⚙️ Settings", nil)
    
    return {
        window = window,
        mainTab = mainTab,
        statsTab = statsTab,
        settingsTab = settingsTab
    }
end

-- ═══════════════════════════════════════════════════════════════
-- RETURN OUR CUSTOM API
-- ═══════════════════════════════════════════════════════════════

print("✅ UILibrary_Rayfield_Fork: Library loaded successfully!")
print("   🎨 Backend:", RayfieldLoaded and "Official Rayfield" or "Fallback Mode")
print("   🔧 API Version:", UILibrary_Fork:GetVersion())
print("   📱 Delta Compatible: ✅ Yes (uses official Rayfield)")

return UILibrary_Fork
