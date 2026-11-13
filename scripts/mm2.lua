-- ⚡ LUAVERSE MM2 | Weapon ESP & No-Clip Fly
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

local Settings = {
    FlySpeed = 80,
    Color_Murderer = Color3.fromRGB(255, 50, 50), -- Ярко-красный
    Color_Sheriff = Color3.fromRGB(50, 150, 255), -- Ярко-синий
}

local isFlying = false
local bodyVelocity, bodyGyro
local espObjects = {} -- Таблица для хранения подсветки

-- == ФУНКЦИЯ ПРОВЕРКИ ОРУЖИЯ ==
local function checkWeapons()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local isMurderer = false
                local isSheriff = false

                -- Проверяем Character (руки) и Backpack
                local containers = {plr.Character, plr:FindFirstChildOfClass("Backpack")}
                
                for _, container in pairs(containers) do
                    if container then
                        for _, item in pairs(container:GetChildren()) do
                            if item:IsA("Tool") then
                                if item.Name == "Knife" then isMurderer = true end
                                if item.Name == "Gun" then isSheriff = true end
                            end
                        end
                    end
                end

                -- Логика создания/обновления ESP
                if isMurderer or isSheriff then
                    if not espObjects[plr] then
                        -- Создаем BoxHandle (работает везде)
                        local box = Instance.new("BoxHandleAdornment")
                        box.Size = Vector3.new(4, 6, 2)
                        box.Transparency = 0.6
                        box.AlwaysOnTop = true -- Видно сквозь стены!
                        box.Adornee = root
                        box.ZIndex = 5
                        box.Parent = root
                        
                        -- Создаем текст над головой
                        local bill = Instance.new("BillboardGui")
                        bill.Name = "LV_Tag"
                        bill.Size = UDim2.new(0, 120, 0, 30)
                        bill.StudsOffset = Vector3.new(0, 4, 0)
                        bill.AlwaysOnTop = true
                        bill.Adornee = root
                        
                        local label = Instance.new("TextLabel")
                        label.Size = UDim2.new(1,0,1,0)
                        label.BackgroundTransparency = 1
                        label.Font = Enum.Font.GothamBold
                        label.TextSize = 16
                        label.TextStrokeTransparency = 0
                        label.TextColor3 = Color3.white
                        label.Parent = bill
                        
                        espObjects[plr] = {Box = box, Tag = bill}
                    end
                    
                    -- Обновляем цвет и текст
                    local objs = espObjects[plr]
                    if isMurderer then
                        objs.Box.Color3 = Settings.Color_Murderer
                        objs.Tag:FindFirstChild("TextLabel").Text = "MURDERER"
                        objs.Tag:FindFirstChild("TextLabel").TextColor3 = Settings.Color_Murderer
                    else
                        objs.Box.Color3 = Settings.Color_Sheriff
                        objs.Tag:FindFirstChild("TextLabel").Text = "SHERIFF"
                        objs.Tag:FindFirstChild("TextLabel").TextColor3 = Settings.Color_Sheriff
                    end
                else
                    -- Если оружия нет, удаляем подсветку
                    if espObjects[plr] then
                        espObjects[plr].Box:Destroy()
                        espObjects[plr].Tag:Destroy()
                        espObjects[plr] = nil
                    end
                end
            end
        end
    end
end

-- Запуск проверки оружия каждые 0.3 сек
task.spawn(function()
    while wait(0.3) do
        pcall(checkWeapons)
    end
end)

-- == NO-CLIP FLY ==
local function setNoClip(enabled)
    local char = LP.Character
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.CanCollide = not enabled
        end
    end
end

local function stopFly()
    isFlying = false
    setNoClip(false)
    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
    if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = false end
    if btn then btn.Text = "FLY: OFF"; btn.BackgroundColor3 = Color3.fromRGB(60, 60, 75) end
end

local function startFly()
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end

    stopFly()
    isFlying = true
    setNoClip(true)
    
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bodyVelocity.Parent = root

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bodyGyro.P = 9000
    bodyGyro.Parent = root

    hum.PlatformStand = true
    if btn then btn.Text = "FLY: ON"; btn.BackgroundColor3 = Color3.fromRGB(0, 160, 90) end

    RunService.RenderStepped:Connect(function()
        if not isFlying or not bodyVelocity or not root then return end
        local camera = workspace.CurrentCamera
        local moveDir = hum.MoveDirection
        local camLook = camera.CFrame.LookVector
        
        if moveDir.Magnitude > 0.1 then
            bodyVelocity.Velocity = camLook.Unit * Settings.FlySpeed * moveDir.Magnitude
            bodyGyro.CFrame = CFrame.lookAt(root.Position, root.Position + camLook.Unit)
        else
            bodyVelocity.Velocity = Vector3.zero
        end
    end)
end

-- GUI
if LP.PlayerGui:FindFirstChild("LUAVERSE_HUB") then LP.PlayerGui.LUAVERSE_HUB:Destroy() end
local Gui = Instance.new("ScreenGui")
Gui.Name = "LUAVERSE_HUB"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = LP.PlayerGui

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 140, 0, 50)
btn.Position = UDim2.new(0, 15, 1, -70)
btn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
btn.TextColor3 = Color3.new(1, 1, 1)
btn.Text = "FLY: OFF"
btn.Font = Enum.Font.GothamBold
btn.TextSize = 16
btn.Parent = Gui
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)

btn.MouseButton1Click:Connect(function()
    if isFlying then stopFly() else startFly() end
end)

LP.CharacterAdded:Connect(function()
    wait(1)
    if isFlying then startFly() end
end)

print("✅ LUAVERSE MM2 Loaded (Weapon ESP)")
