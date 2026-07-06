local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Gakuran_HUD_V5_Mobile"
screenGui.ResetOnSpawn = false
if gethui then 
    screenGui.Parent = gethui() 
elseif syn and syn.protect_gui then 
    syn.protect_gui(screenGui)
    screenGui.Parent = game:GetService("CoreGui")
else
    screenGui.Parent = game:GetService("CoreGui")
end

-- ==========================================
-- SMART DRAG FUNCTION
-- ==========================================
local function makeDraggable(gui, onClickCallback)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    local hasDragged = false

    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            hasDragged = false
            dragStart = input.Position
            startPos = gui.Position
        end
    end)

    gui.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then
                hasDragged = true
                gui.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X, 
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end
    end)

    gui.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            if not hasDragged and onClickCallback then
                onClickCallback()
            end
        end
    end)
end

-- ==========================================
-- MOBILE TOGGLE BUTTON
-- ==========================================
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0, 15, 0, 15)
toggleBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
toggleBtn.BackgroundTransparency = 0.2
toggleBtn.BorderSizePixel = 0
toggleBtn.Text = "HUD"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
toggleBtn.Active = true
toggleBtn.Parent = screenGui

Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)

-- ==========================================
-- MAIN MENU FRAME
-- ==========================================
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 240, 0, 120)
mainFrame.Position = UDim2.new(1, -260, 0, 45)
mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Visible = false
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

makeDraggable(mainFrame, nil)
makeDraggable(toggleBtn, function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- HP Label (Self)
local hpText = Instance.new("TextLabel")
hpText.Size = UDim2.new(1, -20, 0, 30)
hpText.Position = UDim2.new(0, 12, 0, 8)
hpText.BackgroundTransparency = 1
hpText.TextColor3 = Color3.fromRGB(255, 80, 80)
hpText.TextSize = 16
hpText.Font = Enum.Font.GothamBold
hpText.TextXAlignment = Enum.TextXAlignment.Left
hpText.Text = "HP: ..."
hpText.Parent = mainFrame

-- Stamina Label (Self)
local stamText = Instance.new("TextLabel")
stamText.Size = UDim2.new(1, -20, 0, 30)
stamText.Position = UDim2.new(0, 12, 0, 40)
stamText.BackgroundTransparency = 1
stamText.TextColor3 = Color3.fromRGB(255, 180, 60)
stamText.TextSize = 16
stamText.Font = Enum.Font.GothamBold
stamText.TextXAlignment = Enum.TextXAlignment.Left
stamText.Text = "STAMINA: ..."
stamText.Parent = mainFrame

-- ESP Toggle Button
local espToggleBtn = Instance.new("TextButton")
espToggleBtn.Size = UDim2.new(1, -24, 0, 30)
espToggleBtn.Position = UDim2.new(0, 12, 0, 80)
espToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
espToggleBtn.BackgroundTransparency = 0.3
espToggleBtn.Text = "ESP (Proximity): OFF"
espToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
espToggleBtn.Font = Enum.Font.GothamBold
espToggleBtn.TextSize = 14
espToggleBtn.Parent = mainFrame

Instance.new("UICorner", espToggleBtn).CornerRadius = UDim.new(0, 6)

local espEnabled = false
espToggleBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espToggleBtn.Text = "ESP (Proximity): " .. (espEnabled and "ON" or "OFF")
    espToggleBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(40, 40, 45)
end)

-- ==========================================
-- SELF HP / STAMINA LOGIC (unchanged)
-- ==========================================
local hum = nil
local hpConn = nil

local function updateHp()
    if hum then
        hpText.Text = string.format("HP  %.0f / %.0f", hum.Health, hum.MaxHealth)
    end
end

local function setupCharacter(char)
    hum = char:WaitForChild("Humanoid", 5)
    if hpConn then hpConn:Disconnect() end
    if hum then
        hpConn = hum:GetPropertyChangedSignal("Health"):Connect(updateHp)
        updateHp()
    else
        hpText.Text = "HP: Error"
    end
end

if player.Character then setupCharacter(player.Character) end
player.CharacterAdded:Connect(setupCharacter)

-- Gakuran Stamina Logic (kept as-is)
local staminaSource = nil
local sourceType = nil
local lastStamVal = -1

local function findPhysicalStamina()
    local char = player.Character
    if not char then return nil, nil end
    local stats = char:FindFirstChild("Stats") or char:FindFirstChild("Data") or char:FindFirstChild("Folder")
    if stats then
        local stamObj = stats:FindFirstChild("Stamina") or stats:FindFirstChild("stamina") or stats:FindFirstChild("Energy")
        if stamObj and stamObj:IsA("ValueObject") then return stamObj, "Value" end
    end
    local directStam = char:FindFirstChild("Stamina") or char:FindFirstChild("stamina")
    if directStam and directStam:IsA("ValueObject") then return directStam, "Value" end
    if char:GetAttribute("Stamina") ~= nil then return "CharAttribute", "Attribute"
    elseif player:GetAttribute("Stamina") ~= nil then return "PlayerAttribute", "Attribute" end
    return nil, nil
end

local function findGCRelatedStamina()
    if not getgc then return nil, nil end
    local gctables = getgc()
    for _, v in pairs(gctables) do
        if type(v) == "table" then
            local hasStam = rawget(v, "Stamina") or rawget(v, "stamina") or rawget(v, "_stamina")
            if hasStam and type(hasStam) == "number" then
                local isCombatTable = rawget(v, "Posture") or rawget(v, "MaxStamina") or rawget(v, "Blocking") or rawget(v, "Stunned") or rawget(v, "MaxStam")
                if isCombatTable then return v, "Table" end
            end
        end
    end
    return nil, nil
end

