-- https://discord.gg/uG5wXsFHjk 
-- https://github.com/nucax/KuromiX 
local guiParent = (syn and syn.protect_gui and syn.protect_gui(game:GetService("CoreGui"))) or game:GetService("CoreGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KuromiX"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = guiParent

-- Main Frame
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 0, 60)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

-- FPS Counter
local FPSLabel = Instance.new("TextLabel", ScreenGui)
FPSLabel.Size = UDim2.new(0, 100, 0, 25)
FPSLabel.Position = UDim2.new(1, -110, 0, 10)
FPSLabel.BackgroundTransparency = 1
FPSLabel.TextColor3 = Color3.fromRGB(200, 0, 255)
FPSLabel.TextStrokeTransparency = 0.5
FPSLabel.TextXAlignment = Enum.TextXAlignment.Right
FPSLabel.Font = Enum.Font.SourceSansBold
FPSLabel.TextSize = 18
FPSLabel.Text = "FPS: ..."

local RunService = game:GetService("RunService")
local lastTime = tick()
local frameCount = 0

RunService.RenderStepped:Connect(function()
	frameCount += 1
	local now = tick()
	if now - lastTime >= 1 then
		FPSLabel.Text = "FPS: " .. tostring(frameCount)
		frameCount = 0
		lastTime = now
	end
end)

-- UIStroke
local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(128, 0, 255)

-- Tab holder
local TabHolder = Instance.new("Frame", MainFrame)
TabHolder.Size = UDim2.new(0, 100, 1, 0)
TabHolder.BackgroundColor3 = Color3.fromRGB(30, 0, 40)

-- Tabs
local Tabs = {"Player", "ESP", "Environment", "Misc", "Discord", "External Scripts", "Game Scripts", "Myself"}
local TabFrames = {}

for i, tabName in pairs(Tabs) do
	local Button = Instance.new("TextButton", TabHolder)
	Button.Size = UDim2.new(1, 0, 0, 40)
	Button.Position = UDim2.new(0, 0, 0, (i - 1) * 40)
	Button.Text = tabName
	Button.BackgroundColor3 = Color3.fromRGB(60, 0, 80)
	Button.TextColor3 = Color3.fromRGB(255, 255, 255)
	Button.BorderSizePixel = 0

	local TabFrame = Instance.new("Frame", MainFrame)
	TabFrame.Size = UDim2.new(1, -100, 1, 0)
	TabFrame.Position = UDim2.new(0, 100, 0, 0)
	TabFrame.BackgroundColor3 = Color3.fromRGB(20, 0, 30)
	TabFrame.Visible = (i == 1)

	TabFrames[tabName] = TabFrame

	Button.MouseButton1Click:Connect(function()
		for _, frame in pairs(TabFrames) do
			frame.Visible = false
		end
		TabFrame.Visible = true
	end)
end

-- ESP toggle
local ESPEnabled = false

local function createHighlight(player)
	if player.Character and not player.Character:FindFirstChild("KuromiXHighlight") then
		local hl = Instance.new("Highlight")
		hl.Name = "KuromiXHighlight"
		hl.FillColor = Color3.fromRGB(200, 0, 255)
		hl.OutlineColor = Color3.fromRGB(255, 255, 255)
		hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		hl.FillTransparency = 0.5
		hl.Parent = player.Character
		hl.Adornee = player.Character
	end
end

local ToggleESP = Instance.new("TextButton", TabFrames["ESP"])
ToggleESP.Size = UDim2.new(0, 200, 0, 40)
ToggleESP.Position = UDim2.new(0, 10, 0, 10)
ToggleESP.Text = "Toggle ESP (OFF)"
ToggleESP.BackgroundColor3 = Color3.fromRGB(80, 0, 120)
ToggleESP.TextColor3 = Color3.fromRGB(255, 255, 255)

ToggleESP.MouseButton1Click:Connect(function()
	ESPEnabled = not ESPEnabled
	ToggleESP.Text = "Toggle ESP (" .. (ESPEnabled and "ON" or "OFF") .. ")"
end)

