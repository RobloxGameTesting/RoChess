local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Chess = ReplicatedStorage:WaitForChild("Chess")
local Cosmetics = require(Chess.Cosmetics)
local Sprites = require(Chess.Sprites)
local parent = script.Parent
local UI = require(parent.UI)

local Cosmetics2 = {}
Cosmetics2.Shared = Cosmetics
local color = Color3.new(1, 1, 1)
local color2 = Color3.new(0, 0, 0)
local v = { "P", "N", "B", "R", "Q", "K" }
local random = Random.new()

local function rgb(p, p2, p3) -- 206 equivalent calls inferred from this helper
	return Color3.fromRGB(p, p2, p3)
end

local v2 = {}
local v3 = {}

local v4 = {}
local flag = false

local function animate(p, fn) -- 53 equivalent calls inferred from this helper
	if flag then
		table.insert(v4, { p, fn })
		return
	end

	v2[p] = fn
	v3[p] = os.clock()
end
Cosmetics2.animate = animate

local object = setmetatable({}, { __mode = "k" })
local object2 = setmetatable({}, { __mode = "k" })

local function onScreen(instance)
	while instance do
		if instance:IsA("GuiObject") then
			if not instance.Visible then
				return false
			end
		elseif instance:IsA("LayerCollector") then
			return instance.Enabled
		end

		instance = instance.Parent
	end

	return true
end

local function unanimate(p) -- 14 equivalent calls inferred from this helper
	v2[p] = nil
	v3[p] = nil
	object[p] = nil
	object2[p] = nil
end
Cosmetics2.unanimate = unanimate

RunService.RenderStepped:Connect(function()
	local now = os.clock()
	flag = true

	for k, callback in v2 do
		local v5 = object[k]

		if v5 == nil or now - (object2[k] or 0) > 0.5 then
			if k:IsDescendantOf(game) then
				v5 = onScreen(k)
				object[k] = v5
				object2[k] = now
			else
				v5 = false
				object[k] = nil
				local v6 = v3[k]

				if not v6 or now - v6 > 1 then
					unanimate(k) -- inferred equivalent call
				end
			end
		end

		if not v5 or pcall(callback, now, k) then
			continue
		end

		unanimate(k) -- inferred equivalent call
	end

	flag = false

	if #v4 > 0 then
		local v5 = v4
		v4 = {}

		for k, v6 in v5 do
			v2[v6[1]] = v6[2]
			v3[v6[1]] = now
		end
	end
end)

local function gradient(parent2, items, value, value2)
	local uiGradient = Instance.new("UIGradient")
	uiGradient.Name = value2 or "Style"
	local colorSequenceKeypoints = {}

	for k, item in items do
		table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(item[1], item[2]))
	end

	uiGradient.Color = ColorSequence.new(colorSequenceKeypoints)
	uiGradient.Rotation = value or 0
	uiGradient.Parent = parent2
	return uiGradient
end

local function shade(p, p2) -- 27 equivalent calls inferred from this helper
	return p:Lerp(color2, p2)
end

local function tint(p, p2) -- 16 equivalent calls inferred from this helper
	return p:Lerp(color, p2)
end

local v5 = { "Glow", "Aura", "Top", "Motes", "PieceGrad" }
local object3 = setmetatable({}, { __mode = "k" })

local function clearPieceStyle(instance)
	for k, childName in v5 do
		local child = instance:FindFirstChild(childName)

		if child then
			child:Destroy()
		end
	end

	if object3[instance] then
		object3[instance]:Disconnect()
		object3[instance] = nil
	end

	unanimate(instance) -- inferred equivalent call
	instance.ImageColor3 = color
end

local function rainbowKeys(p)
	local result = {}

	for i = 0, 6 do
		local v6 = i / 6
		table.insert(result, { v6, p == 1 and Color3.fromHSV(v6, 0.3, 1) or Color3.fromHSV(v6, 0.7, 0.62) })
	end

	return result
end

local function pieceGradient(parent2, data, p)
	if data.anim == "rainbow" then
		return gradient(parent2, rainbowKeys(p), 45, "PieceGrad")
	end

	local light = p == 1 and data.light or data.dark
	local light2 = p == 1 and data.light2 or data.dark2

	if not light2 then
		return nil
	end

	if data.shine then
		return gradient(parent2, {
			{ 0, light },
			{ 0.42, tint(light, 0.55) },
			{ 0.5, light },
			{ 1, light2 }
		}, 70, "PieceGrad")
	end

	return gradient(parent2, {
		{ 0, light },
		{ 1, light2 }
	}, 90, "PieceGrad")
end

local v6 = {
	pc_toxic = { light = rgb(150, 255, 70), dark = rgb(185, 100, 255), mote = "bubble" }, -- inferred equivalent call
	pc_neon = { light = rgb(90, 235, 255), dark = rgb(255, 80, 205), mote = "spark" }, -- inferred equivalent call
	pc_inferno = {
		light = rgb(255, 165, 40), -- inferred equivalent call
		dark = rgb(255, 75, 25), -- inferred equivalent call
		mote = "ember",
		hot = rgb(255, 235, 140) -- inferred equivalent call
	},
	pc_holo = { light = rgb(220, 226, 255), dark = rgb(190, 130, 255), mote = "spark" }, -- inferred equivalent call
	pc_vip = { light = rgb(255, 204, 70), dark = rgb(255, 178, 40), mote = "spark" } -- inferred equivalent call
}

local function auraDot(parent2, p, p2, p3, p4, backgroundColor, op, value)
	local frame = Instance.new("Frame")
	frame.BorderSizePixel = 0
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.fromScale(p, p2)
	frame.Size = UDim2.fromScale(p3, p4)
	frame.BackgroundColor3 = backgroundColor
	frame.ZIndex = value or 1
	frame:SetAttribute("Op", op)
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0.5, 0)
	uiCorner.Parent = frame
	frame.Parent = parent2
	return frame
end

local function layer(parent2, name, zIndex) -- 3 equivalent calls inferred from this helper
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.fromScale(1, 1)
	frame.ZIndex = zIndex
	frame.Parent = parent2
	return frame
end

local function imageCopy(parent2) -- 2 equivalent calls inferred from this helper
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.BackgroundTransparency = 1
	imageLabel.BorderSizePixel = 0
	imageLabel.Image = parent2.Image
	imageLabel.ImageRectOffset = parent2.ImageRectOffset
	imageLabel.ImageRectSize = parent2.ImageRectSize
	imageLabel.ImageColor3 = parent2.ImageColor3
	imageLabel.ImageTransparency = parent2.ImageTransparency
	imageLabel.ScaleType = parent2.ScaleType
	imageLabel.ResampleMode = parent2.ResampleMode
	return imageLabel
end

local function buildAura(parent2, data, p, instance)
	local v7 = v6[data.id] or { light = data.light, dark = data.dark, mote = "spark" }
	local light = p == 1 and v7.light or v7.dark
	local frame = layer(parent2, "Aura", 0) -- inferred equivalent call
	local v8 = {}

	for k, v9 in {
		{ 1.12, 0.045 },
		{ 0.98, 0.05 },
		{ 0.84, 0.06 },
		{ 0.7, 0.07 },
		{ 0.56, 0.08 },
		{ 0.42, 0.08 }
	} do
		v8[k] = auraDot(frame, 0.5, 0.56, v9[1], v9[1], light, v9[2])
	end

	for k, v9 in {
		{ 0.92, 0.24, 0.07 },
		{ 0.74, 0.18, 0.1 },
		{ 0.56, 0.12, 0.13 },
		{ 0.36, 0.07, 0.16 }
	} do
		table.insert(v8, auraDot(frame, 0.5, 0.9, v9[1], v9[2], tint(light, 0.2), v9[3])) -- inferred equivalent call
	end

	local top = imageCopy(parent2) -- inferred equivalent call
	top.Name = "Top"
	top.AnchorPoint = Vector2.new(0.5, 0.5)
	top.Position = UDim2.fromScale(0.5, 0.5)
	top.Size = UDim2.fromScale(1, 1)
	top.Rotation = 0
	top.ZIndex = 1
	local clone

	if instance then
		clone = instance:Clone()
		clone.Parent = top
	else
		clone = nil
	end

	top.Parent = parent2
	local parent3 = layer(parent2, "Motes", 2) -- inferred equivalent call
	local v9 = {}

	for i = 1, v7.mote == "spark" and 4 or 5 do
		local parent4

		if v7.mote == "bubble" then
			parent4 = auraDot(parent3, 0.5, 0.8, 0.1, 0.1, tint(light, 0.3), 0.18, 1) -- inferred equivalent call
			local uiStroke = Instance.new("UIStroke")
			uiStroke.Color = tint(light, 0.5) -- inferred equivalent call
			uiStroke.Thickness = 1.5
			uiStroke.Parent = parent4
		elseif v7.mote == "ember" then
			parent4 = auraDot(parent3, 0.5, 0.8, 0.06, 0.06, v7.hot, 0.9, 1)
			parent4.UICorner.CornerRadius = UDim.new(0.2, 0)
		else
			parent4 = auraDot(parent3, 0.5, 0.5, 0.07, 0.07, tint(light, 0.6), 0.9, 1) -- inferred equivalent call
			parent4.UICorner.CornerRadius = UDim.new(0.15, 0)
			parent4.Rotation = 45
		end

		v9[i] = {
			f = parent4,
			seed = random:NextNumber(),
			speed = 0.35 + random:NextNumber() * 0.25,
			x = 0.25 + random:NextNumber() * 0.5
		}
	end

	local v10 = 1
	local function fade(instance2, value) -- 2 equivalent calls inferred from this helper
		local imageTransparency = parent2.ImageTransparency
		local v11 = (instance2:GetAttribute("Op") or 0) * v10 * (value or 1)
		instance2.BackgroundTransparency = 1 - v11 * (1 - imageTransparency)
		local uiStroke = instance2:FindFirstChildOfClass("UIStroke")

		if uiStroke then
			uiStroke.Transparency = 1 - math.min(1, v11 * 3) * (1 - imageTransparency)
		end
	end
	local v11 = {}
	local function sync()
		top.ImageTransparency = parent2.ImageTransparency

		for k, v12 in v8 do
			fade(v12) -- inferred equivalent call
		end

		for k, v12 in v9 do
			fade(v12.f, v11[v12] or 0) -- inferred equivalent call
		end
	end
	object3[parent2] = parent2:GetPropertyChangedSignal("ImageTransparency"):Connect(sync)

	local v12 = random:NextNumber() * 10
	local function fn(p2)
		local v13 = p2 + v12

		if data.anim == "pulse" then
			v10 = math.sin(v13 * 2.6) * 0.25 + 0.8
		elseif data.anim == "rainbow" then
			v10 = math.sin(v13 * 1.8) * 0.15 + 0.85

			local v14 = parent2.Position.X.Scale + parent2.Position.Y.Scale
			local v15 = v13 - v12
			local rotation = (v15 * 40 + v14 * 120) % 360
			instance.Rotation = rotation

			if clone then
				clone.Rotation = rotation
			end

			local color3 = Color3.fromHSV((v15 * 0.1 + v14 * 0.35) % 1, p == 1 and 0.4 or 0.7, 1)

			for k, v16 in v8 do
				local backgroundColor

				if k > 6 then
					backgroundColor = tint(color3, 0.2) or color3 -- inferred equivalent call
				else
					backgroundColor = color3
				end

				v16.BackgroundColor3 = backgroundColor
			end

			for k, v16 in v9 do
				v16.f.BackgroundColor3 = tint(color3, 0.55) -- inferred equivalent call
			end
		elseif data.anim == "flow" then
			v10 = math.sin(v13 * 7.1) * 0.08 + 0.9 + math.sin(v13 * 11.3) * 0.06
		else
			v10 = math.sin(v13 * 1.7) * 0.05 + 0.95
		end

		if instance and data.anim == "flow" then
			local vector2 = Vector2.new(0, math.sin(v13 * 2.2) * 0.25)
			instance.Offset = vector2

			if clone then
				clone.Offset = vector2
			end
		end

		for k, v14 in v9 do
			local v15 = (v13 * v14.speed + v14.seed) % 1
			local f = v14.f

			if v7.mote == "spark" then
				local v16 = math.floor(v13 * v14.speed + v14.seed)
				local random2 = Random.new(v16 * 97 + math.floor(v14.seed * 1000))
				local v17 = random2:NextNumber() * 3.141592653589793 * 2
				local v18 = 0.32 + random2:NextNumber() * 0.12
				f.Position = UDim2.fromScale(0.5 + math.cos(v17) * v18, 0.52 + math.sin(v17) * v18 * 0.95)
				local v19 = math.sin(v15 * 3.141592653589793)
				f.Size = UDim2.fromScale(v19 * 0.09, v19 * 0.09)
				v11[v14] = v19
			else
				local v16 = 0.86 - v15 * 0.78
				local v17 = v14.x + math.sin(v15 * 9 + v14.seed * 6) * 0.05
				f.Position = UDim2.fromScale(v17, v16)

				if v7.mote == "ember" then
					local v18 = 0.08 * (1 - v15 * 0.6)
					f.Size = UDim2.fromScale(v18, v18)
					f.Rotation = v15 * 220
					f.BackgroundColor3 = v7.hot:Lerp(light, (math.min(1, v15 * 1.6)))
				else
					local v18 = 0.07 + v15 * 0.06
					f.Size = UDim2.fromScale(v18, v18)
				end

				v11[v14] = math.min(1, v15 * 6) * (1 - v15) ^ 1.4
			end
		end

		sync()
	end

	animate(parent2, fn) -- inferred equivalent call
	sync()
end

local function buildGlint(parent2)
	local top = imageCopy(parent2) -- inferred equivalent call
	top.Name = "Top"
	top.AnchorPoint = Vector2.new(0.5, 0.5)
	top.Position = UDim2.fromScale(0.5, 0.5)
	top.Size = UDim2.fromScale(1, 1)
	top.Rotation = 0
	top.ZIndex = 1
	top.ImageColor3 = color
	local uiGradient = Instance.new("UIGradient")
	uiGradient.Rotation = 35
	uiGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.43, 1),
		NumberSequenceKeypoint.new(0.5, 0.1),
		NumberSequenceKeypoint.new(0.57, 1),
		NumberSequenceKeypoint.new(1, 1)
	})

	uiGradient.Offset = Vector2.new(-1, 0)
	uiGradient.Parent = top
	top.Parent = parent2
	local parent3 = layer(parent2, "Motes", 2) -- inferred equivalent call
	local v7 = {}

	for i = 1, 3 do
		local parent4 = auraDot(parent3, 0.5, 0.5, 0.07, 0.07, color, 0.95, 1)
		parent4.UICorner.CornerRadius = UDim.new(0.15, 0)
		parent4.Rotation = 45
		v7[i] = {
			f = parent4,
			seed = random:NextNumber(),
			speed = 0.45 + random:NextNumber() * 0.3
		}
	end

	local v8 = {}
	local function sync()
		local imageTransparency = parent2.ImageTransparency
		top.ImageTransparency = imageTransparency

		for k, v9 in v7 do
			v9.f.BackgroundTransparency = 1 - 0.95 * (v8[v9] or 0) * (1 - imageTransparency)
		end
	end
	object3[parent2] = parent2:GetPropertyChangedSignal("ImageTransparency"):Connect(sync)
	local v9 = random:NextNumber() * 3.4
	animate(parent2, function(p) -- inferred equivalent call
		local v10 = (p + v9) % 3.4 / 3.4
		uiGradient.Offset = Vector2.new(math.min(1, v10 * 2.8) * 2 + -1, 0)

		for k, v11 in v7 do
			local v12 = (p * v11.speed + v11.seed) % 1
			local v13 = math.floor(p * v11.speed + v11.seed)
			local random2 = Random.new(v13 * 97 + math.floor(v11.seed * 1000))
			local v14 = random2:NextNumber() * 3.141592653589793 * 2
			local v15 = 0.3 + random2:NextNumber() * 0.14
			v11.f.Position = UDim2.fromScale(0.5 + math.cos(v14) * v15, 0.5 + math.sin(v14) * v15 * 0.95)
			local v16 = math.sin(v12 * 3.141592653589793)
			v11.f.Size = UDim2.fromScale(v16 * 0.08, v16 * 0.08)
			v8[v11] = v16
		end

		sync()
	end)
	sync()
end

function Cosmetics2:paintPiece(p, p2)
	clearPieceStyle(self)

	if not p or p == 0 then
		Sprites.applyPiece(self, 0)
		return
	end

	local v7 = p2 and Cosmetics.BY_ID[p2]

	if not v7 or v7.type ~= "pieces" or v7.free then
		Sprites.applyPiece(self, p)
		return
	end

	self.Visible = true
	local v8 = p > 0 and 1 or -1
	Sprites.apply(self, "w" .. v[math.abs(p)])
	local imageColor = v8 == 1 and v7.light or v7.dark
	local v9 = pieceGradient(self, v7, v8)
	imageColor = v9 and color or imageColor
	self.ImageColor3 = imageColor

	if v7.glow then
		buildAura(self, v7, v8, v9)
	elseif v7.glint then
		buildGlint(self)
	elseif v7.anim == "flow" and v9 then
		animate(self, function(p3) -- inferred equivalent call
			v9.Offset = Vector2.new(0, math.sin(p3 * 2.2) * 0.25)
		end)
	end
end

local function spookyPart(parent2, p, p2, p3, p4, backgroundColor, cornerRadius, value, value2)
	local frame = Instance.new("Frame")
	frame.Name = value2 or "Part"
	frame.BorderSizePixel = 0
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.fromScale(p, p2)
	frame.Size = UDim2.fromScale(p3, p4)
	frame.BackgroundColor3 = backgroundColor
	frame.Rotation = value or 0
	frame:SetAttribute("Spooky", true)

	if cornerRadius then
		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = cornerRadius
		uiCorner.Parent = frame
	end

	frame.Parent = parent2
	return frame
end

local function makeBat(backgroundColor)
	local bat = Instance.new("Frame")
	bat.Name = "Bat"
	bat.BackgroundTransparency = 1
	bat.BorderSizePixel = 0

	for k, v7 in { -1, 1 } do
		local frame = Instance.new("Frame")
		frame.Name = v7 < 0 and "WingL" or "WingR"
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Position = UDim2.fromScale(0.5, 0.52)
		frame.Size = UDim2.fromScale(1, 0.5)
		frame.Parent = bat
		spookyPart(frame, 0.5 + v7 * 0.24, 0.55, 0.42, 0.5, backgroundColor, UDim.new(0.5, 0), v7 * -14, "Wing")
		spookyPart(frame, 0.5 + v7 * 0.4, 0.38, 0.22, 0.56, backgroundColor, UDim.new(0.5, 0), v7 * 34, "Tip")
		spookyPart(frame, 0.5 + v7 * 0.3, 0.86, 0.1, 0.24, backgroundColor, UDim.new(0.5, 0), v7 * 20, "Claw")
	end

	spookyPart(bat, 0.5, 0.56, 0.2, 0.3, backgroundColor, UDim.new(0.5, 0), 0, "Body")
	spookyPart(bat, 0.5, 0.4, 0.17, 0.16, backgroundColor, UDim.new(0.5, 0), 0, "Head")
	spookyPart(bat, 0.455, 0.32, 0.06, 0.09, backgroundColor, nil, 20, "Ear")
	spookyPart(bat, 0.545, 0.32, 0.06, 0.09, backgroundColor, nil, -20, "Ear")
	spookyPart(bat, 0.47, 0.4, 0.035, 0.035, rgb(255, 214, 90), UDim.new(0.5, 0), 0, "Eye") -- inferred equivalent call
	spookyPart(bat, 0.53, 0.4, 0.035, 0.035, rgb(255, 214, 90), UDim.new(0.5, 0), 0, "Eye") -- inferred equivalent call
	return bat
end

local function flapBat(instance, p) -- 3 equivalent calls inferred from this helper
	local rotation = math.sin(p) * 30
	local wingL = instance:FindFirstChild("WingL")
	local wingR = instance:FindFirstChild("WingR")

	if wingL and wingR then
		wingL.Rotation = rotation
		wingR.Rotation = -rotation
	end
end

local function makeGhost(color3)
	local ghost = Instance.new("Frame")
	ghost.Name = "Ghost"
	ghost.BackgroundTransparency = 1
	ghost.BorderSizePixel = 0
	local backgroundColor = rgb(34, 26, 46) -- inferred equivalent call
	spookyPart(ghost, 0.17, 0.56, 0.17, 0.09, color3, UDim.new(0.5, 0), -32, "Arm")
	spookyPart(ghost, 0.83, 0.56, 0.17, 0.09, color3, UDim.new(0.5, 0), 32, "Arm")
	spookyPart(ghost, 0.5, 0.42, 0.62, 0.64, color3, UDim.new(0.5, 0), 0, "Head")
	spookyPart(ghost, 0.5, 0.64, 0.62, 0.32, color3, nil, 0, "Body")

	for k, v7 in { 0.29, 0.5, 0.71 } do
		spookyPart(ghost, v7, 0.8, 0.21, 0.2, color3, UDim.new(0.5, 0), 0, "Tail")
	end

	spookyPart(ghost, 0.4, 0.4, 0.1, 0.15, backgroundColor, UDim.new(0.5, 0), 0, "Eye")
	spookyPart(ghost, 0.6, 0.4, 0.1, 0.15, backgroundColor, UDim.new(0.5, 0), 0, "Eye")
	spookyPart(ghost, 0.5, 0.56, 0.1, 0.12, backgroundColor, UDim.new(0.5, 0), 0, "Mouth")
	return ghost
end

local function setSpookyAlpha(folder, backgroundTransparency)
	for i, descendant in folder:GetDescendants() do
		if descendant:GetAttribute("Spooky") then
			descendant.BackgroundTransparency = backgroundTransparency
		end
	end
end

local color6 = rgb(30, 28, 26) -- inferred equivalent call

local function frame(parent2, p, p2, p3, p4, p5, cornerRadius, value, value2)
	local frame2 = Instance.new("Frame")
	frame2.Name = value2 or "Shape"
	frame2.BorderSizePixel = 0
	frame2.AnchorPoint = Vector2.new(0.5, 0.5)
	frame2.Position = UDim2.fromScale(p, p2)
	frame2.Size = UDim2.fromScale(p3, p4)
	frame2.BackgroundColor3 = p5 or color
	frame2.Rotation = value or 0

	if cornerRadius then
		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = cornerRadius
		uiCorner.Parent = frame2
	end

	frame2.Parent = parent2
	return frame2
end

local function group(parent2, p, p2, p3, p4, p5) -- 15 equivalent calls inferred from this helper
	local v7 = frame(parent2, p, p2, p3, p4, nil, nil, p5, "Group")
	v7.BackgroundTransparency = 1
	return v7
end

local function volume(parent2, p, value)
	parent2.BackgroundColor3 = color
	gradient(parent2, {
		{ 0, tint(p, 0.28) },
		{ 0.45, p },
		{ 1, shade(p, 0.22) }
	}, value or 90, "Volume")
end

local function rect(parent2, p, p2, p3, p4, p5, cornerRadius, p6, options)
	local v7 = options or {}

	if v7.outline ~= false then
		local frame_2 = frame(parent2, p, p2, p3 + 0.08, p4 + 0.08, color6, cornerRadius, p6, "Outline")
		frame_2.BackgroundTransparency = v7.alpha or 0
	end

	local v8 = frame(parent2, p, p2, p3, p4, p5, cornerRadius, p6, "Fill")
	v8.BackgroundTransparency = v7.alpha or 0

	if not v7.flat then
		volume(v8, p5)
	end

	return v8
end

local function circle(parent2, p, p2, p3, p4, p5) -- 29 equivalent calls inferred from this helper
	return rect(parent2, p, p2, p3, p3, p4, UDim.new(0.5, 0), 0, p5)
end

local function shine(parent2, p, p2, p3, p4, p5, value)
	local v7 = frame(parent2, p, p2, p3, p4, color, UDim.new(0.5, 0), p5, "Shine")
	v7.BackgroundTransparency = value or 0.55
	return v7
end

local function shadow(parent2, p, p2)
	local v7 = frame(parent2, 0.5, p, p2, 0.12, color2, UDim.new(0.5, 0), 0, "Shadow")
	v7.BackgroundTransparency = 0.72
	return v7
end

local function sliced(p, p2, p3, p4, p5, callback, backgroundColor2, options)
	local v7 = options or {}
	local result = {}
	local slices = v7.slices or 28
	local function pass(p6, p7, p8, p9, backgroundColor, name)
		local parent2 = group(p, p6, p7 + p9 / 2, p8, p9) -- inferred equivalent call
		parent2.Name = name

		for i = 0, slices - 1 do
			local v8 = (i + 0.5) / slices
			local v9 = math.max(0, callback(v8))

			if not (v9 > 0) then
				continue
			end

			local frame2 = Instance.new("Frame")
			frame2.BorderSizePixel = 0
			frame2.AnchorPoint = Vector2.new(0.5, 0.5)
			frame2.Position = UDim2.fromScale(0.5, v8)
			frame2.Size = UDim2.fromScale(v9, 2.2 / slices)
			frame2.BackgroundColor3 = backgroundColor
			local uiCorner = Instance.new("UICorner")
			uiCorner.CornerRadius = UDim.new(0.5, 0)
			uiCorner.Parent = frame2
			frame2.Parent = parent2

			if name == "Fill" then
				local backgroundColor3

				if v7.decorate then
					backgroundColor3 = v7.decorate(v8) or backgroundColor
				else
					backgroundColor3 = backgroundColor
				end

				if v7.flat then
					frame2.BackgroundColor3 = backgroundColor3
				else
					local lerped = tint(backgroundColor3, 0.28 * (1 - v8)):Lerp( -- inferred equivalent call
						shade(backgroundColor3, 0.22), -- inferred equivalent call
						(math.max(0, v8 - 0.5))
					)
					frame2.BackgroundColor3 = color
					gradient(frame2, {
						{ 0, tint(lerped, 0.18) },
						{ 0.35, lerped },
						{ 1, shade(lerped, 0.25) }
					}, 0, "Volume")
				end
			end

			table.insert(result, frame2)
		end

		return parent2
	end

	local v8 = p4 - p3

	if v7.outline ~= false then
		pass(p2, p3 - 0.04, p5 + 0.08, v8 + 0.08, color6, "Outline")
	end

	pass(p2, p3, p5, v8, backgroundColor2, "Fill")
	return result
end

local function cone(p, p2, p3, p4, p5, backgroundColor, p6)
	return sliced(p, p2, p3, p4, p5, function(p7)
		return 0.1 + 0.9 * p7
	end, backgroundColor, p6)
end

local function dome(p, p2, p3, p4, p5, backgroundColor, p6)
	return sliced(p, p2, p3, p4, p5, function(p7)
		return (math.sqrt((math.max(0, 1 - (1 - p7) ^ 2))))
	end, backgroundColor, p6)
end

local newVector2 = Vector2.new
local function limb(parent2, list, list2, backgroundColor, options)
	local v7 = options or {}
	local v8 = {}

	local function lightAngle(p, p2) -- 2 equivalent calls inferred from this helper
		local unit = (p2 - p).Unit
		local vector2 = newVector2(-unit.Y, unit.X)

		if vector2.X + vector2.Y < 0 then
			vector2 = -vector2
		end

		return (math.deg((math.atan2(vector2.Y, vector2.X))))
	end

	local function lit(parent3, p)
		parent3.BackgroundColor3 = color
		gradient(parent3, {
			{ 0, tint(backgroundColor, 0.22) },
			{ 0.45, backgroundColor },
			{ 1, shade(backgroundColor, 0.3) }
		}, p, "Volume")
		table.insert(v8, parent3)
	end
	local function joint(p, p2, p3, p4, p5, p6)
		local item = list[p]
		local v9 = list2[p] + p2 * 2

		if v9 <= 0 then
			return
		end

		local parent3 = frame(parent2, item.X, item.Y, v9, v9, p3, UDim.new(0.5, 0), 0, p4 and "Fill" or "Outline")

		if p4 then
			lit(parent3, lightAngle(p5, p6)) -- inferred equivalent call
		end
	end
	local function pass(p, backgroundColor2, p2)
		for i = 1, #list - 1 do
			local item = list[i]
			local item2 = list[i + 1]
			local v9 = item2 - item
			local magnitude = v9.Magnitude
			local v10 = list2[i] + p * 2
			local v11 = list2[i + 1] + p * 2
			local v12 = math.max(v10, v11)
			local midpoint = (item + item2) / 2
			local v13 = math.deg((math.atan2(-v9.X, v9.Y)))
			local v14 = group(parent2, midpoint.X, midpoint.Y, v12, magnitude + p * 2, v13) -- inferred equivalent call
			v14.Name = p2 and "LimbFill" or "LimbOutline"
			local v15 = sliced(v14, 0.5, 0, 1, 1, function(p3)
				return (v10 + (v11 - v10) * p3) / v12
			end, backgroundColor2, {
				outline = false,
				flat = true,
				slices = math.max(6, (math.floor(magnitude * 30)))
			})

			if p2 then
				local v16 = lightAngle(item, item2) - v13 -- inferred equivalent call

				for k, v17 in v15 do
					lit(v17, v16)
				end
			end

			if i > 1 then
				joint(i, p, backgroundColor2, p2, list[i - 1], item2)
			end
		end

		if v7.roundBase then
			joint(1, p, backgroundColor2, p2, list[1], list[2])
		end

		if v7.roundTip then
			joint(#list, p, backgroundColor2, p2, list[#list - 1], list[#list])
		end
	end

	if v7.outline ~= false then
		pass(0.04, color6, false)
	end

	pass(0, backgroundColor, true)
	return v8
end

local function ring(parent2, p, p2, p3, p4, color3, rel, value)
	local parent3 = frame(parent2, p, p2, p3, p4, color3, UDim.new(0.5, 0), 0, "Ring")
	parent3.BackgroundTransparency = 1
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = color3
	uiStroke.Transparency = value or 0
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke:SetAttribute("Rel", rel)
	uiStroke.Parent = parent3
	return parent3, uiStroke
end

local function shimmer(items, p)
	for k, item in items do
		local volume2 = item:FindFirstChild("Volume") or gradient(item, {
			{ 0, p },
			{ 1, p }
		}, 90, "Volume")
		local v7 = tint(p, 0.7) -- inferred equivalent call
		local color3 = volume2.Color
		animate(volume2, function(p2) -- inferred equivalent call
			local v8 = p2 % 3 / 3 * 2.4 - 0.7

			if v8 < -0.1 or v8 > 1.1 then
				volume2.Color = color3
				return
			end

			local colorSequenceKeypoints = {}

			for k2, keypoint in color3.Keypoints do
				local v9 = math.abs(keypoint.Time - v8)
				table.insert(
					colorSequenceKeypoints,
					ColorSequenceKeypoint.new(keypoint.Time, keypoint.Value:Lerp(v7, math.max(0, 1 - v9 * 5) * 0.8))
				)
			end

			if v8 > 0.001 and v8 < 0.999 then
				local value = color3.Keypoints[1].Value

				for k2, keypoint in color3.Keypoints do
					if keypoint.Time <= v8 then
						value = keypoint.Value
					end
				end

				table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(v8, value:Lerp(v7, 0.8)))
				table.sort(colorSequenceKeypoints, function(a, b): boolean
					return a.Time < b.Time
				end)
			end

			volume2.Color = ColorSequence.new(colorSequenceKeypoints)
		end)
	end
end

