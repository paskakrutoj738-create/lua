-- ⚡ LUAVERSE MM2 | 3-BUTTON STABLE VERSION
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

-- == GUI ==
if LP.PlayerGui:FindFirstChild("LV_SIMPLE") then LP.PlayerGui.LV_SIMPLE:Destroy() end

local Gui = Instance.new("ScreenGui")
Gui.Name = "LV_SIMPLE"
Gui.ResetOnSpawn = false
Gui.DisplayOrder = 9999
Gui.Parent = LP.PlayerGui

-- Окно
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 200, 0, 180)
Main.Position = UDim2.new(0, 50, 0, 50)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Main.BorderSizePixel = 2
Main.BorderColor3 = Color3.fromRGB(100, 100, 255)
Main.Active = true
Main.Draggable = true
Main.Parent = Gui

-- Заголовок
Instance.new("TextLabel", {
    Size = UDim2.new(1, 0, 0, 25),
    BackgroundTransparency = 1,
    Text = "⚡ LUAVERSE MM2",
    TextColor3 = Color3.white,
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    Parent = Main
})

-- Функция создания простой кнопки
local function createSimpleBtn(text, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.Position = UDim2.new(0, 5, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    btn.Text = text
    btn.TextColor3 = Color3.white
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.AutoButtonColor = true -- Включает затемнение при нажатии
    btn.Parent = Main

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        -- Меняем цвет кнопки чтобы было видно состояние
        if state then
            btn.BackgroundColor3 = Color3.fromRGB(0, 150, 50) -- Зеленый
            btn.Text = "✅ " .. string.gsub(text, "❌ ", "")
        else
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60) -- Серый
            btn.Text = "❌ " .. string.gsub(text, "✅ ", "")
        end
        callback(state)
    end)
end

-- == СОЗДАЕМ 3 КНОПКИ ==

-- 1. ПОЛЕТ
createSimpleBtn("❌ No-Clip Fly", 30, function(v)
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

-- 2. ESP
createSimpleBtn("❌ ESP All", 70, function(v)
    Settings.ESP_All = v
    if not v then for _, o in pairs(espObjects) do o:Destroy() end; espObjects = {} end
end)

-- 3. АВТОСТРЕЛ
createSimpleBtn("❌ Auto Shoot", 110, function(v)
    Settings.AutoShoot = v
end)

-- Кнопка закрытия
local Close = Instance.new("TextButton")
Close.Size = UDim2.new(1, 0, 0, 25)
Close.Position = UDim2.new(0, 0, 1, -25)
Close.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
Close.Text = "CLOSE"
Close.TextColor3 = Color3.white
Close.Font = Enum.Font.GothamBlack
Close.TextSize = 12
Close.Parent = Main
Close.MouseButton1Click:Connect(function() Gui:Destroy() end)

-- == ЛОГИКА ==

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

-- Автострел
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

print("✅ 3-BUTTON MENU LOADED")
