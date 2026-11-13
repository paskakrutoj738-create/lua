-- ⚡ LUAVERSE MM2 HUB | Ultimate Version
-- Fly (No-Clip) · ESP All · Auto Shoot

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--== НАСТРОЙКИ ==--
local S = {
	Fly = false, FlySpeed = 80,
	ESP_All = true,
	AutoShoot = false,
	KillAll = false
}

--== ПАЛИТРА ==--
local C = {
	bg      = Color3.fromRGB(14, 16, 28),
	panel   = Color3.fromRGB(20, 23, 38),
	card    = Color3.fromRGB(27, 31, 50),
	stroke  = Color3.fromRGB(58, 64, 96),
	text    = Color3.fromRGB(238, 241, 255),
	muted   = Color3.fromRGB(140, 148, 180),
	violet  = Color3.fromRGB(139, 92, 246),
	cyan    = Color3.fromRGB(34, 211, 238),
	green   = Color3.fromRGB(52, 211, 153),
	red     = Color3.fromRGB(251, 80, 110),
	amber   = Color3.fromRGB(251, 191, 36),
}

local function new(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props) do pcall(function() o[k] = v end) end
	if parent then o.Parent = parent end
	return o
end

local function corner(o, r) return new("UICorner", {CornerRadius = UDim.new(0, r or 10)}, o) end
local function stroke(o, col, t)
	return new("UIStroke", {Color = col or C.stroke, Thickness = t or 1, Transparency = 0.4}, o)
end
local function tween(o, t, props)
	pcall(function()
		TweenService:Create(o, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
	end)
end

--== ОЧИСТКА СТАРОГО GUI ==--
local old = LP.PlayerGui:FindFirstChild("LUAVERSE_HUB")
if old then old:Destroy() end

local Gui = new("ScreenGui", {
	Name = "LUAVERSE_HUB",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 999,
}, LP.PlayerGui)

--== ГЛАВНОЕ ОКНО ==--
local Main = new("Frame", {
	Size = UDim2.new(0, 330, 0, 430),
	Position = UDim2.new(0.5, -165, 0.5, -215),
	BackgroundColor3 = C.bg,
	BorderSizePixel = 0,
	ClipsDescendants = true,
	Active = true,
}, Gui)
corner(Main, 16)
stroke(Main, C.violet, 1.5)

new("UIGradient", {
	Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(24, 20, 45)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 14, 26)),
	},
	Rotation = 90,
}, Main)

--== ШАПКА ==--
local Header = new("Frame", {
	Size = UDim2.new(1, 0, 0, 52),
	BackgroundColor3 = C.panel,
	BorderSizePixel = 0,
}, Main)
corner(Header, 16)
new("Frame", {
	Size = UDim2.new(1, 0, 0, 16),
	Position = UDim2.new(0, 0, 1, -16),
	BackgroundColor3 = C.panel,
	BorderSizePixel = 0,
}, Header)

new("TextLabel", {
	Size = UDim2.new(0, 200, 1, 0),
	Position = UDim2.new(0, 16, 0, 0),
	BackgroundTransparency = 1,
	Text = "⚡ LUAVERSE",
	TextColor3 = C.text,
	Font = Enum.Font.GothamBlack,
	TextSize = 18,
	TextXAlignment = Enum.TextXAlignment.Left,
}, Header)

new("TextLabel", {
	Size = UDim2.new(0, 60, 0, 16),
	Position = UDim2.new(0, 132, 0, 19),
	BackgroundTransparency = 1,
	Text = "MM2",
	TextColor3 = C.cyan,
	Font = Enum.Font.GothamBold,
	TextSize = 12,
	TextXAlignment = Enum.TextXAlignment.Left,
}, Header)

local MinBtn = new("TextButton", {
	Size = UDim2.new(0, 28, 0, 28),
	Position = UDim2.new(1, -66, 0, 12),
	BackgroundColor3 = C.card,
	Text = "–",
	TextColor3 = C.muted,
	Font = Enum.Font.GothamBold,
	TextSize = 20,
	AutoButtonColor = false,
}, Header)
corner(MinBtn, 8)

local CloseBtn = new("TextButton", {
	Size = UDim2.new(0, 28, 0, 28),
	Position = UDim2.new(1, -34, 0, 12),
	BackgroundColor3 = Color3.fromRGB(60, 26, 38),
	Text = "✕",
	TextColor3 = C.red,
	Font = Enum.Font.GothamBold,
	TextSize = 13,
	AutoButtonColor = false,
}, Header)
corner(CloseBtn, 8)