local backgroundColor2 = rgb(255, 196, 52) -- inferred equivalent call
local hats = {
	acc_party = function(parent2)
		local frame_2 = frame(parent2, 0.5, 0.95, 0.62, 0.12, color2, UDim.new(0.5, 0), 0, "Shadow")
		frame_2.BackgroundTransparency = 0.72
		local parent3 = group(parent2, 0.5, 0.5, 1, 1, 4) -- inferred equivalent call
		local backgroundColor = rgb(255, 98, 156) -- inferred equivalent call
		sliced(parent3, 0.5, 0.1, 0.92, 0.58, function(p)
			return 0.1 + 0.9 * p
		end, backgroundColor, {
			decorate = function(p)
				return math.floor(p * 7) % 2 == 1 and rgb(255, 214, 72) or backgroundColor -- inferred equivalent call
			end
		})

		rect(parent3, 0.5, 0.92, 0.66, 0.09, rgb(140, 220, 255), UDim.new(0.5, 0)) -- inferred equivalent call
		local v7, v8 = rgb(255, 236, 120) -- inferred equivalent call
		circle(parent3, 0.44, 0.1, 0.15, v7, v8) -- inferred equivalent call
		local v9, v10 = rgb(255, 236, 120) -- inferred equivalent call
		circle(parent3, 0.56, 0.1, 0.15, v9, v10) -- inferred equivalent call
		local v11, v12 = rgb(255, 236, 120) -- inferred equivalent call
		circle(parent3, 0.5, 0.04, 0.15, v11, v12) -- inferred equivalent call
		local frame_3 = frame(parent3, 0.42, 0.55, 0.05, 0.3, color, UDim.new(0.5, 0), 14, "Shine")
		frame_3.BackgroundTransparency = 0.6
	end,
	acc_beanie = function(parent2)
		local frame_2 = frame(parent2, 0.5, 0.96, 0.84, 0.12, color2, UDim.new(0.5, 0), 0, "Shadow")
		frame_2.BackgroundTransparency = 0.72
		local backgroundColor = rgb(226, 62, 66) -- inferred equivalent call
		local v7, v8 = rgb(250, 250, 250) -- inferred equivalent call
		circle(parent2, 0.43, 0.26, 0.17, v7, v8) -- inferred equivalent call
		local v9, v10 = rgb(250, 250, 250) -- inferred equivalent call
		circle(parent2, 0.57, 0.26, 0.17, v9, v10) -- inferred equivalent call
		local v11, v12 = rgb(250, 250, 250) -- inferred equivalent call
		circle(parent2, 0.5, 0.2, 0.17, v11, v12) -- inferred equivalent call
		sliced(parent2, 0.5, 0.3, 0.86, 0.8, function(p)
			return (math.sqrt((math.max(0, 1 - (1 - p) ^ 2))))
		end, backgroundColor, {
			decorate = function(p)
				return math.floor(p * 8) % 2 == 1 and shade(backgroundColor, 0.08) or backgroundColor -- inferred equivalent call
			end
		})

		local parent3 = rect(parent2, 0.5, 0.86, 0.9, 0.17, shade(backgroundColor, 0.22), UDim.new(0.4, 0)) -- inferred equivalent call

		for i = 0, 8 do
			local frame_3 = frame(parent3, (i + 0.5) / 9, 0.5, 0.035, 0.7, color2, UDim.new(0.5, 0), 0, "Rib")
			frame_3.BackgroundTransparency = 0.8
		end

		local frame_3 = frame(parent2, 0.34, 0.5, 0.06, 0.22, color, UDim.new(0.5, 0), 20, "Shine")
		frame_3.BackgroundTransparency = 0.55
	end,
	acc_cap = function(parent2)
		local frame_2 = frame(parent2, 0.5, 0.95, 0.8, 0.12, color2, UDim.new(0.5, 0), 0, "Shadow")
		frame_2.BackgroundTransparency = 0.72
		local backgroundColor = rgb(58, 110, 230) -- inferred equivalent call
		local v7, v8 = shade(backgroundColor, 0.3) -- inferred equivalent call
		circle(parent2, 0.5, 0.38, 0.11, v7, v8) -- inferred equivalent call
		sliced(parent2, 0.5, 0.4, 0.88, 0.76, function(p)
			return (math.sqrt((math.max(0, 1 - (1 - p) ^ 2))))
		end, backgroundColor, nil)

		local frame_3 = frame(
			parent2,
			0.5,
			0.66,
			0.025,
			0.42,
			shade(backgroundColor, 0.45), -- inferred equivalent call
			UDim.new(0.5, 0),
			0,
			"Seam"
		)
		frame_3.BackgroundTransparency = 0.3
		local v9, v10 = rgb(255, 214, 72) -- inferred equivalent call
		circle(parent2, 0.63, 0.68, 0.14, v9, v10) -- inferred equivalent call
		rect(parent2, 0.8, 0.86, 0.46, 0.11, shade(backgroundColor, 0.25), UDim.new(0.5, 0), -4) -- inferred equivalent call
		local frame_4 = frame(parent2, 0.37, 0.56, 0.06, 0.2, color, UDim.new(0.5, 0), 18, "Shine")
		frame_4.BackgroundTransparency = 0.55
	end,
	acc_bow = function(parent2)
		local v7 = rgb(255, 112, 168) -- inferred equivalent call
		rect(parent2, 0.42, 0.9, 0.1, 0.2, shade(v7, 0.15), UDim.new(0.25, 0), 18) -- inferred equivalent call
		rect(parent2, 0.58, 0.9, 0.1, 0.2, shade(v7, 0.15), UDim.new(0.25, 0), -18) -- inferred equivalent call

		rect(parent2, 0.28, 0.72, 0.34, 0.3, v7, UDim.new(0.35, 0), 45)
		rect(parent2, 0.72, 0.72, 0.34, 0.3, v7, UDim.new(0.35, 0), 45)
		rect(parent2, 0.34, 0.72, 0.12, 0.12, shade(v7, 0.3), UDim.new(0.4, 0), 45, { -- inferred equivalent call
			outline = false,
			flat = true
		})
		rect(parent2, 0.66, 0.72, 0.12, 0.12, shade(v7, 0.3), UDim.new(0.4, 0), 45, { -- inferred equivalent call
			outline = false,
			flat = true
		})
		local v8, v9 = shade(v7, 0.12) -- inferred equivalent call
		circle(parent2, 0.5, 0.73, 0.2, v8, v9) -- inferred equivalent call
		local frame_2 = frame(parent2, 0.22, 0.66, 0.05, 0.14, color, UDim.new(0.5, 0), 45, "Shine")
		frame_2.BackgroundTransparency = 0.5
		local frame_3 = frame(parent2, 0.66, 0.66, 0.05, 0.14, color, UDim.new(0.5, 0), 45, "Shine")
		frame_3.BackgroundTransparency = 0.5
	end,
	acc_tophat = function(parent2)
		local frame_2 = frame(parent2, 0.5, 0.95, 0.86, 0.12, color2, UDim.new(0.5, 0), 0, "Shadow")
		frame_2.BackgroundTransparency = 0.72
		local v7 = rgb(46, 46, 54) -- inferred equivalent call
		sliced(parent2, 0.5, 0.06, 0.82, 0.56, function(p)
			return 0.98 - 0.12 * p
		end, v7)

		rect(parent2, 0.5, 0.72, 0.5, 0.1, rgb(206, 44, 58), nil, 0, { outline = false }) -- inferred equivalent call
		rect(parent2, 0.5, 0.86, 0.9, 0.1, v7, UDim.new(0.5, 0))
		local frame_3 = frame(parent2, 0.35, 0.4, 0.05, 0.46, color, UDim.new(0.5, 0), 0, "Shine")
		frame_3.BackgroundTransparency = 0.75
	end,
	acc_cowboy = function(parent2)
		local frame_2 = frame(parent2, 0.5, 0.95, 0.9, 0.12, color2, UDim.new(0.5, 0), 0, "Shadow")
		frame_2.BackgroundTransparency = 0.72
		local backgroundColor = rgb(172, 112, 60) -- inferred equivalent call

		local function fn(p)
			return 0.9 + 0.1 * p
		end

		local function fn2(p)
			return (math.sqrt((math.max(0, 1 - (1 - p) ^ 2))))
		end

		for k, v7 in { 0.38, 0.62 } do
			sliced(parent2, v7, 0.26, 0.52, 0.38, fn2, color6, {
				outline = false,
				flat = true,
				slices = 12
			})
		end

		sliced(parent2, 0.5, 0.38, 0.82, 0.64, fn, color6, {
			outline = false,
			flat = true,
			slices = 10
		})

		for k, v7 in { 0.38, 0.62 } do
			sliced(parent2, v7, 0.3, 0.52, 0.3, fn2, backgroundColor, {
				outline = false,
				slices = 12
			})
		end

		sliced(parent2, 0.5, 0.42, 0.82, 0.56, fn, backgroundColor, { outline = false, slices = 14 })
		frame(parent2, 0.5, 0.42, 0.03, 0.12, shade(backgroundColor, 0.4), UDim.new(0.5, 0), 0, "Crease") -- inferred equivalent call
		rect(parent2, 0.5, 0.74, 0.58, 0.09, shade(backgroundColor, 0.55), nil, 0, { -- inferred equivalent call
			outline = false
		})
		rect(parent2, 0.5, 0.74, 0.09, 0.09, backgroundColor2, UDim.new(0.2, 0), 0, {
			outline = false
		})
		local frame_3 = frame(parent2, 0.33, 0.56, 0.05, 0.22, color, UDim.new(0.5, 0), 0, "Shine")
		frame_3.BackgroundTransparency = 0.6

		limb(
			parent2,
			{
				newVector2(0.03, 0.64),
				newVector2(0.14, 0.8),
				newVector2(0.32, 0.86),
				newVector2(0.5, 0.87),
				newVector2(0.68, 0.86),
				newVector2(0.86, 0.8),
				newVector2(0.97, 0.64)
			},
			{ 0.06, 0.1, 0.12, 0.13, 0.12, 0.1, 0.06 },
			shade(backgroundColor, 0.06), -- inferred equivalent call
			{ roundTip = true, roundBase = true }
		)
	end,
	acc_santa = function(parent2)
		local frame_2 = frame(parent2, 0.5, 0.96, 0.86, 0.12, color2, UDim.new(0.5, 0), 0, "Shadow")
		frame_2.BackgroundTransparency = 0.72
		local backgroundColor = rgb(214, 36, 46) -- inferred equivalent call
		limb(
			parent2,
			{
				newVector2(0.5, 0.86),
				newVector2(0.5, 0.54),
				newVector2(0.56, 0.29),
				newVector2(0.71, 0.15),
				newVector2(0.85, 0.24)
			},
			{ 0.72, 0.52, 0.32, 0.17, 0.08 },
			backgroundColor,
			{ roundTip = true }
		)
		circle(parent2, 0.86, 0.3, 0.2, color) -- inferred equivalent call
		local frame_3 = frame(parent2, 0.38, 0.6, 0.05, 0.22, color, UDim.new(0.5, 0), 4, "Shine")
		frame_3.BackgroundTransparency = 0.6

		rect(parent2, 0.5, 0.86, 0.86, 0.18, rgb(248, 248, 250), UDim.new(0.5, 0)) -- inferred equivalent call

		for k, v7 in { 0.2, 0.36, 0.5, 0.64, 0.8 } do
			circle(parent2, v7, 0.83 + k % 2 * 0.02, 0.12, color, { outline = false }) -- inferred equivalent call
		end
	end,
	acc_headphones = function(parent2)
		local v7 = group(parent2, 0.5, 0.34, 1.1, 0.68) -- inferred equivalent call
		v7.ClipsDescendants = true
		ring(v7, 0.5, 0.94, 0.76, 1.24, color6, 0.17)
		ring(v7, 0.5, 0.94, 0.76, 1.24, rgb(72, 72, 86), 0.1) -- inferred equivalent call
		local v8 = rgb(240, 66, 106) -- inferred equivalent call

		for k, v9 in { 0.1, 0.9 } do
			rect(parent2, v9, 0.66, 0.08, 0.14, rgb(72, 72, 86), UDim.new(0.3, 0)) -- inferred equivalent call
			rect(parent2, v9, 0.82, 0.24, 0.4, v8, UDim.new(0.45, 0))
			rect(parent2, v9 + (v9 < 0.5 and 0.06 or -0.06), 0.82, 0.08, 0.28, shade(v8, 0.45), UDim.new(0.5, 0), 0, { -- inferred equivalent call
				outline = false,
				flat = true
			})
			local v10 = v9 - 0.04
			local frame_2 = frame(parent2, v10, 0.74, 0.04, 0.12, color, UDim.new(0.5, 0), 0, "Shine")
			frame_2.BackgroundTransparency = 0.5
		end
	end,
	acc_wizard = function(parent2)
		local frame_2 = frame(parent2, 0.5, 0.96, 0.96, 0.12, color2, UDim.new(0.5, 0), 0, "Shadow")
		frame_2.BackgroundTransparency = 0.72
		local v7 = rgb(116, 64, 204) -- inferred equivalent call
		limb(
			parent2,
			{
				newVector2(0.5, 0.88),
				newVector2(0.5, 0.5),
				newVector2(0.53, 0.28),
				newVector2(0.62, 0.12),
				newVector2(0.77, 0.06)
			},
			{ 0.62, 0.4, 0.24, 0.12, 0.03 },
			v7
		)
		rect(parent2, 0.5, 0.78, 0.56, 0.08, backgroundColor2, nil, 0, { outline = false })
		UI.icon("star", 10, backgroundColor2, {
			Name = "Star",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.45, 0.62),
			Size = UDim2.fromScale(0.16, 0.16),
			Parent = parent2
		})

		frame(parent2, 0.56, 0.43, 0.1, 0.1, backgroundColor2, UDim.new(0.5, 0), 0, "Moon")
		frame(parent2, 0.585, 0.415, 0.085, 0.085, v7, UDim.new(0.5, 0), 0, "MoonCut")
		local frame_3 = frame(parent2, 0.4, 0.62, 0.04, 0.2, color, UDim.new(0.5, 0), 2, "Shine")
		frame_3.BackgroundTransparency = 0.65

		rect(parent2, 0.5, 0.88, 1, 0.12, shade(v7, 0.3), UDim.new(0.5, 0)) -- inferred equivalent call
	end,
	acc_viking = function(parent2)
		local frame_2 = frame(parent2, 0.5, 0.95, 0.84, 0.12, color2, UDim.new(0.5, 0), 0, "Shadow")
		frame_2.BackgroundTransparency = 0.72
		local v7 = rgb(246, 236, 212) -- inferred equivalent call

		for k, v8 in { -1, 1 } do
			limb(parent2, {
				newVector2(0.5 + v8 * 0.26, 0.68),
				newVector2(0.5 + v8 * 0.42, 0.6),
				newVector2(0.5 + v8 * 0.5, 0.43),
				newVector2(0.5 + v8 * 0.47, 0.24)
			}, { 0.2, 0.15, 0.09, 0.025 }, v7)
		end

		local backgroundColor = rgb(170, 176, 190) -- inferred equivalent call
		sliced(parent2, 0.5, 0.34, 0.86, 0.78, function(p)
			return (math.sqrt((math.max(0, 1 - (1 - p) ^ 2))))
		end, backgroundColor, nil)

		rect(parent2, 0.5, 0.86, 0.84, 0.13, rgb(132, 84, 48), UDim.new(0.3, 0)) -- inferred equivalent call

		for k, v8 in { 0.2, 0.35, 0.5, 0.65, 0.8 } do
			circle(parent2, v8, 0.86, 0.05, rgb(224, 228, 236), { outline = false }) -- inferred equivalent call
		end

		rect(parent2, 0.5, 0.6, 0.07, 0.4, shade(backgroundColor, 0.15), UDim.new(0.5, 0)) -- inferred equivalent call
		local frame_3 = frame(parent2, 0.33, 0.55, 0.06, 0.22, color, UDim.new(0.5, 0), 20, "Shine")
		frame_3.BackgroundTransparency = 0.45
	end,
	acc_propeller = function(folder)
		local frame_2 = frame(folder, 0.5, 0.95, 0.84, 0.12, color2, UDim.new(0.5, 0), 0, "Shadow")
		frame_2.BackgroundTransparency = 0.72

		local v7 = { rgb(232, 64, 64), rgb(255, 208, 60), rgb(70, 130, 240), rgb(90, 200, 100) } -- inferred equivalent call
		local backBlades = group(folder, 0.5, 0.5, 1, 1, 0) -- inferred equivalent call
		backBlades.Name = "BackBlades"
		rect(folder, 0.5, 0.3, 0.06, 0.16, rgb(130, 130, 142))
		sliced(folder, 0.5, 0.36, 0.88, 0.82, function(p)
			return (math.sqrt((math.max(0, 1 - (1 - p) ^ 2))))
		end, v7[1], nil)

		for i, frame2 in folder:GetDescendants() do
			if not (frame2:IsA("Frame") and frame2.Parent and frame2.Parent.Name == "Fill") then
				continue
			end

			local volume2 = frame2:FindFirstChild("Volume")

			if volume2 then
				volume2:Destroy()
			end

			frame2.BackgroundColor3 = color
			local colorSequenceKeypoints = {}

			for j = 0, 3 do
				table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(j / 4, v7[j + 1]))
				table.insert(
					colorSequenceKeypoints,
					ColorSequenceKeypoint.new(math.min(0.999, (j + 1) / 4 - 0.002), shade(v7[j + 1], 0.12))
				)
			end

			colorSequenceKeypoints[#colorSequenceKeypoints] = ColorSequenceKeypoint.new(1, shade(v7[4], 0.2))
			local uiGradient = Instance.new("UIGradient")
			uiGradient.Color = ColorSequence.new(colorSequenceKeypoints)
			uiGradient.Parent = frame2
		end

		rect(folder, 0.5, 0.88, 0.86, 0.06, rgb(255, 208, 60), UDim.new(0.5, 0)) -- inferred equivalent call
		local frame_3 = frame(folder, 0.33, 0.56, 0.06, 0.2, color, UDim.new(0.5, 0), 20, "Shine")
		frame_3.BackgroundTransparency = 0.5
		local frontBlades = group(folder, 0.5, 0.5, 1, 1, 0) -- inferred equivalent call
		frontBlades.Name = "FrontBlades"
		local v8, v9 = rgb(232, 64, 64) -- inferred equivalent call
		circle(folder, 0.5, 0.21, 0.1, v8, v9) -- inferred equivalent call
		local vector2 = newVector2(0.5, 0.22)
		local v10 = {}

		for k, v11 in { rgb(255, 214, 72), rgb(255, 128, 56) } do -- inferred equivalent call
			local blade = Instance.new("Frame")
			blade.Name = "Blade"
			blade.BorderSizePixel = 0
			blade.AnchorPoint = Vector2.new(0.5, 0.5)
			blade.BackgroundColor3 = color
			local uiCorner = Instance.new("UICorner")
			uiCorner.CornerRadius = UDim.new(0.5, 0)
			uiCorner.Parent = blade
			gradient(blade, {
				{ 0, tint(v11, 0.3) },
				{ 0.5, v11 },
				{ 1, shade(v11, 0.25) }
			}, 90, "Volume")
			local uiStroke = Instance.new("UIStroke")
			uiStroke.Color = color6
			uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			uiStroke:SetAttribute("Rel", 0.032)
			uiStroke.Parent = blade
			blade.Parent = frontBlades
			v10[k] = {
				f = blade,
				phase = (k - 1) * 3.141592653589793
			}
		end

		local function place(p)
			for k, v11 in v10 do
				local v12 = p * 11 + v11.phase
				local v13 = math.cos(v12)
				local v14 = math.sin(v12)

				local v15 = math.abs(v13) * 0.42 + 0.13
				local v16 = v14 * 0.025 + 0.1
				local v17 = vector2 + newVector2(v13 * 0.42 / 2, v14 * 0.42 * 0.24 / 2)
				v11.f.Position = UDim2.fromScale(v17.X, v17.Y)
				v11.f.Size = UDim2.fromScale(v15, v16)
				local v18 = v13 >= 0 and 1 or -1
				v11.f.Rotation = math.deg((math.atan2(
					v14 * math.abs(v13) * 0.42 * 0.24 * v18,
					math.abs(v13) * 0.42 + 0.13
				)))
				local parent2 = v14 < 0 and backBlades or frontBlades

				if v11.f.Parent ~= parent2 then
					v11.f.Parent = parent2
				end
			end
		end
		place(0.35)
		animate(frontBlades, function(p) -- inferred equivalent call
			place(p)
		end)
	end,
	acc_crown = function(parent2)
		local frame_2 = frame(parent2, 0.5, 0.95, 0.9, 0.12, color2, UDim.new(0.5, 0), 0, "Shadow")
		frame_2.BackgroundTransparency = 0.72

		local backgroundColor = backgroundColor2
		local backgroundColor3 = rgb(190, 30, 60) -- inferred equivalent call
		sliced(parent2, 0.5, 0.42, 0.78, 0.66, function(p)
			return (math.sqrt((math.max(0, 1 - (1 - p) ^ 2))))
		end, backgroundColor3, { outline = false })
		local v7 = {}

		for k, v8 in {
			{ 0.16, 0.42, 0.22 },
			{ 0.33, 0.32, 0.24 },
			{ 0.5, 0.18, 0.28 },
			{ 0.67, 0.32, 0.24 },
			{ 0.84, 0.42, 0.22 }
		} do
			local v9 = v8[1]
			local v10 = v8[2]

			for k2, v11 in sliced(parent2, v9, v10, 0.76, v8[3], function(p)
				return 0.1 + 0.9 * p
			end, backgroundColor, { slices = 14 }) do
				table.insert(v7, v11)
			end

			local v11 = v10 + 0.01
			local v12, v13 = tint(backgroundColor, 0.2) -- inferred equivalent call
			circle(parent2, v9, v11, 0.08, v12, v13) -- inferred equivalent call
		end

		table.insert(v7, rect(parent2, 0.5, 0.82, 0.9, 0.24, backgroundColor, UDim.new(0.15, 0)))
		local v8, v9 = rgb(220, 30, 70) -- inferred equivalent call
		circle(parent2, 0.5, 0.82, 0.14, v8, v9) -- inferred equivalent call
		local v10, v11 = rgb(50, 120, 245) -- inferred equivalent call
		circle(parent2, 0.27, 0.82, 0.1, v10, v11) -- inferred equivalent call
		local v12, v13 = rgb(40, 200, 110) -- inferred equivalent call
		circle(parent2, 0.73, 0.82, 0.1, v12, v13) -- inferred equivalent call
		local v14, v15 = rgb(220, 30, 70) -- inferred equivalent call
		circle(parent2, 0.5, 0.2, 0.09, v14, v15) -- inferred equivalent call
		local frame_3 = frame(parent2, 0.47, 0.79, 0.04, 0.05, color, UDim.new(0.5, 0), 0, "Shine")
		frame_3.BackgroundTransparency = 0.3

		shimmer(v7, backgroundColor)
	end,
	acc_halo = function(parent2)
		local parent3 = group(parent2, 0.5, 0.5, 1, 1, 0) -- inferred equivalent call
		ring(parent3, 0.5, 0.26, 1.02, 0.44, rgb(255, 244, 190), 0.2, 0.75) -- inferred equivalent call
		ring(parent3, 0.5, 0.26, 0.9, 0.34, color6, 0.12, 0.5)
		ring(parent3, 0.5, 0.26, 0.9, 0.34, rgb(255, 222, 100), 0.08) -- inferred equivalent call
		ring(parent3, 0.5, 0.24, 0.8, 0.26, rgb(255, 250, 220), 0.025, 0.2) -- inferred equivalent call

		local v7 = {}

		for k, v8 in {
			{ 0.08, 0.1 },
			{ 0.92, 0.2 },
			{ 0.75, 0 }
		} do
			v7[k] = UI.icon("star", 10, rgb(255, 240, 170), { -- inferred equivalent call
				Name = "Twinkle",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(v8[1], v8[2]),
				Size = UDim2.fromScale(0.14, 0.14),
				Parent = parent3
			})
		end

		animate(parent3, function(p) -- inferred equivalent call
			parent3.Position = UDim2.fromScale(0.5, math.sin(p * 2.4) * 0.05 + 0.5)

			for k, v8 in v7 do
				local v9 = math.sin(p * 3 + k * 2.1) * 0.5 + 0.5
				v8.ImageTransparency = 1 - v9
				v8.Size = UDim2.fromScale(v9 * 0.08 + 0.08, v9 * 0.08 + 0.08)
			end
		end)
	end,
	acc_chef = function(parent2)
		local frame_2 = frame(parent2, 0.5, 0.95, 0.74, 0.12, color2, UDim.new(0.5, 0), 0, "Shadow")
		frame_2.BackgroundTransparency = 0.72
		local v7 = rgb(250, 250, 252) -- inferred equivalent call
		rect(parent2, 0.5, 0.56, 0.56, 0.24, v7, UDim.new(0.25, 0))
		circle(parent2, 0.27, 0.42, 0.42, v7) -- inferred equivalent call
		circle(parent2, 0.73, 0.42, 0.42, v7) -- inferred equivalent call
		circle(parent2, 0.5, 0.3, 0.52, v7) -- inferred equivalent call
		local parent3 = rect(parent2, 0.5, 0.79, 0.6, 0.28, rgb(244, 244, 248), UDim.new(0.14, 0)) -- inferred equivalent call

		for i = 1, 4 do
			local frame_3 = frame(parent3, i / 5, 0.52, 0.03, 0.72, rgb(196, 200, 212), UDim.new(0.5, 0), 0, "Pleat") -- inferred equivalent call
			frame_3.BackgroundTransparency = 0.3
		end

		local frame_3 = frame(parent2, 0.4, 0.2, 0.14, 0.07, color, UDim.new(0.5, 0), -20, "Shine")
		frame_3.BackgroundTransparency = 0.4
	end,
	acc_beret = function(parent2)
		local frame_2 = frame(parent2, 0.5, 0.95, 0.78, 0.12, color2, UDim.new(0.5, 0), 0, "Shadow")
		frame_2.BackgroundTransparency = 0.72
		local v7 = rgb(186, 38, 62) -- inferred equivalent call
		local parent3 = group(parent2, 0.5, 0.5, 1, 1, -5) -- inferred equivalent call
		rect(parent3, 0.52, 0.41, 0.05, 0.1, shade(v7, 0.25), UDim.new(0.4, 0)) -- inferred equivalent call

		sliced(parent3, 0.5, 0.43, 0.83, 1, function(p)
			return math.sqrt((math.max(0, 1 - (2 * p - 1) ^ 2))) ^ 0.7
		end, v7)

		rect(parent3, 0.5, 0.85, 0.66, 0.09, shade(v7, 0.4), UDim.new(0.5, 0)) -- inferred equivalent call
		local frame_3 = frame(parent3, 0.36, 0.53, 0.22, 0.05, color, UDim.new(0.5, 0), -4, "Shine")
		frame_3.BackgroundTransparency = 0.6
	end,
	acc_pirate = function(parent2)
		local frame_2 = frame(parent2, 0.5, 0.95, 0.9, 0.12, color2, UDim.new(0.5, 0), 0, "Shadow")
		frame_2.BackgroundTransparency = 0.72
		local backgroundColor = rgb(46, 44, 54) -- inferred equivalent call

		local function fn(p)
			return (math.sqrt((math.max(0, 1 - (1 - p) ^ 2))))
		end

		sliced(parent2, 0.5, 0.3, 0.92, 1.02, fn, backgroundColor2, { slices = 40 })
		sliced(parent2, 0.5, 0.36, 0.87, 0.9, fn, backgroundColor, { outline = false, slices = 36 })
		local v7 = rgb(246, 242, 230) -- inferred equivalent call

		for k, v8 in { 35, -35 } do
			rect(parent2, 0.5, 0.72, 0.36, 0.05, v7, UDim.new(0.5, 0), v8, { flat = true })
		end

		circle(parent2, 0.5, 0.62, 0.2, v7, { flat = true }) -- inferred equivalent call
		rect(parent2, 0.5, 0.72, 0.11, 0.07, v7, UDim.new(0.3, 0), 0, {
			outline = false,
			flat = true
		})
		circle(parent2, 0.457, 0.62, 0.055, color6, { outline = false, flat = true }) -- inferred equivalent call
		circle(parent2, 0.543, 0.62, 0.055, color6, { outline = false, flat = true }) -- inferred equivalent call
		local frame_3 = frame(parent2, 0.24, 0.6, 0.05, 0.2, color, UDim.new(0.5, 0), 30, "Shine")
		frame_3.BackgroundTransparency = 0.7
	end,
	acc_grad = function(parent2)
		local frame_2 = frame(parent2, 0.5, 0.95, 0.78, 0.12, color2, UDim.new(0.5, 0), 0, "Shadow")
		frame_2.BackgroundTransparency = 0.72
		local v7 = rgb(42, 42, 50) -- inferred equivalent call
		sliced(parent2, 0.5, 0.48, 0.9, 0.66, function(p)
			return 0.88 + 0.12 * p
		end, v7)

		local function fn(p)
			return 1 - math.abs(2 * p - 1)
		end

		sliced(parent2, 0.5, 0.25, 0.6, 1.06, fn, shade(v7, 0.35), { flat = true }) -- inferred equivalent call
		sliced(parent2, 0.5, 0.22, 0.56, 1.06, fn, rgb(64, 64, 76), { outline = false }) -- inferred equivalent call
		local v8 = rgb(255, 200, 60) -- inferred equivalent call
		rect(parent2, 0.75, 0.39, 0.5, 0.025, v8, nil, 0, { outline = false, flat = true })
		circle(parent2, 0.5, 0.39, 0.08, v8) -- inferred equivalent call
		local parent3 = group(parent2, 0.99, 0.4, 0.24, 0.9, 0) -- inferred equivalent call
		rect(parent3, 0.5, 0.72, 0.1, 0.46, v8, UDim.new(0.5, 0), 0, { flat = true })
		rect(parent3, 0.5, 0.96, 0.4, 0.14, v8, UDim.new(0.25, 0))
		animate(parent3, function(p) -- inferred equivalent call
			parent3.Rotation = math.sin(p * 2.3) * 9 + math.sin(p * 3.9) * 3
		end)
	end,
	acc_jester = function(parent2)
		local frame_2 = frame(parent2, 0.5, 0.95, 0.88, 0.12, color2, UDim.new(0.5, 0), 0, "Shadow")
		frame_2.BackgroundTransparency = 0.72
		local color3 = rgb(132, 66, 214) -- inferred equivalent call
		local color4 = rgb(58, 186, 112) -- inferred equivalent call
		local v7 = {
			{
				color = color3,
				p = {
					newVector2(0.38, 0.84),
					newVector2(0.28, 0.56),
					newVector2(0.17, 0.4),
					newVector2(0.05, 0.42)
				}
			},
			{
				color = color3,
				p = {
					newVector2(0.62, 0.84),
					newVector2(0.72, 0.56),
					newVector2(0.83, 0.4),
					newVector2(0.95, 0.42)
				}
			},
			{
				color = color4,
				p = {
					newVector2(0.5, 0.84),
					newVector2(0.5, 0.5),
					newVector2(0.54, 0.27),
					newVector2(0.64, 0.12)
				}
			}
		}

		for k, v8 in v7 do
			limb(parent2, v8.p, { 0.32, 0.21, 0.12, 0.05 }, v8.color, { roundTip = true })
			v8.tip = v8.p[#v8.p]
		end

		local parent3 = rect(parent2, 0.5, 0.86, 0.86, 0.15, shade(color3, 0.3), UDim.new(0.35, 0)) -- inferred equivalent call

		for i = 1, 5 do
			frame(parent3, i / 6, 0.5, 0.065, 0.45, backgroundColor2, UDim.new(0.15, 0), 45, "Diamond")
		end

		local v8 = {}

		for k, v9 in v7 do
			local parent4 = group(parent2, v9.tip.X, v9.tip.Y, 0.22, 0.22, 0) -- inferred equivalent call
			circle(parent4, 0.5, 0.72, 0.6, backgroundColor2) -- inferred equivalent call
			rect(parent4, 0.5, 0.86, 0.36, 0.08, shade(backgroundColor2, 0.55), UDim.new(0.5, 0), 0, { -- inferred equivalent call
				outline = false,
				flat = true
			})
			local frame_3 = frame(parent4, 0.38, 0.6, 0.14, 0.14, color, UDim.new(0.5, 0), 0, "Shine")
			frame_3.BackgroundTransparency = 0.35

			v8[k] = parent4
		end

		animate(v8[1], function(p) -- inferred equivalent call
			for k, v9 in v8 do
				v9.Rotation = math.sin(p * 6.5 + k * 2.1) * 16 * (math.sin(p * 1.3 + k) * 0.4 + 0.6)
			end
		end)
		local frame_3 = frame(parent2, 0.27, 0.6, 0.05, 0.16, color, UDim.new(0.5, 0), -30, "Shine")
		frame_3.BackgroundTransparency = 0.6
	end
}

local function flameWidth(p)
	return math.sin(p * 3.141592653589793 * 0.62) / 0.93
end

local function flame(parent2, p, p2, p3, p4, items)
	local flame2 = Instance.new("Frame")
	flame2.Name = "Flame"
	flame2.BackgroundTransparency = 1
	flame2.AnchorPoint = Vector2.new(0.5, 1)
	flame2.Position = UDim2.fromScale(p, p2)
	flame2.Size = UDim2.fromScale(p3, p4)
	flame2.Parent = parent2

	for k, item in items do
		sliced(flame2, 0.5, item[1], 1, item[2], flameWidth, item[3], {
			outline = false,
			flat = true,
			slices = item[5],
			decorate = function(p5)
				return item[3]:Lerp(item[4], (math.min(1, p5 * 1.3)))
			end
		})
	end

	return flame2
end

function hats.acc_flamecrown(parent2)
	local frame_2 = frame(parent2, 0.5, 0.95, 0.88, 0.12, color2, UDim.new(0.5, 0), 0, "Shadow")
	frame_2.BackgroundTransparency = 0.72

	local v7 = {}

	for k, v8 in {
		{ 1.45, 0.05 },
		{ 1.15, 0.07 },
		{ 0.85, 0.1 },
		{ 0.55, 0.12 }
	} do
		local v9 = frame(parent2, 0.5, 0.5, v8[1], v8[1] * 0.9, rgb(255, 110, 30), UDim.new(0.5, 0), 0, "Glow") -- inferred equivalent call
		v9.BackgroundTransparency = 1 - v8[2]
		v7[k] = { f = v9, op = v8[2] }
	end

	local v8 = {}
	local function addFlame(p, p2, p3, sway)
		table.insert(v8, {
			f = p,
			h = p2,
			w = p3,
			sway = sway,
			ph = random:NextNumber() * 6,
			sp = 6 + random:NextNumber() * 4
		})
	end

	for k, v9 in {
		{ 0.15, 0.42 },
		{ 0.32, 0.56 },
		{ 0.5, 0.72 },
		{ 0.68, 0.56 },
		{ 0.85, 0.42 }
	} do
		addFlame(flame(parent2, v9[1], 0.8, 0.32, v9[2], {
			{ 0, 1, rgb(214, 40, 26), rgb(255, 112, 34), 16 }, -- inferred equivalent call
			{ 0.3, 0.62, rgb(255, 128, 36), rgb(255, 196, 66), 9 } -- inferred equivalent call
		}), v9[2], 0.32, 7)
	end

	local backgroundColor = rgb(70, 58, 68) -- inferred equivalent call

	for k, v9 in {
		{ 0.15, 0.56, 0.22 },
		{ 0.32, 0.46, 0.24 },
		{ 0.5, 0.36, 0.27 },
		{ 0.68, 0.46, 0.24 },
		{ 0.85, 0.56, 0.22 }
	} do
		sliced(parent2, v9[1], v9[2], 0.78, v9[3], function(p)
			return 0.1 + 0.9 * p
		end, backgroundColor, { slices = 10 })
		circle(parent2, v9[1], v9[2] + 0.01, 0.05, rgb(255, 214, 90), { outline = false }) -- inferred equivalent call
	end

	for k, v9 in {
		{ 0.235, 0.3 },
		{ 0.41, 0.38 },
		{ 0.59, 0.38 },
		{ 0.765, 0.3 }
	} do
		addFlame(flame(parent2, v9[1], 0.8, 0.2, v9[2], {
			{ 0, 1, rgb(230, 50, 24), rgb(255, 140, 34), 11 }, -- inferred equivalent call
			{ 0.28, 0.66, rgb(255, 150, 36), rgb(255, 220, 80), 8 }, -- inferred equivalent call
			{ 0.55, 0.36, rgb(255, 236, 140), rgb(255, 255, 236), 6 } -- inferred equivalent call
		}), v9[2], 0.2, 10)
	end

	local parent3 = rect(parent2, 0.5, 0.85, 0.94, 0.19, rgb(44, 38, 46), UDim.new(0.2, 0)) -- inferred equivalent call
	local v9 = {}

	for k, v10 in {
		{ 0.1, 0.5, 0.12, 35 },
		{ 0.19, 0.42, 0.09, -40 },
		{ 0.32, 0.56, 0.11, 22 },
		{ 0.68, 0.5, 0.11, -24 },
		{ 0.8, 0.42, 0.09, 40 },
		{ 0.9, 0.56, 0.12, -32 }
	} do
		table.insert(
			v9,
			frame(parent3, v10[1], v10[2], v10[3], 0.09, rgb(255, 120, 30), UDim.new(0.5, 0), v10[4], "Crack") -- inferred equivalent call
		)
	end

	local v10 = {}

	for k, v11 in { 0.758, 0.942 } do
		table.insert(
			v10,
			rect(parent2, 0.5, v11, 0.96, 0.035, backgroundColor2, UDim.new(0.5, 0), 0, {
				outline = false
			})
		)
	end

	shimmer(v10, backgroundColor2)

	for k, v11 in { 0.27, 0.73 } do
		local v12, v13 = rgb(255, 150, 40) -- inferred equivalent call
		circle(parent2, v11, 0.85, 0.08, v12, v13) -- inferred equivalent call
	end

	rect(parent2, 0.5, 0.85, 0.14, 0.14, rgb(232, 40, 40), UDim.new(0.2, 0), 45) -- inferred equivalent call
	local v11 = frame(parent2, 0.5, 0.85, 0.07, 0.07, rgb(255, 230, 150), UDim.new(0.5, 0), 0, "GemCore") -- inferred equivalent call

	local v12 = {}

	for i = 1, 3 do
		v12[i] = {
			f = flame(parent2, 0.5, 0.4, 0.09, 0.14, {
				{ 0, 1, rgb(240, 60, 24), rgb(255, 190, 60), 8 } -- inferred equivalent call
			}),
			seed = (i - 1) / 3,
			x = (i - 1) * 0.2 + 0.3,
			sp = 0.7 + random:NextNumber() * 0.3
		}
	end

	local v13 = {}

	for i = 1, 7 do
		v13[i] = {
			f = frame(parent2, 0.5, 0.5, 0.045, 0.045, rgb(255, 220, 120), UDim.new(0.3, 0), 45, "Ember"), -- inferred equivalent call
			seed = random:NextNumber(),
			sp = 0.45 + random:NextNumber() * 0.4,
			x = 0.1 + random:NextNumber() * 0.8
		}
	end

	animate(v8[1].f, function(p) -- inferred equivalent call
		for k, v14 in v8 do
			local v15 = p * v14.sp + v14.ph
			local v16 = math.sin(v15) * 0.12 + 1 + math.sin(v15 * 1.9 + 1) * 0.07
			v14.f.Size = UDim2.fromScale(v14.w * (1 - math.sin(v15 * 1.3) * 0.06), v14.h * v16)
			v14.f.Rotation = v14.sway * math.sin(v15 * 0.55 + v14.ph)
		end

		local v14 = math.sin(p * 9.1) * 0.2 * math.sin(p * 5.3) + 0.8

		for k, v15 in v7 do
			v15.f.BackgroundTransparency = 1 - v15.op * v14
		end

		local v15 = math.sin(p * 3.1) * 0.5 + 0.5
		local lerped = rgb(255, 90, 20):Lerp(rgb(255, 210, 90), v15) -- inferred equivalent call

		for k, v16 in v9 do
			v16.BackgroundColor3 = lerped
		end

		local v16 = math.sin(p * 5.2) * 0.5 + 0.5
		v11.BackgroundTransparency = (1 - v16) * 0.5 + 0.1
		v11.Size = UDim2.fromScale(v16 * 0.03 + 0.05, v16 * 0.03 + 0.05)

		for k, v17 in v12 do
			local v18 = (p * v17.sp + v17.seed) % 1
			local v19 = 1 - v18
			v17.f.Position = UDim2.fromScale(v17.x + math.sin(v18 * 6 + v17.seed * 9) * 0.05, 0.36 - v18 * 0.42)
			v17.f.Size = UDim2.fromScale(0.09 * v19, 0.14 * v19 * (math.min(1, v18 * 5) * 0.4 + 0.6))
			v17.f.Rotation = math.sin(v18 * 8 + v17.seed * 5) * 10
		end

		for k, v17 in v13 do
			local v18 = (p * v17.sp + v17.seed) % 1
			v17.f.Position = UDim2.fromScale(v17.x + math.sin(v18 * 7 + v17.seed * 9) * 0.07, 0.6 - v18 * 0.85)
			v17.f.BackgroundColor3 = rgb(255, 240, 160):Lerp(rgb(255, 70, 30), v18) -- inferred equivalent call
			v17.f.BackgroundTransparency = 1 - math.min(1, v18 * 6) * (1 - v18)
			local v19 = 0.045 * (1 - v18 * 0.5)
			v17.f.Size = UDim2.fromScale(v19, v19)
		end
	end)
end

function hats.acc_vip(parent2)
	local frame_2 = frame(parent2, 0.5, 0.95, 0.88, 0.12, color2, UDim.new(0.5, 0), 0, "Shadow")
	frame_2.BackgroundTransparency = 0.72
	local v7 = rgb(34, 32, 40) -- inferred equivalent call
	local parent3 = group(parent2, 0.5, 0.5, 1, 1, -4) -- inferred equivalent call
	sliced(parent3, 0.5, 0.04, 0.8, 0.58, function(p)
		return 1 - 0.1 * p
	end, v7)

	shimmer({ rect(parent3, 0.5, 0.69, 0.53, 0.13, backgroundColor2, nil, 0, { outline = false }) }, backgroundColor2)

	rect(parent3, 0.5, 0.69, 0.13, 0.13, rgb(176, 232, 255), UDim.new(0.18, 0), 45) -- inferred equivalent call
	frame(parent3, 0.47, 0.66, 0.035, 0.035, color, UDim.new(0.5, 0), 0, "Glint")

	rect(parent3, 0.5, 0.86, 0.96, 0.11, v7, UDim.new(0.5, 0))
	rect(parent3, 0.5, 0.9, 0.84, 0.025, backgroundColor2, UDim.new(0.5, 0), 0, {
		outline = false,
		flat = true
	})
	local frame_3 = frame(parent3, 0.34, 0.38, 0.05, 0.44, color, UDim.new(0.5, 0), 0, "Shine")
	frame_3.BackgroundTransparency = 0.72

	local v8 = {}

	for k, v9 in {
		{ 0.06, 0.3 },
		{ 0.92, 0.18 },
		{ 0.84, 0.62 }
	} do
		v8[k] = UI.icon("star", 10, rgb(255, 236, 160), { -- inferred equivalent call
			Name = "Twinkle",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(v9[1], v9[2]),
			Size = UDim2.fromScale(0.14, 0.14),
			Parent = parent2
		})
	end

	animate(v8[1], function(p) -- inferred equivalent call
		for k, v9 in v8 do
			local v10 = math.max(0, (math.sin(p * 2.6 + k * 2.1)))
			v9.ImageTransparency = 1 - v10
			v9.Size = UDim2.fromScale(v10 * 0.1 + 0.06, v10 * 0.1 + 0.06)
			v9.Rotation = (p * 40 + k * 30) % 360
		end
	end)
end

function hats.acc_witch(parent2)
	local frame_2 = frame(parent2, 0.5, 0.96, 0.98, 0.12, color2, UDim.new(0.5, 0), 0, "Shadow")
	frame_2.BackgroundTransparency = 0.72
	local v7 = rgb(54, 38, 74) -- inferred equivalent call
	local parent3 = group(parent2, 0.5, 0.5, 1, 1, -4) -- inferred equivalent call
	limb(
		parent3,
		{
			newVector2(0.5, 0.86),
			newVector2(0.5, 0.5),
			newVector2(0.52, 0.3),
			newVector2(0.6, 0.16),
			newVector2(0.75, 0.13),
			newVector2(0.84, 0.23)
		},
		{ 0.58, 0.38, 0.24, 0.13, 0.07, 0.025 },
		v7
	)
	rect(parent3, 0.5, 0.76, 0.53, 0.1, rgb(255, 132, 36), nil, 0, { outline = false }) -- inferred equivalent call

	rect(parent3, 0.5, 0.76, 0.15, 0.13, backgroundColor2, UDim.new(0.15, 0), 0, { outline = false })
	frame(parent3, 0.5, 0.76, 0.075, 0.065, rgb(255, 132, 36), UDim.new(0.15, 0), 0, "BuckleHole") -- inferred equivalent call
	local frame_3 = frame(parent3, 0.41, 0.52, 0.04, 0.3, color, UDim.new(0.5, 0), 8, "Shine")
	frame_3.BackgroundTransparency = 0.72

	rect(parent2, 0.5, 0.87, 1.02, 0.12, shade(v7, 0.18), UDim.new(0.5, 0)) -- inferred equivalent call
end

function hats.acc_pumpkin(parent2)
	local frame_2 = frame(parent2, 0.5, 0.96, 0.92, 0.12, color2, UDim.new(0.5, 0), 0, "Shadow")
	frame_2.BackgroundTransparency = 0.72
	local v7 = rgb(242, 122, 26) -- inferred equivalent call
	local v8 = {}

	for k, v9 in {
		{ 1.2, 0.05 },
		{ 0.92, 0.07 }
	} do
		local v10 = frame(parent2, 0.5, 0.6, v9[1], v9[1] * 0.85, rgb(255, 150, 40), UDim.new(0.5, 0), 0, "Glow") -- inferred equivalent call
		v10.BackgroundTransparency = 1 - v9[2]
		v8[k] = { f = v10, op = v9[2] }
	end

	rect(parent2, 0.53, 0.22, 0.09, 0.17, rgb(92, 122, 46), UDim.new(0.3, 0), 12) -- inferred equivalent call
	rect(parent2, 0.65, 0.28, 0.17, 0.07, rgb(116, 166, 62), UDim.new(0.5, 0), -22) -- inferred equivalent call

	rect(parent2, 0.5, 0.6, 0.92, 0.62, v7, UDim.new(0.5, 0))
	ring(parent2, 0.5, 0.6, 0.44, 0.6, shade(v7, 0.3), 0.014, 0.35) -- inferred equivalent call
	ring(parent2, 0.5, 0.6, 0.74, 0.61, shade(v7, 0.3), 0.014, 0.45) -- inferred equivalent call

	local v9 = {}
	local function hole(p, p2, p3)
		local parent3 = group(parent2, p, p2, p3, p3 / 2) -- inferred equivalent call
		parent3.ClipsDescendants = true
		local v10 = frame(parent3, 0.5, 1, 0.7071067811865475, 1.4142135623730951, rgb(255, 214, 90), nil, 45, "Cut") -- inferred equivalent call
		table.insert(v9, v10)
	end
	hole(0.35, 0.5, 0.2)
	hole(0.65, 0.5, 0.2)
	hole(0.5, 0.61, 0.1)
	table.insert(v9, frame(parent2, 0.5, 0.73, 0.5, 0.11, rgb(255, 214, 90), UDim.new(0.45, 0), 0, "Grin")) -- inferred equivalent call

	for k, v10 in {
		{ 0.4, 0.695 },
		{ 0.6, 0.695 },
		{ 0.5, 0.765 }
	} do
		frame(parent2, v10[1], v10[2], 0.07, 0.05, v7, UDim.new(0.15, 0), 0, "Tooth")
	end

	local frame_3 = frame(parent2, 0.22, 0.48, 0.05, 0.22, color, UDim.new(0.5, 0), 10, "Shine")
	frame_3.BackgroundTransparency = 0.6

	animate(v9[1], function(p) -- inferred equivalent call
		local v10 = math.sin(p * 7.3) * 0.28 * math.sin(p * 3.1 + 1) + 0.72
		local lerped = rgb(255, 140, 30):Lerp(rgb(255, 238, 150), v10) -- inferred equivalent call

		for k, v11 in v9 do
			v11.BackgroundColor3 = lerped
		end

		for k, v11 in v8 do
			v11.f.BackgroundTransparency = 1 - v11.op * (v10 * 0.4 + 0.6)
		end
	end)
end

Cosmetics2.HATS = hats

local function fitStrokes(folder) -- 1 equivalent call inferred from this helper
	local flag2 = false
	local function fit()
		if flag2 then
			return
		end

		flag2 = true
		local x = folder.AbsoluteSize.X

		for i, uiStroke in folder:GetDescendants() do
			if not (uiStroke:IsA("UIStroke") and uiStroke:GetAttribute("Rel")) then
				continue
			end

			local thickness = math.max(1, uiStroke:GetAttribute("Rel") * x)

			if math.abs(uiStroke.Thickness - thickness) > 0.01 then
				uiStroke.Thickness = thickness
			end
		end

		task.defer(function()
			flag2 = false
		end)
	end
	folder:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
	task.defer(fit)
end

local function artLayer(parent2, p, value, value2)
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = value2 or "Art"
	imageLabel.BackgroundTransparency = 1
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.Position = UDim2.fromScale(0.5, 0.5)
	imageLabel.Size = UDim2.fromScale(1, 1)
	imageLabel.ScaleType = Enum.ScaleType.Fit
	imageLabel.Image = "rbxassetid://" .. tostring(p)
	imageLabel.ZIndex = value or 2
	imageLabel.Parent = parent2
	return imageLabel
end

local function twinkles(parent2, items, p, value)
	local result = {}

	for k, item in items do
		local icon = UI.icon("star", 10, p or rgb(255, 240, 170), { -- inferred equivalent call
			Name = "Twinkle",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(item[1], item[2]),
			Size = UDim2.fromScale(0.14, 0.14),
			Parent = parent2
		})

		icon.ZIndex = value or 3
		result[k] = icon
	end

	animate(result[1], function(p2) -- inferred equivalent call
		for k, v7 in result do
			local v8 = math.max(0, (math.sin(p2 * 2.6 + k * 2.1)))
			v7.ImageTransparency = 1 - v8
			v7.Size = UDim2.fromScale(v8 * 0.1 + 0.05, v8 * 0.1 + 0.05)
			v7.Rotation = (p2 * 40 + k * 30) % 360
		end
	end)
	return result
end

local function glowBlob(parent2, p, p2, p3, p4, p5, p6) -- 2 equivalent calls inferred from this helper
	local v7 = frame(parent2, p, p2, p3, p4, p5, UDim.new(0.5, 0), 0, "Glow")
	v7.BackgroundTransparency = 1 - p6
	v7.ZIndex = 1
	return v7
end

local v7 = {
	acc_beanie = { s = 1.159, ay = 0.922 },
	acc_beret = { s = 1.15, ay = 0.938 },
	acc_bow = { s = 1.1, ay = 0.84 },
	acc_cap = { s = 1.25, ay = 0.83 },
	acc_chef = { s = 1.2, ay = 0.934 },
	acc_cowboy = { s = 1.3, ay = 0.801 },
	acc_crown = { s = 1.019, ay = 0.934 },
	acc_flamecrown = { s = 1.09, ay = 0.934 },
	acc_grad = { s = 1.15, ay = 0.859 },
	acc_halo = { s = 1, ay = 0.5, y = 0.5 },
	acc_headphones = { s = 1.25, ay = 0.79, y = 0.95 },
	acc_jester = { s = 1.15, ay = 0.934 },
	acc_party = { s = 1.12, ay = 0.86 },
	acc_pirate = { s = 1.159, ay = 0.859 },
	acc_propeller = { s = 1.2, ay = 0.859 },
	acc_pumpkin = { s = 1.101, ay = 0.938 },
	acc_santa = { s = 1.058, ay = 0.93 },
	acc_tophat = { s = 1.15, ay = 0.871 },
	acc_vip = { s = 1.15, ay = 0.871 },
	acc_viking = { s = 1.237, ay = 0.891 },
	acc_witch = { s = 1.15, ay = 0.859 },
	acc_wizard = { s = 1.15, ay = 0.867 }
}

Cosmetics2.IMAGE_FIT = v7

local v8 = {
	acc_crown = function(p)
		twinkles(p, {
			{ 0.12, 0.3 },
			{ 0.86, 0.36 },
			{ 0.62, 0.12 }
		})
	end,
	acc_vip = function(p)
		twinkles(p, {
			{ 0.08, 0.3 },
			{ 0.92, 0.2 },
			{ 0.86, 0.62 }
		}, rgb(255, 236, 160))
	end,
	acc_halo = function(p, p2)
		twinkles(p, {
			{ 0.08, 0.36 },
			{ 0.92, 0.42 },
			{ 0.74, 0.22 }
		})

		animate(p2, function(p3) -- inferred equivalent call
			p2.Position = UDim2.fromScale(0.5, math.sin(p3 * 2.4) * 0.04 + 0.5)
		end)
	end,
	acc_flamecrown = function(parent2, p, p2)
		local v8 = {}

		for k, v9 in {
			{ 1.3, 0.06 },
			{ 0.95, 0.09 }
		} do
			v8[k] = {
				f = glowBlob(parent2, 0.5, 0.55, v9[1], v9[1] * 0.85, rgb(255, 110, 30), v9[2]), -- inferred equivalent call
				op = v9[2]
			}
		end

		if not p2.fx then
			return
		end

		local v9 = artLayer(parent2, p2.fx, 1, "Flames")
		v9.AnchorPoint = Vector2.new(0.5, 0.79)
		v9.Position = UDim2.fromScale(0.5, 0.79)
		animate(v9, function(p3) -- inferred equivalent call
			local v10 = math.sin(p3 * 9.1) * math.sin(p3 * 4.3 + 1)
			v9.Size = UDim2.fromScale(1 - v10 * 0.03, v10 * 0.08 + 1 + math.sin(p3 * 13) * 0.03)
			v9.Rotation = math.sin(p3 * 5.2) * 2.2

			for k, v11 in v8 do
				v11.f.BackgroundTransparency = 1 - v11.op * (v10 * 0.25 + 0.75)
			end
		end)
	end,
	acc_pumpkin = function(parent2, p, p2)
		local v8 = {}

		for k, v9 in {
			{ 1.2, 0.05 },
			{ 0.92, 0.07 }
		} do
			v8[k] = {
				f = glowBlob(parent2, 0.5, 0.6, v9[1], v9[1] * 0.85, rgb(255, 150, 40), v9[2]), -- inferred equivalent call
				op = v9[2]
			}
		end

		if not p2.fx then
			return
		end

		local v9 = artLayer(parent2, p2.fx, 3, "Face")
		animate(v9, function(p3) -- inferred equivalent call
			local v10 = math.sin(p3 * 7.3) * 0.28 * math.sin(p3 * 3.1 + 1) + 0.72
			v9.ImageTransparency = (1 - v10) * 1.2

			for k, v11 in v8 do
				v11.f.BackgroundTransparency = 1 - v11.op * (v10 * 0.4 + 0.6)
			end
		end)
	end,
	acc_propeller = function(instance)
		local backBlades = group(instance, 0.5, 0.5, 1, 1, 0) -- inferred equivalent call
		backBlades.Name = "BackBlades"
		backBlades.ZIndex = 1
		local frontBlades = group(instance, 0.5, 0.5, 1, 1, 0) -- inferred equivalent call
		frontBlades.Name = "FrontBlades"
		frontBlades.ZIndex = 3
		local vector2 = newVector2(0.5, 0.19)
		local v8 = {}

		for k, v9 in { rgb(255, 214, 72), rgb(255, 128, 56) } do -- inferred equivalent call
			local blade = Instance.new("Frame")
			blade.Name = "Blade"
			blade.BorderSizePixel = 0
			blade.AnchorPoint = Vector2.new(0.5, 0.5)
			blade.BackgroundColor3 = color
			local uiCorner = Instance.new("UICorner")
			uiCorner.CornerRadius = UDim.new(0.5, 0)
			uiCorner.Parent = blade
			gradient(blade, {
				{ 0, tint(v9, 0.3) },
				{ 0.5, v9 },
				{ 1, shade(v9, 0.25) }
			}, 90, "Volume")
			local uiStroke = Instance.new("UIStroke")
			uiStroke.Color = color6
			uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			uiStroke:SetAttribute("Rel", 0.032)
			uiStroke.Parent = blade
			blade.Parent = frontBlades
			v8[k] = {
				f = blade,
				phase = (k - 1) * 3.141592653589793
			}
		end

		local x = vector2.X
		local y = vector2.Y
		local v9, v10 = rgb(232, 64, 64) -- inferred equivalent call
		local v11 = circle(instance, x, y, 0.1, v9, v10) -- inferred equivalent call

		for i, guiObject in instance:GetChildren() do
			if not (guiObject:IsA("GuiObject") and guiObject.ZIndex == 1 and guiObject ~= backBlades and (guiObject.Name == "Outline" or guiObject.Name == "Fill")) then
				continue
			end

			guiObject.ZIndex = guiObject.Name == "Fill" and 5 or 4
		end

		local function place(p)
			for k, v12 in v8 do
				local v13 = p * 11 + v12.phase
				local v14 = math.cos(v13)
				local v15 = math.sin(v13)
				local v16 = math.abs(v14) * 0.42 + 0.13
				local v17 = v15 * 0.025 + 0.1
				local v18 = vector2 + newVector2(v14 * 0.42 / 2, v15 * 0.42 * 0.24 / 2)
				v12.f.Position = UDim2.fromScale(v18.X, v18.Y)
				v12.f.Size = UDim2.fromScale(v16, v17)
				local v19 = v14 >= 0 and 1 or -1
				v12.f.Rotation = math.deg((math.atan2(
					v15 * math.abs(v14) * 0.42 * 0.24 * v19,
					math.abs(v14) * 0.42 + 0.13
				)))
				local parent2 = v15 < 0 and backBlades or frontBlades

				if v12.f.Parent ~= parent2 then
					v12.f.Parent = parent2
				end
			end
		end
		place(0.35)
		animate(frontBlades, function(p) -- inferred equivalent call
			place(p)
		end)
		return v11
	end
}

Cosmetics2.HAT_FX = v8

function Cosmetics2.buildHat(p, parent2)
	local v9 = Cosmetics.BY_ID[p]

	if not v9 or v9.type ~= "accessory" or v9.free then
		return nil
	end

	local hat = Instance.new("Frame")
	hat.Name = "Hat"
	hat.BackgroundTransparency = 1
	hat.ZIndex = 2

	if v9.image then
		local v10 = v7[p] or { s = 1, ay = 0.5, y = 0.5 }
		local fit = Instance.new("Frame")
		fit.Name = "Fit"
		fit.BackgroundTransparency = 1
		fit.AnchorPoint = Vector2.new(0.5, v10.ay)
		fit.Position = UDim2.fromScale(0.5, v10.y or 0.955)
		fit.Size = UDim2.fromScale(v10.s, v10.s)
		fit.Parent = hat
		local v11 = artLayer(fit, v9.image, 2)

		if v8[p] then
			v8[p](fit, v11, v9)
		end
	elseif hats[p] then
		hats[p](hat)
	end

	fitStrokes(hat) -- inferred equivalent call
	hat.Parent = parent2
	return hat
end

Cosmetics2.HAT_SIZE = 0.68
Cosmetics2.HAT_BOTTOM = 0.37

local v9 = {
	acc_pumpkin = { y = -0.045 }
}

Cosmetics2.HAT_FIT = v9

function Cosmetics2.setHat(parent2, id)
	local hat = parent2:FindFirstChild("Hat")

	if hat then
		if hat:GetAttribute("Id") == id then
			return
		end

		hat:Destroy()
	end

	local hat2 = Cosmetics2.buildHat(id, nil)

	if not hat2 then
		return
	end

	hat2:SetAttribute("Id", id)
	hat2.AnchorPoint = Vector2.new(0.5, 1)
	hat2.Size = UDim2.fromScale(Cosmetics2.HAT_SIZE, Cosmetics2.HAT_SIZE)
	local v10 = Cosmetics.BY_ID[id]
	local v11 = v10 and v10.image and {} or v9[id] or {}
	hat2.Position = UDim2.fromScale(
		0.5 + (v11.x or 0) * Cosmetics2.HAT_SIZE,
		Cosmetics2.HAT_BOTTOM + (v11.y or 0) * Cosmetics2.HAT_SIZE
	)
	hat2.Parent = parent2
end

local function grey(value)
	local v10 = (math.clamp)(value, 0, 1)
	return Color3.new(v10, v10, v10)
end

local function rounded(parent2, udim) -- 8 equivalent calls inferred from this helper
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = udim or UDim.new(0.5, 0)
	uiCorner.Parent = parent2
	return parent2
end

local function fadeSeq(items)
	local numberSequenceKeypoints = {}

	for k, item in items do
		table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(item[1], item[2]))
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

