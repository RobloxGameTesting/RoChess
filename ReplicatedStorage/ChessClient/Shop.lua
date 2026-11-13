local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Chess = ReplicatedStorage:WaitForChild("Chess")
local Cosmetics = require(Chess.Cosmetics)
local Config = require(Chess.Config)
local parent = script.Parent
local Theme = require(parent.Theme)
local UI = require(parent.UI)
local Sound = require(parent.Sound)
local Haptics = require(parent.Haptics)
local Cosmetics2 = require(parent.Cosmetics)

local Shop = {}

local CRATE_PRICE = Cosmetics.CRATE_PRICE

local function rarityOf(p) -- 10 equivalent calls inferred from this helper
	return Cosmetics.RARITY[p.rarity] or Cosmetics.RARITIES[1]
end

local function hex(color) -- 2 equivalent calls inferred from this helper
	return string.format(
		"#%02X%02X%02X",
		math.floor(color.R * 255),
		math.floor(color.G * 255),
		(math.floor(color.B * 255))
	)
end

local function pct(p)
	if p <= 0 then
		return "0%"
	end

	local v = p * 100

	if v < 10 and math.abs(v - math.round(v)) > 0.05 then
		return string.format("%.1f%%", v)
	end

	return string.format("%d%%", (math.round(v)))
end

local function tokenChip(frame, p, p2, value, p3)
	local frame2 = UI.new("Frame", {
		Name = "Tokens",
		Size = UDim2.new(0, 0, 0, p2 + 4),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		LayoutOrder = value or 0,
		Parent = frame
	}, { UI.list(Enum.FillDirection.Horizontal, 4, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center) })
	UI.icon("token", p2, Theme.token, { Name = "Icon", LayoutOrder = 1, Parent = frame2 })
	return frame2, (UI.text({
		Name = "Amount",
		Text = tostring(p),
		FontFace = Theme.fontHeavy,
		TextSize = (math.floor)(p2 * 0.95),
		TextColor3 = p3 or Theme.token,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 1, 0),
		LayoutOrder = 2,
		Parent = frame2
	}))
end

local function tile(parent2, data, data2)
	local v = rarityOf(data) -- inferred equivalent call
	local textButton = UI.new("TextButton", {
		Name = data.id,
		Size = data2.size or UDim2.fromOffset(92, 92),
		BackgroundColor3 = Theme.panelHeader,
		LayoutOrder = data2.order or 0,
		ClipsDescendants = true,
		Parent = parent2
	}, { UI.corner(10) })
	textButton:SetAttribute("Sfx", data2.onClick and "press" or "none")
	local frame = UI.new("Frame", {
		Name = "Glow",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = v.color,
		BackgroundTransparency = 0.82,
		Parent = textButton
	})

	local uiGradient = Instance.new("UIGradient")
	uiGradient.Rotation = 90
	uiGradient.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) })
	uiGradient.Parent = frame
	local frame2 = UI.new("Frame", {
		Name = "Area",
		Size = UDim2.new(1, 0, 1, data2.name == false and -4 or -22),
		BackgroundTransparency = 1,
		Parent = textButton
	})

	Cosmetics2.preview(data, frame2)

	if data.type == "effect" and not data.free and data2.loop ~= false then
		Cosmetics2.loopEffect(frame2, data.id, math.random() * 1.4)
	end

	if data2.name ~= false then
		UI.text({
			Name = "Name",
			Text = data.name,
			FontFace = Theme.fontBold,
			TextSize = 12,
			TextColor3 = Theme.textSoft,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Size = UDim2.new(1, -8, 0, 16),
			Position = UDim2.new(0, 4, 1, -20),
			Parent = textButton
		})
	end

	UI.new("Frame", {
		Name = "Bar",
		Size = UDim2.new(1, 0, 0, 3),
		Position = UDim2.new(0, 0, 1, -3),
		BackgroundColor3 = v.color,
		Parent = textButton
	})

	local stroke = UI.stroke(Theme.green, 2.5, 1)
	stroke.Parent = textButton

	if data.vip then
		local frame3 = UI.new("Frame", {
			Name = "VipTag",
			Position = UDim2.fromOffset(4, 4),
			Size = UDim2.fromOffset(28, 15),
			BackgroundColor3 = v.color,
			ZIndex = 4,
			Parent = textButton
		}, { UI.corner(UDim.new(0, 4)) })
		UI.text({
			Text = "VIP",
			FontFace = Theme.fontHeavy,
			TextSize = 11,
			TextColor3 = Color3.fromRGB(64, 38, 4),
			Size = UDim2.fromScale(1, 1),
			ZIndex = 4,
			Parent = frame3
		})
	end

	local v2 = { button = textButton, area = frame2, stroke = stroke, item = data }
	function v2.set(p, p2)
		local lock = textButton:FindFirstChild("Lock")

		if p or lock then
			if p and lock then
				lock:Destroy()
			end
		else
			local frame3 = UI.new("Frame", {
				Name = "Lock",
				Size = UDim2.fromScale(1, 1),
				BackgroundColor3 = Color3.new(0, 0, 0),
				BackgroundTransparency = data.type == "effect" and 0.65 or 0.45,
				ZIndex = 3,
				Parent = textButton
			})

			UI.icon("lock", 20, Theme.textSoft, {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -5, 0, 5),
				ZIndex = 3,
				Parent = frame3
			})
		end

		stroke.Transparency = p2 and 0 or 1
		local equipped = textButton:FindFirstChild("Equipped")

		if p2 and not equipped then
			local frame3 = UI.new("Frame", {
				Name = "Equipped",
				Size = UDim2.fromOffset(20, 20),
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -4, 0, 4),
				BackgroundColor3 = Theme.green,
				ZIndex = 3,
				Parent = textButton
			}, { UI.corner(UDim.new(1, 0)) })
			UI.icon("check", 16, Color3.new(1, 1, 1), {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				ZIndex = 3,
				Parent = frame3
			})

			UI.pop(frame3, 0.4, 0.2)
		elseif not p2 and equipped then
			equipped:Destroy()
		end
	end

	if data2.owned ~= nil then
		v2.set(data2.owned, data2.equipped)
	end

	if data2.onClick then
		textButton.Activated:Connect(function()
			data2.onClick(v2)
		end)
		textButton.MouseEnter:Connect(function()
			UI.tween(textButton, UI.FAST, { BackgroundColor3 = Theme.rowActive })
		end)
		textButton.MouseLeave:Connect(function()
			UI.tween(textButton, UI.SNAP, { BackgroundColor3 = Theme.panelHeader })
		end)
	end

	return v2
end

Shop.tile = tile

