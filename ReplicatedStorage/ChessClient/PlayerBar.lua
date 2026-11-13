local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Chess.Config)
local Sprites = require(ReplicatedStorage.Chess.Sprites)
local Theme = require(script.Parent.Theme)
local UI = require(script.Parent.UI)

local PlayerBar = {}
PlayerBar.__index = PlayerBar

local v = { 1, 3, 3, 5, 9, 0 }

PlayerBar.CARD_PAD_X = 12
PlayerBar.CARD_PAD_Y = 9

function PlayerBar:setCard(p)
	local v2 = p and true or false
	self.card.Visible = v2

	if self.stacked ~= v2 then
		self.stacked = v2

		if self.width then
			self:layout(self.width, self.height)
		end
	end
end

function PlayerBar.stackedHeight(p, p2)
	if p2 then
		return (math.clamp(math.floor(p * 0.15), 78, 96))
	end

	return (math.clamp(math.floor(p * 0.085), 40, 52))
end

function PlayerBar:setClockOut(p)
	local clockOut = p ~= nil
	self.clock.Parent = p or self.frame
	self.reportBtn.Parent = p or self.frame

	if self.clockOut ~= clockOut then
		self.clockOut = clockOut

		if self.width then
			self:layout(self.width, self.height)
		end
	end
end

function PlayerBar:reportWidth(p)
	if not self.reportBtn.Visible then
		return 0
	end

	local v2 = math.clamp(p / 40, 0.8, 1.3)
	local v3 = math.floor(v2 * 18)
	local v4 = math.floor(v2 * 16)
	local x = TextService:GetTextSize(self.reportText.Text, v4, Enum.Font.BuilderSansBold, Vector2.new(1000, 100)).X
	return v3 + 12 + 4 + math.ceil(x) + 14
end

function PlayerBar:placeReport(p, p2, p3)
	local reportWidth = self:reportWidth(p3)

	if reportWidth == 0 then
		return 0
	end

	local v2 = math.clamp(p3 / 40, 0.8, 1.3)
	self.reportIcon.Size = UDim2.fromOffset(math.floor(v2 * 18), (math.floor(v2 * 18)))
	self.reportText.TextSize = math.floor(v2 * 16)
	self.reportPad.PaddingLeft = UDim.new(0, 12)
	self.reportPad.PaddingRight = UDim.new(0, 14)
	self.reportBtn.AnchorPoint = Vector2.zero
	self.reportBtn.Position = UDim2.fromOffset(p, p2)
	self.reportBtn.Size = UDim2.fromOffset(reportWidth, p3)
	return reportWidth
end

function PlayerBar.placeClock(data, p, p2, p3, p4)
	local v2 = math.clamp(p4 / 40, 0.8, 1.3)
	data.clock.AnchorPoint = Vector2.zero
	data.clock.Position = UDim2.fromOffset(p, p2)
	data.clock.Size = UDim2.fromOffset(p3, p4)
	data.clock.Visible = data.clockVisible
	data.clockText.TextSize = math.floor(v2 * 24)
	data.clockText.Size = UDim2.new(1, -math.floor(v2 * 12), 1, 0)
	data.clockIcon.Size = UDim2.fromOffset(math.floor(v2 * 18), (math.floor(v2 * 18)))
end

function PlayerBar:wantsSecondRow()
	return if self.clockVisible then true else self.reportBtn.Visible
end

function PlayerBar:rowsChanged()
	if (self.stacked or self.clockOut) and self.onRows then
		self.onRows()
	elseif self.width then
		self:layout(self.width, self.height)
	end
end

local color = Color3.fromRGB(255, 204, 64)
local color2 = Color3.fromRGB(255, 232, 140)
local color3 = Color3.fromRGB(222, 150, 28)
local color4 = Color3.fromRGB(255, 250, 222)

local v2 = {
	[8839297805] = { "RoChess Creator", Color3.fromRGB(255, 92, 92), Color3.fromRGB(176, 24, 40) },
	[573649346] = { "RoChess Developer", Color3.fromRGB(46, 150, 78), Color3.fromRGB(14, 82, 38) }
}

