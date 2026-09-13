-- this script has been made by nucax
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Window
local Window = Rayfield:CreateWindow({
	Name = "Build a Boat For Treasure",
	LoadingTitle = "KuromiX",
	LoadingSubtitle = "discord.gg/uG5wXsFHjk",
	ToggleUIKeybind = "K",
	ConfigurationSaving = { Enabled = false }
})

-- Tabs
local TeleportTab = Window:CreateTab("Teleports", nil)
local AutofarmTab = Window:CreateTab("Autofarm", nil)
local MiscTab = Window:CreateTab("Misc", nil)

-- Helpers
local function tpTo(x, y, z)
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		LocalPlayer.Character:MoveTo(Vector3.new(x, y, z))
	end
end

-- Autofarm Logic
local checkpoints = {
	Vector3.new(-57.13, 67.09, 616.45),    -- Start
	Vector3.new(-47.10, 53.47, 8674.01),   -- Checkpoint 2
	Vector3.new(-49.31, -270.43, 8793.45), -- Checkpoint 3
	Vector3.new(-60.29, -355.07, 9489.90)  -- End
}

local tweening = false
local currentTween = nil
local currentIndex = 2

local function tweenToCheckpoint(index)
	if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
	local root = LocalPlayer.Character.HumanoidRootPart
	if index > #checkpoints then
		tweening = false
		currentIndex = 2
		return
	end
	local goal = { CFrame = CFrame.new(checkpoints[index]) }
	currentTween = TweenService:Create(root, TweenInfo.new(25, Enum.EasingStyle.Linear), goal)
	currentTween:Play()
	currentTween.Completed:Connect(function()
		if tweening then
			currentIndex = currentIndex + 1
			tweenToCheckpoint(currentIndex)
		end
	end)
end

-- Teleport Tab
TeleportTab:CreateButton({
	Name = "TP to White Spawn",
	Callback = function()
		tpTo(-48.89, -8.06, -611.44)
	end
})

TeleportTab:CreateButton({
	Name = "TP to Cool Spot",
	Callback = function()
		tpTo(-740.48, 73.30, 265.03)
	end
})

-- Autofarm Tab
AutofarmTab:CreateToggle({
	Name = "Autofarm",
	CurrentValue = false,
	Callback = function(v)
		tweening = v
		if tweening then
			currentIndex = 2
			if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
				LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(checkpoints[1])
				tweenToCheckpoint(currentIndex)
			end
		else
			if currentTween then
				currentTween:Cancel()
			end
		end
	end
})

-- Misc Tab
MiscTab:CreateButton({
	Name = "Copy Nucax GitHub",
	Callback = function()
		if setclipboard then
			setclipboard("https://github.com/nucax")
		end
	end
})

MiscTab:CreateLabel("Script made by nucax")
MiscTab:CreateLabel("discord.gg/uG5wXsFHjk")
