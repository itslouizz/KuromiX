-- this script has been made by nucax
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Window = Rayfield:CreateWindow({
	Name = "MM2 Script",
	LoadingTitle = "nucax",
	LoadingSubtitle = "https://github.com/nucax",
	ConfigurationSaving = { Enabled = false },
})

-- State
getgenv().RoleESPEnabled = false
local coinESPEnabled = false
local tracerEnabled = false
local weaponESPEnabled = false
local tracerColor = Color3.fromRGB(255, 255, 255)
local tracerThickness = 2
local tracers = {}

local roleColors = {
	Murderer = Color3.fromRGB(255, 0, 0),
	Sheriff  = Color3.fromRGB(0, 100, 255),
	Innocent = Color3.fromRGB(0, 255, 0),
}

-- Folders
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "MM2_RoleESP"
ESPFolder.Parent = CoreGui

local CoinFolder = Instance.new("Folder")
CoinFolder.Name = "MM2_CoinESP"
CoinFolder.Parent = CoreGui

local WeaponFolder = Instance.new("Folder")
WeaponFolder.Name = "MM2_WeaponESP"
WeaponFolder.Parent = CoreGui

local coinHighlights = {}
local weaponHighlights = {}

-- Label helpers
local function addLabel(char, roleText)
	if char:FindFirstChild("RoleLabel") then return end
	local bb = Instance.new("BillboardGui")
	bb.Name = "RoleLabel"
	bb.Size = UDim2.fromScale(4, 1.2)
	bb.StudsOffset = Vector3.new(0, 3.5, 0)
	bb.AlwaysOnTop = true
	bb.Adornee = char:FindFirstChild("HumanoidRootPart")
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.fromScale(1, 1)
	lbl.BackgroundTransparency = 1
	lbl.TextScaled = true
	lbl.Text = roleText
	lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	lbl.Font = Enum.Font.GothamBold
	lbl.Parent = bb
	bb.Parent = char
end

local function removeLabel(char)
	local l = char and char:FindFirstChild("RoleLabel")
	if l then l:Destroy() end
end

-- Tracers
local function addTracer(player)
	if player == LocalPlayer or tracers[player] then return end
	local line = Drawing.new("Line")
	line.Thickness = tracerThickness
	line.Color = tracerColor
	line.Transparency = 1
	line.Visible = false
	tracers[player] = line
end

local function removeTracer(player)
	if tracers[player] then
		tracers[player]:Remove()
		tracers[player] = nil
	end
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

-- Role ESP tracking
local function TrackPlayer(player)
	local highlight = Instance.new("Highlight")
	highlight.Name = player.Name .. "_RoleESP"
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0
	highlight.Parent = ESPFolder

	addTracer(player)

	task.spawn(function()
		while player and player.Parent do
			pcall(function()
				local char = player.Character
				if char and char:FindFirstChild("HumanoidRootPart") then
					highlight.Adornee = char
					local knife = char:FindFirstChild("Knife")
						or (player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild("Knife"))
					local gun = char:FindFirstChild("Gun")
						or (player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild("Gun"))

					local roleText, fillColor
					if knife then
						roleText = "Murderer"
						fillColor = roleColors.Murderer
					elseif gun then
						roleText = "Sheriff"
						fillColor = roleColors.Sheriff
					else
						roleText = "Innocent"
						fillColor = roleColors.Innocent
					end

					highlight.FillColor = fillColor
					highlight.OutlineColor = fillColor
					highlight.Enabled = getgenv().RoleESPEnabled

					if getgenv().RoleESPEnabled then
						addLabel(char, roleText)
					else
						removeLabel(char)
					end
				else
					highlight.Enabled = false
				end
			end)
			task.wait(0.5)
		end
		highlight:Destroy()
		removeTracer(player)
	end)
end

for _, p in ipairs(Players:GetPlayers()) do
	if p ~= LocalPlayer then TrackPlayer(p) end
end

Players.PlayerAdded:Connect(function(p)
	if p ~= LocalPlayer then TrackPlayer(p) end
end)

Players.PlayerRemoving:Connect(function(p)
	local old = ESPFolder:FindFirstChild(p.Name .. "_RoleESP")
	if old then old:Destroy() end
	removeTracer(p)
end)

-- Coin ESP
local function refreshCoinESP()
	for _, h in pairs(coinHighlights) do if h then h:Destroy() end end
	coinHighlights = {}
	if not coinESPEnabled then return end
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj.Name == "Coin" and (obj:IsA("BasePart") or obj:IsA("Model")) then
			if not coinHighlights[obj] then
				local h = Instance.new("Highlight")
				h.Adornee = obj
				h.FillColor = Color3.fromRGB(255, 215, 0)
				h.OutlineColor = Color3.fromRGB(255, 215, 0)
				h.FillTransparency = 0.3
				h.OutlineTransparency = 0
				h.Parent = CoinFolder
				coinHighlights[obj] = h
			end
		end
	end
end

task.spawn(function()
	while true do
		task.wait(5)
		if coinESPEnabled then refreshCoinESP() end
	end
end)