PlayerBar.STAFF_TAGS = v2

local v3 = {
	donated = { Color3.fromRGB(255, 128, 196), Color3.fromRGB(196, 44, 128) },
	bullet = { Color3.fromRGB(255, 196, 92), Color3.fromRGB(206, 120, 20) },
	blitz = { Color3.fromRGB(120, 186, 255), Color3.fromRGB(36, 104, 206) },
	rapid = { Color3.fromRGB(150, 214, 104), Color3.fromRGB(70, 146, 44) },
	puzzle = { Color3.fromRGB(255, 170, 96), Color3.fromRGB(214, 100, 30) },
	wins = { Color3.fromRGB(104, 214, 180), Color3.fromRGB(28, 140, 112) },
	playtime = { Color3.fromRGB(186, 156, 255), Color3.fromRGB(110, 76, 200) }
}

PlayerBar.LB_COLORS = v3

function PlayerBar.new(parent)
	local object = setmetatable({}, PlayerBar)
	object.height = 44
	object.frame = UI.new("Frame", {
		Name = "PlayerBar",
		Size = UDim2.fromOffset(400, 44),
		BackgroundTransparency = 1,
		Parent = parent
	})

	object.card = UI.new("Frame", {
		Name = "Card",
		BackgroundColor3 = Theme.panel,
		Position = UDim2.fromOffset(-PlayerBar.CARD_PAD_X, -PlayerBar.CARD_PAD_Y),
		Size = UDim2.new(1, 2 * PlayerBar.CARD_PAD_X, 1, 2 * PlayerBar.CARD_PAD_Y),
		ZIndex = 0,
		Visible = false,
		Parent = object.frame
	}, { UI.corner(Theme.radius or 14) })
	UI.lift(object.card, 0.12)
	object.avatar = UI.avatar(nil, 40)
	object.avatar.frame.Parent = object.frame
	object.avatar.frame.AnchorPoint = Vector2.new(0, 0.5)
	object.avatar.frame.Position = UDim2.fromScale(0, 0.5)

	object.openBtn = UI.new("TextButton", {
		Name = "Open",
		Text = "",
		BackgroundTransparency = 1,
		Visible = false,
		ZIndex = 2,
		Parent = object.frame
	})

	object.openBtn:SetAttribute("Sfx", "press")
	object.avatarRing = UI.stroke(Color3.new(1, 1, 1), 2, 1)
	object.avatarRing.Parent = object.avatar.frame
	local function ring(p) -- 4 equivalent calls inferred from this helper
		UI.to(object.avatarRing, UI.FAST, {
			Transparency = p and 0.15 or 1
		})
	end
	object.openBtn.MouseEnter:Connect(function()
		ring(true) -- inferred equivalent call
	end)
	object.openBtn.MouseLeave:Connect(function()
		ring(false) -- inferred equivalent call
	end)
	object.openBtn.SelectionGained:Connect(function()
		ring(true) -- inferred equivalent call
	end)
	object.openBtn.SelectionLost:Connect(function()
		ring(false) -- inferred equivalent call
	end)
	object.openBtn.Activated:Connect(function()
		if object.onOpen then
			object.onOpen()
		end
	end)

	object.info = UI.new("Frame", {
		Name = "Info",
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent = object.frame
	})

	object.nameRow = UI.new(
		"Frame",
		{
			Name = "NameRow",
			Size = UDim2.new(1, 0, 0.5, 0),
			BackgroundTransparency = 1,
			Parent = object.info
		},
		{ UI.list(Enum.FillDirection.Horizontal, 5, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center) }
	)
	object.nameLabel = UI.text({
		Name = "Name",
		Text = "Opponent",
		FontFace = Theme.fontBold,
		TextSize = 16,
		TextColor3 = Theme.text,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromScale(0, 1),
		TextTruncate = Enum.TextTruncate.AtEnd,
		LayoutOrder = 1,
		Parent = object.nameRow
	})

	object.nameFit = Instance.new("UISizeConstraint")
	object.nameFit.Parent = object.nameLabel

	object.nameGrad = Instance.new("UIGradient")
	object.nameGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, color),
		ColorSequenceKeypoint.new(0.4, color),
		ColorSequenceKeypoint.new(0.5, color4),
		ColorSequenceKeypoint.new(0.6, color),
		ColorSequenceKeypoint.new(1, color)
	})

	object.nameGrad.Offset = Vector2.new(-1, 0)
	object.nameGrad.Enabled = false
	object.nameGrad.Parent = object.nameLabel
	object.nameSweep = TweenService:Create(
		object.nameGrad,
		TweenInfo.new(1.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, false, 2.4),
		{ Offset = Vector2.new(1, 0) }
	)

	object.ownerTag = UI.new("Frame", {
		Name = "Owner",
		Size = UDim2.fromOffset(0, 16),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = Color3.new(1, 1, 1),
		Visible = false,
		LayoutOrder = 2,
		Parent = object.nameRow
	}, { UI.corner(UDim.new(0, 4)) })
	object.ownerGrad = Instance.new("UIGradient")
	object.ownerGrad.Rotation = 90
	object.ownerGrad.Parent = object.ownerTag
	object.ownerPad = UI.pad(0, 5, 0, 5)
	object.ownerPad.Parent = object.ownerTag
	object.ownerText = UI.text({
		Name = "Label",
		Text = "",
		FontFace = Theme.fontHeavy,
		TextSize = 12,
		TextColor3 = Color3.new(1, 1, 1),
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromScale(0, 1),
		Parent = object.ownerTag
	})

	object.vipTag = UI.new("Frame", {
		Name = "Vip",
		Size = UDim2.fromOffset(30, 16),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Visible = false,
		LayoutOrder = 3,
		Parent = object.nameRow
	}, { UI.corner(UDim.new(0, 4)) })
	local uiGradient = Instance.new("UIGradient")
	uiGradient.Rotation = 90
	uiGradient.Color = ColorSequence.new(color2, color3)
	uiGradient.Parent = object.vipTag
	object.vipText = UI.text({
		Name = "Label",
		Text = "VIP",
		FontFace = Theme.fontHeavy,
		TextSize = 12,
		TextColor3 = Color3.fromRGB(64, 38, 4),
		Size = UDim2.fromScale(1, 1),
		Parent = object.vipTag
	})

	object.lbTag = UI.new("Frame", {
		Name = "LbTag",
		Size = UDim2.fromOffset(0, 16),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = Color3.new(1, 1, 1),
		Visible = false,
		LayoutOrder = 4,
		Parent = object.nameRow
	}, { UI.corner(UDim.new(0, 4)) })
	object.lbGrad = Instance.new("UIGradient")
	object.lbGrad.Rotation = 90
	object.lbGrad.Parent = object.lbTag
	local padded = UI.pad(0, 5, 0, 5)
	padded.Parent = object.lbTag
	object.lbText = UI.text({
		Name = "Label",
		Text = "",
		FontFace = Theme.fontHeavy,
		TextSize = 12,
		TextColor3 = Color3.new(1, 1, 1),
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromScale(0, 1),
		Parent = object.lbTag
	})

	object.ratingLabel = UI.text({
		Name = "Rating",
		Text = "",
		FontFace = Theme.font,
		TextSize = 15,
		TextColor3 = Theme.textDim,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromScale(0, 1),
		LayoutOrder = 5,
		Parent = object.nameRow
	})

	object.statusLabel = UI.text({
		Name = "Status",
		Text = "",
		FontFace = Theme.fontMedium,
		TextSize = 13,
		TextColor3 = Theme.textDim,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromScale(0, 1),
		LayoutOrder = 6,
		Parent = object.nameRow
	})

	object.reportBtn = UI.new("TextButton", {
		Name = "Report",
		Text = "",
		AnchorPoint = Vector2.new(1, 0.5),
		Size = UDim2.fromOffset(90, 30),
		BackgroundColor3 = Theme.button,
		BackgroundTransparency = 0,
		AutoButtonColor = false,
		Visible = false,
		Parent = object.frame
	}, {
		UI.corner(UDim.new(0.5, 0)),
		UI.list(Enum.FillDirection.Horizontal, 4, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)
	})

	object.reportPad = UI.pad(0, 9, 0, 7)
	object.reportPad.Parent = object.reportBtn
	object.reportIcon = UI.icon("flag", 16, Theme.text, {
		LayoutOrder = 1,
		Parent = object.reportBtn
	})

	object.reportText = UI.text({
		Name = "Label",
		Text = "Report",
		FontFace = Theme.fontBold,
		TextSize = 15,
		TextColor3 = Theme.text,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromScale(0, 1),
		LayoutOrder = 2,
		Parent = object.reportBtn
	})

	local function reportColors(p)
		local loss = (object.reported or p) and Theme.loss or Theme.text
		UI.to(object.reportIcon, UI.FAST, { ImageColor3 = loss })
		UI.to(object.reportText, UI.FAST, { TextColor3 = loss })
	end
	object.reportColors = reportColors
	object.reportBtn.MouseEnter:Connect(function()
		reportColors(not object.reported)
	end)
	object.reportBtn.MouseLeave:Connect(function()
		reportColors(false)
	end)
	object.reportBtn.Activated:Connect(function()
		if object.onReport and not object.reported then
			object.onReport()
		end
	end)

	object.capturedRow = UI.new("Frame", {
		Name = "Captured",
		Size = UDim2.new(1, 0, 0.5, 0),
		Position = UDim2.fromScale(0, 0.5),
		BackgroundTransparency = 1,
		Parent = object.info
	})

	object.levelLabel = UI.text({
		Name = "Level",
		Text = "",
		FontFace = Theme.fontBold,
		TextSize = 14,
		TextColor3 = Theme.textDim,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 0.5, 0),
		Position = UDim2.fromScale(0, 0.5),
		Visible = false,
		Parent = object.info
	})

	object.clock = UI.new("Frame", {
		Name = "Clock",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.fromScale(1, 0.5),
		Size = UDim2.fromOffset(124, 40),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Parent = object.frame
	}, { UI.corner(10) })

	object.clockRing = UI.stroke(Theme.accent or Theme.green, 2, 1)
	object.clockRing.Parent = object.clock
	object.clockIcon = UI.icon("timer", 18, Theme.bg, {
		Name = "Icon",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 8, 0.5, 0),
		Visible = false,
		Parent = object.clock
	})

	object.clockText = UI.text({
		Name = "Time",
		Text = "10:00",
		FontFace = Theme.fontMono,
		TextSize = 24,
		TextXAlignment = Enum.TextXAlignment.Right,
		Size = UDim2.new(1, -10, 1, 0),
		Parent = object.clock
	})

	object.clockColor = 1
	object.clockVisible = true
	local function fit()
		object:fitName()
	end
	object.ratingLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
	object.statusLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
	object:layout(400, 44)
	return object
