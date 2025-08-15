-- Debug UI Loading Script
print("🔍 Starting UI Debug...")

-- Test 1: Check if game services are available
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("✅ Players:", Players)
print("✅ RunService:", RunService)
print("✅ ReplicatedStorage:", ReplicatedStorage)

local Player = Players.LocalPlayer
if Player then
    print("✅ LocalPlayer found:", Player.Name)
else
    print("❌ LocalPlayer not found!")
    return
end

-- Test 2: Try loading UILibrary_Rayfield_Fork directly
print("🎨 Loading UILibrary_Rayfield_Fork...")
local UILib
local success, err = pcall(function()
    local response = game:HttpGet("https://raw.githubusercontent.com/MELLISAEFFENDY/MELLISAEFFENDY.github.io/main/UILibrary_Rayfield_Fork.lua", true)
    print("📄 Response received, length:", string.len(response or ""))
    
    if response and string.len(response) > 100 then
        print("📄 First 200 chars:", string.sub(response, 1, 200))
        UILib = loadstring(response)()
        print("✅ Loadstring executed, UILib type:", type(UILib))
        
        if UILib then
            print("🔧 UILib functions:")
            for k, v in pairs(UILib) do
                if type(v) == "function" then
                    print("   •", k, ":", type(v))
                end
            end
        end
    else
        error("Empty or invalid response from GitHub")
    end
end)

if not success then
    print("❌ Failed to load UILib:", err)
    return
end

-- Test 3: Try creating basic window
if UILib then
    print("🎯 Testing CreateWindow...")
    local windowSuccess, windowErr = pcall(function()
        local window = UILib:CreateWindow({
            Title = "🧪 Debug Test Window"
        })
        print("✅ Window created:", type(window))
        return window
    end)
    
    if not windowSuccess then
        print("❌ CreateWindow failed:", windowErr)
    end
    
    -- Test 4: Try CreateFishingWindow
    print("🎣 Testing CreateFishingWindow...")
    local fishingSuccess, fishingErr = pcall(function()
        local fishingUI = UILib:CreateFishingWindow("🧪 Debug Fishing Window")
        print("✅ FishingUI created:", type(fishingUI))
        
        if fishingUI then
            print("🎯 FishingUI properties:")
            for k, v in pairs(fishingUI) do
                print("   •", k, ":", type(v))
            end
            
            if fishingUI.mainTab then
                print("🔘 Testing button creation...")
                local button = fishingUI.mainTab:CreateButton({
                    Name = "🧪 Debug Button",
                    Callback = function()
                        print("🎉 Button clicked!")
                    end
                })
                print("✅ Button created:", type(button))
            end
        end
        
        return fishingUI
    end)
    
    if not fishingSuccess then
        print("❌ CreateFishingWindow failed:", fishingErr)
    end
else
    print("❌ UILib is nil, cannot test")
end

print("🔍 Debug completed!")