local function squaresOf(data)
	local dark = data.theme.dark
	local result = {}

	for k, square in data.squares do
		local backgroundColor3 = square.BackgroundColor3
		table.insert(result, {
			sq = square,
			i = k,
			dark = math.abs(backgroundColor3.R - dark.R) + math.abs(backgroundColor3.G - dark.G) + math.abs(backgroundColor3.B - dark.B) < 0.02
		})
	end

	return result
end

local function spot(sq) -- 1 equivalent call inferred from this helper
	return sq.Position.X.Scale + sq.Size.X.Scale / 2, sq.Position.Y.Scale + sq.Size.Y.Scale / 2
end

local function sqFrame(parent2, p, p2, p3, p4, backgroundColor, value, value2)
	local style = Instance.new("Frame")
	style.Name = "Style"
	style.BorderSizePixel = 0
	style.AnchorPoint = Vector2.new(0.5, 0.5)
	style.Position = UDim2.fromScale(p, p2)
	style.Size = UDim2.fromScale(p3, p4)
	style.BackgroundColor3 = backgroundColor
	style.BackgroundTransparency = value or 0
	style.Rotation = value2 or 0
	style.Parent = parent2
	return style
end

local function boardFx(p) -- 3 equivalent calls inferred from this helper
	local styleFx = Instance.new("Frame")
	styleFx.Name = "StyleFx"
	styleFx.BorderSizePixel = 0
	styleFx.AnchorPoint = Vector2.new(0.5, 0.5)
	styleFx.ZIndex = 2
	styleFx.Parent = p.squareLayer
	return styleFx
end