RunService.RenderStepped:Connect(function()
	if ESPEnabled then
		for _, player in ipairs(game.Players:GetPlayers()) do
			if player ~= game.Players.LocalPlayer then
				createHighlight(player)
			end
		end
	else
		for _, player in ipairs(game.Players:GetPlayers()) do
			local char = player.Character
			if char and char:FindFirstChild("KuromiXHighlight") then
				char:FindFirstChild("KuromiXHighlight"):Destroy()
			end
		end
	end
end)

-- Environment Tab
local Lighting = game:GetService("Lighting")
local nightLoop, dayLoop = false, false

local NightBtn = Instance.new("TextButton", TabFrames["Environment"])
NightBtn.Size = UDim2.new(0, 200, 0, 40)
NightBtn.Position = UDim2.new(0, 10, 0, 10)
NightBtn.Text = "Night Mode (OFF)"
NightBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 150)
NightBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

NightBtn.MouseButton1Click:Connect(function()
	nightLoop = not nightLoop
	dayLoop = false
	NightBtn.Text = "Night Mode (" .. (nightLoop and "ON" or "OFF") .. ")"
	while nightLoop do
		Lighting.ClockTime = 0
		task.wait(2)
	end
end)

local DayBtn = Instance.new("TextButton", TabFrames["Environment"])
DayBtn.Size = UDim2.new(0, 200, 0, 40)
DayBtn.Position = UDim2.new(0, 10, 0, 60)
DayBtn.Text = "Day Mode (OFF)"
DayBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 100)
DayBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

DayBtn.MouseButton1Click:Connect(function()
	dayLoop = not dayLoop
	nightLoop = false
	DayBtn.Text = "Day Mode (" .. (dayLoop and "ON" or "OFF") .. ")"
	while dayLoop do
		Lighting.ClockTime = 14
		task.wait(2)
	end
end)

-- External Scripts Tab
local ExternalTab = TabFrames["External Scripts"]

local InfiniteYieldBtn = Instance.new("TextButton", ExternalTab)
InfiniteYieldBtn.Size = UDim2.new(0, 200, 0, 40)
InfiniteYieldBtn.Position = UDim2.new(0, 10, 0, 10)
InfiniteYieldBtn.Text = "Run Infinite Yield"
InfiniteYieldBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 150)
InfiniteYieldBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
InfiniteYieldBtn.MouseButton1Click:Connect(function()
	pcall(function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
	end)
end)


-- dex
local DexBtn = Instance.new("TextButton", ExternalTab)
DexBtn.Size = UDim2.new(0, 200, 0, 40)
DexBtn.Position = UDim2.new(0, 10, 0, 60)
DexBtn.Text = "Launch Dex Explorer"
DexBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 180)
DexBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DexBtn.MouseButton1Click:Connect(function()
	pcall(function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/peyton2465/Dex/master/out.lua"))()
	end)
end)


-- skidfling gui
local FlingBtn = Instance.new("TextButton", ExternalTab)
FlingBtn.Size = UDim2.new(0, 200, 0, 40)
FlingBtn.Position = UDim2.new(0, 10, 0, 110)
FlingBtn.Text = "Launch Fling Tool"
FlingBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 120)
FlingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FlingBtn.MouseButton1Click:Connect(function()
	pcall(function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/K1LAS1K/Ultimate-Fling-GUI/main/flingscript.lua"))()
	end)
end)

-- Game Scripts Tab (Scrollable, with manual placeholders)
local GameScriptsTab = TabFrames["Game Scripts"]

-- Create a ScrollingFrame inside the tab
local ScrollFrame = Instance.new("ScrollingFrame", GameScriptsTab)
ScrollFrame.Size = UDim2.new(1, 0, 1, 0)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 4900) -- ts
ScrollFrame.ScrollBarThickness = 8
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0

