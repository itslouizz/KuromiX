-- this script has been made by nucax
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local function getHRP()
	local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	return char:WaitForChild("HumanoidRootPart")
end

local Window = Rayfield:CreateWindow({
	Name = "SharkBite Classic Script by nucax",
	LoadingTitle = "Loading...",
	LoadingSubtitle = "discord.gg/3VzqkKKfQZ",
	ConfigurationSaving = { Enabled = false },
	Discord = { Enabled = false },
	KeySystem = false,
})

-- AUTO FARM TAB
local AutoFarmTab = Window:CreateTab("Auto Farm", nil)
AutoFarmTab:CreateSection("Loop Teleport to Secret Spot")

local autoFarm = false
local autoFarmPos = Vector3.new(116.7, 262.0, -42.1)
local autoFarmInterval = 3

task.spawn(function()
	while true do
		if autoFarm then
			local hrp = getHRP()
			hrp.CFrame = CFrame.new(autoFarmPos)
		end
		task.wait(autoFarmInterval)
	end
end)

AutoFarmTab:CreateToggle({
	Name = "Enable Auto Farm",
	CurrentValue = false,
	Callback = function(val)
		autoFarm = val
	end
})

AutoFarmTab:CreateSlider({
	Name = "Teleport Interval",
	Range = {1, 10},
	Increment = 1,
	Suffix = "s",
	CurrentValue = 3,
	Callback = function(val)
		autoFarmInterval = val
	end
})

-- TELEPORT TAB
local TeleportTab = Window:CreateTab("Teleports", nil)
TeleportTab:CreateSection("Teleport To:")

-- Ordered array so buttons always appear in this exact sequence
local locations = {
	{ name = "Spawn",                    pos = Vector3.new(6.8,   285.9, -72.4) },
	{ name = "Light Tower",              pos = Vector3.new(26.8,  464.5,  16.0) },
	{ name = "Shop",                     pos = Vector3.new(19.8,  284.9, 142.7) },
	{ name = "Secret Place (Auto Farm)", pos = autoFarmPos                       },
}

for _, loc in ipairs(locations) do
	TeleportTab:CreateButton({
		Name = loc.name,
		Callback = function()
			getHRP().CFrame = CFrame.new(loc.pos)
		end,
	})
end

-- PLAYER TAB
local PlayerTab = Window:CreateTab("Player", nil)
PlayerTab:CreateSection("Movement")

local currentSpeed = 16

PlayerTab:CreateSlider({
	Name = "Walk Speed",
	Range = {1, 100},
	Increment = 1,
	Suffix = " Speed",
	CurrentValue = 16,
	Callback = function(val)
		currentSpeed = val
	end
})

task.spawn(function()
	while true do
		if LocalPlayer.Character then
			local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if hum and hum.WalkSpeed ~= currentSpeed then
				hum.WalkSpeed = currentSpeed
			end
		end
		task.wait(0.1)
	end
end)

-- ESP TAB
local EspTab = Window:CreateTab("ESP", nil)
EspTab:CreateSection("Player Highlights & Tracers")

local espEnabled = false
local tracerEnabled = false
local espColor = Color3.fromRGB(255, 0, 0)
local tracerColor = Color3.fromRGB(255, 0, 0)
local tracerThickness = 1.5

local highlights = {}
local tracers = {}

local function addHighlight(player)
	if player == LocalPlayer or highlights[player] then return end
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	local highlight = Instance.new("Highlight")
	highlight.Name = "ESP_Highlight"
	highlight.FillColor = espColor
	highlight.OutlineColor = espColor
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0
	highlight.Adornee = char
	highlight.Parent = game:GetService("CoreGui")
	highlights[player] = highlight
end

local function removeHighlight(player)
	if highlights[player] then
		highlights[player]:Destroy()
		highlights[player] = nil
	end
end

local function addTracer(player)
	if player == LocalPlayer or tracers[player] then return end
	local line = Drawing.new("Line")
	line.Transparency = 1
	line.Thickness = tracerThickness
	line.Color = tracerColor
	line.Visible = false
	tracers[player] = line