--== ПЕРЕТАСКИВАНИЕ (тач + мышь) ==--
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
		if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
end

--== ВКЛАДКИ ==--
local TabBar = new("Frame", {
	Size = UDim2.new(1, -20, 0, 34),
	Position = UDim2.new(0, 10, 0, 58),
	BackgroundColor3 = C.panel,
	BorderSizePixel = 0,
}, Main)
corner(TabBar, 10)
new("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	Padding = UDim.new(0, 4),
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
	VerticalAlignment = Enum.VerticalAlignment.Center,
}, TabBar)

local Pages, Tabs = {}, {}

local function makeTab(name, icon)
	local btn = new("TextButton", {
		Size = UDim2.new(0, 98, 1, -6),
		BackgroundColor3 = C.card,
		BackgroundTransparency = 1,
		Text = icon .. " " .. name,
		TextColor3 = C.muted,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		AutoButtonColor = false,
	}, TabBar)
	corner(btn, 8)

	local page = new("ScrollingFrame", {
		Size = UDim2.new(1, -20, 1, -108),
		Position = UDim2.new(0, 10, 0, 100),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = C.violet,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false,
	}, Main)
	new("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, page)
	new("UIPadding", {PaddingBottom = UDim.new(0, 8)}, page)

	Pages[name], Tabs[name] = page, btn

	btn.MouseButton1Click:Connect(function()
		for n, p in pairs(Pages) do
			p.Visible = (n == name)
			tween(Tabs[n], 0.2, {
				BackgroundTransparency = (n == name) and 0 or 1,
				TextColor3 = (n == name) and C.text or C.muted,
			})
		end
	end)
	return page
end

local PageMain = makeTab("Main", "🎮")
local PageVisual = makeTab("Visual", "👁")
local PageCombat = makeTab("Combat", "⚔")

--== ЭЛЕМЕНТЫ UI ==--
local function sectionLabel(parent, text)
	new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = C.muted,
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, parent)
end

local function toggle(parent, title, desc, accent, callback)
	local card = new("Frame", {
		Size = UDim2.new(1, 0, 0, 56),
		BackgroundColor3 = C.card,
		BorderSizePixel = 0,
	}, parent)
	corner(card, 12)
	local st = stroke(card, C.stroke, 1)

	new("TextLabel", {
		Size = UDim2.new(1, -80, 0, 20),
		Position = UDim2.new(0, 14, 0, 9),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = C.text,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, card)

	new("TextLabel", {
		Size = UDim2.new(1, -80, 0, 16),
		Position = UDim2.new(0, 14, 0, 29),
		BackgroundTransparency = 1,
		Text = desc,
		TextColor3 = C.muted,
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, card)

	local pill = new("Frame", {
		Size = UDim2.new(0, 46, 0, 24),
		Position = UDim2.new(1, -60, 0.5, -12),
		BackgroundColor3 = Color3.fromRGB(45, 49, 72),
		BorderSizePixel = 0,
	}, card)
	corner(pill, 12)

	local knob = new("Frame", {
		Size = UDim2.new(0, 18, 0, 18),
		Position = UDim2.new(0, 3, 0.5, -9),
		BackgroundColor3 = C.muted,
		BorderSizePixel = 0,
	}, pill)
	corner(knob, 9)

	local hit = new("TextButton", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "",
	}, card)

	local state = false
	hit.MouseButton1Click:Connect(function()
		state = not state
		tween(pill, 0.2, {BackgroundColor3 = state and accent or Color3.fromRGB(45, 49, 72)})
		tween(knob, 0.2, {
			Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
			BackgroundColor3 = state and Color3.new(1,1,1) or C.muted,
		})
		tween(st, 0.2, {Color = state and accent or C.stroke, Transparency = state and 0.1 or 0.4})
		callback(state)
	end)
	return card
end

local function slider(parent, title, min, max, default, accent, callback)
	local card = new("Frame", {
		Size = UDim2.new(1, 0, 0, 62),
		BackgroundColor3 = C.card,
		BorderSizePixel = 0,
	}, parent)
	corner(card, 12)
	stroke(card)

	new("TextLabel", {
		Size = UDim2.new(1, -70, 0, 20),
		Position = UDim2.new(0, 14, 0, 8),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = C.text,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, card)

	local val = new("TextLabel", {
		Size = UDim2.new(0, 50, 0, 20),
		Position = UDim2.new(1, -64, 0, 8),
		BackgroundTransparency = 1,
		Text = tostring(default),
		TextColor3 = accent,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Right,
	}, card)

	local track = new("Frame", {
		Size = UDim2.new(1, -28, 0, 6),
		Position = UDim2.new(0, 14, 0, 40),
		BackgroundColor3 = Color3.fromRGB(45, 49, 72),
		BorderSizePixel = 0,
	}, card)
	corner(track, 3)

	local fill = new("Frame", {
		Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
		BackgroundColor3 = accent,
		BorderSizePixel = 0,
	}, track)
	corner(fill, 3)

	local knob = new("Frame", {
		Size = UDim2.new(0, 14, 0, 14),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		ZIndex = 3,
	}, track)
	corner(knob, 7)

	local hit = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 28),
		Position = UDim2.new(0, 0, 0, -11),
		BackgroundTransparency = 1,
		Text = "",
	}, track)

	local sliding = false
	local function setFromX(x)
		local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		local v = math.floor(min + (max - min) * rel + 0.5)
		val.Text = tostring(v)
		fill.Size = UDim2.new(rel, 0, 1, 0)
		knob.Position = UDim2.new(rel, 0, 0.5, 0)
		callback(v)
	end

	hit.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
			sliding = true
			setFromX(i.Position.X)
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if sliding and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
			setFromX(i.Position.X)
		end
	end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
			sliding = false
		end
	end)
	return card
