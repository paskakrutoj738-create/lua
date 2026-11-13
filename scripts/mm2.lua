-- ⚡ LUAVERSE MM2 | Delta 100% Working Menu
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

-- Ждем персонажа и его загрузку
local Character = LP.Character or LP.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Camera = workspace.CurrentCamera

local Settings = { FlySpeed = 80, AutoShoot = false, ESP_All = true }
local isFlying = false
local bodyVelocity, bodyGyro
local espObjects = {}

-- == 1. ОЧИСТКА И СОЗДАНИЕ GUI ==
if LP.PlayerGui:FindFirstChild("LV_HUB") then LP.PlayerGui.LV_HUB:Destroy() end

local Gui = Instance.new("ScreenGui")
Gui.Name = "LV_HUB"
Gui.ResetOnSpawn = false
Gui.DisplayOrder = 1000 -- Высокий приоритет отображения
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = LP.PlayerGui

-- Главное окно (Frame)
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 240, 0, 280)
Main.Position = UDim2.new(0.5, -120, 0.5, -140)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Main.BorderSizePixel = 2
Main.BorderColor3 = Color3.fromRGB(100, 100, 255)
Main.Active = true
Main.Draggable = true
Main.ClipsDescendants = true
Main.Visible = true -- Принудительно включаем видимость
Main.Parent = Gui

-- Шапка (Header)
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
Header.BorderSizePixel = 0
Header.Parent = Main

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 5, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ LUAVERSE"
Title.TextColor3 = Color3.white
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Кнопка закрытия (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "Close"
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -28, 0, 2)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.white
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = Header

-- Контент (Вместо скролла используем простой Frame)
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, 0, 1, -30)
Content.Position = UDim2.new(0, 0, 0, 30)
Content.BackgroundTransparency = 1
Content.Parent = Main

-- == 2. ФУНКЦИЯ СОЗДАНИЯ КНОПОК (Жесткие координаты) ==
local function createButton(yPos, text, callback)
    local btnFrame = Instance.new("Frame")
    btnFrame.Size = UDim2.new(1, -10, 0, 30)
    btnFrame.Position = UDim2.new(0, 5, 0, yPos)
    btnFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    btnFrame.Parent = Content

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -40, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.white
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = btnFrame

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 30, 0, 20)
    toggleBtn.Position = UDim2.new(1, -35, 0.5, -10)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    toggleBtn.Text = ""
    toggleBtn.Parent = btnFrame

    local state = false
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(60, 60, 60)
        callback(state)
    end)
end

-- == 3. ДОБАВЛЕНИЕ КНОПОК В МЕНЮ ==
createButton(10, "✈️ No-Clip Fly", function(v)
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

createButton(45, "👁️ ESP All Players", function(v)
    Settings.ESP_All = v
    if not v then for _, o in pairs(espObjects) do o:Destroy() end; espObjects = {} end
end)

createButton(80, "🔫 Auto Shoot", function(v)
    Settings.AutoShoot = v
end)

-- == 4. ЛОГИКА СКРИПТА ==

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
RunService.RenderStepped:Connect(function()
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

-- Закрытие меню
CloseBtn.MouseButton1Click:Connect(function()
    Gui:Destroy()
end)

print("✅ Меню создано и функции загружены!")
