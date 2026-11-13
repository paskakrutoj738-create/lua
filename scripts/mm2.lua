-- ⚡ LUAVERSE MM2 | EMERGENCY VERSION
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

-- == 1. СОЗДАНИЕ ЧЕРЕЗ STARTERGUI (ИНОГДА РАБОТАЕТ ЛУЧШЕ) ==
if game.StarterGui:FindFirstChild("LV_EMERGENCY") then 
    game.StarterGui.LV_EMERGENCY:Destroy() 
end

local Gui = Instance.new("ScreenGui")
Gui.Name = "LV_EMERGENCY"
Gui.ResetOnSpawn = false
Gui.DisplayOrder = 9999 -- Максимальный приоритет
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = LP.PlayerGui

-- Яркое окно, чтобы его точно было видно
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 200, 0, 200)
Main.Position = UDim2.new(0, 50, 0, 50) -- Фиксированная позиция в углу
Main.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Черный фон
Main.BorderSizePixel = 4 -- Толстая рамка
Main.BorderColor3 = Color3.fromRGB(255, 0, 0) -- КРАСНАЯ РАМКА (чтобы видеть границы)
Main.Active = true
Main.Draggable = true
Main.Parent = Gui

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "⚡ LUAVERSE"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 16
Title.Parent = Main

-- Кнопки функций (Простые TextButton)
local function addBigBtn(text, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.Position = UDim2.new(0, 5, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.Text = text
    btn.TextColor3 = Color3.white
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.AutoButtonColor = true
    btn.Parent = Main
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
        btn.Text = (state and "[ON] " or "[OFF] ") .. string.gsub(text, "%[ON%] ", "")
        btn.Text = string.gsub(btn.Text, "%[OFF%] ", "")
        if state then btn.Text = "[ON] " .. btn.Text else btn.Text = "[OFF] " .. btn.Text end
        callback(state)
    end)
end

addBigBtn("No-Clip Fly", 40, function(v)
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

addBigBtn("ESP All", 80, function(v)
    Settings.ESP_All = v
    if not v then for _, o in pairs(espObjects) do o:Destroy() end; espObjects = {} end
end)

addBigBtn("Auto Shoot", 120, function(v)
    Settings.AutoShoot = v
end)

-- Кнопка закрытия
local Close = Instance.new("TextButton")
Close.Size = UDim2.new(1, 0, 0, 30)
Close.Position = UDim2.new(0, 0, 1, -30)
Close.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
Close.Text = "CLOSE MENU"
Close.TextColor3 = Color3.white
Close.Font = Enum.Font.GothamBlack
Close.TextSize = 14
Close.Parent = Main
Close.MouseButton1Click:Connect(function() Gui:Destroy() end)

-- == 2. ЛОГИКА (Та же самая, она работала) ==
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

print("✅ EMERGENCY MENU LOADED")