end

function PlayerBar:fitName()
	local infoW = self.infoW or 200
	local total = 0

	for _, v4 in { self.ratingLabel, self.statusLabel, self.vipTag } do
		if v4.Visible and v4.AbsoluteSize.X > 0 then
			total += v4.AbsoluteSize.X + 5
		end
	end

	if self.ownerWanted then
		local v4 = math.max(self.ownerTag.AbsoluteSize.X, 80) + 5
		local visible = infoW - total - v4 - 4 >= 80

		if self.ownerTag.Visible ~= visible then
			self.ownerTag.Visible = visible
		end

		if visible then
			total += v4
		end
	end

	if self.lbTagText then
		local v4 = math.max(self.lbTag.AbsoluteSize.X, 70) + 5
		local visible = infoW - total - v4 - 4 >= 80

		if self.lbTag.Visible ~= visible then
			self.lbTag.Visible = visible
		end

		if visible then
			total += v4
		end
	end

	self.nameFit.MaxSize = Vector2.new(math.max(40, infoW - total - 4), 1e999)
end

function PlayerBar:layout(width, height)
	self.width = width
	self.height = height
	self.frame.Size = UDim2.fromOffset(width, height)

	if self.stacked then
		return self:layoutStacked(width, height)
	end

	self.avatar.frame.AnchorPoint = Vector2.new(0, 0.5)
	self.avatar.frame.Position = UDim2.fromScale(0, 0.5)
	self.reportBtn.AnchorPoint = Vector2.new(1, 0.5)
	local v4 = math.floor(height * 0.9)
	self.avatar.frame.Size = UDim2.fromOffset(v4, v4)
	local v5 = math.clamp(height / 44, 0.75, 1.15)
	self.clock.Visible = self.clockVisible
	local v6

	if self.clockOut then
		v6 = 0
	else
		v6 = self.clockVisible and math.floor(v5 * 118) or 0
		self.clock.AnchorPoint = Vector2.new(1, 0.5)
		self.clock.Position = UDim2.fromScale(1, 0.5)
		self.clock.Size = UDim2.fromOffset(v6, (math.floor(height * 0.88)))
		self.clockText.TextSize = math.floor(v5 * 23)
		self.clockText.Size = UDim2.new(1, -math.floor(v5 * 10), 1, 0)
		self.clockIcon.Size = UDim2.fromOffset(math.floor(v5 * 17), (math.floor(v5 * 17)))
	end

	local v7

	if self.reportBtn.Visible and not self.clockOut then
		local v8 = math.max(16, (math.floor(v5 * 18)))
		local textSize = math.max(15, (math.floor(v5 * 17)))
		local v9 = math.max(8, (math.floor(v5 * 10)))
		local v10 = math.max(10, (math.floor(v5 * 12)))
		self.reportIcon.Size = UDim2.fromOffset(v8, v8)
		self.reportText.TextSize = textSize
		self.reportPad.PaddingLeft = UDim.new(0, v9)
		self.reportPad.PaddingRight = UDim.new(0, v10)
		local x = TextService:GetTextSize(
			self.reportText.Text,
			textSize,
			Enum.Font.BuilderSansBold,
			Vector2.new(1000, 100)
		).X
		local v11 = v9 + v8 + 4 + math.ceil(x) + v10 + 2
		self.reportBtn.Size = UDim2.fromOffset(v11, (math.max(26, (math.floor(height * 0.72)))))
		self.reportBtn.Position = UDim2.new(1, -(v6 + (v6 > 0 and 8 or 0)), 0.5, 0)
		v7 = v11 + 8
	else
		v7 = 0
	end

	self.info.Position = UDim2.fromOffset(v4 + 8, 0)
	self.info.Size = UDim2.new(1, -(v4 + 8 + v6 + 8 + v7), 1, 0)
	self.infoW = width - (v4 + 8 + v6 + 8 + v7)

	self.openBtn.Size = UDim2.fromOffset(v4 + 8 + math.max(0, self.infoW), height)
	self.levelLabel.TextSize = math.max(11, (math.floor(v5 * 14)))
	self.nameLabel.TextSize = math.floor(v5 * 16)
	self.ratingLabel.TextSize = math.floor(v5 * 15)
	self.statusLabel.TextSize = math.floor(v5 * 13)
	self.vipTag.Size = UDim2.fromOffset(math.max(26, (math.floor(v5 * 32))), (math.max(14, (math.floor(v5 * 17)))))
	self.vipText.TextSize = math.max(10, (math.floor(v5 * 12)))
	self.ownerTag.Size = UDim2.fromOffset(0, (math.max(14, (math.floor(v5 * 17)))))
	self.ownerText.TextSize = math.max(10, (math.floor(v5 * 12)))
	self.lbTag.Size = UDim2.fromOffset(0, (math.max(14, (math.floor(v5 * 17)))))
	self.lbText.TextSize = math.max(10, (math.floor(v5 * 12)))
	self:renderCaptured()
	self:fitName()
