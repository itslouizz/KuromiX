-- This script has been made by nucax
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local ESP_Active = false
local Highlights = {}
local Labels = {}
local ESPColor = Color3.fromRGB(255, 0, 0)
local OutlineColor = Color3.fromRGB(255, 255, 255)
local FillTransparency = 0.5

local CoreGui = game:GetService("CoreGui")

-- Helpers
local function createLabel(model)
	if Labels[model] then return end
	local bb = Instance.new("BillboardGui")
	bb.Name = "ESPLabel"
	bb.Size = UDim2.fromScale(5, 1.5)
	bb.StudsOffset = Vector3.new(0, 3, 0)
	bb.AlwaysOnTop = true
	bb.Adornee = model.PrimaryPart

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.fromScale(1, 1)
	lbl.BackgroundTransparency = 1
	lbl.TextScaled = true
	lbl.Text = model.Name
	lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	lbl.Font = Enum.Font.GothamBold
	lbl.Parent = bb

	bb.Parent = CoreGui
	Labels[model] = bb
end

local function createESP(model)
	if not model:IsA("Model") then return end
	if Highlights[model] then return end

	if not model.PrimaryPart then
		for _, child in ipairs(model:GetDescendants()) do
			if child:IsA("BasePart") then
				model.PrimaryPart = child
				break
			end
		end
		if not model.PrimaryPart then return end
	end

	local highlight = Instance.new("Highlight")
	highlight.Adornee = model
	highlight.Parent = CoreGui
	highlight.FillColor = ESPColor
	highlight.OutlineColor = OutlineColor
	highlight.FillTransparency = FillTransparency
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	Highlights[model] = highlight

	createLabel(model)
end

local function applyESP()
	local animatronicsFolder = workspace:FindFirstChild("Animatronics")
	if not animatronicsFolder then return end
	for _, folder in ipairs(animatronicsFolder:GetChildren()) do
		if folder:IsA("Folder") then
			for _, child in ipairs(folder:GetChildren()) do
				createESP(child)
			end
		end
	end
end

local function clearESP()
	for _, h in pairs(Highlights) do
		if h then h:Destroy() end
	end
	for _, l in pairs(Labels) do
		if l then l:Destroy() end
	end
	Highlights = {}
	Labels = {}
end

-- Live refresh: auto-apply ESP to newly spawned animatronics
local spawnConnection = nil

local function connectSpawnListener()
	local animatronicsFolder = workspace:FindFirstChild("Animatronics")
	if not animatronicsFolder then return end
	spawnConnection = animatronicsFolder.DescendantAdded:Connect(function(desc)
		if ESP_Active and desc:IsA("Model") then
			task.wait(0.1) -- brief wait for PrimaryPart to be assigned
			createESP(desc)
		end
	end)
end

local function disconnectSpawnListener()
	if spawnConnection then
		spawnConnection:Disconnect()
		spawnConnection = nil
	end
end

-- Window
local Window = Rayfield:CreateWindow({
	Name = "FNAF: Coop | https://discord.gg/uG5wXsFHjk",
	LoadingTitle = "https://discord.gg/uG5wXsFHjk",
	LoadingSubtitle = "github.com/nucax",
	ConfigurationSaving = { Enabled = false },
})

local ESPTab = Window:CreateTab("ESP")
local ConfigTab = Window:CreateTab("Config")

-- ESP Tab
ESPTab:CreateToggle({
	Name = "Animatronic ESP",
	CurrentValue = false,
	Callback = function(state)
		ESP_Active = state
		if state then
			applyESP()
			connectSpawnListener()
		else
			clearESP()
			disconnectSpawnListener()
		end
	end,
})

-- Config Tab
ConfigTab:CreateColorPicker({
	Name = "Fill Color",
	Color = ESPColor,
	Callback = function(color)
		ESPColor = color
		for _, h in pairs(Highlights) do
			if h then h.FillColor = ESPColor end
		end
	end,
})

ConfigTab:CreateColorPicker({
	Name = "Outline Color",
	Color = OutlineColor,
	Callback = function(color)
		OutlineColor = color
		for _, h in pairs(Highlights) do
			if h then h.OutlineColor = OutlineColor end
		end
	end,
})

ConfigTab:CreateSlider({
	Name = "Fill Transparency",
	Range = {0, 10},
	Increment = 1,
	Suffix = "0%",
	CurrentValue = 5,
	Callback = function(value)
		FillTransparency = value / 10
		for _, h in pairs(Highlights) do
			if h then h.FillTransparency = FillTransparency end
		end
	end,
})