end

local function removeTracer(player)
	if tracers[player] then
		tracers[player]:Remove()
		tracers[player] = nil
	end
end

local function enableESP()
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer then addHighlight(p) end
	end
end

local function disableESP()
	for p in pairs(highlights) do removeHighlight(p) end
end

local function enableTracers()
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer then addTracer(p) end
	end
end

local function disableTracers()
	for p in pairs(tracers) do removeTracer(p) end
end

-- Auto-apply ESP/tracers on character respawn
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		task.wait(1)
		if espEnabled then addHighlight(player) end
		if tracerEnabled then addTracer(player) end
	end)
end)

for _, player in ipairs(Players:GetPlayers()) do
	player.CharacterAdded:Connect(function()
		task.wait(1)
		if espEnabled then addHighlight(player) end
		if tracerEnabled then addTracer(player) end
	end)
end

RunService.RenderStepped:Connect(function()
	if not tracerEnabled then
		for _, line in pairs(tracers) do line.Visible = false end
		return
	end
	local origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y - 10)
	for player, line in pairs(tracers) do
		local char = player.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			local pos, onScreen = Camera:WorldToViewportPoint(char.HumanoidRootPart.Position)
			if onScreen then
				line.From = origin
				line.To = Vector2.new(pos.X, pos.Y)
				line.Thickness = tracerThickness
				line.Visible = true
			else
				line.Visible = false
			end
		else
			line.Visible = false
		end
	end
end)

EspTab:CreateToggle({
	Name = "Enable ESP Highlights",
	CurrentValue = false,
	Callback = function(val)
		espEnabled = val
		if val then enableESP() else disableESP() end
	end,
})

EspTab:CreateToggle({
	Name = "Enable Tracers",
	CurrentValue = false,
	Callback = function(val)
		tracerEnabled = val
		if val then enableTracers() else disableTracers() end
	end,
})

EspTab:CreateColorPicker({
	Name = "Highlight Color",
	Color = espColor,
	Callback = function(color)
		espColor = color
		for _, h in pairs(highlights) do
			h.FillColor = color
			h.OutlineColor = color
		end
	end,
})

EspTab:CreateColorPicker({
	Name = "Tracer Color",
	Color = tracerColor,
	Callback = function(color)
		tracerColor = color
		for _, line in pairs(tracers) do
			line.Color = color
		end
	end,
})

EspTab:CreateSlider({
	Name = "Tracer Thickness",
	Range = {1, 5},
	Increment = 1,
	Suffix = "px",
	CurrentValue = 2,
	Callback = function(val)
		tracerThickness = val
	end,
})

-- ENVIRONMENT TAB
local EnvironmentTab = Window:CreateTab("Environment", nil)
EnvironmentTab:CreateSection("Visual Settings")

local originalTransparency = {}

EnvironmentTab:CreateToggle({
	Name = "Enable X-Ray Mode",
	CurrentValue = false,
	Callback = function(val)
		for _, part in ipairs(workspace:GetDescendants()) do
			if part:IsA("BasePart") and part.Transparency < 1 then
				if val then
					originalTransparency[part] = part.Transparency
					part.Transparency = 0.8
				elseif originalTransparency[part] then
					part.Transparency = originalTransparency[part]
				end
			end
		end
		if not val then originalTransparency = {} end
	end,
})

EnvironmentTab:CreateButton({
	Name = "Set to Day",
	Callback = function() Lighting.ClockTime = 14 end,
})

EnvironmentTab:CreateButton({
	Name = "Set to Night",
	Callback = function() Lighting.ClockTime = 0 end,
})

-- DISCORD TAB
local DiscordTab = Window:CreateTab("Discord", nil)
DiscordTab:CreateSection("Join the Server")

DiscordTab:CreateButton({
	Name = "Copy Discord Invite",
	Callback = function()
		setclipboard("https://discord.gg/3VzqkKKfQZ")
		Rayfield:Notify({
			Title = "Copied!",
			Content = "Discord invite copied to clipboard.",
			Duration = 4
		})
	end,
})
