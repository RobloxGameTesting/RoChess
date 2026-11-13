local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Chess = ReplicatedStorage:WaitForChild("Chess")
local Config = require(Chess.Config)
local Cosmetics = require(Chess.Cosmetics)
local parent = script.Parent
local Theme = require(parent.Theme)
local UI = require(parent.UI)
local Sound = require(parent.Sound)

local Vip = {}

local v = utf8.char(57346)
local v2 = { "board", "background", "pieces", "accessory", "effect" }

local function vipItems()
	local result = {}

	for _, v3 in v2 do
		for _, v4 in Cosmetics.BY_TYPE[v3] or {} do
			if v4.vip then
				table.insert(result, v4)
			end
		end
	end

	return result
end

Vip.items = vipItems

local v3 = {
	{
		icon = "crown",
		color = Theme.vip,
		title = "Gold name + tag",
		sub = "Your opponents see it every game"
	},
	{
		icon = "star",
		color = Theme.blueSoft,
		title = "The VIP set",
		sub = "5 items you can't get anywhere else"
	},
	{
		icon = "trend",
		color = Color3.fromRGB(112, 148, 255),
		title = "+50% XP",
		sub = "From games, puzzles and Puzzle Sprint"
	},
	{
		icon = "token",
		color = Theme.token,
		title = "2x tokens",
		sub = "From daily tasks and level-ups"
	}
}

