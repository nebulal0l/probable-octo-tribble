local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer

-- Function to create rainbow effect
local function createRainbowTween(frame)
    local colors = {
        Color3.fromRGB(255, 0, 0),    -- Red
        Color3.fromRGB(255, 127, 0),  -- Orange
        Color3.fromRGB(255, 255, 0),  -- Yellow
        Color3.fromRGB(0, 255, 0),    -- Green
        Color3.fromRGB(0, 0, 255),    -- Blue
        Color3.fromRGB(75, 0, 130),   -- Indigo
        Color3.fromRGB(148, 0, 211)   -- Violet
    }
    
    local currentColorIndex = 1
    
    local function updateColor()
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
        local tween = TweenService:Create(frame, tweenInfo, {BackgroundColor3 = colors[currentColorIndex]})
        tween:Play()
        
        currentColorIndex = currentColorIndex + 1
        if currentColorIndex > #colors then
            currentColorIndex = 1
        end
    end
    
    -- Start the rainbow effect
    local connection
    connection = RunService.Heartbeat:Connect(function()
        wait(0.5)
        updateColor()
    end)
    
    return connection
end

-- Create the main ESP box template
local function createESPBox()
    local gui = Instance.new("BillboardGui")
    gui.Name = "ESP_Box"
    gui.AlwaysOnTop = true
    gui.LightInfluence = 0
    gui.Size = UDim2.new(2, 0, 2.5, 0)
    gui.StudsOffset = Vector3.new(0, 1, 0)
    
    -- Main container frame
    local container = Instance.new("Frame", gui)
    container.Name = "Container"
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 1, 0)
    
    -- Name label
    local nameLabel = Instance.new("TextLabel", container)
    nameLabel.Name = "NameLabel"
    nameLabel.BackgroundTransparency = 1
    nameLabel.Size = UDim2.new(1, 0, 0.2, 0)
    nameLabel.Position = UDim2.new(0, 0, -0.25, 0)
    nameLabel.Text = "Player"
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextScaled = true
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.Font = Enum.Font.GothamBold
    
    -- Main ESP frame (the box)
    local frame = Instance.new("Frame", container)
    frame.Name = "ESPFrame"
    frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Starting color
    frame.Size = UDim2.new(0.8, 0, 0.8, 0)
    frame.Position = UDim2.new(0.1, 0, 0.1, 0)
    frame.BorderSizePixel = 3
    frame.BorderColor3 = Color3.fromRGB(255, 255, 255)
    
    -- Add corner rounding for modern look
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 8)
    
    -- Add glow effect
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 2
    stroke.Transparency = 0.3
    
    -- Health bar background
    local healthBarBG = Instance.new("Frame", container)
    healthBarBG.Name = "HealthBarBG"
    healthBarBG.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    healthBarBG.Size = UDim2.new(0.1, 0, 0.8, 0)
    healthBarBG.Position = UDim2.new(-0.15, 0, 0.1, 0)
    healthBarBG.BorderSizePixel = 1
    healthBarBG.BorderColor3 = Color3.fromRGB(255, 255, 255)
    
    local healthCorner = Instance.new("UICorner", healthBarBG)
    healthCorner.CornerRadius = UDim.new(0, 4)
    
    -- Health bar
    local healthBar = Instance.new("Frame", healthBarBG)
    healthBar.Name = "HealthBar"
    healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthBar.Size = UDim2.new(1, 0, 1, 0)
    healthBar.Position = UDim2.new(0, 0, 0, 0)
    healthBar.BorderSizePixel = 0
    
    local healthBarCorner = Instance.new("UICorner", healthBar)
    healthBarCorner.CornerRadius = UDim.new(0, 4)
    
    return gui
end

-- Function to update health bar
local function updateHealthBar(gui, character)
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        local healthBar = gui.Container.HealthBarBG.HealthBar
        local healthPercent = humanoid.Health / humanoid.MaxHealth
        healthBar.Size = UDim2.new(1, 0, healthPercent, 0)
        healthBar.Position = UDim2.new(0, 0, 1 - healthPercent, 0)
        
        -- Change color based on health
        if healthPercent > 0.6 then
            healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Green
        elseif healthPercent > 0.3 then
            healthBar.BackgroundColor3 = Color3.fromRGB(255, 255, 0) -- Yellow
        else
            healthBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Red
        end
    end
end

-- Store connections for cleanup
local connections = {}

-- Function to add ESP to a player
local function addESP(player)
    if player == localPlayer then return end
    
    local character = player.Character or player.CharacterAdded:Wait()
    local head = character:WaitForChild("Head")
    
    -- Create ESP box
    local espGui = createESPBox()
    espGui.Container.NameLabel.Text = player.Name
    espGui.Parent = head
    
    -- Start rainbow effect
    local rainbowConnection = createRainbowTween(espGui.Container.ESPFrame)
    connections[player.Name .. "_rainbow"] = rainbowConnection
    
    -- Health bar update connection
    local healthConnection = RunService.Heartbeat:Connect(function()
        if character.Parent and character:FindFirstChild("Humanoid") then
            updateHealthBar(espGui, character)
        end
    end)
    connections[player.Name .. "_health"] = healthConnection
    
    -- Clean up when player leaves or character is removed
    local function cleanup()
        if connections[player.Name .. "_rainbow"] then
            connections[player.Name .. "_rainbow"]:Disconnect()
            connections[player.Name .. "_rainbow"] = nil
        end
        if connections[player.Name .. "_health"] then
            connections[player.Name .. "_health"]:Disconnect()
            connections[player.Name .. "_health"] = nil
        end
    end
    
    player.AncestryChanged:Connect(cleanup)
    character.AncestryChanged:Connect(cleanup)
end

-- Add ESP to existing players
for _, player in pairs(Players:GetPlayers()) do
    if player.Character then
        addESP(player)
    end
end

-- Add ESP to new players
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        addESP(player)
    end)
end)

-- Handle when existing players spawn
Players.PlayerAdded:Connect(addESP)
