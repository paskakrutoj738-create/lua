-- ⚡ LUAVERSE MM2 HUB | Delta Fixed Layout
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

local Character = LP.Character or LP.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Camera = workspace.CurrentCamera

local Settings = { FlySpeed = 80, AutoShoot = false, ESP_All = true }
local isFlying = false
local bodyVelocity, bodyGyro
local espObjects = {}
local shootConn

-- == GUI ==
if LP.PlayerGui:FindFirstChild("LV_HUB") then LP.PlayerGui.LV_HUB:Destroy() end

local Gui = Instance.new("ScreenGui")
Gui.Name = "LV_HUB"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = LP.PlayerGui

-- Основное окно
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 250, 0, 300)
Main.Position = UDim2.new(0.5, -125, 0.5, -150)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Main.BorderSizePixel = 2
Main.BorderColor3 = Color3.fromRGB(100, 100, 255)
Main.Active = true
Main.Draggable = true
Main.ClipsDescendants = true -- Важно для сворачивания
Main.Parent = Gui

-- Шапка
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
Header.BorderSizePixel = 0
Header.Parent = Main

Instance.new("TextLabel", {
    Size = UDim2.new(1, -70, 1, 0), Position = UDim2.new(0, 10, 0, 0),
    BackgroundTransparency = 1, Text = "⚡ LUAVERSE", TextColor3 = Color3.white,
    Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = Header
})

-- Кнопки управления окном
local function createWinBtn(text, pos, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 25, 0, 25)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.white
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.AutoButtonColor = false
    btn.Parent = Header
    btn.MouseButton1Click:Connect(callback)
end

createWinBtn("-", UDim2.new(1, -55, 0, 5), Color3.fromRGB(60,60,70), function()
    if Main.Size.Y.Offset > 40 then
        Main.Size = UDim2.new(0, 250, 0, 35) -- Свернуть
    else
        Main.Size = UDim2.new(0, 250, 0, 300) -- Развернуть
    end
end)

createWinBtn("X", UDim2.new(1, -28, 0, 5), Color3.fromRGB(150,50,50), function()
    Gui:Destroy()
end)

-- Контейнер для контента (Вместо ScrollingFrame используем обычный Frame)
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 1, -35)
Content.Position = UDim2.new(0, 0, 0, 35)
Content.BackgroundTransparency = 1
Content.Parent = Main

-- Вкладки (Кнопки)
local Tab1 = Instance.new("TextButton")
Tab1.Size = UDim2.new(0.5, 0, 0, 25)
Tab1.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
Tab1.Text = "Main"
Tab1.TextColor3 = Color3.white
Tab1.Font = Enum.Font.GothamBold
Tab1.TextSize = 12
Tab1.Parent = Content

local Tab2 = Instance.new("TextButton")
Tab2.Size = UDim2.new(0.5, 0, 0, 25)
Tab2.Position = UDim2.new(0.5, 0, 0, 0)
Tab2.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
Tab2.Text = "Combat"
Tab2.TextColor3 = Color3.fromRGB(150,150,150)
Tab2.Font = Enum.Font.GothamBold
Tab2.TextSize = 12
Tab2.Parent = Content

-- Страницы (Frame внутри Content)
local Page1 = Instance.new("Frame")
Page1.Size = UDim2.new(1, 0, 1, -25)
Page1.Position = UDim2.new(0, 0, 0, 25)
Page1.BackgroundTransparency = 1
Page1.Visible = true
Page1.Parent = Content

local Page2 = Instance.new("Frame")
Page2.Size = UDim2.new(1, 0, 1, -25)
Page2.Position = UDim2.new(0, 0, 0, 25)
Page2.BackgroundTransparency = 1
Page2.Visible = false
Page2.Parent = Content

-- Переключение вкладок
Tab1.MouseButton1Click:Connect(function()
    Page1.Visible = true; Page2.Visible = false
    Tab1.BackgroundColor3 = Color3.fromRGB(80,80,120); Tab1.TextColor3 = Color3.white
    Tab2.BackgroundColor3 = Color3.fromRGB(40,40,50); Tab2.TextColor3 = Color3.fromRGB(150,150,150)
end)

