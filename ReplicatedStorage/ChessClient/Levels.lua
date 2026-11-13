local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Chess = ReplicatedStorage:WaitForChild("Chess")
local Levels = require(Chess.Levels)
local Config = require(Chess.Config)
local parent = script.Parent
local Theme = require(parent.Theme)
local UI = require(parent.UI)
local Sound = require(parent.Sound)

local Levels2 = {}
Levels2.Shared = Levels
Levels2.XP_COLOR = Color3.fromRGB(112, 148, 255)

local track = Theme.track or Color3.fromRGB(56, 59, 66)

local function hex(token) -- 1 equivalent call inferred from this helper
	return "#" .. token:ToHex()
end

function Levels2.bar(p, p2)
	local frame = UI.new("Frame", {
		Name = "Bar",
		Size = UDim2.new(1, 0, 0, p),
		BackgroundColor3 = track
	}, {
		UI.corner(UDim.new(1, 0))
	})
	local frame2 = UI.new("Frame", {
		Name = "Fill",
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = p2 or Levels2.XP_COLOR,
		Parent = frame
	}, { UI.corner(UDim.new(1, 0)) })
	local v = { frame = frame, fill = frame2, value = 0 }
	function v.set(p3, p4)
		local v2 = math.clamp(tonumber(p3) or 0, 0, 1)
		v.value = v2

		if p4 and p4 > 0 then
			return UI.tween(
				frame2,
				p4,
				{ Size = UDim2.fromScale(v2, 1) },
				Enum.EasingStyle.Quart,
				Enum.EasingDirection.Out
			)
		end

		frame2.Size = UDim2.fromScale(v2, 1)
		return nil
	end

	return v
end

function Levels2.tokenChip(parent2, p, p2, value)
	local frame = UI.new("Frame", {
		Name = "Tokens",
		Size = UDim2.new(0, 0, 0, p2 + 4),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		LayoutOrder = value or 0,
		Parent = parent2
	}, { UI.list(Enum.FillDirection.Horizontal, 3, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center) })
	UI.icon("token", p2, Theme.token, { Name = "Icon", LayoutOrder = 1, Parent = frame })
	UI.text({
		Name = "Amount",
		Text = "+" .. tostring(p),
		FontFace = Theme.fontHeavy,
		TextSize = math.floor(p2 * 0.9),
		TextColor3 = Theme.token,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 1, 0),
		LayoutOrder = 2,
		Parent = frame
	})

	return frame
end

local function burst(frame, vector2, colors, value)
	local frame2 = UI.new("Frame", {
		Name = "Fx",
		Size = UDim2.new(),
		BackgroundTransparency = 1,
		ZIndex = 20,
		Parent = frame
	})

	UI.confetti(frame2, vector2, {
		count = value or 22,
		spread = 110,
		zindex = 20,
		colors = colors
	})
	task.delay(2.5, function()
		frame2:Destroy()
	end)
end