-- Layout
local ListLayout = Instance.new("UIListLayout", ScrollFrame)
ListLayout.Padding = UDim.new(0, 10)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Helper to make buttons
local function createGameButton(name, color, url)
	local Btn = Instance.new("TextButton", ScrollFrame)
	Btn.Size = UDim2.new(0, 200, 0, 40)
	Btn.Text = name
	Btn.BackgroundColor3 = color
	Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	Btn.BorderSizePixel = 0
	Btn.Font = Enum.Font.SourceSansBold
	Btn.TextScaled = true
	Btn.MouseButton1Click:Connect(function()
		pcall(function()
			loadstring(game:HttpGet(url, true))()
		end)
	end)
end

-- You can find the Source code of the game scripts in the KuromiX GitHub Repo
-- Game script buttons
createGameButton("Sharkbite Classic", Color3.fromRGB(0, 170, 255), "https://raw.githubusercontent.com/nucax/KuromiX/refs/heads/main/Game%20Scripts/sharkbite_classic.lua") -- sharkbite
createGameButton("Natural Disaster Survival", Color3.fromRGB(0, 200, 100), "https://raw.githubusercontent.com/nucax/KuromiX/refs/heads/main/Game%20Scripts/Natural_disaster_survival.lua") -- nds
createGameButton("MM2 Script", Color3.fromRGB(200, 50, 50), "https://raw.githubusercontent.com/nucax/KuromiX/refs/heads/main/Game%20Scripts/Murder_Mystery_2.lua") -- Murder Mystery 2
createGameButton("Zombie Attack Troll", Color3.fromRGB(255, 100, 0), "https://raw.githubusercontent.com/nucax/KuromiX/refs/heads/main/Game%20Scripts/zombie_attack.lua") -- zombie attack troll
createGameButton("Build a Boat For Treasure", Color3.fromRGB(120, 0, 255), "https://raw.githubusercontent.com/nucax/KuromiX/refs/heads/main/Game%20Scripts/build-a-boat-for-treasure.lua") -- build a boat for treasure
createGameButton("Emergency Hamburg", Color3.fromRGB(140, 0, 220), "https://raw.githubusercontent.com/nucax/KuromiX/refs/heads/main/Game%20Scripts/Emergency_hamburg.lua") -- emergency hamburg
createGameButton("FNAF: Coop", Color3.fromRGB(160, 0, 200), "https://raw.githubusercontent.com/nucax/KuromiX/refs/heads/main/Game%20Scripts/fnaf_coop.lua") -- fnaf coop update
createGameButton("Survive Overnight in a Mega Store", Color3.fromRGB(180, 0, 180), "https://raw.githubusercontent.com/nucax/KuromiX/refs/heads/main/Game%20Scripts/Survive_Overnight_in_a_Mega_Store.lua") -- survive in a superstore
createGameButton("Rainbow Friends 1", Color3.fromRGB(200, 0, 160), "https://raw.githubusercontent.com/nucax/KuromiX/refs/heads/main/Game%20Scripts/rainbow_friends.lua")
createGameButton("Doors", Color3.fromRGB(220, 0, 140), "https://raw.githubusercontent.com/nucax/KuromiX/refs/heads/main/Game%20Scripts/doors.lua") -- doors
createGameButton("Prison Life", Color3.fromRGB(240, 0, 120), "https://raw.githubusercontent.com/nucax/KuromiX/refs/heads/main/Game%20Scripts/prison_life.lua") -- Prison Life
createGameButton("Placeholder Script 8", Color3.fromRGB(255, 50, 100), "https://example.com/script8.lua")
createGameButton("Placeholder Script 9", Color3.fromRGB(255, 100, 80), "https://example.com/script9.lua")
createGameButton("Placeholder Script 10", Color3.fromRGB(255, 130, 60), "https://example.com/script10.lua")
createGameButton("Placeholder Script 11", Color3.fromRGB(255, 160, 40), "https://example.com/script11.lua")
createGameButton("Placeholder Script 12", Color3.fromRGB(255, 180, 20), "https://example.com/script12.lua")
createGameButton("Placeholder Script 13", Color3.fromRGB(255, 200, 0), "https://example.com/script13.lua")
createGameButton("Placeholder Script 14", Color3.fromRGB(220, 180, 20), "https://example.com/script14.lua")
createGameButton("Placeholder Script 15", Color3.fromRGB(200, 160, 40), "https://example.com/script15.lua")
createGameButton("Placeholder Script 16", Color3.fromRGB(180, 140, 60), "https://example.com/script16.lua")
createGameButton("Placeholder Script 17", Color3.fromRGB(160, 120, 80), "https://example.com/script17.lua")
createGameButton("Placeholder Script 18", Color3.fromRGB(140, 100, 100), "https://example.com/script18.lua")
createGameButton("Placeholder Script 19", Color3.fromRGB(120, 80, 120), "https://example.com/script19.lua")
createGameButton("Placeholder Script 20", Color3.fromRGB(100, 60, 140), "https://example.com/script20.lua")
createGameButton("Placeholder Script 21", Color3.fromRGB(80, 40, 160), "https://example.com/script21.lua")
createGameButton("Placeholder Script 22", Color3.fromRGB(60, 20, 180), "https://example.com/script22.lua")
createGameButton("Placeholder Script 23", Color3.fromRGB(40, 0, 200), "https://example.com/script23.lua")
createGameButton("Placeholder Script 24", Color3.fromRGB(60, 20, 220), "https://example.com/script24.lua")
createGameButton("Placeholder Script 25", Color3.fromRGB(80, 40, 240), "https://example.com/script25.lua")
createGameButton("Placeholder Script 26", Color3.fromRGB(100, 60, 255), "https://example.com/script26.lua")
createGameButton("Placeholder Script 27", Color3.fromRGB(120, 90, 255), "https://example.com/script27.lua")
createGameButton("Placeholder Script 28", Color3.fromRGB(140, 120, 255), "https://example.com/script28.lua")
createGameButton("Placeholder Script 29", Color3.fromRGB(160, 150, 255), "https://example.com/script29.lua")
createGameButton("Placeholder Script 30", Color3.fromRGB(180, 180, 255), "https://example.com/script30.lua")
createGameButton("Placeholder Script 31", Color3.fromRGB(200, 200, 255), "https://example.com/script31.lua")
createGameButton("Placeholder Script 32", Color3.fromRGB(180, 220, 240), "https://example.com/script32.lua")
createGameButton("Placeholder Script 33", Color3.fromRGB(160, 240, 220), "https://example.com/script33.lua")
createGameButton("Placeholder Script 34", Color3.fromRGB(140, 255, 200), "https://example.com/script34.lua")
createGameButton("Placeholder Script 35", Color3.fromRGB(120, 255, 180), "https://example.com/script35.lua")
createGameButton("Placeholder Script 36", Color3.fromRGB(100, 255, 160), "https://example.com/script36.lua")
createGameButton("Placeholder Script 37", Color3.fromRGB(80, 240, 140), "https://example.com/script37.lua")
createGameButton("Placeholder Script 38", Color3.fromRGB(60, 220, 120), "https://example.com/script38.lua")
createGameButton("Placeholder Script 39", Color3.fromRGB(40, 200, 100), "https://example.com/script39.lua")
createGameButton("Placeholder Script 40", Color3.fromRGB(20, 180, 80), "https://example.com/script40.lua")
createGameButton("Placeholder Script 41", Color3.fromRGB(40, 160, 60), "https://example.com/script41.lua")
createGameButton("Placeholder Script 42", Color3.fromRGB(60, 140, 40), "https://example.com/script42.lua")
createGameButton("Placeholder Script 43", Color3.fromRGB(80, 120, 20), "https://example.com/script43.lua")
createGameButton("Placeholder Script 44", Color3.fromRGB(100, 140, 20), "https://example.com/script44.lua")
createGameButton("Placeholder Script 45", Color3.fromRGB(120, 160, 20), "https://example.com/script45.lua")
createGameButton("Placeholder Script 46", Color3.fromRGB(140, 180, 20), "https://example.com/script46.lua")
createGameButton("Placeholder Script 47", Color3.fromRGB(160, 200, 40), "https://example.com/script47.lua")
createGameButton("Placeholder Script 48", Color3.fromRGB(180, 220, 60), "https://example.com/script48.lua")
createGameButton("Placeholder Script 49", Color3.fromRGB(200, 240, 80), "https://example.com/script49.lua")
createGameButton("Placeholder Script 50", Color3.fromRGB(220, 255, 100), "https://example.com/script50.lua")
createGameButton("Placeholder Script 51", Color3.fromRGB(240, 255, 120), "https://example.com/script51.lua")
createGameButton("Placeholder Script 52", Color3.fromRGB(255, 240, 140), "https://example.com/script52.lua")
createGameButton("Placeholder Script 53", Color3.fromRGB(255, 220, 160), "https://example.com/script53.lua")
createGameButton("Placeholder Script 54", Color3.fromRGB(255, 200, 180), "https://example.com/script54.lua")
createGameButton("Placeholder Script 55", Color3.fromRGB(255, 180, 200), "https://example.com/script55.lua")
createGameButton("Placeholder Script 56", Color3.fromRGB(255, 160, 220), "https://example.com/script56.lua")
createGameButton("Placeholder Script 57", Color3.fromRGB(255, 140, 240), "https://example.com/script57.lua")
createGameButton("Placeholder Script 58", Color3.fromRGB(240, 120, 255), "https://example.com/script58.lua")
createGameButton("Placeholder Script 59", Color3.fromRGB(220, 100, 255), "https://example.com/script59.lua")
createGameButton("Placeholder Script 60", Color3.fromRGB(200, 80, 255), "https://example.com/script60.lua")
createGameButton("Placeholder Script 61", Color3.fromRGB(180, 60, 255), "https://example.com/script61.lua")
createGameButton("Placeholder Script 62", Color3.fromRGB(160, 40, 255), "https://example.com/script62.lua")
createGameButton("Placeholder Script 63", Color3.fromRGB(140, 20, 255), "https://example.com/script63.lua")
createGameButton("Placeholder Script 64", Color3.fromRGB(120, 0, 255), "https://example.com/script64.lua")
createGameButton("Placeholder Script 65", Color3.fromRGB(100, 0, 235), "https://example.com/script65.lua")
createGameButton("Placeholder Script 66", Color3.fromRGB(80, 0, 215), "https://example.com/script66.lua")
createGameButton("Placeholder Script 67", Color3.fromRGB(60, 0, 195), "https://example.com/script67.lua")
createGameButton("Placeholder Script 68", Color3.fromRGB(40, 0, 175), "https://example.com/script68.lua")
createGameButton("Placeholder Script 69", Color3.fromRGB(20, 0, 155), "https://example.com/script69.lua")
createGameButton("Placeholder Script 70", Color3.fromRGB(0, 0, 135), "https://example.com/script70.lua")
createGameButton("Placeholder Script 71", Color3.fromRGB(0, 20, 155), "https://example.com/script71.lua")
createGameButton("Placeholder Script 72", Color3.fromRGB(0, 40, 175), "https://example.com/script72.lua")
createGameButton("Placeholder Script 73", Color3.fromRGB(0, 60, 195), "https://example.com/script73.lua")
createGameButton("Placeholder Script 74", Color3.fromRGB(0, 80, 215), "https://example.com/script74.lua")
createGameButton("Placeholder Script 75", Color3.fromRGB(0, 100, 235), "https://example.com/script75.lua")
createGameButton("Placeholder Script 76", Color3.fromRGB(0, 120, 255), "https://example.com/script76.lua")
createGameButton("Placeholder Script 77", Color3.fromRGB(20, 140, 255), "https://example.com/script77.lua")
createGameButton("Placeholder Script 78", Color3.fromRGB(40, 160, 255), "https://example.com/script78.lua")
createGameButton("Placeholder Script 79", Color3.fromRGB(60, 180, 255), "https://example.com/script79.lua")
createGameButton("Placeholder Script 80", Color3.fromRGB(80, 200, 255), "https://example.com/script80.lua")
createGameButton("Placeholder Script 81", Color3.fromRGB(100, 220, 255), "https://example.com/script81.lua")
createGameButton("Placeholder Script 82", Color3.fromRGB(120, 240, 255), "https://example.com/script82.lua")
createGameButton("Placeholder Script 83", Color3.fromRGB(140, 255, 240), "https://example.com/script83.lua")
createGameButton("Placeholder Script 84", Color3.fromRGB(160, 255, 220), "https://example.com/script84.lua")
createGameButton("Placeholder Script 85", Color3.fromRGB(180, 255, 200), "https://example.com/script85.lua")
createGameButton("Placeholder Script 86", Color3.fromRGB(200, 255, 180), "https://example.com/script86.lua")
createGameButton("Placeholder Script 87", Color3.fromRGB(220, 255, 160), "https://example.com/script87.lua")
createGameButton("Placeholder Script 88", Color3.fromRGB(240, 255, 140), "https://example.com/script88.lua")
createGameButton("Placeholder Script 89", Color3.fromRGB(255, 240, 120), "https://example.com/script89.lua")
createGameButton("Placeholder Script 90", Color3.fromRGB(255, 220, 100), "https://example.com/script90.lua")
createGameButton("Placeholder Script 91", Color3.fromRGB(255, 200, 80), "https://example.com/script91.lua")
createGameButton("Placeholder Script 92", Color3.fromRGB(255, 180, 60), "https://example.com/script92.lua")
createGameButton("Placeholder Script 93", Color3.fromRGB(255, 160, 40), "https://example.com/script93.lua")
createGameButton("Placeholder Script 94", Color3.fromRGB(255, 140, 20), "https://example.com/script94.lua")
createGameButton("Placeholder Script 95", Color3.fromRGB(255, 120, 0), "https://example.com/script95.lua")
createGameButton("Placeholder Script 96", Color3.fromRGB(235, 100, 0), "https://example.com/script96.lua")
createGameButton("Placeholder Script 97", Color3.fromRGB(215, 80, 0), "https://example.com/script97.lua")
createGameButton("Placeholder Script 98", Color3.fromRGB(195, 60, 0), "https://example.com/script98.lua")
createGameButton("Placeholder Script 99", Color3.fromRGB(175, 40, 0), "https://example.com/script99.lua")
createGameButton("Placeholder Script 100", Color3.fromRGB(155, 20, 0), "https://example.com/script100.lua")

