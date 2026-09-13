-- this script has been made by nucax
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Window = Rayfield:CreateWindow({
	Name = "discord.gg/uG5wXsFHjk",
	LoadingTitle = "discord.gg/uG5wXsFHjk",
	LoadingSubtitle = "by nucax",
	ConfigurationSaving = { Enabled = false },
	KeySystem = false
})

-- State
local highlightEnabled = false
local fillColor    = Color3.fromRGB(255, 0, 0)
local outlineColor = Color3.fromRGB(255, 255, 255)
local fillTransparency = 0.6

local monsterHighlights = {}
local monsterLabels     = {}

-- Helpers
local function getPrimaryPart(model)
	if model.PrimaryPart then return model.PrimaryPart end
	for _, d in ipairs(model:GetDescendants()) do
		if d:IsA("BasePart") then return d end
	end
end

local function addLabel(monster)
	if monsterLabels[monster] then return end
	local part = getPrimaryPart(monster)
	if not part then return end

	local bb = Instance.new("BillboardGui")
	bb.Name = "MonsterLabel"
	bb.Size = UDim2.fromScale(5, 1.5)
	bb.StudsOffset = Vector3.new(0, 4, 0)
	bb.AlwaysOnTop = true
	bb.Adornee = part

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.fromScale(1, 1)
	lbl.BackgroundTransparency = 1
	lbl.TextScaled = true
	lbl.Text = monster.Name
	lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	lbl.Font = Enum.Font.GothamBold
	lbl.Parent = bb

	bb.Parent = game:GetService("CoreGui")
	monsterLabels[monster] = bb
end

local function removeLabel(monster)
	if monsterLabels[monster] then
		monsterLabels[monster]:Destroy()
		monsterLabels[monster] = nil
	end
end

local function addHighlight(monster)
	if not monster:IsA("Model") or monsterHighlights[monster] then return end

	local h = Instance.new("Highlight")
	h.Adornee = monster
	h.FillColor = fillColor
	h.OutlineColor = outlineColor
	h.FillTransparency = fillTransparency
	h.OutlineTransparency = 0
	h.Parent = game:GetService("CoreGui")
	monsterHighlights[monster] = h

	addLabel(monster)
end

local function removeHighlight(monster)
	if monsterHighlights[monster] then
		monsterHighlights[monster]:Destroy()
		monsterHighlights[monster] = nil
	end
	removeLabel(monster)
end

local function removeAllHighlights()
	for monster in pairs(monsterHighlights) do
		removeHighlight(monster)
	end
end

local function refreshColors()
	for _, h in pairs(monsterHighlights) do
		h.FillColor = fillColor
		h.OutlineColor = outlineColor
		h.FillTransparency = fillTransparency
	end
end

-- Auto-cleanup when a monster leaves workspace
workspace.Monsters.ChildRemoved:Connect(function(child)
	removeHighlight(child)
end)

-- Auto-add when a monster spawns (only if ESP is on)
workspace.Monsters.ChildAdded:Connect(function(child)
	if highlightEnabled then
		task.wait(0.1) -- for loading
		addHighlight(child)
	end
end)

-- VISUALS TAB
local VisualsTab = Window:CreateTab("Visuals", nil)
VisualsTab:CreateSection("Monster ESP")

VisualsTab:CreateToggle({
	Name = "Highlight Monsters",
	CurrentValue = false,
	Callback = function(v)
		highlightEnabled = v
		if v then
			for _, m in ipairs(workspace.Monsters:GetChildren()) do
				addHighlight(m)
			end
		else
			removeAllHighlights()
		end
	end
})

-- CONFIG TAB
local ConfigTab = Window:CreateTab("Config", nil)
ConfigTab:CreateSection("ESP Appearance")

ConfigTab:CreateColorPicker({
	Name = "Fill Color",
	Color = fillColor,
	Callback = function(c)
		fillColor = c
		refreshColors()
	end,
})

ConfigTab:CreateColorPicker({
	Name = "Outline Color",
	Color = outlineColor,
	Callback = function(c)
		outlineColor = c
		refreshColors()
	end,
})

ConfigTab:CreateSlider({
	Name = "Fill Transparency",
	Range = {0, 10},
	Increment = 1,
	Suffix = "0%",
	CurrentValue = 6,
	Callback = function(v)
		fillTransparency = v / 10
		refreshColors()
	end,
})

-- PLAYER TAB
local PlayerTab = Window:CreateTab("Player", nil)
PlayerTab:CreateSection("Movement")

local currentSpeed = 16
local currentJump  = 50

PlayerTab:CreateSlider({
	Name = "Walk Speed",
	Range = {1, 100},
	Increment = 1,
	Suffix = " Speed",
	CurrentValue = 16,
	Callback = function(v) currentSpeed = v end,
})

PlayerTab:CreateSlider({
	Name = "Jump Power",
	Range = {1, 200},
	Increment = 5,
	Suffix = " Power",
	CurrentValue = 50,
	Callback = function(v) currentJump = v end,
})

task.spawn(function()
	while true do
		if LocalPlayer.Character then
			local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if hum then
				if hum.WalkSpeed ~= currentSpeed then hum.WalkSpeed = currentSpeed end
				if hum.JumpPower  ~= currentJump  then hum.JumpPower  = currentJump  end
			end
		end
		task.wait(0.1)
	end
end)
