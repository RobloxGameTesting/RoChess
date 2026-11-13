local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Chess.Config)
require(ReplicatedStorage.Chess.Sprites)
local Theme = require(script.Parent.Theme)
local UI = require(script.Parent.UI)
local Cosmetics = require(script.Parent.Cosmetics)

local BoardView = {}
BoardView.__index = BoardView

local v = { "a", "b", "c", "d", "e", "f", "g", "h" }

local function showAt(instance, position, backgroundTransparency, p)
	local key = instance:GetAttribute("Key")
	instance.Position = position

	if not instance.Visible or key ~= p then
		instance:SetAttribute("Key", p)
		instance.Visible = true
		instance.BackgroundTransparency = 1
		UI.tween(instance, 0.12, { BackgroundTransparency = backgroundTransparency })
	end
end

local function hide(instance) -- 5 equivalent calls inferred from this helper
	instance.Visible = false
	instance:SetAttribute("Key", nil)
end

local function fileRank(p) -- 6 equivalent calls inferred from this helper
	return (p - 1) % 8, (p - 1) // 8
end

local function sqOf(p, p2) -- 9 equivalent calls inferred from this helper
	return p2 * 8 + p + 1
end

local function isLight(p): boolean -- 3 equivalent calls inferred from this helper
	return ((p - 1) % 8 + (p - 1) // 8) % 2 == 1
end

local function sign(p): number -- 12 equivalent calls inferred from this helper
	if p > 0 then
		return 1
	end

	return if p < 0 then -1 else 0
end

local fn

function BoardView.new(parent, p)
	local object = setmetatable({}, BoardView)
	object.settings = p or Config.DEFAULT_SETTINGS
	object.flipped = false
	object.position = table.create(64, 0)
	object.pieces = {}
	object.interactive = false
	object.movable = 0
	object.turn = 1
	object.targets = {}
	object.selected = nil
	object.premove = nil
	object.premoves = {}
	object.realPosition = table.create(64, 0)
	object.realLast = nil
	object.marks = {}
	object.arrows = {}
	object.lastMove = nil
	object.checkSq = nil
	object.sqPx = 60

	object.loadouts = { [1] = {}, [-1] = {} }

	local udim = UDim.new(0.024, 0)
	object.frame = UI.new("Frame", {
		Name = "Board",
		Size = UDim2.fromOffset(480, 480),
		BackgroundTransparency = 1,
		ClipsDescendants = false,
		Parent = parent
	}, { UI.corner(udim) })
	object.outline = Instance.new("UIStroke")
	object.outline.Name = "Outline"
	object.outline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	object.outline.Color = Theme.outline or Color3.fromRGB(64, 89, 120)
	object.outline.Thickness = 5
	object.outline.Parent = object.frame
	local bezel = Instance.new("UIGradient")
	bezel.Name = "Bezel"
	bezel.Rotation = 90
	bezel.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(140, 144, 156))
	bezel.Parent = object.outline
	local function layer(name, zIndex)
		return UI.new("Frame", {
			Name = name,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			ZIndex = zIndex,
			Parent = object.frame
		})
	end

	object.squareLayer = UI.new("CanvasGroup", {
		Name = "Squares",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 1,
		Parent = object.frame
	}, { UI.corner(udim) })

	object.hlLayer = layer("Highlights", 2)
	object.hlLayer.Parent = object.squareLayer
	object.coordLayer = layer("Coords", 3)
	object.hintLayer = layer("Hints", 4)
	object.pieceLayer = layer("Pieces", 5)
	object.shadeLayer = UI.new("Frame", {
		Name = "Shades",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 0,
		Parent = object.pieceLayer
	})

	object.arrowLayer = layer("Arrows", 6)
	object.dragLayer = layer("Drag", 7)
	object.overlayLayer = layer("Overlay", 9)

	object.squares = {}

	for i = 1, 64 do
		object.squares[i] = UI.new("Frame", {
			Name = "S" .. i,
			Size = UDim2.fromScale(0.125, 0.125),
			Parent = object.squareLayer
		})
	end

	local function hl(name, backgroundColor, backgroundTransparency)
		return UI.new("Frame", {
			Name = name,
			Size = UDim2.fromScale(0.125, 0.125),
			BackgroundColor3 = backgroundColor,
			BackgroundTransparency = backgroundTransparency,
			Visible = false,
			Parent = object.hlLayer
		})
	end

	object.hlFrom = hl("LastFrom", Theme.highlight, Theme.highlightAlpha)
	object.hlTo = hl("LastTo", Theme.highlight, Theme.highlightAlpha)
	object.hlSel = hl("Selected", Theme.highlight, Theme.highlightAlpha)

	object.preFrames = {}
	function object.makePreFrame(p2)
		local v2 = hl("Pre" .. p2, Theme.premove, 0.45)
		object.preFrames[p2] = v2
		return v2
	end

	object.hlCheck = UI.new("Frame", {
		Name = "Check",
		Size = UDim2.fromScale(0.125, 0.125),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = object.hlLayer
	})

	for k, v2 in {
		{ 1, 0.72 },
		{ 0.78, 0.62 },
		{ 0.55, 0.5 }
	} do
		UI.new("Frame", {
			Name = "Ring" .. k,
			Size = UDim2.fromScale(v2[1], v2[1]),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Theme.check,
			BackgroundTransparency = v2[2],
			Parent = object.hlCheck
		}, { UI.corner(UDim.new(1, 0)) })
	end

	object.hoverFrame = UI.new("Frame", {
		Name = "Hover",
		Size = UDim2.fromScale(0.125, 0.125),
		BackgroundTransparency = 1,
		Visible = false,
		ZIndex = 3,
		Parent = object.hlLayer
	})

	object.hoverStroke = UI.stroke(Color3.new(1, 1, 1), 3, 0.35)
	object.hoverStroke.Parent = object.hoverFrame

	object.rankLabels = {}
	object.fileLabels = {}

	for i = 1, 8 do
		object.rankLabels[i] = UI.text({
			Name = "Rank" .. i,
			Size = UDim2.fromScale(0.125, 0.125),
			FontFace = Theme.font,
			TextTransparency = 0.1,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			Parent = object.coordLayer
		})

		object.fileLabels[i] = UI.text({
			Name = "File" .. i,
			Size = UDim2.fromScale(0.125, 0.125),
			FontFace = Theme.font,
			TextTransparency = 0.1,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextYAlignment = Enum.TextYAlignment.Bottom,
			Parent = object.coordLayer
		})
	end

	object.hints = {}

	for i = 1, 32 do
		local frame = UI.new("Frame", {
			Name = "Hint" .. i,
			Size = UDim2.fromScale(0.125, 0.125),
			BackgroundTransparency = 1,
			Visible = false,
			Parent = object.hintLayer
		})

		local frame2 = UI.new("Frame", {
			Name = "Dot",
			Size = UDim2.fromScale(0.33, 0.33),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.86,
			Parent = frame
		}, { UI.corner(UDim.new(1, 0)) })
		local frame3 = UI.new("Frame", {
			Name = "Ring",
			Size = UDim2.fromScale(0.9, 0.9),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Visible = false,
			Parent = frame
		}, { UI.corner(UDim.new(1, 0)) })
		local stroke = UI.stroke(Color3.new(0, 0, 0), 6, 0.86)
		stroke.Parent = frame3
		object.hints[i] = { frame = frame, dot = frame2, ring = frame3, stroke = stroke }
	end

	object.input = UI.new("TextButton", {
		Name = "Input",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		ZIndex = 8,
		Selectable = false,
		Parent = object.frame
	})

	object:applyTheme()
	object:layoutStatic()
	object:connectInput()
	object.frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		object:onResize()
	end)
	object:onResize()
	return object