local function tidy(items)
	local v10 = -1
	local result = {}

	for k, item in items do
		local v11 = math.clamp(item[1], 0, 1)

		if not (v10 + 0.002 < v11 and #result < 19) then
			continue
		end

		table.insert(result, { v11, item[2] })
		v10 = v11
	end

	result[1][1] = 0

	if result[#result][1] < 1 then
		table.insert(result, { 1, result[#result][2] })
	end

	return result
end

local function joints(p, backgroundColor, backgroundTransparency)
	local v10 = #p.squares > 16 and 8 or 4

	for i = 1, v10 - 1 do
		for k, v11 in { true, false } do
			local styleFx = boardFx(p) -- inferred equivalent call
			styleFx.BackgroundColor3 = backgroundColor
			styleFx.BackgroundTransparency = backgroundTransparency

			if v11 then
				styleFx.Position = UDim2.fromScale(0.5, i / v10)
				styleFx.Size = UDim2.new(1, 0, 0, 1)
			else
				styleFx.Position = UDim2.fromScale(i / v10, 0.5)
				styleFx.Size = UDim2.new(0, 1, 1, 0)
			end
		end
	end
end

local function sheen(p, p2)
	local parent2 = boardFx(p) -- inferred equivalent call
	parent2.Position = UDim2.fromScale(0.5, 0.5)
	parent2.Size = UDim2.fromScale(1, 1)
	parent2.BackgroundColor3 = color
	local uiGradient = Instance.new("UIGradient")
	uiGradient.Rotation = 35
	uiGradient.Transparency = fadeSeq({
		{ 0, 1 },
		{ 0.3, 1 },
		{ 0.42, p2 },
		{ 0.5, 1 },
		{ 0.6, 1 },
		{ 0.66, p2 + (1 - p2) * 0.4 },
		{ 0.72, 1 },
		{ 1, 1 }
	})

	uiGradient.Parent = parent2
end

local function bevel(sq, p) -- 2 equivalent calls inferred from this helper
	sqFrame(sq, 0.5, 0.02, 1, 0.04, color, 0.7)
	sqFrame(sq, 0.5, 0.98, 1, 0.04, color2, p)
end

local function spline(list, p)
	local count = #list
	local result = {}

	for i = 1, count - 1 do
		local item = list[math.max(1, i - 1)]
		local item2 = list[i]
		local item3 = list[i + 1]
		local item4 = list[math.min(count, i + 2)]

		for j = 0, p - 1 do
			local v10 = j / p
			local v11 = v10 * v10
			local v12 = v10 * v10 * v10
			table.insert(
				result,
				0.5 * (2 * item2 + (item3 - item) * v10 + (2 * item - 5 * item2 + 4 * item3 - item4) * v11 + (3 * item2 - item - 3 * item3 + item4) * v12)
			)
		end
	end

	table.insert(result, list[count])
	return result
end

local function woodSquare(item, p)
	local sq = item.sq
	local random2 = Random.new(item.i * 7919 + 101)
	local dark = item.dark

	local dark2 = dark and p.dark or p.light
	local lerped = dark2:Lerp(
		dark and Color3.new(dark2.R * 0.84, dark2.G * 0.77, dark2.B * 0.7) or Color3.new(dark2.R * 0.94, dark2.G * 0.88, dark2.B * 0.8),
		random2:NextNumber() * 0.6
	)
	local v10 = 0.95 + random2:NextNumber() * 0.05

	local pos = random2:NextNumber() * 0.12
	local v11 = {}

	while pos < 1 and #v11 < 6 do
		local v12 = random2:NextNumber() < 0.3
		table.insert(v11, {
			pos = pos,
			d = v12 and (dark and 0.1 or 0.07) or (dark and 0.16 or 0.1) + random2:NextNumber() * (dark and 0.12 or 0.08),
			hw = v12 and 0.03 + random2:NextNumber() * 0.025 or 0.008 + random2:NextNumber() * 0.01,
			band = 0.95 + random2:NextNumber() * 0.07,
			amp = 0.008 + random2:NextNumber() * 0.018,
			ph = random2:NextNumber() * 6.28
		})

		pos += 0.1 + random2:NextNumber() * 0.12
	end

	local v12 = 0.5 + random2:NextNumber()
	local v13 = random2:NextNumber() * 6.28

	for i = 0, 7 do
		local v14 = (i + 0.5) / 8
		local v15 = v10 * (math.sin(v14 * 7 + v13) * 0.03 + 1)
		local v16 = 0.98
		local v17 = {
			{ 0, grey(v15 * v16) }
		}

		for k, v18 in v11 do
			local v19 = v18.pos + v18.amp * math.sin(v14 * 6.28 * v12 + v18.ph)
			table.insert(v17, { v19 - v18.hw, grey(v15 * v16) })
			table.insert(v17, { v19, grey(v15 * v16 * (1 - v18.d)) })
			v16 = v18.band
			table.insert(v17, { v19 + v18.hw, grey(v15 * v16) })
		end

		table.insert(v17, { 1, grey(v15 * v16) })
		local style = Instance.new("Frame")
		style.Name = "Style"
		style.BorderSizePixel = 0
		style.BackgroundColor3 = lerped

		local v18 = i < 7 and 1 or 0

		if dark then
			style.Size = UDim2.new(1, 0, 0.125, v18)
			style.Position = UDim2.fromScale(0, i / 8)
			gradient(style, tidy(v17), 0)
		else
			style.Size = UDim2.new(0.125, v18, 1, 0)
			style.Position = UDim2.fromScale(i / 8, 0)
			gradient(style, tidy(v17), 90)
		end

		style.Parent = sq
	end

	bevel(sq, 0.82) -- inferred equivalent call
end

local function woodStyle(data, items, theme)
	for k, item in items do
		woodSquare(item, theme)
	end

	joints(data, rgb(70, 40, 20), 0.6) -- inferred equivalent call
	sheen(data, 0.86)
end

local function marbleSquare(item, data)
	local sq = item.sq
	local random2 = Random.new(item.i * 7919 + 202)
	local dark = item.dark and data.dark or data.light
	sq.ClipsDescendants = true

	local v10 = {}

	for i = 0, 5 do
		table.insert(v10, { i / 5, grey(0.93 + random2:NextNumber() * 0.07) })
	end

	gradient(sq, v10, random2:NextInteger(0, 179))
	local v11 = sqFrame(sq, random2:NextNumber(), random2:NextNumber(), 0.9, 0.6, color, 1, random2:NextInteger(0, 179))
	local v12 = random2:NextNumber() < 0.5 and dark:Lerp(color2, 0.14) or tint(dark, 0.18) -- inferred equivalent call

	rounded(sqFrame(v11, 0.5, 0.5, 1, 1, v12, 0.9299999999999999), nil) -- inferred equivalent call
	rounded(sqFrame(v11, 0.5, 0.5, 0.72, 0.72, v12, 0.86), nil) -- inferred equivalent call
	rounded(sqFrame(v11, 0.5, 0.5, 0.43999999999999995, 0.43999999999999995, v12, 0.79), nil) -- inferred equivalent call

	local veinDark = item.dark and (data.veinDark or rgb(226, 242, 234)) or data.veinLight or rgb(120, 122, 132) -- inferred equivalent call

	local function draw(list, p, p2)
		local lerped = dark:Lerp(veinDark, p2)

		for i = 1, #list - 1 do
			local item2 = list[i]
			local item3 = list[i + 1]
			local v13 = p * (math.sin(3.141592653589793 * (i - 0.5) / (#list - 1)) * 0.7 + 0.3)
			local v14 = item3 - item2
			local midpoint = (item2 + item3) / 2
			sqFrame(
				sq,
				midpoint.X,
				midpoint.Y,
				v14.Magnitude + v13 * 0.6,
				v13,
				lerped,
				0,
				math.deg((math.atan2(v14.Y, v14.X)))
			)
		end
	end

	local function vein(p, p2, p3, p4)
		local vector2 = Vector2.new(math.cos(p3), (math.sin(p3)))
		local vector2_2 = Vector2.new(-vector2.Y, vector2.X)
		local vector2_3 = Vector2.new(p, p2)
		local v13 = {}

		for i = -2, 2 do
			table.insert(v13, vector2_3 + vector2 * (i * 0.42) + vector2_2 * ((random2:NextNumber() - 0.5) * p4))
		end

		return spline(v13, 2)
	end

	local v13 = 0.5934119456780721 + (random2:NextNumber() - 0.5) * 0.7
	local v14 = vein(0.2 + random2:NextNumber() * 0.6, 0.2 + random2:NextNumber() * 0.6, v13, 0.22)
	draw(v14, 0.11, item.dark and 0.16 or 0.12)
	draw(v14, 0.035, item.dark and 0.55 or 0.45)

	local v15 = v14[random2:NextInteger(3, 6)]
	local v16 = v13 + (random2:NextNumber() < 0.5 and -1 or 1) * (0.35 + random2:NextNumber() * 0.35)
	local vector2 = Vector2.new(math.cos(v16), (math.sin(v16)))
	local vector2_2 = Vector2.new(-vector2.Y, vector2.X)
	draw(
		spline(
			{
				v15,
				v15 + vector2 * 0.2 + vector2_2 * (random2:NextNumber() - 0.5) * 0.08,
				v15 + vector2 * 0.42 + vector2_2 * (random2:NextNumber() - 0.5) * 0.12
			},
			2
		),
		0.022,
		item.dark and 0.4 or 0.32
	)

	if random2:NextNumber() < 0.55 then
		draw(
			vein(random2:NextNumber(), random2:NextNumber(), v13 + (random2:NextNumber() - 0.5) * 0.4, 0.3),
			0.02,
			item.dark and 0.32 or 0.24
		)
	end

	bevel(sq, 0.85) -- inferred equivalent call
end

local function marbleStyle(data, items, theme)
	for k, item in items do
		marbleSquare(item, theme)
	end

	joints(data, theme.joint or rgb(40, 50, 48), 0.72) -- inferred equivalent call
	sheen(data, 0.86)
end

local function wavesStyle(data, items, theme)
	local v10 = {}

	for k, item in items do
		if item.dark then
			gradient(item.sq, {
				{ 0, color },
				{ 1, grey(0.84) }
			}, 90)
			item.sq.ClipsDescendants = true
			local parent2 = sqFrame(item.sq, -0.5, 0.5, 0.42, 1.8, rgb(225, 255, 250), 0, 24) -- inferred equivalent call
			local uiGradient = Instance.new("UIGradient")
			uiGradient.Transparency = fadeSeq({
				{ 0, 1 },
				{ 0.5, 0.5 },
				{ 1, 1 }
			})
			uiGradient.Parent = parent2
			table.insert(v10, { f = parent2, sq = item.sq })
		else
			gradient(item.sq, {
				{ 0, color },
				{ 1, grey(0.88) }
			}, 45)
		end
	end

	animate(data.squareLayer, function(p) -- inferred equivalent call
		if data.theme == theme then
			for k, v11 in v10 do
				local v12, v13 = spot(v11.sq) -- inferred equivalent call
				local v14 = (p * 0.32 - v12 * 0.9 - v13 * 0.45) % 1
				v11.f.Position = UDim2.fromScale(-0.45 + v14 * 2.6, 0.5)
			end
		else
			unanimate(data.squareLayer) -- inferred equivalent call
		end
	end)
end

local function starryStyle(data, items, theme)
	local v10 = {}

	for k, item in items do
		local random2 = Random.new(item.i * 7919 + 303)

		if item.dark then
			gradient(item.sq, {
				{ 0, color },
				{ 1, grey(0.84) }
			}, 90)
			item.sq.ClipsDescendants = true

			for i = 1, random2:NextInteger(2, 4) do
				local v11 = 0.035 + random2:NextNumber() * 0.035
				local v12 = random2:NextNumber() < 0.3 and rgb(196, 214, 255) or color -- inferred equivalent call
				local parent2 = rounded( -- inferred equivalent call
					sqFrame(
						item.sq,
						0.1 + random2:NextNumber() * 0.8,
						0.1 + random2:NextNumber() * 0.8,
						v11,
						v11,
						v12,
						0.3
					),
					nil
				)
				table.insert(v10, {
					f = parent2,
					ph = random2:NextNumber() * 6,
					sp = 0.7 + random2:NextNumber() * 1.8,
					base = 0.1 + random2:NextNumber() * 0.35
				})
			end

			if random2:NextNumber() < 0.3 then
				local parent2 = sqFrame(
					item.sq,
					0.2 + random2:NextNumber() * 0.6,
					0.2 + random2:NextNumber() * 0.6,
					0.36,
					0.36,
					color,
					1
				)

				for k2, v11 in { 0, 90 } do
					local parent3 = sqFrame(parent2, 0.5, 0.5, 1, 0.07, rgb(230, 236, 255), 0, v11) -- inferred equivalent call
					local uiGradient = Instance.new("UIGradient")
					uiGradient.Transparency = fadeSeq({
						{ 0, 1 },
						{ 0.5, 0 },
						{ 1, 1 }
					})
					uiGradient.Parent = parent3
				end

				rounded(sqFrame(parent2, 0.5, 0.5, 0.2, 0.2, color, 0), nil) -- inferred equivalent call
				table.insert(v10, {
					f = parent2,
					ph = random2:NextNumber() * 6,
					sp = 0.6 + random2:NextNumber() * 0.6,
					sparkle = true
				})
			end
		else
			gradient(item.sq, {
				{ 0, color },
				{ 1, grey(0.9) }
			}, 90)
		end
	end

	local parent2 = rounded(boardFx(data), UDim.new(1, 0)) -- inferred equivalent call
	parent2.BackgroundColor3 = color
	parent2.Visible = false
	local uiGradient = Instance.new("UIGradient")
	uiGradient.Transparency = fadeSeq({
		{ 0, 1 },
		{ 0.75, 0.4 },
		{ 1, 0 }
	})
	uiGradient.Parent = parent2

	animate(data.squareLayer, function(p) -- inferred equivalent call
		if data.theme == theme then
			for k, v11 in v10 do
				local v12 = math.sin(p * v11.sp + v11.ph) * 0.5 + 0.5

				if v11.sparkle then
					local v13 = v12 * 0.5 + 0.5
					v11.f.Size = UDim2.fromScale(v13 * 0.36, v13 * 0.36)
					v11.f.Rotation = p * 12 % 90
				else
					v11.f.BackgroundTransparency = v11.base + (0.92 - v11.base) * v12
				end
			end

			local v11 = p / 7
			local v12 = math.floor(v11)
			local v13 = (v11 - v12) * 7

			if v13 > 0.8 then
				parent2.Visible = false
				return
			end

			local random2 = Random.new(v12 * 31 + 11)
			local v14 = 0.15 + random2:NextNumber() * 0.5
			local v15 = random2:NextNumber() * 0.35
			local v16 = 0.35 + random2:NextNumber() * 0.15
			local v17 = 0.2 + random2:NextNumber() * 0.12
			local v18 = v13 / 0.8
			parent2.Visible = true
			parent2.Position = UDim2.fromScale(v14 + v16 * v18, v15 + v17 * v18)
			parent2.Rotation = math.deg((math.atan2(v17, v16)))
			parent2.Size = UDim2.new(math.sin(math.min(1, v18 * 1.6) * 3.141592653589793 * 0.5) * 0.22, 0, 0, 2)
			parent2.BackgroundTransparency = v18 < 0.7 and 0 or (v18 - 0.7) / 0.3
		else
			unanimate(data.squareLayer) -- inferred equivalent call
		end
	end)
end

local function hauntedStyle(data, items, theme)
	local v10 = {}

	for k, item in items do
		local random2 = Random.new(item.i * 4271 + 77)

		if item.dark then
			gradient(item.sq, {
				{ 0, color },
				{ 1, grey(0.78) }
			}, 90)
			item.sq.ClipsDescendants = true

			if random2:NextNumber() < 0.3 then
				local v11 = 0.25 + random2:NextNumber() * 0.5
				local v12 = 0.3 + random2:NextNumber() * 0.4
				local halo = rounded(sqFrame(item.sq, v11, v12, 0.34, 0.34, rgb(255, 140, 40), 0.85), UDim.new(1, 0)) -- inferred equivalent call
				local core = rounded(sqFrame(item.sq, v11, v12, 0.11, 0.11, rgb(255, 196, 90), 0.3), UDim.new(1, 0)) -- inferred equivalent call
				table.insert(v10, {
					core = core,
					halo = halo,
					x = v11,
					y = v12,
					ph = random2:NextNumber() * 6,
					sp = 0.8 + random2:NextNumber()
				})
			end
		else
			gradient(item.sq, {
				{ 0, color },
				{ 1, grey(0.9) }
			}, 90)
		end
	end

	local styleFx = makeBat(rgb(26, 16, 34))
	styleFx.Name = "StyleFx"
	styleFx.AnchorPoint = Vector2.new(0.5, 0.5)
	styleFx.ZIndex = 2
	styleFx.Visible = false
	styleFx.Parent = data.squareLayer

	animate(data.squareLayer, function(p) -- inferred equivalent call
		if data.theme == theme then
			for k, v11 in v10 do
				local v12 = math.sin(p * v11.sp + v11.ph) * 0.5 + 0.5
				local udim = UDim2.fromScale(
					v11.x + math.sin(p * 0.9 + v11.ph) * 0.07,
					v11.y + math.sin(p * 0.7 + v11.ph * 2) * 0.09
				)
				v11.core.Position = udim
				v11.halo.Position = udim
				v11.core.BackgroundTransparency = (1 - v12) * 0.4 + 0.05
				v11.halo.BackgroundTransparency = (1 - v12) * 0.2 + 0.68
			end

			local v11 = p / 6
			local v12 = math.floor(v11)
			local v13 = (v11 - v12) * 6

			if v13 > 2.4 then
				styleFx.Visible = false
				return
			end

			local random2 = Random.new(v12 * 53 + 9)
			local v14 = random2:NextNumber() < 0.5 and -1 or 1
			local v15 = 0.15 + random2:NextNumber() * 0.6
			local v16 = v13 / 2.4
			styleFx.Visible = true
			styleFx.Size = UDim2.fromScale(0.13, 0.13)
			styleFx.Position = UDim2.fromScale(
				v14 > 0 and -0.1 + 1.2 * v16 or 1.1 - 1.2 * v16,
				v15 + math.sin(v16 * 10) * 0.06 - 0.08 * v16
			)
			flapBat(styleFx, p * 22) -- inferred equivalent call
		else
			unanimate(data.squareLayer) -- inferred equivalent call
		end
	end)
end

function Cosmetics2.styleBoard(data)
	local theme = data.theme
	local style = theme.style

	for k, square in data.squares do
		for i, child in square:GetChildren() do
			if child.Name == "Style" then
				child:Destroy()
			end
		end

		square.ClipsDescendants = false
	end

	for i, child in data.squareLayer:GetChildren() do
		if child.Name == "Shine" or child.Name == "StyleFx" then
			child:Destroy()
		end
	end

	unanimate(data.squareLayer) -- inferred equivalent call
	local v10 = squaresOf(data)

	if style == "gradient" then
		for k, square in data.squares do
			gradient(square, {
				{ 0, color },
				{ 1, rgb(206, 206, 206) }
			}, 45)
		end
	elseif style == "gloss" or style == "shimmer" then
		for k, square in data.squares do
			gradient(square, {
				{ 0, color },
				{ 0.46, rgb(244, 244, 244) },
				{ 0.54, rgb(218, 218, 218) },
				{ 1, rgb(212, 212, 212) }
			}, 90)
		end
	elseif style == "wood" then
		woodStyle(data, v10, theme)
	elseif style == "marble" or style == "royal" then
		marbleStyle(data, v10, theme)
	elseif style == "waves" then
		wavesStyle(data, v10, theme)
	elseif style == "starry" then
		starryStyle(data, v10, theme)
	elseif style == "haunted" then
		hauntedStyle(data, v10, theme)
	end

	if style == "shimmer" or style == "royal" then
		local shine2 = Instance.new("Frame")
		shine2.Name = "Shine"
		shine2.BorderSizePixel = 0
		shine2.Size = UDim2.fromScale(1, 1)
		shine2.BackgroundColor3 = style == "royal" and rgb(255, 222, 130) or rgb(255, 250, 225) -- inferred equivalent call
		shine2.ZIndex = 2
		local uiGradient = Instance.new("UIGradient")
		uiGradient.Rotation = 30
		uiGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.4, 1),
			NumberSequenceKeypoint.new(0.5, 0.55),
			NumberSequenceKeypoint.new(0.6, 1),
			NumberSequenceKeypoint.new(1, 1)
		})

		uiGradient.Parent = shine2
		shine2.Parent = data.squareLayer
		animate(shine2, function(p) -- inferred equivalent call
			local v11 = p % 4.5 / 4.5
			uiGradient.Offset = Vector2.new(math.min(1, v11 * 1.8) * 2.4 + -1.2, 0)
		end)
	elseif style == "prism" then
		local v11 = {}

		for k, square in data.squares do
			local v12 = (k - 1) % 8
			local v13 = (k - 1) // 8

			if (v12 + v13) % 2 == 0 then
				table.insert(v11, {
					sq = square,
					k = (v12 + v13) / 14
				})
			end
		end

		animate(data.squareLayer, function(p) -- inferred equivalent call
			if data.theme == theme then
				for k, v12 in v11 do
					v12.sq.BackgroundColor3 = Color3.fromHSV((p * 0.02 + v12.k * 0.5) % 1, 0.42, 0.86)
				end
			else
				unanimate(data.squareLayer) -- inferred equivalent call
			end
		end)
	end

	local hint = theme.hint or color2
	local v11 = theme.hint and 0.7 or 0.86

	for k, hint2 in data.hints do
		hint2.dot.BackgroundColor3 = hint
		hint2.dot.BackgroundTransparency = v11
		hint2.stroke.Color = hint
		hint2.stroke.Transparency = v11
	end
end

function Cosmetics2.boardSwatch(theme, parent2)
	local board = Instance.new("Frame")
	board.Name = "Board"
	board:SetAttribute("NoTint", true)
	board.BackgroundTransparency = 1
	board.Size = UDim2.fromScale(1, 1)
	local squares = {}

	for i = 1, 16 do
		local v10 = (i - 1) % 4
		local v11 = (i - 1) // 4
		local frame2 = Instance.new("Frame")
		frame2.BorderSizePixel = 0
		frame2.Size = UDim2.fromScale(0.25, 0.25)
		frame2.Position = UDim2.fromScale(v10 * 0.25, v11 * 0.25)
		frame2.BackgroundColor3 = (v10 + v11) % 2 == 0 and theme.light or theme.dark
		frame2.Parent = board
		squares[i] = frame2
	end

	board.Parent = parent2

	if theme.style == "prism" then
		animate(board, function(p) -- inferred equivalent call
			for k, v10 in squares do
				local v11 = (k - 1) % 4
				local v12 = (k - 1) // 4

				if (v11 + v12) % 2 == 1 then
					v10.BackgroundColor3 = Color3.fromHSV((p * 0.02 + (v11 + v12) / 12) % 1, 0.42, 0.86)
				end
			end
		end)
	elseif theme.style then
		Cosmetics2.styleBoard({ theme = theme, squares = squares, squareLayer = board, hints = {} })
	end

	return board
end

local function stars(parent2, p, p2)
	for i = 1, p do
		local star = Instance.new("Frame")
		star.Name = "Star"
		star.BorderSizePixel = 0
		star.AnchorPoint = Vector2.new(0.5, 0.5)
		star.Position = UDim2.fromScale(random:NextNumber(), random:NextNumber())
		local v10 = p2 * (random:NextNumber() < 0.15 and 2 or 1)
		star.Size = UDim2.fromOffset(v10, v10)
		star.BackgroundColor3 = random:NextNumber() < 0.2 and rgb(200, 220, 255) or color -- inferred equivalent call
		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(1, 0)
		uiCorner.Parent = star
		star.Parent = parent2
		local v11 = random:NextNumber() * 6
		local v12 = 0.6 + random:NextNumber() * 1.6
		local v13 = 0.25 + random:NextNumber() * 0.4
		animate(star, function(p3) -- inferred equivalent call
			star.BackgroundTransparency = v13 + (1 - v13) * 0.5 * (math.sin(p3 * v12 + v11) + 1)
		end)
	end
end

local function blob(bgStyle, backgroundColor, p, p2)
	local blob2 = Instance.new("Frame")
	blob2.Name = "Blob"
	blob2.BorderSizePixel = 0
	blob2.AnchorPoint = Vector2.new(0.5, 0.5)
	blob2.Size = UDim2.fromScale(p, p)
	blob2.SizeConstraint = Enum.SizeConstraint.RelativeXX
	blob2.BackgroundColor3 = backgroundColor
	blob2.BackgroundTransparency = 0
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0.5, 0)
	uiCorner.Parent = blob2
	local uiGradient = Instance.new("UIGradient")
	uiGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.5, p2),
		NumberSequenceKeypoint.new(1, 1)
	})

	uiGradient.Parent = blob2
	blob2.Parent = bgStyle
	return blob2, uiGradient
end

local function seqT(items)
	local numberSequenceKeypoints = {}

	for k, item in items do
		table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(item[1], item[2]))
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

local function fill(parent2, backgroundColor, value, value2)
	local frame2 = Instance.new("Frame")
	frame2.Name = value or "Fill"
	frame2.BorderSizePixel = 0
	frame2.Size = UDim2.fromScale(1, 1)
	frame2.BackgroundColor3 = backgroundColor
	frame2.ZIndex = value2 or 1
	frame2.Parent = parent2
	return frame2
end

local function roundify(parent2) -- 18 equivalent calls inferred from this helper
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0.5, 0)
	uiCorner.Parent = parent2
end

local v10 = nil
local function getDotTile()
	if v10 ~= nil then
		return v10 or nil
	end

	local success, result = pcall(function()
		local buf = buffer.create(4096)

		for i = 0, 31 do
			for j = 0, 31 do
				local v11 = math.floor(math.clamp(2.2 - math.sqrt((j - 15.5) ^ 2 + (i - 15.5) ^ 2), 0, 1) * 255)
				buffer.writeu32(buf, (i * 32 + j) * 4, v11 * 16777216 + 16777215)
			end
		end

		local AssetService = game:GetService("AssetService")
		local editableImage = AssetService:CreateEditableImage({ Size = Vector2.new(32, 32) })
		editableImage:WritePixelsBuffer(Vector2.zero, Vector2.new(32, 32), buf)
		return {
			content = Content.fromObject(editableImage),
			img = editableImage
		}
	end)

	v10 = success and result or false

	if not success then
		warn("[Chess] background dots unavailable: " .. tostring(result))
	end

	return v10 or nil
end

local function dots(bgStyle, p, value)
	local dotTile = getDotTile()

	if not dotTile then
		return
	end

	local v11 = p and 12 or 26
	local dots2 = Instance.new("ImageLabel")
	dots2.Name = "Dots"
	dots2.BackgroundTransparency = 1
	dots2.Size = UDim2.fromScale(1, 1)
	dots2.ImageContent = dotTile.content
	dots2.ScaleType = Enum.ScaleType.Tile
	dots2.TileSize = UDim2.fromOffset(v11, v11)
	dots2.ImageTransparency = 1 - (value or 0.09)
	dots2.ZIndex = 3
	dots2.Parent = bgStyle
end

local function vignette(parent2, p)
	for k, rotation in { 0, 90 } do
		local vignette2 = Instance.new("Frame")
		vignette2.Name = "Vignette"
		vignette2.BorderSizePixel = 0
		vignette2.Size = UDim2.fromScale(1, 1)
		vignette2.BackgroundColor3 = color2
		vignette2.ZIndex = 4
		vignette2.Parent = parent2

		local uiGradient = Instance.new("UIGradient")
		uiGradient.Rotation = rotation
		uiGradient.Transparency = seqT({
			{ 0, 1 - p },
			{ 0.25, 1 },
			{ 0.75, 1 },
			{ 1, 1 - p }
		})
		uiGradient.Parent = vignette2
	end
end

local function softDot(parent2, backgroundColor, p, p2, value)
	local soft = Instance.new("Frame")
	soft.Name = "Soft"
	soft.BackgroundTransparency = 1
	soft.AnchorPoint = Vector2.new(0.5, 0.5)
	soft.Size = UDim2.fromScale(p, p)
	soft.SizeConstraint = Enum.SizeConstraint.RelativeXX
	soft.ZIndex = value or 2

	local v11 = p < 0.05 and 3 or p < 0.2 and 14 or 28

	for i = 1, v11 do
		local v12 = 1 - (i - 1) / v11 * 0.92

		local v13 = v11 == 3 and p2 * 0.4 or p2 * 0.55 * (i / v11) ^ 2 * (10 / v11)
		local frame2 = Instance.new("Frame")
		frame2.BorderSizePixel = 0
		frame2.AnchorPoint = Vector2.new(0.5, 0.5)
		frame2.Position = UDim2.fromScale(0.5, 0.5)
		frame2.Size = UDim2.fromScale(v12, v12)
		frame2.BackgroundColor3 = backgroundColor
		frame2:SetAttribute("Op", v13)
		frame2.BackgroundTransparency = 1 - v13
		roundify(frame2) -- inferred equivalent call
		frame2.Parent = soft
	end

	soft.Parent = parent2
	return soft
end

local function setOp(instance, value)
	for i, child in instance:GetChildren() do
		child.BackgroundTransparency = 1 - child:GetAttribute("Op") * math.clamp(value, 0, 1)
	end
end

