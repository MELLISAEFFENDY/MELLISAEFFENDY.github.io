-- Quick UI Test Script
print("🧪 Testing UILibrary_Rayfield_Fork...")

-- Load our fork
local UILib
local success, err = pcall(function()
    local response = game:HttpGet("https://raw.githubusercontent.com/MELLISAEFFENDY/MELLISAEFFENDY.github.io/main/UILibrary_Rayfield_Fork.lua", true)
    print("📄 Response length:", string.len(response or ""))
    UILib = loadstring(response)()
    print("✅ UILib loaded:", type(UILib))
end)

if not success then
    print("❌ Failed to load UILib:", err)
    return
end

-- Test CreateFishingWindow
print("🎣 Testing CreateFishingWindow...")
local fishingUI = UILib:CreateFishingWindow("🧪 Test Window")
print("🎯 FishingUI:", type(fishingUI))

if fishingUI then
    print("🎯 MainTab:", type(fishingUI.mainTab))
    print("🎯 StatsTab:", type(fishingUI.statsTab))
    
    -- Test creating a button
    if fishingUI.mainTab then
        local testButton = fishingUI.mainTab:CreateButton({
            Name = "🧪 Test Button",
            Callback = function()
                UILib:Notify({
                    Title = "Test Success!",
                    Content = "Button working correctly!",
                    Duration = 3
                })
            end
        })
        print("✅ Test button created!")
    end
else
    print("❌ Failed to create fishing UI")
end

print("🧪 Test completed!")