function Vip:install()
	local pages = self.pages
	local priceInRobux = nil
	local lastTime = 0

	function self.promptVip()
		if self.isVip() or os.clock() - lastTime < 1 then
			return
		end

		lastTime = os.clock()

		if not pcall(function()
			MarketplaceService:PromptGamePassPurchase(Players.LocalPlayer, Config.VIP_PASS)
		end) then
			self.toast("Couldn't open the purchase. Try again in a moment.", Theme.loss)
		end
	end

	local function wearing(): boolean
		local eq = self.cos and self.cos.eq or {}

		for _, v4 in vipItems() do
			if (v4.type == "board" and self.settings.theme or eq[v4.type]) ~= v4.id then
				return false
			end
		end

		return true
	end

	function Vip.wear()
		if self.isVip() and self.Shop.equip then
			for _, v4 in vipItems() do
				self.Shop.equip(v4)
			end
		end
	end

	local v4 = {}
	local shop = pages.shop
	local scrollingFrame = shop and shop.frame:FindFirstChildOfClass("ScrollingFrame")
	local tokenPacks = scrollingFrame and scrollingFrame:FindFirstChild("TokenPacks")

	if tokenPacks then
		local frame = UI.new("Frame", {
			Name = "Vip",
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Color3.new(1, 1, 1),
			LayoutOrder = 0,
			Parent = tokenPacks
		}, {
			UI.corner(10),
			UI.pad(14, 14, 14, 14),
			UI.list(Enum.FillDirection.Vertical, 10),
			UI.stroke(Theme.vip, 2, 0.15)
		})

		frame:SetAttribute("NoTint", true)
		local uiGradient = Instance.new("UIGradient")
		uiGradient.Rotation = 120
		uiGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(58, 42, 14)),
			ColorSequenceKeypoint.new(0.55, Color3.fromRGB(26, 22, 16)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 16, 14))
		})

		uiGradient.Parent = frame
		v4.frame = frame

		local frame2 = UI.new("Frame", {
			Name = "Head",
			Size = UDim2.new(1, 0, 0, 40),
			BackgroundTransparency = 1,
			LayoutOrder = 1,
			Parent = frame
		})

		v4.crown = UI.icon("crown", 38, Theme.vip, {
			Name = "Crown",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0, 19, 0.5, 0),
			Parent = frame2
		})

		local text = UI.text({
			Name = "Title",
			Text = "VIP",
			FontFace = Theme.fontHeavy,
			TextSize = 28,
			TextColor3 = Color3.new(1, 1, 1),
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, -150, 0, 26),
			Position = UDim2.fromOffset(48, 0),
			Parent = frame2
		})

		local uiGradient2 = Instance.new("UIGradient")
		uiGradient2.Rotation = 90
		uiGradient2.Color = ColorSequence.new(Color3.fromRGB(255, 236, 160), Color3.fromRGB(232, 160, 36))
		uiGradient2.Parent = text
		v4.sub = UI.text({
			Name = "Sub",
			Text = "Stand out and level up faster",
			TextSize = 13,
			TextColor3 = Theme.textSoft,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Size = UDim2.new(1, -150, 0, 16),
			Position = UDim2.fromOffset(48, 25),
			Parent = frame2
		})

		v4.active = UI.new("Frame", {
			Name = "Active",
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.fromScale(1, 0.5),
			Size = UDim2.fromOffset(0, 24),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundColor3 = Theme.teal,
			Visible = false,
			Parent = frame2
		}, {
			UI.corner(UDim.new(1, 0)),
			UI.pad(0, 10, 0, 8),
			UI.list(Enum.FillDirection.Horizontal, 4, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)
		})

		UI.icon("check", 16, Color3.new(1, 1, 1), { LayoutOrder = 1, Parent = v4.active })
		UI.text({
			Text = "ACTIVE",
			FontFace = Theme.fontHeavy,
			TextSize = 13,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.new(0, 0, 1, 0),
			LayoutOrder = 2,
			Parent = v4.active
		})

		local frame3 = UI.new("Frame", {
			Name = "Perks",
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = 2,
			Parent = frame
		})

		local uiGridLayout = Instance.new("UIGridLayout")
		uiGridLayout.CellSize = UDim2.new(0.5, -5, 0, 40)
		uiGridLayout.CellPadding = UDim2.fromOffset(10, 6)
		uiGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uiGridLayout.Parent = frame3

		for k, v5 in v3 do
			local frame4 = UI.new("Frame", {
				Name = "Perk" .. k,
				BackgroundTransparency = 1,
				LayoutOrder = k,
				Parent = frame3
			})

			UI.icon(v5.icon, 24, v5.color, {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0, 12, 0.5, 0),
				Parent = frame4
			})

			UI.text({
				Name = "Title",
				Text = v5.title,
				FontFace = Theme.fontBold,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Size = UDim2.new(1, -32, 0, 18),
				Position = UDim2.fromOffset(32, 2),
				Parent = frame4
			})

			UI.text({
				Name = "Sub",
				Text = v5.sub,
				TextSize = 11,
				TextColor3 = Theme.textDim,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextWrapped = true,
				TextYAlignment = Enum.TextYAlignment.Top,
				Size = UDim2.new(1, -32, 0, 22),
				Position = UDim2.fromOffset(32, 20),
				Parent = frame4
			})
		end

		local frame4 = UI.new("Frame", {
			Name = "Items",
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = 3,
			Parent = frame
		})

		local uiGridLayout2 = Instance.new("UIGridLayout")
		uiGridLayout2.CellSize = UDim2.new(0.2, -5, 0, 84)
		uiGridLayout2.CellPadding = UDim2.fromOffset(6, 6)
		uiGridLayout2.SortOrder = Enum.SortOrder.LayoutOrder
		uiGridLayout2.Parent = frame4
		v4.tiles = {}

		for k, v5 in vipItems() do
			local tile = self.Shop.tile(frame4, v5, {
				order = k,
				size = UDim2.fromScale(1, 1),
				name = false,
				onClick = function(p)
					if v5.type == "effect" then
						self.Cosmetics.previewEffect(p.area, v5.id, false)
					end

					if not self.owns(v5.id) then
						self.toast(v5.name .. ": comes with VIP", Theme.vip)

						return
					end

					self.Shop.equip(v5)
					Sound.play("confirm")
					task.defer(Vip.refresh)
				end
			})

			v4.tiles[k] = tile
		end

		v4.names = UI.text({
			Name = "Names",
			Text = "",
			TextSize = 12,
			TextColor3 = Theme.textDim,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = 4,
			Parent = frame
		})

		local names = {}

		for _, v5 in vipItems() do
			table.insert(names, v5.name)
		end

		v4.names.Text = table.concat(names, "  ·  ")

		v4.button = UI.button({
			parent = frame,
			name = "GetVip",
			size = UDim2.new(1, 0, 0, 50),
			style = "gold",
			icon = "crown",
			iconSize = 24,
			text = "Get VIP",
			textSize = 19,
			font = Theme.fontHeavy,
			layoutOrder = 5,
			onClick = function()
				if self.isVip() then
					if not wearing() then
						Vip.wear()
						Sound.play("unlock")
						self.toast("Wearing the VIP set", Theme.vip, 2.5)
						task.delay(0.3, Vip.refresh)
					end
				else
					self.promptVip()
				end
			end
		})

		v4.button.face:SetAttribute("NoTint", true)

		task.spawn(function()
			local success, productInfoAsync = pcall(
				MarketplaceService.GetProductInfoAsync,
				MarketplaceService,
				Config.VIP_PASS,
				Enum.InfoType.GamePass
			)

			if success and type(productInfoAsync) == "table" and tonumber(productInfoAsync.PriceInRobux) then
				priceInRobux = productInfoAsync.PriceInRobux
				Vip.refresh()
			end
		end)
	end

	function Vip.refresh()
		if not v4.frame then
			return
		end

		local vip = self.isVip()
		v4.active.Visible = vip
		v4.sub.Text = vip and "Thanks for your support!" or "Stand out and level up faster"

		for _, tile in v4.tiles do
			local eq = self.cos and self.cos.eq or {}
			local theme = tile.item.type == "board" and self.settings.theme or eq[tile.item.type]
			tile.set(true, vip and theme == tile.item.id)
		end

		local button = v4.button

		if vip then
			local v5 = wearing()
			button:setStyle(v5 and "secondary" or "gold")
			button:setText(v5 and "Wearing the VIP set" or "Wear the VIP set")
			button:setEnabled(not v5)
		else
			button:setStyle("gold")
			button:setText(string.format("Get VIP   %s %d", v, priceInRobux or Config.VIP_ROBUX))
			button:setEnabled(true)
		end

		if shop and shop.applyVip then
			shop.applyVip()
		end
	end

	local profile = self.handlers.profile
	function self.handlers.profile(p)
		profile(p)
		Vip.refresh()
	end

	if shop then
		local refresh = shop.refresh

		if refresh then
			function shop.refresh(...)
				refresh(...)
				Vip.refresh()
			end
		end

		local onShow = shop.onShow
		function shop.onShow(...)
			if onShow then
				onShow(...)
			end

			Vip.refresh()
		end
	end

	function Vip.celebrate()
		Sound.play("unlock")
		task.delay(0.2, Sound.play, "currency")
		self.toast("You're VIP! Thanks for supporting RoChess", Theme.vip, 4)
		local absoluteSize = self.gui.AbsoluteSize
		local frame = UI.new("Frame", {
			Name = "VipFx",
			Size = UDim2.new(),
			BackgroundTransparency = 1,
			ZIndex = 60,
			Parent = self.gui
		})
		local colors = {
			Theme.vip,
			Color3.fromRGB(255, 240, 180),
			Color3.fromRGB(214, 150, 30),
			Color3.new(1, 1, 1)
		}

		for k, v5 in { 0.25, 0.5, 0.75 } do
			task.delay((k - 1) * 0.15, function()
				UI.confetti(frame, Vector2.new(absoluteSize.X * v5, absoluteSize.Y * 0.35), {
					count = 34,
					spread = 220,
					zindex = 60,
					colors = colors
				})
			end)
		end

		task.delay(3.5, frame.Destroy, frame)

		if v4.crown then
			UI.pop(v4.crown, 0.4, 0.4)
		end

		local session = self.session

		if session then
			local white = session.myColor == 1 and session.white or session.black

			if type(white) == "table" and white.userId == Players.LocalPlayer.UserId then
				white.vip = true
				self.refreshBars()
			end
		end

		task.delay(1.4, function()
			if self.isVip() and not wearing() then
				self.modals.confirm("Wear the VIP set now?", "Wear it", function()
					Vip.wear()
					task.delay(0.3, Vip.refresh)
				end, "primary")
			end
		end)
	end

	function self.handlers.vipUnlocked()
		if self.profile then
			self.profile.vip = true
		end

		Vip.refresh()
		Vip.celebrate()
	end

	function Vip.debug(options)
		local v5 = options or {}

		if v5.wear then
			Vip.wear()
		end

		if v5.celebrate then
			Vip.celebrate()
		end

		local v6 = { vip = self.isVip(), wearing = wearing(), price = priceInRobux }

		if v4.frame then
			v6.card = {
				button = v4.button.label and v4.button.label.Text,
				enabled = v4.button.enabled,
				active = v4.active.Visible,
				tiles = #v4.tiles
			}
		end

		v6.bars = {}

		for k, v7 in { top = self.topBar, bottom = self.bottomBar } do
			v6.bars[k] = { name = v7.nameLabel.Text, vip = v7.vipTag.Visible }
		end

		return v6
	end

	Vip.refresh()
end

return Vip