end

function BoardView:colRow(p)
	local v2, v3 = fileRank(p) -- inferred equivalent call

	if self.flipped then
		return 7 - v2, v3
	end

	return v2, 7 - v3
end

function BoardView:sqPos(p)
	local colRow, v2 = self:colRow(p)
	return UDim2.fromScale(colRow / 8, v2 / 8)
end

local function pieceDown(value): number
	local v2 = math.abs(value or 0)
	return if v2 == 1 or v2 == 4 then 0.07 else 0.02
end

function BoardView:piecePos(p, value)
	local sqPos = self:sqPos(p)
	local v2 = math.abs(value or 0)
	return sqPos + UDim2.fromScale(0, ((v2 == 1 or v2 == 4) and 0.07 or 0.02) / 8)
end

function BoardView:sqCenterPx(p)
	local colRow, v2 = self:colRow(p)
	return Vector2.new((colRow + 0.5) * self.sqPx, (v2 + 0.5) * self.sqPx)
end

function BoardView:squareAt(p)
	local v2 = p - self.frame.AbsolutePosition
	local x = self.frame.AbsoluteSize.X

	if v2.X < 0 or v2.Y < 0 or x <= v2.X or x <= v2.Y then
		return nil
	end

	local v3 = math.floor(v2.X / x * 8)
	local v4 = math.floor(v2.Y / x * 8)

	if not self.flipped then
		return sqOf(v3, 7 - v4) -- inferred equivalent call
	end

	return sqOf(7 - v3, v4) -- inferred equivalent call
end

function BoardView:layoutStatic()
	for i = 1, 64 do
		self.squares[i].Position = self:sqPos(i)
	end

	local theme = self.theme

	for i = 0, 7 do
		local rankLabel = self.rankLabels[i + 1]
		local v2 = self.flipped and i or 7 - i
		local v3 = self.flipped and 7 or 0
		rankLabel.Position = UDim2.fromScale(0, i / 8)
		rankLabel.Text = tostring(v2 + 1)
		rankLabel.TextColor3 = isLight(sqOf(v3, v2)) and theme.dark or theme.light -- inferred equivalent call
	end

	for i = 0, 7 do
		local fileLabel = self.fileLabels[i + 1]
		local v2

		if self.flipped then
			v2 = 7 - i or i
		else
			v2 = i
		end

		local v3 = self.flipped and 7 or 0
		fileLabel.Position = UDim2.fromScale(i / 8, 0.875)
		fileLabel.Text = v[v2 + 1]
		fileLabel.TextColor3 = isLight(sqOf(v2, v3)) and theme.dark or theme.light -- inferred equivalent call
	end

	for k, piece in self.pieces do
		piece.Position = self:piecePos(k, self.position[k])
	end

	self:refreshHighlights()
	self:redrawArrows()
	self:layoutCursor(true)
end

function BoardView:onResize()
	local x = self.frame.AbsoluteSize.X

	if x <= 0 then
		return
	end

	self.sqPx = x / 8
	local textSize = math.max(9, (math.floor(self.sqPx * 0.2)))
	local v2 = math.max(2, (math.floor(self.sqPx * 0.05)))

	for i = 1, 8 do
		for k, parent in { self.rankLabels[i], self.fileLabels[i] } do
			parent.TextSize = textSize
			local uiPadding = parent:FindFirstChildOfClass("UIPadding") or UI.pad(0)
			uiPadding.PaddingTop = UDim.new(0, v2 - 1)
			uiPadding.PaddingLeft = UDim.new(0, v2)
			uiPadding.PaddingRight = UDim.new(0, v2)
			uiPadding.PaddingBottom = UDim.new(0, v2 - 2)
			uiPadding.Parent = parent
		end
	end

	for k, hint in self.hints do
		hint.stroke.Thickness = math.max(3, (math.floor(self.sqPx * 0.085)))
	end

	local v3 = math.max(2, (math.floor(self.sqPx * 0.05)))
	self.hoverStroke.Thickness = v3
	self.hoverStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	self.hoverInset = v3
	self:layoutCursor()
	self:redrawArrows()

	if self.promoState then
		self:layoutPromotion()
	end
end

function BoardView:applyTheme()
	local theme = Config.THEME_BY_ID[self.settings.theme] or Config.BOARD_THEMES[1]
	self.theme = theme

	for i = 1, 64 do
		self.squares[i].BackgroundColor3 = isLight(i) and theme.light or theme.dark -- inferred equivalent call
	end

	Cosmetics.styleBoard(self)
	self.coordLayer.Visible = self.settings.coords ~= false
	self:layoutStatic()
end

function BoardView:paint(instance, value, p)
	if instance.Name == "DragPiece" then
		local v2 = math.abs(value or 0)
		instance.AnchorPoint = Vector2.new(0.5, 0.5 - ((v2 == 1 or v2 == 4) and 0.07 or 0.02))
	elseif instance.Name == "Ghost" then
		instance.AnchorPoint = Vector2.zero
		local v2 = math.abs(value or 0)
		instance.Position = UDim2.fromScale(0, (v2 == 1 or v2 == 4) and 0.07 or 0.02)
	end

	local v2 = sign(value) -- inferred equivalent call
	local v3 = self.loadouts[v2] or {}
	Cosmetics.paintPiece(instance, value, v3.pieces)
	local setHat = Cosmetics.setHat
	local v4

	if not (p or math.abs(value) ~= 6) then
		v4 = v3.accessory or nil
	end

	setHat(instance, v4)

	local v5 = instance:FindFirstChild("Hat") and 3 or nil

	if instance:GetAttribute("BaseZ") ~= v5 then
		instance:SetAttribute("BaseZ", v5)

		if instance.Parent == self.pieceLayer and instance.ZIndex ~= 4 then
			instance.ZIndex = v5 or 1
		end
	end
end

function BoardView:setLoadouts(options, options2)
	local v2 = options or {}
	local v3 = options2 or {}
	local loadouts = self.loadouts

	if
		loadouts[1].pieces == v2.pieces
		and loadouts[1].accessory == v2.accessory
		and loadouts[-1].pieces == v3.pieces
		and loadouts[-1].accessory == v3.accessory
	then
		return
	end

	self.loadouts = { [1] = v2, [-1] = v3 }

	for k, piece in self.pieces do
		self:paint(piece, self.position[k])
	end
end

function BoardView:playEffect(p, p2, p3)
	if p and p2 then
		return Cosmetics.playEffect(self.overlayLayer, self:sqCenterPx(p), self.sqPx, p2, p3, {
			shake = function(p4, p5)
				self:shake(p4, p5)
			end
		})
	end

	return false
end

function BoardView:shake(p, p2)
	local v2 = {
		self.squareLayer,
		self.coordLayer,
		self.hintLayer,
		self.pieceLayer,
		self.arrowLayer
	}
	self.shakeToken = (self.shakeToken or 0) + 1
	local shakeToken = self.shakeToken
	local lastTime = os.clock()
	local renderSteppedConnection = nil
	local RunService = game:GetService("RunService")
	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		local v3 = (os.clock() - lastTime) / p2

		if v3 >= 1 or shakeToken ~= self.shakeToken then
			renderSteppedConnection:Disconnect()

			if shakeToken == self.shakeToken then
				for k, v4 in v2 do
					v4.Position = UDim2.new()
				end
			end
		else
			local v4 = p * (1 - v3) ^ 2
			local udim = UDim2.fromOffset(math.random(-100, 100) / 100 * v4, math.random(-100, 100) / 100 * v4)

			for k, v5 in v2 do
				v5.Position = udim
			end
		end
	end)