-- Misc Tab - AFK Fling Script
local MiscTab = TabFrames["Misc"]

local AFKFlingBtn = Instance.new("TextButton", MiscTab)
AFKFlingBtn.Size = UDim2.new(0, 200, 0, 40)
AFKFlingBtn.Position = UDim2.new(0, 10, 0, 10)
AFKFlingBtn.Text = "Load AFK Fling"
AFKFlingBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 100)
AFKFlingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AFKFlingBtn.MouseButton1Click:Connect(function()
	pcall(function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/nucax/afk-fling-script-roblox-gui/main/fling.lua"))()
	end)
end)

-- Misc Tab - FOV Slider Button
local FOVSliderBtn = Instance.new("TextButton", MiscTab)
FOVSliderBtn.Size = UDim2.new(0, 200, 0, 40)
FOVSliderBtn.Position = UDim2.new(0, 10, 0, 60) -- Below the AFK Fling button
FOVSliderBtn.Text = "Load FOV Slider"
FOVSliderBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 180)
FOVSliderBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

FOVSliderBtn.MouseButton1Click:Connect(function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/nucax/FOV-Slider-Script-Roblox/main/script.lua"))()
    end)
end)

-- Player Tab - Aimbot Button
local PlayerTab = TabFrames["Player"]
local AimbotBtn = Instance.new("TextButton", PlayerTab)
AimbotBtn.Size = UDim2.new(0, 200, 0, 40)
AimbotBtn.Position = UDim2.new(0, 10, 0, 10)
AimbotBtn.Text = "Load Aimbot Script"
AimbotBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
AimbotBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AimbotBtn.MouseButton1Click:Connect(function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/nucax/roblox-lua-aimbot-universal/main/aimbotnucax.lua"))()
    end)