-- Dropped Weapon ESP
local function refreshWeaponESP()
	for _, h in pairs(weaponHighlights) do if h then h:Destroy() end end
	weaponHighlights = {}
	if not weaponESPEnabled then return end
	for _, obj in ipairs(workspace:GetDescendants()) do
		if (obj.Name == "Knife" or obj.Name == "Gun") and obj:IsA("Model") then
			-- Only highlight if not parented to a character
			local parent = obj.Parent
			local isHeld = parent and Players:GetPlayerFromCharacter(parent) ~= nil
			if not isHeld and not weaponHighlights[obj] then
				local color = obj.Name == "Knife"
					and Color3.fromRGB(255, 60, 60)
					or Color3.fromRGB(60, 120, 255)
				local h = Instance.new("Highlight")
				h.Adornee = obj
				h.FillColor = color
				h.OutlineColor = color
				h.FillTransparency = 0.3
				h.OutlineTransparency = 0
				h.Parent = WeaponFolder
				weaponHighlights[obj] = h
			end
		end
	end
end

task.spawn(function()
	while true do
		task.wait(3)
		if weaponESPEnabled then refreshWeaponESP() end
	end
end)

-- ESP TAB
local ESPTab = Window:CreateTab("ESP", nil)
ESPTab:CreateSection("Players")

ESPTab:CreateToggle({
	Name = "Role ESP",
	CurrentValue = false,
	Callback = function(v) getgenv().RoleESPEnabled = v end,
})

ESPTab:CreateToggle({
	Name = "Tracers",
	CurrentValue = false,
	Callback = function(v)
		tracerEnabled = v
		if v then
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= LocalPlayer then addTracer(p) end
			end
		end
	end,
})

ESPTab:CreateSection("World")

ESPTab:CreateToggle({
	Name = "Coin ESP",
	CurrentValue = false,
	Callback = function(v)
		coinESPEnabled = v
		refreshCoinESP()
	end,
})

ESPTab:CreateToggle({
	Name = "Dropped Weapon ESP",
	CurrentValue = false,
	Callback = function(v)
		weaponESPEnabled = v
		refreshWeaponESP()
	end,
})

-- FARM TAB
local FarmTab = Window:CreateTab("Farm", nil)
local autofarm = false

FarmTab:CreateToggle({
	Name = "Auto Farm (Coin Spot)",
	CurrentValue = false,
	Callback = function(v)
		autofarm = v
		if v then
			task.spawn(function()
				while autofarm do
					pcall(function()
						local char = LocalPlayer.Character
						if char and char:FindFirstChild("HumanoidRootPart") then
							char.HumanoidRootPart.CFrame = CFrame.new(99.9, 140.4, 60.7)
						end
					end)
					task.wait(0.1)
				end
			end)
		end
	end,
})

-- Anti-AFK
local antiAfk = false
FarmTab:CreateToggle({
	Name = "Anti-AFK",
	CurrentValue = false,
	Callback = function(v)
		antiAfk = v
		if v then
			task.spawn(function()
				while antiAfk do
					task.wait(60)
					if antiAfk and LocalPlayer.Character then
						local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
						if hum then hum.Jump = true end
					end
				end
			end)
		end
	end,
})

-- PLAYER TAB
local PlayerTab = Window:CreateTab("Player", nil)
PlayerTab:CreateSection("Movement")

local currentSpeed = 16
local currentJump = 50

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
				if hum.JumpPower ~= currentJump then hum.JumpPower = currentJump end
			end
		end
		task.wait(0.1)
	end
end)

-- CONFIG TAB
local ConfigTab = Window:CreateTab("Config", nil)
ConfigTab:CreateSection("Role ESP Colors")

ConfigTab:CreateColorPicker({
	Name = "Murderer Color",
	Color = roleColors.Murderer,
	Callback = function(c) roleColors.Murderer = c end,
})

ConfigTab:CreateColorPicker({
	Name = "Sheriff Color",
	Color = roleColors.Sheriff,
	Callback = function(c) roleColors.Sheriff = c end,
})

ConfigTab:CreateColorPicker({
	Name = "Innocent Color",
	Color = roleColors.Innocent,
	Callback = function(c) roleColors.Innocent = c end,
})

ConfigTab:CreateSection("Tracers")

ConfigTab:CreateColorPicker({
	Name = "Tracer Color",
	Color = tracerColor,
	Callback = function(c)
		tracerColor = c
		for _, line in pairs(tracers) do line.Color = c end
	end,
})

ConfigTab:CreateSlider({
	Name = "Tracer Thickness",
	Range = {1, 5},
	Increment = 1,
	Suffix = "px",
	CurrentValue = 2,
	Callback = function(v) tracerThickness = v end,
})

-- GITHUB TAB
local GitHubTab = Window:CreateTab("GitHub", nil)
GitHubTab:CreateButton({
	Name = "Copy GitHub to Clipboard",
	Callback = function()
		setclipboard("https://github.com/nucax")
		Rayfield:Notify({
			Title = "GitHub",
			Content = "Copied GitHub link to clipboard!",
			Duration = 5
		})
	end,
})