end

function PlayerBar:layoutStacked(p, p2)
	local wantsSecondRow = self:wantsSecondRow()
	local v4 = wantsSecondRow and 6 or 0
	local v5

	if wantsSecondRow then
		v5 = math.floor((p2 - v4) * 0.55) or p2
	else
		v5 = p2
	end

	local v6 = wantsSecondRow and p2 - v4 - v5 or 0
	local v7 = math.clamp(v5 / 44, 0.75, 1.15)
	local v8 = math.floor(v5 * 0.95)
	self.avatar.frame.AnchorPoint = Vector2.new(0, 0.5)
	self.avatar.frame.Position = UDim2.fromOffset(0, (math.floor(v5 / 2)))
	self.avatar.frame.Size = UDim2.fromOffset(v8, v8)

	self.info.Position = UDim2.fromOffset(v8 + 10, 0)
	self.info.Size = UDim2.new(1, -(v8 + 10), 0, v5)
	self.infoW = p - (v8 + 10)
	self.openBtn.Size = UDim2.fromOffset(p, v5)

	local v9 = v5 + v4 + math.floor(v6 / 2)
	local v10 = self.clockVisible and math.floor(v7 * 126) or 0
	self.clock.Visible = self.clockVisible
	self.clock.AnchorPoint = Vector2.new(1, 0.5)
	self.clock.Position = UDim2.new(1, 0, 0, v9)
	self.clock.Size = UDim2.fromOffset(v10, v6)
	self.clockText.TextSize = math.floor(v7 * 24)
	self.clockText.Size = UDim2.new(1, -math.floor(v7 * 10), 1, 0)
	self.clockIcon.Size = UDim2.fromOffset(math.floor(v7 * 17), (math.floor(v7 * 17)))

	if self.reportBtn.Visible then
		local v11 = math.max(16, (math.floor(v7 * 18)))
		local textSize = math.max(15, (math.floor(v7 * 16)))
		self.reportIcon.Size = UDim2.fromOffset(v11, v11)
		self.reportText.TextSize = textSize
		self.reportPad.PaddingLeft = UDim.new(0, 10)
		self.reportPad.PaddingRight = UDim.new(0, 12)
		local x = TextService:GetTextSize(
			self.reportText.Text,
			textSize,
			Enum.Font.BuilderSansBold,
			Vector2.new(1000, 100)
		).X
		self.reportBtn.AnchorPoint = Vector2.new(0, 0.5)
		self.reportBtn.Size = UDim2.fromOffset(v11 + 10 + 4 + math.ceil(x) + 12 + 2, (math.max(28, v6 - 4)))
		self.reportBtn.Position = UDim2.new(0, 0, 0, v9)
	end

	self.levelLabel.TextSize = math.max(11, (math.floor(v7 * 14)))
	self.nameLabel.TextSize = math.floor(v7 * 17)
	self.ratingLabel.TextSize = math.floor(v7 * 15)
	self.statusLabel.TextSize = math.floor(v7 * 13)
	self.vipTag.Size = UDim2.fromOffset(math.max(26, (math.floor(v7 * 32))), (math.max(14, (math.floor(v7 * 17)))))
	self.vipText.TextSize = math.max(10, (math.floor(v7 * 12)))
	self.ownerTag.Size = UDim2.fromOffset(0, (math.max(14, (math.floor(v7 * 17)))))
	self.ownerText.TextSize = math.max(10, (math.floor(v7 * 12)))
	self.lbTag.Size = UDim2.fromOffset(0, (math.max(14, (math.floor(v7 * 17)))))
	self.lbText.TextSize = math.max(10, (math.floor(v7 * 12)))
	self:renderCaptured()
	self:fitName()
