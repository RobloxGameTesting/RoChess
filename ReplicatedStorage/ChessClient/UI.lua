local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(script.Parent.Theme)
local Sound = require(script.Parent.Sound)
local Sprites = require(ReplicatedStorage.Chess.Sprites)

local UI = {}

local v = { TextLabel = true, TextButton = true, TextBox = true }
local v2 = { ImageLabel = true, ImageButton = true }

local v3 = {
	[11] = 12,
	[13] = 14,
	[15] = 16,
	[17] = 16,
	[19] = 20,
	[21] = 20,
	[22] = 20
}

function UI.new(className, p, items)
	if p and p.TextSize and v3[p.TextSize] and not p.TextScaled then
		p = table.clone(p)
		p.TextSize = v3[p.TextSize]
	end

	local instance = Instance.new(className)

	if instance:IsA("GuiObject") then
		instance.BorderSizePixel = 0
	end

	if v[className] then
		instance.BackgroundTransparency = 1
		instance.FontFace = Theme.font
		instance.TextColor3 = Theme.text
		instance.TextSize = 16

		if className ~= "TextBox" then
			instance.Text = ""
		end
	end

	if v2[className] then
		instance.BackgroundTransparency = 1
	end

	if className == "TextButton" or className == "ImageButton" then
		instance.AutoButtonColor = false
	end

	local parent = nil

	if p then
		for k, v4 in p do
			if k == "Parent" then
				parent = v4
			else
				instance[k] = v4
			end
		end
	end

	if items then
		for _, item in items do
			item.Parent = instance
		end
	end

	if parent then
		instance.Parent = parent
	end

	return instance
end

local v4 = {
	[1] = 6,
	[2] = 6,
	[3] = 6,
	[4] = 6,
	[5] = 10,
	[6] = 10,
	[7] = 14,
	[8] = 14,
	[9] = 14,
	[11] = 14,
	[12] = 14,
	[13] = 14
}
function UI.corner(cornerRadius)
	local uiCorner = Instance.new("UICorner")

	if typeof(cornerRadius) == "UDim" then
		uiCorner.CornerRadius = cornerRadius
		return uiCorner
	end

	local v5 = cornerRadius or 6
	uiCorner.CornerRadius = UDim.new(0, v4[v5] or v5)

	return uiCorner
end

function UI.lift(parent, value)
	local edge = parent:FindFirstChild("Edge")

	if edge then
		return edge
	end

	local edge2 = Instance.new("UIStroke")
	edge2.Name = "Edge"
	edge2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	edge2.Color = Color3.new(1, 1, 1)
	edge2.Thickness = 1
	edge2.Transparency = 0
	local uiGradient = Instance.new("UIGradient")
	uiGradient.Rotation = 90
	local v5 = 1 - (value or 0.14)
	uiGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, v5),
		NumberSequenceKeypoint.new(0.35, 0.93),
		NumberSequenceKeypoint.new(1, 0.96)
	})

	uiGradient.Parent = edge2
	edge2.Parent = parent
	return edge2
end

function UI:depth(backgroundColor)
	if backgroundColor then
		self.BackgroundColor3 = backgroundColor
	end

	local depth = self:FindFirstChild("Depth") or Instance.new("UIGradient")
	depth.Name = "Depth"
	depth.Rotation = 90
	depth.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
		ColorSequenceKeypoint.new(0.45, Color3.fromRGB(212, 214, 220)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 182, 190))
	})

	depth.Parent = self
	UI.lift(self, 0.22)
	return depth
end

function UI.shadow(instance, parent, value)
	local frame = UI.new("Frame", {
		Name = instance.Name .. "Shadow",
		BackgroundTransparency = 1,
		ZIndex = 0,
		Parent = parent
	})

	for k, v5 in {
		{ 2, 0.7 },
		{ 8, 0.84 },
		{ 18, 0.92 },
		{ 30, 0.96 }
	} do
		UI.new("Frame", {
			Name = "S" .. k,
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = v5[2],
			Position = UDim2.fromOffset(-v5[1], -v5[1] + 8),
			Size = UDim2.new(1, v5[1] * 2, 1, v5[1] * 2),
			ZIndex = 0,
			Parent = frame
		}, { UI.corner(UDim.new(0, (value or 14) + v5[1])) })
	end

	local function visible(guiObject): boolean
		while guiObject and guiObject ~= parent and guiObject:IsA("GuiObject") do
			if not guiObject.Visible then
				return false
			end

			guiObject = guiObject.Parent
		end

		return true
	end

	local function sync()
		local absolutePosition = parent.AbsolutePosition
		frame.Position = UDim2.fromOffset(
			instance.AbsolutePosition.X - absolutePosition.X,
			instance.AbsolutePosition.Y - absolutePosition.Y
		)
		frame.Size = UDim2.fromOffset(instance.AbsoluteSize.X, instance.AbsoluteSize.Y)
		frame.Visible = visible(instance) and instance.AbsoluteSize.X > 4
	end
	instance:GetPropertyChangedSignal("AbsolutePosition"):Connect(sync)
	instance:GetPropertyChangedSignal("AbsoluteSize"):Connect(sync)
	local guiObject = instance

	while guiObject and guiObject ~= parent and guiObject:IsA("GuiObject") do
		guiObject:GetPropertyChangedSignal("Visible"):Connect(sync)
		guiObject = guiObject.Parent
	end

	task.defer(sync)
	return frame
