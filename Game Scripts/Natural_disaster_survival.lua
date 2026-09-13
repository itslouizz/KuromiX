-- this script has been made by nucax
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

local autoFarmEnabled = false
local darkMode = false
local spawnPosition = Vector3.new(-246.7, 180.1, 326.7)
local mapPosition = Vector3.new(-125.0, 48.1, 14.5)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "i bet youre using dex"
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local function createButton(name, position, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 200, 0, 50)
    button.Position = position
    button.Text = name
    button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    button.TextColor3 = Color3.fromRGB(0, 0, 0)
    button.Parent = ScreenGui
    button.MouseButton1Click:Connect(callback)
    return button
end

local tpButton = createButton("Tp to Spawn", UDim2.new(0, 50, 0, 50), function()
    hrp.CFrame = CFrame.new(spawnPosition)
end)

local tpMapButton = createButton("Tp to Map", UDim2.new(0, 50, 0, 120), function()
    hrp.CFrame = CFrame.new(mapPosition)
end)

local toggleButton = createButton("Auto Farm: OFF", UDim2.new(0, 50, 0, 190), function()
    autoFarmEnabled = not autoFarmEnabled
end)

local githubButton = createButton("https://github.com/nucax", UDim2.new(0, 50, 0, 260), function()
    if syn then
        syn.request({Url = "https://github.com/nucax", Method = "GET"})
    else
        setclipboard("https://github.com/nucax")
    end
end)

local closeButton = createButton("Close GUI", UDim2.new(0, 50, 0, 330), function()
    ScreenGui:Destroy()
end)

local themeButton
local buttons = {}

themeButton = createButton("Toggle White/Black GUI", UDim2.new(0, 50, 0, 400), function()
    darkMode = not darkMode
    local bg = darkMode and Color3.fromRGB(0,0,0) or Color3.fromRGB(255,255,255)
    local fg = darkMode and Color3.fromRGB(255,255,255) or Color3.fromRGB(0,0,0)
    for _, btn in ipairs(buttons) do
        btn.BackgroundColor3 = bg
        btn.TextColor3 = fg
    end
end)

buttons = {tpButton, tpMapButton, toggleButton, githubButton, closeButton, themeButton}

RunService.RenderStepped:Connect(function()
    if autoFarmEnabled then
        hrp.CFrame = CFrame.new(spawnPosition)
    end
end)

RunService.RenderStepped:Connect(function()
    toggleButton.Text = autoFarmEnabled and "Auto Farm: ON" or "Auto Farm: OFF"
end)