end

--============================================
--  ЛОГИКА
--============================================

local bv, bg, flyConn
local espObjects = {}
local shootConn

--== FLY (NO-CLIP) ==--
local function stopFly()
	if flyConn then flyConn:Disconnect() flyConn = nil end
	if bv then bv:Destroy() bv = nil end
	if bg then bg:Destroy() bg = nil end
	local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
	if h then 
        h.PlatformStand = false 
        -- Возвращаем коллизию
        for _, part in pairs(LP.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
end

local function startFly()
	stopFly()
	local char = LP.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local root = char:FindFirstChild("HumanoidRootPart")
	if not hum or not root then return end

	bv = new("BodyVelocity", {MaxForce = Vector3.new(1e5,1e5,1e5), Velocity = Vector3.zero}, root)
	bg = new("BodyGyro", {MaxTorque = Vector3.new(1e5,1e5,1e5), P = 9000, CFrame = root.CFrame}, root)
	hum.PlatformStand = true
	
	-- Включаем No-Clip
	for _, part in pairs(char:GetDescendants()) do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then 
			part.CanCollide = false 
		end
	end

	flyConn = RunService.RenderStepped:Connect(function()
		if not bv or not bv.Parent then return end
		local cam = workspace.CurrentCamera
		local move = hum.MoveDirection
		local look = cam.CFrame.LookVector
		
		-- Умное управление: летим туда, куда смотрим
		local fL = Vector3.new(look.X, 0, look.Z)
		if fL.Magnitude > 0 then fL = fL.Unit end

		local vel = fL * move.Magnitude * S.FlySpeed
		vel = vel + Vector3.new(0, look.Y * S.FlySpeed, 0)
		
		bv.Velocity = vel
		if fL.Magnitude > 0 then
			bg.CFrame = CFrame.lookAt(root.Position, root.Position + fL)
		end
	end)
end

--== ESP ДЛЯ ВСЕХ ==--
local function updateESP()
	if not S.ESP_All then 
		for _, o in pairs(espObjects) do if o then o:Destroy() end end
		espObjects = {}
		return 
	end
	
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LP and plr.Character then
			local root = plr.Character:FindFirstChild("HumanoidRootPart")
			if root then
				if not espObjects[plr] then
					local hl = new("Highlight", {
						FillTransparency = 0.6, 
						OutlineTransparency = 0.2,
						DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
						Adornee = plr.Character
					}, plr.Character)
					espObjects[plr] = hl
				end
				
				local hl = espObjects[plr]
				-- Проверка оружия
				local isMurderer = plr.Character:FindFirstChild("Knife") or (plr.Backpack and plr.Backpack:FindFirstChild("Knife"))
				local isSheriff = plr.Character:FindFirstChild("Gun") or (plr.Backpack and plr.Backpack:FindFirstChild("Gun"))
				
				if isMurderer then
					hl.FillColor = C.red
				elseif isSheriff then
					hl.FillColor = Color3.fromRGB(60, 150, 255)
				else
					hl.FillColor = C.green -- Мирные зеленые
				end
			end
		end
	end
end

task.spawn(function()
	while Gui.Parent do
		pcall(updateESP)
		task.wait(0.5)
	end
end)

--== AUTO SHOOT & KILL ALL ==--
shootConn = RunService.RenderStepped:Connect(function()
	if S.AutoShoot or S.KillAll then
		local char = LP.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		local gun = char and char:FindFirstChild("Gun")
		
		if root and gun and gun:IsA("Tool") then
			local nearest, dist = nil, math.huge
			for _, plr in pairs(Players:GetPlayers()) do
				if plr ~= LP and plr.Character then
					-- Ищем убийцу для автошота или любого игрока для Kill All
					local isTarget = false
					if S.AutoShoot then
						isTarget = plr.Character:FindFirstChild("Knife") or (plr.Backpack and plr.Backpack:FindFirstChild("Knife"))
					elseif S.KillAll then
						isTarget = true
					end
					
					if isTarget then
						local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")
						if tRoot then
							local d = (root.Position - tRoot.Position).Magnitude
							if d < dist and d < 50 then
								dist = d
								nearest = plr
							end
						end
					end
				end
			end
			
			if nearest then
				local tRoot = nearest.Character:FindFirstChild("HumanoidRootPart")
				Camera.CFrame = CFrame.lookAt(root.Position, tRoot.Position)
				pcall(function() gun:Activate() end)
				task.wait(0.4)
			end
		end
	end
end)

--== РЕСПАВН ==--
LP.CharacterAdded:Connect(function()
	task.wait(1)
	bv, bg = nil, nil
	if S.Fly then startFly() end
end)

--============================================
--  НАПОЛНЕНИЕ ВКЛАДОК
--============================================

sectionLabel(PageMain, "  ДВИЖЕНИЕ")
toggle(PageMain, "✈️ No-Clip Fly", "Летай сквозь стены", C.cyan, function(v)
	S.Fly = v
	if v then startFly() else stopFly() end
end)
slider(PageMain, "Скорость полёта", 20, 200, S.FlySpeed, C.cyan, function(v) S.FlySpeed = v end)

sectionLabel(PageVisual, "  ВИЗУАЛ")
toggle(PageVisual, "👁 ESP All Players", "Подсветка всех (M/S/Мирные)", C.violet, function(v)
	S.ESP_All = v
end)

sectionLabel(PageCombat, "  БОЙ")
toggle(PageCombat, "🔫 Auto Shoot", "Авто-стрельба по убийце", C.red, function(v)
	S.AutoShoot = v
end)
toggle(PageCombat, "💀 Kill All", "Убивать всех подряд", C.amber, function(v)
	S.KillAll = v
end)

--== ФУТЕР ==--
local Footer = new("TextLabel", {
	Size = UDim2.new(1, 0, 0, 22),
	Position = UDim2.new(0, 0, 1, -22),
	BackgroundTransparency = 1,
	Text = "LUAVERSE · v3.0",
	TextColor3 = C.muted,
	Font = Enum.Font.Gotham,
	TextSize = 10,
}, Main)

--== СВОРАЧИВАНИЕ ==--
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	tween(Main, 0.25, {Size = minimized and UDim2.new(0, 330, 0, 52) or UDim2.new(0, 330, 0, 430)})
	MinBtn.Text = minimized and "+" or "–"
end)

--== ЗАКРЫТИЕ ==--
CloseBtn.MouseButton1Click:Connect(function()
	S.Fly = false; S.ESP_All = false; S.AutoShoot = false; S.KillAll = false
	stopFly()
	for _, o in pairs(espObjects) do if o then o:Destroy() end end
	Gui:Destroy()
end)

--== ОТКРЫТИЕ: АНИМАЦИЯ + ПЕРВАЯ ВКЛАДКА ==--
Main.Size = UDim2.new(0, 330, 0, 0)
tween(Main, 0.3, {Size = UDim2.new(0, 330, 0, 430)})
Tabs["Main"].BackgroundTransparency = 0
Tabs["Main"].TextColor3 = C.text
PageMain.Visible = true

print("⚡ LUAVERSE HUB v3.0 Loaded")