end

function UI.pad(value, p, p2, p3)
	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingTop = UDim.new(0, value or 0)
	uiPadding.PaddingRight = UDim.new(0, p or value or 0)
	uiPadding.PaddingBottom = UDim.new(0, p2 or value or 0)
	uiPadding.PaddingLeft = UDim.new(0, p3 or p or value or 0)
	return uiPadding
end

function UI.list(p, value, p2, p3)
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.FillDirection = p or Enum.FillDirection.Vertical
	uiListLayout.Padding = UDim.new(0, value or 0)
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.HorizontalAlignment = p2 or Enum.HorizontalAlignment.Left
	uiListLayout.VerticalAlignment = p3 or Enum.VerticalAlignment.Top
	return uiListLayout
end

function UI.stroke(p, value, value2)
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = p or Color3.new(1, 1, 1)
	uiStroke.Thickness = value or 1
	uiStroke.Transparency = value2 or 0
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	return uiStroke
end

function UI.text(p)
	return (UI.new("TextLabel", p))
end

function UI.tween(instance, duration, goal, p, p2, value)
	local tween = TweenService:Create(
		instance,
		TweenInfo.new(duration, p or Enum.EasingStyle.Quad, p2 or Enum.EasingDirection.Out, 0, false, value or 0),
		goal
	)

	tween:Play()
	return tween
end

UI.FAST = 0.08
UI.SNAP = 0.14
UI.POP = 0.2

local object = setmetatable({}, { __mode = "k" })
function UI.to(p, p2, items, p3, p4)
	local v5 = object[p]

	if not v5 then
		v5 = {}
		object[p] = v5
	end

	local v6 = false

	for k, item in items do
		if v5[k] == nil then
			if p[k] ~= item then
				v6 = true
			end
		elseif v5[k] ~= item then
			v6 = true
		end
	end

	if not v6 then
		return nil
	end

	for k, item in items do
		v5[k] = item
	end

	return UI.tween(p, p2, items, p3, p4)
end