end

function BoardView:applySettings(settings)
	self.settings = settings
	local themeKey = tostring(settings and settings.theme) .. "|" .. tostring(settings and settings.coords)

	if themeKey ~= self._themeKey then
		self._themeKey = themeKey
		self:applyTheme()
	end

	self:refreshHighlights()
end

function BoardView:setFlipped(flipped)
	if self.flipped == flipped then
		return
	end

	self.flipped = flipped
	self:cancelDrag()
	self:hidePromotion()
	self:layoutStatic()

	if self.selected then
		self:showTargets()
	end
end

function BoardView:makePiece(p, p2)
	local imageLabel = UI.new("ImageLabel", {
		Name = "P",
		AnchorPoint = Vector2.zero,
		Size = UDim2.fromScale(0.125, 0.125),
		Position = self:piecePos(p, p2),
		ScaleType = Enum.ScaleType.Fit,
		Parent = self.pieceLayer
	})

	self:paint(imageLabel, p2)
	self:attachShade(imageLabel)
	return imageLabel
end

function BoardView:attachShade(instance)
	if not self.shadeLayer then
		return
	end

	local shade = Instance.new("ImageLabel")
	shade.Name = "Shade"
	shade.BackgroundTransparency = 1
	shade.ImageColor3 = Color3.new(0, 0, 0)
	shade.Parent = self.shadeLayer
	local function sync()
		if not shade.Parent then
			return
		end

		shade.Image = instance.Image
		shade.ImageRectOffset = instance.ImageRectOffset
		shade.ImageRectSize = instance.ImageRectSize
		shade.ScaleType = instance.ScaleType
		shade.AnchorPoint = instance.AnchorPoint
		shade.Size = instance.Size
		shade.Rotation = instance.Rotation
		shade.Position = instance.Position + UDim2.fromOffset(0, (math.max(2, (math.floor(self.sqPx * 0.045)))))
		shade.ImageTransparency = 0.8 + 0.19999999999999996 * instance.ImageTransparency
		shade.Visible = instance.Visible and instance.Parent == self.pieceLayer
	end
	sync()
	instance.Changed:Connect(sync)
	instance.Destroying:Connect(function()
		shade:Destroy()
	end)
end

local function withPremoves(p, premoves, p2)
	local clone = table.clone(p)
	local v2 = 0

	for k, item in premoves do
		local v3 = clone[item.from]

		if v3 == 0 or sign(v3) ~= p2 then -- inferred equivalent call
			break
		end

		local v4 = math.abs(v3)
		local v5, v6 = fileRank(item.from) -- inferred equivalent call
		local v7, v8 = fileRank(item.to) -- inferred equivalent call
		clone[item.from] = 0

		if v4 == 1 and (v8 == 7 or v8 == 0) then
			v3 = p2 * (item.promo and item.promo > 0 and item.promo or 5)
		end

		clone[item.to] = v3

		if v4 == 6 and math.abs(v7 - v5) == 2 then
			local v9 = sqOf(v5 < v7 and 7 or 0, v6) -- inferred equivalent call
			local v10 = sqOf(v5 < v7 and 5 or 3, v6) -- inferred equivalent call

			if clone[v9] == 4 * p2 then
				clone[v10] = clone[v9]
				clone[v9] = 0
			end
		end

		v2 = k
	end

	return clone, v2
end

function BoardView:setPosition(list, realLast, p)
	if self.promoState and self.realPosition then
		for i = 1, 64 do
			if list[i] ~= self.realPosition[i] then
				self:hidePromotion()
				break
			end
		end
	end

	self.realPosition = table.clone(list)
	self.realLast = realLast

	if #self.premoves == 0 then
		self:drawPosition(list, realLast, p)
		return
	end

	local v2, v3 = withPremoves(list, self.premoves, self:premoveColor())

	if v3 < #self.premoves then
		for i = #self.premoves, v3 + 1, -1 do
			table.remove(self.premoves, i)
		end

		self:premovesChanged()
	end

	self:drawPosition(v2, realLast, p)
end

function BoardView:premoveColor()
	if self.movable == 1 or self.movable == -1 then
		return self.movable
	end

	return -self.turn
end

function BoardView:redrawPremoves(p)
	self:drawPosition(withPremoves(self.realPosition, self.premoves, self:premoveColor()), self.realLast, {
		instant = p and { [p] = true } or nil
	})
end

function BoardView:premovesChanged()
	self.premove = self.premoves[1]

	if self.onPremove then
		self.onPremove(self.premove)
	end
end