end)

-- ESP Tab - Better ESP Button
local ESPTab = TabFrames["ESP"]
local BetterESPBtn = Instance.new("TextButton", ESPTab)
BetterESPBtn.Size = UDim2.new(0, 200, 0, 40)
BetterESPBtn.Position = UDim2.new(0, 10, 0, 60)
BetterESPBtn.Text = "Load Better ESP"
BetterESPBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 150)
BetterESPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
BetterESPBtn.MouseButton1Click:Connect(function()
    ESPEnabled = false
    ToggleESP.Text = "Toggle ESP (OFF)"
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/nucax/FrittenKaese-esp-script-lua/main/espnuxac_frittenkäse.lua"))()
    end)
end)

-- Myself Tab
local MyselfTab = TabFrames["Myself"]
local GitHubBtn = Instance.new("TextButton", MyselfTab)
GitHubBtn.Size = UDim2.new(0, 200, 0, 40)
GitHubBtn.Position = UDim2.new(0, 10, 0, 10)
GitHubBtn.Text = "GitHub (Copy Link)"
GitHubBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 140)
GitHubBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GitHubBtn.MouseButton1Click:Connect(function()
	setclipboard("https://github.com/nucax")
end)

-- Discord Tab
local DiscordLabel = Instance.new("TextLabel", TabFrames["Discord"])
DiscordLabel.Size = UDim2.new(1, -20, 0, 40)
DiscordLabel.Position = UDim2.new(0, 10, 0, 10)
DiscordLabel.Text = ".gg/uG5wXsFHjk"
DiscordLabel.TextColor3 = Color3.fromRGB(200, 150, 255)
DiscordLabel.BackgroundTransparency = 1
DiscordLabel.TextScaled = true