local function drifters(parent2, p, data)
	for i = 1, p do
		local v11 = softDot(
			parent2,
			data.colors[random:NextInteger(1, #data.colors)],
			data.size[1] + random:NextNumber() * (data.size[2] - data.size[1]),
			data.op,
			data.z or 2
		)
		local number = random:NextNumber()
		local v12 = random:NextNumber() * 1.2
		local v13 = 0.6 + random:NextNumber() * 0.8
		local v14 = random:NextNumber() * 20
		animate(v11, function(p2) -- inferred equivalent call
			local v15 = (v12 + p2 * (data.vy or 0) * v13) % 1.2 - 0.1
			local v16 = (number + (data.sway or 0) * math.sin(p2 * 0.35 * v13 + v14) + (data.vx or 0) * p2 * v13 + 0.1) % 1.2 - 0.1
			v11.Position = UDim2.fromScale(v16, v15)
			setOp(v11, data.twinkle and math.sin(p2 * data.twinkle * v13 + v14) * 0.5 + 0.5 or 1)
		end)
	end
end

local function starLayer(parent2, p, p2, p3, p4, p5)
	for i = 1, p do
		local star = Instance.new("Frame")
		star.Name = "Star"
		star.BorderSizePixel = 0
		star.AnchorPoint = Vector2.new(0.5, 0.5)
		local v11 = p2 * (random:NextNumber() < 0.12 and 2 or 1)
		star.Size = UDim2.fromOffset(v11, v11)
		star.BackgroundColor3 = random:NextNumber() < 0.25 and rgb(190, 215, 255) -- inferred equivalent call
			or random:NextNumber() < 0.1 and rgb(255, 225, 190) -- inferred equivalent call
			or color
		star.ZIndex = 2
		roundify(star) -- inferred equivalent call
		star.Parent = parent2
		local number = random:NextNumber()
		local number2 = random:NextNumber()
		local v12 = random:NextNumber() * 6
		local v13 = 0.5 + random:NextNumber() * 1.8
		local v14 = p4 + random:NextNumber() * (p5 - p4)
		animate(star, function(p6) -- inferred equivalent call
			star.Position = UDim2.fromScale((number + p6 * p3) % 1, number2)
			star.BackgroundTransparency = 1 - v14 * (math.sin(p6 * v13 + v12) * 0.45 + 0.55)
		end)
	end
end

local function shootingStars(bgStyle, p, value)
	local meteor = Instance.new("Frame")
	meteor.Name = "Meteor"
	meteor.BorderSizePixel = 0
	meteor.AnchorPoint = Vector2.new(1, 0.5)
	meteor.BackgroundColor3 = color
	meteor.ZIndex = 3
	meteor.Visible = false
	roundify(meteor) -- inferred equivalent call
	local uiGradient = Instance.new("UIGradient")
	uiGradient.Transparency = seqT({
		{ 0, 1 },
		{ 0.8, 0.3 },
		{ 1, 0 }
	})
	uiGradient.Parent = meteor
	meteor.Parent = bgStyle

	animate(meteor, function(p2) -- inferred equivalent call
		local v11 = p2 / p + (value or 0)
		local v12 = math.floor(v11)
		local v13 = (v11 - v12) * p

		if v13 > 0.9 then
			meteor.Visible = false
			return
		end

		local random2 = Random.new(v12 * 31 + 7)
		local absoluteSize = bgStyle.AbsoluteSize
		local v14 = 0.1 + random2:NextNumber() * 0.6
		local v15 = random2:NextNumber() * 0.4
		local v16 = 0.3 + random2:NextNumber() * 0.15
		local v17 = 0.12 + random2:NextNumber() * 0.12
		local v18 = v13 / 0.9
		meteor.Visible = true
		meteor.Position = UDim2.fromScale(v14 + v16 * v18, v15 + v17 * v18)
		local rotation = math.deg((math.atan2(v17 * absoluteSize.Y, v16 * absoluteSize.X)))
		meteor.Rotation = rotation
		local v19 = math.min(absoluteSize.X * 0.14, 180) * math.sin(math.min(1, v18 * 1.6) * 3.141592653589793 * 0.5)
		meteor.Size = UDim2.fromOffset(v19, 2)
		meteor.Position = UDim2.new(
			v14 + v16 * v18,
			v19 / 2 * (math.cos((math.rad(rotation))) - 1) * 0,
			v15 + v17 * v18,
			0
		)
		meteor.AnchorPoint = Vector2.new(0.5, 0.5)
		meteor.BackgroundTransparency = v18 < 0.7 and 0 or (v18 - 0.7) / 0.3
	end)
end

local function sweep(bgStyle, backgroundColor, p, p2)
	local sweep2 = Instance.new("Frame")
	sweep2.Name = "Sweep"
	sweep2.BorderSizePixel = 0
	sweep2.Size = UDim2.fromScale(1, 1)
	sweep2.BackgroundColor3 = backgroundColor
	sweep2.ZIndex = 3
	sweep2.Parent = bgStyle

	sweep2.AnchorPoint = Vector2.new(0.5, 0.5)
	sweep2.Size = UDim2.fromScale(0.35, 3)
	sweep2.Rotation = 25
	local uiGradient = Instance.new("UIGradient")
	uiGradient.Transparency = seqT({
		{ 0, 1 },
		{ 0.5, 1 - p2 },
		{ 1, 1 }
	})
	uiGradient.Parent = sweep2
	animate(sweep2, function(p3) -- inferred equivalent call
		local v11 = p3 % p / p
		sweep2.Position = UDim2.fromScale(-0.4 + v11 * 2.2, 0.5)
	end)
end

local function curtain(bgStyle, p, p2, p3, p4, p5, p6, p7, p8)
	local v11 = {}

	for i = 1, p do
		local curtain2 = Instance.new("Frame")
		curtain2.Name = "Curtain"
		curtain2.BorderSizePixel = 0
		curtain2.AnchorPoint = Vector2.new(0.5, 1)
		curtain2.BackgroundColor3 = color
		curtain2.ZIndex = 2
		local uiGradient = Instance.new("UIGradient")
		uiGradient.Rotation = 90
		uiGradient.Color = ColorSequence.new(p2, p3)
		uiGradient.Transparency = seqT({
			{ 0, 1 },
			{ 0.45, 0.55 },
			{ 0.88, 0.15 },
			{ 1, 1 }
		})
		uiGradient.Parent = curtain2
		curtain2.Parent = bgStyle
		v11[i] = curtain2
	end

	animate(v11[1], function(p9) -- inferred equivalent call
		local v12 = p9 * p6 + p7

		for k, v13 in v11 do
			local v14 = (k - 0.5) / p
			local v15 = math.sin(v14 * 4 + v12 * 0.5) + math.sin(v14 * 9 - v12 * 0.8) * 0.4
			local v16 = p5 * (math.sin(v14 * 5 + v12 * 0.6) * 0.25 + 0.75)
			v13.Position = UDim2.new(v14, 0, p4 + v15 * 0.05, 0)
			v13.Size = UDim2.new(1 / p, 1, v16, 0)
			local v17 = math.sin(v14 * 3.5 - v12 * 0.7) * 0.5 + 0.5

			local v18 = math.clamp(math.min(v14, 1 - v14) * 6, 0, 1)
			v13.BackgroundTransparency = 1 - p8 * (v17 * 0.7 + 0.3) * (v18 * 0.6 + 0.4)
		end
	end)
end

local function spiral(bgStyle, p, p2, p3)
	local v11 = {}
	local v12 = {}

	for i = 1, p2 do
		local v13 = (i - 1) / p2 * 3.141592653589793 * 2

		for j = 1, p do
			local arm = Instance.new("Frame")
			arm.Name = "Arm"
			arm.BorderSizePixel = 0
			arm.AnchorPoint = Vector2.new(0.5, 0.5)
			local v14 = p3 and 1 or random:NextNumber() < 0.12 and 3 or 2
			arm.Size = UDim2.fromOffset(v14, v14)
			local v15 = (j / p) ^ 0.75
			arm.BackgroundColor3 = color:Lerp(
				random:NextNumber() < 0.5 and rgb(255, 150, 230) or rgb(140, 180, 255), -- inferred equivalent call
				v15 * 0.7
			)
			arm.ZIndex = 3
			roundify(arm) -- inferred equivalent call
			arm.Parent = bgStyle
			table.insert(v11, {
				f = arm,
				r = v15 + (random:NextNumber() - 0.5) * 0.06,
				a = v13 + v15 * 5 + (random:NextNumber() - 0.5) * (0.2 + 0.35 * v15),
				op = 0.45 + 0.5 * random:NextNumber(),
				ph = random:NextNumber() * 6
			})
		end

		for j = 1, p3 and 4 or 14 do
			local v14 = 0.12 + j / (p3 and 4 or 14) * 0.85 + (random:NextNumber() - 0.5) * 0.05
			table.insert(v12, {
				f = softDot(bgStyle, j % 2 == 0 and rgb(220, 110, 230) or rgb(110, 140, 255), 0.04 + 0.05 * v14, 0.3, 2), -- inferred equivalent call
				r = v14,
				a = v13 + v14 * 5 + (random:NextNumber() - 0.5) * 0.3
			})
		end
	end

	local v13 = softDot(bgStyle, rgb(255, 215, 245), 0.22, 0.55, 2) -- inferred equivalent call
	v13.Position = UDim2.fromScale(0.5, 0.5)
	animate(v13, function(p4) -- inferred equivalent call
		local absoluteSize = bgStyle.AbsoluteSize
		local v14 = math.max(absoluteSize.X, absoluteSize.Y) * 0.55
		local v15 = p4 * 0.05

		for k, v16 in v11 do
			local v17 = v16.a + v15
			v16.f.Position = UDim2.new(0.5, math.cos(v17) * v16.r * v14, 0.5, math.sin(v17) * v16.r * v14 * 0.45)
			v16.f.BackgroundTransparency = 1 - v16.op * (math.sin(p4 * 1.5 + v16.ph) * 0.35 + 0.65)
		end

		for k, v16 in v12 do
			local v17 = v16.a + v15
			v16.f.Position = UDim2.new(0.5, math.cos(v17) * v16.r * v14, 0.5, math.sin(v17) * v16.r * v14 * 0.45)
		end

		setOp(v13, math.sin(p4 * 0.8) * 0.15 + 0.85)
	end)
end

local function fallers(bgStyle, data)
	for i = 1, data.n do
		local fall = Instance.new("Frame")
		fall.Name = "Fall"
		fall.BorderSizePixel = 0
		fall.AnchorPoint = Vector2.new(0.5, 0.5)
		fall.BackgroundColor3 = data.colors[random:NextInteger(1, #data.colors)]
		fall.ZIndex = data.z or 3
		local v11 = data.size[1] + random:NextNumber() * (data.size[2] - data.size[1])

		if data.shape == "streak" then
			fall.Size = UDim2.fromOffset(math.max(1, v11 * 0.07), v11)
			fall.Rotation = data.angle or 0
			local uiGradient = Instance.new("UIGradient")
			uiGradient.Rotation = 90
			uiGradient.Transparency = seqT({
				{ 0, 1 },
				{ 1, 0 }
			})
			uiGradient.Parent = fall
		else
			if data.shape == "petal" then
				fall.Size = UDim2.fromOffset(v11, v11 * 0.6)
			else
				fall.Size = UDim2.fromOffset(v11, v11)
			end

			local uiCorner = Instance.new("UICorner")
			uiCorner.CornerRadius = UDim.new(0.5, 0)
			uiCorner.Parent = fall
		end

		fall.BackgroundTransparency = 1 - (data.op[1] + random:NextNumber() * (data.op[2] - data.op[1]))
		fall.Parent = bgStyle
		local number = random:NextNumber()
		local number2 = random:NextNumber()
		local v12 = data.speed[1] + random:NextNumber() * (data.speed[2] - data.speed[1])
		local v13 = random:NextNumber() * 6
		local v14 = (data.sway or 0) * (0.5 + random:NextNumber())
		local v15 = (random:NextNumber() * 2 - 1) * (data.spin or 0)
		local v16 = 2 + random:NextNumber() * 3
		animate(fall, function(p) -- inferred equivalent call
			local v17 = (number2 + p * v12) % 1.1 - 0.05
			local v18 = (number + p * (data.drift or 0) * v12 + v14 * math.sin(p * 0.9 + v13)) % 1.1 - 0.05
			fall.Position = UDim2.fromScale(v18, v17)

			if data.shape == "petal" then
				fall.Rotation = (p * v15 + v13 * 60) % 360
				fall.Size = UDim2.fromOffset(v11 * (math.abs((math.cos(p * v16 + v13))) * 0.75 + 0.25), v11 * 0.6)
			end
		end)
	end
end

local function skyBolt(bolts, vector2, vector2_2, p)
	local function seg(p2, p3, p4, backgroundColor, backgroundTransparency)
		local v11 = p3 - p2
		local frame2 = Instance.new("Frame")
		frame2.BorderSizePixel = 0
		frame2.AnchorPoint = Vector2.new(0.5, 0.5)
		frame2.Position = UDim2.fromOffset((p2.X + p3.X) / 2, (p2.Y + p3.Y) / 2)
		frame2.Size = UDim2.fromOffset(v11.Magnitude + p4 * 0.6, p4)
		frame2.Rotation = math.deg((math.atan2(v11.Y, v11.X)))
		frame2.BackgroundColor3 = backgroundColor
		frame2.BackgroundTransparency = backgroundTransparency
		frame2.ZIndex = bolts.ZIndex
		roundify(frame2) -- inferred equivalent call
		frame2.Parent = bolts
	end
	local function path(p2, p3, p4, p5)
		local v11 = p3 - p2
		local unit = Vector2.new(-v11.Y, v11.X).Unit
		local result = { p2 }

		for i = 1, p4 - 1 do
			table.insert(result, p2 + v11 * (i / p4) + unit * (random:NextNumber() * 2 - 1) * p5)
		end

		table.insert(result, p3)
		return result
	end

	local magnitude = (vector2_2 - vector2).Magnitude
	local v11 = path(vector2, vector2_2, 10, magnitude * 0.06)

	for i = 1, #v11 - 1 do
		seg(v11[i], v11[i + 1], p * 6, rgb(150, 170, 255), 0.85) -- inferred equivalent call
		seg(v11[i], v11[i + 1], p, rgb(235, 240, 255), 0) -- inferred equivalent call
	end

	for i = 1, 2 do
		local v12 = v11[random:NextInteger(3, 7)]
		local v13 = path(
			v12,
			v12 + Vector2.new(
				(random:NextNumber() * 2 - 1) * magnitude * 0.25,
				magnitude * (0.15 + random:NextNumber() * 0.2)
			),
			4,
			magnitude * 0.03
		)

		for j = 1, #v13 - 1 do
			seg(v13[j], v13[j + 1], math.max(1, p * 0.55), rgb(210, 220, 255), 0.25) -- inferred equivalent call
		end
	end
end

local function blossomBranch(bgStyle, p, zIndex)
	local branch = Instance.new("Frame")
	branch.Name = "Branch"
	branch.BackgroundTransparency = 1
	branch.AnchorPoint = Vector2.new(p < 0 and 0 or 1, 0)
	branch.Position = UDim2.fromScale(p < 0 and 0 or 1, 0)
	branch.ZIndex = zIndex
	branch.Parent = bgStyle
	local function fit() -- 1 equivalent call inferred from this helper
		local v11 = math.min(bgStyle.AbsoluteSize.X * 0.45, bgStyle.AbsoluteSize.Y * 0.62)
		branch.Size = UDim2.fromOffset(v11, v11)
	end
	bgStyle:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
	fit() -- inferred equivalent call

	local function X(p2) -- 3 equivalent calls inferred from this helper
		return p < 0 and p2 or 1 - p2
	end

	local function piece(parent2, p2, p3, p4, p5, backgroundColor, value)
		local frame2 = Instance.new("Frame")
		frame2.BorderSizePixel = 0
		frame2.AnchorPoint = Vector2.new(0.5, 0.5)
		frame2.Position = UDim2.fromScale(p2, p3)
		frame2.Size = UDim2.fromScale(p4, p5)
		frame2.Rotation = value or 0
		frame2.BackgroundColor3 = backgroundColor
		frame2.ZIndex = zIndex
		roundify(frame2) -- inferred equivalent call
		frame2.Parent = parent2
		return frame2
	end

	local backgroundColor = rgb(46, 22, 32) -- inferred equivalent call

	local function limb2(p2, p3, p4, p5, p6)
		local vector2 = Vector2.new(X(p2), p3) -- inferred equivalent call
		local vector2_2 = Vector2.new(X(p4), p5) -- inferred equivalent call
		local v11 = vector2_2 - vector2
		piece(
			branch,
			(vector2.X + vector2_2.X) / 2,
			(vector2.Y + vector2_2.Y) / 2,
			v11.Magnitude + p6 * 0.5,
			p6,
			backgroundColor,
			math.deg((math.atan2(v11.Y, v11.X)))
		)
	end
	limb2(-0.05, 0.02, 0.3, 0.14, 0.05)
	limb2(0.3, 0.14, 0.62, 0.16, 0.035)
	limb2(0.62, 0.16, 0.86, 0.1, 0.022)
	limb2(0.3, 0.14, 0.46, 0.34, 0.028)
	limb2(0.46, 0.34, 0.52, 0.5, 0.018)
	limb2(0.62, 0.16, 0.72, 0.3, 0.018)

	local v11 = { rgb(255, 196, 214), rgb(255, 172, 200), rgb(255, 224, 234) } -- inferred equivalent call

	for k, v12 in {
		{ 0.16, 0.08, 0.075 },
		{ 0.32, 0.1, 0.08 },
		{ 0.44, 0.2, 0.07 },
		{ 0.58, 0.12, 0.08 },
		{ 0.74, 0.16, 0.07 },
		{ 0.88, 0.09, 0.06 },
		{ 0.5, 0.4, 0.065 },
		{ 0.42, 0.29, 0.06 },
		{ 0.7, 0.29, 0.06 },
		{ 0.24, 0.17, 0.055 },
		{ 0.53, 0.5, 0.05 }
	} do
		local frame2 = Instance.new("Frame")
		frame2.BackgroundTransparency = 1
		frame2.AnchorPoint = Vector2.new(0.5, 0.5)
		frame2.Position = UDim2.fromScale(X(v12[1]), v12[2]) -- inferred equivalent call
		frame2.Size = UDim2.fromScale(v12[3], v12[3])
		frame2.Rotation = k * 37
		frame2.ZIndex = zIndex
		frame2.Parent = branch
		local v13 = v11[k % #v11 + 1]

		for i = 0, 4 do
			local v14 = i / 5 * 3.141592653589793 * 2
			piece(frame2, math.cos(v14) * 0.27 + 0.5, math.sin(v14) * 0.27 + 0.5, 0.5, 0.5, v13)
		end

		piece(frame2, 0.5, 0.5, 0.26, 0.26, rgb(236, 110, 150))
	end

	animate(branch, function(p2) -- inferred equivalent call
		branch.Rotation = p * 1.2 * math.sin(p2 * 0.6)
	end)
	return branch
end

local baseGradient

local function smoothstep(p, p2, p3) -- 3 equivalent calls inferred from this helper
	local v11 = math.clamp((p3 - p) / (p2 - p), 0, 1)
	return v11 * v11 * (3 - v11 * 2)
end

local v11 = {
	dots = function()
		return 32, function(p, p2)
			return 1 - smoothstep(1.6, 2.8, math.sqrt((p - 16) ^ 2 + (p2 - 16) ^ 2)) -- inferred equivalent call
		end
	end,
	glow = function()
		return 128, function(p, p2)
			local v11 = 1 - smoothstep(0, 1, math.sqrt((p - 64) ^ 2 + (p2 - 64) ^ 2) / 64) -- inferred equivalent call
			return v11 * v11
		end
	end,
	vignette = function()
		return 128, function(p, p2)
			return smoothstep(0.55, 1.42, math.sqrt((p - 64) ^ 2 + (p2 - 64) ^ 2) / 64) -- inferred equivalent call
		end
	end
}

local v12 = {}
local function painted(name)
	local v13 = v12[name]

	if v13 ~= nil then
		return v13 and v13.content or nil
	end

	v13 = false
	local success, result = pcall(function()
		local v14, v15 = v11[name]()
		local buf = buffer.create(v14 * v14 * 4)
		buffer.fill(buf, 0, 255)

		for i = 0, v14 - 1 do
			for j = 0, v14 - 1 do
				buffer.writeu8(
					buf,
					(i * v14 + j) * 4 + 3,
					(math.clamp(math.floor(v15(j + 0.5, i + 0.5) * 255 + 0.5), 0, 255))
				)
			end
		end

		local AssetService = game:GetService("AssetService")
		local editableImage = AssetService:CreateEditableImage({ Size = Vector2.new(v14, v14) })
		editableImage:WritePixelsBuffer(Vector2.zero, editableImage.Size, buf)
		return {
			img = editableImage,
			content = Content.fromObject(editableImage)
		}
	end)

	if success and result then
		v13 = result
	else
		warn("[Chess] painted texture '" .. name .. "' unavailable: " .. tostring(result))
	end

	v12[name] = v13

	return v13 and v13.content or nil
end

local function paintedLabel(parent2, name, items)
	local imageContent = painted(name)

	if not imageContent then
		return nil
	end

	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = name
	imageLabel.BackgroundTransparency = 1
	imageLabel.BorderSizePixel = 0
	imageLabel.Size = UDim2.fromScale(1, 1)
	imageLabel.ImageContent = imageContent

	for k, item in items do
		imageLabel[k] = item
	end

	imageLabel.Parent = parent2
	return imageLabel
end

local v13 = { "wP", "wN", "wB", "wR", "wQ", "wK" }
local function livingBackground(bgStyle, data, p)
	baseGradient(bgStyle, {
		{ 0, data.c1 },
		{ 0.5, data.c2 },
		{ 1, data.c3 or data.c2 }
	}, 90)
	paintedLabel(bgStyle, "glow", {
		Name = "Glow",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.45),
		Size = UDim2.fromScale(1.25, 1.6),
		ImageColor3 = data.glow or rgb(61, 139, 255), -- inferred equivalent call
		ImageTransparency = data.glowT or 0.86,
		ZIndex = 2
	})

	paintedLabel(bgStyle, "dots", {
		Name = "Dots",
		ScaleType = Enum.ScaleType.Tile,
		TileSize = UDim2.fromOffset(p and 12 or 26, p and 12 or 26),
		ImageColor3 = data.dotColor or rgb(150, 180, 255), -- inferred equivalent call
		ImageTransparency = data.dotT or 0.9,
		ZIndex = 2
	})

	if not p then
		for i = 1, data.floaters or 18 do
			local v14 = i % 3 == 0
			local v15 = v14 and random:NextInteger(62, 92) or random:NextInteger(32, 58)
			local floater = Instance.new("ImageLabel")
			floater.Name = "Floater"
			floater.BackgroundTransparency = 1
			floater.AnchorPoint = Vector2.new(0.5, 0.5)
			floater.Size = UDim2.fromOffset(v15, v15)
			floater.ImageColor3 = data.floatColor or rgb(170, 195, 255) -- inferred equivalent call
			floater.ImageTransparency = v14 and 0.86 or 0.9
			floater.ZIndex = v14 and 4 or 3
			Sprites.apply(floater, v13[random:NextInteger(1, #v13)])
			floater.Parent = bgStyle
			local number = random:NextNumber()
			local v16 = random:NextNumber() * 1.3
			local v17 = (v14 and 1.7 or 1) * (0.008 + random:NextNumber() * 0.01)
			local v18 = 0.005 + random:NextNumber() * 0.015
			local v19 = random:NextNumber() * 6
			local integer = random:NextInteger(-25, 25)
			local v20 = random:NextNumber() * 16 - 8
			animate(floater, function(p2) -- inferred equivalent call
				local v21 = 1.15 - (1.3 - v16 + p2 * v17) % 1.3
				floater.Position = UDim2.fromScale(number + v18 * math.sin(p2 * 0.4 + v19), v21)
				floater.Rotation = integer + v20 * math.sin(p2 * 0.25 + v19)
			end)
		end
	end

	paintedLabel(bgStyle, "vignette", {
		Name = "Vignette",
		ImageColor3 = data.vignette or rgb(6, 7, 10), -- inferred equivalent call
		ImageTransparency = data.vignetteT or 0.25,
		ZIndex = 5
	})
end

baseGradient = function(parent2, p, value)
	local base = Instance.new("Frame")
	base.Name = "Base"
	base.BorderSizePixel = 0
	base.Size = UDim2.fromScale(1, 1)
	base.BackgroundColor3 = color
	base.ZIndex = 1
	base.Parent = parent2

	base.AnchorPoint = Vector2.new(0.5, 0.5)
	base.Position = UDim2.fromScale(0.5, 0.5)
	gradient(base, p, value or 90)
	return base
end

local function moonDisc(parent2, backgroundColor, p, p2, p3)
	local moon = Instance.new("Frame")
	moon.Name = "Moon"
	moon.BorderSizePixel = 0
	moon.AnchorPoint = Vector2.new(0.5, 0.5)
	moon.SizeConstraint = Enum.SizeConstraint.RelativeXX
	moon.Size = UDim2.fromScale(p, p)
	moon.Position = UDim2.fromScale(p2, p3)
	moon.BackgroundColor3 = backgroundColor
	moon.ZIndex = 2
	roundify(moon) -- inferred equivalent call

	for k, v14 in {
		{ 0.34, 0.38, 0.2 },
		{ 0.64, 0.58, 0.26 },
		{ 0.42, 0.72, 0.13 },
		{ 0.7, 0.3, 0.1 }
	} do
		local patch = Instance.new("Frame")
		patch.Name = "Patch"
		patch.BorderSizePixel = 0
		patch.AnchorPoint = Vector2.new(0.5, 0.5)
		patch.Position = UDim2.fromScale(v14[1], v14[2])
		patch.Size = UDim2.fromScale(v14[3], v14[3])
		patch.BackgroundColor3 = shade(backgroundColor, 0.14) -- inferred equivalent call
		patch.BackgroundTransparency = 0.35
		patch.ZIndex = 2
		roundify(patch) -- inferred equivalent call
		patch.Parent = moon
	end

	moon.Parent = parent2
	return moon
end

local function batsAcross(parent2, p, p2)
	for i = 1, p do
		local bat = makeBat(p2 or rgb(16, 10, 22)) -- inferred equivalent call
		bat.AnchorPoint = Vector2.new(0.5, 0.5)
		bat.SizeConstraint = Enum.SizeConstraint.RelativeXX
		bat.ZIndex = 3
		bat.Visible = false
		bat.Parent = parent2
		local v14 = i * 2.3 + 7
		local number = random:NextNumber()
		local v15 = 0.028 + random:NextNumber() * 0.024
		local function fn(p3)
			local v16 = p3 / v14 + number
			local v17 = math.floor(v16)
			local v18 = (v16 - v17) * v14 / 4.5

			if v18 > 1 then
				bat.Visible = false
				return
			end

			local random2 = Random.new(v17 * 17 + i * 101)
			local v19 = random2:NextNumber() < 0.5 and -1 or 1
			local v20 = 0.08 + random2:NextNumber() * 0.4
			bat.Visible = true
			bat.Size = UDim2.fromScale(v15, v15)
			bat.Position = UDim2.fromScale(
				v19 > 0 and -0.05 + 1.1 * v18 or 1.05 - 1.1 * v18,
				v20 + math.sin(v18 * 14 + i) * 0.03 - 0.06 * v18
			)
			flapBat(bat, p3 * 20 + i) -- inferred equivalent call
		end

		animate(bat, fn) -- inferred equivalent call
	end
end

local function bloodMoon(bgStyle, p, p2, count)
	baseGradient(bgStyle, {
		{ 0, rgb(8, 2, 5) },
		{ 0.5, p.c2 },
		{ 0.82, rgb(118, 22, 26) },
		{ 1, rgb(46, 6, 10) }
	}, 90)
	starLayer(bgStyle, count(45), p2 and 1 or 2, 0.0006, 0.1, 0.45)
	local v14 = p2 and 0.66 or 0.8
	local v15 = p2 and 0.36 or 0.3
	local v16 = p2 and 0.4 or 0.22
	local corona = Instance.new("Frame")
	corona.Name = "Corona"
	corona.BackgroundTransparency = 1
	corona.AnchorPoint = Vector2.new(0.5, 0.5)
	corona.Position = UDim2.fromScale(v14, v15)
	corona.SizeConstraint = Enum.SizeConstraint.RelativeXX
	local v17 = v16 * (p2 and 3.6 or 7)
	corona.Size = UDim2.fromScale(v17, v17)
	corona.ZIndex = 2
	corona.Parent = bgStyle
	local v18 = p2 and 12 or 22
	local v19 = {}

	for i = 1, v18 do
		local ray = Instance.new("Frame")
		ray.Name = "Ray"
		ray.BackgroundTransparency = 1
		ray.AnchorPoint = Vector2.new(0.5, 0.5)
		ray.Position = UDim2.fromScale(0.5, 0.5)
		ray.Size = UDim2.fromScale(1, 1)
		ray.Rotation = (i - 1) / v18 * 360 + random:NextNumber() * 8
		ray.ZIndex = 2
		ray.Parent = corona
		local v20 = i % 2 == 0
		local frame2 = Instance.new("Frame")
		frame2.BorderSizePixel = 0
		frame2.AnchorPoint = Vector2.new(0.5, 1)
		frame2.Position = UDim2.fromScale(0.5, 0.5)
		local len = 0.28 + random:NextNumber() * 0.2
		local v21 = v20 and (p2 and 0.04 or 0.022) or p2 and 0.012 or 0.006
		frame2.Size = UDim2.fromScale(v21, len)
		frame2.BackgroundColor3 = v20 and rgb(200, 30, 30) or rgb(255, 120, 80) -- inferred equivalent call
		frame2.ZIndex = 2
		roundify(frame2) -- inferred equivalent call
		local uiGradient = Instance.new("UIGradient")
		uiGradient.Rotation = 90
		uiGradient.Transparency = seqT({
			{ 0, 1 },
			{ 0.55, 0.65 },
			{ 1, 0.3 }
		})
		uiGradient.Parent = frame2
		frame2.Parent = ray
		v19[i] = {
			f = frame2,
			w = v21,
			len = len,
			op = v20 and 0.5 or 0.45,
			ph = random:NextNumber() * 6,
			sp = 0.4 + random:NextNumber() * 0.6
		}
	end

	local v20 = softDot(bgStyle, rgb(255, 45, 30), v16 * (p2 and 2.4 or 3.4), 0.55, 2) -- inferred equivalent call
	v20.Position = UDim2.fromScale(v14, v15)
	local v21 = softDot(bgStyle, rgb(255, 110, 70), v16 * 1.5, 0.5, 2) -- inferred equivalent call
	v21.Position = UDim2.fromScale(v14, v15)

	local parent3 = moonDisc(bgStyle, color, v16, v14, v15)
	parent3.ZIndex = 3
	gradient(parent3, {
		{ 0, rgb(255, 160, 100) },
		{ 0.35, rgb(228, 62, 42) },
		{ 0.75, rgb(118, 16, 18) },
		{ 1, rgb(46, 6, 10) }
	}, 50)

	for i, frame2 in parent3:GetChildren() do
		if not frame2:IsA("Frame") then
			continue
		end

		frame2.BackgroundColor3 = rgb(80, 8, 12) -- inferred equivalent call
		frame2.BackgroundTransparency = 0.6
		frame2.ZIndex = 3
	end

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = rgb(255, 140, 95) -- inferred equivalent call
	uiStroke.Thickness = p2 and 1 or 2
	uiStroke.Transparency = 0.5
	uiStroke.Parent = parent3

	for i = 1, p2 and 2 or 3 do
		local cloud = Instance.new("CanvasGroup")
		cloud.Name = "Cloud"
		cloud.BorderSizePixel = 0
		cloud.BackgroundTransparency = 1
		cloud.AnchorPoint = Vector2.new(0.5, 0.5)
		cloud.SizeConstraint = Enum.SizeConstraint.RelativeXX
		local v22 = (p2 and 0.6 or 0.26) * (0.8 + random:NextNumber() * 0.4)
		cloud.Size = UDim2.fromScale(v22, v22 * 0.3)
		cloud.GroupTransparency = 0.25
		cloud.ZIndex = 4
		local total = 0.1
		local v23 = {}

		while total < 0.9 do
			table.insert(v23, { total, (1 - math.abs(total - 0.5) * 1.6) * 0.45 + 0.35 + random:NextNumber() * 0.15 })
			total += 0.1 + random:NextNumber() * 0.07
		end

		for j = 1, 2 do
			local v24 = j == 1

			for k, v25 in v23 do
				local frame2 = Instance.new("Frame")
				frame2.BorderSizePixel = 0
				frame2.AnchorPoint = Vector2.new(0.5, 1)
				frame2.SizeConstraint = Enum.SizeConstraint.RelativeYY
				frame2.Size = UDim2.fromScale(v25[2], v25[2])
				frame2.Position = UDim2.fromScale(v25[1], v24 and 0.93 or 1)
				frame2.BackgroundColor3 = v24 and rgb(190, 50, 40) or rgb(22, 4, 8) -- inferred equivalent call
				frame2.ZIndex = v24 and 1 or 2
				roundify(frame2) -- inferred equivalent call
				frame2.Parent = cloud
			end
		end

		local frame2 = Instance.new("Frame")
		frame2.BorderSizePixel = 0
		frame2.AnchorPoint = Vector2.new(0.5, 1)
		frame2.Position = UDim2.fromScale(0.5, 1)
		frame2.Size = UDim2.fromScale(0.86, 0.32)
		frame2.BackgroundColor3 = rgb(22, 4, 8) -- inferred equivalent call
		frame2.ZIndex = 2
		roundify(frame2) -- inferred equivalent call
		frame2.Parent = cloud
		cloud.Parent = bgStyle
		local v24 = v15 + (p2 and -0.04 or -0.03) + (i - 1) * (p2 and 0.2 or 0.1) + random:NextNumber() * 0.03
		local v25 = random:NextNumber() * 1.8
		local v26 = (0.008 + random:NextNumber() * 0.01) * (i % 2 == 0 and -1 or 1)
		animate(cloud, function(p3) -- inferred equivalent call
			cloud.Position = UDim2.fromScale((v25 + p3 * v26) % 1.8 - 0.4, v24)
		end)
	end

	local backgroundColor = rgb(10, 2, 5) -- inferred equivalent call
	local v22 = p2 and 0.8 or 0.88
	local ground = Instance.new("Frame")
	ground.Name = "Ground"
	ground.BackgroundTransparency = 1
	ground.Size = UDim2.fromScale(1, 1)
	ground.ZIndex = 4
	ground.Parent = bgStyle
	local land = Instance.new("Frame")
	land.Name = "Land"
	land.BorderSizePixel = 0
	land.Size = UDim2.fromScale(1, 1)
	land.BackgroundColor3 = backgroundColor
	land.ZIndex = 4
	land.Parent = ground

	land.Position = UDim2.fromScale(0, v22 + 0.04)

	for k, v23 in p2 and {
		{ 0.1, 0.5 },
		{ 0.5, 0.65 },
		{ 0.92, 0.5 }
	} or {
		{ 0.04, 0.3 },
		{ 0.24, 0.24 },
		{ 0.5, 0.36 },
		{ 0.74, 0.26 },
		{ 0.96, 0.32 }
	} do
		local hill = Instance.new("Frame")
		hill.Name = "Hill"
		hill.BorderSizePixel = 0
		hill.AnchorPoint = Vector2.new(0.5, 0)
		hill.SizeConstraint = Enum.SizeConstraint.RelativeXX
		hill.Size = UDim2.fromScale(v23[2], v23[2])
		hill.Position = UDim2.fromScale(v23[1], v22 - 0.015 + random:NextNumber() * 0.03)
		hill.BackgroundColor3 = backgroundColor
		hill.ZIndex = 4
		roundify(hill) -- inferred equivalent call
		hill.Parent = ground
	end

	local function standing(p3, p4, value)
		local frame2 = Instance.new("Frame")
		frame2.BackgroundTransparency = 1
		frame2.AnchorPoint = Vector2.new(0.5, 1)
		frame2.Position = UDim2.fromScale(p3, v22 + 0.045)
		frame2.SizeConstraint = Enum.SizeConstraint.RelativeYY
		frame2.Size = UDim2.fromScale(p4 * (value or 1), p4)
		frame2.ZIndex = 4
		frame2.Parent = ground
		return frame2
	end

	local function bar(parent2, p3, p4, p5, p6, value, p7)
		local frame2 = Instance.new("Frame")
		frame2.BorderSizePixel = 0
		frame2.AnchorPoint = Vector2.new(0.5, 0.5)
		frame2.Position = UDim2.fromScale(p3, p4)
		frame2.Size = UDim2.fromScale(p5, p6)
		frame2.Rotation = value or 0
		frame2.BackgroundColor3 = backgroundColor
		frame2.ZIndex = 4

		if p7 then
			roundify(frame2) -- inferred equivalent call
		end

		frame2.Parent = parent2
		return frame2
	end

	local function tree(p3, p4, p5)
		local parent2 = standing(p3, p4)
		local function branch(p6, p7, p8, p9, p10)
			if p5 then
				p6 = 1 - p6
				p8 = 1 - p8
			end

			local vector2 = Vector2.new(p8 - p6, p9 - p7)
			bar(
				parent2,
				(p6 + p8) / 2,
				(p7 + p9) / 2,
				vector2.Magnitude + p10 * 0.5,
				p10,
				math.deg((math.atan2(vector2.Y, vector2.X))),
				true
			)
		end
		local v23 = 0.5
		local v24 = 0.53

		if p5 then
			v23 = 1 - v23
			v24 = 1 - v24
		end

		local vector2 = Vector2.new(v24 - v23, -0.47)
		bar(
			parent2,
			(v23 + v24) / 2,
			0.785,
			vector2.Magnitude + 0.0375,
			0.075,
			math.deg((math.atan2(vector2.Y, vector2.X))),
			true
		)

		local v25 = 0.53
		local v26 = 0.49

		if p5 then
			v25 = 1 - v25
			v26 = 1 - v26
		end

		local vector2_2 = Vector2.new(v26 - v25, -0.27)
		bar(
			parent2,
			(v25 + v26) / 2,
			0.41500000000000004,
			vector2_2.Magnitude + 0.0225,
			0.045,
			math.deg((math.atan2(vector2_2.Y, vector2_2.X))),
			true
		)

		local v27 = 0.52
		local v28 = 0.28

		if p5 then
			v27 = 1 - v27
			v28 = 1 - v28
		end

		local vector2_3 = Vector2.new(v28 - v27, -0.22000000000000003)
		bar(
			parent2,
			(v27 + v28) / 2,
			0.53,
			vector2_3.Magnitude + 0.018,
			0.036,
			math.deg((math.atan2(vector2_3.Y, vector2_3.X))),
			true
		)

		local v29 = 0.28
		local v30 = 0.17

		if p5 then
			v29 = 1 - v29
			v30 = 1 - v30
		end

		local vector2_4 = Vector2.new(v30 - v29, -0.19999999999999998)
		bar(
			parent2,
			(v29 + v30) / 2,
			0.32,
			vector2_4.Magnitude + 0.011,
			0.022,
			math.deg((math.atan2(vector2_4.Y, vector2_4.X))),
			true
		)

		local v31 = 0.28
		local v32 = 0.1

		if p5 then
			v31 = 1 - v31
			v32 = 1 - v32
		end

		local vector2_5 = Vector2.new(v32 - v31, 0.020000000000000018)
		bar(
			parent2,
			(v31 + v32) / 2,
			0.43,
			vector2_5.Magnitude + 0.009,
			0.018,
			math.deg((math.atan2(vector2_5.Y, vector2_5.X))),
			true
		)

		local v39 = 0.53
		local v40 = 0.77

		if p5 then
			v39 = 1 - v39
			v40 = 1 - v40
		end

		local vector2_6 = Vector2.new(v40 - v39, -0.16000000000000003)
		bar(
			parent2,
			(v39 + v40) / 2,
			0.44,
			vector2_6.Magnitude + 0.016,
			0.032,
			math.deg((math.atan2(vector2_6.Y, vector2_6.X))),
			true
		)

		local v41 = 0.77
		local v42 = 0.86

		if p5 then
			v41 = 1 - v41
			v42 = 1 - v42
		end

		local vector2_7 = Vector2.new(v42 - v41, -0.19999999999999998)
		bar(
			parent2,
			(v41 + v42) / 2,
			0.26,
			vector2_7.Magnitude + 0.01,
			0.02,
			math.deg((math.atan2(vector2_7.Y, vector2_7.X))),
			true
		)

		local v43 = 0.77
		local v44 = 0.93

		if p5 then
			v43 = 1 - v43
			v44 = 1 - v44
		end

		local vector2_8 = Vector2.new(v44 - v43, 0.020000000000000018)
		bar(
			parent2,
			(v43 + v44) / 2,
			0.37,
			vector2_8.Magnitude + 0.008,
			0.016,
			math.deg((math.atan2(vector2_8.Y, vector2_8.X))),
			true
		)

		local v45 = 0.49
		local v46 = 0.4

		if p5 then
			v45 = 1 - v45
			v46 = 1 - v46
		end

		local vector2_9 = Vector2.new(v46 - v45, -0.18000000000000002)
		bar(
			parent2,
			(v45 + v46) / 2,
			0.19,
			vector2_9.Magnitude + 0.01,
			0.02,
			math.deg((math.atan2(vector2_9.Y, vector2_9.X))),
			true
		)

		local v47 = 0.49
		local v48 = 0.61

		if p5 then
			v47 = 1 - v47
			v48 = 1 - v48
		end

		local vector2_10 = Vector2.new(v48 - v47, -0.21000000000000002)
		bar(
			parent2,
			(v47 + v48) / 2,
			0.17500000000000002,
			vector2_10.Magnitude + 0.009,
			0.018,
			math.deg((math.atan2(vector2_10.Y, vector2_10.X))),
			true
		)

		local v49 = 0.36
		local v50 = 0.5

		if p5 then
			v49 = 1 - v49
			v50 = 1 - v50
		end

		local vector2_11 = Vector2.new(v50 - v49, -0.09999999999999998)
		bar(
			parent2,
			(v49 + v50) / 2,
			0.95,
			vector2_11.Magnitude + 0.025,
			0.05,
			math.deg((math.atan2(vector2_11.Y, vector2_11.X))),
			true
		)

		local v51 = 0.66
		local v52 = 0.52

		if p5 then
			v51 = 1 - v51
			v52 = 1 - v52
		end

		local vector2_12 = Vector2.new(v52 - v51, -0.09999999999999998)
		bar(
			parent2,
			(v51 + v52) / 2,
			0.95,
			vector2_12.Magnitude + 0.025,
			0.05,
			math.deg((math.atan2(vector2_12.Y, vector2_12.X))),
			true
		)
	end
	local function stone(p3, p4, p5) -- 9 equivalent calls inferred from this helper
		local parent2 = standing(p3, p4, p5 and 0.7 or 0.65)
		parent2.Rotation = (random:NextNumber() * 2 - 1) * 8

		if p5 then
			bar(parent2, 0.5, 0.55, 0.24, 0.95)
			bar(parent2, 0.5, 0.3, 0.9, 0.2)
		else
			bar(parent2, 0.5, 0.4, 1, 0.7, 0, true)
			bar(parent2, 0.5, 0.72, 1, 0.56)
		end
	end

	if p2 then
		tree(0.2, 0.42, false)
		stone(0.6, 0.1, false) -- inferred equivalent call
		stone(0.72, 0.13, true) -- inferred equivalent call
		stone(0.84, 0.09, false) -- inferred equivalent call
	else
		tree(0.17, 0.3, false)
		tree(0.95, 0.36, true)
		stone(0.215, 0.06, false) -- inferred equivalent call
		stone(0.245, 0.08, true) -- inferred equivalent call
		stone(0.4, 0.05, false) -- inferred equivalent call
		stone(0.63, 0.07, true) -- inferred equivalent call
		stone(0.88, 0.075, true) -- inferred equivalent call
		stone(0.91, 0.055, false) -- inferred equivalent call
	end

	for i = 1, p2 and 2 or 4 do
		local fog = Instance.new("Frame")
		fog.Name = "Fog"
		fog.BorderSizePixel = 0
		fog.AnchorPoint = Vector2.new(0.5, 0.5)
		fog.Size = UDim2.fromScale(1.4, p2 and 0.12 or 0.08)
		fog.BackgroundColor3 = rgb(170, 30, 35) -- inferred equivalent call
		fog.ZIndex = 4
		roundify(fog) -- inferred equivalent call
		local v23 = 0.18 + random:NextNumber() * 0.12
		local uiGradient = Instance.new("UIGradient")
		uiGradient.Transparency = seqT({
			{ 0, 1 },
			{ 0.3, 1 - v23 },
			{ 0.7, 1 - v23 },
			{ 1, 1 }
		})
		uiGradient.Parent = fog
		fog.Parent = bgStyle
		local v24 = v22 + 0.015 + (i - 1) * (p2 and 0.06 or 0.03)
		local v25 = random:NextNumber() * 6
		local v26 = 0.6 + random:NextNumber() * 0.8
		animate(fog, function(p3) -- inferred equivalent call
			fog.Position = UDim2.fromScale(math.sin(p3 * 0.06 * v26 + v25) * 0.22 + 0.5, v24)
		end)
	end

	drifters(bgStyle, count(28), {
		colors = { rgb(255, 120, 60), rgb(255, 70, 40), rgb(255, 190, 100) }, -- inferred equivalent call
		size = { 0.005, 0.012 },
		op = 1,
		vy = -0.035,
		sway = 0.03,
		twinkle = 2,
		z = 4
	})
	batsAcross(bgStyle, p2 and 1 or 4, rgb(18, 4, 8))
	vignette(bgStyle, 0.55)

	for i, child in v20:GetChildren() do
		child.BackgroundTransparency = 1 - child:GetAttribute("Op") * 0.75
	end

	for i, child in v21:GetChildren() do
		child.BackgroundTransparency = 1 - child:GetAttribute("Op") * 0.8
	end

	for k, v23 in v19 do
		v23.f.BackgroundTransparency = 1 - v23.op * 0.8
	end

	animate(corona, function(p3) -- inferred equivalent call
		corona.Rotation = p3 * 1.5 % 360

		for k, v23 in v19 do
			local v24 = math.sin(p3 * v23.sp * 0.5 + v23.ph) * 0.5 + 0.5
			v23.f.Size = UDim2.fromScale(v23.w, v23.len * (v24 * 0.15 + 0.85))
		end
	end)
end

function Cosmetics2:applyBackground(p, p2)
	self:SetAttribute("NoTint", true)

	for i, child in self:GetChildren() do
		if child.Name == "BgStyle" then
			child:Destroy()
		end
	end

	local v14 = Cosmetics.BY_ID[p]

	if not v14 or v14.type ~= "background" then
		v14 = Cosmetics.BY_ID[Cosmetics.DEFAULT.background]
	end

	self.BackgroundColor3 = v14.c1
	self.BackgroundTransparency = 0
	self.ClipsDescendants = true
	local bgStyle = Instance.new("Frame")
	bgStyle.Name = "BgStyle"
	bgStyle.BackgroundTransparency = 1
	bgStyle.Size = UDim2.fromScale(1, 1)
	bgStyle.ZIndex = self.ZIndex
	bgStyle.Parent = self
	local v15 = p2 and 0.3 or 1

	local function count(p3) -- 19 equivalent calls inferred from this helper
		return (math.max(1, (math.floor(p3 * v15 + 0.5))))
	end

	local style = v14.style

	if style == "living" then
		livingBackground(bgStyle, v14, p2)
	elseif style == "soft" then
		baseGradient(bgStyle, {
			{ 0, tint(v14.c1, 0.07) },
			{ 1, shade(v14.c1, 0.35) }
		})
		drifters(bgStyle, p2 and 2 or 4, {
			colors = { v14.c2, tint(v14.c2, 0.3) },
			size = { 0.35, 0.6 },
			op = 0.22,
			vy = -0.004,
			sway = 0.12,
			z = 2
		})
		vignette(bgStyle, 0.4)
	elseif style == "gradient" then
		baseGradient(bgStyle, {
			{ 0, v14.c1 },
			{ 1, v14.c2 or v14.c1 }
		}, v14.rot)

		if v14.dots then
			local v16

			if v14.dots ~= true then
				v16 = v14.dots or nil
			end

			dots(bgStyle, p2, v16)
		end

		vignette(bgStyle, 0.35)
	elseif style == "sunset" then
		baseGradient(bgStyle, {
			{ 0, v14.c1 },
			{ 0.55, rgb(150, 50, 100) },
			{ 0.85, rgb(235, 110, 80) },
			{ 1, v14.c2 }
		})
		local v16 = softDot(bgStyle, rgb(255, 200, 110), 0.7, 0.55, 2) -- inferred equivalent call
		v16.Position = UDim2.fromScale(0.5, 1.02)
		animate(v16, function(p3) -- inferred equivalent call
			setOp(v16, math.sin(p3 * 0.6) * 0.15 + 0.85)
		end)
		drifters(bgStyle, count(16), { -- inferred equivalent call
			colors = { rgb(255, 180, 120), rgb(255, 120, 150), rgb(255, 220, 160) }, -- inferred equivalent call
			size = { 0.015, 0.05 },
			op = 0.45,
			vy = -0.02,
			sway = 0.03,
			twinkle = 0.8
		})
		starLayer(bgStyle, count(25), p2 and 1 or 2, 0, 0.2, 0.6) -- inferred equivalent call
		vignette(bgStyle, 0.35)
	elseif style == "deepsea" then
		baseGradient(bgStyle, {
			{ 0, v14.c1 },
			{ 0.6, rgb(10, 40, 70) },
			{ 1, v14.c2 }
		})

		for i = 1, p2 and 3 or 6 do
			local v16 = (i - 0.5) / (p2 and 3 or 6) + (random:NextNumber() - 0.5) * 0.1
			local v17 = 0.05 + random:NextNumber() * 0.08
			local v18 = random:NextNumber() * 6
			local ray = Instance.new("Frame")
			ray.Name = "Ray"
			ray.BackgroundTransparency = 1
			ray.AnchorPoint = Vector2.new(0.5, 0)
			ray.Position = UDim2.fromScale(v16, -0.1)
			ray.Size = UDim2.fromScale(v17, 1.4)
			ray.ZIndex = 2
			ray.Parent = bgStyle

			for k, v19 in {
				{ 1, 0.9 },
				{ 0.55, 0.85 },
				{ 0.22, 0.8 }
			} do
				local backgroundColor = rgb(150, 230, 255) -- inferred equivalent call
				local strip = Instance.new("Frame")
				strip.Name = "Strip"
				strip.BorderSizePixel = 0
				strip.Size = UDim2.fromScale(1, 1)
				strip.BackgroundColor3 = backgroundColor
				strip.ZIndex = 2
				strip.Parent = ray

				strip.AnchorPoint = Vector2.new(0.5, 0)
				strip.Position = UDim2.fromScale(0.5, 0)
				strip.Size = UDim2.fromScale(v19[1], 1)
				local uiGradient = Instance.new("UIGradient")
				uiGradient.Rotation = 90
				uiGradient.Transparency = seqT({
					{ 0, v19[2] },
					{ 0.7, 1 },
					{ 1, 1 }
				})
				uiGradient.Parent = strip
			end

			animate(ray, function(p3) -- inferred equivalent call
				ray.Rotation = math.sin(p3 * 0.25 + v18) * 5 + 14
				ray.Size = UDim2.fromScale(v17 * (math.sin(p3 * 0.4 + v18) * 0.2 + 0.8), 1.4)
			end)
		end

		for i = 1, count(22) do -- inferred equivalent call
			local bubble = Instance.new("Frame")
			bubble.Name = "Bubble"
			bubble.AnchorPoint = Vector2.new(0.5, 0.5)
			local v16 = (p2 and 2 or 4) + random:NextNumber() * (p2 and 3 or 7)
			bubble.Size = UDim2.fromOffset(v16, v16)
			bubble.BackgroundColor3 = rgb(180, 240, 255) -- inferred equivalent call
			bubble.BackgroundTransparency = 0.85
			bubble.ZIndex = 3
			roundify(bubble) -- inferred equivalent call
			local uiStroke = Instance.new("UIStroke")
			uiStroke.Color = rgb(190, 245, 255) -- inferred equivalent call
			uiStroke.Thickness = 1
			uiStroke.Parent = bubble
			bubble.Parent = bgStyle
			local number = random:NextNumber()
			local v17 = random:NextNumber() * 1.2
			local v18 = 0.03 + random:NextNumber() * 0.04
			local v19 = random:NextNumber() * 6
			animate(bubble, function(p3) -- inferred equivalent call
				local v20 = (v17 - p3 * v18) % 1.2 - 0.1
				bubble.Position = UDim2.fromScale(number + math.sin(p3 * 2 + v19) * 0.012, v20)
				uiStroke.Transparency = (1 - math.clamp(v20, 0, 1)) * 0.5 + 0.35
			end)
		end

		vignette(bgStyle, 0.45)
	elseif style == "witching" then
		baseGradient(bgStyle, {
			{ 0, v14.c1 },
			{ 0.7, v14.c2 },
			{ 1, rgb(34, 16, 30) }
		}, 90)
		starLayer(bgStyle, count(60), p2 and 1 or 2, 0.001, 0.2, 0.7) -- inferred equivalent call
		local softDot_2 = softDot(bgStyle, rgb(255, 236, 196), p2 and 0.45 or 0.4, 0.35, 2) -- inferred equivalent call
		softDot_2.Position = UDim2.fromScale(0.76, 0.2)
		moonDisc(bgStyle, rgb(250, 238, 206), p2 and 0.16 or 0.1, 0.76, 0.2) -- inferred equivalent call
		drifters(bgStyle, p2 and 2 or 5, {
			colors = { rgb(120, 90, 160), rgb(90, 70, 130) }, -- inferred equivalent call
			size = { 0.4, 0.7 },
			op = 0.18,
			vx = 0.006,
			sway = 0.05,
			z = 3
		})
		drifters(bgStyle, count(18), { -- inferred equivalent call
			colors = { rgb(255, 170, 60), rgb(255, 210, 110) }, -- inferred equivalent call
			size = { 0.01, 0.02 },
			op = 1,
			vy = -0.008,
			sway = 0.04,
			twinkle = 1.4,
			z = 3
		})
		batsAcross(bgStyle, p2 and 1 or 3)
		vignette(bgStyle, 0.45)
	elseif style == "bloodmoon" then
		bloodMoon(bgStyle, v14, p2, count)
	elseif style == "fireflies" then
		baseGradient(bgStyle, {
			{ 0, v14.c1 },
			{ 1, v14.c2 }
		}, v14.rot)
		drifters(bgStyle, p2 and 2 or 3, {
			colors = { rgb(60, 200, 160) },
			size = { 0.4, 0.6 },
			op = 0.1,
			vx = 0.004,
			sway = 0.08
		})
		drifters(bgStyle, count(34), { -- inferred equivalent call
			colors = { rgb(220, 255, 120), rgb(170, 255, 170) }, -- inferred equivalent call
			size = { 0.012, 0.022 },
			op = 1,
			vy = -0.006,
			vx = 0.003,
			sway = 0.04,
			twinkle = 1.6,
			z = 3
		})
		vignette(bgStyle, 0.4)
	elseif style == "stars" then
		baseGradient(bgStyle, {
			{ 0, v14.c1 },
			{ 1, v14.c2 }
		}, v14.rot)
		drifters(bgStyle, p2 and 2 or 4, {
			colors = { rgb(110, 60, 190), rgb(40, 90, 190), rgb(170, 60, 150) }, -- inferred equivalent call
			size = { 0.45, 0.75 },
			op = 0.3,
			vx = 0.002,
			sway = 0.05
		})

		starLayer(bgStyle, count(150), 1, 0.002, 0.3, 0.7) -- inferred equivalent call
		starLayer(bgStyle, count(70), p2 and 1 or 2, 0.005, 0.5, 0.95) -- inferred equivalent call
		starLayer(bgStyle, count(22), p2 and 2 or 3, 0.01, 0.75, 1) -- inferred equivalent call

		for i = 1, p2 and 1 or 4 do
			local v16 = softDot(bgStyle, rgb(190, 210, 255), p2 and 0.04 or 0.025, 0.8, 3) -- inferred equivalent call
			v16.Position = UDim2.fromScale(random:NextNumber(), random:NextNumber())
			local v17 = random:NextNumber() * 6
			animate(v16, function(p3) -- inferred equivalent call
				setOp(v16, math.sin(p3 * 1.3 + v17) * 0.4 + 0.6)
			end)
		end

		if not p2 then
			shootingStars(bgStyle, 5)
			shootingStars(bgStyle, 7, 0.5)
		end

		vignette(bgStyle, 0.35)
	elseif style == "drift" then
		local v16 = p2 and 14 or 80
		local grid = Instance.new("Frame")
		grid.Name = "Grid"
		grid.BackgroundTransparency = 1
		grid.ZIndex = 2
		grid.Parent = bgStyle
		local v17 = 0
		local function build()
			local absoluteSize = self.AbsoluteSize
			local v18 = math.ceil(absoluteSize.X / v16) + 3
			local v19 = math.ceil(absoluteSize.Y / v16) + 3

			if v18 * v19 == v17 then
				return
			end

			v17 = v18 * v19
			grid:ClearAllChildren()
			grid.Size = UDim2.fromOffset(v18 * v16, v19 * v16)

			for i = 0, v19 - 1 do
				for j = 0, v18 - 1 do
					if (i + j) % 2 ~= 0 then
						continue
					end

					local frame2 = Instance.new("Frame")
					frame2.BorderSizePixel = 0
					frame2.Size = UDim2.fromOffset(v16, v16)
					frame2.Position = UDim2.fromOffset(j * v16, i * v16)
					frame2.BackgroundColor3 = v14.c2
					frame2.BackgroundTransparency = 0.55
					frame2.Parent = grid
				end
			end
		end
		build()
		bgStyle:GetPropertyChangedSignal("AbsoluteSize"):Connect(build)
		animate(grid, function(p3) -- inferred equivalent call
			local v18 = p3 * 14 % (v16 * 2)
			grid.Position = UDim2.fromOffset(-v16 * 2 + v18, -v16 * 2 + v18)
		end)
		sweep(bgStyle, rgb(170, 255, 190), 7, 0.12) -- inferred equivalent call
		drifters(bgStyle, p2 and 1 or 3, {
			colors = { rgb(120, 220, 140) },
			size = { 0.4, 0.6 },
			op = 0.1,
			vx = 0.003,
			sway = 0.1,
			z = 3
		})
		vignette(bgStyle, 0.5)
	elseif style == "aurora" then
		baseGradient(bgStyle, {
			{ 0, v14.c1 },
			{ 0.7, v14.c2 },
			{ 1, rgb(10, 40, 40) }
		})
		starLayer(bgStyle, count(80), p2 and 1 or 2, 0.001, 0.25, 0.8) -- inferred equivalent call
		local backgroundColor = rgb(40, 200, 150) -- inferred equivalent call
		local horizon = Instance.new("Frame")
		horizon.Name = "Horizon"
		horizon.BorderSizePixel = 0
		horizon.Size = UDim2.fromScale(1, 1)
		horizon.BackgroundColor3 = backgroundColor
		horizon.ZIndex = 2
		horizon.Parent = bgStyle

		local uiGradient = Instance.new("UIGradient")
		uiGradient.Rotation = 90
		uiGradient.Transparency = seqT({
			{ 0, 1 },
			{ 0.55, 1 },
			{ 1, 0.7 }
		})
		uiGradient.Parent = horizon
		curtain(bgStyle, p2 and 24 or 90, rgb(90, 120, 255), rgb(90, 255, 220), 0.5, 0.42, 0.8, 3, 0.7) -- inferred equivalent call
		curtain(bgStyle, p2 and 30 or 110, rgb(190, 90, 255), rgb(60, 255, 160), 0.64, 0.58, 1, 0, 0.95) -- inferred equivalent call

		if not p2 then
			shootingStars(bgStyle, 9)
		end

		vignette(bgStyle, 0.35)
	elseif style == "galaxy" then
		local v16 = baseGradient(bgStyle, {
			{ 0, v14.c1 },
			{ 0.5, v14.c2 },
			{ 1, v14.c1 }
		})
		v16.Size = UDim2.fromScale(2.2, 2.2)
		v16.SizeConstraint = Enum.SizeConstraint.RelativeXX
		animate(v16, function(p3) -- inferred equivalent call
			v16.Rotation = p3 * 3 % 360
		end)
		local v17 = blob(bgStyle, rgb(150, 70, 200), 0.9, 0.7) -- inferred equivalent call
		local v18 = blob(bgStyle, rgb(60, 110, 220), 0.7, 0.75) -- inferred equivalent call
		animate(v17, function(p3) -- inferred equivalent call
			v17.Position = UDim2.fromScale(math.sin(p3 * 0.13) * 0.08 + 0.35, math.cos(p3 * 0.11) * 0.08 + 0.4)
			v18.Position = UDim2.fromScale(math.cos(p3 * 0.09) * 0.07 + 0.68, math.sin(p3 * 0.12) * 0.07 + 0.62)
		end)
		starLayer(bgStyle, count(70), p2 and 1 or 2, 0, 0.25, 0.8) -- inferred equivalent call
		spiral(bgStyle, p2 and 40 or 150, 2, p2)

		if not p2 then
			shootingStars(bgStyle, 6)
		end

		vignette(bgStyle, 0.4)
	elseif style == "vip" then
		baseGradient(bgStyle, {
			{ 0, v14.c2 },
			{ 0.45, v14.c1 },
			{ 1, shade(v14.c1, 0.4) }
		})
		drifters(bgStyle, p2 and 2 or 4, {
			colors = { rgb(200, 140, 40), rgb(255, 190, 80) }, -- inferred equivalent call
			size = { 0.4, 0.7 },
			op = 0.12,
			vx = 0.002,
			sway = 0.08
		})

		for k, v16 in p2 and {
			{ 0.2, 20 },
			{ 0.8, -20 }
		} or {
			{ 0.12, 24 },
			{ 0.38, 10 },
			{ 0.62, -10 },
			{ 0.88, -24 }
		} do
			local spot2 = Instance.new("Frame")
			spot2.Name = "Spot"
			spot2.BackgroundTransparency = 1
			spot2.AnchorPoint = Vector2.new(0.5, 0)
			spot2.Position = UDim2.fromScale(v16[1], -0.08)
			spot2.Size = UDim2.fromScale(0.16, 1.5)
			spot2.ZIndex = 2
			spot2.Parent = bgStyle

			for k2, v17 in {
				{ 1, 0.93 },
				{ 0.6, 0.89 },
				{ 0.25, 0.84 }
			} do
				local backgroundColor = rgb(255, 214, 130) -- inferred equivalent call
				local strip = Instance.new("Frame")
				strip.Name = "Strip"
				strip.BorderSizePixel = 0
				strip.Size = UDim2.fromScale(1, 1)
				strip.BackgroundColor3 = backgroundColor
				strip.ZIndex = 2
				strip.Parent = spot2

				strip.AnchorPoint = Vector2.new(0.5, 0)
				strip.Position = UDim2.fromScale(0.5, 0)
				strip.Size = UDim2.fromScale(v17[1], 1)
				local uiGradient = Instance.new("UIGradient")
				uiGradient.Rotation = 90
				uiGradient.Transparency = seqT({
					{ 0, v17[2] },
					{ 0.65, 1 },
					{ 1, 1 }
				})
				uiGradient.Parent = strip
			end

			local v17 = k * 1.7
			local function fn(p3)
				spot2.Rotation = v16[2] + math.sin(p3 * 0.3 + v17) * 7
			end

			animate(spot2, fn) -- inferred equivalent call
		end

		drifters(bgStyle, count(46), { -- inferred equivalent call
			colors = { rgb(255, 214, 100), rgb(255, 240, 190), rgb(232, 170, 50) }, -- inferred equivalent call
			size = p2 and { 0.025, 0.04 } or { 0.005, 0.012 },
			op = 1,
			vy = 0.014,
			sway = 0.02,
			twinkle = 2.2,
			z = 3
		})
		sweep(bgStyle, rgb(255, 214, 120), 9, 0.07) -- inferred equivalent call
		vignette(bgStyle, 0.5)
	elseif style == "snow" then
		baseGradient(bgStyle, {
			{ 0, v14.c1 },
			{ 0.7, v14.c2 },
			{ 1, tint(v14.c2, 0.2) }
		})

		local softDot_2 = softDot(bgStyle, rgb(170, 200, 255), 1.2, 0.2, 2) -- inferred equivalent call
		softDot_2.Position = UDim2.fromScale(0.5, 1.15)

		fallers(bgStyle, {
			n = count(90), -- inferred equivalent call
			size = { p2 and 1 or 2, p2 and 2 or 3 },
			speed = { 0.025, 0.04 },
			drift = 0.15,
			sway = 0.01,
			colors = { color, rgb(220, 232, 255) },
			op = { 0.35, 0.7 },
			z = 2
		})
		fallers(bgStyle, {
			n = count(55), -- inferred equivalent call
			size = { p2 and 2 or 4, p2 and 3 or 7 },
			speed = { 0.05, 0.075 },
			drift = 0.12,
			sway = 0.02,
			colors = { color },
			op = { 0.6, 0.9 },
			z = 3
		})
		fallers(bgStyle, {
			n = count(14), -- inferred equivalent call
			size = { p2 and 3 or 10, p2 and 4 or 16 },
			speed = { 0.1, 0.14 },
			drift = 0.08,
			sway = 0.03,
			colors = { color },
			op = { 0.25, 0.45 },
			z = 3
		})
		vignette(bgStyle, 0.4)
	elseif style == "sakura" then
		baseGradient(bgStyle, {
			{ 0, v14.c1 },
			{ 0.55, rgb(116, 58, 104) },
			{ 1, rgb(214, 124, 152) }
		})
		local softDot_2 = softDot(bgStyle, rgb(255, 176, 200), 1.1, 0.3, 2) -- inferred equivalent call
		softDot_2.Position = UDim2.fromScale(0.5, 1.1)
		drifters(bgStyle, p2 and 1 or 3, {
			colors = { rgb(255, 160, 200) },
			size = { 0.35, 0.55 },
			op = 0.1,
			vx = 0.003,
			sway = 0.08
		})

		blossomBranch(bgStyle, -1, 3)
		blossomBranch(bgStyle, 1, 3)
		fallers(bgStyle, {
			n = count(36), -- inferred equivalent call
			shape = "petal",
			size = { p2 and 3 or 9, p2 and 5 or 14 },
			speed = { 0.035, 0.06 },
			drift = 0.6,
			sway = 0.04,
			spin = 120,
			colors = { rgb(255, 196, 214), rgb(255, 170, 198), rgb(255, 222, 232) }, -- inferred equivalent call
			op = { 0.75, 0.95 },
			z = 3
		})
		fallers(bgStyle, {
			n = count(8), -- inferred equivalent call
			shape = "petal",
			size = { p2 and 5 or 18, p2 and 6 or 26 },
			speed = { 0.07, 0.1 },
			drift = 0.5,
			sway = 0.05,
			spin = 80,
			colors = { rgb(255, 190, 210) },
			op = { 0.3, 0.45 },
			z = 3
		})
		vignette(bgStyle, 0.35)
	elseif style == "synth" then
		baseGradient(bgStyle, {
			{ 0, v14.c1 },
			{ 0.35, rgb(56, 14, 84) },
			{ 0.62, rgb(196, 50, 140) },
			{ 1, rgb(196, 50, 140) }
		})
		local sky = Instance.new("Frame")
		sky.Name = "Sky"
		sky.BorderSizePixel = 0
		sky.Size = UDim2.fromScale(1, 1)
		sky.BackgroundColor3 = color
		sky.ZIndex = 2
		sky.Parent = bgStyle

		sky.BackgroundTransparency = 1
		starLayer(sky, count(60), p2 and 1 or 2, 0.001, 0.2, 0.7) -- inferred equivalent call

		local v16 = softDot(sky, rgb(255, 90, 170), 0.85, 0.3, 2) -- inferred equivalent call
		v16.SizeConstraint = Enum.SizeConstraint.RelativeYY
		v16.Position = UDim2.fromScale(0.5, 0.47)
		local sun = Instance.new("Frame")
		sun.Name = "Sun"
		sun.BorderSizePixel = 0
		sun.Size = UDim2.fromScale(1, 1)
		sun.BackgroundColor3 = color
		sun.ZIndex = 3
		sun.Parent = sky

		sun.AnchorPoint = Vector2.new(0.5, 0.5)
		sun.SizeConstraint = Enum.SizeConstraint.RelativeYY
		sun.Size = UDim2.fromScale(0.5, 0.5)
		sun.Position = UDim2.fromScale(0.5, 0.49)
		roundify(sun) -- inferred equivalent call
		local v17 = gradient(sun, {
			{ 0, rgb(255, 236, 120) },
			{ 0.45, rgb(255, 150, 90) },
			{ 1, rgb(255, 50, 160) }
		}, 90)
		animate(sun, function(p3) -- inferred equivalent call
			local v18 = p3 * 0.03 % 0.1
			local v19 = {
				{ 0, 0 }
			}

			for i = 0, 6 do
				local v20 = i * 0.1 + 0.31999999999999995 + v18
				local v21 = 0.003 + (v20 - 0.42) * 0.075

				if not (v20 - v21 > 0.42 and v20 + v21 + 0.004 < 1 and #v19 < 17) then
					continue
				end

				table.insert(v19, { v20 - v21 - 0.004, 0 })
				table.insert(v19, { v20 - v21, 1 })
				table.insert(v19, { v20 + v21, 1 })
				table.insert(v19, { v20 + v21 + 0.004, 0 })
			end

			table.insert(v19, { 1, 0 })
			v17.Transparency = seqT(v19)
		end)
		local floor = Instance.new("Frame")
		floor.Name = "Floor"
		floor.BorderSizePixel = 0
		floor.Size = UDim2.fromScale(1, 1)
		floor.BackgroundColor3 = color
		floor.ZIndex = 3
		floor.Parent = bgStyle

		floor.Position = UDim2.fromScale(0, 0.62)
		floor.Size = UDim2.fromScale(1, 0.38)
		gradient(floor, {
			{ 0, rgb(46, 10, 64) },
			{ 1, rgb(10, 2, 22) }
		}, 90)
		local backgroundColor = rgb(255, 80, 200) -- inferred equivalent call
		local horizonGlow = Instance.new("Frame")
		horizonGlow.Name = "HorizonGlow"
		horizonGlow.BorderSizePixel = 0
		horizonGlow.Size = UDim2.fromScale(1, 1)
		horizonGlow.BackgroundColor3 = backgroundColor
		horizonGlow.ZIndex = 3
		horizonGlow.Parent = bgStyle

		horizonGlow.Position = UDim2.fromScale(0, 0.55)
		horizonGlow.Size = UDim2.fromScale(1, 0.07)
		local uiGradient = Instance.new("UIGradient")
		uiGradient.Rotation = 90
		uiGradient.Transparency = seqT({
			{ 0, 1 },
			{ 1, 0.55 }
		})
		uiGradient.Parent = horizonGlow
		local backgroundColor3 = rgb(255, 96, 222) -- inferred equivalent call
		local backgroundColor4 = rgb(255, 150, 230) -- inferred equivalent call
		local horizon = Instance.new("Frame")
		horizon.Name = "Horizon"
		horizon.BorderSizePixel = 0
		horizon.Size = UDim2.fromScale(1, 1)
		horizon.BackgroundColor3 = backgroundColor4
		horizon.ZIndex = 3
		horizon.Parent = floor

		horizon.Size = UDim2.new(1, 0, 0, p2 and 1 or 2)
		local v18 = {}

		for i = 1, p2 and 7 or 14 do
			local hLine = Instance.new("Frame")
			hLine.Name = "HLine"
			hLine.BorderSizePixel = 0
			hLine.Size = UDim2.fromScale(1, 1)
			hLine.BackgroundColor3 = backgroundColor3
			hLine.ZIndex = 3
			hLine.Parent = floor

			hLine.AnchorPoint = Vector2.new(0, 0.5)
			table.insert(v18, hLine)
		end

		local v19 = {}

		for i = -12, 12 do
			local vLine = Instance.new("Frame")
			vLine.Name = "VLine"
			vLine.BorderSizePixel = 0
			vLine.Size = UDim2.fromScale(1, 1)
			vLine.BackgroundColor3 = backgroundColor3
			vLine.ZIndex = 3
			vLine.Parent = floor

			vLine.AnchorPoint = Vector2.new(0.5, 0.5)
			local uiGradient2 = Instance.new("UIGradient")
			uiGradient2.Transparency = seqT({
				{ 0, 1 },
				{ 1, 0.15 }
			})
			uiGradient2.Parent = vLine
			table.insert(v19, { f = vLine, k = i })
		end

		local function layoutGrid()
			local absoluteSize = floor.AbsoluteSize

			for k, v20 in v19 do
				local vector2 = Vector2.new(absoluteSize.X * 0.5, 0)
				local vector2_2 = Vector2.new(absoluteSize.X * (0.5 + v20.k * 0.16), absoluteSize.Y)
				local v21 = vector2_2 - vector2
				v20.f.Position = UDim2.fromOffset((vector2.X + vector2_2.X) / 2, (vector2.Y + vector2_2.Y) / 2)
				v20.f.Size = UDim2.fromOffset(v21.Magnitude, p2 and 1 or 2)
				v20.f.Rotation = math.deg((math.atan2(v21.Y, v21.X)))
			end
		end
		floor:GetPropertyChangedSignal("AbsoluteSize"):Connect(layoutGrid)
		layoutGrid()
		task.defer(layoutGrid)
		animate(floor, function(p3) -- inferred equivalent call
			local v20 = p3 * 0.5 % 1

			for k, v21 in v18 do
				local v22 = 1 / (1 + (k - v20) * 0.55)
				v21.Position = UDim2.fromScale(0, v22)
				v21.Size = UDim2.new(1, 0, 0, (math.max(1, (p2 and 1 or 3) * v22)))
				v21.BackgroundTransparency = 1 - (0.15 + 0.85 * v22)
			end
		end)
		vignette(bgStyle, 0.4)
	elseif style == "storm" then
		baseGradient(bgStyle, {
			{ 0, v14.c1 },
			{ 0.65, v14.c2 },
			{ 1, shade(v14.c2, 0.4) }
		})
		local sky = Instance.new("Frame")
		sky.Name = "Sky"
		sky.BorderSizePixel = 0
		sky.Size = UDim2.fromScale(1, 1)
		sky.BackgroundColor3 = color
		sky.ZIndex = 2
		sky.Parent = bgStyle

		sky.BackgroundTransparency = 1
		local bolts = Instance.new("Frame")
		bolts.Name = "Bolts"
		bolts.BorderSizePixel = 0
		bolts.Size = UDim2.fromScale(1, 1)
		bolts.BackgroundColor3 = color
		bolts.ZIndex = 2
		bolts.Parent = sky

		bolts.BackgroundTransparency = 1
		bolts.Visible = false
		local backgroundColor = rgb(54, 62, 82) -- inferred equivalent call
		local v16 = rgb(156, 168, 204) -- inferred equivalent call
		local v17 = {}
		local v18 = {}

		for i = 1, p2 and 3 or 6 do
			local cloud = Instance.new("Frame")
			cloud.Name = "Cloud"
			cloud.BackgroundTransparency = 1
			cloud.AnchorPoint = Vector2.new(0.5, 0.5)
			cloud.Size = UDim2.fromScale(0.45 + random:NextNumber() * 0.3, 0.2)
			cloud.ZIndex = 3
			cloud.Parent = sky

			for j = 1, 5 do
				local v19 = 0.26 + random:NextNumber() * 0.2
				local frame2 = Instance.new("Frame")
				frame2.BackgroundTransparency = 1
				frame2.AnchorPoint = Vector2.new(0.5, 0.5)
				frame2.Position = UDim2.fromScale(
					(j - 0.5) / 5 + (random:NextNumber() - 0.5) * 0.1,
					0.5 + (random:NextNumber() - 0.5) * 0.4
				)
				frame2.SizeConstraint = Enum.SizeConstraint.RelativeXX
				frame2.Size = UDim2.fromScale(v19, v19 * 0.62)
				frame2.ZIndex = 3
				frame2.Parent = cloud

				for k = 1, 6 do
					local v20 = 1 - (k - 1) * 0.15
					local frame3 = Instance.new("Frame")
					frame3.BorderSizePixel = 0
					frame3.AnchorPoint = Vector2.new(0.5, 0.5)
					frame3.Position = UDim2.fromScale(0.5, 0.5)
					frame3.Size = UDim2.fromScale(v20, v20)
					frame3.BackgroundColor3 = backgroundColor
					frame3.BackgroundTransparency = 0.88
					frame3.ZIndex = 3
					roundify(frame3) -- inferred equivalent call
					frame3.Parent = frame2
					table.insert(v17, frame3)
				end
			end

			table.insert(v18, {
				f = cloud,
				x0 = random:NextNumber() * 1.6,
				y = 0.04 + random:NextNumber() * 0.3,
				sp = 0.003 + random:NextNumber() * 0.005
			})
		end

		for i = 1, 2 do
			for j = 1, 4 do
				local hill = Instance.new("Frame")
				hill.Name = "Hill"
				hill.BorderSizePixel = 0
				hill.AnchorPoint = Vector2.new(0.5, 0)
				hill.SizeConstraint = Enum.SizeConstraint.RelativeXX
				local v19 = 0.4 + random:NextNumber() * 0.3
				hill.Size = UDim2.fromScale(v19, v19)
				hill.Position = UDim2.fromScale(
					(j - 0.5) / 4 + (random:NextNumber() - 0.5) * 0.12 + (i - 1) * 0.12,
					i == 1 and 0.8 + random:NextNumber() * 0.05 or 0.87 + random:NextNumber() * 0.04
				)
				hill.BackgroundColor3 = i == 1 and rgb(24, 29, 42) or rgb(13, 15, 23) -- inferred equivalent call
				hill.ZIndex = 3
				roundify(hill) -- inferred equivalent call
				hill.Parent = bgStyle
			end
		end

		local backgroundColor3 = rgb(200, 214, 255) -- inferred equivalent call
		local flash = Instance.new("Frame")
		flash.Name = "Flash"
		flash.BorderSizePixel = 0
		flash.Size = UDim2.fromScale(1, 1)
		flash.BackgroundColor3 = backgroundColor3
		flash.ZIndex = 3
		flash.Parent = bgStyle

		flash.BackgroundTransparency = 1
		fallers(bgStyle, {
			n = count(120), -- inferred equivalent call
			shape = "streak",
			size = { p2 and 6 or 16, p2 and 10 or 30 },
			speed = { 0.9, 1.3 },
			drift = -0.12,
			angle = 10,
			colors = { rgb(170, 190, 230) },
			op = { 0.2, 0.45 },
			z = 3
		})
		local v19 = os.clock() + 2 + random:NextNumber() * 2
		local v20 = -100
		local v21 = -1
		local function fn(p3)
			if v19 <= p3 then
				v20 = p3
				v19 = p3 + 5 + random:NextNumber() * 5
				bolts:ClearAllChildren()
				local absoluteSize = bgStyle.AbsoluteSize
				local v22 = absoluteSize.X * (0.15 + random:NextNumber() * 0.7)
				skyBolt(
					bolts,
					Vector2.new(v22, -10),
					Vector2.new(
						v22 + (random:NextNumber() - 0.5) * absoluteSize.X * 0.2,
						absoluteSize.Y * (0.45 + random:NextNumber() * 0.3)
					),
					p2 and 1 or 2.5
				)
			end

			local v22 = p3 - v20
			local v23

			if not (v22 < 0.7) then
				v23 = 0
			elseif v22 < 0.07 then
				v23 = 1
			elseif v22 < 0.13 then
				v23 = 0.25
			elseif v22 < 0.2 then
				v23 = 0.8
			else
				v23 = math.max(0, 0.8 * (1 - (v22 - 0.2) / 0.5))
			end

			flash.BackgroundTransparency = 1 - v23 * 0.2
			bolts.Visible = v22 < 0.45 and v23 > 0.2

			for k, v24 in v18 do
				v24.f.Position = UDim2.fromScale((v24.x0 + p3 * v24.sp) % 1.6 - 0.3, v24.y)
			end

			if math.abs(v23 - v21) > 0.02 then
				v21 = v23
				local lerped = backgroundColor:Lerp(v16, v23)

				for k, v24 in v17 do
					v24.BackgroundColor3 = lerped
				end
			end
		end

		animate(flash, fn) -- inferred equivalent call
		vignette(bgStyle, 0.45)
	end

	return bgStyle
end

local v14 = nil
local object4 = setmetatable({}, { __mode = "k" })
local object5 = setmetatable({}, { __mode = "k" })
local object6 = setmetatable({}, { __mode = "k" })
local folderSet = {}

local v15 = { Dock = "Nav", Panel = "Side", RightCard = "Root" }

local object7 = setmetatable({}, { __mode = "k" })

local function tinted(p) -- 1 equivalent call inferred from this helper
	if not v14 then
		return p
	end

	local hsv, v16, v17 = p:ToHSV()

	if v16 > 0.16 or v17 > 0.36 or v17 < 0.03 then
		return p
	end

	return Color3.fromHSV(v14.h, math.min(1, v14.s), (math.clamp(v17 * v14.vk, 0, 1)))
end

local function noTint(guiObject): boolean
	while guiObject and guiObject:IsA("GuiObject") do
		if guiObject:GetAttribute("NoTint") then
			return true
		end

		guiObject = guiObject.Parent
	end

	return false
end

local function retint(guiObject)
	if not guiObject:IsA("GuiObject") or noTint(guiObject) then
		return
	end

	if object4[guiObject] == nil then
		object4[guiObject] = guiObject.BackgroundColor3
	end

	local backgroundColor = tinted(object4[guiObject]) -- inferred equivalent call
	object5[guiObject] = backgroundColor
	guiObject.BackgroundColor3 = backgroundColor

	if not object6[guiObject] then
		object6[guiObject] = true
		guiObject:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
			if guiObject.BackgroundColor3 == object5[guiObject] then
				return
			end

			object4[guiObject] = guiObject.BackgroundColor3
			retint(guiObject)
		end)
	end

	local v16 = v15[guiObject.Name]

	if v16 and guiObject.Parent and guiObject.Parent.Name == v16 then
		if object7[guiObject] == nil then
			object7[guiObject] = guiObject.BackgroundTransparency
		end

		guiObject.BackgroundTransparency = v14 and math.min(object7[guiObject], 0.05) or object7[guiObject]
	end
end

function Cosmetics2.tintUI(items, p)
	local v16 = Cosmetics.BY_ID[p]

	if v16 and v16.type == "background" and v16.ui then
		local hsv, v17 = v16.ui:ToHSV()
		v14 = {
			h = hsv,
			s = v17 * 0.5,
			vk = 1.12 * (v16.uiv or 1)
		}
	else
		v14 = nil
	end

	for k, folder in items do
		if not folder then
			continue
		end

		retint(folder)

		for i, descendant in folder:GetDescendants() do
			retint(descendant)
		end

		if folderSet[folder] then
			continue
		end

		folderSet[folder] = true
		folder.DescendantAdded:Connect(function(descendant)
			task.defer(function()
				if descendant.Parent then
					retint(descendant)
				end
			end)
		end)
	end
end

local function pick(list) -- 9 equivalent calls inferred from this helper
	return list[random:NextInteger(1, #list)]
end

local function rand(p, p2) -- 90 equivalent calls inferred from this helper
	return p + random:NextNumber() * (p2 - p)
end

local function polar(at, p, p2) -- 1 equivalent call inferred from this helper
	return at + Vector2.new(math.cos(p), (math.sin(p))) * p2
end

local function corner(parent2, udim) -- 14 equivalent calls inferred from this helper
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = udim or UDim.new(1, 0)
	uiCorner.Parent = parent2
end

local function easeOut(p) -- 6 equivalent calls inferred from this helper
	return 1 - (1 - p) ^ 3
end

local function particle(parent2, data)
	local shape = data.shape or "dot"
	local fx

	if shape == "icon" then
		fx = UI.icon(data.icon, 10, data.color, { Name = "Fx" })
	elseif shape == "bat" or shape == "ghost" then
		fx = shape == "bat" and makeBat(data.color or rgb(36, 24, 46)) or makeGhost(data.color or color) -- inferred equivalent call
		fx.Name = "Fx"
	else
		fx = Instance.new("Frame")
		fx.Name = "Fx"
		fx.BorderSizePixel = 0
		fx.BackgroundColor3 = data.color or color

		if shape == "dot" or shape == "streak" then
			corner(fx) -- inferred equivalent call
		elseif shape == "square" or shape == "paper" then
			corner(fx, UDim.new(0.2, 0)) -- inferred equivalent call
		elseif shape == "glow" then
			fx.BackgroundTransparency = 1

			for k, v16 in {
				{ 1, 0.74 },
				{ 0.66, 0.48 },
				{ 0.36, 0.08 }
			} do
				local frame2 = Instance.new("Frame")
				frame2.Name = "G" .. k
				frame2.BorderSizePixel = 0
				frame2.AnchorPoint = Vector2.new(0.5, 0.5)
				frame2.Position = UDim2.fromScale(0.5, 0.5)
				frame2.Size = UDim2.fromScale(v16[1], v16[1])
				frame2.BackgroundColor3 = k == 3 and tint(data.color or color, 0.45) or data.color or color -- inferred equivalent call
				frame2:SetAttribute("Base", v16[2])
				corner(frame2) -- inferred equivalent call
				frame2.Parent = fx
			end
		elseif shape == "shard" then
			corner(fx, UDim.new(0.08, 0)) -- inferred equivalent call
			local uiStroke = Instance.new("UIStroke")
			uiStroke.Color = color
			uiStroke.Transparency = 0.3
			uiStroke.Parent = fx
		elseif shape == "bubble" then
			corner(fx) -- inferred equivalent call
			local uiStroke = Instance.new("UIStroke")
			uiStroke.Color = tint(data.color or color, 0.45) -- inferred equivalent call
			uiStroke.Thickness = 1.5
			uiStroke.Parent = fx
			local hi = Instance.new("Frame")
			hi.Name = "Hi"
			hi.BorderSizePixel = 0
			hi.AnchorPoint = Vector2.new(0.5, 0.5)
			hi.Position = UDim2.fromScale(0.32, 0.3)
			hi.Size = UDim2.fromScale(0.26, 0.18)
			hi.Rotation = -35
			hi.BackgroundColor3 = color
			corner(hi) -- inferred equivalent call
			hi.Parent = fx
		elseif shape == "coin" then
			corner(fx) -- inferred equivalent call
			local face = Instance.new("Frame")
			face.Name = "Face"
			face.BorderSizePixel = 0
			face.AnchorPoint = Vector2.new(0.5, 0.5)
			face.Position = UDim2.fromScale(0.5, 0.5)
			face.Size = UDim2.fromScale(0.66, 0.66)
			face.BackgroundColor3 = shade(data.color or color, 0.2) -- inferred equivalent call
			corner(face) -- inferred equivalent call
			face.Parent = fx
			local hi = Instance.new("Frame")
			hi.Name = "Hi"
			hi.BorderSizePixel = 0
			hi.AnchorPoint = Vector2.new(0.5, 0.5)
			hi.Position = UDim2.fromScale(0.34, 0.3)
			hi.Size = UDim2.fromScale(0.22, 0.22)
			hi.BackgroundColor3 = color
			corner(hi) -- inferred equivalent call
			hi.Parent = fx
		end
	end

	fx.AnchorPoint = Vector2.new(0.5, 0.5)
	fx.ZIndex = data.z or 10
	local v16 = data.at
	local v17 = data.vel or Vector2.zero
	local rot = data.rot or random:NextInteger(0, 359)
	local alpha = data.alpha or 0
	local alpha2 = data.alpha2 or 1
	local fadeAt = data.fadeAt or 0.45
	local function setAlpha(p)
		if shape == "icon" then
			fx.ImageTransparency = p
		elseif shape == "bat" or shape == "ghost" then
			setSpookyAlpha(fx, p)
		elseif shape == "glow" then
			for i, child in fx:GetChildren() do
				child.BackgroundTransparency = 1 - (1 - child:GetAttribute("Base")) * (1 - p)
			end
		elseif shape == "bubble" then
			fx.BackgroundTransparency = 0.8 + 0.2 * p
			fx.UIStroke.Transparency = 0.1 + 0.9 * p
			fx.Hi.BackgroundTransparency = 0.2 + 0.8 * p
		elseif shape == "coin" then
			fx.BackgroundTransparency = p
			fx.Face.BackgroundTransparency = p
			fx.Hi.BackgroundTransparency = 0.3 + 0.7 * p
		else
			fx.BackgroundTransparency = p
			local uiStroke = fx:FindFirstChildOfClass("UIStroke")

			if uiStroke then
				uiStroke.Transparency = 0.3 + 0.7 * p
			end
		end
	end
	local function start()
		if not parent2.Parent then
			return
		end

		fx.Position = UDim2.fromOffset(v16.X, v16.Y)
		fx.Size = UDim2.fromOffset(data.size, data.size)
		setAlpha(alpha)
		fx.Parent = parent2
		local now = os.clock()
		local v18 = now
		local function fn(p)
			local v19 = math.min(p - v18, 0.05)
			v18 = p
			local v20 = (p - now) / data.life

			if v20 >= 1 then
				unanimate(fx) -- inferred equivalent call
				fx:Destroy()

				if data.done then
					data.done(v16)
				end
			else
				if data.orbit then
					local orbit = data.orbit
					local v21 = orbit.r0 * (1 - v20) ^ 1.6
					local v22 = orbit.a0 + orbit.turns * 3.141592653589793 * 2 * v20 ^ 1.4
					local v23 = polar(data.at, v22, v21) -- inferred equivalent call
					v17 = (v23 - v16) / math.max(v19, 0.001)
					v16 = v23
				else
					if data.gravity then
						v17 += data.gravity * v19
					end

					if data.drag then
						v17 *= math.max(0, 1 - data.drag * v19)
					end

					v16 += v17 * v19
				end

				local v21 = data.size + ((data.size2 or data.size) - data.size) * v20

				if shape == "streak" then
					local v22 = v21 + v17.Magnitude * (data.stretch or 0.03)
					fx.Size = UDim2.fromOffset(v22, (math.max(1.5, v21 * 0.38)))

					if v17.Magnitude > 1 then
						fx.Rotation = math.deg((math.atan2(v17.Y, v17.X)))
					end
				elseif shape == "paper" then
					fx.Size = UDim2.fromOffset(
						v21 * math.max(0.15, (math.abs((math.cos((p - now) * 11 + rot))))),
						v21 * 0.55
					)
					rot += (data.spin or 0) * v19
					fx.Rotation = rot
				elseif shape == "coin" then
					fx.Size = UDim2.fromOffset(
						v21 * math.max(
							0.1,
							(math.abs((math.cos((p - now) * (data.flip or 9) * 3.141592653589793 + rot))))
						),
						v21
					)
					fx.Rotation = 0
				elseif shape == "bubble" then
					fx.Size = UDim2.fromOffset(v21, v21)
					fx.UIStroke.Thickness = math.max(1, v21 * 0.07)
				elseif shape == "pixel" then
					fx.Size = UDim2.fromOffset(v21, v21)
					fx.Rotation = 0
				else
					fx.Size = UDim2.fromOffset(v21, v21)
					rot += (data.spin or 0) * v19
					fx.Rotation = rot
				end

				fx.Position = UDim2.fromOffset(v16.X, v16.Y)
				setAlpha(alpha + (alpha2 - alpha) * math.clamp((v20 - fadeAt) / math.max(0.01, 1 - fadeAt), 0, 1))

				if data.update then
					data.update(fx, v20, v16)
				end
			end
		end

		animate(fx, fn) -- inferred equivalent call
	end

	if data.delay and data.delay > 0 then
		task.delay(data.delay, start)
	else
		start()
	end

	return fx
end

local function glow(parent2, at, size, color3, life, options)
	local v16 = options or {}
	return particle(parent2, {
		at = at,
		shape = "glow",
		color = color3,
		size = v16.from or size * 0.3,
		size2 = size,
		life = life,
		delay = v16.delay,
		alpha = v16.alpha or 0,
		fadeAt = v16.fadeAt or 0.2,
		z = 9
	})
end

local function shock(parent2, p, color3, p2, p3, p4, p5, duration)
	local fx = Instance.new("Frame")
	fx.Name = "Fx"
	fx.BackgroundTransparency = 1
	fx.AnchorPoint = Vector2.new(0.5, 0.5)
	fx.Position = UDim2.fromOffset(p.X, p.Y)
	fx.ZIndex = 10
	corner(fx) -- inferred equivalent call
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = color3
	uiStroke.Parent = fx
	local function start()
		if not parent2.Parent then
			return
		end

		fx.Size = UDim2.fromOffset(p2, p2)
		fx.Parent = parent2
		local now = os.clock()
		animate(fx, function(p6) -- inferred equivalent call
			local v16 = (p6 - now) / p5

			if v16 >= 1 then
				unanimate(fx) -- inferred equivalent call
				fx:Destroy()
			else
				local v17 = easeOut(v16) -- inferred equivalent call
				local v18 = p2 + (p3 - p2) * v17
				fx.Size = UDim2.fromOffset(v18, v18)
				uiStroke.Thickness = math.max(1, p4 * (1 - v16))
				uiStroke.Transparency = v16 ^ 1.5
			end
		end)
	end

	if duration and duration > 0 then
		task.delay(duration, start)
	else
		start()
	end
end

local function flash(parent2, backgroundColor, backgroundTransparency, p)
	local fx = Instance.new("Frame")
	fx.Name = "Fx"
	fx.BorderSizePixel = 0
	fx.Size = UDim2.fromScale(1, 1)
	fx.BackgroundColor3 = backgroundColor
	fx.BackgroundTransparency = backgroundTransparency
	fx.ZIndex = 8
	fx.Parent = parent2
	UI.tween(fx, p, { BackgroundTransparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out).Completed:Connect(function()
		fx:Destroy()
	end)
end

local function rays(parent2, p, backgroundColor, p2, p3, p4, p5, value)
	local v16 = random:NextNumber() * 360

	for i = 1, p2 do
		local fx = Instance.new("Frame")
		fx.Name = "Fx"
		fx.BorderSizePixel = 0
		fx.AnchorPoint = Vector2.new(0, 0.5)
		fx.Position = UDim2.fromOffset(p.X, p.Y)
		fx.BackgroundColor3 = backgroundColor
		fx.ZIndex = 9
		corner(fx) -- inferred equivalent call
		local uiGradient = Instance.new("UIGradient")
		uiGradient.Transparency = NumberSequence.new(0, 1)
		uiGradient.Parent = fx
		local v17 = v16 + i / p2 * 360 + rand(-8, 8) -- inferred equivalent call
		local v18 = p3 * rand(0.6, 1.1) -- inferred equivalent call

		fx.Parent = parent2
		local now = os.clock()
		animate(fx, function(p6) -- inferred equivalent call
			local v19 = (p6 - now) / p5

			if v19 >= 1 then
				unanimate(fx) -- inferred equivalent call
				fx:Destroy()
			else
				fx.Rotation = v17 + (value or 0) * v19
				fx.Size = UDim2.fromOffset(v18 * easeOut(math.min(1, v19 * 2.2)), p4 * (1 - v19 * 0.6)) -- inferred equivalent call
				fx.BackgroundTransparency = v19 ^ 2
			end
		end)
	end
end

local function bolt(parent2, p, p2, backgroundColor3, p3, p4)
	local fx = Instance.new("Frame")
	fx.Name = "Fx"
	fx.BackgroundTransparency = 1
	fx.Size = UDim2.fromScale(1, 1)
	fx.ZIndex = 11
	fx.Parent = parent2
	local function seg(p5, p6, p7, backgroundColor, backgroundTransparency, zIndex)
		local v16 = p6 - p5
		local frame2 = Instance.new("Frame")
		frame2.BorderSizePixel = 0
		frame2.AnchorPoint = Vector2.new(0.5, 0.5)
		frame2.Position = UDim2.fromOffset((p5.X + p6.X) / 2, (p5.Y + p6.Y) / 2)
		frame2.Size = UDim2.fromOffset(v16.Magnitude + p7 * 0.6, p7)
		frame2.Rotation = math.deg((math.atan2(v16.Y, v16.X)))
		frame2.BackgroundColor3 = backgroundColor
		frame2.BackgroundTransparency = backgroundTransparency
		frame2.ZIndex = zIndex
		frame2:SetAttribute("Base", backgroundTransparency)
		corner(frame2) -- inferred equivalent call
		frame2.Parent = fx
	end
	local function path(p5, p6, p7, p8)
		local v16 = p6 - p5
		local unit = Vector2.new(-v16.Y, v16.X).Unit
		local result = { p5 }

		for i = 1, p7 - 1 do
			local v17 = p5 + v16 * (i / p7)
			table.insert(result, v17 + unit * rand(-p8, p8)) -- inferred equivalent call
		end

		table.insert(result, p6)
		return result
	end

	local v16 = path(p, p2, 8, (p2 - p).Magnitude * 0.09)

	for i = 1, #v16 - 1 do
		seg(v16[i], v16[i + 1], p3 * 3.2, backgroundColor3, 0.7, 11)
		seg(v16[i], v16[i + 1], p3, tint(backgroundColor3, 0.7), 0, 12) -- inferred equivalent call
	end

	local v17 = v16[random:NextInteger(3, 5)]
	local v18 = path(
		v17,
		v17 + (p2 - p).Unit:Lerp(Vector2.new(rand(-1, 1), 0.3), 0.6) * (p2 - p).Magnitude * 0.3, -- inferred equivalent call
		4,
		(p2 - p).Magnitude * 0.05
	)

	for i = 1, #v18 - 1 do
		seg(v18[i], v18[i + 1], p3 * 0.6, tint(backgroundColor3, 0.5), 0.15, 12) -- inferred equivalent call
	end

	local now = os.clock()
	animate(fx, function(p5) -- inferred equivalent call
		local v19 = (p5 - now) / p4

		if v19 >= 1 then
			unanimate(fx) -- inferred equivalent call
			fx:Destroy()
		else
			local v20 = v19 < 0.6 and random:NextNumber() < 0.25 and 0.6 or 0

			for i, child in fx:GetChildren() do
				child.BackgroundTransparency = math.min(1, child:GetAttribute("Base") + v19 ^ 2 + v20)
			end
		end
	end)
end

local function burst(parent2, p, p2, list, p3, p4, options)
	local v16 = options or {}

	for i = 1, p3 do
		local v17

		if v16.angle then
			v17 = v16.angle + rand(-v16.spread, v16.spread) or random:NextNumber() * 3.141592653589793 * 2 -- inferred equivalent call
		else
			v17 = random:NextNumber() * 3.141592653589793 * 2
		end

		local v18 = p2 * rand(p4 * 0.5, p4) -- inferred equivalent call
		particle(parent2, {
			at = p + Vector2.new(rand(-1, 1), rand(-1, 1)) * p2 * (v16.jitter or 0.1), -- inferred equivalent call
			vel = Vector2.new(math.cos(v17), (math.sin(v17))) * v18,
			gravity = Vector2.new(0, p2 * (v16.gravity or 0)),
			drag = v16.drag or 2.5,
			life = rand(v16.life or 0.5, (v16.life or 0.5) * 1.5), -- inferred equivalent call
			size = p2 * (v16.size or 0.1) * rand(0.7, 1.3), -- inferred equivalent call
			size2 = p2 * (v16.size2 or 0.02),
			color = pick(list), -- inferred equivalent call
			shape = v16.shape or "streak",
			stretch = v16.stretch,
			spin = v16.spin,
			fadeAt = v16.fadeAt or 0.4,
			delay = v16.delay,
			icon = v16.icon
		})
	end
end

local effects = {}

function effects.burst(parent2, p, p2, p3, p4, p5)
	local v16 = p4 and 2.2 or 1
	glow(parent2, p, p2 * 1.4 * v16, p3.colors[1], 0.35)
	burst(parent2, p, p2, p3.colors, p4 and 46 or 16, 9 * v16, {
		gravity = 9,
		drag = 2.2,
		life = 0.45,
		size = 0.1,
		stretch = 0.035
	})

	for i = 1, p4 and 16 or 6 do
		particle(parent2, {
			at = p + Vector2.new(rand(-0.4, 0.4), rand(-0.3, 0.3)) * p2 * v16, -- inferred equivalent call
			vel = Vector2.new(rand(-0.5, 0.5), rand(-1.6, -0.6)) * p2, -- inferred equivalent call
			drag = 0.6,
			life = rand(0.7, 1.2), -- inferred equivalent call
			size = p2 * 0.06,
			size2 = p2 * 0.02,
			color = pick(p3.colors), -- inferred equivalent call
			fadeAt = 0.2,
			delay = 0.08
		})
	end

	if p4 then
		shock(parent2, p, p3.colors[1], p2 * 0.3, p2 * 5, p2 * 0.14, 0.6)
		p5.flash(p3.colors[1], 0.75, 0.4)
		p5.shake(p2 * 0.12, 0.35)
	end
end

function effects.puff(parent2, p, p2, p3, p4, p5)
	local v16 = p4 and 2 or 1

	for i = 1, p4 and 26 or 11 do
		local v17 = random:NextNumber() * 3.141592653589793 * 2
		particle(parent2, {
			at = p + Vector2.new(math.cos(v17), (math.sin(v17))) * p2 * 0.15,
			vel = Vector2.new(math.cos(v17), math.sin(v17) * 0.6) * p2 * rand(1, 2.6) * v16 + Vector2.new(0, -p2 * 0.4), -- inferred equivalent call
			drag = 2.8,
			gravity = Vector2.new(0, -p2 * 0.6),
			life = rand(0.7, 1.1) * (p4 and 1.3 or 1), -- inferred equivalent call
			size = p2 * 0.28 * v16,
			size2 = p2 * rand(0.6, 0.9) * v16, -- inferred equivalent call
			color = pick(p3.colors), -- inferred equivalent call
			alpha = 0.2,
			fadeAt = 0.15
		})
	end

	burst(parent2, p, p2, { rgb(150, 140, 128), rgb(110, 102, 94) }, p4 and 16 or 7, 5 * v16, { -- inferred equivalent call
		gravity = 18,
		drag = 0.8,
		life = 0.55,
		size = 0.07,
		size2 = 0.06,
		shape = "square",
		spin = 400,
		fadeAt = 0.6,
		angle = -1.5707963267948966,
		spread = 1.3
	})

	if p4 then
		shock(parent2, p, rgb(220, 214, 204), p2 * 0.4, p2 * 5, p2 * 0.25, 0.7) -- inferred equivalent call
		p5.shake(p2 * 0.15, 0.4)
	end
end

function effects.confetti(parent2, at, p, p2, p3, p4)
	local v16 = p3 and 1.7 or 1
	glow(parent2, at, p * 1.1 * v16, color, 0.25)
	shock(parent2, at, p2.colors[2] or color, p * 0.2, p * 1.6 * v16, p * 0.08, 0.35)

	for i = 1, p3 and 80 or 26 do
		local v17 = -1.5707963267948966 + rand(-1, 1) * (p3 and 1.4 or 1) -- inferred equivalent call
		particle(parent2, {
			at = at,
			vel = Vector2.new(math.cos(v17), (math.sin(v17))) * p * rand(4, 10) * v16, -- inferred equivalent call
			gravity = Vector2.new(0, p * 11),
			drag = 2.4,
			life = rand(0.9, 1.5) * (p3 and 1.4 or 1), -- inferred equivalent call
			size = p * rand(0.12, 0.18), -- inferred equivalent call
			color = pick(p2.colors), -- inferred equivalent call
			shape = "paper",
			spin = rand(-400, 400), -- inferred equivalent call
			fadeAt = 0.7
		})
	end

	if p3 then
		p4.shake(p * 0.08, 0.25)
	end
end

function effects.icons(parent2, at, p, p2, p3, p4)
	local v16 = p3 and 2 or 1
	glow(parent2, at, p * 1.2 * v16, p2.colors[1], 0.4)

	particle(parent2, {
		at = at,
		shape = "icon",
		icon = p2.icon,
		color = p2.colors[1],
		size = p * 0.2,
		size2 = p * 0.9 * v16,
		life = 0.55,
		spin = 0,
		rot = 0,
		fadeAt = 0.5,
		update = function(p5, p6)
			p5.Rotation = math.sin(p6 * 12) * 10 * (1 - p6)
		end
	})

	for i = 1, p3 and 22 or 8 do
		local v17 = rand(1.5, 3) -- inferred equivalent call
		local v18 = random:NextNumber() * 6
		particle(parent2, {
			at = at + Vector2.new(rand(-0.3, 0.3), rand(-0.2, 0.2)) * p * v16, -- inferred equivalent call
			vel = Vector2.new(rand(-1.8, 1.8) * v16, -rand(2, 4.5) * v16) * p, -- inferred equivalent call
			drag = 1.6,
			gravity = Vector2.new(0, -p * 0.6),
			life = rand(0.9, 1.3) * (p3 and 1.3 or 1), -- inferred equivalent call
			size = p * rand(0.2, 0.32), -- inferred equivalent call
			size2 = p * 0.12,
			color = pick(p2.colors), -- inferred equivalent call
			shape = "icon",
			icon = p2.icon,
			rot = rand(-20, 20), -- inferred equivalent call
			fadeAt = 0.5,
			delay = i % 4 * 0.04,
			update = function(self, p5)
				self.Rotation = math.sin(p5 * v17 * 4 + v18) * 18
			end
		})
	end

	if p3 then
		shock(parent2, at, p2.colors[1], p * 0.4, p * 5, p * 0.14, 0.7)
		p4.flash(p2.colors[1], 0.8, 0.4)
		p4.shake(p * 0.08, 0.3)
	end
end

function effects.bats(parent2, at, p, p2, p3, p4)
	local v16 = p3 and 1.8 or 1
	glow(parent2, at, p * 1.3 * v16, p2.colors[2], 0.4)

	for i = 1, p3 and 10 or 5 do
		local v17 = random:NextNumber() * 3.141592653589793 * 2
		particle(parent2, {
			at = at,
			vel = Vector2.new(math.cos(v17), (math.sin(v17))) * p * rand(0.6, 1.6) * v16, -- inferred equivalent call
			drag = 2.5,
			life = rand(0.6, 0.9), -- inferred equivalent call
			size = p * 0.3 * v16,
			size2 = p * 0.7 * v16,
			color = p2.colors[3],
			alpha = 0.35,
			fadeAt = 0.1
		})
	end

	for i = 1, p3 and 24 or 9 do
		local v17 = -1.5707963267948966 + rand(-1.25, 1.25) -- inferred equivalent call

		local v18 = random:NextNumber() * 6
		local v19 = rand(18, 26) -- inferred equivalent call
		particle(parent2, {
			at = at + Vector2.new(rand(-0.15, 0.15), rand(-0.1, 0.1)) * p, -- inferred equivalent call
			vel = Vector2.new(math.cos(v17), (math.sin(v17))) * p * rand(3, 6) * v16, -- inferred equivalent call
			drag = 1.2,
			gravity = Vector2.new(0, -p * 1.2),
			life = rand(0.9, 1.3) * (p3 and 1.3 or 1), -- inferred equivalent call
			size = p * rand(0.32, 0.46), -- inferred equivalent call
			size2 = p * 0.3,
			color = p2.colors[1],
			shape = "bat",
			rot = rand(-12, 12), -- inferred equivalent call
			spin = 0,
			fadeAt = 0.6,
			delay = i % 5 * 0.03,
			update = function(instance)
				flapBat(instance, os.clock() * v19 + v18) -- inferred equivalent call
			end
		})
	end

	if p3 then
		shock(parent2, at, p2.colors[2], p * 0.3, p * 4.5, p * 0.14, 0.6)
		p4.flash(p2.colors[3], 0.75, 0.4)
		p4.shake(p * 0.1, 0.35)
	end
end

function effects.ghosts(parent2, p, p2, p3, p4, p5)
	local v16 = p4 and 1.7 or 1
	local v17 = p4 and 9 or 4
	glow(parent2, p, p2 * 1.4 * v16, p3.colors[2], 0.45)
	shock(parent2, p, p3.colors[2], p2 * 0.2, p2 * 1.8 * v16, p2 * 0.07, 0.45)

	for i = 1, v17 do
		local v18 = rand(3, 5) -- inferred equivalent call
		local v19 = random:NextNumber() * 6
		local v20 = (i - (v17 + 1) / 2) * 0.22
		particle(parent2, {
			at = p + Vector2.new(v20 * p2 * v16 * 0.7, rand(-0.1, 0.1) * p2), -- inferred equivalent call
			vel = Vector2.new(v20 * p2 * 1.2, -rand(1.6, 2.8) * p2 * v16), -- inferred equivalent call
			drag = 0.9,
			life = rand(1.1, 1.5) * (p4 and 1.25 or 1), -- inferred equivalent call
			size = p2 * 0.2,
			size2 = p2 * rand(0.55, 0.7) * (p4 and 1.15 or 1), -- inferred equivalent call
			color = p3.colors[1],
			shape = "ghost",
			rot = 0,
			spin = 0,
			alpha = 0.05,
			fadeAt = 0.55,
			delay = (i - 1) * 0.06,
			update = function(p6, p7)
				p6.Rotation = math.sin(p7 * v18 * 3 + v19) * 14
			end
		})
	end

	burst(parent2, p, p2, { p3.colors[2], p3.colors[3] }, p4 and 26 or 10, 4 * v16, {
		gravity = -3,
		drag = 1.6,
		life = 0.8,
		size = 0.08,
		size2 = 0.02,
		shape = "dot",
		fadeAt = 0.3,
		jitter = 0.3
	})

	if p4 then
		p5.flash(p3.colors[2], 0.8, 0.45)
		p5.shake(p2 * 0.08, 0.3)
	end
end

function effects.ring(parent2, p, p2, p3, p4, p5)
	local v16 = p4 and 2.6 or 1
	glow(parent2, p, p2 * 1.3 * v16, p3.colors[1], 0.3)

	for i = 0, p4 and 3 or 1 do
		shock(
			parent2,
			p,
			i % 2 == 0 and p3.colors[1] or color,
			p2 * 0.2,
			p2 * 2.1 * v16,
			p2 * (0.2 - i * 0.03),
			0.5,
			i * 0.09
		)
	end

	burst(parent2, p, p2, { p3.colors[1], color }, p4 and 26 or 12, math.sqrt(v16) * 16, {
		drag = 7,
		life = 0.3,
		size = 0.07,
		stretch = 0.03,
		jitter = 0.3
	})

	if p4 then
		p5.flash(p3.colors[1], 0.7, 0.35)
		p5.shake(p2 * 0.2, 0.45)
	end
end

function effects.lightning(parent2, at, p, p2, p3, p4)
	for i = 1, p3 and 4 or 1 do
		task.delay((i - 1) * 0.11, function()
			if not parent2.Parent then
				return
			end

			local v16 = at + (i == 1 and Vector2.zero or Vector2.new(rand(-1.2, 1.2), rand(-0.6, 0.6)) * p) -- inferred equivalent call
			bolt(
				parent2,
				v16 + Vector2.new(rand(-0.7, 0.7) * p, -p * (p3 and 6 or 2.6)), -- inferred equivalent call
				v16,
				p2.colors[2] or color,
				math.max(2, p * 0.07),
				0.38
			)
			glow(parent2, v16, p * (p3 and 1.8 or 1.2), p2.colors[1], 0.3)
			burst(parent2, v16, p, { p2.colors[1], color }, p3 and 12 or 10, 7, {
				gravity = 14,
				drag = 1.6,
				life = 0.4,
				size = 0.08,
				stretch = 0.03,
				angle = -1.5707963267948966,
				spread = 1.4
			})

			if p3 then
				p4.flash(rgb(230, 240, 255), 0.65, 0.18) -- inferred equivalent call
			end
		end)
	end

	particle(parent2, {
		at = at,
		shape = "dot",
		color = rgb(30, 26, 40), -- inferred equivalent call
		size = p * 0.6,
		size2 = p * 0.8,
		alpha = 0.55,
		life = 0.9,
		fadeAt = 0.3,
		z = 8
	})

	if p3 then
		p4.shake(p * 0.22, 0.5)
	end
end

function effects.shatter(parent2, at, p, p2, p3, p4)
	local v16 = p3 and 1.9 or 1

	for i = 1, p3 and 9 or 6 do
		local v17 = i / (p3 and 9 or 6) * 3.141592653589793 * 2 + rand(-0.3, 0.3) -- inferred equivalent call
		local v18 = p * rand(0.35, 0.55) * v16 -- inferred equivalent call

		local fx = Instance.new("Frame")
		fx.Name = "Fx"
		fx.BorderSizePixel = 0
		fx.AnchorPoint = Vector2.new(0, 0.5)
		fx.Position = UDim2.fromOffset(at.X, at.Y)
		fx.Rotation = math.deg(v17)
		fx.Size = UDim2.fromOffset(0, (math.max(1.5, p * 0.03)))
		fx.BackgroundColor3 = color
		fx.ZIndex = 10
		fx.Parent = parent2
		UI.tween(fx, 0.08, {
			Size = UDim2.fromOffset(v18, fx.Size.Y.Offset)
		})
		task.delay(0.12, function()
			if fx.Parent then
				UI.tween(fx, 0.25, { BackgroundTransparency = 1 }).Completed:Connect(function()
					fx:Destroy()
				end)
			end
		end)
	end

	glow(parent2, at, p * 1.1 * v16, rgb(200, 230, 255), 0.25, { delay = 0.1 }) -- inferred equivalent call

	for i = 1, p3 and 34 or 14 do
		local v17 = random:NextNumber() * 3.141592653589793 * 2
		particle(parent2, {
			at = at + Vector2.new(math.cos(v17), (math.sin(v17))) * p * rand(0.05, 0.35), -- inferred equivalent call
			vel = Vector2.new(math.cos(v17), (math.sin(v17))) * p * rand(2, 5.5) * v16 + Vector2.new(0, -p * 2.5), -- inferred equivalent call
			gravity = Vector2.new(0, p * 16),
			drag = 0.6,
			life = rand(0.6, 0.95) * (p3 and 1.25 or 1), -- inferred equivalent call
			size = p * rand(0.1, 0.22) * math.sqrt(v16), -- inferred equivalent call
			color = pick(p2.colors), -- inferred equivalent call
			alpha = 0.2,
			shape = "shard",
			spin = rand(-500, 500), -- inferred equivalent call
			fadeAt = 0.55,
			delay = 0.1
		})
	end

	burst(parent2, at, p, { color }, p3 and 14 or 6, 10 * v16, {
		drag = 5,
		life = 0.25,
		size = 0.05,
		stretch = 0.025,
		delay = 0.1
	})

	if p3 then
		p4.flash(color, 0.7, 0.25)
		p4.shake(p * 0.16, 0.4)
	end
end

function effects.supernova(parent2, at, p, p2, p3, p4)
	local v16 = p3 and 2.2 or 1
	particle(parent2, {
		at = at,
		shape = "glow",
		color = p2.colors[2],
		size = p * 1.4 * v16,
		size2 = p * 0.25,
		life = 0.16,
		fadeAt = 0.9
	})
	task.delay(0.15, function()
		if not parent2.Parent then
			return
		end

		glow(parent2, at, p * 3.2 * v16, p2.colors[1], 0.55, {
			from = p * 0.4
		})
		rays(parent2, at, p2.colors[2], p3 and 16 or 10, p * 2.4 * v16, math.max(2, p * 0.1), 0.6, 25)
		shock(parent2, at, p2.colors[2], p * 0.3, p * 3.4 * v16, p * 0.2, 0.55)
		shock(parent2, at, p2.colors[4], p * 0.3, p * 2.5 * v16, p * 0.13, 0.55, 0.1)
		burst(parent2, at, p, p2.colors, p3 and 70 or 24, 11 * v16, {
			drag = 2.4,
			life = 0.6,
			size = 0.09,
			stretch = 0.03,
			gravity = 2
		})
		burst(parent2, at, p, { p2.colors[1], p2.colors[2] }, p3 and 18 or 6, 5 * v16, {
			shape = "icon",
			icon = "star",
			drag = 2.5,
			life = 0.8,
			size = 0.28,
			size2 = 0.05,
			spin = 300,
			fadeAt = 0.5
		})

		if p3 then
			p4.flash(p2.colors[1], 0.5, 0.5)
			p4.shake(p * 0.25, 0.55)
		end
	end)
end

function effects.blackhole(parent2, at, p, p2, p3, p4)
	local v16 = p3 and 2.2 or 1
	local v17 = p3 and 1.1 or 0.6
	glow(parent2, at, p * 1.4 * v16, p2.colors[1], v17 + 0.2, {
		from = p * 0.2,
		fadeAt = 0.7
	})
	local fx = Instance.new("Frame")
	fx.Name = "Fx"
	fx.BorderSizePixel = 0
	fx.AnchorPoint = Vector2.new(0.5, 0.5)
	fx.Position = UDim2.fromOffset(at.X, at.Y)
	fx.BackgroundColor3 = rgb(6, 2, 14) -- inferred equivalent call
	fx.ZIndex = 11
	corner(fx) -- inferred equivalent call
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = math.max(2, p * 0.08 * v16)
	uiStroke.Color = color
	uiStroke.Parent = fx
	local uiGradient = Instance.new("UIGradient")
	uiGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, p2.colors[1]),
		ColorSequenceKeypoint.new(0.5, p2.colors[2]),
		ColorSequenceKeypoint.new(1, p2.colors[1])
	})

	uiGradient.Parent = uiStroke
	fx.Parent = parent2
	local v18 = p * 0.7 * v16
	local now = os.clock()
	animate(fx, function(p5) -- inferred equivalent call
		local v19 = p5 - now
		local v20

		if v19 < 0.2 then
			v20 = v18 * easeOut(v19 / 0.2) -- inferred equivalent call
		elseif v19 < v17 then
			v20 = v18 * (math.sin(v19 * 20) * 0.06 + 1)
		elseif v19 < v17 + 0.18 then
			v20 = v18 * (1 - (v19 - v17) / 0.18)
		else
			unanimate(fx) -- inferred equivalent call
			fx:Destroy()
			return
		end

		fx.Size = UDim2.fromOffset(v20, v20)
		uiGradient.Rotation = v19 * 400 % 360
	end)

	for i = 1, p3 and 60 or 22 do
		particle(parent2, {
			at = at,
			shape = "streak",
			color = pick(p2.colors), -- inferred equivalent call
			size = p * rand(0.08, 0.13), -- inferred equivalent call
			size2 = p * 0.03,
			stretch = 0.018,
			life = v17 * rand(0.6, 1), -- inferred equivalent call
			alpha = 0.1,
			fadeAt = 0.8,
			orbit = {
				r0 = p * rand(0.9, 1.8) * v16, -- inferred equivalent call
				a0 = random:NextNumber() * 3.141592653589793 * 2,
				turns = rand(0.8, 1.4) -- inferred equivalent call
			},
			z = 10
		})
	end

	task.delay(v17 + 0.15, function()
		if not parent2.Parent then
			return
		end

		shock(parent2, at, p2.colors[2], p * 0.2, p * 3 * v16, p * 0.14, 0.5)
		glow(parent2, at, p * 1.6 * v16, color, 0.3)
		burst(parent2, at, p, { color, p2.colors[2] }, p3 and 30 or 12, 12 * v16, {
			drag = 3,
			life = 0.4,
			size = 0.07,
			stretch = 0.03
		})

		if p3 then
			p4.flash(p2.colors[1], 0.65, 0.4)
			p4.shake(p * 0.22, 0.45)
		end
	end)
end

function effects.bubbles(parent2, at, p, p2, p3, p4)
	local v16 = p3 and 1.8 or 1
	glow(parent2, at, p * 0.9 * v16, p2.colors[2], 0.3)

	local function pop(p5, p6)
		shock(parent2, p5, color, p6 * 0.7, p6 * 1.6, math.max(1, p6 * 0.08), 0.18)
		burst(parent2, p5, p, { color, p2.colors[2] }, 2, 2.2, {
			drag = 4,
			life = 0.18,
			size = 0.035,
			size2 = 0.01,
			shape = "dot",
			jitter = 0
		})
	end

	for i = 1, p3 and 28 or 11 do
		local v17 = random:NextNumber() * 3.141592653589793 * 2
		local size = p * rand(0.18, 0.34) * (p3 and 1.2 or 1) -- inferred equivalent call
		local v18 = rand(0.8, 1.6) -- inferred equivalent call
		local v19 = random:NextNumber() * 6
		particle(parent2, {
			at = at + Vector2.new(math.cos(v17), (math.sin(v17))) * p * 0.15,
			vel = Vector2.new(math.cos(v17), math.sin(v17) * 0.7) * p * rand(1.2, 3.2) * v16, -- inferred equivalent call
			drag = 3,
			gravity = Vector2.new(0, -p * 2.2),
			life = rand(0.55, 1) * (p3 and 1.3 or 1), -- inferred equivalent call
			size = size * 0.6,
			size2 = size,
			color = pick(p2.colors), -- inferred equivalent call
			shape = "bubble",
			fadeAt = 0.92,
			delay = i % 5 * 0.03,
			update = function(self, p5, p6)
				self.Position = UDim2.fromOffset(p6.X + math.sin(p5 * 14 * v18 + v19) * p * 0.05, p6.Y)
			end,
			done = function(p5)
				pop(p5, size)
			end
		})
	end

	if p3 then
		particle(parent2, {
			at = at,
			shape = "bubble",
			color = p2.colors[1],
			size = p * 0.3,
			size2 = p * 1.5,
			life = 0.6,
			fadeAt = 0.95,
			update = function(p5, p6)
				local v17 = p * (0.3 + 1.2 * easeOut(p6)) -- inferred equivalent call

				p5.Size = UDim2.fromOffset(v17 * (math.sin(p6 * 40) * 0.06 + 1), v17 * (1 - math.sin(p6 * 40) * 0.06))
			end,
			done = function()
				shock(parent2, at, color, p * 1.2, p * 3, p * 0.12, 0.35)
				burst(parent2, at, p, { color, p2.colors[1], p2.colors[2] }, 18, 9, {
					drag = 3,
					life = 0.35,
					size = 0.07,
					stretch = 0.025
				})
				p4.flash(p2.colors[2], 0.82, 0.3)
				p4.shake(p * 0.08, 0.25)
			end
		})
	end
end

function effects.pixels(parent2, at, p, p2, p3, p4)
	local v16 = p3 and 2 or 1
	local v17 = math.max(2, (math.floor(p * 0.08)))
	local function snap(p5) -- 4 equivalent calls inferred from this helper
		return math.floor(p5 / v17 + 0.5) * v17
	end

	particle(parent2, {
		at = Vector2.new(snap(at.X), snap(at.Y)), -- inferred equivalent call
		shape = "pixel",
		color = color,
		size = v17 * 3,
		size2 = v17 * 8 * v16,
		life = 0.16,
		alpha = 0.15,
		fadeAt = 0.2,
		rot = 0
	})
	local function piece(vel, size, color3, life, delay)
		particle(parent2, {
			at = at,
			vel = vel,
			drag = 2.6,
			gravity = Vector2.new(0, p * 2.5),
			life = life,
			size = size,
			color = color3,
			shape = "pixel",
			rot = 0,
			fadeAt = 0.5,
			delay = delay,
			update = function(p5, p6, p7)
				p5.Position = UDim2.fromOffset(snap(p7.X), snap(p7.Y)) -- inferred equivalent call
				p5.BackgroundTransparency = math.floor(math.clamp((p6 - 0.5) / 0.5, 0, 1) * 3 + 0.5) / 3
			end
		})
	end

	for i = 0, 7 do
		local v18 = i * 3.141592653589793 / 4
		piece(
			Vector2.new(math.cos(v18), (math.sin(v18))) * p * 5 * v16,
			v17 * 2,
			p2.colors[i % #p2.colors + 1],
			0.42 * (p3 and 1.3 or 1),
			0
		)
	end

	for i = 1, p3 and 40 or 16 do
		local v18 = random:NextInteger(0, 7) * 3.141592653589793 / 4 + rand(-0.3, 0.3) -- inferred equivalent call
		piece(
			Vector2.new(math.cos(v18), (math.sin(v18))) * p * rand(1.8, 4.5) * v16, -- inferred equivalent call
			v17 * (random:NextNumber() < 0.3 and 2 or 1),
			pick(p2.colors), -- inferred equivalent call
			rand(0.45, 0.75) * (p3 and 1.3 or 1), -- inferred equivalent call
			random:NextNumber() * 0.06
		)
	end

	if p3 then
		for i = 0, 7 do
			local v18 = (i + 0.5) * 3.141592653589793 / 4
			piece(Vector2.new(math.cos(v18), (math.sin(v18))) * p * 7, v17 * 3, color, 0.5, 0.12)
		end

		p4.flash(color, 0.8, 0.2)
		p4.shake(p * 0.1, 0.3)
	end
end

function effects.coins(parent2, at, p, p2, p3, p4)
	local v16 = p3 and 1.8 or 1
	glow(parent2, at, p * 1.2 * v16, p2.colors[1], 0.35)

	for i = 1, p3 and 26 or 10 do
		local v17 = -1.5707963267948966 + rand(-0.8, 0.8) -- inferred equivalent call
		particle(parent2, {
			at = at,
			vel = Vector2.new(math.cos(v17), (math.sin(v17))) * p * rand(4.5, 8) * math.sqrt(v16), -- inferred equivalent call
			gravity = Vector2.new(0, p * 18),
			drag = 1,
			life = rand(0.75, 1.05) * (p3 and 1.25 or 1), -- inferred equivalent call
			size = p * rand(0.2, 0.28), -- inferred equivalent call
			color = p2.colors[1],
			shape = "coin",
			flip = rand(2.5, 4.5), -- inferred equivalent call
			fadeAt = 0.75,
			delay = i % 6 * 0.03
		})
	end

	burst(parent2, at, p, { color, p2.colors[2] }, p3 and 14 or 6, 6 * v16, {
		shape = "icon",
		icon = "star",
		drag = 3,
		life = 0.6,
		size = 0.18,
		size2 = 0.04,
		spin = 200,
		fadeAt = 0.4
	})

	if p3 then
		rays(parent2, at, p2.colors[2], 12, p * 2.6, math.max(2, p * 0.08), 0.6, 15)
		shock(parent2, at, p2.colors[1], p * 0.3, p * 3.6, p * 0.14, 0.5)
		p4.flash(p2.colors[1], 0.78, 0.4)
		p4.shake(p * 0.08, 0.3)
	end
end

function effects.vipcrown(parent2, at, p, p2, p3, p4)
	local v16 = p3 and 1.8 or 1
	local color3 = p2.colors[1]
	local color4 = p2.colors[2]
	local color5 = p2.colors[3]
	local life = p3 and 0.3 or 0.2
	local at2 = at + Vector2.new(0, -p * (p3 and 3 or 1.7))
	local size = p * 0.62 * v16
	local function land()
		if not parent2.Parent then
			return
		end

		particle(parent2, {
			at = at - Vector2.new(0, p * 0.08 * v16),
			shape = "icon",
			icon = p2.icon,
			color = color3,
			size = size,
			life = 0.6,
			rot = 0,
			spin = 0,
			fadeAt = 0.55,
			z = 12,
			update = function(p5, p6)
				local v17 = math.exp(-p6 * 9) * 0.25 * math.cos(p6 * 30) + 1
				p5.Size = UDim2.fromOffset(size * v17, size / v17)
				p5.Rotation = 0
			end
		})

		glow(parent2, at, p * 1.6 * v16, color3, 0.4)
		shock(parent2, at, color3, p * 0.3, p * 2.2 * v16, p * 0.15, 0.5)
		shock(parent2, at, color4, p * 0.3, p * 1.6 * v16, p * 0.09, 0.45, 0.08)

		for i = 1, p3 and 22 or 9 do
			local v17 = -1.5707963267948966 + rand(-0.9, 0.9) -- inferred equivalent call
			particle(parent2, {
				at = at,
				vel = Vector2.new(math.cos(v17), (math.sin(v17))) * p * rand(4, 7.5) * math.sqrt(v16), -- inferred equivalent call
				gravity = Vector2.new(0, p * 18),
				drag = 1,
				life = rand(0.7, 1) * (p3 and 1.2 or 1), -- inferred equivalent call
				size = p * rand(0.18, 0.26), -- inferred equivalent call
				color = color3,
				shape = "coin",
				flip = rand(2.5, 4.5), -- inferred equivalent call
				fadeAt = 0.75,
				delay = i % 5 * 0.025
			})
		end

		burst(parent2, at, p, { color3, color4, color5 }, p3 and 30 or 12, 9 * v16, {
			drag = 3,
			life = 0.45,
			size = 0.07,
			stretch = 0.03,
			gravity = 4
		})
		burst(parent2, at, p, { color4, color3 }, p3 and 14 or 6, 5 * v16, {
			shape = "icon",
			icon = "star",
			drag = 2.5,
			life = 0.7,
			size = 0.22,
			size2 = 0.04,
			spin = 260,
			fadeAt = 0.45
		})

		if not p3 then
			p4.shake(p * 0.05, 0.2)

			return
		end

		rays(parent2, at, color4, 14, p * 2.6 * v16, math.max(2, p * 0.09), 0.6, 20)
		p4.flash(color3, 0.72, 0.45)
		p4.shake(p * 0.16, 0.4)
	end

	particle(parent2, {
		at = at2,
		shape = "icon",
		icon = p2.icon,
		color = color3,
		size = size * 0.8,
		size2 = size,
		life = life,
		rot = 0,
		spin = 0,
		alpha = 0.2,
		alpha2 = 0,
		fadeAt = 0,
		z = 12,
		update = function(p5, p6)
			p5.Position = UDim2.fromOffset(at.X, at2.Y + (at.Y - p * 0.08 * v16 - at2.Y) * p6 * p6)
			p5.Rotation = 0
		end,
		done = land
	})

	particle(parent2, {
		at = at2,
		shape = "streak",
		color = color4,
		vel = Vector2.new(0, (at.Y - at2.Y) / life),
		size = p * 0.12,
		size2 = p * 0.05,
		stretch = 0.06,
		life = life,
		alpha = 0.4,
		fadeAt = 0.3,
		z = 11
	})
end

function effects.fireworks(parent2, p, p2, p3, p4, p5)
	local v16 = p4 and 1.35 or 1

	local function explode(at, color3)
		glow(parent2, at, p2 * 1.6 * v16, color3, 0.4)
		shock(parent2, at, tint(color3, 0.4), p2 * 0.2, p2 * 1.8 * v16, p2 * 0.07, 0.35) -- inferred equivalent call
		local v17 = p4 and 30 or 24

		for i = 1, v17 do
			local v18 = i / v17 * 3.141592653589793 * 2 + rand(-0.08, 0.08) -- inferred equivalent call
			local v19 = {
				at = at,
				vel = Vector2.new(math.cos(v18), (math.sin(v18))) * p2 * rand(3.8, 4.6) * v16, -- inferred equivalent call
				gravity = Vector2.new(0, p2 * 4),
				drag = 2.4,
				life = rand(0.75, 1), -- inferred equivalent call
				size = p2 * 0.13,
				size2 = p2 * 0.04,
				color = 0,
				shape = "streak",
				stretch = 0.03,
				fadeAt = 0.55,
				update = 0
			}
			local color4

			if random:NextNumber() < 0.2 then
				color4 = color or color3
			else
				color4 = color3
			end

			v19.color = color4

			function v19:update(p6)
				if p6 > 0.6 and random:NextNumber() < 0.35 then
					self.BackgroundTransparency = 1
				end
			end

			particle(parent2, v19)
		end

		burst(parent2, at, p2, { color, tint(color3, 0.5) }, p4 and 10 or 6, 2.5 * v16, {
			shape = "dot",
			drag = 3,
			life = 0.9,
			size = 0.07,
			size2 = 0.03,
			gravity = 1.5,
			fadeAt = 0.3
		})
	end

	local v17 = p4 and 5 or 2

	for i = 1, v17 do
		local color3 = p3.colors[random:NextInteger(1, #p3.colors)]
		local v18 = p4 and 2.2 or 0.9
		local at = p + Vector2.new((-0.15 + random:NextNumber() * 0.3) * p2, 0)
		local v19 = p4 and 1.8 or 1.2
		local at2 = p + Vector2.new(rand(-v18, v18) * p2, -p2 * (v19 + random:NextNumber() * ((p4 and 3.4 or 2) - v19))) -- inferred equivalent call
		particle(parent2, {
			at = at,
			shape = "dot",
			color = tint(color3, 0.5), -- inferred equivalent call
			size = p2 * 0.1,
			size2 = p2 * 0.07,
			life = 0.26 + random:NextNumber() * 0.08,
			fadeAt = 1,
			delay = (i - 1) * (p4 and 0.11 or 0.16),
			update = function(p6, p7)
				local lerped = at:Lerp(at2, easeOut(p7)) -- inferred equivalent call
				p6.Position = UDim2.fromOffset(lerped.X, lerped.Y)

				if random:NextNumber() < 0.75 then
					particle(parent2, {
						at = lerped,
						vel = Vector2.new(
							-0.3 + random:NextNumber() * 0.6,
							0.2 + random:NextNumber() * 0.6000000000000001
						) * p2,
						drag = 2,
						life = 0.2 + random:NextNumber() * 0.14999999999999997,
						size = p2 * 0.05,
						size2 = p2 * 0.01,
						color = Color3.fromRGB(255, 220, 160),
						fadeAt = 0.2
					})
				end
			end,
			done = function()
				explode(at2, color3)

				if p4 and i == v17 then
					p5.flash(color, 0.82, 0.3)
					p5.shake(p2 * 0.1, 0.3)
				end
			end
		})
	end
end

local function cut(parent2, p, p2, p3, p4, backgroundColor3, value, p5) -- 1 equivalent call inferred from this helper
	task.delay(value or 0, function()
		if not parent2.Parent then
			return
		end

		local fx = Instance.new("Frame")
		fx.Name = "Fx"
		fx.BackgroundTransparency = 1
		fx.AnchorPoint = Vector2.new(0.5, 0.5)
		fx.Position = UDim2.fromOffset(p.X, p.Y)
		fx.Size = UDim2.fromOffset(p3, p4 * 4)
		fx.Rotation = math.deg(p2)
		fx.ZIndex = 11
		fx.Parent = parent2
		local function line(backgroundColor, p6)
			local frame2 = Instance.new("Frame")
			frame2.BorderSizePixel = 0
			frame2.AnchorPoint = Vector2.new(0, 0.5)
			frame2.Position = UDim2.fromScale(0, 0.5)
			frame2.BackgroundColor3 = backgroundColor
			frame2.ZIndex = 11
			corner(frame2) -- inferred equivalent call
			local uiGradient = Instance.new("UIGradient")
			uiGradient.Transparency = NumberSequence.new(p6)
			uiGradient.Parent = frame2
			frame2.Parent = fx
			return frame2
		end

		local parent3 = line(backgroundColor3, {
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.2, 0.3),
			NumberSequenceKeypoint.new(0.8, 0.3),
			NumberSequenceKeypoint.new(1, 1)
		})
		local parent4 = line(color, {
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.25, 0),
			NumberSequenceKeypoint.new(0.75, 0),
			NumberSequenceKeypoint.new(1, 1)
		})
		local now = os.clock()
		animate(fx, function(p6) -- inferred equivalent call
			local v16 = (p6 - now) / p5

			if v16 >= 1 then
				unanimate(fx) -- inferred equivalent call
				fx:Destroy()
			else
				local v17 = easeOut(math.min(1, v16 / 0.2)) -- inferred equivalent call
				local backgroundTransparency = math.clamp((v16 - 0.2) / 0.8, 0, 1)
				parent3.Size = UDim2.new(v17, 0, 0, p4 * 3 * (1 - backgroundTransparency * 0.7))
				parent4.Size = UDim2.new(v17, 0, 0, (math.max(1, p4 * (1 - backgroundTransparency * 0.8))))
				parent3.BackgroundTransparency = backgroundTransparency * 0.75 + 0.25
				parent4.BackgroundTransparency = backgroundTransparency
			end
		end)
	end)
end

function effects.slash(parent2, at, p, p2, p3, p4)
	local v16 = p3 and { 0.6, 2.55, -0.2, 1.37 } or { 0.62, 2.52 }
	local v17 = p * (p3 and 3.4 or 1.7)
	local v18 = math.max(2, p * 0.07) * (p3 and 1.4 or 1)

	for k, v19 in v16 do
		local v20 = (k - 1) * (p3 and 0.08 or 0.1)
		cut(parent2, at, v19, v17, v18, p2.colors[1], v20, p3 and 0.45 or 0.35) -- inferred equivalent call

		task.delay(v20 + 0.03, function()
			if not parent2.Parent then
				return
			end

			local vector2 = Vector2.new(math.cos(v19), (math.sin(v19)))

			for k2, v21 in { 1, -1 } do
				burst(
					parent2,
					at + vector2 * v21 * p * 0.3,
					p,
					{ color, p2.colors[1], p2.colors[3] },
					p3 and 7 or 4,
					9,
					{
						angle = math.atan2(vector2.Y * v21, vector2.X * v21),
						spread = 0.35,
						drag = 4,
						life = 0.3,
						size = 0.07,
						stretch = 0.03,
						gravity = 4
					}
				)
			end
		end)
	end

	glow(parent2, at, p * 1.1 * (p3 and 1.8 or 1), p2.colors[1], 0.3, { delay = 0.05 })

	if p3 then
		task.delay(#v16 * 0.08 + 0.05, function()
			if not parent2.Parent then
				return
			end

			shock(parent2, at, p2.colors[2], p * 0.3, p * 4, p * 0.12, 0.45)
			shock(parent2, at, p2.colors[3], p * 0.3, p * 3, p * 0.08, 0.45, 0.06)
			p4.flash(p2.colors[1], 0.72, 0.3)
			p4.shake(p * 0.18, 0.4)
		end)
	end
end

function effects.meteor(parent2, at, p, p2, p3, p4)
	local v16 = p3 and 2 or 1
	local life = p3 and 0.45 or 0.32
	local at2 = at + Vector2.new(p * (p3 and 4.5 or 2.4), -p * (p3 and 6 or 3.2))
	local function posAt(p5) -- 2 equivalent calls inferred from this helper
		return at2:Lerp(at, p5 ^ 1.6)
	end

	local v17 = at2
	particle(parent2, {
		at = at2,
		shape = "glow",
		color = p2.colors[2],
		size = p * 0.9 * v16,
		life = life,
		fadeAt = 1,
		z = 10,
		update = function(p5, p6)
			local at3 = posAt(p6) -- inferred equivalent call
			p5.Position = UDim2.fromOffset(at3.X, at3.Y)

			local v18 = math.clamp(math.floor((at3 - v17).Magnitude / (p * 0.2)) + 1, 1, 4)

			for i = 1, v18 do
				particle(parent2, {
					at = v17:Lerp(at3, i / v18),
					shape = "glow",
					color = random:NextNumber() < 0.5 and p2.colors[2] or p2.colors[3],
					size = p * 0.5 * v16,
					size2 = p * 0.12,
					life = rand(0.18, 0.3), -- inferred equivalent call
					fadeAt = 0,
					alpha = 0.15,
					z = 9
				})
			end

			v17 = at3

			if random:NextNumber() < 0.45 then
				particle(parent2, {
					at = at3,
					vel = Vector2.new(rand(-0.4, 0.4), rand(-0.4, 0.2)) * p, -- inferred equivalent call
					drag = 2,
					shape = "glow",
					color = p2.colors[4],
					size = p * 0.25 * v16,
					size2 = p * 0.55 * v16,
					life = rand(0.4, 0.6), -- inferred equivalent call
					fadeAt = 0,
					alpha = 0.35,
					z = 8
				})
			end
		end,
		done = function()
			glow(parent2, at, p * 2.6 * v16, p2.colors[1], 0.45, {
				from = p * 0.5
			})
			shock(parent2, at, p2.colors[2], p * 0.3, p * 3.2 * v16, p * 0.22, 0.55)
			shock(parent2, at, p2.colors[1], p * 0.2, p * 2.2 * v16, p * 0.12, 0.45, 0.08)
			burst(parent2, at, p, { p2.colors[4], rgb(70, 60, 64), rgb(130, 108, 100) }, p3 and 22 or 10, 6 * v16, { -- inferred equivalent call
				shape = "square",
				gravity = 16,
				drag = 0.8,
				life = 0.7,
				size = 0.12,
				size2 = 0.08,
				spin = 500,
				fadeAt = 0.6,
				angle = -1.5707963267948966,
				spread = 1.4
			})
			burst(parent2, at, p, { p2.colors[1], p2.colors[2], p2.colors[3] }, p3 and 40 or 16, 9 * v16, {
				gravity = 6,
				drag = 2.2,
				life = 0.55,
				size = 0.09,
				stretch = 0.03
			})

			for i = 1, p3 and 9 or 4 do
				particle(parent2, {
					at = at + Vector2.new(rand(-0.3, 0.3), rand(-0.2, 0.2)) * p * v16, -- inferred equivalent call
					vel = Vector2.new(rand(-0.6, 0.6), rand(-1.6, -0.6)) * p * v16, -- inferred equivalent call
					drag = 1.6,
					life = rand(0.8, 1.2), -- inferred equivalent call
					size = p * 0.4 * v16,
					size2 = p * 1 * v16,
					color = p2.colors[4],
					shape = "glow",
					alpha = 0.3,
					fadeAt = 0.1,
					z = 9
				})
			end

			particle(parent2, {
				at = at,
				shape = "dot",
				color = rgb(40, 24, 20), -- inferred equivalent call
				size = p * 0.6 * v16,
				size2 = p * 0.75 * v16,
				alpha = 0.45,
				life = 1.2,
				fadeAt = 0.4,
				z = 8
			})
			particle(parent2, {
				at = at,
				shape = "glow",
				color = p2.colors[3],
				size = p * 0.7 * v16,
				size2 = p * 0.5 * v16,
				alpha = 0.2,
				life = 0.9,
				fadeAt = 0.2,
				z = 8
			})

			if p3 then
				p4.flash(p2.colors[2], 0.55, 0.5)
				p4.shake(p * 0.3, 0.6)
			end
		end
	})

	particle(parent2, {
		at = at2,
		shape = "dot",
		color = rgb(80, 56, 44), -- inferred equivalent call
		size = p * 0.26 * v16,
		life = life,
		fadeAt = 1,
		z = 11,
		update = function(p5, p6)
			local v18 = posAt(p6) -- inferred equivalent call
			p5.Position = UDim2.fromOffset(v18.X, v18.Y)
		end
	})
end

Cosmetics2.EFFECTS = effects

function Cosmetics2.playEffect(parent2, p, p2, p3, p4, options): boolean
	local v16 = p3 and Cosmetics.BY_ID[p3]

	if not v16 or v16.type ~= "effect" or v16.free or not effects[v16.kind] then
		return false
	end

	local v17 = options or {}
	local v18 = {
		shake = v17.shake or function() end,
		flash = v17.flash or function(backgroundColor, backgroundTransparency, p5)
			flash(parent2, backgroundColor, backgroundTransparency, p5)
		end
	}

	local success, result = pcall(effects[v16.kind], parent2, p, p2, v16, p4, v18)

	if not success then
		warn("[Chess] effect " .. p3 .. " failed: " .. tostring(result))
	end

	return true
end

Cosmetics2.flash = flash

local function king(preview, p, p2, p3, p4)
	local king2 = Instance.new("ImageLabel")
	king2.Name = "King"
	king2.BackgroundTransparency = 1
	king2.ScaleType = Enum.ScaleType.Fit
	king2.AnchorPoint = Vector2.new(0.5, 1)
	king2.Size = UDim2.fromScale(p3, p3)
	king2.Position = UDim2.fromScale(p4, 0.96)
	king2.Parent = preview
	Cosmetics2.paintPiece(king2, p, p2)
	return king2
end

function Cosmetics2.preview(data, parent2)
	local preview = Instance.new("Frame")
	preview.Name = "Preview"
	preview.BackgroundTransparency = 1
	preview.Size = UDim2.fromScale(1, 1)
	preview.Parent = parent2

	if data.type == "board" then
		local frame2 = Instance.new("Frame")
		frame2.BackgroundTransparency = 1
		frame2.AnchorPoint = Vector2.new(0.5, 0.5)
		frame2.Position = UDim2.fromScale(0.5, 0.5)
		frame2.Size = UDim2.fromScale(0.8, 0.8)
		frame2.SizeConstraint = Enum.SizeConstraint.RelativeYY
		frame2.Parent = preview
		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(0.08, 0)
		uiCorner.Parent = frame2
		frame2.ClipsDescendants = true
		Cosmetics2.boardSwatch(data, frame2)
		return preview
	elseif data.type == "background" then
		local frame2 = Instance.new("Frame")
		frame2.BorderSizePixel = 0
		frame2.AnchorPoint = Vector2.new(0.5, 0.5)
		frame2.Position = UDim2.fromScale(0.5, 0.5)
		frame2.Size = UDim2.fromScale(0.88, 0.8)
		frame2.Parent = preview
		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(0, 6)
		uiCorner.Parent = frame2
		Cosmetics2.applyBackground(frame2, data.id, true)
		return preview
	else
		if data.type == "pieces" then
			king(preview, 6, data.id, 0.74, 0.32)
			king(preview, -6, data.id, 0.74, 0.68)
		elseif data.type == "accessory" then
			local v16 = king(preview, 6, nil, 0.62, 0.5)
			v16.Position = UDim2.fromScale(0.5, 1)
			Cosmetics2.setHat(v16, data.id)

			if data.free then
				v16.ImageTransparency = 0.5
				return preview
			end
		elseif data.type == "effect" and not data.free then
			local victim = Instance.new("ImageLabel")
			victim.Name = "Victim"
			victim.BackgroundTransparency = 1
			victim.ScaleType = Enum.ScaleType.Fit
			victim.AnchorPoint = Vector2.new(0.5, 0.5)
			victim.Position = UDim2.fromScale(0.5, 0.5)
			victim.Size = UDim2.fromScale(0.5, 0.5)
			victim.SizeConstraint = Enum.SizeConstraint.RelativeYY
			victim.Parent = preview
			Sprites.applyPiece(victim, -3)
			return preview
		elseif data.type == "effect" then
			local v16 = data.colors and (data.colors[1] == color and data.colors[2] or data.colors[1])
				or rgb(150, 150, 150) -- inferred equivalent call
			_ = UI.icon(data.free and "close" or data.icon or ({
				lightning = "bolt",
				ring = "flip",
				puff = "history",
				blackhole = "globe",
				shatter = "puzzle"
			})[data.kind] or "star", 10, v16, {
				Name = "Icon",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.42, 0.42),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Parent = preview
			})
		end

		return preview
	end
end

function Cosmetics2.previewEffect(p, p2, p3)
	local absoluteSize = p.AbsoluteSize
	local v16 = math.min(absoluteSize.X, absoluteSize.Y) * (p3 and 0.3 or 0.5)
	return Cosmetics2.playEffect(p, absoluteSize / 2, v16, p2, p3)
end

local function shown(instance)
	while instance and not instance:IsA("LayerCollector") do
		if instance:IsA("GuiObject") and not instance.Visible then
			return false
		end

		instance = instance.Parent
	end

	return instance ~= nil and instance.Enabled
end

local function inView(instance): boolean
	local absolutePosition = instance.AbsolutePosition
	local absoluteSize = instance.AbsoluteSize
	local x = absolutePosition.X
	local y = absolutePosition.Y
	local v16 = absolutePosition.X + absoluteSize.X
	local v17 = absolutePosition.Y + absoluteSize.Y
	local parent2 = instance.Parent

	while parent2 do
		local isA = parent2:IsA("LayerCollector")

		if
			isA
			or parent2:IsA("GuiObject")
			and (parent2.ClipsDescendants or parent2:IsA("ScrollingFrame") or parent2:IsA("CanvasGroup"))
		then
			local absolutePosition2 = parent2.AbsolutePosition
			local absoluteSize2 = parent2.AbsoluteSize
			x = math.max(x, absolutePosition2.X)
			y = math.max(y, absolutePosition2.Y)
			v16 = math.min(v16, absolutePosition2.X + absoluteSize2.X)
			v17 = math.min(v17, absolutePosition2.Y + absoluteSize2.Y)

			if v16 <= x or v17 <= y then
				return false
			end
		end

		if isA then
			return true
		end

		parent2 = parent2.Parent
	end

	return false
end

Cosmetics2.inView = inView

function Cosmetics2.loopEffect(instance, p, value, callback)
	task.spawn(function()
		task.wait(value or 0)
		local v16 = false

		while instance.Parent and instance:IsDescendantOf(game) and (not callback or callback()) do
			if shown(instance) and instance.AbsoluteSize.X > 0 and inView(instance) then
				Cosmetics2.previewEffect(instance, p, v16)
				task.wait(v16 and 2.2 or 1.4)
				v16 = not v16
			else
				task.wait(0.5)
			end
		end
	end)
end

return Cosmetics2