function UI.pop(parent, value, p)
	if not (parent and parent.Parent) then
		return
	end

	local popScale = parent:FindFirstChild("PopScale")

	if not popScale then
		if parent:FindFirstChildOfClass("UIScale") then
			return
		end

		popScale = Instance.new("UIScale")
		popScale.Name = "PopScale"
		popScale.Parent = parent
	end

	popScale.Scale = value or 0.6
	return UI.tween(popScale, p or UI.POP, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

function UI:countTo(p, p2, value, value2, p3)
	local v5 = value2 or "%d"
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = p
	self.Text = string.format(v5, p)
	local v6 = math.round(p)
	numberValue.Changed:Connect(function(p4)
		if self.Parent then
			local v7 = math.round(p4)
			self.Text = string.format(v5, v7)

			if p3 and v7 ~= v6 and p2 ~= p then
				Sound.play(p3, math.clamp((p4 - p) / (p2 - p), 0, 1) * 0.45 + 0.9)
			end

			v6 = v7
		end
	end)
	local tween = UI.tween(numberValue, value or 0.45, { Value = p2 }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	tween.Completed:Connect(function()
		if self.Parent then
			self.Text = string.format(v5, p2)
		end

		numberValue:Destroy()
	end)
	return tween
end

local object2 = setmetatable({}, { __mode = "k" })
function UI.shake(p, value, p2)
	if object2[p] then
		return
	end

	object2[p] = true
	local v5 = value or 5
	local v6 = p2 or p.Position
	task.spawn(function()
		for _, v7 in { -1, 0.8, -0.55, 0.3, 0 } do
			UI.tween(p, 0.04, {
				Position = v6 + UDim2.fromOffset(v5 * v7, 0)
			}).Completed:Wait()
		end

		object2[p] = nil
	end)
end

local v5 = {
	Color3.fromRGB(61, 139, 255),
	Color3.fromRGB(255, 200, 60),
	Color3.fromRGB(240, 110, 120),
	Color3.fromRGB(110, 170, 240),
	Color3.fromRGB(250, 250, 250)
}

function UI.confetti(parent, p, options)
	options = options or {}
	local colors = options.colors or v5
	local spread = options.spread or 150

	for _ = 1, options.count or 28 do
		local v6 = math.random(5, 9) * (options.size or 1)
		local frame = UI.new("Frame", {
			Name = "Confetti",
			Size = UDim2.fromOffset(v6, v6 * (math.random() < 0.5 and 0.5 or 1.4)),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(p.X, p.Y),
			BackgroundColor3 = colors[math.random(1, #colors)],
			Rotation = math.random(0, 360),
			ZIndex = options.zindex or 20,
			Parent = parent
		}, { UI.corner(2) })
		local v7 = math.rad((math.random(200, 340)))
		local v8 = spread * (0.45 + math.random() * 0.75)
		local v9 = p + Vector2.new(math.cos(v7) * v8, math.sin(v7) * v8 * 0.75)
		local v10 = 0.28 + math.random() * 0.14
		local v11 = 0.7 + math.random() * 0.5
		UI.tween(
			frame,
			v10,
			{ Position = UDim2.fromOffset(v9.X, v9.Y) },
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		)
		UI.tween(frame, v10 + v11, {
			Rotation = frame.Rotation + math.random(-540, 540)
		})
		task.delay(v10, function()
			if not frame.Parent then
				return
			end

			UI.tween(frame, v11, {
				Position = UDim2.fromOffset(v9.X + math.random(-30, 30), v9.Y + spread * (0.7 + math.random() * 0.5)),
				BackgroundTransparency = 1
			}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			task.delay(v11, function()
				frame:Destroy()
			end)
		end)
	end
end

function UI:textIn(p)
	self.TextTransparency = 1
	return UI.tween(self, p or UI.SNAP, { TextTransparency = 0 })
end

local object3 = setmetatable({}, { __mode = "k" })
local v6 = { "LayoutOrder", "ZIndex", "Visible" }
local v7 = { "Size", "Position", "AnchorPoint", "AutomaticSize", "SizeConstraint" }

local function inLayout(parent) -- 1 equivalent call inferred from this helper
	return parent and parent:FindFirstChildWhichIsA("UIGridStyleLayout") ~= nil
end

local function unwrap(p)
	local v8 = object3[p]

	if not v8 then
		return
	end

	object3[p] = nil

	for _, conn in v8.conns do
		conn:Disconnect()
	end

	if p.Parent == v8.group then
		v8.own = true

		for _, v9 in v7 do
			p[v9] = v8.saved[v9]
		end

		p.Parent = v8.group.Parent
	end

	v8.group:Destroy()
end
UI.unwrap = unwrap

local function wrap(instance)
	local v8 = object3[instance]

	if v8 then
		return v8
	end

	local parent = instance.Parent

	if not parent then
		return nil
	end

	local canvasGroup = Instance.new("CanvasGroup")
	canvasGroup.Name = instance.Name
	canvasGroup.BackgroundTransparency = 1
	canvasGroup.BorderSizePixel = 0

	local v9 = {
		group = canvasGroup,
		conns = {},
		own = false,
		saved = {},
		margin = (inLayout(parent) or instance.AutomaticSize ~= Enum.AutomaticSize.None) and 0 or 4, -- inferred equivalent call
		token = 0,
		echo = {}
	}

	for _, v10 in v7 do
		v9.saved[v10] = instance[v10]
	end

	local function put(p, p2) -- 4 equivalent calls inferred from this helper
		if instance[p] ~= p2 then
			v9.echo[p] = p2
			instance[p] = p2
		end
	end
	local function place()
		local saved = v9.saved
		local margin = v9.margin
		local anchorPoint = saved.AnchorPoint
		canvasGroup.AnchorPoint = anchorPoint
		canvasGroup.AutomaticSize = saved.AutomaticSize
		canvasGroup.SizeConstraint = saved.SizeConstraint
		canvasGroup.Size = saved.Size + UDim2.fromOffset(2 * margin, 2 * margin)
		v9.basePos = saved.Position + UDim2.fromOffset(
			margin * (2 * anchorPoint.X - 1),
			margin * (2 * anchorPoint.Y - 1)
		)
		canvasGroup.Position = v9.basePos + (v9.slide or UDim2.new())
		v9.own = true
		local automaticSize = saved.AutomaticSize
		local v10 = automaticSize == Enum.AutomaticSize.X or automaticSize == Enum.AutomaticSize.XY
		local v11 = automaticSize == Enum.AutomaticSize.Y or automaticSize == Enum.AutomaticSize.XY
		put("AnchorPoint", Vector2.zero) -- inferred equivalent call
		put("Position", UDim2.fromOffset(margin, margin)) -- inferred equivalent call
		put("SizeConstraint", Enum.SizeConstraint.RelativeXY) -- inferred equivalent call
		put( -- inferred equivalent call
			"Size",
			UDim2.new(
				v10 and saved.Size.X or UDim.new(1, -2 * margin),
				v11 and saved.Size.Y or UDim.new(1, -2 * margin)
			)
		)

		v9.own = false
	end
	v9.place = place

	for _, v10 in v6 do
		canvasGroup[v10] = instance[v10]
	end

	place()
	v9.echo = {}
	canvasGroup.Parent = parent
	instance.Parent = canvasGroup

	for _, propertyName in v6 do
		table.insert(v9.conns, instance:GetPropertyChangedSignal(propertyName):Connect(function()
			canvasGroup[propertyName] = instance[propertyName]
		end))
	end

	for _, propertyName in v7 do
		table.insert(v9.conns, instance:GetPropertyChangedSignal(propertyName):Connect(function()
			if v9.own or object3[instance] ~= v9 then
				v9.echo[propertyName] = nil
				return
			end

			local v10 = v9.echo[propertyName]

			if v10 ~= nil then
				v9.echo[propertyName] = nil

				if instance[propertyName] == v10 then
					return
				end
			end

			v9.saved[propertyName] = instance[propertyName]

			if propertyName == "Position" then
				v9.slide = nil
			end

			place()
		end))
	end

	table.insert(v9.conns, instance.AncestryChanged:Connect(function()
		if instance.Parent ~= canvasGroup then
			unwrap(instance)
		end
	end))
	object3[instance] = v9
	return v9
end

function UI.fadeIn(p, p2, p3)
	if not (p and p.Parent) then
		return
	end

	local v8 = wrap(p)

	if not v8 then
		return
	end

	v8.token += 1
	local token = v8.token
	local group = v8.group
	group.Interactable = true

	if not v8.fading then
		group.GroupTransparency = 1
	end

	v8.fading = true
	local v9 = p2 or UI.SNAP

	if p3 and p3 ~= 0 then
		local parent = group.Parent

		if not parent or parent:FindFirstChildWhichIsA("UIGridStyleLayout") == nil then
			v8.slide = UDim2.fromOffset(0, p3)
			group.Position = v8.basePos + v8.slide
			UI.tween(group, v9, { Position = v8.basePos })
		end
	end

	local tween = UI.tween(group, v9, { GroupTransparency = 0 })
	tween.Completed:Connect(function()
		if v8.token == token and object3[p] == v8 then
			v8.slide = nil
			unwrap(p)
		end
	end)
	return tween
end

function UI.fadeOut(instance, p, p2, callback)
	local function finish() -- 1 equivalent call inferred from this helper
		if callback then
			callback(instance)
		else
			instance:Destroy()
		end
	end

	if not (instance and instance.Parent) then
		return
	end

	local v8 = wrap(instance)

	if v8 then
		v8.token += 1
		local token = v8.token
		local group = v8.group
		group.Interactable = false
		v8.fading = true
		local v9 = p or UI.SNAP

		if p2 and p2 ~= 0 then
			local parent = group.Parent

			if not parent or parent:FindFirstChildWhichIsA("UIGridStyleLayout") == nil then
				v8.slide = UDim2.fromOffset(0, p2)
				UI.tween(group, v9, {
					Position = v8.basePos + v8.slide
				}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			end
		end

		local tween = UI.tween(group, v9, { GroupTransparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		tween.Completed:Connect(function()
			if v8.token ~= token then
				return
			end

			v8.slide = nil

			if callback then
				callback(instance)
				unwrap(instance)
			else
				object3[instance] = nil

				for _, conn in v8.conns do
					conn:Disconnect()
				end

				group:Destroy()
			end
		end)
		return tween
	end

	finish() -- inferred equivalent call
end

function UI:reveal(p, p2, p3)
	if p then
		if not self.Visible then
			self.Visible = true
			UI.fadeIn(self, p3, p2)
		end
	else
		if object3[self] then
			unwrap(self)
		end

		self.Visible = false
	end
end

function UI.hover(data, p, callback, callback2)
	local function enter()
		UI.tween(p or data, UI.FAST, type(callback) == "function" and callback() or callback)
	end
	local function leave()
		UI.tween(p or data, UI.SNAP, type(callback2) == "function" and callback2() or callback2)
	end
	data.MouseEnter:Connect(enter)
	data.MouseLeave:Connect(leave)

	data.SelectionGained:Connect(enter)
	data.SelectionLost:Connect(leave)
end

function UI.icon(p, value, p2, items)
	local result = Sprites.icon(p)
	result.Size = UDim2.fromOffset(value or 20, value or 20)
	result.ImageColor3 = p2 or Theme.text

	if items then
		for k, item in items do
			result[k] = item
		end
	end

	return result
end

function UI.scroll(items)
	local scrollingFrame = UI.new("ScrollingFrame", {
		BackgroundTransparency = 1,
		ScrollBarThickness = 5,
		ScrollBarImageColor3 = Color3.fromRGB(120, 118, 115),
		ScrollBarImageTransparency = 0.3,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
		BorderSizePixel = 0,
		Selectable = false
	})

	if items then
		for k, item in items do
			scrollingFrame[k] = item
		end
	end

	return scrollingFrame
end

function UI.ink(parent, p)
	if not parent then
		return
	end

	local ink = parent:FindFirstChild("Ink")

	if not ink then
		if not p then
			return
		end

		ink = Instance.new("UIStroke")
		ink.Name = "Ink"
		ink.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
		ink.Color = Color3.new(0, 0, 0)
		ink.LineJoinMode = Enum.LineJoinMode.Round
		ink.Parent = parent
	end

	ink.Thickness = math.clamp((parent.TextSize or 16) / 11, 1.2, 2.6)
	ink.Transparency = 0.15
	ink.Enabled = p and UI.INK and true or false
end
UI.INK = false

function UI.selected(parent, _)
	local sel = parent:FindFirstChild("Sel")

	if not sel then
		sel = Instance.new("UIStroke")
		sel.Name = "Sel"
		sel.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		sel.Color = Theme.selEdge
		sel.Thickness = 1
		sel.Parent = parent
	end

	sel.Transparency = 0.35
	sel.Enabled = false
end

local function primaryShade(face, p)
	local shade = face:FindFirstChild("Shade")

	if p and not shade then
		local shade2 = Instance.new("UIGradient")
		shade2.Name = "Shade"
		shade2.Rotation = 90
		shade2.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(196, 202, 214))
		shade2.Parent = face
	elseif shade then
		shade.Enabled = p and true or false
	end
end

local styles = {
	primary = {
		bg = Theme.green,
		hover = Theme.greenHover,
		shadow = Theme.greenShadow,
		text = Theme.text,
		depth = 3
	},
	secondary = {
		bg = Theme.button,
		hover = Theme.buttonHover,
		shadow = Theme.buttonShadow,
		text = Theme.textSoft,
		depth = 4
	},
	danger = {
		bg = Theme.red,
		hover = Theme.redHover,
		shadow = Theme.redShadow,
		text = Theme.text,
		depth = 4
	},
	ghost = {
		bg = Theme.panel,
		hover = Theme.panelLight,
		shadow = nil,
		text = Theme.textDim,
		depth = 0,
		transparent = true
	},
	flat = {
		bg = Theme.panelLight,
		hover = Theme.rowActive,
		shadow = nil,
		text = Theme.textSoft,
		depth = 0
	},
	gold = {
		bg = Theme.vip,
		hover = Theme.vipHover,
		shadow = Theme.vipShadow,
		text = Theme.vipInk,
		depth = 4
	}
}

UI.STYLES = styles

local class = {}
class.__index = class

function UI.button(data)
	local object4 = setmetatable({}, class)
	object4.style = data.style or "secondary"
	object4.enabled = true
	object4.callback = data.onClick
	object4.sfx = data.sfx
	local v8 = styles[object4.style]

	local radius = data.radius or object4.style == "flat" and 14 or UDim.new(1, 0)

	object4.holder = UI.new("Frame", {
		Name = data.name or "Button",
		Size = data.size or UDim2.new(1, 0, 0, 44),
		Position = data.position or UDim2.new(),
		AnchorPoint = data.anchor or Vector2.zero,
		BackgroundTransparency = 1,
		LayoutOrder = data.layoutOrder or 0,
		Parent = data.parent
	})

	object4.shadow = UI.new("Frame", {
		Name = "Shadow",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = v8.shadow or v8.bg,
		BackgroundTransparency = v8.shadow and 0 or 1,
		Parent = object4.holder
	}, { UI.corner(radius) })

	object4.face = UI.new("TextButton", {
		Name = "Face",
		Size = UDim2.new(1, 0, 1, -v8.depth),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, -v8.depth / 2),
		BackgroundColor3 = v8.bg,
		BackgroundTransparency = v8.transparent and 1 or 0,
		Text = "",
		Parent = object4.holder
	}, { UI.corner(radius) })
	object4.face:SetAttribute("Sfx", object4.sfx or object4.style == "primary" and "confirm" or "press")

	if object4.style == "flat" or object4.style == "secondary" then
		UI.lift(object4.face, object4.style == "flat" and 0.12 or 0.1)
	end

	primaryShade(object4.face, object4.style == "primary")
	local frame = UI.new(
		"Frame",
		{
			Name = "Content",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Parent = object4.face
		},
		{
			UI.list(
				Enum.FillDirection.Horizontal,
				data.gap or 8,
				data.align or Enum.HorizontalAlignment.Center,
				Enum.VerticalAlignment.Center
			),
			UI.pad(0, data.padX or 10, 0, data.padX or 10)
		}
	)

	object4.content = frame

	if data.icon then
		object4.icon = UI.icon(data.icon, data.iconSize or 22, data.iconColor or v8.text, {
			LayoutOrder = 1,
			Parent = frame
		})
	end

	if data.text then
		local frame2 = UI.new("Frame", {
			Name = "TextWrap",
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.XY,
			Size = UDim2.new(),
			LayoutOrder = 2,
			Parent = frame
		}, { UI.list(
				Enum.FillDirection.Vertical,
				0,
				data.align == Enum.HorizontalAlignment.Left and Enum.HorizontalAlignment.Left or Enum.HorizontalAlignment.Center
			) })
		object4.label = UI.text({
			Name = "Label",
			Text = data.text,
			FontFace = data.font or Theme.fontBold,
			TextSize = data.textSize or 18,
			TextColor3 = data.textColor or v8.text,
			AutomaticSize = Enum.AutomaticSize.XY,
			Size = UDim2.new(),
			LayoutOrder = 1,
			Parent = frame2
		})

		UI.ink(object4.label, object4.style == "primary" and not data.textColor)

		if data.subtext then
			object4.sublabel = UI.text({
				Name = "Sub",
				Text = data.subtext,
				FontFace = Theme.font,
				TextSize = data.subtextSize or 13,
				TextColor3 = Theme.textDim,
				AutomaticSize = Enum.AutomaticSize.XY,
				Size = UDim2.new(),
				LayoutOrder = 2,
				Parent = frame2
			})
		end
	end

	local v9 = false
	local v10 = false
	local function release()
		if not v10 then
			return
		end

		v10 = false
		UI.tween(
			object4.face,
			0.12,
			{ Position = object4:restPosition() },
			Enum.EasingStyle.Back,
			Enum.EasingDirection.Out
		)
		local v11 = styles[object4.style]

		if v9 and object4.enabled then
			UI.tween(object4.face, UI.FAST, {
				BackgroundColor3 = v11.hover,
				BackgroundTransparency = 0
			})
		else
			UI.tween(object4.face, UI.SNAP, {
				BackgroundColor3 = v11.bg,
				BackgroundTransparency = v11.transparent and 1 or 0
			})
		end
	end
	local function enter()
		v9 = true

		if object4.enabled then
			UI.tween(object4.face, UI.FAST, {
				BackgroundColor3 = styles[object4.style].hover,
				BackgroundTransparency = 0
			})
		end
	end
	local function leave()
		v9 = false
		local v11 = styles[object4.style]
		UI.tween(object4.face, UI.SNAP, {
			BackgroundColor3 = v11.bg,
			BackgroundTransparency = v11.transparent and 1 or 0
		})
		release()
	end
	object4.face.MouseEnter:Connect(enter)
	object4.face.MouseLeave:Connect(leave)
	object4.face.SelectionGained:Connect(enter)
	object4.face.SelectionLost:Connect(leave)
	object4.face.MouseButton1Down:Connect(function()
		if not object4.enabled then
			return
		end

		v10 = true
		local v11 = styles[object4.style]

		if v11.depth > 0 then
			UI.tween(object4.face, 0.05, {
				Position = object4:restPosition() + UDim2.fromOffset(0, 2)
			})
		else
			UI.tween(object4.face, 0.05, {
				BackgroundColor3 = v11.hover:Lerp(Color3.new(0, 0, 0), 0.18),
				BackgroundTransparency = 0
			})
		end
	end)
	object4.face.MouseButton1Up:Connect(release)

	object4.face.InputBegan:Connect(function(input)
		if object4.enabled then
			return
		end

		local userInputType = input.UserInputType

		if userInputType == Enum.UserInputType.MouseButton1 or userInputType == Enum.UserInputType.Touch then
			Sound.play("locked")
			UI.shake(object4.face, 4, object4:restPosition())
		end
	end)
	object4.face.Activated:Connect(function()
		release()

		if object4.enabled and object4.callback then
			object4.callback(object4)
		end
	end)
	return object4
end

function class:restPosition()
	return UDim2.new(0.5, 0, 0.5, -styles[self.style].depth / 2)
end

function class.setText(p, text)
	if p.label then
		p.label.Text = text
	end
end

function class.setSubtext(p, text)
	if p.sublabel then
		p.sublabel.Text = text
	end
end

function class.setIcon(p, p2)
	if p.icon then
		Sprites.apply(p.icon, p2)
	end
end

function class:setEnabled(p)
	self.enabled = p
	self.face.Active = p
	self.face.Selectable = p
	local v8 = p and 0 or 0.45

	if self.label then
		UI.to(self.label, UI.SNAP, { TextTransparency = v8 })
	end

	if self.icon then
		UI.to(self.icon, UI.SNAP, { ImageTransparency = v8 })
	end
end

function class:setStyle(style)
	if self.style == style then
		return
	end

	self.style = style

	if not self.sfx then
		self.face:SetAttribute("Sfx", style == "primary" and "confirm" or "press")
	end

	UI.ink(self.label, style == "primary")
	primaryShade(self.face, style == "primary")
	local v8 = styles[style]
	UI.tween(self.face, UI.SNAP, {
		BackgroundColor3 = v8.bg,
		BackgroundTransparency = v8.transparent and 1 or 0
	})

	if style == "primary" then
		UI.pop(self.face, 0.9, 0.25)
	end

	self.face.Size = UDim2.new(1, 0, 1, -v8.depth)
	self.face.Position = self:restPosition()
	UI.tween(self.shadow, UI.SNAP, {
		BackgroundColor3 = v8.shadow or v8.bg,
		BackgroundTransparency = v8.shadow and 0 or 1
	})

	if self.label then
		UI.tween(self.label, UI.SNAP, { TextColor3 = v8.text })
	end

	if self.icon then
		UI.tween(self.icon, UI.SNAP, { ImageColor3 = v8.text })
	end
end

function class.setVisible(p, p2)
	UI.reveal(p.holder, p2, 4)
end

function UI.toggle(p, callback)
	local v8 = p and true or false
	local textButton = UI.new("TextButton", {
		Size = UDim2.fromOffset(42, 24),
		BackgroundColor3 = v8 and Theme.green or Theme.button,
		BackgroundTransparency = 0,
		Text = ""
	}, { UI.corner(UDim.new(1, 0)) })
	local frame = UI.new("Frame", {
		Size = UDim2.fromOffset(18, 18),
		Position = v8 and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Parent = textButton
	}, { UI.corner(UDim.new(1, 0)) })
	textButton:SetAttribute("Sfx", "none")
	local v9 = { frame = textButton }
	function v9.set(p2, p3)
		v8 = p2 and true or false
		UI.tween(textButton, 0.12, {
			BackgroundColor3 = v8 and Theme.green or Theme.button
		})

		if p3 then
			UI.tween(frame, 0.12, {
				Position = v8 and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
			})
		else
			frame.Size = UDim2.fromOffset(24, 16)
			UI.tween(frame, 0.2, {
				Position = v8 and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
			}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			UI.tween(frame, 0.22, { Size = UDim2.fromOffset(18, 18) }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		end

		if not p3 then
			if callback then
				callback(v8)
			end

			Sound.play(v8 and "toggleOn" or "toggleOff")
		end
	end
	textButton.Activated:Connect(function()
		v9.set(not v8)
	end)
	return v9
end

function UI.segmented(list, p, callback, value)
	local frame = UI.new("Frame", {
		Size = UDim2.new(1, 0, 0, value or 40),
		BackgroundColor3 = Theme.bgDark
	}, { UI.corner(6), UI.list(Enum.FillDirection.Horizontal, 4), UI.pad(4) })
	local textButtonsById = {}
	local v8 = { frame = frame, value = p }
	local function refresh()
		for k, v9 in textButtonsById do
			local v10 = k == v8.value
			UI.to(v9, UI.SNAP, {
				BackgroundColor3 = v10 and Theme.rowActive or Theme.bgDark,
				BackgroundTransparency = v10 and 0 or 1
			})
			local label = v9:FindFirstChild("Label", true)

			if label then
				UI.to(label, UI.SNAP, {
					TextColor3 = v10 and Theme.text or Theme.textDim
				})
			end

			local icon = v9:FindFirstChild("Icon", true)

			if icon then
				UI.to(icon, UI.SNAP, {
					ImageColor3 = v10 and (icon:GetAttribute("OnColor") or Theme.text) or Theme.textDim
				})
			end
		end
	end

	for k, item in list do
		local textButton = UI.new("TextButton", {
			Size = UDim2.new(1 / #list, (#list - 1) * -4 / #list, 1, 0),
			BackgroundColor3 = Theme.bgDark,
			LayoutOrder = k,
			Parent = frame
		}, {
			UI.corner(4),
			UI.list(Enum.FillDirection.Horizontal, 6, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center)
		})

		if item.icon then
			local icon = UI.icon(item.icon, 18, Theme.text, {
				Name = "Icon",
				LayoutOrder = 1,
				Parent = textButton
			})

			if item.iconColor then
				icon:SetAttribute("OnColor", item.iconColor)
			end
		end

		if item.label then
			UI.text({
				Name = "Label",
				Text = item.label,
				FontFace = Theme.fontBold,
				TextSize = 15,
				AutomaticSize = Enum.AutomaticSize.XY,
				Size = UDim2.new(),
				LayoutOrder = 2,
				Parent = textButton
			})
		end

		textButtonsById[item.id] = textButton
		textButton:SetAttribute("Sfx", "tab")
		textButton.MouseEnter:Connect(function()
			if v8.value ~= item.id then
				UI.tween(textButton, UI.FAST, {
					BackgroundColor3 = Theme.panelLight,
					BackgroundTransparency = 0.4
				})
			end
		end)
		textButton.MouseLeave:Connect(function()
			if v8.value ~= item.id then
				UI.tween(textButton, UI.SNAP, {
					BackgroundColor3 = Theme.bgDark,
					BackgroundTransparency = 1
				})
			end
		end)
		textButton.SelectionGained:Connect(function()
			if v8.value ~= item.id then
				UI.tween(textButton, UI.FAST, {
					BackgroundColor3 = Theme.panelLight,
					BackgroundTransparency = 0.4
				})
			end
		end)
		textButton.SelectionLost:Connect(function()
			if v8.value ~= item.id then
				UI.tween(textButton, UI.SNAP, {
					BackgroundColor3 = Theme.bgDark,
					BackgroundTransparency = 1
				})
			end
		end)
		textButton:SetAttribute("NoSquish", true)
		textButton.Activated:Connect(function()
			v8.value = item.id
			refresh()

			if callback then
				callback(item.id)
			end
		end)
	end

	function v8.set(p2)
		v8.value = p2
		refresh()
	end
	refresh()
	return v8
end

function UI.avatar(p, value, items)
	local v8 = value or 40
	local frame = UI.new(
		"Frame",
		{
			Name = "Avatar",
			Size = UDim2.fromOffset(v8, v8),
			BackgroundColor3 = Color3.fromRGB(58, 61, 68),
			ClipsDescendants = true
		},
		{ UI.corner((math.max(3, v8 // 12))) }
	)
	local imageLabel = UI.new("ImageLabel", {
		Name = "Image",
		Size = UDim2.fromScale(1, 1),
		Parent = frame
	})

	local v9 = { frame = frame }

	local function keyOf(data)
		if not data then
			return "none"
		end

		local bot

		if type(data.bot) == "table" then
			bot = data.bot or nil
		end

		local headshot = tostring(data.headshot)
		local avatar = tostring(data.avatar)
		local v10

		if data.bot == nil then
			v10 = false
		else
			v10 = data.bot ~= false
		end

		return table.concat({
			headshot,
			avatar,
			tostring(v10),
			tostring(data.icon),
			tostring(data.color or bot and bot.color),
			(tostring(data.userId))
		}, "|")
	end

	function v9.set(data)
		local v10 = keyOf(data)

		if v10 == v9.key then
			return
		end

		v9.key = v10

		for _, child in frame:GetChildren() do
			if child.Name == "BotIcon" or child.Name == "Initial" then
				child:Destroy()
			end
		end

		v9.token = (v9.token or 0) + 1

		if data and type(data.headshot) == "number" and not data.bot then
			imageLabel.Visible = true
			frame.BackgroundColor3 = Color3.fromRGB(58, 61, 68)
			imageLabel.Image = string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150", data.headshot)
		elseif data and data.avatar and not data.bot then
			imageLabel.Visible = false
			frame.BackgroundColor3 = Color3.fromRGB(58, 61, 68)
			local token = v9.token
			task.spawn(function()
				local chessBotAvatars = ReplicatedStorage:WaitForChild("ChessBotAvatars", 5)
				local child = chessBotAvatars and chessBotAvatars:WaitForChild(tostring(data.avatar), 5)

				if v9.token ~= token then
					return
				end

				if not (child and child:FindFirstChild("Head")) then
					v9.key = nil
					return
				end

				local viewportFrame = UI.new("ViewportFrame", {
					Name = "BotIcon",
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					Ambient = Color3.fromRGB(170, 170, 170),
					LightColor = Color3.fromRGB(255, 255, 255),
					LightDirection = Vector3.new(-0.4, -0.6, -1)
				})

				local clone = child:Clone()
				clone.Parent = viewportFrame
				local cframe = clone:FindFirstChild("Head").CFrame
				local camera = Instance.new("Camera")
				camera.FieldOfView = 26
				local v11 = cframe.Position + Vector3.new(0, 0.05, 0)
				local v12 = v11 + cframe.LookVector * 4.6 + cframe.RightVector * -1.1 + Vector3.new(0, 0.35, 0)
				camera.CFrame = CFrame.lookAt(v12, v11)
				camera.Parent = viewportFrame
				viewportFrame.CurrentCamera = camera
				viewportFrame.Parent = frame
			end)
		elseif data and (data.bot or data.icon) then
			imageLabel.Visible = false
			frame.BackgroundColor3 = data.color or data.bot and data.bot.color or Theme.button
			local icon = UI.icon(data.icon or "bot", math.floor(v8 * 0.62), Color3.new(1, 1, 1), {
				Name = "BotIcon",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				ImageTransparency = 0.05
			})

			icon.Parent = frame
		elseif data and data.userId and data.userId > 0 then
			imageLabel.Visible = true
			frame.BackgroundColor3 = Color3.fromRGB(58, 61, 68)
			local image = string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150", data.userId)

			if imageLabel.Image ~= image then
				imageLabel.Image = image
				imageLabel.ImageTransparency = 1
				UI.tween(imageLabel, 0.2, { ImageTransparency = 0 })
			end
		else
			imageLabel.Visible = false
			frame.BackgroundColor3 = Color3.fromRGB(58, 61, 68)

			local icon = UI.icon("person", math.floor(v8 * 0.62), Theme.textDim, {
				Name = "BotIcon",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5)
			})

			icon.Parent = frame
		end
	end
	v9.set(p)

	if items then
		for k, item in items do
			frame[k] = item
		end
	end

	return v9
end

return UI