-- Minimize & Close
local MinimizeButton = Instance.new("TextButton", MainFrame)
MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
MinimizeButton.Position = UDim2.new(1, -60, 0, 5)
MinimizeButton.Text = "-"
MinimizeButton.BackgroundColor3 = Color3.fromRGB(80, 0, 100)
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)

local CloseButton = Instance.new("TextButton", MainFrame)
CloseButton.Size = UDim2.new(0, 25, 0, 25)
CloseButton.Position = UDim2.new(1, -30, 0, 5)
CloseButton.Text = "X"
CloseButton.BackgroundColor3 = Color3.fromRGB(120, 0, 120)
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)

local SmallRestoreButton = Instance.new("TextButton", ScreenGui)
SmallRestoreButton.Size = UDim2.new(0, 100, 0, 30)
SmallRestoreButton.Position = UDim2.new(0, 10, 1, -40)
SmallRestoreButton.Text = "KuromiX"
SmallRestoreButton.BackgroundColor3 = Color3.fromRGB(60, 0, 80)
SmallRestoreButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SmallRestoreButton.Visible = false

SmallRestoreButton.MouseButton1Click:Connect(function()
	MainFrame.Visible = true
	SmallRestoreButton.Visible = false
end)

MinimizeButton.MouseButton1Click:Connect(function()
	MainFrame.Visible = false
	SmallRestoreButton.Visible = true
end)

CloseButton.MouseButton1Click:Connect(function()
	ESPEnabled = false
	for _, player in ipairs(game.Players:GetPlayers()) do
		local char = player.Character
		if char and char:FindFirstChild("KuromiXHighlight") then
			char:FindFirstChild("KuromiXHighlight"):Destroy()
		end
	end
	ScreenGui:Destroy()
end)

-- Mobile scaling
local UIScale = Instance.new("UIScale", MainFrame)
UIScale.Scale = 1
