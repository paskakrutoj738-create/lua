-- ⚡ LUAVERSE MM2 | Ultimate Hub
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LP = Players.LocalPlayer

-- Ждем загрузки
local Character = LP.Character or LP.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Camera = workspace.CurrentCamera

-- Настройки
local Settings = {
    FlySpeed = 80,
    AutoShoot = false,
    ESP_All = true
}

local isFlying = false
local bodyVelocity, bodyGyro
local espObjects = {}
local shootConn

-- == GUI SYSTEM ==
if LP.PlayerGui:FindFirstChild("LV_HUB") then LP.PlayerGui.LV_HUB:Destroy() end

local Gui = Instance.new("ScreenGui")
Gui.Name = "LV_HUB"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = LP.PlayerGui

-- Main Frame
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 280, 0, 350)
Main.Position = UDim2.new(0.5, -140, 0.5, -175)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true -- Встроенное перетаскивание
Main.Parent = Gui
Instance.new("UICorner", {CornerRadius = UDim.new(0, 12), Parent = Main})
Instance.new("UIStroke", {Color = Color3.fromRGB(100, 100, 255), Thickness = 1, Parent = Main})

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
Header.BorderSizePixel = 0
Header.Parent = Main
Instance.new("UICorner", {CornerRadius = UDim.new(0, 12), Parent = Header})
Instance.new("Frame", {Size = UDim2.new(1,0,0,12), Position = UDim2.new(0,0,1,-12), BackgroundColor3 = Color3.fromRGB(30,30,45), BorderSizePixel=0, Parent = Header})

Instance.new("TextLabel", {
    Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1,
    Text = "⚡ LUAVERSE MM2", TextColor3 = Color3.white,
    Font = Enum.Font.GothamBold, TextSize = 16, Parent = Header
})

-- Tabs
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, -10, 0, 30)
TabFrame.Position = UDim2.new(0, 5, 0, 45)
TabFrame.BackgroundTransparency = 1
TabFrame.Parent = Main

local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Size = UDim2.new(1, -10, 1, -90)
ContentFrame.Position = UDim2.new(0, 5, 0, 80)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 4
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentFrame.Parent = Main
Instance.new("UIListLayout", {Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder, Parent = ContentFrame})

local function createTab(name, xPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.5, -2, 1, 0)
    btn.Position = UDim2.new(xPos, 0, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    btn.Text = name
    btn.TextColor3 = Color3.white
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.AutoButtonColor = false
    btn.Parent = TabFrame
    Instance.new("UICorner", {CornerRadius = UDim.new(0, 6), Parent = btn})
    
    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = (xPos == 0)
    page.Parent = ContentFrame
    Instance.new("UIListLayout", {Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder, Parent = page})

    btn.MouseButton1Click:Connect(function()
        for _, child in pairs(TabFrame:GetChildren()) do
            if child:IsA("TextButton") then child.BackgroundColor3 = Color3.fromRGB(40,40,55) end
        end
        btn.BackgroundColor3 = Color3.fromRGB(80, 80, 150)
        for _, p in pairs(ContentFrame:GetChildren()) do
            if p:IsA("Frame") then p.Visible = false end
        end
        page.Visible = true
    end)
    
    if xPos == 0 then btn.BackgroundColor3 = Color3.fromRGB(80, 80, 150) end
    return page
end

local Page1 = createTab("Movement", 0)
local Page2 = createTab("Visual", 0.5)
local Page3 = createTab("Combat", 1) -- Исправлено для 3 вкладок, но пока оставим 2 для простоты, добавим в Page2

-- UI Helpers
local function addToggle(parent, text, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    frame.Parent = parent
    Instance.new("UICorner", {CornerRadius = UDim.new(0, 6), Parent = frame})
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -40, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.white
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 30, 0, 20)
    btn.Position = UDim2.new(1, -35, 0.5, -10)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.Text = ""
    btn.Parent = frame
    Instance.new("UICorner", {CornerRadius = UDim.new(0, 4), Parent = btn})
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(60, 60, 60)
        callback(state)
    end)
end

-- == MOVEMENT ==
addToggle(Page1, "✈️ No-Clip Fly", function(v)
    isFlying = v
    if v then
        -- Start Fly Logic
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(1e5,1e5,1e5)
        bodyVelocity.Parent = RootPart
        
        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(1e5,1e5,1e5)
        bodyGyro.P = 9000
        bodyGyro.Parent = RootPart
        
        Humanoid.PlatformStand = true
        for _, p in pairs(Character:GetDescendants()) do
            if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.CanCollide = false end
        end
    else
        -- Stop Fly Logic
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
        Humanoid.PlatformStand = false
        for _, p in pairs(Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = true end
        end
    end
end)

-- == VISUAL (ESP FOR ALL) ==
addToggle(Page2, "👁️ ESP All Players", function(v)
    Settings.ESP_All = v
    if not v then
        for _, obj in pairs(espObjects) do obj:Destroy() end
        espObjects = {}
    end
end)

local function updateESP()
    if not Settings.ESP_All then return end
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            if root then
                if not espObjects[plr] then
                    local hl = Instance.new("Highlight")
                    hl.FillTransparency = 0.7
                    hl.OutlineTransparency = 0.2
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Adornee = plr.Character
                    hl.Parent = plr.Character
                    espObjects[plr] = hl
                end
                
                local hl = espObjects[plr]
                local isMurderer = plr.Character:FindFirstChild("Knife") or (plr.Backpack and plr.Backpack:FindFirstChild("Knife"))
                local isSheriff = plr.Character:FindFirstChild("Gun") or (plr.Backpack and plr.Backpack:FindFirstChild("Gun"))
                
                if isMurderer then
                    hl.FillColor = Color3.fromRGB(255, 50, 50) -- Red
                elseif isSheriff then
                    hl.FillColor = Color3.fromRGB(50, 150, 255) -- Blue
                else
                    hl.FillColor = Color3.fromRGB(50, 255, 100) -- Green (Innocent)
                end
            end
        end
    end
end
task.spawn(function() while wait(0.5) do pcall(updateESP) end end)

-- == COMBAT (AUTO SHOOT) ==
addToggle(Page3, "🔫 Auto Shoot (Sheriff)", function(v)
    Settings.AutoShoot = v
    if not v and shootConn then shootConn:Disconnect() end
end)

shootConn = RunService.RenderStepped:Connect(function()
    if Settings.AutoShoot then
        local gun = Character:FindFirstChild("Gun")
        if gun and gun:IsA("Tool") then
            -- Find nearest Murderer
            local nearestPlr, nearestDist = nil, math.huge
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LP and plr.Character then
                    local hasKnife = plr.Character:FindFirstChild("Knife") or (plr.Backpack and plr.Backpack:FindFirstChild("Knife"))
                    if hasKnife then
                        local targetRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                        if targetRoot then
                            local dist = (RootPart.Position - targetRoot.Position).Magnitude
                            if dist < nearestDist and dist < 50 then -- Range 50 studs
                                nearestDist = dist
                                nearestPlr = plr
                            end
                        end
                    end
                end
            end
            
            if nearestPlr then
                -- Aim at murderer
                local targetRoot = nearestPlr.Character:FindFirstChild("HumanoidRootPart")
                Camera.CFrame = CFrame.lookAt(RootPart.Position, targetRoot.Position)
                
                -- Shoot
                pcall(function()
                    gun:Activate()
                    wait(0.4) -- Fire rate
                end)
            end
        end
    end
end)

print("✅ LUAVERSE MM2 Loaded")