function BoardView:drawPosition(list, lastMove, options)
	local v2 = options or {}
	local v3

	if v2.animate == false then
		v3 = false
	else
		v3 = self.settings.animate ~= false
	end

	local position = self.position
	local sq = self.dragState and self.dragState.sq or self.press and self.press.sq
	local v4

	if sq == nil then
		v4 = false
	else
		v4 = list[sq] == position[sq]
	end

	local v5 = {}
	local v6 = {}

	for i = 1, 64 do
		local v7 = position[i]
		local item = list[i]

		if v7 == item then
			continue
		end

		if v7 ~= 0 then
			table.insert(v6, i)
		end

		if item ~= 0 then
			table.insert(v5, i)
		end
	end

	local v7 = {}

	for k, sq2 in v6 do
		local piece = self.pieces[sq2]

		if piece then
			table.insert(v7, { sq = sq2, code = position[sq2], label = piece })
		end

		self.pieces[sq2] = nil
	end

	local function dist(sq2, p) -- 2 equivalent calls inferred from this helper
		local v8, v9 = fileRank(sq2) -- inferred equivalent call
		local v10, v11 = fileRank(p) -- inferred equivalent call
		return math.abs(v8 - v10) + math.abs(v9 - v11)
	end

	local v8 = {}
	local v9 = {}

	for k, to in v5 do
		local item = list[to]
		local v10 = nil
		local v11 = nil

		for k2, v12 in v7 do
			if v12.code ~= item then
				continue
			end

			local v13 = dist(v12.sq, to) -- inferred equivalent call

			if not (not v10 or v13 < v11) then
				continue
			end

			v11 = v13
			v10 = k2
		end

		if v10 then
			local v12 = table.remove(v7, v10)
			table.insert(v8, { label = v12.label, from = v12.sq, to = to })
		else
			table.insert(v9, to)
		end
	end

	for k, to in v9 do
		local item = list[to]
		local v10 = nil
		local v11 = nil

		for k2, v12 in v7 do
			if v12.code ~= sign(item) * 1 then -- inferred equivalent call
				continue
			end

			local v13 = dist(v12.sq, to) -- inferred equivalent call

			if not (v13 <= 2 and (not v10 or v13 < v11)) then
				continue
			end

			v11 = v13
			v10 = k2
		end

		if v10 then
			local v12 = table.remove(v7, v10)
			table.insert(v8, { label = v12.label, from = v12.sq, to = to, promote = item })
		else
			local piece = self:makePiece(to, item)
			self.pieces[to] = piece

			if v3 then
				piece.ImageTransparency = 1
				UI.tween(piece, 0.13, { ImageTransparency = 0 })
			end
		end
	end

	for k, v10 in v8 do
		local label = v10.label
		self.pieces[v10.to] = label
		label.ImageTransparency = 0

		if v10.promote then
			self:paint(label, v10.promote)
		end

		local piecePos = self:piecePos(v10.to, list[v10.to])

		if v3 and not (v2.instant and v2.instant[v10.to]) then
			label.ZIndex = 4
			local tween = TweenService:Create(
				label,
				TweenInfo.new(0.13, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
				{ Position = piecePos }
			)
			tween.Completed:Connect(function()
				label.ZIndex = label:GetAttribute("BaseZ") or 1
			end)
			tween:Play()
		else
			label.Position = piecePos
		end
	end

	for k, v10 in v7 do
		local label = v10.label

		if v3 then
			label.ZIndex = 0
			UI.tween(label, 0.13, { ImageTransparency = 1 }).Completed:Connect(function()
				label:Destroy()
			end)
		else
			label:Destroy()
		end
	end

	self.position = table.clone(list)
	self.lastMove = lastMove

	if sq and not v4 then
		self:cancelDrag()
	end

	if self.selected and self.position[self.selected] == 0 then
		self:deselect()
	elseif self.selected then
		if self.selectingPremove then
			self.targets = fn(self.position, self.selected, self.position[self.selected])
		end

		self:showTargets()
	end

	self:refreshHighlights()
end

function BoardView:setCheck(checkSq)
	self.checkSq = checkSq
	self:refreshHighlights()
end

function BoardView:refreshHighlights()
	local lastMove = self.lastMove
	local v2 = lastMove and self.settings.highlightLast ~= false

	if v2 and lastMove.from then
		showAt(self.hlFrom, self:sqPos(lastMove.from), Theme.highlightAlpha, lastMove.from)
	else
		hide(self.hlFrom) -- inferred equivalent call
	end

	if v2 and lastMove.to then
		showAt(self.hlTo, self:sqPos(lastMove.to), Theme.highlightAlpha, lastMove.to)
	else
		hide(self.hlTo) -- inferred equivalent call
	end

	if self.selected then
		showAt(self.hlSel, self:sqPos(self.selected), Theme.highlightAlpha, self.selected)
	else
		hide(self.hlSel) -- inferred equivalent call
	end

	if self.checkSq then
		local v3 = not self.hlCheck.Visible or self.hlCheck:GetAttribute("Key") ~= self.checkSq
		self.hlCheck.Position = self:sqPos(self.checkSq)
		self.hlCheck.Visible = true

		if v3 then
			self.hlCheck:SetAttribute("Key", self.checkSq)
			UI.pop(self.hlCheck, 0.4, 0.22)
		end
	else
		hide(self.hlCheck) -- inferred equivalent call
	end

	local set = {}
	local count = 0

	for k, premove in self.premoves do
		for k2, v3 in { premove.from, premove.to } do
			if set[v3] then
				continue
			end

			set[v3] = true
			count += 1
			showAt(self.preFrames[count] or self.makePreFrame(count), self:sqPos(v3), 0.45, v3)
		end
	end

	for i = count + 1, #self.preFrames do
		hide(self.preFrames[i]) -- inferred equivalent call
	end

	if self.tints then
		for k, tint in self.tints do
			tint.frame.Position = self:sqPos(tint.sq)
		end
	end
end

function BoardView:setTint(p, sq, p2, value)
	self.tints = self.tints or {}
	local v2 = self.tints[p]

	if sq then
		local v3 = v2 == nil or v2.sq ~= sq

		if not v2 then
			v2 = {
				frame = UI.new("Frame", {
					Name = "Tint_" .. p,
					Size = UDim2.fromScale(0.125, 0.125),
					ZIndex = 2,
					Parent = self.hlLayer
				})
			}

			self.tints[p] = v2
		end

		v2.sq = sq
		v2.frame.BackgroundColor3 = p2 or Theme.highlight
		v2.frame.Position = self:sqPos(sq)

		if not v3 then
			v2.frame.BackgroundTransparency = value or 0.45

			return
		end

		v2.frame.BackgroundTransparency = 1
		UI.tween(v2.frame, 0.12, {
			BackgroundTransparency = value or 0.45
		})
	elseif v2 then
		local frame = v2.frame
		self.tints[p] = nil
		UI.tween(frame, 0.1, { BackgroundTransparency = 1 }).Completed:Connect(function()
			frame:Destroy()
		end)
	end
end

function BoardView:clearTints()
	if self.tints then
		for k in self.tints do
			self:setTint(k, nil)
		end
	end
end

function BoardView:canPick(p): boolean
	if p == 0 or not self.interactive then
		return false
	end

	local v2 = sign(p) -- inferred equivalent call

	if self.movable == 2 then
		return v2 == self.turn
	end

	return self.movable == v2 and (v2 == self.turn or self.settings.premove ~= false)
end

fn = function(position, selected, p)
	local v2 = {}
	local v3 = sign(p) -- inferred equivalent call
	local v4 = math.abs(p)
	local v5, v6 = fileRank(selected) -- inferred equivalent call

	local function add(p2, p3) -- 8 equivalent calls inferred from this helper
		if p2 >= 0 and p2 < 8 and p3 >= 0 and p3 < 8 then
			v2[sqOf(p2, p3)] = v4 == 1 and (v3 == 1 and p3 == 7 or v3 == -1 and p3 == 0) -- inferred equivalent call
		end
	end

	if v4 == 1 then
		add(v5, v6 + v3) -- inferred equivalent call

		if v3 == 1 and v6 == 1 or v3 == -1 and v6 == 6 then
			add(v5, v6 + 2 * v3) -- inferred equivalent call
		end

		add(v5 - 1, v6 + v3) -- inferred equivalent call
		local v7 = v5 + 1
		local v8 = v6 + v3

		if v7 >= 0 and v7 < 8 and v8 >= 0 and v8 < 8 then
			v2[v8 * 8 + v7 + 1] = v4 == 1 and (v3 == 1 and v8 == 7 or v3 == -1 and v8 == 0)
			return v2
		end
	elseif v4 == 2 then
		for k, v7 in {
			{ 1, 2 },
			{ 2, 1 },
			{ -1, 2 },
			{ -2, 1 },
			{ 1, -2 },
			{ 2, -1 },
			{ -1, -2 },
			{ -2, -1 }
		} do
			add(v5 + v7[1], v6 + v7[2]) -- inferred equivalent call
		end

		return v2
	elseif v4 == 6 then
		for i = -1, 1 do
			add(v5 + i, v6 + -1) -- inferred equivalent call

			if i ~= 0 then
				add(v5 + i, v6 + 0) -- inferred equivalent call
			end

			add(v5 + i, v6 + 1) -- inferred equivalent call
		end

		local v7 = v3 == 1 and 0 or 7

		if v5 == 4 and v6 == v7 then
			if v7 >= 0 and v7 < 8 then
				v2[v7 * 8 + 6 + 1] = v4 == 1 and (v3 == 1 and v7 == 7 or v3 == -1 and v7 == 0)
			end

			if v7 >= 0 and v7 < 8 then
				v2[v7 * 8 + 2 + 1] = v4 == 1 and (v3 == 1 and v7 == 7 or v3 == -1 and v7 == 0)
				return v2
			end
		end
	else
		local v7 = {}

		if v4 == 3 or v4 == 5 then
			for k, v8 in {
				{ 1, 1 },
				{ 1, -1 },
				{ -1, 1 },
				{ -1, -1 }
			} do
				table.insert(v7, v8)
			end
		end

		if v4 == 4 or v4 == 5 then
			for k, v8 in {
				{ 1, 0 },
				{ -1, 0 },
				{ 0, 1 },
				{ 0, -1 }
			} do
				table.insert(v7, v8)
			end
		end

		for k, v8 in v7 do
			local v9 = v5 + v8[1]
			local v10 = v6 + v8[2]

			while v9 >= 0 and v9 < 8 and v10 >= 0 and v10 < 8 do
				add(v9, v10) -- inferred equivalent call
				v9 += v8[1]
				v10 += v8[2]
			end
		end
	end

	return v2
end

function BoardView:select(selected)
	self.selected = selected
	local v2 = self.position[selected]

	if sign(v2) == self.turn and #self.premoves == 0 then -- inferred equivalent call
		self.targets = self.getTargets and self.getTargets(selected) or {}
		self.selectingPremove = false
	else
		self.targets = fn(self.position, selected, v2)
		self.selectingPremove = true
	end

	self:showTargets()
	self:refreshHighlights()
end

function BoardView:deselect()
	self.selected = nil
	self.targets = {}
	self:showTargets()
	self:refreshHighlights()
end

function BoardView:showTargets()
	local count = 0

	if self.selected and self.settings.showLegal ~= false then
		for k in self.targets do
			count += 1
			local hint = self.hints[count]

			if not hint then
				break
			end

			local visible = self.position[k] ~= 0
			local v2 = not hint.frame.Visible or hint.sq ~= k or self.hintsFor ~= self.selected
			hint.sq = k
			hint.frame.Position = self:sqPos(k)
			hint.frame.Visible = true
			hint.dot.Visible = not visible
			hint.ring.Visible = visible

			if v2 then
				UI.pop(visible and hint.ring or hint.dot, 0.2, 0.16)
			end
		end
	end

	for i = count + 1, #self.hints do
		self.hints[i].frame.Visible = false
	end

	self.hintsFor = self.selected
	self:refreshCursorGhost()
end

function BoardView:setInteractive(interactive)
	self.interactive = interactive

	if not interactive then
		self:cancelDrag()
		self:deselect()
		self:hidePromotion()
	end
end

function BoardView:setMovable(movable)
	self.movable = movable
end

function BoardView:setTurn(turn)
	self.turn = turn

	if self.selected then
		local selected = self.selected

		if self.position[selected] == 0 or not self:canPick(self.position[selected]) then
			self:deselect()
		else
			self:select(selected)
		end
	end
end

function BoardView:setPremove(premove)
	local v2 = #self.premoves > 0
	local premoves

	if premove then
		premoves = { premove } or {}
	else
		premoves = {}
	end

	self.premoves = premoves
	self.premove = premove

	if v2 or premove then
		self:redrawPremoves()
	else
		self:refreshHighlights()
	end
end

function BoardView:addPremove(p, p2): boolean
	if #self.premoves >= 10 then
		return false
	end

	table.insert(self.premoves, p)
	self:redrawPremoves(p2)
	self:premovesChanged()
	return true
end

function BoardView:shiftPremove()
	local v2 = table.remove(self.premoves, 1)

	if v2 then
		self:premovesChanged()
	end

	return v2
end

function BoardView:clearPremove()
	local v2 = #self.premoves > 0
	self.premoves = {}

	if self.realPosition then
		self:redrawPremoves()
	end

	if v2 then
		self:premovesChanged()
	end
end

function BoardView:tryMove(from, to, p)
	local v2 = self.position[from]
	local target = self.targets[to]

	if self.selectingPremove then
		self:deselect()
		local function add(promo) -- 2 equivalent calls inferred from this helper
			self:addPremove({ from = from, to = to, promo = promo }, p and to or nil)
		end

		if target and (self.noAutoQueen or not self.settings.autoQueen) then
			self:showPromotion(from, to, sign(v2), function(promo) -- inferred equivalent call
				if promo then
					add(promo) -- inferred equivalent call
				end
			end)
		else
			add(target and 5 or 0) -- inferred equivalent call
		end
	else
		if not target or not self.noAutoQueen and self.settings.autoQueen then
			self:commit(from, to, target and 5 or 0, p)
			return
		end

		self:deselect()

		local v3 = p and self.pieces[from]

		if v3 then
			v3.Position = self:piecePos(to, v2)
		end

		local function restore() -- 1 equivalent call inferred from this helper
			local piece = self.pieces[from]

			if piece and piece.Parent then
				piece.Position = self:piecePos(from, self.position[from])
			end
		end
		self:showPromotion(from, to, sign(v2), function(p2) -- inferred equivalent call
			restore() -- inferred equivalent call

			if p2 then
				self:commit(from, to, p2, false)
			end
		end, restore)
	end
end

local v2 = 0
function BoardView.fromInput(): boolean
	return v2 > 0
end

function BoardView:commit(p, p2, p3, p4)
	self:deselect()

	if self.onMove then
		v2 += 1
		local success, result = xpcall(self.onMove, debug.traceback, p, p2, p3, p4)
		v2 -= 1

		if not success then
			error(result, 0)
		end

		local v3 = not result and p4 and self.pieces[p]

		if v3 then
			UI.tween(v3, 0.13, {
				Position = self:piecePos(p, self.position[p])
			}, Enum.EasingStyle.Cubic)
		end
	end
end

function BoardView:showPromotion(p, to, p2, callback, onDismiss)
	self:hidePromotion()

	local set = {}
	local function arm(p3) -- 3 equivalent calls inferred from this helper
		p3.InputBegan:Connect(function(input)
			local userInputType = input.UserInputType

			if userInputType == Enum.UserInputType.MouseButton1 or userInputType == Enum.UserInputType.Touch then
				set[p3] = true
			end
		end)
	end
	local function counts(p3, p4): boolean -- 3 equivalent calls inferred from this helper
		local userInputType = p4 and p4.UserInputType

		if userInputType == Enum.UserInputType.MouseButton1 or userInputType == Enum.UserInputType.Touch then
			return set[p3] == true
		end

		return true
	end

	local textButton = UI.new("TextButton", {
		Name = "PromoDim",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.6,
		Text = "",
		Selectable = false,
		Parent = self.overlayLayer
	})

	local frame = UI.new("Frame", {
		Name = "PromoColumn",
		BackgroundColor3 = Color3.new(1, 1, 1),
		SelectionGroup = true,
		SelectionBehaviorUp = Enum.SelectionBehavior.Stop,
		SelectionBehaviorDown = Enum.SelectionBehavior.Stop,
		SelectionBehaviorLeft = Enum.SelectionBehavior.Stop,
		SelectionBehaviorRight = Enum.SelectionBehavior.Stop,
		Parent = self.overlayLayer
	}, { UI.corner(4) })
	local stroke = UI.stroke(Color3.new(0, 0, 0), 2, 0.6)
	stroke.Parent = frame

	local imageButtons = {}

	for k, v3 in { 5, 2, 4, 3 } do
		local imageButton = UI.new("ImageButton", {
			Name = "Choice" .. v3,
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 1,
			ScaleType = Enum.ScaleType.Fit,
			Parent = frame
		})

		self:paint(imageButton, v3 * p2)
		imageButton.MouseEnter:Connect(function()
			imageButton.BackgroundTransparency = 0
			imageButton.BackgroundColor3 = Color3.fromRGB(225, 225, 225)
		end)
		imageButton.MouseLeave:Connect(function()
			imageButton.BackgroundTransparency = 1
		end)
		imageButton.SelectionGained:Connect(function()
			imageButton.BackgroundTransparency = 0
			imageButton.BackgroundColor3 = Color3.fromRGB(225, 225, 225)
		end)
		imageButton.SelectionLost:Connect(function()
			imageButton.BackgroundTransparency = 1
		end)
		arm(imageButton) -- inferred equivalent call
		imageButton.Activated:Connect(function(p3)
			if not counts(imageButton, p3) then -- inferred equivalent call
				return
			end

			self:hidePromotion(true)
			callback(v3)
		end)
		imageButtons[k] = imageButton
	end

	local textButton2 = UI.new("TextButton", {
		Name = "Cancel",
		BackgroundColor3 = Color3.fromRGB(240, 240, 240),
		Text = "",
		Parent = frame
	})

	local icon = UI.icon("close", 20, Color3.fromRGB(110, 110, 110), {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Parent = textButton2
	})

	local function cancelPick() -- 2 equivalent calls inferred from this helper
		self:hidePromotion(true)
		callback(nil)
	end

	arm(textButton2) -- inferred equivalent call
	arm(textButton) -- inferred equivalent call
	textButton2.Activated:Connect(function(p3)
		if counts(textButton2, p3) then -- inferred equivalent call
			cancelPick() -- inferred equivalent call
		end
	end)
	textButton.Activated:Connect(function(p3)
		if counts(textButton, p3) then -- inferred equivalent call
			cancelPick() -- inferred equivalent call
		end
	end)
	textButton.BackgroundTransparency = 1
	UI.tween(textButton, UI.SNAP, { BackgroundTransparency = 0.6 })

	for k, parent in imageButtons do
		local popScale = Instance.new("UIScale")
		popScale.Name = "PopScale"
		popScale.Scale = 0
		popScale.Parent = parent
		task.delay((k - 1) * 0.03, UI.pop, parent, 0.3, 0.18)
		parent.MouseEnter:Connect(function()
			UI.tween(popScale, UI.FAST, { Scale = 1.08 }, Enum.EasingStyle.Back)
		end)
		parent.MouseLeave:Connect(function()
			UI.tween(popScale, UI.SNAP, { Scale = 1 })
		end)
	end

	self.promoState = {
		dim = textButton,
		column = frame,
		items = imageButtons,
		cancel = textButton2,
		to = to,
		x = icon,
		cancelPick = cancelPick,
		onDismiss = onDismiss
	}
	self:layoutPromotion()
end

function BoardView:layoutPromotion()
	local promoState = self.promoState

	if not promoState then
		return
	end

	local colRow, v3 = self:colRow(promoState.to)
	local v4 = v3 < 4
	local sqPx = self.sqPx
	local v5 = math.floor(sqPx * 0.5)
	promoState.column.Size = UDim2.fromOffset(sqPx, sqPx * 4 + v5)

	if v4 then
		promoState.column.Position = UDim2.fromOffset(colRow * sqPx, v3 * sqPx)
	else
		promoState.column.Position = UDim2.fromOffset(colRow * sqPx, (v3 + 1) * sqPx - (sqPx * 4 + v5))
	end

	for k, item in promoState.items do
		item.Size = UDim2.fromOffset(sqPx, sqPx)
		local v6 = v4 and k - 1 or 4 - k
		item.Position = UDim2.fromOffset(0, (v4 and 0 or v5) + v6 * sqPx)
	end

	promoState.cancel.Size = UDim2.fromOffset(sqPx, v5)
	promoState.cancel.Position = UDim2.fromOffset(0, v4 and 4 * sqPx or 0)
end

function BoardView:hidePromotion(p)
	local promoState = self.promoState

	if promoState then
		promoState.dim:Destroy()
		promoState.column:Destroy()
		self.promoState = nil

		if not p and promoState.onDismiss then
			promoState.onDismiss()
		end
	end
end

function BoardView:toggleMark(p)
	if self.marks[p] then
		local mark = self.marks[p]
		self.marks[p] = nil
		UI.tween(mark, 0.08, { BackgroundTransparency = 1 }).Completed:Connect(function()
			mark:Destroy()
		end)
	else
		self.marks[p] = UI.new("Frame", {
			Name = "Mark",
			Size = UDim2.fromScale(0.125, 0.125),
			Position = self:sqPos(p),
			BackgroundColor3 = Theme.mark,
			BackgroundTransparency = 1,
			Parent = self.hlLayer
		})

		UI.tween(self.marks[p], UI.FAST, { BackgroundTransparency = 0.2 })
	end
end

local v3 = nil
local function arrowHeadContent()
	if v3 ~= nil then
		return v3 or nil
	end

	local success, result = pcall(function()
		local buf = buffer.create(65536)

		for i = 0, 127 do
			for j = 0, 127 do
				local count = 0

				for k = 0, 3 do
					local v4 = i + (k + 0.5) / 4

					for i2 = 0, 3 do
						if not (math.abs(v4 - 64) <= (1 - (j + (i2 + 0.5) / 4) / 128) * 64) then
							continue
						end

						count += 1
					end
				end

				local v4 = math.floor(count / 16 * 255 + 0.5)
				buffer.writeu32(buf, (i * 128 + j) * 4, v4 * 16777216 + 16777215)
			end
		end

		local AssetService = game:GetService("AssetService")
		local editableImage = AssetService:CreateEditableImage({ Size = Vector2.new(128, 128) })
		editableImage:WritePixelsBuffer(Vector2.zero, Vector2.new(128, 128), buf)
		return Content.fromObject(editableImage)
	end)

	v3 = success and result or false
	return v3 or nil
end

function BoardView:setArrow(p, from, to, p2, value)
	if self.arrows[p] then
		if self.arrows[p].group then
			self.arrows[p].group:Destroy()
		end

		self.arrows[p] = nil
	end

	if from and to and from ~= to then
		local v4 = {
			from = from,
			to = to,
			color = p2 or Theme.arrow,
			alpha = value or 0.2,
			parts = {}
		}
		v4.group = UI.new("CanvasGroup", {
			Name = "Arrow",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			GroupTransparency = 1,
			Parent = self.arrowLayer
		})

		self.arrows[p] = v4
		self:drawArrow(v4)
		UI.tween(v4.group, UI.SNAP, { GroupTransparency = v4.alpha })
	end
end

function BoardView:toggleArrow(p, p2)
	local v4 = "u" .. p .. "_" .. p2

	if self.arrows[v4] then
		self:setArrow(v4, nil)
	else
		self:setArrow(v4, p, p2)
	end
end

function BoardView:drawArrow(state)
	for k, part in state.parts do
		part:Destroy()
	end

	state.parts = {}
	local group = state.group or self.arrowLayer
	local sqPx = self.sqPx
	local sqCenterPx = self:sqCenterPx(state.from)
	local sqCenterPx2 = self:sqCenterPx(state.to)
	local v4 = sqCenterPx2 - sqCenterPx
	local magnitude = v4.Magnitude

	if magnitude < 1 then
		return
	end

	local v5 = sqPx * 0.22
	local v6 = sqPx * 0.5
	local v7 = sqPx * 0.66
	local v8 = sqPx * 0.2
	local parts = {}
	local function bar(p, p2, p3)
		local v9 = p2 - p
		local midpoint = (p + p2) / 2
		local frame = UI.new("Frame", {
			Name = "ArrowShaft",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(midpoint.X, midpoint.Y),
			Size = UDim2.fromOffset(v9.Magnitude, v5),
			Rotation = math.deg((math.atan2(v9.Y, v9.X))),
			BackgroundColor3 = state.color,
			BorderSizePixel = 0,
			Parent = group
		}, p3 and { UI.corner(UDim.new(0.5, 0)) } or nil)
		table.insert(parts, frame)
		return frame
	end

	local v9 = math.abs((math.floor(v4.X / sqPx + 0.5)))
	local v10 = math.abs((math.floor(v4.Y / sqPx + 0.5)))
	local vector2

	if v9 == 1 and v10 == 2 or v9 == 2 and v10 == 1 then
		vector2 = v9 < v10 and Vector2.new(sqCenterPx.X, sqCenterPx2.Y) or Vector2.new(sqCenterPx2.X, sqCenterPx.Y)
		bar(sqCenterPx + (vector2 - sqCenterPx).Unit * v8, vector2, true)
		table.insert(parts, UI.new("Frame", {
			Name = "ArrowCorner",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(vector2.X, vector2.Y),
			Size = UDim2.fromOffset(v5, v5),
			BackgroundColor3 = state.color,
			BorderSizePixel = 0,
			Parent = group
		}))

		v4 = sqCenterPx2 - vector2
		magnitude = v4.Magnitude
	end

	local v11 = v4 / magnitude
	local rotation = math.deg((math.atan2(v4.Y, v4.X)))
	local v12 = sqCenterPx2 - v11 * (sqPx * 0.06)
	local v13 = v12 - v11 * (v6 - 2)
	local v14 = vector2 == nil
	local v15 = vector2 or sqCenterPx + v11 * v8

	if (v13 - v15):Dot(v11) > 1 then
		bar(v15, v13, v14)
	end

	local v16 = v12 - v11 * (v6 / 2)

	if v3 == nil then
		local success, result = pcall(function()
			local buf = buffer.create(65536)

			for i = 0, 127 do
				for j = 0, 127 do
					local count = 0

					for k = 0, 3 do
						local v17 = i + (k + 0.5) / 4

						for i2 = 0, 3 do
							if not (math.abs(v17 - 64) <= (1 - (j + (i2 + 0.5) / 4) / 128) * 64) then
								continue
							end

							count += 1
						end
					end

					local v17 = math.floor(count / 16 * 255 + 0.5)
					buffer.writeu32(buf, (i * 128 + j) * 4, v17 * 16777216 + 16777215)
				end
			end

			local AssetService = game:GetService("AssetService")
			local editableImage = AssetService:CreateEditableImage({ Size = Vector2.new(128, 128) })
			editableImage:WritePixelsBuffer(Vector2.zero, Vector2.new(128, 128), buf)
			return Content.fromObject(editableImage)
		end)

		v3 = success and result or false
	end

	local imageContent = v3 or nil
	local v17

	if imageContent then
		v17 = UI.new("ImageLabel", {
			Name = "ArrowHead",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(v16.X, v16.Y),
			Size = UDim2.fromOffset(v6, v7),
			Rotation = rotation,
			BackgroundTransparency = 1,
			ImageContent = imageContent,
			ImageColor3 = state.color,
			ScaleType = Enum.ScaleType.Stretch,
			Parent = group
		})
	else
		v17 = UI.icon("arrowhead", 10, state.color, {
			Name = "ArrowHead",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(v16.X, v16.Y),
			Size = UDim2.fromOffset(v6, v7),
			ScaleType = Enum.ScaleType.Stretch,
			Rotation = rotation,
			Parent = group
		})
	end

	table.insert(parts, v17)
	state.parts = parts
end

function BoardView:redrawArrows()
	for k, arrow in self.arrows do
		self:drawArrow(arrow)
	end

	for k, mark in self.marks do
		mark.Position = self:sqPos(k)
	end
end

function BoardView:setMoveBadge(p, backgroundColor, value, p2)
	if self.moveBadge then
		self.moveBadge:Destroy()
		self.moveBadge = nil
	end

	if not (p and backgroundColor) then
		return
	end

	local colRow, v4 = self:colRow(p)
	local frame = UI.new("Frame", {
		Name = "MoveBadge",
		Size = UDim2.fromScale(0.05, 0.05),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale((colRow + 0.88) / 8, (v4 + 0.12) / 8),
		BackgroundColor3 = backgroundColor,
		ZIndex = 3,
		Parent = self.arrowLayer
	}, { UI.corner(UDim.new(0.3, 0)), UI.stroke(Color3.fromRGB(20, 20, 24), 2, 0.35) })

	if p2 then
		UI.icon(p2, 10, Color3.new(1, 1, 1), {
			Size = UDim2.fromScale(0.72, 0.72),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			ZIndex = 3,
			Parent = frame
		})
	else
		_ = UI.text({
			Text = value or "",
			FontFace = Theme.fontHeavy,
			TextScaled = true,
			Size = UDim2.fromScale(0.8, 0.8),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			ZIndex = 3,
			Parent = frame
		})
	end

	self.moveBadge = frame
	UI.pop(frame, 0.2, 0.22)
end

function BoardView:clearAnnotations()
	for k in self.arrows do
		if string.sub(k, 1, 1) == "u" then
			self:setArrow(k, nil)
		end
	end

	for k, mark in self.marks do
		mark:Destroy()
		self.marks[k] = nil
	end
end

local function pos2(input)
	return Vector2.new(input.Position.X, input.Position.Y)
end

function BoardView:startDrag(sq, p)
	local piece = self.pieces[sq]

	if not piece then
		return
	end

	piece.ImageTransparency = 0.55
	local imageLabel = UI.new("ImageLabel", {
		Name = "DragPiece",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(self.sqPx, self.sqPx),
		ScaleType = Enum.ScaleType.Fit,
		Parent = self.dragLayer
	})

	self:paint(imageLabel, self.position[sq])

	local uiScale = Instance.new("UIScale")
	uiScale.Scale = 1
	uiScale.Parent = imageLabel
	UI.tween(uiScale, UI.FAST, { Scale = 1.12 })
	local dragShade = Instance.new("ImageLabel")
	dragShade.Name = "DragShade"
	dragShade.BackgroundTransparency = 1
	dragShade.ImageColor3 = Color3.new(0, 0, 0)
	dragShade.ImageTransparency = 0.72
	dragShade.Image = imageLabel.Image
	dragShade.ImageRectOffset = imageLabel.ImageRectOffset
	dragShade.ImageRectSize = imageLabel.ImageRectSize
	dragShade.ScaleType = imageLabel.ScaleType
	dragShade.AnchorPoint = imageLabel.AnchorPoint
	dragShade.Size = imageLabel.Size
	dragShade.ZIndex = 0
	local uiScale2 = Instance.new("UIScale")
	uiScale2.Scale = 1
	uiScale2.Parent = dragShade
	UI.tween(uiScale2, UI.FAST, { Scale = 1.16 })
	dragShade.Parent = self.dragLayer
	piece.ImageTransparency = 0
	UI.tween(piece, UI.FAST, { ImageTransparency = 0.55 })
	self.dragState = { sq = sq, ghost = imageLabel, label = piece, shade = dragShade }
	self:moveDrag(p)
end

function BoardView:moveDrag(p)
	local dragState = self.dragState

	if not dragState then
		return
	end

	local v4 = p - self.frame.AbsolutePosition
	dragState.ghost.Position = UDim2.fromOffset(v4.X, v4.Y)

	if dragState.shade then
		dragState.shade.Position = UDim2.fromOffset(v4.X, v4.Y + math.floor(self.sqPx * 0.14))
	end

	local squareAt = self:squareAt(p)

	if not squareAt then
		self.hoverFrame.Visible = false

		return
	end

	local hoverInset = self.hoverInset or 2
	local colRow, v5 = self:colRow(squareAt)
	self.hoverFrame.Size = UDim2.fromOffset(self.sqPx - hoverInset * 2, self.sqPx - hoverInset * 2)
	self.hoverFrame.Position = UDim2.fromOffset(colRow * self.sqPx + hoverInset, v5 * self.sqPx + hoverInset)
	self.hoverFrame.Visible = true
end

function BoardView:endDrag()
	local dragState = self.dragState

	if not dragState then
		return
	end

	dragState.ghost:Destroy()

	if dragState.shade then
		dragState.shade:Destroy()
	end

	if dragState.label and dragState.label.Parent then
		UI.tween(dragState.label, 0.05, { ImageTransparency = 0 })
	end

	self.hoverFrame.Visible = false
	self.dragState = nil
end

function BoardView:cancelDrag()
	self:endDrag()
	self.press = nil
end

function BoardView:pointerDown(start)
	local squareAt = self:squareAt(start)
	self:clearAnnotations()

	if not squareAt or not self.interactive or self.promoState then
		return
	end

	if #self.premoves > 0 and not (self.selected or self:canPick(self.position[squareAt])) then
		self:clearPremove()
	end

	if self.selected and squareAt ~= self.selected and self.targets[squareAt] ~= nil then
		local v4 = self:canPick(self.position[squareAt])

		if v4 then
			local v5 = sign(self.position[squareAt]) -- inferred equivalent call
			v4 = v5 == sign(self.position[self.selected]) -- inferred equivalent call
		end

		if not v4 then
			self:tryMove(self.selected, squareAt, false)
			return
		end
	end

	if not self:canPick(self.position[squareAt]) then
		self:deselect()

		return
	end

	local wasSelected = self.selected == squareAt
	self:select(squareAt)
	self.press = { sq = squareAt, start = start, wasSelected = wasSelected }
end

function BoardView:pointerMove(p)
	local press = self.press

	if not press then
		return
	end

	if self.dragState then
		self:moveDrag(p)
	elseif (p - press.start).Magnitude >= 5 then
		self:startDrag(press.sq, p)
	end
end

function BoardView:pointerUp(p)
	local press = self.press
	self.press = nil

	if not press then
		return
	end

	if self.dragState then
		local dragState = self.dragState
		local squareAt = self:squareAt(p)
		self:endDrag()

		if squareAt and squareAt ~= press.sq and self.targets[squareAt] ~= nil and self.selected == press.sq then
			if dragState.label and not self.selectingPremove then
				dragState.label.Position = self:piecePos(squareAt, self.position[press.sq])
			end

			self:tryMove(press.sq, squareAt, true)
		elseif squareAt ~= press.sq then
			self:deselect()
		end
	elseif press.wasSelected then
		self:deselect()
	end
end

function BoardView:sqAtColRow(p, p2)
	if not self.flipped then
		return sqOf(p, 7 - p2) -- inferred equivalent call
	end

	return sqOf(7 - p, p2) -- inferred equivalent call
end

function BoardView:ensureCursor()
	if self.cursor then
		return self.cursor
	end

	local frame = UI.new("Frame", {
		Name = "Cursor",
		Size = UDim2.fromScale(0.125, 0.125),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.82,
		Visible = false,
		ZIndex = 2,
		Parent = self.dragLayer
	}, { UI.corner(4) })
	local stroke = UI.stroke(Color3.new(1, 1, 1), 3, 0)
	stroke.Parent = frame
	self.cursor = {
		frame = frame,
		stroke = stroke,
		ghost = UI.new("ImageLabel", {
			Name = "Ghost",
			AnchorPoint = Vector2.zero,
			Size = UDim2.fromScale(1, 1),
			ScaleType = Enum.ScaleType.Fit,
			ImageTransparency = 0.45,
			Visible = false,
			ZIndex = 2,
			Parent = frame
		}),
		sq = nil,
		on = false
	}
	return self.cursor
end

function BoardView:layoutCursor(p)
	local cursor = self.cursor

	if not (cursor and cursor.sq) then
		return
	end

	local thickness = math.max(3, (math.floor(self.sqPx * 0.06)))
	cursor.stroke.Thickness = thickness
	local colRow, v4 = self:colRow(cursor.sq)
	local udim = UDim2.new(colRow / 8, thickness, v4 / 8, thickness)
	cursor.frame.Size = UDim2.new(0.125, thickness * -2, 0.125, thickness * -2)

	if p or not cursor.frame.Visible then
		cursor.frame.Position = udim
	else
		UI.tween(cursor.frame, 0.06, { Position = udim })
	end
end

function BoardView:refreshCursorGhost()
	local cursor = self.cursor

	if not cursor then
		return
	end

	local selected = self.selected
	local visible = cursor.on

	if visible then
		if selected == nil or cursor.sq == selected or self.targets[cursor.sq] == nil then
			visible = false
		else
			visible = self.position[selected] ~= 0
		end
	end

	if visible then
		self:paint(cursor.ghost, self.position[selected])
	end

	cursor.ghost.Visible = visible
end

function BoardView:setCursor(sq)
	local cursor = self:ensureCursor()
	cursor.sq = sq
	self:layoutCursor()
	self:refreshCursorGhost()
end

function BoardView:showCursor(on)
	local cursor = self:ensureCursor()

	if cursor.on == on then
		return
	end

	cursor.on = on

	if on then
		self:layoutCursor(true)
		cursor.frame.Visible = true
		UI.pop(cursor.frame, 0.85, 0.15)
	else
		cursor.frame.Visible = false
	end

	self:refreshCursorGhost()
end

function BoardView:moveCursor(p, p2): boolean
	local cursor = self:ensureCursor()

	if not cursor.sq then
		return false
	end

	local colRow, v4 = self:colRow(cursor.sq)
	local v5 = math.clamp(colRow + p, 0, 7)
	local v6 = math.clamp(v4 + p2, 0, 7)

	if v5 == colRow and v6 == v4 then
		return false
	end

	self:setCursor(self:sqAtColRow(v5, v6))
	return true
end

function BoardView:pressSquare(p)
	self:clearAnnotations()

	if not p or not self.interactive or self.promoState then
		return
	end

	if #self.premoves > 0 and not (self.selected or self:canPick(self.position[p])) then
		self:clearPremove()
	end

	if self.selected and p ~= self.selected and self.targets[p] ~= nil then
		local v4 = self:canPick(self.position[p])

		if v4 then
			local v5 = sign(self.position[p]) -- inferred equivalent call
			v4 = v5 == sign(self.position[self.selected]) -- inferred equivalent call
		end

		if not v4 then
			self:tryMove(self.selected, p, false)
			return
		end
	end

	local v4 = self.position[p]

	if self.selected == p then
		self:deselect()
	elseif self:canPick(v4) then
		self:select(p)
	else
		self:deselect()
	end
end

function BoardView:connectInput()
	local v4 = nil
	self.input.InputBegan:Connect(function(input)
		local userInputType = input.UserInputType

		if userInputType == Enum.UserInputType.MouseButton1 or userInputType == Enum.UserInputType.Touch then
			if self.activeTouch and userInputType == Enum.UserInputType.Touch then
				return
			end

			if userInputType == Enum.UserInputType.Touch then
				self.activeTouch = input
			end

			self:pointerDown(pos2(input))
		elseif userInputType == Enum.UserInputType.MouseButton2 then
			if #self.premoves > 0 then
				self:clearPremove()
				self:deselect()
				v4 = nil
			else
				v4 = self:squareAt(pos2(input))
			end
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		local userInputType = input.UserInputType

		if
			userInputType == Enum.UserInputType.MouseMovement
			or userInputType == Enum.UserInputType.Touch and input == self.activeTouch
		then
			self:pointerMove(pos2(input))
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		local userInputType = input.UserInputType

		if
			userInputType == Enum.UserInputType.MouseButton1
			or userInputType == Enum.UserInputType.Touch and input == self.activeTouch
		then
			self.activeTouch = nil
			self:pointerUp(pos2(input))
		elseif userInputType == Enum.UserInputType.MouseButton2 and v4 then
			local squareAt = self:squareAt(pos2(input))

			if squareAt == v4 then
				self:toggleMark(squareAt)
			elseif squareAt then
				self:toggleArrow(v4, squareAt)
			end

			v4 = nil
		end
	end)
end

return BoardView