Tab2.MouseButton1Click:Connect(function()
    Page1.Visible = false; Page2.Visible = true
    Tab2.BackgroundColor3 = Color3.fromRGB(80,80,120); Tab2.TextColor3 = Color3.white
    Tab1.BackgroundColor3 = Color3.fromRGB(40,40,50); Tab1.TextColor3 = Color3.fromRGB(150,150,150)
end)

-- Функция создания кнопки-переключателя
local yPos = 5
local function addToggle(parent, text, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 30)
    frame.Position = UDim2.new(0, 5, 0, yPos)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    frame.Parent = parent
    yPos = yPos + 35 -- Сдвигаем следующую кнопку вниз

    Instance.new("TextLabel", {
        Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 5, 0, 0),
        BackgroundTransparency = 1, Text = text, TextColor3 = Color3.white,
        Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = frame
    })

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 30, 0, 20)
    btn.Position = UDim2.new(1, -35, 0.5, -10)
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

-- == ЗАПОЛНЕНИЕ ВКЛАДОК ==
yPos = 5 -- Сброс позиции для первой страницы

-- Вкладка 1: Движение
addToggle(Page1, "✈️ No-Clip Fly", function(v)
    isFlying = v
    if v then
        bodyVelocity = Instance.new("BodyVelocity"); bodyVelocity.MaxForce = Vector3.new(1e5,1e5,1e5); bodyVelocity.Parent = RootPart
        bodyGyro = Instance.new("BodyGyro"); bodyGyro.MaxTorque = Vector3.new(1e5,1e5,1e5); bodyGyro.P = 9000; bodyGyro.Parent = RootPart
        Humanoid.PlatformStand = true
        for _, p in pairs(Character:GetDescendants()) do if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.CanCollide = false end end
    else
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
        Humanoid.PlatformStand = false
        for _, p in pairs(Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end
    end
end)

yPos = 5 -- Сброс позиции для второй страницы

-- Вкладка 2: Бой и Визуал
addToggle(Page2, "👁️ ESP All", function(v)
    Settings.ESP_All = v
    if not v then for _, o in pairs(espObjects) do o:Destroy() end; espObjects = {} end
end)

addToggle(Page2, "🔫 Auto Shoot", function(v)
    Settings.AutoShoot = v
end)

-- == ЛОГИКА СКРИПТА ==

-- Полет
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

-- ESP
task.spawn(function()
    while wait(0.5) do
        if Settings.ESP_All then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LP and plr.Character then
                    local root = plr.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        if not espObjects[plr] then
                            local hl = Instance.new("Highlight")
                            hl.FillTransparency = 0.7; hl.OutlineTransparency = 0.2
                            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            hl.Adornee = plr.Character; hl.Parent = plr.Character
                            espObjects[plr] = hl
                        end
                        local hl = espObjects[plr]
                        local isM = plr.Character:FindFirstChild("Knife") or (plr.Backpack and plr.Backpack:FindFirstChild("Knife"))
                        local isS = plr.Character:FindFirstChild("Gun") or (plr.Backpack and plr.Backpack:FindFirstChild("Gun"))
                        if isM then hl.FillColor = Color3.fromRGB(255, 50, 50)
                        elseif isS then hl.FillColor = Color3.fromRGB(50, 150, 255)
                        else hl.FillColor = Color3.fromRGB(50, 255, 100) end
                    end
                end
            end
        end
    end
end)

-- Auto Shoot
shootConn = RunService.RenderStepped:Connect(function()
    if Settings.AutoShoot then
        local gun = Character:FindFirstChild("Gun")
        if gun and gun:IsA("Tool") then
            local nearest, dist = nil, math.huge
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LP and plr.Character then
                    local hasK = plr.Character:FindFirstChild("Knife") or (plr.Backpack and plr.Backpack:FindFirstChild("Knife"))
                    if hasK then
                        local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                        if tRoot then
                            local d = (RootPart.Position - tRoot.Position).Magnitude
                            if d < dist and d < 50 then dist = d; nearest = plr end
                        end
                    end
                end
            end
            if nearest then
                local tRoot = nearest.Character:FindFirstChild("HumanoidRootPart")
                Camera.CFrame = CFrame.lookAt(RootPart.Position, tRoot.Position)
                pcall(function() gun:Activate() end)
                wait(0.4)
            end
        end
    end
end)

print("✅ LUAVERSE MM2 Loaded")
