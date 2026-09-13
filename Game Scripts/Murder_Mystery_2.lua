-- this script has been made by nucax
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Window = Rayfield:CreateWindow({
	Name = "MM2 Script",
	LoadingTitle = "nucax",
	LoadingSubtitle = "https://github.com/nucax",
	ConfigurationSaving = { Enabled = false },
})

-- State
getgenv().RoleESPEnabled = false
local coinESPEnabled = false

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

local coinHighlights = {}

-- Role label helper
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

-- Track player role ESP
local function TrackPlayer(player)
	local highlight = Instance.new("Highlight")
	highlight.Name = player.Name .. "_RoleESP"
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0
	highlight.Parent = ESPFolder

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
end)

-- Coin ESP
local function refreshCoinESP()
	for _, h in pairs(coinHighlights) do
		if h then h:Destroy() end
	end
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

-- ESP TAB
local ESPTab = Window:CreateTab("ESP", nil)

ESPTab:CreateToggle({
	Name = "Role ESP",
	CurrentValue = false,
	Callback = function(v)
		getgenv().RoleESPEnabled = v
	end,
})

ESPTab:CreateToggle({
	Name = "Coin ESP",
	CurrentValue = false,
	Callback = function(v)
		coinESPEnabled = v
		refreshCoinESP()
	end,
})

-- Auto-refresh coin ESP every 5s to catch new coins
task.spawn(function()
	while true do
		task.wait(5)
		if coinESPEnabled then refreshCoinESP() end
	end
end)

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
	Callback = function(v)
		currentSpeed = v
	end,
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

-- CONFIG TAB
local ConfigTab = Window:CreateTab("Config", nil)
ConfigTab:CreateSection("Role ESP Colors")

ConfigTab:CreateColorPicker({
	Name = "Murderer Color",
	Color = roleColors.Murderer,
	Callback = function(c)
		roleColors.Murderer = c
	end,
})

ConfigTab:CreateColorPicker({
	Name = "Sheriff Color",
	Color = roleColors.Sheriff,
	Callback = function(c)
		roleColors.Sheriff = c
	end,
})

ConfigTab:CreateColorPicker({
	Name = "Innocent Color",
	Color = roleColors.Innocent,
	Callback = function(c)
		roleColors.Innocent = c
	end,
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
