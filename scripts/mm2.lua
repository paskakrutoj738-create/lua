-- ⚡ LUAVERSE MM2 HUB | Stable Version
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer

local Settings = {
    Fly = false, FlySpeed = 60,
    ESP = false, Roles = false,
    KillAll = false, AutoGun = false,
    Speed = false, WalkSpeed = 32,
}

local C = {
    bg = Color3.fromRGB(14, 16, 28), panel = Color3.fromRGB(20, 23, 38),
    card = Color3.fromRGB(27, 31, 50), stroke = Color3.fromRGB(58, 64, 96),
    text = Color3.fromRGB(238, 241, 255), muted = Color3.fromRGB(140, 148, 180),
    violet = Color3.fromRGB(139, 92, 246), cyan = Color3.fromRGB(34, 211, 238),
    green = Color3.fromRGB(52, 211, 153), red = Color3.fromRGB(251, 80, 110),
    amber = Color3.fromRGB(251, 191, 36), off = Color3.fromRGB(45, 49, 72),
}

local function new(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props) do pcall(function() o[k] = v end) end
    if parent then o.Parent = parent end
    return o
end

if LP.PlayerGui:FindFirstChild("LUAVERSE_HUB") then LP.PlayerGui.LUAVERSE_HUB:Destroy() end

local Gui = new("ScreenGui", { Name = "LUAVERSE_HUB", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999 }, LP.PlayerGui)
pcall(function() Gui.IgnoreGuiInset = true end)

local Main = new("Frame", { Size = UDim2.new(0, 330, 0, 430), Position = UDim2.new(0.5, -165, 0.5, -215), BackgroundColor3 = C.bg, BorderSizePixel = 0, ClipsDescendants = true, Active = true, Visible = true }, Gui)
new("UICorner", { CornerRadius = UDim.new(0, 16) }, Main)
new("UIStroke", { Color = C.violet, Thickness = 1.5, Transparency = 0.4 }, Main)

local Header = new("Frame", { Size = UDim2.new(1, 0, 0, 52), BackgroundColor3 = C.panel, BorderSizePixel = 0 }, Main)
new("UICorner", { CornerRadius = UDim.new(0, 16) }, Header)
new("TextLabel", { Size = UDim2.new(0, 200, 1, 0), Position = UDim2.new(0, 16, 0, 0), BackgroundTransparency = 1, Text = "⚡ LUAVERSE", TextColor3 = C.text, Font = Enum.Font.GothamBold, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left }, Header)

local CloseBtn = new("TextButton", { Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(1, -34, 0, 12), BackgroundColor3 = Color3.fromRGB(60, 26, 38), Text = "X", TextColor3 = C.red, Font = Enum.Font.GothamBold, TextSize = 13, AutoButtonColor = false }, Header)
new("UICorner", { CornerRadius = UDim.new(0, 8) }, CloseBtn)

-- Dragging
do
    local dragging, dragStart, startPos = false, nil, nil
    Header.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging, dragStart, startPos = true, i.Position, Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
            local d = i.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

-- Tabs
local TabBar = new("Frame", { Size = UDim2.new(1, -20, 0, 34), Position = UDim2.new(0, 10, 0, 58), BackgroundColor3 = C.panel, BorderSizePixel = 0 }, Main)
new("UICorner", { CornerRadius = UDim.new(0, 10) }, TabBar)
new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4), HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center }, TabBar)

local Pages, Tabs = {}, {}
local function makeTab(name, icon, xPos)
    local btn = new("TextButton", { Size = UDim2.new(0.5, -2, 1, -6), BackgroundColor3 = C.card, BackgroundTransparency = 1, Text = icon .. " " .. name, TextColor3 = C.muted, Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false }, TabBar)
    new("UICorner", { CornerRadius = UDim.new(0, 8) }, btn)
    
    local page = new("ScrollingFrame", { Size = UDim2.new(1, -20, 1, -130), Position = UDim2.new(0, 10, 0, 100), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, CanvasSize = UDim2.new(0, 0, 0, 0), Visible = (xPos == 0) }, Main)
    pcall(function() page.AutomaticCanvasSize = Enum.AutomaticSize.Y end)
    new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, page)
    new("UIPadding", { PaddingBottom = UDim.new(0, 8) }, page)
    
    Pages[name], Tabs[name] = page, btn
    btn.MouseButton1Click:Connect(function()
        for n, p in pairs(Pages) do
            p.Visible = (n == name)
            Tabs[n].TextColor3 = (n == name) and C.text or C.muted
            Tabs[n].BackgroundTransparency = (n == name) and 0 or 1
        end
    end)
    if xPos == 0 then btn.TextColor3 = C.text; btn.BackgroundTransparency = 0 end
    return page