function Levels2:install()
	local pages = self.pages

	function self.level()
		local xp = self.profile and tonumber(self.profile.xp)
		return xp and Levels.of(xp) or nil
	end

	local home = pages.home
	local fn

	if home and home.progress then
		local textButton = UI.new("TextButton", {
			Name = "Level",
			Size = UDim2.new(1, 0, 0, 72),
			BackgroundColor3 = Theme.panelLight,
			Visible = false,
			LayoutOrder = 1,
			Parent = home.progress
		}, { UI.corner(14) })
		UI.lift(textButton, 0.12)
		textButton:SetAttribute("Sfx", "press")
		local text = UI.text({
			Name = "Title",
			Text = "Level 1",
			FontFace = Theme.fontBold,
			TextSize = 16,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, -150, 0, 20),
			Position = UDim2.fromOffset(16, 12),
			Parent = textButton
		})

		local text2 = UI.text({
			Name = "Count",
			Text = "",
			FontFace = Theme.fontBold,
			TextSize = 13,
			TextColor3 = Theme.textDim,
			TextXAlignment = Enum.TextXAlignment.Right,
			AnchorPoint = Vector2.new(1, 0),
			Size = UDim2.fromOffset(130, 20),
			Position = UDim2.new(1, -16, 0, 12),
			Parent = textButton
		})

		local bar = Levels2.bar(8)
		bar.frame.Position = UDim2.fromOffset(16, 36)
		bar.frame.Size = UDim2.new(1, -32, 0, 8)
		bar.frame.Parent = textButton
		local text3 = UI.text({
			Name = "Hint",
			Text = "",
			RichText = true,
			TextSize = 14,
			TextColor3 = Theme.textDim,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Size = UDim2.new(1, -32, 0, 18),
			Position = UDim2.fromOffset(16, 48),
			Parent = textButton
		})

		UI.hover(textButton, nil, { BackgroundColor3 = Theme.rowActive }, {
			BackgroundColor3 = Theme.panelLight
		})
		textButton.Activated:Connect(function()
			pages.show("stats")
		end)

		local v = nil
		local v2 = nil
		fn = function()
			local xp = self.profile and tonumber(self.profile.xp)
			textButton.Visible = xp ~= nil

			if not xp then
				return
			end

			local v3, v4, v5 = Levels.of(xp)
			local v6

			if v == nil then
				v6 = false
			else
				v6 = v < xp
			end

			text.Text = "Level " .. v3

			if v6 and v3 ~= v2 then
				UI.textIn(text, 0.3)
				bar.set(0)
			end

			local v7 = v and select(2, Levels.of(v))

			if v6 and v3 == v2 and v7 and v7 < v4 then
				UI.countTo(text2, v7, v4, 0.6, "%d / " .. v5 .. " XP")
			else
				text2.Text = string.format("%d / %d XP", v4, v5)
			end

			bar.set(v4 / v5, v6 and 0.6 or nil)
			local vipTokens = Config.vipTokens(Levels.reward(v3 + 1), self.isVip())
			text3.Text = string.format(
				"Level %d: <font color=\"%s\">+%d %s</font>",
				v3 + 1,
				hex(Theme.token), -- inferred equivalent call
				vipTokens,
				vipTokens == 1 and "token" or "tokens"
			)
			v = xp
			v2 = v3
		end
		local afterRefresh = home.afterRefresh
		function home.afterRefresh()
			if afterRefresh then
				afterRefresh()
			end

			fn()
		end
		Levels2.homeCard = {
			frame = textButton,
			title = text,
			count = text2,
			hint = text3,
			bar = bar
		}
		fn()
	else
		fn = function() end
	end

	local function xpRow(frame, xpResult)
		if xpResult.short then
			UI.text({
				Name = "XP",
				Text = "No XP: games need 5 moves each to count",
				TextSize = 13,
				TextColor3 = Theme.textMuted,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, 0, 0, 18),
				LayoutOrder = 1,
				Parent = frame
			})

			return
		end

		local xp = tonumber(xpResult.xp) or 0
		local g = tonumber(xpResult.g) or 0
		local v, v2, v3 = Levels.of(xp - g)
		local v4, v5, v6 = Levels.of(xp)

		local frame2 = UI.new("Frame", {
			Name = "XP",
			Size = UDim2.new(1, 0, 0, 32),
			BackgroundTransparency = 1,
			LayoutOrder = 1,
			Parent = frame
		})

		local frame3 = UI.new(
			"Frame",
			{
				Name = "Left",
				Size = UDim2.new(1, -96, 0, 20),
				BackgroundTransparency = 1,
				Parent = frame2
			},
			{ UI.list(Enum.FillDirection.Horizontal, 6, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center) }
		)
		local text = UI.text({
			Name = "Status",
			Text = "Level " .. v,
			FontFace = Theme.fontBold,
			TextSize = 14,
			TextColor3 = Theme.textSoft,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.new(0, 0, 1, 0),
			LayoutOrder = 1,
			Parent = frame3
		})

		if xpResult.vip then
			UI.text({
				Name = "Vip",
				Text = string.format("VIP +%d%%", (math.floor((Config.VIP_XP_MULT - 1) * 100 + 0.5))),
				FontFace = Theme.fontHeavy,
				TextSize = 12,
				TextColor3 = Theme.gold,
				AutomaticSize = Enum.AutomaticSize.X,
				Size = UDim2.new(0, 0, 1, 0),
				LayoutOrder = 3,
				Parent = frame3
			})
		end

		local text2 = UI.text({
			Name = "Note",
			Text = "+0 XP",
			FontFace = Theme.fontBold,
			TextSize = 13,
			TextColor3 = Levels2.XP_COLOR,
			TextXAlignment = Enum.TextXAlignment.Right,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.fromScale(1, 0),
			Size = UDim2.fromOffset(130, 20),
			Parent = frame2
		})

		local bar = Levels2.bar(8)
		bar.frame.Position = UDim2.fromOffset(0, 24)
		bar.frame.Parent = frame2
		bar.set(v2 / v3)
		task.delay(0.6, function()
			if not frame2.Parent then
				return
			end

			UI.countTo(text2, 0, g, 0.6, "+%d XP")

			if v4 == v then
				bar.set(v5 / v6, 0.6)
				return
			end

			bar.set(1, 0.45)
			task.delay(0.5, function()
				if not frame2.Parent then
					return
				end

				text.Text = "Level " .. v4 .. "!"
				text.TextColor3 = Theme.gold
				UI.textIn(text, 0.2)
				bar.set(0)
				bar.set(v5 / v6, 0.5)
				Sound.play("unlock")
				burst(frame2, Vector2.new(30, 10), { Levels2.XP_COLOR, Theme.gold, Color3.new(1, 1, 1) })
				local tk = tonumber(xpResult.tk) or 0

				if tk > 0 then
					local tokenChip = Levels2.tokenChip(frame3, tk, 16, 2)
					UI.pop(tokenChip, 0.5, 0.3)
					task.delay(0.25, Sound.play, "currency")
				end
			end)
		end)
	end

	function self.levelsGameOver(parent2, p, layoutOrder)
		local session = p.session

		if not session or session.kind ~= "online" or p.result == "*" or not session.xpResult then
			return
		end

		xpRow(UI.new("Frame", {
			Name = "Progress",
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = layoutOrder,
			Parent = parent2
		}, { UI.list(Enum.FillDirection.Vertical, 10), UI.pad(0, 16, 8, 16) }), session.xpResult)
	end

	local gameEnd = self.handlers.gameEnd
	function self.handlers.gameEnd(p)
		local session = self.session

		if session and session.kind == "online" and session.id == p.id then
			local xpResult

			if type(p.xp) == "table" then
				xpResult = p.xp[session.myColor == 1 and "w" or "b"] or nil
			end

			session.xpResult = xpResult

			local lv = session.xpResult and tonumber(session.xpResult.lv)

			if lv then
				task.delay(2.4, function()
					local white = session.myColor == 1 and session.white or session.black

					if self.session == session and white then
						white.lvl = lv
						self.refreshBars()
					end
				end)
			end
		end

		gameEnd(p)
	end

	function Levels2.levelUpToast(p, p2)
		Sound.play("unlock")
		local toast = self.toast("Level " .. p .. "!", Levels2.XP_COLOR, 3.5)

		if not toast or p2 <= 0 then
			return
		end

		local list = UI.list(
			Enum.FillDirection.Horizontal,
			8,
			Enum.HorizontalAlignment.Left,
			Enum.VerticalAlignment.Center
		)
		list.Parent = toast
		local textLabel = toast:FindFirstChildOfClass("TextLabel")

		if textLabel then
			textLabel.LayoutOrder = 1
		end

		Levels2.tokenChip(toast, p2, 20, 2)
		task.delay(0.25, Sound.play, "currency")
	end

	function self.handlers.xp(data)
		if self.profile and tonumber(data.xp) then
			self.profile.xp = data.xp
		end

		if type(data.tasks) == "table" and pages.tasks and pages.tasks.apply then
			pages.tasks.apply(data.tasks, true)
		end

		fn()

		if pages.current == "stats" and pages.stats and pages.stats.refresh then
			pages.stats.refresh()
		end

		local lv = tonumber(data.lv) or 0

		if (tonumber(data.from) or 0) < lv then
			Levels2.levelUpToast(lv, tonumber(data.tk) or 0)
		end
	end

	function Levels2.state()
		local v = {
			level = self.level(),
			xp = self.profile and self.profile.xp
		}
		local homeCard = Levels2.homeCard

		if homeCard then
			v.home = {
				visible = homeCard.frame.Visible,
				title = homeCard.title.Text,
				count = homeCard.count.Text,
				hint = homeCard.hint.ContentText,
				bar = math.floor(homeCard.bar.value * 100 + 0.5)
			}
		end

		local gameOver = self.modalLayer and self.modalLayer:FindFirstChild("GameOver", true)
		local progress = gameOver and gameOver:FindFirstChild("Progress", true)

		if progress then
			v.gameOver = {}

			for _, guiObject in progress:GetChildren() do
				if not guiObject:IsA("GuiObject") then
					continue
				end

				local texts = {}

				if guiObject:IsA("TextLabel") then
					table.insert(texts, guiObject.Text)
				end

				for _, label in guiObject:GetDescendants() do
					if label:IsA("TextLabel") and label.Text ~= "" then
						table.insert(texts, label.Text)
					end
				end

				local bar = guiObject:FindFirstChild("Bar")
				local fill = bar and bar:FindFirstChild("Fill")
				v.gameOver[guiObject.Name] = table.concat(texts, " | ") .. (fill and string.format(
					" [%d%%]",
					(math.floor(fill.Size.X.Scale * 100 + 0.5))
				) or "")
			end
		end

		v.bars = {}

		for k, v2 in { top = self.topBar, bottom = self.bottomBar } do
			local bars = v.bars
			local v3 = {
				name = v2.nameLabel and v2.nameLabel.Text,
				level = 0,
				vip = 0
			}
			local level

			if v2.levelLabel and v2.levelLabel.Visible then
				level = v2.levelLabel.Text or nil
			end

			v3.level = level
			local vip

			if v2.vipTag ~= nil then
				vip = v2.vipTag.Visible or nil
			end

			v3.vip = vip
			bars[k] = v3
		end

		return v
	end
end

return Levels2