end

function PlayerBar:levelWidth()
	local levelLabel = self.levelLabel

	if levelLabel.Visible and levelLabel.Text ~= "" then
		return math.ceil(TextService:GetTextSize(
			levelLabel.Text,
			levelLabel.TextSize,
			Enum.Font.BuilderSansBold,
			Vector2.new(1000, 100)
		).X) + math.max(6, (math.floor(self.height * 0.2)))
	end

	return 0
end

function PlayerBar:setPlayer(player)
	self.player = player
	local lvl = player and tonumber(player.lvl)
	local text = lvl and "Level " .. lvl or ""

	if self.levelLabel.Text ~= text then
		self.levelLabel.Text = text
		self.levelLabel.Visible = lvl ~= nil
		self:renderCaptured()
	end

	if player then
		local display = player.display or player.name or "Player"

		if self.nameLabel.Text ~= display then
			self.nameLabel.Text = display
			UI.textIn(self.nameLabel, 0.15)
		end

		if player.rating then
			self.ratingLabel.Text = tostring(player.rating) .. (player.prov and "?" or "")
		else
			self.ratingLabel.Text = ""
		end

		self.avatar.set(player)
		self:setVip(player.vip == true)
		local v4

		if not player.bot then
			v4 = v2[tonumber(player.userId) or 0] or nil
		end

		self:setOwner(v4)
		local v5

		if not player.bot then
			v5 = player.lbTag or nil
		end

		self:setLbTag(v5)
	else
		self.nameLabel.Text = "Opponent"
		self.ratingLabel.Text = ""
		self.avatar.set(nil)
		self:setVip(false)
		self:setOwner(nil)
		self:setLbTag(nil)
	end