end

local PageMain = makeTab("Main", "🎮", 0)
local PageVisual = makeTab("Visual", "👁", 0.5)

-- UI Helpers
local function toggle(parent, title, desc, accent, callback)
    local card = new("Frame", { Size = UDim2.new(1, 0, 0, 56), BackgroundColor3 = C.card, BorderSizePixel = 0 }, parent)
    new("UICorner", { CornerRadius = UDim.new(0, 12) }, card)
    new("TextLabel", { Size = UDim2.new(1, -80, 0, 20), Position = UDim2.new(0, 14, 0, 9), BackgroundTransparency = 1, Text = title, TextColor3 = C.text, Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left }, card)
    new("TextLabel", { Size = UDim2.new(1, -80, 0, 16), Position = UDim2.new(0, 14, 0, 29), BackgroundTransparency = 1, Text = desc, TextColor3 = C.muted, Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left }, card)
    
    local pill = new("Frame", { Size = UDim2.new(0, 46, 0, 24), Position = UDim2.new(1, -60, 0.5, -12), BackgroundColor3 = C.off, BorderSizePixel = 0 }, card)
    new("UICorner", { CornerRadius = UDim.new(0, 12) }, pill)
    local knob = new("Frame", { Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(0, 3, 0.5, -9), BackgroundColor3 = C.muted, BorderSizePixel = 0 }, pill)
    new("UICorner", { CornerRadius = UDim.new(0, 9) }, knob)
    
    local hit = new("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "" }, card)
    local state = false
    hit.MouseButton1Click:Connect(function()
        state = not state
        pill.BackgroundColor3 = state and accent or C.off
        knob.Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        knob.BackgroundColor3 = state and Color3.new(1,1,1) or C.muted
        callback(state)
    end)
end

-- Logic
local bv, bg, flyConn
local function stopFly()
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if bv then bv:Destroy() bv = nil end
    if bg then bg:Destroy() bg = nil end
    local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if h then h.PlatformStand = false end
end

local function startFly()
    stopFly()
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end
    bv = new("BodyVelocity", { MaxForce = Vector3.new(1e5,1e5,1e5) }, root)
    bg = new("BodyGyro", { MaxTorque = Vector3.new(1e5,1e5,1e5), P = 9000 }, root)
    hum.PlatformStand = true
    flyConn = RunService.RenderStepped:Connect(function()
        if not bv or not bv.Parent then return end
        local cam = workspace.CurrentCamera
        local move = hum.MoveDirection
        local look = cam.CFrame.LookVector
        local fL = Vector3.new(look.X, 0, look.Z).Unit
        local vel = fL * move.Magnitude * Settings.FlySpeed
        vel = vel + Vector3.new(0, look.Y * Settings.FlySpeed, 0)
        bv.Velocity = vel
        bg.CFrame = CFrame.lookAt(root.Position, root.Position + fL)
    end)
end

task.spawn(function()
    while Gui.Parent do
        if Settings.AutoGun then
            pcall(function()
                local drop = workspace:FindFirstChild("GunDrop")
                local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if drop and root then
                    local old = root.CFrame
                    root.CFrame = drop:IsA("BasePart") and drop.CFrame or (drop.PrimaryPart and drop.PrimaryPart.CFrame)
                    task.wait(0.15)
                    root.CFrame = old
                end
            end)
        end
        task.wait(0.4)
    end
end)

LP.CharacterAdded:Connect(function(char)
    task.wait(1)
    bv, bg = nil, nil
    if Settings.Fly then startFly() end
    if Settings.Speed then LP.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = Settings.WalkSpeed end
end)

-- Populate Tabs
toggle(PageMain, "✈️ Fly", "Джойстик + Камера", C.cyan, function(v) Settings.Fly = v; if v then startFly() else stopFly() end end)
toggle(PageMain, "🏃 Speed", "Быстрый бег", C.green, function(v) Settings.Speed = v; if LP.Character then LP.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = v and Settings.WalkSpeed or 16 end end)
toggle(PageVisual, "👁 ESP", "Подсветка оружия", C.violet, function(v) Settings.ESP = v end)
toggle(PageVisual, "💀 Kill All", "Только если Murderer", C.red, function(v) Settings.KillAll = v end)
toggle(PageVisual, "🔫 Auto Gun", "Авто-подбор", C.amber, function(v) Settings.AutoGun = v end)

CloseBtn.MouseButton1Click:Connect(function()
    stopFly()
    Gui:Destroy()
end)

print("✅ LUAVERSE MM2 Loaded")