local function resolveStaminaSource()
    local src, t = findPhysicalStamina()
    if src then staminaSource = src; sourceType = t; return end
    src, t = findGCRelatedStamina()
    if src then staminaSource = src; sourceType = t; return end
    staminaSource = nil; sourceType = nil
end

player.CharacterRemoving:Connect(function()
    staminaSource = nil; sourceType = nil; lastStamVal = -1
end)

task.spawn(function()
    local scanCooldown = 0
    while task.wait(0.05) do
        if not staminaSource then
            if tick() - scanCooldown > 3 then
                scanCooldown = tick()
                resolveStaminaSource()
            end
            if mainFrame.Visible then
                stamText.Text = "STAMINA: Searching..."
            end
            continue
        end

        if not mainFrame.Visible then continue end

        local currentStam = nil
        local success = pcall(function()
            if sourceType == "Value" then currentStam = staminaSource.Value
            elseif sourceType == "Attribute" then
                local char = player.Character
                if staminaSource == "CharAttribute" and char then currentStam = char:GetAttribute("Stamina")
                else currentStam = player:GetAttribute("Stamina") end
            elseif sourceType == "Table" then
                currentStam = rawget(staminaSource, "Stamina") or rawget(staminaSource, "stamina") or rawget(staminaSource, "_stamina")
            end
        end)

        if not success or currentStam == nil then
            staminaSource = nil; sourceType = nil
            continue
        end

        if currentStam ~= lastStamVal then
            lastStamVal = currentStam
            stamText.Text = string.format("STAMINA  %.0f", currentStam)
            if currentStam < 30 then stamText.TextColor3 = Color3.fromRGB(255, 100, 100)
            else stamText.TextColor3 = Color3.fromRGB(255, 180, 60) end
        end
    end
end)

-- ==========================================
-- PROXIMITY ESP (Health + Stamina, No Wallhack, Low Lag)
-- ==========================================
local espObjects = {}  -- player -> {frame, hpLabel, stamLabel}

local function createESPFor(plr)
    if plr == player then return end
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 180, 0, 60)
    frame.BackgroundTransparency = 0.6
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BorderSizePixel = 0
    frame.Visible = false
    frame.Parent = screenGui
    
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Text = plr.Name
    nameLabel.Parent = frame
    
    local hpLabel = Instance.new("TextLabel")
    hpLabel.Size = UDim2.new(1, 0, 0, 20)
    hpLabel.Position = UDim2.new(0, 0, 0, 20)
    hpLabel.BackgroundTransparency = 1
    hpLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    hpLabel.TextSize = 13
    hpLabel.Font = Enum.Font.Gotham
    hpLabel.Text = "HP: --"
    hpLabel.Parent = frame
    
    local stamLabel = Instance.new("TextLabel")
    stamLabel.Size = UDim2.new(1, 0, 0, 20)
    stamLabel.Position = UDim2.new(0, 0, 0, 40)
    stamLabel.BackgroundTransparency = 1
    stamLabel.TextColor3 = Color3.fromRGB(255, 180, 60)
    stamLabel.TextSize = 13
    stamLabel.Font = Enum.Font.Gotham
    stamLabel.Text = "STAM: --"
    stamLabel.Parent = frame
    
    espObjects[plr] = {frame = frame, hpLabel = hpLabel, stamLabel = stamLabel}
end

-- Cleanup on player leave
Players.PlayerRemoving:Connect(function(plr)
    if espObjects[plr] then
        espObjects[plr].frame:Destroy()
        espObjects[plr] = nil
    end
end)

-- Create ESP for existing players
for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= player then
        createESPFor(plr)
    end
end
Players.PlayerAdded:Connect(createESPFor)

-- Main ESP Update Loop (proximity + line-of-sight check to avoid walls)
local camera = workspace.CurrentCamera

RunService.RenderStepped:Connect(function()
    if not espEnabled then 
        for _, data in pairs(espObjects) do
            data.frame.Visible = false
        end
        return 
    end
    
    local myChar = player.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    
    local myHum = myChar:FindFirstChild("Humanoid")
    
    for plr, data in pairs(espObjects) do
        local char = plr.Character
        if not char then 
            data.frame.Visible = false
            continue 
        end
        
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if not root or not hum then 
            data.frame.Visible = false
            continue 
        end
        
        -- Proximity filter (reduce lag)
        local dist = (root.Position - myRoot.Position).Magnitude
        if dist > 80 then  -- adjustable proximity
            data.frame.Visible = false
            continue
        end
        
        -- Line of sight (anti-wall)
        local ray = Ray.new(myRoot.Position, (root.Position - myRoot.Position).Unit * dist)
        local hit, _ = workspace:FindPartOnRayWithIgnoreList(ray, {myChar, char})
        if hit then 
            data.frame.Visible = false
            continue
        end
        
        -- Update info
        data.hpLabel.Text = string.format("HP: %.0f / %.0f", hum.Health, hum.MaxHealth)
        
        -- Try to grab stamina (same logic as self)
        local stamVal = "??"
        local stats = char:FindFirstChild("Stats") or char:FindFirstChild("Data")
        if stats then
            local s = stats:FindFirstChild("Stamina") or stats:FindFirstChild("stamina")
            if s and s:IsA("NumberValue") then stamVal = math.floor(s.Value) end
        end
        data.stamLabel.Text = "STAM: " .. stamVal
        
        -- World to Screen
        local screenPos, onScreen = camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0))
        if onScreen then
            data.frame.Position = UDim2.new(0, screenPos.X - 90, 0, screenPos.Y - 40)
            data.frame.Visible = true
        else
            data.frame.Visible = false
        end
    end
end)

-- INSERT keybind
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.Insert then
        mainFrame.Visible = not mainFrame.Visible
    end
end)