end

function PlayerBar:setOwner(p)
	local owner = type(p) == "table" and p or nil

	if self.owner == owner then
		return
	end

	self.owner = owner
	self.ownerWanted = owner ~= nil
	self.ownerTag.Visible = owner ~= nil

	if owner then
		self.ownerText.Text = owner[1]
		self.ownerGrad.Color = ColorSequence.new(owner[2], owner[3])
		UI.pop(self.ownerTag, 0.5, 0.25)
	end

	self:fitName()
end

function PlayerBar:setLbTag(p)
	local text

	if type(p) == "table" and type(p.text) == "string" then
		text = p.text or nil
	end

	if self.lbTagText == text then
		return
	end

	self.lbTagText = text
	self.lbTag.Visible = text ~= nil

	if text then
		local v4 = v3[p.board] or v3.blitz
		self.lbGrad.Color = ColorSequence.new(v4[1], v4[2])
		self.lbText.Text = text
		UI.pop(self.lbTag, 0.5, 0.25)
	end

	self:fitName()
end

function PlayerBar:setVip(p)
	if self.vip == p then
		return
	end

	self.vip = p
	self.vipTag.Visible = p
	self.nameGrad.Enabled = p
	self.nameLabel.TextColor3 = p and Color3.new(1, 1, 1) or Theme.text

	if p then
		self.nameGrad.Offset = Vector2.new(-1, 0)
		self.nameSweep:Play()
		UI.pop(self.vipTag, 0.5, 0.25)
	else
		self.nameSweep:Cancel()
	end

	self:fitName()