function Shop:install()
	local pages = self.pages
	self.cos = nil
	local set = {}

	function self.owns(p): boolean
		local v = Cosmetics.BY_ID[p]
		return v ~= nil and (v.free == true or set[p] == true)
	end

	local function equippedId(p) -- 9 equivalent calls inferred from this helper
		local eq = self.cos and self.cos.eq or {}

		if p == "board" then
			return self.settings.theme
		end

		return eq[p] or Cosmetics.DEFAULT[p]
	end

	local function tokens() -- 9 equivalent calls inferred from this helper
		return self.tasks and tonumber(self.tasks.tokens) or 0
	end

	local function owned(p)
		local count = 0
		local count2 = 0

		for k, v in Cosmetics.CRATE_POOL[p] or {} do
			for k2, v2 in v do
				count += 1

				if set[v2.id] then
					count2 += 1
				end
			end
		end

		return count2, count
	end

	local function ownedOfType(p)
		local count = 0
		local count2 = 0

		for k, v in Cosmetics.BY_TYPE[p] do
			if v.free or v.vip then
				continue
			end

			count += 1

			if set[v.id] then
				count2 += 1
			end
		end

		return count2, count
	end

	local v = nil
	local v2 = nil

	local function setCos(cos)
		if type(cos) ~= "table" then
			return
		end

		self.cos = cos
		set = {}

		for k, v3 in cos.inv or {} do
			set[v3] = true
		end

		self.applyCosmetics()

		if v then
			v.refresh()
		end

		if v2 then
			v2.refresh()
		end
	end
	self.setCos = setCos

	local profile = self.handlers.profile
	function self.handlers.profile(p)
		profile(p)

		if p.cos then
			setCos(p.cos)
		end
	end

	local function equip(p)
		if not self.owns(p.id) then
			return
		end

		local cos = self.cos or { inv = {}, eq = {} }
		cos.eq = cos.eq or {}
		cos.eq[p.type] = p.id

		if p.type == "board" then
			self.settings.theme = p.id
			self.applySettings()
		end

		setCos(cos)
		task.spawn(function()
			local request = self.request({ type = "equip", kind = p.type, id = p.id })

			if type(request) == "table" and request.cos then
				setCos(request.cos)

				if p.type == "board" and request.cos.eq then
					self.settings.theme = request.cos.eq.board
					self.applySettings()
				end
			end
		end)
	end
	Shop.equip = equip

	local flag = false
	local openCrate

	local function fillerItem(p)
		local odds = Cosmetics.odds(p)
		local v3 = math.random()
		local total = 0
		local v4 = "common"

		for k, v5 in Cosmetics.RARITIES do
			if not (odds[v5.id] > 0) then
				continue
			end

			total += odds[v5.id]
			v4 = v5.id

			if v3 < total then
				break
			end
		end

		local v5 = Cosmetics.CRATE_POOL[p][v4]
		return v5[math.random(1, #v5)]
	end

	local function nearMissItem(p, p2)
		if math.random() >= 0.35 then
			return nil
		end

		local odds = Cosmetics.odds(p)
		local v3 = {}

		for k, v4 in Cosmetics.RARITIES do
			local v5 = Cosmetics.CRATE_POOL[p][v4.id]

			if not (v4.order >= 3 and v4.order > rarityOf(p2).order and (odds[v4.id] or 0) > 0 and v5) then -- inferred equivalent call
				continue
			end

			if not (#v5 > 0) then
				continue
			end

			for k2, v6 in v5 do
				table.insert(v3, v6)
			end
		end

		if #v3 == 0 then
			return nil
		end

		return v3[math.random(1, #v3)]
	end

	local function showReel(p, data)
		local v3 = Cosmetics.CRATE_BY_ID[p]
		local v4 = Cosmetics.BY_ID[data.item]
		local v5 = rarityOf(v4) -- inferred equivalent call
		local modal, v6 = self.modals.openModal("Crate", 480, { dismissable = false })
		local list = UI.list(Enum.FillDirection.Vertical, 12, Enum.HorizontalAlignment.Center)
		list.Parent = modal
		local padded = UI.pad(16, 16, 16, 16)
		padded.Parent = modal
		UI.text({
			Name = "Title",
			Text = v3.crate,
			FontFace = Theme.fontHeavy,
			TextSize = 20,
			Size = UDim2.new(1, 0, 0, 24),
			LayoutOrder = 1,
			Parent = modal
		})

		local frame = UI.new("Frame", {
			Name = "Reel",
			Size = UDim2.new(1, 0, 0, 108),
			BackgroundColor3 = Theme.bgDark,
			ClipsDescendants = true,
			LayoutOrder = 2,
			Parent = modal
		}, { UI.corner(10) })
		local frame2 = UI.new("Frame", {
			Name = "Strip",
			Size = UDim2.fromOffset(4400, 92),
			Position = UDim2.fromOffset(0, 8),
			BackgroundTransparency = 1,
			Parent = frame
		})

		local v7 = nearMissItem(p, v4)
		local v8 = {}

		for i = 1, 44 do
			local v9 = i == 38 and v4 or i == 37 and v7 or fillerItem(p)
			local v10 = tile(frame2, v9, { name = false, loop = false })
			v10.button.Position = UDim2.fromOffset((i - 1) * 100, 0)
			v10.button.Active = false
			v8[i] = v10

			if v9.type ~= "effect" or v9.free then
				continue
			end

			Cosmetics2.loopEffect(v10.area, v9.id, math.random() * 0.4)
		end

		local frame3 = UI.new("Frame", {
			Name = "Marker",
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.new(0, 3, 1, 0),
			BackgroundColor3 = Theme.token,
			ZIndex = 5,
			Parent = frame
		})

		for k, v9 in { 0, 1 } do
			UI.new("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, v9),
				Size = UDim2.fromOffset(14, 14),
				Rotation = 45,
				BackgroundColor3 = Theme.token,
				ZIndex = 5,
				Parent = frame3
			})
		end

		for k, v9 in { 0, 1 } do
			local frame4 = UI.new("Frame", {
				Name = "Fade",
				AnchorPoint = Vector2.new(v9, 0),
				Position = UDim2.fromScale(v9, 0),
				Size = UDim2.new(0, 60, 1, 0),
				BackgroundColor3 = Theme.bgDark,
				ZIndex = 4,
				Parent = frame
			})

			local uiGradient = Instance.new("UIGradient")
			uiGradient.Transparency = NumberSequence.new(v9 == 0 and 0 or 1, v9 == 0 and 1 or 0)
			uiGradient.Parent = frame4
		end

		local frame4 = UI.new("Frame", {
			Name = "Result",
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Visible = false,
			LayoutOrder = 3,
			Parent = modal
		}, { UI.list(Enum.FillDirection.Vertical, 4, Enum.HorizontalAlignment.Center) })
		UI.text({
			Name = "Rarity",
			Text = string.upper(v5.name),
			FontFace = Theme.fontHeavy,
			TextSize = 14,
			TextColor3 = v5.color,
			Size = UDim2.new(1, 0, 0, 16),
			LayoutOrder = 1,
			Parent = frame4
		})

		UI.text({
			Name = "ItemName",
			Text = v4.name,
			FontFace = Theme.fontHeavy,
			TextSize = 26,
			Size = UDim2.new(1, 0, 0, 30),
			LayoutOrder = 2,
			Parent = frame4
		})

		_ = UI.text({
			Name = "Status",
			Text = data.dup and string.format("You already have this one. +%d tokens back", data.refund or 0) or "New " .. string.lower(Cosmetics.TYPE[v4.type].one) .. "!",
			FontFace = Theme.fontBold,
			TextSize = 14,
			TextColor3 = data.dup and Theme.token or Theme.green,
			Size = UDim2.new(1, 0, 0, 20),
			LayoutOrder = 3,
			Parent = frame4
		})

		local frame5 = UI.new("Frame", {
			Name = "Buttons",
			Size = UDim2.new(1, 0, 0, 46),
			BackgroundTransparency = 1,
			LayoutOrder = 4,
			Parent = modal
		}, { UI.list(Enum.FillDirection.Horizontal, 8, Enum.HorizontalAlignment.Center) })
		local button = UI.button({
			parent = frame5,
			name = "Skip",
			size = UDim2.new(0.5, -4, 1, 0),
			style = "ghost",
			text = "Skip",
			textSize = 16,
			layoutOrder = 9
		})

		local button2 = UI.button({
			parent = frame5,
			name = "Equip",
			size = UDim2.new(1 / 3, -6, 1, 0),
			style = "primary",
			text = "Equip",
			textSize = 17,
			layoutOrder = 1
		})

		local button3 = UI.button({
			parent = frame5,
			name = "Again",
			size = UDim2.new(1 / 3, -6, 1, 0),
			style = "secondary",
			icon = "token",
			iconColor = Theme.token,
			iconSize = 18,
			text = "Again " .. CRATE_PRICE,
			textSize = 16,
			layoutOrder = 2
		})

		local button4 = UI.button({
			parent = frame5,
			name = "Done",
			size = UDim2.new(1 / 3, -6, 1, 0),
			style = "secondary",
			text = "Done",
			textSize = 16,
			layoutOrder = 3
		})

		button2.holder.Visible = false
		button3.holder.Visible = false
		button4.holder.Visible = false

		local flag2 = false
		local tween = nil
		local function finish()
			if flag2 then
				return
			end

			flag2 = true
			flag = false
			button.holder.Visible = false
			setCos(data.cos)
			local v9 = v8[38]
			UI.pop(v9.button, 0.8, 0.3)
			UI.tween(v9.stroke, 0.2, { Transparency = 0, Color = v5.color })

			for k, v10 in v8 do
				if k == 38 then
					continue
				end

				local frame6 = UI.new("Frame", {
					Name = "Shade",
					Size = UDim2.fromScale(1, 1),
					BackgroundColor3 = Color3.new(0, 0, 0),
					BackgroundTransparency = 1,
					ZIndex = 3,
					Parent = v10.button
				})

				UI.tween(frame6, 0.3, { BackgroundTransparency = 0.5 })
			end

			v9.button.ZIndex = 2
			UI.reveal(frame4, true, 6)
			local v10 = ({ common = "step", rare = "success", epic = "unlock", legendary = "win" })[v5.id] or "success"

			if v5.id == "legendary" then
				Haptics.play("legendary")
			end

			Sound.play(v10)

			if data.dup then
				task.delay(0.25, Sound.play, "currency")
			end

			if v5.order >= 3 then
				local v11 = frame.AbsolutePosition + frame.AbsoluteSize / 2 - self.gui.AbsolutePosition
				local frame6 = UI.new("Frame", {
					Name = "CrateFx",
					Size = UDim2.new(),
					BackgroundTransparency = 1,
					ZIndex = 50,
					Parent = self.gui
				})
				UI.confetti(frame6, v11, {
					count = v5.order == 4 and 80 or 40,
					spread = v5.order == 4 and 260 or 180,
					zindex = 50,
					colors = { v5.color, Theme.token, Color3.new(1, 1, 1) }
				})

				task.delay(3, frame6.Destroy, frame6)
			end

			local visible = not data.dup or equippedId(v4.type) ~= v4.id -- inferred equivalent call
			button2.holder.Visible = visible
			button2:setText(equippedId(v4.type) == v4.id and "Equipped" or "Equip") -- inferred equivalent call
			button3.holder.Visible = true
			button4.holder.Visible = true
			local v11 = visible and 3 or 2

			for k, v12 in { button2, button3, button4 } do
				v12.holder.Size = UDim2.new(1 / v11, -(8 * (v11 - 1)) / v11, 1, 0)
			end

			button3:setStyle(CRATE_PRICE <= tokens() and "secondary" or "ghost") -- inferred equivalent call
			button3:setEnabled(Cosmetics.crateLive(v3))

			if v6.dim then
				v6.dim.Activated:Connect(function()
					self.modals.close("Crate", false, true)
				end)
			end
		end
		function button2.callback()
			equip(v4)
			button2:setText("Equipped")
			button2:setEnabled(false)
			Sound.play("confirm")
		end
		function button3.callback()
			self.modals.close("Crate", true)
			openCrate(p)
		end
		function button4.callback()
			self.modals.close("Crate", false, true)
		end

		task.defer(function()
			local v9 = v7 and -43 + math.random() * 4 or (math.random() - 0.5) * 92 * 0.7

			local function half() -- 4 equivalent calls inferred from this helper
				local x = v6.card.AbsoluteSize.X

				if x <= 0 then
					return 222
				end

				return frame.AbsoluteSize.X / x * 480 / 2
			end

			local function targetX() -- 1 equivalent call inferred from this helper
				return half() - 3746 - v9 -- inferred equivalent call
			end

			frame2.Position = UDim2.fromOffset(half() - 138, 8) -- inferred equivalent call
			tween = UI.tween(frame2, 4.6, {
				Position = UDim2.fromOffset(half() - 3746 - v9, 8) -- inferred equivalent call
			}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

			local v10 = nil
			local renderSteppedConnection = nil
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				if flag2 or not frame2.Parent then
					renderSteppedConnection:Disconnect()

					if not flag2 then
						flag2 = true
						flag = false
						setCos(data.cos)
					end
				else
					local v11 = math.floor((half() - frame2.Position.X.Offset) / 100) -- inferred equivalent call

					if v10 and v11 ~= v10 then
						Sound.play("tick", 1 + 0.25 * math.random())
						Haptics.play("reel")
					end

					v10 = v11
				end
			end)
			tween.Completed:Connect(function(p2)
				if p2 == Enum.PlaybackState.Completed then
					finish()
				end
			end)
			function button.callback()
				if tween then
					tween:Cancel()
				end

				frame2.Position = UDim2.fromOffset(targetX(), 8) -- inferred equivalent call
				finish()
			end
		end)
		Shop.reel = {
			finish = function()
				if button.callback then
					button.callback()
				end
			end
		}
	end

	openCrate = function(crate)
		if flag then
			return
		end

		local v3 = Cosmetics.CRATE_BY_ID[crate]

		if not v3 then
			return
		end

		if Cosmetics.crateLive(v3) then
			if tokens() < CRATE_PRICE then -- inferred equivalent call
				if Shop.needTokens then
					Shop.needTokens(CRATE_PRICE, "The " .. v3.crate, function()
						openCrate(crate)
					end)
					return
				end

				Sound.play("locked")
				self.toast(string.format("You need %d tokens. Earn them from Daily Tasks!", CRATE_PRICE), Theme.token)
			else
				flag = true
				task.spawn(function()
					local request = self.request({ type = "openCrate", crate = crate })

					if type(request) == "table" and request.ok then
						if request.tasks and self.pages.tasks then
							self.pages.tasks.apply(request.tasks, false)
						end

						if self.inLiveGame() then
							flag = false
							setCos(request.cos)

							if v then
								v.refresh()
							end

							local v4 = Cosmetics.BY_ID[request.item]

							if v4 then
								self.toast(
									request.dup and string.format(
										"Crate: %s again, +%d tokens back",
										v4.name,
										request.refund or 0
									) or "Crate: you got " .. v4.name .. "!",
									Theme.token
								)
							end
						else
							if v then
								v.refresh()
							end

							Sound.play("open")
							showReel(crate, request)
						end
					else
						flag = false
						local reason = type(request) == "table" and request.reason or nil

						if reason ~= "busy" then
							self.toast(reason or "Couldn't open the crate. Try again.", Theme.loss)
						end
					end
				end)
			end
		else
			Sound.play("locked")
			self.toast("The " .. v3.crate .. " has ended.", Theme.loss)
		end
	end
	Shop.openCrate = openCrate

	local page, scrollingFrame = pages.newPage("shop", "Shop", "crate", Theme.textSoft, true)
	local shop = { frame = page }
	pages.shop = shop
	v = shop

	local v3 = utf8.char(57346)

	local function card(p, p2) -- 6 equivalent calls inferred from this helper
		p.BackgroundColor3 = p.BackgroundColor3 or Theme.panelLight
		local frame = UI.new("Frame", p, p2)
		local corner = UI.corner(14)
		corner.Parent = frame
		UI.lift(frame, 0.1)
		return frame
	end

	local function restyle(object, p, token) -- 2 equivalent calls inferred from this helper
		object:setStyle(p)

		if object.icon and token then
			task.delay(UI.SNAP + 0.05, function()
				object.icon.ImageColor3 = token
			end)
		end
	end

	local function heading(parent2, name, text, layoutOrder)
		local frame = UI.new("Frame", {
			Name = name,
			Size = UDim2.new(1, 0, 0, 24),
			BackgroundTransparency = 1,
			LayoutOrder = layoutOrder,
			Parent = parent2
		})

		UI.text({
			Name = "Heading",
			Text = text,
			FontFace = Theme.fontBold,
			TextSize = 16,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(0.5, 0, 1, 0),
			Parent = frame
		})

		return frame, (UI.text({
			Name = "Right",
			Text = "",
			RichText = true,
			TextSize = 14,
			TextColor3 = Theme.textDim,
			TextXAlignment = Enum.TextXAlignment.Right,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.fromScale(1, 0),
			Size = UDim2.new(0.6, 0, 1, 0),
			Parent = frame
		}))
	end

	local function limitedText(p, p2) -- 6 equivalent calls inferred from this helper
		local crateLeft = Cosmetics.crateLeft(p)

		if not crateLeft then
			return nil
		end

		if crateLeft <= 0 then
			if p2 then
				return "Ended"
			end

			return "<b>LIMITED TIME</b>  ·  Ended"
		elseif p2 then
			return Cosmetics.formatLeft(crateLeft) .. " left"
		else
			return "<b>LIMITED TIME</b>  ·  Ends in " .. Cosmetics.formatLeft(crateLeft)
		end
	end

	local function crateArt(parent2, p, p2, p3)
		local icon = UI.icon("crate", p2, p.color, p3)
		UI.icon(p.icon, (math.floor)(p2 * 0.42), Color3.new(1, 1, 1), {
			Name = "TypeIcon",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.82, 0.8),
			Parent = icon
		})

		icon.Parent = parent2
		return icon
	end

	local parent2 = card({ -- inferred equivalent call
		Name = "Balance",
		Size = UDim2.new(1, 0, 0, 64),
		LayoutOrder = 0,
		Parent = scrollingFrame
	})

	UI.icon("token", 32, Theme.token, {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 16, 0.5, 0),
		Parent = parent2
	})

	UI.text({
		Name = "Caption",
		Text = "Your tokens",
		TextSize = 12,
		TextColor3 = Theme.textDim,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(0, 120, 0, 16),
		Position = UDim2.fromOffset(60, 10),
		Parent = parent2
	})

	local text = UI.text({
		Name = "Amount",
		Text = "0",
		FontFace = Theme.fontHeavy,
		TextSize = 28,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(0, 120, 0, 30),
		Position = UDim2.fromOffset(60, 24),
		Parent = parent2
	})

	UI.button({
		parent = parent2,
		name = "Earn",
		size = UDim2.fromOffset(120, 36),
		position = UDim2.new(1, -16, 0.5, 0),
		anchor = Vector2.new(1, 0.5),
		style = "secondary",
		icon = "calendar",
		iconColor = Theme.textSoft,
		iconSize = 18,
		text = "Earn more",
		textSize = 14,
		onClick = function()
			pages.show("tasks")
		end
	})

	local frame = UI.new("Frame", {
		Name = "DailyShop",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 2,
		Parent = scrollingFrame
	}, { UI.list(Enum.FillDirection.Vertical, 8) })
	local v4, v5 = heading(frame, "Head", "Daily Shop", 1)
	local frame2 = UI.new("Frame", {
		Name = "Items",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 2,
		Parent = frame
	})

	local uiGridLayout = Instance.new("UIGridLayout")
	uiGridLayout.CellSize = UDim2.new(1 / 3, -6, 0, 156)
	uiGridLayout.CellPadding = UDim2.fromOffset(8, 8)
	uiGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiGridLayout.Parent = frame2

	local v6 = nil
	local result = {}
	local flag2 = false

	local function countdown(p)
		local v7 = math.max(0, (math.floor(p)))
		local v8 = v7 // 3600
		local v9 = v7 % 3600 // 60

		if v8 > 0 then
			return string.format("%dh %dm", v8, v9)
		end

		return string.format("%dm %ds", v9, v7 % 60)
	end

	local function refreshDailyButtons()
		for k, v7 in result do
			local item = v7.item
			local owns = self.owns(item.id)
			local v8 = equippedId(item.type) == item.id -- inferred equivalent call
			v7.tile.set(true, v8)

			restyle(v7.button, owns and "flat" or "secondary", Theme.token) -- inferred equivalent call

			if owns then
				if v8 then
					v7.button:setText("Equipped")
					v7.button.icon.Visible = false
					v7.button:setEnabled(false)
				else
					v7.button:setText("Equip")
					v7.button.icon.Visible = false
					v7.button:setEnabled(true)
				end
			else
				v7.button:setText((tostring(v7.price)))
				v7.button.icon.Visible = true
				v7.button:setEnabled(not flag2)
			end

			v7.tag.Text = owns and "OWNED" or v7.tagText
			v7.tag.TextColor3 = owns and Theme.teal or v7.tagColor
		end
	end

	local function buyDaily(data)
		local item = data.item

		if self.owns(item.id) then
			if equippedId(item.type) ~= item.id then -- inferred equivalent call
				equip(item)
				Sound.play("confirm")
				refreshDailyButtons()
			end
		elseif tokens() < data.price then -- inferred equivalent call
			Shop.needTokens(data.price, item.name, function()
				if data.frame.Parent then
					buyDaily(data)
				end
			end)
		else
			self.modals.confirm(string.format("Buy %s for %d tokens?", item.name, data.price), "Buy", function()
				if flag2 then
					return
				end

				flag2 = true
				refreshDailyButtons()
				task.spawn(function()
					local request = self.request({ type = "buyItem", id = item.id })
					flag2 = false

					if type(request) == "table" then
						if request.tasks and self.pages.tasks then
							self.pages.tasks.apply(request.tasks, false)
						end

						if request.cos then
							setCos(request.cos)
						end

						if request.ok then
							Sound.play("currency")
							task.delay(0.2, Sound.play, "unlock")
							local v7 = rarityOf(item) -- inferred equivalent call
							self.toast("Got " .. item.name .. "!", v7.color, 3)
							UI.pop(data.frame, 0.85, 0.3)
							local v8 = data.frame.AbsolutePosition + data.frame.AbsoluteSize / 2 - self.gui.AbsolutePosition
							local frame3 = UI.new("Frame", {
								Name = "BuyFx",
								Size = UDim2.new(),
								BackgroundTransparency = 1,
								ZIndex = 50,
								Parent = self.gui
							})
							UI.confetti(frame3, v8, {
								count = 26,
								spread = 120,
								zindex = 50,
								colors = { v7.color, Theme.token, Color3.new(1, 1, 1) }
							})
							task.delay(2.5, frame3.Destroy, frame3)
							refreshDailyButtons()
						else
							if request.reason ~= "busy" then
								self.toast(request.reason or "Couldn't buy that.", Theme.loss)
							end

							if request.stale then
								shop.buildDaily(true)
							end

							refreshDailyButtons()
						end
					else
						self.toast("Couldn't buy that. Try again.", Theme.loss)
						refreshDailyButtons()
					end
				end)
			end, "primary")
		end
	end
	function Shop.buyDaily(p)
		if result[p] then
			buyDaily(result[p])
		end
	end

	function shop.buildDaily(p)
		local day = Cosmetics.dayOf(self.serverNow())

		if day == v6 and not p then
			refreshDailyButtons()
			return
		end

		v6 = day

		for k, v7 in result do
			v7.frame:Destroy()
		end

		result = {}

		for k, v7 in Cosmetics.dailyShop(day) do
			local v8 = Cosmetics.BY_ID[v7.id]
			local frame3 = UI.new("Frame", {
				Name = "Daily" .. k,
				BackgroundTransparency = 1,
				LayoutOrder = k,
				Parent = frame2
			})

			local tile2 = tile(frame3, v8, {
				size = UDim2.new(1, 0, 1, -42),
				onClick = v8.type == "effect" and (function(p2)
					Cosmetics2.previewEffect(p2.area, v8.id, false)
				end or nil) or nil
			})

			tile2.area.Position = UDim2.fromOffset(0, 12)
			tile2.area.Size = UDim2.new(1, 0, 1, -32)
			local v9 = rarityOf(v8) -- inferred equivalent call
			local text2 = UI.text({
				Name = "Type",
				Text = string.upper(Cosmetics.TYPE[v8.type].one),
				FontFace = Theme.fontHeavy,
				TextSize = 10,
				TextColor3 = v9.color,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, -30, 0, 12),
				Position = UDim2.fromOffset(8, 6),
				ZIndex = 4,
				Parent = tile2.button
			})

			local v10 = {
				frame = frame3,
				item = v8,
				price = v7.price,
				tile = tile2,
				tag = text2,
				tagText = text2.Text,
				tagColor = v9.color
			}
			v10.button = UI.button({
				parent = frame3,
				name = "Buy",
				size = UDim2.new(1, 0, 0, 36),
				position = UDim2.new(0, 0, 1, 0),
				anchor = Vector2.new(0, 1),
				style = "secondary",
				icon = "token",
				iconColor = Theme.token,
				iconSize = 18,
				text = tostring(v7.price),
				textSize = 16,
				font = Theme.fontHeavy,
				onClick = function()
					buyDaily(v10)
				end
			})

			table.insert(result, v10)
		end

		refreshDailyButtons()
	end
	function shop.dailyCells()
		return result
	end

	task.spawn(function()
		while page.Parent do
			if page.Visible and v6 then
				local serverNow = self.serverNow()

				if Cosmetics.dayOf(serverNow) ~= v6 then
					shop.buildDaily()
				end

				v5.Text = string.format(
					"New items in <font color=\"#F3F4F6\">%s</font>",
					countdown(Cosmetics.resetAt(v6) - serverNow)
				)
			end

			task.wait(1)
		end
	end)

	local frame3 = UI.new("Frame", {
		Name = "TokenPacks",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 3,
		Parent = scrollingFrame
	}, { UI.list(Enum.FillDirection.Vertical, 8) })
	heading(frame3, "Heading", "Get tokens", 1)
	local frame4 = UI.new("Frame", {
		Name = "Packs",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 2,
		Parent = frame3
	})

	local uiGridLayout2 = Instance.new("UIGridLayout")
	uiGridLayout2.CellSize = UDim2.new(1 / 3, -6, 0, 136)
	uiGridLayout2.CellPadding = UDim2.fromOffset(8, 8)
	uiGridLayout2.SortOrder = Enum.SortOrder.LayoutOrder
	uiGridLayout2.Parent = frame4

	local v7, v8 = heading(scrollingFrame, "CratesHeading", "Crates", 4)
	v8.Text = CRATE_PRICE .. " tokens each"

	local parent3 = card({ -- inferred equivalent call
		Name = "CratesUnavailable",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Visible = false,
		LayoutOrder = 25,
		Parent = scrollingFrame
	}, { UI.pad(12, 16, 12, 16) })
	UI.icon("info", 20, Theme.textSoft, { Position = UDim2.fromOffset(0, 0), Parent = parent3 })

	UI.text({
		Name = "Text",
		Text = "<b>Crates aren't available in your country.</b> Roblox doesn't allow random items bought with Robux there. You can still get every item from the <b>Daily Shop</b> above, and spend your tokens there.",
		RichText = true,
		TextSize = 14,
		TextColor3 = Theme.textSoft,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Size = UDim2.new(1, -32, 0, 0),
		Position = UDim2.fromOffset(32, 1),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = parent3
	})

	local priceInRobuxesById = {}
	local packTiles = {}
	local lastTime = 0
	local function buy(p)
		if p.id == 0 then
			Sound.play("locked")
			self.toast("Token packs are coming soon!", Theme.token)
		else
			if os.clock() - lastTime < 1 then
				return
			end

			lastTime = os.clock()

			if not pcall(function()
				MarketplaceService:PromptProductPurchase(Players.LocalPlayer, p.id)
			end) then
				self.toast("Couldn't open the purchase. Try again in a moment.", Theme.loss)
			end
		end
	end
	local function priceOf(p) -- 4 equivalent calls inferred from this helper
		return priceInRobuxesById[p.id] or p.robux
	end

	local function bonusOf(pack) -- 3 equivalent calls inferred from this helper
		local v9 = Config.TOKEN_PACKS[1]
		local v10 = v9.tokens / math.max(1, priceOf(v9)) -- inferred equivalent call
		return (math.floor((pack.tokens / math.max(1, priceOf(pack)) / v10 - 1) * 100 + 0.5)) -- inferred equivalent call
	end

	local v9 = 0

	for k, pack in Config.TOKEN_PACKS do
		local v10 = card({ -- inferred equivalent call
			Name = "Pack" .. pack.tokens,
			LayoutOrder = k,
			Parent = frame4
		})

		local v11 = math.min(k, 4)
		local frame5 = UI.new("Frame", {
			Name = "Coins",
			Size = UDim2.new(1, 0, 0, 44),
			Position = UDim2.fromOffset(0, 12),
			BackgroundTransparency = 1,
			Parent = v10
		})

		for i = 1, v11 do
			local v12 = (i - (v11 + 1) / 2) * 13
			local v13 = i % 2 == 0 and -5 or 0
			UI.icon("token", math.min(k, 5) * 2 + 28, Theme.token, {
				Name = "Coin",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, v12, 0.5, v13),
				ZIndex = i + 1,
				Parent = frame5
			})
		end

		UI.text({
			Name = "Amount",
			Text = tostring(pack.tokens),
			FontFace = Theme.fontHeavy,
			TextSize = 20,
			Size = UDim2.new(1, 0, 0, 24),
			Position = UDim2.fromOffset(0, 56),
			Parent = v10
		})

		UI.text({
			Name = "Label",
			Text = "tokens",
			TextSize = 12,
			TextColor3 = Theme.textDim,
			Size = UDim2.new(1, 0, 0, 14),
			Position = UDim2.fromOffset(0, 78),
			Parent = v10
		})

		local frame6 = UI.new("Frame", {
			Name = "Bonus",
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -6, 0, 6),
			Size = UDim2.fromOffset(0, 18),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundColor3 = Theme.selBg,
			Visible = false,
			ZIndex = 8,
			Parent = v10
		}, { UI.corner(UDim.new(1, 0)), UI.pad(0, 6, 0, 6) })
		local text2 = UI.text({
			Text = "",
			FontFace = Theme.fontHeavy,
			TextSize = 12,
			TextColor3 = Theme.teal,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.fromScale(0, 1),
			ZIndex = 8,
			Parent = frame6
		})

		packTiles[k] = {
			frame = v10,
			pack = pack,
			button = UI.button({
				parent = v10,
				name = "Buy",
				size = UDim2.new(1, -16, 0, 34),
				position = UDim2.new(0.5, 0, 1, -8),
				anchor = Vector2.new(0.5, 1),
				style = "secondary",
				text = v3 .. pack.robux,
				textSize = 16,
				font = Theme.fontHeavy,
				onClick = function()
					buy(pack)
				end
			}),
			ribbon = frame6,
			ribbonText = text2
		}
	end

	local function refreshPacks()
		v9 = 0

		for k, v10 in packTiles do
			local v11 = v9
			v9 = math.max(v11, bonusOf(v10.pack)) -- inferred equivalent call
		end

		for k, v10 in packTiles do
			local pack = v10.pack
			local v11 = pack.id == 0
			local v12 = bonusOf(pack) -- inferred equivalent call
			local v13

			if v12 >= 5 then
				v13 = v12 == v9
			else
				v13 = false
			end

			v10.button:setText(v11 and "Soon" or v3 .. priceOf(pack)) -- inferred equivalent call

			v10.button:setStyle(v13 and not v11 and "primary" or "secondary")
			v10.ribbon.Visible = v12 >= 5
			v10.ribbonText.Text = (v13 and "BEST " or "") .. "+" .. v12 .. "%"
			v10.ribbon.BackgroundColor3 = v13 and Theme.token or Theme.selBg
			v10.ribbonText.TextColor3 = v13 and Theme.bgDark or Theme.teal
		end
	end
	refreshPacks()

	local flag3 = false
	local function loadPrices() -- 2 equivalent calls inferred from this helper
		if flag3 then
			return
		end

		flag3 = true
		task.spawn(function()
			for k, v10 in packTiles do
				if v10.pack.id == 0 then
					continue
				end

				local success, result2 = pcall(function()
					return MarketplaceService:GetProductInfo(v10.pack.id, Enum.InfoType.Product)
				end)

				if success and type(result2) == "table" then
					if tonumber(result2.PriceInRobux) then
						priceInRobuxesById[v10.pack.id] = tonumber(result2.PriceInRobux)
					end

					v10.frame.Visible = result2.IsForSale ~= false
				else
					flag3 = false
				end
			end

			refreshPacks()
		end)
	end
	task.delay(3, loadPrices)
	shop.packTiles = packTiles

	local v10 = true
	local v11 = false
	local function checkPolicy(p) -- 1 equivalent call inferred from this helper
		if p or not v11 and Cosmetics.TOKENS_FOR_SALE then
			v11 = true
			task.spawn(function()
				local request = self.request({ type = "shopInfo" })

				if type(request) ~= "table" then
					v11 = false
					return
				end

				v10 = request.canOpen ~= false

				v11 = v10
				shop.refresh()
			end)
		end
	end

	local function oddsText(p)
		local odds = Cosmetics.odds(p)
		local v12 = {}

		for k, v13 in Cosmetics.RARITIES do
			if not (odds[v13.id] > 0) then
				continue
			end

			table.insert(
				v12,
				string.format("<font color=\"%s\">%s</font> %s", hex(v13.color), v13.name, pct(odds[v13.id])) -- inferred equivalent call
			)
		end

		return table.concat(v12, "   ")
	end

	local cards = {}

	for k, crate in Cosmetics.CRATES do
		local v12 = { crate = crate, tiles = {}, expanded = false }
		cards[crate.id] = v12
		v12.card = card({ -- inferred equivalent call
			Name = "Crate_" .. crate.id,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = 10 + k,
			Parent = scrollingFrame
		}, { UI.pad(12, 12, 12, 12), UI.list(Enum.FillDirection.Vertical, 8) })

		if crate.ends then
			v12.timer = UI.text({
				Name = "Limited",
				Text = limitedText(crate, false) or "", -- inferred equivalent call
				RichText = true,
				FontFace = Theme.fontBold,
				TextSize = 12,
				TextColor3 = crate.color,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, 0, 0, 16),
				LayoutOrder = 0,
				Parent = v12.card
			})
		end

		local frame5 = UI.new("Frame", {
			Name = "Top",
			Size = UDim2.new(1, 0, 0, 52),
			BackgroundTransparency = 1,
			LayoutOrder = 1,
			Parent = v12.card
		})

		crateArt(frame5, crate, 48, {
			Name = "Crate",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0)
		})

		UI.text({
			Name = "Title",
			Text = crate.crate,
			FontFace = Theme.fontBold,
			TextSize = 16,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Size = UDim2.new(1, -152, 0, 20),
			Position = UDim2.fromOffset(60, 6),
			Parent = frame5
		})

		v12.sub = UI.text({
			Name = "Owned",
			Text = "",
			TextSize = 14,
			TextColor3 = Theme.textDim,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Size = UDim2.new(1, -152, 0, 18),
			Position = UDim2.fromOffset(60, 27),
			Parent = frame5
		})

		v12.open = UI.button({
			parent = frame5,
			name = "Open",
			size = UDim2.fromOffset(84, 40),
			position = UDim2.new(1, 0, 0.5, 0),
			anchor = Vector2.new(1, 0.5),
			style = "secondary",
			icon = "token",
			iconColor = Theme.token,
			iconSize = 18,
			text = tostring(CRATE_PRICE),
			textSize = 16,
			font = Theme.fontHeavy,
			onClick = function()
				openCrate(crate.id)
			end
		})

		v12.odds = UI.text({
			Name = "Odds",
			Text = oddsText(crate.id),
			RichText = true,
			FontFace = Theme.fontBold,
			TextSize = 12,
			TextColor3 = Theme.textSoft,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = 2,
			Parent = v12.card
		})

		local textButton = UI.new("TextButton", {
			Name = "SeeItems",
			Size = UDim2.new(1, 0, 0, 24),
			BackgroundTransparency = 1,
			Text = "",
			LayoutOrder = 3,
			Parent = v12.card
		}, { UI.list(Enum.FillDirection.Horizontal, 4, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center) })
		textButton:SetAttribute("Sfx", "tab")
		local text2 = UI.text({
			Text = "See items",
			FontFace = Theme.fontBold,
			TextSize = 14,
			TextColor3 = Theme.textDim,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.new(0, 0, 1, 0),
			LayoutOrder = 1,
			Parent = textButton
		})

		local icon = UI.icon("down", 16, Theme.textDim, { LayoutOrder = 2, Parent = textButton })
		UI.hover(textButton, text2, { TextColor3 = Theme.text }, { TextColor3 = Theme.textDim })
		v12.grid = UI.new("Frame", {
			Name = "Items",
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Visible = false,
			LayoutOrder = 4,
			Parent = v12.card
		})

		local uiGridLayout3 = Instance.new("UIGridLayout")
		uiGridLayout3.CellSize = UDim2.new(1 / 3, -6, 0, 104)
		uiGridLayout3.CellPadding = UDim2.fromOffset(8, 8)
		uiGridLayout3.SortOrder = Enum.SortOrder.LayoutOrder
		uiGridLayout3.Parent = v12.grid
		function v12.build()
			for k2, tile2 in v12.tiles do
				tile2.button:Destroy()
			end

			v12.tiles = {}
			local count = 0

			for k2, v13 in Cosmetics.RARITIES do
				for k3, v14 in Cosmetics.CRATE_POOL[crate.id][v13.id] do
					count += 1
					local grid = v12.grid
					local v15 = {
						order = count,
						size = UDim2.fromScale(1, 1),
						owned = self.owns(v14.id),
						equipped = equippedId(v14.type) == v14.id, -- inferred equivalent call
						onClick = 0
					}
					local v16 = v14
					v15.onClick = v14.type == "effect" and (function(p)
						Cosmetics2.previewEffect(p.area, v16.id, false)
					end or nil) or nil
					local v17 = tile(grid, v14, v15)

					table.insert(v12.tiles, v17)
				end
			end
		end
		function v12.refreshTiles()
			for k2, tile2 in v12.tiles do
				tile2.set(self.owns(tile2.item.id), equippedId(tile2.item.type) == tile2.item.id) -- inferred equivalent call
			end
		end
		textButton.Activated:Connect(function()
			v12.expanded = not v12.expanded

			if v12.expanded and #v12.tiles == 0 then
				v12.build()
			elseif v12.expanded then
				v12.refreshTiles()
			end

			UI.reveal(v12.grid, v12.expanded, 6)
			text2.Text = v12.expanded and "Hide items" or "See items"
			UI.to(icon, UI.SNAP, {
				Rotation = v12.expanded and 180 or 0
			})
		end)
	end

	local v12 = {}

	for k, v13 in Cosmetics.RARITIES do
		table.insert(v12, string.format("<font color=\"%s\">%s</font> %d", hex(v13.color), v13.name, v13.refund)) -- inferred equivalent call
	end

	UI.text({
		Name = "Note",
		Text = "Every crate costs " .. CRATE_PRICE .. " tokens. Got it already? You get tokens back: " .. table.concat(v12, ", ") .. ". Crates hold cosmetics only and never change how the game plays.",
		RichText = true,
		TextSize = 12,
		TextColor3 = Theme.textMuted,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 30,
		Parent = scrollingFrame
	})

	function shop.refresh()
		text.Text = tostring(tokens()) -- inferred equivalent call
		parent3.Visible = not v10

		if v6 then
			refreshDailyButtons()
		end

		for k, v13 in cards do
			local v14, v15 = owned(k)
			local crateLive = Cosmetics.crateLive(v13.crate)
			v13.sub.Text = not crateLive and "Event ended"
				or v15 <= v14 and string.format("All %d collected!", v15)
				or string.format("%d / %d collected", v14, v15)

			if v13.timer then
				local timer = v13.timer
				timer.Text = limitedText(v13.crate, false) or "" -- inferred equivalent call
			end

			v13.open:setEnabled(v10 and crateLive)

			if v13.expanded then
				v13.refreshTiles()
			end
		end

		if shop.refreshWide then
			shop.refreshWide()
		end
	end
	function shop.onShow()
		shop.refresh()
		shop.buildDaily()
		loadPrices() -- inferred equivalent call

		if not v11 then
			if not Cosmetics.TOKENS_FOR_SALE then
				return
			end

			checkPolicy(true) -- inferred equivalent call
		end
	end
	shop.cards = cards
	shop.balance = text
	shop.checkPolicy = checkPolicy

	local v13 = nil

	local function coverPack(p)
		local v14 = {}

		for k, v15 in packTiles do
			if v15.pack.id ~= 0 and v15.frame.Visible then
				table.insert(v14, v15)
			end
		end

		for k, v15 in v14 do
			if p <= v15.pack.tokens then
				return v15, v14[k + 1]
			end
		end

		return v14[#v14], nil
	end

	function Shop.needTokens(cost, p, resume)
		local v14 = tokens() -- inferred equivalent call
		local v15 = math.max(1, cost - v14)
		Sound.play("locked")
		local v16, v17

		if Cosmetics.TOKENS_FOR_SALE and v10 then
			v16, v17 = coverPack(v15)
		end

		if not v16 then
			self.toast(string.format("You need %d more tokens. Earn them from Daily Tasks!", v15), Theme.token)
			return
		end

		loadPrices() -- inferred equivalent call
		local v18 = {
			cost = cost,
			resume = resume,
			at = os.clock(),
			session = self.session,
			live = self.inLiveGame()
		}
		v13 = v18
		local modal, v19 = self.modals.openModal("NeedTokens", 380)
		self.modals.closeButton(modal, "NeedTokens")
		local list = UI.list(Enum.FillDirection.Vertical, 12, Enum.HorizontalAlignment.Center)
		list.Parent = modal
		local padded = UI.pad(24, 20, 20, 20)
		padded.Parent = modal
		UI.icon("token", 48, Theme.token, { Name = "Icon", LayoutOrder = 1, Parent = modal })
		UI.text({
			Name = "Title",
			Text = string.format("%d more token%s", v15, v15 == 1 and "" or "s"),
			FontFace = Theme.fontHeavy,
			TextSize = 20,
			Size = UDim2.new(1, 0, 0, 24),
			LayoutOrder = 2,
			Parent = modal
		})

		UI.text({
			Name = "Body",
			Text = string.format("%s costs <b>%d</b>. You have <b>%d</b>.", p, cost, v14),
			RichText = true,
			TextSize = 14,
			TextColor3 = Theme.textSoft,
			TextWrapped = true,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = 3,
			Parent = modal
		})

		local function offerRow(p2, layoutOrder, p3)
			local parent4 = card({ -- inferred equivalent call
				Name = p3 and "Offer" or "BetterValue",
				Size = UDim2.new(1, 0, 0, p3 and 72 or 60),
				LayoutOrder = layoutOrder,
				Parent = modal
			})

			UI.icon("token", p3 and 32 or 28, Theme.token, {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 16, 0.5, 0),
				Parent = parent4
			})
			local v20 = p3 and 14 or 10
			UI.text({
				Name = "Amount",
				Text = p2.pack.tokens .. " tokens",
				FontFace = Theme.fontHeavy,
				TextSize = p3 and 20 or 16,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, -184, 0, 22),
				Position = UDim2.fromOffset(60, v20),
				Parent = parent4
			})

			local v21 = v14 + p2.pack.tokens - cost
			local v22 = bonusOf(p2.pack) -- inferred equivalent call
			local v23

			if p3 then
				if v21 > 0 then
					v23 = string.format("Covers it, %d left over", v21)
				else
					v23 = v21 == 0 and "Exactly enough" or "Gets you closer"
				end
			else
				v23 = "Better value"
			end

			UI.text({
				Name = "Sub",
				Text = v23 .. (v22 >= 5 and string.format("  ·  +%d%% tokens", v22) or ""),
				TextSize = 12,
				TextColor3 = not p3 and v22 >= 5 and Theme.teal or Theme.textDim,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, -184, 0, 16),
				Position = UDim2.fromOffset(60, v20 + (p3 and 26 or 22)),
				Parent = parent4
			})
			UI.button({
				parent = parent4,
				name = "Buy",
				size = UDim2.fromOffset(112, p3 and 44 or 38),
				position = UDim2.new(1, -12, 0.5, 0),
				anchor = Vector2.new(1, 0.5),
				style = p3 and "primary" or "secondary",
				text = v3 .. priceOf(p2.pack), -- inferred equivalent call
				textSize = 16,
				font = Theme.fontHeavy,
				onClick = function()
					v18.prompted = true
					buy(p2.pack)
				end
			})
		end
		offerRow(v16, 4, true)

		if v17 then
			offerRow(v17, 5, false)
		end

		UI.button({
			parent = modal,
			name = "Earn",
			size = UDim2.new(1, 0, 0, 40),
			style = "ghost",
			icon = "calendar",
			iconColor = Theme.textSoft,
			iconSize = 18,
			text = "Earn free tokens",
			textSize = 14,
			layoutOrder = 6,
			onClick = function()
				self.modals.close("NeedTokens", false, true)
				pages.show("tasks")
			end
		})

		v19.card.Destroying:Connect(function()
			if v13 == v18 and not v18.prompted then
				v13 = nil
			end
		end)
	end

	local v14 = { Balance = 1, TokenPacks = 2, Codes = 3 }

	local v15 = { Heading = 1, Packs = 2, Vip = 3, SendGift = 4 }

	local function cols(uiGridLayout3, p, p2) -- 3 equivalent calls inferred from this helper
		uiGridLayout3.CellSize = UDim2.new(1 / p, -math.ceil(8 * (p - 1) / p), 0, p2)
	end

	local frame5 = UI.new("Frame", {
		Name = "AsidePane",
		BackgroundTransparency = 1,
		Visible = false,
		Parent = page
	})

	local scroll = UI.scroll({ Name = "Scroll", Size = UDim2.fromScale(1, 1), Parent = frame5 })
	local list = UI.list(Enum.FillDirection.Vertical, 12)
	list.Parent = scroll
	local padded = UI.pad(16, 0, 16, 0)
	padded.Parent = scroll

	local frame6 = UI.new("Frame", {
		Name = "CrateRow",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Visible = false,
		LayoutOrder = 5,
		Parent = scrollingFrame
	}, { UI.list(Enum.FillDirection.Horizontal, 8, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top) })
	local parent4 = card({ -- inferred equivalent call
		Name = "CrateDetail",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Visible = false,
		LayoutOrder = 6,
		Parent = scrollingFrame
	}, { UI.pad(16, 16, 16, 16), UI.list(Enum.FillDirection.Vertical, 8) })
	local frame7 = UI.new("Frame", {
		Name = "Head",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 1,
		Parent = parent4
	}, { UI.list(Enum.FillDirection.Vertical, 4) })
	local text2 = UI.text({
		Name = "Limited",
		Text = "",
		RichText = true,
		FontFace = Theme.fontBold,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 16),
		Visible = false,
		LayoutOrder = 1,
		Parent = frame7
	})

	local text3 = UI.text({
		Name = "Title",
		Text = "",
		FontFace = Theme.fontBold,
		TextSize = 20,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 24),
		LayoutOrder = 2,
		Parent = frame7
	})

	local text4 = UI.text({
		Name = "Odds",
		Text = "",
		RichText = true,
		FontFace = Theme.fontBold,
		TextSize = 14,
		TextColor3 = Theme.textSoft,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 3,
		Parent = frame7
	})

	local mode = "narrow"
	local row = false
	local v16 = {}
	local selected = Cosmetics.CRATES[1].id
	local v17 = nil

	local function returnGrid() -- 2 equivalent calls inferred from this helper
		if v17 then
			local v18 = cards[v17]
			v18.grid.Parent = v18.card
			v18.grid.LayoutOrder = 4
			v18.grid.Visible = v18.expanded
			v17 = nil
		end
	end

	local function styleTile(p)
		local v18 = v16[p]

		if not v18 then
			return
		end

		local v19 = p == selected
		UI.tween(v18.frame, UI.SNAP, {
			BackgroundColor3 = v19 and Theme.selBg or v18.hover and Theme.rowActive or Theme.panelLight
		})
		UI.selected(v18.frame, v19)
		UI.tween(v18.title, UI.SNAP, {
			TextColor3 = v19 and Theme.selText or Theme.textSoft
		})

		restyle(v18.open, v19 and "primary" or "secondary", Theme.token) -- inferred equivalent call
	end

	local function pick(p)
		selected = p

		for k in v16 do
			styleTile(k)
		end

		if not row then
			return
		end

		returnGrid() -- inferred equivalent call
		local v18 = cards[p]

		if #v18.tiles == 0 then
			v18.build()
		else
			v18.refreshTiles()
		end

		v18.grid.Parent = parent4
		v18.grid.LayoutOrder = 3
		v18.grid.Visible = true
		v17 = p
		local v19 = Cosmetics.CRATE_BY_ID[p]
		text3.Text = "What's in the " .. v19.crate
		text4.Text = oddsText(p)
		text2.Visible = v19.ends ~= nil
		text2.TextColor3 = v19.color
		text2.Text = limitedText(v19, false) or "" -- inferred equivalent call
	end

	for k, crate in Cosmetics.CRATES do
		local textButton = UI.new("TextButton", {
			Name = "Crate_" .. crate.id,
			Size = UDim2.new(1 / #Cosmetics.CRATES, -math.ceil((#Cosmetics.CRATES - 1) * 8 / #Cosmetics.CRATES), 0, 184),
			Text = "",
			AutoButtonColor = false,
			BackgroundColor3 = Theme.panelLight,
			LayoutOrder = k,
			Parent = frame6
		}, { UI.corner(14) })
		UI.lift(textButton, 0.1)
		textButton:SetAttribute("Sfx", "tab")
		crateArt(textButton, crate, 60, {
			Name = "Crate",
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 20)
		})

		local text5 = UI.text({
			Name = "Title",
			Text = crate.crate,
			FontFace = Theme.fontBold,
			TextSize = 14,
			TextColor3 = Theme.textSoft,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Size = UDim2.new(1, -16, 0, 18),
			Position = UDim2.fromOffset(8, 88),
			Parent = textButton
		})

		local text6 = UI.text({
			Name = "Owned",
			Text = "",
			TextSize = 12,
			TextColor3 = Theme.textDim,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Size = UDim2.new(1, -16, 0, 16),
			Position = UDim2.fromOffset(8, 106),
			Parent = textButton
		})
		local pillText

		if crate.ends then
			local frame8 = UI.new("Frame", {
				Name = "Limited",
				BackgroundColor3 = crate.color,
				Size = UDim2.fromOffset(0, 20),
				AutomaticSize = Enum.AutomaticSize.X,
				Position = UDim2.fromOffset(8, 8),
				ZIndex = 3,
				Parent = textButton
			}, { UI.corner(UDim.new(1, 0)), UI.pad(0, 8, 0, 8) })
			pillText = UI.text({
				Name = "Left",
				Text = limitedText(crate, true) or "", -- inferred equivalent call
				FontFace = Theme.fontHeavy,
				TextSize = 12,
				TextColor3 = Color3.new(1, 1, 1),
				Size = UDim2.fromScale(0, 1),
				AutomaticSize = Enum.AutomaticSize.X,
				ZIndex = 3,
				Parent = frame8
			})
		end

		local v18 = {
			frame = textButton,
			title = text5,
			sub = text6,
			open = UI.button({
				parent = textButton,
				name = "Open",
				size = UDim2.new(1, -16, 0, 40),
				position = UDim2.new(0.5, 0, 1, -8),
				anchor = Vector2.new(0.5, 1),
				style = "secondary",
				icon = "token",
				iconColor = Theme.token,
				iconSize = 18,
				text = tostring(CRATE_PRICE),
				textSize = 16,
				font = Theme.fontHeavy,
				onClick = function()
					pick(crate.id)
					openCrate(crate.id)
				end
			}),
			crate = crate,
			pillText = pillText,
			hover = false
		}
		v16[crate.id] = v18
		textButton.Activated:Connect(function()
			pick(crate.id)
		end)
		textButton.MouseEnter:Connect(function()
			v18.hover = true
			styleTile(crate.id)
		end)
		textButton.MouseLeave:Connect(function()
			v18.hover = false
			styleTile(crate.id)
		end)
	end

	local function setRow(visible) -- 1 equivalent call inferred from this helper
		if visible == row then
			return
		end

		row = visible

		for k, v18 in cards do
			v18.card.Visible = not visible
		end

		frame6.Visible = visible
		parent4.Visible = visible

		if visible then
			pick(selected)
			return
		end

		returnGrid() -- inferred equivalent call
	end

	local function setAside(visible)
		if visible then
			for i, guiObject in scrollingFrame:GetChildren() do
				local layoutOrder = guiObject:IsA("GuiObject") and v14[guiObject.Name]

				if not layoutOrder then
					continue
				end

				if guiObject:GetAttribute("ShopOrder") == nil then
					guiObject:SetAttribute("ShopOrder", guiObject.LayoutOrder)
				end

				guiObject.LayoutOrder = layoutOrder
				guiObject.Parent = scroll
			end

			for i, guiObject in frame3:GetChildren() do
				local layoutOrder = guiObject:IsA("GuiObject") and v15[guiObject.Name]

				if not layoutOrder then
					continue
				end

				if guiObject:GetAttribute("ShopOrder") == nil then
					guiObject:SetAttribute("ShopOrder", guiObject.LayoutOrder)
				end

				guiObject.LayoutOrder = layoutOrder
			end
		else
			for i, guiObject in scroll:GetChildren() do
				if not guiObject:IsA("GuiObject") then
					continue
				end

				local shopOrder = guiObject:GetAttribute("ShopOrder")

				if shopOrder then
					guiObject.LayoutOrder = shopOrder
				end

				guiObject.Parent = scrollingFrame
			end

			for i, guiObject in frame3:GetChildren() do
				local shopOrder = guiObject:IsA("GuiObject") and guiObject:GetAttribute("ShopOrder")

				if shopOrder then
					guiObject.LayoutOrder = shopOrder
				end
			end
		end

		frame5.Visible = visible
	end

	local function applyVip()
		local vip = frame3:FindFirstChild("Vip")
		local head = vip and vip:FindFirstChild("Head")
		local active = head and head:FindFirstChild("Active")

		if not active then
			return
		end

		local v18 = not (mode == "narrow") and active.Visible

		for i, guiObject in vip:GetChildren() do
			if not (guiObject:IsA("GuiObject") and guiObject ~= head and guiObject.Name ~= "GiftVip") then
				continue
			end

			if v18 and guiObject.Visible then
				guiObject:SetAttribute("VipHid", true)
				guiObject.Visible = false
			elseif not v18 and guiObject:GetAttribute("VipHid") then
				guiObject:SetAttribute("VipHid", nil)
				guiObject.Visible = true
			end
		end
	end
	shop.applyVip = applyVip

	function shop.refreshWide()
		for k, v18 in v16 do
			local v19, v20 = owned(k)
			local crateLive = Cosmetics.crateLive(v18.crate)
			v18.sub.Text = not crateLive and "Event ended"
				or v20 <= v19 and "All collected!"
				or string.format("%d / %d collected", v19, v20)

			if v18.pillText then
				local pillText = v18.pillText
				pillText.Text = limitedText(v18.crate, true) or "" -- inferred equivalent call
			end

			v18.open:setEnabled(v10 and crateLive)
		end

		if v17 then
			cards[v17].refreshTiles()
			local v18 = Cosmetics.CRATE_BY_ID[v17]

			if v18.ends then
				text2.Text = limitedText(v18, false) or "" -- inferred equivalent call
			end
		end

		applyVip()
	end

	function shop.relayout()
		local offset = self.panel.Size.X.Offset > 0 and self.panel.Size.X.Offset or 360
		local scrollBarThickness = scrollingFrame.ScrollBarThickness
		local v18 = offset - 32 - scrollBarThickness

		local v19 = self.isFull and (v18 >= 860 and "two" or v18 >= 600 and "one" or "narrow") or "narrow"

		if v19 ~= mode then
			if v19 == "two" or mode == "two" then
				setAside(v19 == "two")
			end

			mode = v19
		end

		local v20

		if v19 == "two" then
			local v21 = math.min(offset - 32, 1240)
			local v22 = math.floor((offset - v21) / 2)
			v20 = v21 - 360 - 20
			scrollingFrame.Position = UDim2.fromOffset(v22 - 16, 0)
			scrollingFrame.Size = UDim2.new(0, v20 + 32 + scrollBarThickness, 1, 0)
			frame5.Position = UDim2.fromOffset(v22 + v21 - 360, 0)
			frame5.Size = UDim2.new(0, 360 + scroll.ScrollBarThickness, 1, 0)
		else
			scrollingFrame.Position = UDim2.new()
			scrollingFrame.Size = UDim2.fromScale(1, 1)
			v20 = v18
		end

		setRow(v19 ~= "narrow" and v20 >= 560) -- inferred equivalent call

		if v19 == "narrow" then
			uiGridLayout.CellSize = UDim2.new(1 / 3, -6, 0, 156)
			uiGridLayout2.CellSize = UDim2.new(1 / 3, -6, 0, 136)
		else
			cols(uiGridLayout, v20 >= 672 and 6 or 3, 164) -- inferred equivalent call
			cols(uiGridLayout2, v19 == "one" and v18 >= 580 and #packTiles or 3, 140) -- inferred equivalent call
		end

		v20 = row and v20 - 32 or v20
		local v21 = v19 == "narrow" and 3 or math.clamp(math.floor((v20 + 8) / 124), 3, 8)

		for k, v22 in cards do
			local uiGridLayout3 = v22.grid:FindFirstChildOfClass("UIGridLayout")

			if uiGridLayout3 then
				cols(uiGridLayout3, v21, 104) -- inferred equivalent call
			end
		end

		shop.refreshWide()
	end
	function shop.layoutMode()
		return mode, row
	end

	local onLayout = pages.onLayout
	function pages.onLayout()
		onLayout()
		shop.relayout()
	end

	function shop.debugState()
		local needTokens = self.modalLayer:FindFirstChild("NeedTokens")
		local needTokens2

		if needTokens then
			needTokens2 = {}

			for i, label in needTokens:GetDescendants() do
				if label:IsA("TextLabel") and label.Text ~= "" and label.Visible then
					table.insert(needTokens2, label.Name .. ": " .. label.Text)
				end
			end
		end

		return {
			full = self.isFull == true,
			mode = mode,
			row = row,
			selected = selected,
			pending = v13 ~= nil,
			needTokens = needTokens2,
			limited = v16.halloween and v16.halloween.pillText and v16.halloween.pillText.Text or nil
		}
	end

	local v18 = false

	for k, v19 in Cosmetics.CRATES do
		v18 = v18 or v19.ends ~= nil
	end

	if v18 then
		task.spawn(function()
			while page.Parent do
				task.wait(30)

				if page.Visible then
					pcall(shop.refresh)
				end
			end
		end)
	end

	function shop.scrollToCrates()
		if not scrollingFrame:IsA("ScrollingFrame") then
			return
		end

		local v19 = v7.AbsolutePosition.Y - scrollingFrame.AbsolutePosition.Y + scrollingFrame.CanvasPosition.Y - 8
		local v20 = math.max(0, scrollingFrame.AbsoluteCanvasSize.Y - scrollingFrame.AbsoluteWindowSize.Y)
		UI.tween(
			scrollingFrame,
			0.45,
			{
				CanvasPosition = Vector2.new(0, (math.clamp(v19, 0, v20)))
			},
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		)
		local count = 0

		for k, v21 in Cosmetics.CRATES do
			local v22 = row and v16[v21.id] or cards[v21.id]

			if not (v22 and v22.open.face) then
				continue
			end

			count += 1
			task.delay(count * 0.09 + 0.45, UI.pop, v22.open.face, 0.75, 0.3)
		end
	end

	function self.handlers.tokensBought(p)
		if type(p.tasks) == "table" and self.pages.tasks then
			self.pages.tasks.apply(p.tasks, true)
		end

		shop.refresh()
		Sound.play("currency")
		task.delay(0.25, Sound.play, "unlock")
		local tokens2 = tonumber(p.tokens) or 0
		local toast = self.toast("+" .. tokens2 .. " tokens. Thanks for your support!", Theme.token, 4)

		if toast then
			local list = UI.list(
				Enum.FillDirection.Horizontal,
				8,
				Enum.HorizontalAlignment.Left,
				Enum.VerticalAlignment.Center
			)
			list.Parent = toast
			local textLabel = toast:FindFirstChildOfClass("TextLabel")

			if textLabel then
				textLabel.LayoutOrder = 2
			end

			UI.icon("token", 22, Theme.token, { LayoutOrder = 1, Parent = toast })
		end

		if page.Visible then
			UI.pop(text, 0.7, 0.3)
			local v19 = text.AbsolutePosition + Vector2.new(20, text.AbsoluteSize.Y / 2) - self.gui.AbsolutePosition
			local frame8 = UI.new("Frame", {
				Name = "TokenFx",
				Size = UDim2.new(),
				BackgroundTransparency = 1,
				ZIndex = 50,
				Parent = self.gui
			})
			UI.confetti(frame8, v19, {
				count = 30,
				spread = 140,
				zindex = 50,
				colors = { Theme.token, Theme.gold, Color3.fromRGB(255, 230, 150) }
			})
			task.delay(2.5, frame8.Destroy, frame8)
		end

		local v19 = v13

		if v19 and os.clock() - v19.at < 300 and tokens() >= v19.cost then -- inferred equivalent call
			v13 = nil
			self.modals.close("NeedTokens", true)

			if not self.inLiveGame() or v19.live and self.session == v19.session then
				task.delay(0.8, function()
					local session = self.session

					if self.inLiveGame() and (not v19.live or session ~= v19.session) then
						return
					end

					v19.resume()
				end)
			end
		end
	end

	function Shop.fakeTokensBought(tokens2)
		self.handlers.tokensBought({ tokens = tokens2 })
	end

	local v19 = false
	local v20 = nil
	local lastTime2 = 0
	local v21 = false
	local v22 = nil

	local function eligible(): boolean -- 1 equivalent call inferred from this helper
		local cos = self.cos
		return not (v19 or not cos or cos.prompted or (tonumber(cos.crates) or 0) > 0) and CRATE_PRICE <= tokens() -- inferred equivalent call
	end

	local function quiet(): boolean
		if flag or self.searching or self.joining or self.modals.top() ~= nil then
			return false
		end

		if v and v.frame.Visible then
			return false
		end

		local session = self.session

		if
			session
			and session.kind ~= "idle"
			and (session.kind ~= "online" and session.kind ~= "bot" or not session.over)
		then
			return false
		end

		return true
	end

	local function log(action) -- 3 equivalent calls inferred from this helper
		task.spawn(self.request, { type = "cratePrompt", action = action })
	end

	local function show()
		v19 = true

		if self.cos then
			self.cos.prompted = true
		end

		log("shown") -- inferred equivalent call
		local modal, v23 = self.modals.openModal("CratePrompt", 400)
		self.modals.closeButton(modal, "CratePrompt")
		local list = UI.list(Enum.FillDirection.Vertical, 10, Enum.HorizontalAlignment.Center)
		list.Parent = modal
		local padded = UI.pad(20, 20, 18, 20)
		padded.Parent = modal

		local frame8 = UI.new("Frame", {
			Name = "Crates",
			Size = UDim2.new(1, 0, 0, 70),
			BackgroundTransparency = 1,
			LayoutOrder = 1,
			Parent = modal
		})

		local v24 = math.min(#Cosmetics.TYPES, 3)
		local flag4 = false

		for i = 1, v24 do
			local v25 = Cosmetics.TYPES[i]
			local v26 = i == (v24 + 1) // 2
			local v27 = v26 and 64 or 48
			local v28 = (i - (v24 + 1) / 2) * 76
			local icon = UI.icon("crate", v27, v25.color, {
				Name = "Crate_" .. v25.id,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, v28, 0.5, v26 and 0 or 6),
				Rotation = v26 and 0 or v28 < 0 and -8 or 8,
				Parent = frame8
			})

			UI.icon(v25.icon, math.floor(v27 * 0.4), Color3.new(1, 1, 1), {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.82, 0.82),
				Parent = icon
			})

			task.delay(i * 0.1, function()
				if not icon.Parent then
					return
				end

				UI.pop(icon, 0.5, 0.35)
				local position = icon.Position
				local position2 = position + UDim2.fromOffset(0, -5)

				while icon.Parent do
					UI.tween(icon, 0.9, { Position = position2 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
					task.wait(0.9)

					if not icon.Parent then
						break
					end

					UI.tween(icon, 0.9, { Position = position }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
					task.wait(0.9)
				end
			end)
		end

		UI.text({
			Name = "Title",
			Text = "You can open a crate!",
			FontFace = Theme.fontHeavy,
			TextSize = 24,
			Size = UDim2.new(1, 0, 0, 28),
			LayoutOrder = 2,
			Parent = modal
		})

		local frame9 = UI.new("Frame", {
			Name = "Have",
			Size = UDim2.new(1, 0, 0, 26),
			BackgroundTransparency = 1,
			LayoutOrder = 3,
			Parent = modal
		}, { UI.list(
				Enum.FillDirection.Horizontal,
				6,
				Enum.HorizontalAlignment.Center,
				Enum.VerticalAlignment.Center
			) })
		UI.text({
			Text = "You have",
			FontFace = Theme.fontBold,
			TextSize = 16,
			TextColor3 = Theme.textSoft,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.new(0, 0, 1, 0),
			LayoutOrder = 1,
			Parent = frame9
		})

		tokenChip(frame9, tokens(), 20, 2) -- inferred equivalent call
		UI.text({
			Text = "tokens",
			FontFace = Theme.fontBold,
			TextSize = 16,
			TextColor3 = Theme.textSoft,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.new(0, 0, 1, 0),
			LayoutOrder = 3,
			Parent = frame9
		})

		UI.text({
			Name = "Body",
			Text = string.format(
				"A crate costs <b>%d tokens</b> and has a random board, piece set, accessory or effect inside. Your opponents see your accessory and effects!",
				CRATE_PRICE
			),
			RichText = true,
			TextSize = 15,
			TextColor3 = Theme.textSoft,
			TextWrapped = true,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = 4,
			Parent = modal
		})

		local frame10 = UI.new("Frame", {
			Name = "Buttons",
			Size = UDim2.new(1, 0, 0, 50),
			BackgroundTransparency = 1,
			LayoutOrder = 5,
			Parent = modal
		}, { UI.list(Enum.FillDirection.Horizontal, 8, Enum.HorizontalAlignment.Center) })
		UI.button({
			parent = frame10,
			name = "Later",
			size = UDim2.new(0.34, -4, 1, 0),
			style = "ghost",
			text = "Later",
			textSize = 16,
			layoutOrder = 1,
			onClick = function()
				self.modals.close("CratePrompt", false, true)
			end
		})

		UI.button({
			parent = frame10,
			name = "GoShop",
			size = UDim2.new(0.66, -4, 1, 0),
			style = "primary",
			icon = "crate",
			iconColor = Theme.token,
			iconSize = 22,
			text = "Open a crate",
			textSize = 18,
			font = Theme.fontHeavy,
			layoutOrder = 2,
			onClick = function()
				if flag4 then
					return
				end

				flag4 = true
				log("shop") -- inferred equivalent call
				self.modals.close("CratePrompt")
				pages.show("shop")
				task.delay(0.2, function()
					if v and v.frame.Visible and v.scrollToCrates then
						v.scrollToCrates()
					end
				end)
			end
		})

		v23.card.Destroying:Connect(function()
			if not flag4 then
				flag4 = true
				log("later") -- inferred equivalent call
			end
		end)
		Sound.play("unlock")
	end
	Shop.showCratePrompt = show

	task.spawn(function()
		while self.gui and self.gui.Parent do
			task.wait(1)

			if eligible() then -- inferred equivalent call
				if v20 == false and os.clock() - lastTime2 > 120 then
					v20 = nil
				end

				if v20 == nil then
					if not v21 then
						v21 = true
						task.spawn(function()
							local request = self.request({ type = "shopInfo" })
							v21 = false
							lastTime2 = os.clock()

							if type(request) == "table" then
								v20 = request.canOpen ~= false
							end
						end)
					end
				elseif v20 and quiet() then
					v22 = v22 or os.clock()

					if os.clock() - v22 >= 2.5 then
						show()
					end
				else
					v22 = nil
				end
			else
				v22 = nil
			end
		end
	end)

	local page2, parent5 = pages.newPage("inventory", "Inventory", "grid", Theme.tasks, true)
	local inventory = { frame = page2, kind = "board" }
	pages.inventory = inventory
	v2 = inventory

	local v23 = {}

	for k, v24 in Cosmetics.TYPES do
		table.insert(v23, { id = v24.id, icon = v24.icon, iconColor = v24.color })
	end

	local segmented = UI.segmented(v23, inventory.kind, function(kind)
		inventory.kind = kind
		inventory.build()
	end, 44)
	segmented.frame.LayoutOrder = 1
	segmented.frame.Parent = parent5

	for i, button in segmented.frame:GetChildren() do
		local icon = button:IsA("TextButton") and button:FindFirstChild("Icon")

		if icon then
			icon.Size = UDim2.fromOffset(24, 24)
		end
	end

	local text5 = UI.text({
		Name = "Heading",
		Text = "",
		RichText = true,
		FontFace = Theme.fontBold,
		TextSize = 17,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 22),
		LayoutOrder = 2,
		Parent = parent5
	})

	local frame8 = UI.new("Frame", {
		Name = "Items",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 3,
		Parent = parent5
	})

	local uiGridLayout3 = Instance.new("UIGridLayout")
	uiGridLayout3.CellSize = UDim2.new(1 / 3, -6, 0, 112)
	uiGridLayout3.CellPadding = UDim2.fromOffset(8, 8)
	uiGridLayout3.SortOrder = Enum.SortOrder.LayoutOrder
	uiGridLayout3.Parent = frame8
	local text6 = UI.text({
		Name = "Hint",
		Text = "",
		TextSize = 12,
		TextColor3 = Theme.textMuted,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 4,
		Parent = parent5
	})

	_ = UI.button({
		parent = parent5,
		name = "ToShop",
		size = UDim2.new(1, 0, 0, 44),
		style = "secondary",
		icon = "crate",
		iconColor = Theme.token,
		iconSize = 22,
		text = "Get more in the Shop",
		textSize = 16,
		layoutOrder = 5,
		onClick = function()
			pages.show("shop")
		end
	})

	local v24 = {
		board = "Only you see your board.",
		background = "Only you see your background.",
		pieces = "Used for both sides' pieces. Only you see your piece set.",
		accessory = "Worn by your king. Your opponent sees it too.",
		effect = "Plays when you capture, and big when you checkmate. Tap one to see it."
	}

	local v25 = {}
	function inventory.build()
		for k, v26 in v25 do
			v26.button:Destroy()
		end

		v25 = {}
		local kind = inventory.kind
		local v26 = Cosmetics.TYPE[kind]
		segmented.set(kind)
		local clone = table.clone(Cosmetics.BY_TYPE[kind])

		local v27 = {}

		for k, v28 in clone do
			v27[v28] = k
		end

		table.sort(clone, function(a, b): boolean
			local v28 = a.free and 0 or 1
			local v29 = b.free and 0 or 1

			if v28 ~= v29 then
				return v28 < v29
			end

			local order = rarityOf(a).order -- inferred equivalent call
			local order2 = rarityOf(b).order -- inferred equivalent call

			if a.free or order == order2 then
				return v27[a] < v27[b]
			end

			return order < order2
		end)

		for k, v28 in clone do
			local v29 = {
				order = k,
				size = UDim2.fromScale(1, 1),
				owned = self.owns(v28.id),
				equipped = equippedId(kind) == v28.id, -- inferred equivalent call
				onClick = function(p)
					if self.owns(v28.id) then
						if v28.type == "effect" then
							Cosmetics2.previewEffect(p.area, v28.id, false)
						end

						if equippedId(kind) ~= v28.id then -- inferred equivalent call
							equip(v28)
							Sound.play("confirm")
						end
					else
						Sound.play("locked")
						UI.shake(p.area, 4, UDim2.new())

						if v28.vip then
							self.toast(v28.name .. ": comes with VIP", rarityOf(v28).color) -- inferred equivalent call

							if self.promptVip then
								task.delay(0.4, self.promptVip)
							end
						else
							self.toast(
								string.format(
									"%s %s: from the %s",
									rarityOf(v28).name, -- inferred equivalent call
									v28.name,
									Cosmetics.crateOf(v28).crate
								),
								rarityOf(v28).color -- inferred equivalent call
							)
						end

						if v28.type == "effect" then
							Cosmetics2.previewEffect(p.area, v28.id, false)
						end
					end
				end
			}
			local v30 = tile(frame8, v28, v29)

			table.insert(v25, v30)
		end

		inventory.refresh()
	end

	function inventory.refresh()
		local kind = inventory.kind
		local v26 = Cosmetics.TYPE[kind]
		local v27, v28 = ownedOfType(kind)
		text5.Text = string.format(
			"%s  <font color=\"#989795\" size=\"14\">%d / %d collected</font>",
			v26.name,
			v27,
			v28
		)
		text6.Text = v24[kind] or ""

		for k, v29 in v25 do
			v29.set(self.owns(v29.item.id), equippedId(kind) == v29.item.id) -- inferred equivalent call
		end
	end

	function inventory.onShow()
		if #v25 == 0 then
			inventory.build()
		else
			inventory.refresh()
		end
	end
	function inventory.show(kind)
		inventory.kind = kind
		pages.show("inventory")
		inventory.build()
	end

	function Shop.state()
		local v26 = {
			tokens = tokens(), -- inferred equivalent call
			eq = self.cos and self.cos.eq,
			owned = {},
			crates = {},
			opening = flag
		}

		for k, v27 in Cosmetics.TYPES do
			local v28, v29 = ownedOfType(v27.id)
			v26.owned[v27.id] = v28 .. "/" .. v29
		end

		for k, v27 in Cosmetics.CRATES do
			local v28, v29 = owned(v27.id)
			v26.crates[v27.id] = v28 .. "/" .. v29
		end

		if v and v.debugState then
			v26.page = v.debugState()
		end

		local crate = self.modalLayer:FindFirstChild("Crate")

		if crate then
			local result2 = crate:FindFirstChild("Result", true)
			v26.crate = result2
				and result2.Visible
				and {
					rarity = result2:FindFirstChild("Rarity").Text,
					name = result2:FindFirstChild("ItemName").Text,
					status = result2:FindFirstChild("Status").Text
				}
				or "spinning"
		end

		return v26
	end
end

return Shop