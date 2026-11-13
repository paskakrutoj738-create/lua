-- ⚡ LUAVERSE MM2 HUB | Delta Stable Edition
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LP = Players.LocalPlayer

-- Ждем персонажа
local Character = LP.Character or LP.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Camera = workspace.CurrentCamera

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
Main.Size = UDim2.new(0, 260, 0, 320)
Main.Position = UDim2.new(0.5, -130, 0.5, -160)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Main.BorderSizePixel = 2
Main.BorderColor3 = Color3.fromRGB(80, 80, 150)
Main.Active = true
Main.Draggable = true -- ТАСКАТЬ ПАЛЬЦЕМ
Main.Parent = Gui

-- Header (Шапка)
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Header.BorderSizePixel = 0
Header.Parent = Main

Instance.new("TextLabel", {
    Size = UDim2.new(1, -70, 1, 0),
    Position = UDim2.new(0, 10, 0, 0),
    BackgroundTransparency = 1,
    Text = "⚡ LUAVERSE",
    TextColor3 = Color3.white,
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = Header
})

-- Кнопка Минус (Свернуть)
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 25, 0, 25)
MinBtn.Position = UDim2.new(1, -55, 0, 5)
MinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.white
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 18
MinBtn.AutoButtonColor = false
MinBtn.Parent = Header

-- Кнопка Крестик (Закрыть)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -28, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.white
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = Header

-- Вкладки
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 30)
TabBar.Position = UDim2.new(0, 0, 0, 35)
TabBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
TabBar.BorderSizePixel = 0
TabBar.Parent = Main

local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -10, 1, -75)
Content.Position = UDim2.new(0, 5, 0, 70)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 3
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Content.Parent = Main
Instance.new("UIListLayout", {Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder, Parent = Content})

-- Логика вкладок
local Pages = {}
local function createTab(name, xPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.5, 0, 1, 0)
    btn.Position = UDim2.new(xPos, 0, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.AutoButtonColor = false
    btn.Parent = TabBar
    
    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = (xPos == 0)
    page.Parent = Content
    Instance.new("UIListLayout", {Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder, Parent = page})
    
    Pages[name] = {Btn = btn, Page = page}
    
    btn.MouseButton1Click:Connect(function()
        for _, v in pairs(Pages) do
            v.Page.Visible = false
            v.Btn.TextColor3 = Color3.fromRGB(150, 150, 150)
            v.Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        end
        page.Visible = true
        btn.TextColor3 = Color3.white
        btn.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
    end)
    
    if xPos == 0 then 
        btn.TextColor3 = Color3.white
        btn.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
    end
    return page
end

local PageMove = createTab("Move", 0)
local PageVis = createTab("Visual", 0.5)

-- Элементы управления (Toggle)
local function addToggle(parent, text, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 28)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -35, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.white
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 25, 0, 18)
    btn.Position = UDim2.new(1, -30, 0.5, -9)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.Text = ""
    btn.Parent = frame
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(60, 60, 60)
        callback(state)
    end)
end

-- == ФУНКЦИИ ==

-- 1. FLY + NO-CLIP
addToggle(PageMove, "✈️ No-Clip Fly", function(v)
    isFlying = v
    if v then
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
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
        Humanoid.PlatformStand = false
        for _, p in pairs(Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = true end
        end
    end
end)

-- Полет логика
RunService.RenderStepped:Connect(function()
    if isFlying and bodyVelocity and RootPart then
        local moveDir = Humanoid.MoveDirection
        local camLook = Camera.CFrame.LookVector
        if moveDir.Magnitude > 0.1 then
            bodyVelocity.Velocity = camLook.Unit * Settings.FlySpeed * moveDir.Magnitude
            bodyGyro.CFrame = CFrame.lookAt(RootPart.Position, RootPart.Position + camLook.Unit)
        else
            bodyVelocity.Velocity = Vector3.zero
        end
    end
end)

-- 2. ESP ALL
addToggle(PageVis, "👁️ ESP All Players", function(v)
    Settings.ESP_All = v
    if not v then
        for _, obj in pairs(espObjects) do obj:Destroy() end
        espObjects = {}
    end
end)

task.spawn(function()
    while wait(0.5) do
        if Settings.ESP_All then
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
                        
                        if isMurderer then hl.FillColor = Color3.fromRGB(255, 50, 50)
                        elseif isSheriff then hl.FillColor = Color3.fromRGB(50, 150, 255)
                        else hl.FillColor = Color3.fromRGB(50, 255, 100) end
                    end
                end
            end
        end
    end
end)

-- 3. AUTO SHOOT
addToggle(PageVis, "🔫 Auto Shoot", function(v)
    Settings.AutoShoot = v
    if not v and shootConn then shootConn:Disconnect() end
end)

shootConn = RunService.RenderStepped:Connect(function()
    if Settings.AutoShoot then
        local gun = Character:FindFirstChild("Gun")
        if gun and gun:IsA("Tool") then
            local nearestPlr, nearestDist = nil, math.huge
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LP and plr.Character then
                    local hasKnife = plr.Character:FindFirstChild("Knife") or (plr.Backpack and plr.Backpack:FindFirstChild("Knife"))
                    if hasKnife then
                        local targetRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                        if targetRoot then
                            local dist = (RootPart.Position - targetRoot.Position).Magnitude
                            if dist < nearestDist and dist < 50 then
                                nearestDist = dist
                                nearestPlr = plr
                            end
                        end
                    end
                end
            end
            
            if nearestPlr then
                local targetRoot = nearestPlr.Character:FindFirstChild("HumanoidRootPart")
                Camera.CFrame = CFrame.lookAt(RootPart.Position, targetRoot.Position)
                pcall(function() gun:Activate() end)
                wait(0.4)
            end
        end
    end
end)

-- Управление кнопками окна
MinBtn.MouseButton1Click:Connect(function()
    Content.Visible = not Content.Visible
    TabBar.Visible = not TabBar.Visible
    Main.Size = Content.Visible and UDim2.new(0, 260, 0, 320) or UDim2.new(0, 260, 0, 35)
    MinBtn.Text = Content.Visible and "-" or "+"
end)

CloseBtn.MouseButton1Click:Connect(function()
    isFlying = false
    if bodyVelocity then bodyVelocity:Destroy() end
    Gui:Destroy()
end)

print("✅ LUAVERSE MM2 Loaded")