end

function PlayerBar:setOpen(onOpen)
	self.onOpen = onOpen
	self.openBtn.Visible = onOpen ~= nil

	if not onOpen then
		self.avatarRing.Transparency = 1
	end
end

function PlayerBar:setReport(onReport, p)
	self.onReport = onReport
	self.reported = p and true or false
	local visible = onReport ~= nil
	local text = self.reported and "Reported" or "Report"

	if self.reportBtn.Visible ~= visible or self.reportText.Text ~= text then
		local v4 = self.reportBtn.Visible ~= visible or self.clockOut
		self.reportBtn.Visible = visible
		self.reportText.Text = text

		if v4 then
			self:rowsChanged()
		elseif self.width then
			self:layout(self.width, self.height)
		end
	end

	self.reportColors(false)
	self.reportBtn.Active = not self.reported
end

function PlayerBar.setStatus(p, value, p2)
	if p.statusLabel.Text ~= (value or "") then
		p.statusLabel.Text = value or ""

		if value and value ~= "" then
			UI.textIn(p.statusLabel, 0.15)
		end
	end

	p.statusLabel.TextColor3 = p2 or Theme.textDim
end

function PlayerBar:setCaptured(options, value)
	local v4 = #(self.captured or {})
	self.captured = options or {}
	self.diff = value or 0
	self:renderCaptured()

	if #self.captured == v4 + 1 and self.lastAdded then
		UI.pop(self.lastAdded, 0.3, 0.2)
	end
end

