local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Emergency Hamburg",
    LoadingTitle = "nucaxem",
    LoadingSubtitle = "YES PLWEASE",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "nucaxHamburg",
        FileName = "Rainbowhamburg"
    },
    Discord = {Enabled = false},
    KeySystem = false
})

local MainTab = Window:CreateTab("Main", 4483362458)
local AimbotTab = Window:CreateTab("Aimbot", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- State
local highlightEnabled = false
local noclipEnabled = false
local nameLabelsEnabled = false
local tracersEnabled = false
local aimbotEnabled = false
local aimbotSmoothness = 0.2
local aimbotFOV = 100
local miscDimLighting = false
local miscPartsTransparency = false

local tracerLines = {}
local fovCircle = nil

local function getRainbowColor(offset)
    local hue = (tick() * 0.5 + offset) % 1
    return Color3.fromHSV(hue, 1, 1)
end

local function applyHighlight(character, color)
    if not character then return end
    local highlight = character:FindFirstChildWhichIsA("Highlight")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Parent = character
    end
    highlight.FillColor = color
    highlight.OutlineColor = color
end

-- // Name Labels
local function applyNameLabel(player)
    if not player.Character then return end
    local head = player.Character:FindFirstChild("Head")
    if not head then return end
    if head:FindFirstChild("NameLabel") then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "NameLabel"
    billboard.Adornee = head
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0,120,0,30)
    billboard.StudsOffset = Vector3.new(0,2,0)
    billboard.Parent = head

    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "Text"
    textLabel.BackgroundTransparency = 1
    textLabel.Text = player.Name
    textLabel.TextScaled = true
    textLabel.TextStrokeTransparency = 0
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Size = UDim2.new(1,0,1,0)
    textLabel.Parent = billboard
end

-- // Cleanup
local function clearNameLabels()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Character then
            local head = plr.Character:FindFirstChild("Head")
            if head then
                local label = head:FindFirstChild("NameLabel")
                if label then label:Destroy() end
            end
        end
    end
end

local function clearHighlights()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Character then
            for _, v in pairs(plr.Character:GetChildren()) do
                if v:IsA("Highlight") then v:Destroy() end
            end
        end
    end
end

local function clearTracers()
    for _, line in pairs(tracerLines) do
        pcall(function() line:Remove() end)
    end
    tracerLines = {}
end

-- // FOV circle helpers
local function createFOVCircle()
    if fovCircle and pcall(function() return fovCircle.Radius end) then return end
    local ok, circle = pcall(function()
        return Drawing.new("Circle")
    end)
    if not ok or not circle then fovCircle=nil return end
    fovCircle = circle
    fovCircle.Visible = false
    fovCircle.Radius = aimbotFOV
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    fovCircle.Thickness = 2
    fovCircle.Filled = false
    fovCircle.Transparency = 1
end

local function removeFOVCircle()
    if fovCircle then
        pcall(function() fovCircle.Visible=false fovCircle:Remove() end)
        fovCircle = nil
    end
end

-- Closest player for aimbot
local function getClosestPlayerToCenter()
    local closest = nil
    local shortestDist = aimbotFOV
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local vec3, onScreen = Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
            if onScreen then
                local screenPos = Vector2.new(vec3.X, vec3.Y)
                local dist = (screenPos - center).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closest = plr
                end
            end
        end
    end
    return closest
end

-- // Update loop
RunService.RenderStepped:Connect(function()
    -- FOV circle
    if aimbotEnabled then
        createFOVCircle()
    end
    if fovCircle then
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        fovCircle.Radius = aimbotFOV
        fovCircle.Color = getRainbowColor(0.25)
        fovCircle.Visible = aimbotEnabled
    end

    -- Tracers
    if tracersEnabled then clearTracers() end

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local rainbowColor = getRainbowColor(plr.UserId % 10 / 10)

            if highlightEnabled then pcall(function() applyHighlight(plr.Character,rainbowColor) end) end
            if nameLabelsEnabled then
                pcall(function()
                    applyNameLabel(plr)
                    local head = plr.Character:FindFirstChild("Head")
                    if head then
                        local billboard = head:FindFirstChild("NameLabel")
                        if billboard and billboard:FindFirstChild("Text") then
                            billboard.Text.TextColor3 = rainbowColor
                        end
                    end
                end)
            end

            if tracersEnabled then
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local vec, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        local ok, line = pcall(function() return Drawing.new("Line") end)
                        if ok and line then
                            line.Visible = true
                            line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                            line.To = Vector2.new(vec.X, vec.Y)
                            line.Color = rainbowColor
                            line.Thickness = 1.5
                            line.Transparency = 1
                            table.insert(tracerLines,line)
                        end
                    end
                end
            end
        end
    end

    -- Noclip
    if noclipEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end

    -- Aimbot
    if aimbotEnabled then
        local target = getClosestPlayerToCenter()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local desiredCFrame = CFrame.new(Camera.CFrame.Position, target.Character.HumanoidRootPart.Position)
            local lerpAlpha = math.clamp(1-aimbotSmoothness,0.01,0.99)
            Camera.CFrame = Camera.CFrame:Lerp(desiredCFrame, lerpAlpha)
        end
    end

    -- Misc: Dim lighting
    if miscDimLighting then
        Lighting.Ambient = Color3.fromRGB(100,0,100)
        Lighting.OutdoorAmbient = Color3.fromRGB(100,0,100)
        Lighting.Brightness = 1
        Lighting.FogEnd = 500
    end

    -- Misc: Part transparency
    if miscPartsTransparency then
        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0.5
            end
        end
    end

    if not miscPartsTransparency then
        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0
            end
        end
    end
end)

-- // UI Toggles
MainTab:CreateToggle({Name="Rainbow Highlights",CurrentValue=false,Flag="RainbowHighlights",Callback=function(Value) highlightEnabled=Value if not Value then clearHighlights() end end})
MainTab:CreateToggle({Name="Rainbow Name Labels",CurrentValue=false,Flag="NameLabels",Callback=function(Value) nameLabelsEnabled=Value if not Value then clearNameLabels() end end})
MainTab:CreateToggle({Name="Noclip",CurrentValue=false,Flag="Noclip",Callback=function(Value) noclipEnabled=Value end})
MainTab:CreateToggle({Name="Tracers",CurrentValue=false,Flag="Tracers",Callback=function(Value) tracersEnabled=Value if not Value then clearTracers() end end})

-- Aimbot Tab
AimbotTab:CreateToggle({Name="Aimbot (mobile auto)",CurrentValue=false,Flag="AimbotToggle",Callback=function(Value) aimbotEnabled=Value if not Value then removeFOVCircle() end end})
AimbotTab:CreateSlider({Name="Smoothness (0=instant,1=slow)",Range={0,1},Increment=0.01,Suffix="",CurrentValue=0.2,Flag="AimbotSmoothness",Callback=function(Value) aimbotSmoothness=Value end})
AimbotTab:CreateSlider({Name="FOV Radius",Range={10,500},Increment=1,Suffix="px",CurrentValue=100,Flag="AimbotFOV",Callback=function(Value) aimbotFOV=Value if fovCircle then fovCircle.Radius=Value end end})

-- Misc Tab
MiscTab:CreateToggle({Name="Dim & Purple Lighting",CurrentValue=false,Flag="DimLighting",Callback=function(Value) miscDimLighting=Value end})
MiscTab:CreateToggle({Name="Parts 50% Opacity",CurrentValue=false,Flag="PartsOpacity",Callback=function(Value) miscPartsTransparency=Value end})