function PlayerBar:renderCaptured()
	local captured = self.captured or {}
	local v4 = math.floor(self.height * 0.4)
	local v5 = math.floor(v4 * 0.45)
	local levelWidth = self:levelWidth()
	table.sort(captured, function(a, b): boolean
		local v6 = v[math.abs(a)]
		local v7 = v[math.abs(b)]

		if v6 == v7 then
			return math.abs(a) < math.abs(b)
		end

		return v6 < v7
	end)

	local capturedKey = table.concat(captured, ",") .. "|" .. tostring(self.diff or 0) .. "|" .. v4 .. "|" .. levelWidth

	if
		capturedKey == self._capturedKey
		and (#self.capturedRow:GetChildren() > 0) == (#captured > 0 or (self.diff or 0) > 0)
	then
		self.lastAdded = nil
		return
	end

	self._capturedKey = capturedKey

	for _, child in self.capturedRow:GetChildren() do
		child:Destroy()
	end

	local clone = table.clone(captured)
	local v6 = nil

	for _, v7 in self.renderedCaptured or {} do
		local index = table.find(clone, v7)

		if index then
			table.remove(clone, index)
		end
	end

	self.renderedCaptured = table.clone(captured)
	local v7 = clone[1]
	self.lastAdded = nil

	for _, v8 in captured do
		local v9 = math.abs(v8)

		if v6 and v6 ~= v9 then
			levelWidth += v4 - v5 + 2
		end

		local imageLabel = UI.new("ImageLabel", {
			Size = UDim2.fromOffset(v4, v4),
			Position = UDim2.new(0, levelWidth, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			ScaleType = Enum.ScaleType.Fit,
			Parent = self.capturedRow
		})

		Sprites.applyPiece(imageLabel, v8)

		if v8 == v7 and #clone == 1 then
			self.lastAdded = imageLabel
		end

		levelWidth += v5
		v6 = v9
	end

	if #captured > 0 then
		levelWidth += v4 - v5 + 4
	end

	if (self.diff or 0) > 0 then
		UI.text({
			Text = "+" .. tostring(self.diff),
			FontFace = Theme.fontBold,
			TextSize = math.floor(v4 * 0.8),
			TextColor3 = Theme.textDim,
			Size = UDim2.fromOffset(40, v4),
			Position = UDim2.new(0, levelWidth, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = self.capturedRow
		})
	end
end

function PlayerBar:showClock(clockVisible)
	if self.clockVisible ~= clockVisible then
		self.clockVisible = clockVisible
		self:rowsChanged()
	end
end

function PlayerBar:setClock(p, p2, _, value)
	local formatClock = Config.formatClock(p)
	local v4 = p2 and p < math.min(20000, (value or 600) * 1000 * 0.1 + 10000)
	local clockStateShown = (p2 and 1 or 0) + (v4 and 2 or 0)

	if formatClock == self._clockTextShown and clockStateShown == self._clockStateShown and p2 == self.clockActive then
		return
	end

	self._clockTextShown = formatClock
	self._clockStateShown = clockStateShown
	self.clockText.Text = formatClock

	local backgroundColor = p2 and Theme.text or Theme.panelLight
	local v5 = p2 and Theme.bg or Theme.textDim

	if v4 then
		backgroundColor = Color3.fromRGB(197, 46, 40)
		v5 = Color3.new(1, 1, 1)
	end

	UI.to(self.clockRing, UI.SNAP, {
		Transparency = p2 and not v4 and 0.05 or 1,
		Thickness = p2 and not v4 and 3 or 2
	})
	UI.to(self.clock, UI.SNAP, { BackgroundColor3 = backgroundColor })
	UI.to(self.clockText, UI.SNAP, { TextColor3 = v5 })
	UI.to(self.clockIcon, UI.SNAP, { ImageColor3 = v5 })

	if p2 ~= self.clockActive then
		self.clockActive = p2
		self.clockIcon.Visible = p2

		if p2 then
			self.clockIcon.Rotation = -90
			UI.tween(self.clockIcon, 0.2, { Rotation = 0 }, Enum.EasingStyle.Back)
		end
	end
end

return PlayerBar