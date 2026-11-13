local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Chess = ReplicatedStorage:WaitForChild("Chess")
local Config = require(Chess.Config)
local Cosmetics = require(Chess.Cosmetics)
local Levels = require(Chess.Levels)
local parent = script.Parent
local Theme = require(parent.Theme)
local UI = require(parent.UI)
local Levels2 = require(parent.Levels)
local Cosmetics2 = require(parent.Cosmetics)

local Profile = {}

local blueSoft = Theme.blueSoft
local color = Color3.fromRGB(255, 204, 64)
local color2 = Color3.fromRGB(255, 232, 140)
local color3 = Color3.fromRGB(222, 150, 28)
local color4 = Color3.fromRGB(255, 250, 222)
local color5 = Color3.fromRGB(30, 29, 27)

local v = {
	playing = { "In a game", Theme.loss },
	searching = { "Looking for a game", Theme.gold },
	bot = { "Playing a bot", Theme.blueSoft },
	puzzle = { "Solving puzzles", Theme.puzzle },
	idle = { "Online", Theme.green }
}

local v2 = {
	busy = "Lots of profiles opened at once. Try again in a few seconds.",
	none = "This player hasn't played RoChess yet.",
	error = "Couldn't load this profile right now."
}

local v3 = {
	invalid = "Usernames are 3 to 20 letters, numbers or _.",
	busy = "Too many searches. Try again in a few seconds.",
	error = "Search isn't working right now. Try again soon."
}

local function hex(p) -- 5 equivalent calls inferred from this helper
	return "#" .. p:ToHex()
end

local v4 = hex(Theme.textDim) -- inferred equivalent call

local function commas(p)
	local v5 = math.floor(tonumber(p) or 0)
	local v6 = tostring((math.abs(v5)))
	local v7 = string.reverse((string.gsub(string.reverse(v6), "(%d%d%d)", "%1,")))
	local v8 = string.gsub(v7, "^,", "")
	return (v5 < 0 and "-" or "") .. v8
end

Profile.commas = commas

local function timePlayed(playtime) -- 1 equivalent call inferred from this helper
	local v5 = math.floor((tonumber(playtime) or 0) / 60)

	if v5 < 60 then
		return tostring(v5) .. "m"
	end

	local v6 = v5 // 60

	if v6 >= 100 then
		return commas(v6) .. "h"
	end

	return string.format("%dh %dm", v6, v5 % 60)
end

local function monthYear(p) -- 2 equivalent calls inferred from this helper
	local v5 = tonumber(p)

	if not v5 or v5 <= 0 then
		return nil
	end

	local success, result = pcall(function()
		return DateTime.fromUnixTimestamp((math.floor(v5))):FormatLocalTime("MMM YYYY", "en-us")
	end)

	return success and result or nil
end

local function cleaned(value) -- 3 equivalent calls inferred from this helper
	local v5 = string.gsub(string.gsub(value or "", "^%s+", ""), "%s+$", "")
	return (string.gsub(v5, "^@", ""))
end

local function bands(items)
	local colorSequenceKeypoints = {}
	local v5 = -1
	local function add(value, p) -- 2 equivalent calls inferred from this helper
		local v6 = math.clamp(value, 0, 1)

		if v6 <= v5 then
			v6 = v5 + 0.0001
		end

		if v6 > 1 then
			return
		end

		v5 = v6
		table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(v6, p))
	end

	for _, item in items do
		add(item[1], item[3]) -- inferred equivalent call
		add(item[2], item[3]) -- inferred equivalent call
	end

	if colorSequenceKeypoints[#colorSequenceKeypoints].Time < 1 then
		table.insert(
			colorSequenceKeypoints,
			ColorSequenceKeypoint.new(1, colorSequenceKeypoints[#colorSequenceKeypoints].Value)
		)
	end

	return ColorSequence.new(colorSequenceKeypoints)
end

local function card(parent2, layoutOrder, name)
	return UI.new("Frame", {
		Name = name,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.panelLight,
		LayoutOrder = layoutOrder,
		Parent = parent2
	}, { UI.corner(8), UI.pad(12, 12, 12, 12), UI.list(Enum.FillDirection.Vertical, 8) })
end

local function titleRow(parent2, layoutOrder, p, p2, text)
	local frame = UI.new("Frame", {
		Name = "Title",
		Size = UDim2.new(1, 0, 0, 22),
		BackgroundTransparency = 1,
		LayoutOrder = layoutOrder,
		Parent = parent2
	})

	UI.icon(p, 20, p2, {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Parent = frame
	})

	UI.text({
		Name = "Label",
		Text = text,
		FontFace = Theme.fontBold,
		TextSize = 17,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(0.6, -26, 1, 0),
		Position = UDim2.fromOffset(26, 0),
		Parent = frame
	})

	return frame, (UI.text({
		Name = "Note",
		Text = "",
		RichText = true,
		FontFace = Theme.fontBold,
		TextSize = 14,
		TextColor3 = Theme.textSoft,
		TextXAlignment = Enum.TextXAlignment.Right,
		AnchorPoint = Vector2.new(1, 0),
		Size = UDim2.new(0.45, 0, 1, 0),
		Position = UDim2.fromScale(1, 0),
		Parent = frame
	}))
end

local function statCell(parent2, layoutOrder, size, p, p2, p3)
	local frame = UI.new("Frame", {
		Name = p3,
		Size = size,
		BackgroundColor3 = Theme.panel,
		LayoutOrder = layoutOrder,
		Parent = parent2
	}, { UI.corner(6) })
	UI.icon(p, 14, p2, { Position = UDim2.fromOffset(8, 7), Parent = frame })
	UI.text({
		Name = "Label",
		Text = p3,
		TextSize = 12,
		TextColor3 = Theme.textDim,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Size = UDim2.new(1, -30, 0, 14),
		Position = UDim2.fromOffset(26, 7),
		Parent = frame
	})

	return (UI.text({
		Name = "Value",
		Text = "--",
		RichText = true,
		FontFace = Theme.fontHeavy,
		TextSize = 18,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Size = UDim2.new(1, -16, 0, 20),
		Position = UDim2.fromOffset(8, 24),
		Parent = frame
	}))
end

local function cellRow(parent2, layoutOrder, value)
	return UI.new("Frame", {
		Name = "Cells",
		Size = UDim2.new(1, 0, 0, value or 48),
		BackgroundTransparency = 1,
		LayoutOrder = layoutOrder,
		Parent = parent2
	}, { UI.list(Enum.FillDirection.Horizontal, 6) })
end

local function chip(frame, layoutOrder, p, p2, backgroundColor, p3)
	local new = UI.new
	local v5 = {
		Name = p,
		Size = UDim2.fromOffset(0, 18),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = 0,
		Visible = false,
		LayoutOrder = 0,
		Parent = 0
	}
	backgroundColor = p3 and Color3.new(1, 1, 1) or backgroundColor
	v5.BackgroundColor3 = backgroundColor

	v5.LayoutOrder = layoutOrder
	v5.Parent = frame
	local parent2 = new("Frame", v5, {
		UI.corner(UDim.new(0, 4)),
		UI.pad(0, 6, 0, p2 and 4 or 6),
		UI.list(Enum.FillDirection.Horizontal, 3, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)
	})

	if p3 then
		local uiGradient = Instance.new("UIGradient")
		uiGradient.Rotation = 90
		uiGradient.Color = ColorSequence.new(color2, color3)
		uiGradient.Parent = parent2
	end

	if p2 then
		UI.icon(p2, 12, Color3.new(1, 1, 1), { LayoutOrder = 1, Parent = parent2 })
	end

	UI.text({
		Name = "Label",
		Text = p,
		FontFace = Theme.fontHeavy,
		TextSize = 12,
		TextColor3 = p3 and Theme.vipInk or Theme.text,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromScale(0, 1),
		LayoutOrder = 2,
		Parent = parent2
	})

	return parent2
end

local function build(app, parent2, p)
	local v5 = {}

	local frame = UI.new("Frame", {
		Name = "State",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Visible = false,
		LayoutOrder = 0,
		Parent = parent2
	}, { UI.list(Enum.FillDirection.Vertical, 12, Enum.HorizontalAlignment.Center), UI.pad(24, 0, 0, 0) })
	local text = UI.text({
		Name = "Text",
		Text = "",
		TextSize = 15,
		TextColor3 = Theme.textDim,
		TextWrapped = true,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 1,
		Parent = frame
	})

	local button = UI.button({
		parent = frame,
		name = "Retry",
		size = UDim2.fromOffset(150, 42),
		style = "secondary",
		icon = "replay",
		iconSize = 18,
		text = "Try again",
		textSize = 16,
		layoutOrder = 2,
		onClick = function()
			if v5.onRetry then
				v5.onRetry()
			end
		end
	})

	local frame2 = UI.new("Frame", {
		Name = "Content",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 1,
		Parent = parent2
	})

	local list = UI.list(Enum.FillDirection.Vertical, 10)
	list.Parent = frame2

	local uiSizeConstraint = Instance.new("UISizeConstraint")
	uiSizeConstraint.Parent = frame2
	local function column(name, layoutOrder)
		return UI.new("Frame", {
			Name = name,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = layoutOrder,
			Parent = frame2
		}, { UI.list(Enum.FillDirection.Vertical, 10) })
	end

	local parent3 = column("Left", 1)
	local parent4 = column("Right", 2)

	local frame3 = UI.new("Frame", {
		Name = "Head",
		Size = UDim2.new(1, 0, 0, 128),
		BackgroundColor3 = Theme.panelLight,
		LayoutOrder = 1,
		Parent = parent3
	}, { UI.corner(8) })
	local avatar = UI.avatar(nil, 72, { Position = UDim2.fromOffset(12, 12), Parent = frame3 })
	local text2 = UI.text({
		Name = "Name",
		Text = "",
		FontFace = Theme.fontHeavy,
		TextSize = 22,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Size = UDim2.new(1, -108, 0, 26),
		Position = UDim2.fromOffset(96, 12),
		Parent = frame3
	})

	local uiGradient = Instance.new("UIGradient")
	uiGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, color),
		ColorSequenceKeypoint.new(0.4, color),
		ColorSequenceKeypoint.new(0.5, color4),
		ColorSequenceKeypoint.new(0.6, color),
		ColorSequenceKeypoint.new(1, color)
	})

	uiGradient.Offset = Vector2.new(-1, 0)
	uiGradient.Enabled = false
	uiGradient.Parent = text2
	local tween = TweenService:Create(
		uiGradient,
		TweenInfo.new(1.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, false, 2.4),
		{ Offset = Vector2.new(1, 0) }
	)

	local frame4 = UI.new("Frame", {
		Name = "Sub",
		Size = UDim2.new(1, -108, 0, 18),
		Position = UDim2.fromOffset(96, 40),
		BackgroundTransparency = 1,
		Parent = frame3
	}, { UI.list(Enum.FillDirection.Horizontal, 6, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center) })
	local text3 = UI.text({
		Name = "User",
		Text = "",
		TextSize = 14,
		TextColor3 = Theme.textDim,
		TextTruncate = Enum.TextTruncate.AtEnd,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromScale(0, 1),
		LayoutOrder = 1,
		Parent = frame4
	})

	local uiSizeConstraint2 = Instance.new("UISizeConstraint")
	uiSizeConstraint2.MaxSize = Vector2.new(150, 1e999)
	uiSizeConstraint2.Parent = text3
	local v6 = chip(frame4, 2, "VIP", nil, nil, true)
	local v7 = chip(frame4, 3, "Supporter", "heart", Theme.donate)

	local v8 = {
		donated = Color3.fromRGB(196, 44, 128),
		bullet = Color3.fromRGB(206, 120, 20),
		blitz = Color3.fromRGB(36, 104, 206),
		rapid = Color3.fromRGB(70, 146, 44),
		puzzle = Color3.fromRGB(214, 100, 30),
		wins = Color3.fromRGB(28, 140, 112),
		playtime = Color3.fromRGB(110, 76, 200)
	}

	local v9 = chip(frame4, 4, "LbTag", "leaderboard", v8.blitz)
	local function setLbChip(lbTag) -- 1 equivalent call inferred from this helper
		local visible

		if type(lbTag) == "table" then
			visible = type(lbTag.text) == "string"
		else
			visible = false
		end

		v9.Visible = visible

		if visible then
			v9.BackgroundColor3 = v8[lbTag.board] or v8.blitz
			v9.Label.Text = lbTag.text
		end
	end
	local frame5 = UI.new("Frame", {
		Name = "Status",
		Size = UDim2.new(1, -108, 0, 16),
		Position = UDim2.fromOffset(96, 62),
		BackgroundTransparency = 1,
		Parent = frame3
	}, { UI.list(Enum.FillDirection.Horizontal, 6, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center) })
	local frame6 = UI.new("Frame", {
		Name = "Dot",
		Size = UDim2.fromOffset(8, 8),
		BackgroundColor3 = Theme.green,
		Visible = false,
		LayoutOrder = 1,
		Parent = frame5
	}, { UI.corner(UDim.new(1, 0)) })
	local text4 = UI.text({
		Name = "Text",
		Text = "",
		TextSize = 13,
		TextColor3 = Theme.textDim,
		TextTruncate = Enum.TextTruncate.AtEnd,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromScale(0, 1),
		LayoutOrder = 2,
		Parent = frame5
	})

	local text5 = UI.text({
		Name = "Level",
		Text = "",
		FontFace = Theme.fontBold,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(0.5, -12, 0, 18),
		Position = UDim2.fromOffset(12, 90),
		Parent = frame3
	})

	local text6 = UI.text({
		Name = "XP",
		Text = "",
		TextSize = 12,
		TextColor3 = Theme.textDim,
		TextXAlignment = Enum.TextXAlignment.Right,
		AnchorPoint = Vector2.new(1, 0),
		Size = UDim2.new(0.5, -12, 0, 18),
		Position = UDim2.new(1, -12, 0, 90),
		Parent = frame3
	})

	local bar = Levels2.bar(8)
	bar.frame.Position = UDim2.fromOffset(12, 111)
	bar.frame.Size = UDim2.new(1, -24, 0, 8)
	bar.frame.Parent = frame3
	local v10

	if p then
		v10 = nil
	else
		v10 = UI.button({
			parent = frame3,
			name = "Challenge",
			size = UDim2.new(1, -24, 0, 40),
			position = UDim2.fromOffset(12, 128),
			style = "primary",
			icon = "swords",
			iconSize = 20,
			text = "Challenge",
			textSize = 17,
			onClick = function()
				local view = v5.view

				if view and app.modals then
					app.modals.challenge({
						UserId = view.userId,
						DisplayName = text2.Text ~= "" and text2.Text or view.display or view.name or "Player",
						Name = view.name or ""
					})
				end
			end
		})

		v10.holder.Visible = false
	end

	local v11

	if p then
		v11 = nil
	else
		v11 = UI.button({
			parent = frame3,
			name = "Watch",
			size = UDim2.new(1, -24, 0, 40),
			position = UDim2.fromOffset(12, 128),
			style = "primary",
			icon = "eye",
			iconSize = 20,
			text = "Watch Live Game",
			textSize = 17,
			onClick = function()
				local view = v5.view

				if view and app.watch then
					task.spawn(app.watch, view.userId)
				end
			end
		})

		v11.holder.Visible = false
	end

	local v12 = false
	local function setVip(enabled) -- 1 equivalent call inferred from this helper
		if v12 == enabled then
			return
		end

		v12 = enabled
		uiGradient.Enabled = enabled
		text2.TextColor3 = enabled and Color3.new(1, 1, 1) or Theme.text

		if not enabled then
			tween:Cancel()

			return
		end

		uiGradient.Offset = Vector2.new(-1, 0)
		tween:Play()
	end

	local text7 = UI.text({
		Name = "RatingsLabel",
		Text = "Ratings",
		FontFace = Theme.fontBold,
		TextSize = 14,
		TextColor3 = Theme.textDim,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 16),
		LayoutOrder = 2,
		Parent = parent3
	})

	local frame7 = UI.new("Frame", {
		Name = "Ratings",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 3,
		Parent = parent3
	})

	local uiGridLayout = Instance.new("UIGridLayout")
	uiGridLayout.CellSize = UDim2.new(0.5, -4, 0, 84)
	uiGridLayout.CellPadding = UDim2.fromOffset(8, 8)
	uiGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiGridLayout.Parent = frame7
	local v13 = {}
	local function ratingTile(p2, layoutOrder, p3, p4, p5)
		local frame8 = UI.new(
			"Frame",
			{
				Name = p5,
				BackgroundColor3 = Theme.panelLight,
				LayoutOrder = layoutOrder,
				Parent = frame7
			},
			{ UI.corner(8) }
		)
		UI.icon(p3, 18, p4, { Position = UDim2.fromOffset(10, 10), Parent = frame8 })
		UI.text({
			Name = "Label",
			Text = p5,
			FontFace = Theme.fontBold,
			TextSize = 14,
			TextColor3 = Theme.textSoft,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, -44, 0, 18),
			Position = UDim2.fromOffset(34, 10),
			Parent = frame8
		})

		v13[p2] = {
			value = UI.text({
				Name = "Value",
				Text = "--",
				RichText = true,
				FontFace = Theme.fontHeavy,
				TextSize = 26,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, -20, 0, 28),
				Position = UDim2.fromOffset(10, 31),
				Parent = frame8
			}),
			sub = UI.text({
				Name = "Sub",
				Text = "",
				TextSize = 12,
				TextColor3 = Theme.textDim,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Size = UDim2.new(1, -20, 0, 16),
				Position = UDim2.fromOffset(10, 60),
				Parent = frame8
			})
		}
	end

	for k, class in Config.CLASSES do
		ratingTile(class, k, Config.CLASS_ICON[class], Config.CLASS_COLOR[class], Config.CLASS_LABEL[class])
	end

	ratingTile("puzzle", #Config.CLASSES + 1, "puzzle", Theme.puzzle, "Puzzles")

	local parent5 = card(parent3, 4, "Games")
	local _, v14 = titleRow(parent5, 1, "pawn", Theme.green, "Online games")
	local frame8 = UI.new("Frame", {
		Name = "Results",
		Size = UDim2.new(1, 0, 0, 10),
		BackgroundColor3 = color5,
		LayoutOrder = 2,
		Parent = parent5
	}, { UI.corner(UDim.new(1, 0)) })
	local uiGradient2 = Instance.new("UIGradient")
	uiGradient2.Enabled = false
	uiGradient2.Parent = frame8
	local text8 = UI.text({
		Name = "ResultsText",
		Text = "",
		RichText = true,
		FontFace = Theme.fontMedium,
		TextSize = 13,
		TextColor3 = Theme.textDim,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Size = UDim2.new(1, 0, 0, 16),
		LayoutOrder = 3,
		Parent = parent5
	})

	local parent6 = cellRow(parent5, 4)
	local udim = UDim2.new(1 / 3, -4, 1, 0)
	local v15 = statCell(parent6, 1, udim, "chart", blueSoft, "Win rate")
	local v16 = statCell(parent6, 2, udim, "trend", Theme.green, "Win streak")
	local v17 = statCell(parent6, 3, udim, "star", Theme.gold, "Best win")

	local parent7 = cellRow(parent5, 5)
	local v18 = statCell(parent7, 1, UDim2.new(1, 0, 1, 0), "crown", Theme.gold, "Tournament medals")
	parent7.Visible = Config.TOURNAMENTS_ENABLED == true

	local function setResults(total, total2, total3)
		local v19 = total + total2 + total3

		if v19 <= 0 then
			uiGradient2.Enabled = false
			frame8.BackgroundColor3 = color5
		else
			local total4 = 0
			local v20 = {}

			for _, v21 in {
				{ total, Theme.win },
				{ total2, Theme.draw },
				{ total3, Theme.loss }
			} do
				if not (v21[1] > 0) then
					continue
				end

				table.insert(v20, { total4, total4 + v21[1] / v19, v21[2] })
				total4 += v21[1] / v19
			end

			frame8.BackgroundColor3 = Color3.new(1, 1, 1)
			uiGradient2.Color = bands(v20)
			uiGradient2.Enabled = true
		end
	end

	local parent8 = card(parent3, 5, "Private")
	parent8.Visible = false
	titleRow(parent8, 1, "lock", Theme.textSoft, "Private profile")
	UI.text({
		Name = "Text",
		Text = "This player has made their profile private.",
		TextSize = 14,
		TextColor3 = Theme.textDim,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 2,
		Parent = parent8
	})

	local parent9 = card(parent3, 6, "Badges")
	UI.lift(parent9)
	local _, v19 = titleRow(parent9, 1, "trophy", Theme.gold, "Badges")
	local frame9 = UI.new("Frame", {
		Name = "Grid",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 2,
		Parent = parent9
	})

	local uiGridLayout2 = Instance.new("UIGridLayout")
	uiGridLayout2.CellSize = UDim2.fromOffset(48, 48)
	uiGridLayout2.CellPadding = UDim2.fromOffset(8, 8)
	uiGridLayout2.SortOrder = Enum.SortOrder.LayoutOrder
	uiGridLayout2.Parent = frame9
	local text9 = UI.text({
		Name = "BadgeName",
		Text = "",
		RichText = true,
		FontFace = Theme.fontBold,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Size = UDim2.new(1, 0, 0, 18),
		Visible = false,
		LayoutOrder = 3,
		Parent = parent9
	})

	local text10 = UI.text({
		Name = "BadgeDesc",
		Text = "",
		TextSize = 13,
		TextColor3 = Theme.textDim,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 4,
		Parent = parent9
	})

	local v20 = {}
	local v21 = nil
	local function pickBadge(p2)
		v21 = p2
		local badge = nil

		for k, v22 in v20 do
			v22.ring.Enabled = k == p2

			if k == p2 then
				badge = v22.badge
			end
		end

		if badge then
			text9.Text = string.format(
				"%s  <font size=\"12\" color=\"%s\">%s</font>",
				badge.n,
				badge.got and hex(Theme.win) or v4, -- inferred equivalent call
				badge.got and "Earned" or "Not earned yet"
			)

			text10.Text = badge.d
			text9.Visible = true
		else
			text9.Text = ""
			text9.Visible = false
			text10.Text = "Tap a badge to see how to get it."
		end
	end
	local function setBadges(badges)
		local v22 = type(badges) == "table" and badges or {}
		local set = {}
		local count = 0

		for k, badge in v22 do
			set[badge.k] = true

			if badge.got then
				count += 1
			end

			local v23 = v20[badge.k]

			if not v23 then
				local imageButton = UI.new("ImageButton", {
					Name = badge.k,
					AutoButtonColor = false,
					BackgroundColor3 = Theme.panelHeader,
					ScaleType = Enum.ScaleType.Fit,
					Parent = frame9
				}, { UI.corner(UDim.new(1, 0)) })
				local uiStroke = Instance.new("UIStroke")
				uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				uiStroke.Color = Theme.gold
				uiStroke.Thickness = 2
				uiStroke.Enabled = false
				uiStroke.Parent = imageButton
				v23 = {
					button = imageButton,
					ring = uiStroke,
					lock = UI.icon("lock", 14, Theme.textSoft, {
						Name = "Lock",
						AnchorPoint = Vector2.new(1, 1),
						Position = UDim2.fromScale(1, 1),
						ZIndex = 2,
						Parent = imageButton
					})
				}
				v20[badge.k] = v23
				local k2 = badge.k
				imageButton.Activated:Connect(function()
					local v24

					if v21 ~= k2 then
						v24 = k2 or nil
					end

					pickBadge(v24)
				end)
			end

			v23.badge = badge
			v23.button.LayoutOrder = k
			v23.button.Image = string.format("rbxthumb://type=BadgeIcon&id=%d&w=150&h=150", tonumber(badge.id) or 0)
			v23.button.ImageTransparency = badge.got and 0 or 0.72
			v23.button.ImageColor3 = badge.got and Color3.new(1, 1, 1) or Color3.fromRGB(150, 150, 150)
			v23.lock.Visible = not badge.got
		end

		for k, v23 in v20 do
			if set[k] then
				continue
			end

			v23.button:Destroy()
			v20[k] = nil
		end

		v19.Text = string.format("%s / %s", commas(count), commas(#v22))
		parent9.Visible = #v22 > 0 and not v5.private
		pickBadge(v21 and v20[v21] and v21 or nil)
	end

	local parent10 = card(parent3, 7, "RecentGames")
	UI.lift(parent10)
	local _, v22 = titleRow(parent10, 1, "history", Theme.blueSoft or Theme.green, "Recent games")
	local frame10 = UI.new("Frame", {
		Name = "List",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 2,
		Parent = parent10
	}, { UI.list(Enum.FillDirection.Vertical, 6) })
	local text11 = UI.text({
		Name = "Empty",
		Text = "No online games yet.",
		TextSize = 14,
		TextColor3 = Theme.textDim,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 18),
		Visible = false,
		LayoutOrder = 3,
		Parent = parent10
	})

	local button2 = UI.button({
		parent = parent10,
		name = "AllGames",
		size = UDim2.new(1, 0, 0, 42),
		style = "secondary",
		icon = "history",
		iconSize = 18,
		text = "View all games",
		textSize = 15,
		layoutOrder = 4,
		onClick = function()
			local view = v5.view

			if not view then
				return
			end

			if p then
				app.pages.show("history")
			elseif app.openPlayerGames then
				app.openPlayerGames(view.userId, view.display or view.name)
			end
		end
	})

	local function ago(t)
		local v23 = os.time() - (tonumber(t) or os.time())

		if v23 < 60 then
			return "just now"
		end

		if v23 < 3600 then
			return v23 // 60 .. "m ago"
		end

		if v23 < 86400 then
			return v23 // 3600 .. "h ago"
		end

		if v23 < 2592000 then
			return v23 // 86400 .. "d ago"
		end

		return monthYear(t) or "" -- inferred equivalent call
	end

	local function recentRow(k, data)
		local color6 = data.color
		local black = color6 == 1 and data.black or data.white or {}
		local v23

		if data.res == "1-0" and color6 == 1 then
			v23 = true
		elseif data.res == "0-1" then
			v23 = color6 == -1
		else
			v23 = false
		end

		local v24 = data.res == "1/2-1/2"
		local v25 = data.res == "*"
		local textButton = UI.new("TextButton", {
			Name = "Game" .. k,
			Text = "",
			AutoButtonColor = false,
			Size = UDim2.new(1, 0, 0, 48),
			BackgroundColor3 = Theme.panel,
			LayoutOrder = k,
			Parent = frame10
		}, { UI.corner(10) })
		textButton:SetAttribute("Sfx", "press")
		local frame11 = UI.new("Frame", {
			Name = "Result",
			Size = UDim2.fromOffset(30, 30),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 9, 0.5, 0),
			BackgroundColor3 = v25 and Theme.textMuted or v23 and Theme.win or v24 and Theme.draw or Theme.loss,
			Parent = textButton
		}, { UI.corner(UDim.new(0.3, 0)) })
		UI.text({
			Text = v25 and "-" or v23 and "W" or v24 and "D" or "L",
			FontFace = Theme.fontHeavy,
			TextSize = 15,
			TextColor3 = Color3.new(1, 1, 1),
			Size = UDim2.fromScale(1, 1),
			Parent = frame11
		})

		UI.text({
			Name = "Opponent",
			Text = "vs " .. tostring(black.n or "Opponent") .. (black.r and " (" .. tostring(black.r) .. ")" or ""),
			FontFace = Theme.fontBold,
			TextSize = 15,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Size = UDim2.new(1, -120, 0, 18),
			Position = UDim2.fromOffset(48, 6),
			Parent = textButton
		})

		local v26 = Config.TC_BY_ID[data.tc]
		local v27 = data.mv and data.mv ~= "" and #string.split(data.mv, " ") or 0
		UI.text({
			Name = "Meta",
			Text = string.format("%s  ·  %d moves  ·  %s", v26 and v26.label or "?", (v27 + 1) // 2, ago(data.t)),
			TextSize = 12,
			TextColor3 = Theme.textDim,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Size = UDim2.new(1, -120, 0, 16),
			Position = UDim2.fromOffset(48, 25),
			Parent = textButton
		})

		if data.rated and type(data.d) == "number" then
			UI.text({
				Name = "Delta",
				Text = (data.d >= 0 and "+" or "") .. tostring(data.d),
				FontFace = Theme.fontHeavy,
				TextSize = 15,
				TextColor3 = data.d > 0 and Theme.win or data.d < 0 and Theme.loss or Theme.textDim,
				TextXAlignment = Enum.TextXAlignment.Right,
				AnchorPoint = Vector2.new(1, 0.5),
				Size = UDim2.fromOffset(60, 20),
				Position = UDim2.new(1, -12, 0.5, 0),
				Parent = textButton
			})
		end

		UI.hover(textButton, nil, { BackgroundColor3 = Theme.rowActive }, {
			BackgroundColor3 = Theme.panel
		})
		textButton.Activated:Connect(function()
			if app.inLiveGame() then
				app.toast("Finish your game first.")
			else
				app.openHistory(data)
			end
		end)
	end

	local function setRecent(view)
		for _, guiObject in frame10:GetChildren() do
			if guiObject:IsA("GuiObject") then
				guiObject:Destroy()
			end
		end

		local recent = type(view.recent) == "table" and view.recent or {}
		local gamesTotal = tonumber(view.gamesTotal) or #recent

		for k, v23 in recent do
			if type(v23) == "table" then
				recentRow(k, v23)
			end
		end

		text11.Visible = #recent == 0
		frame10.Visible = #recent > 0
		button2:setVisible(gamesTotal > 0)
		v22.Text = gamesTotal > 0 and commas(gamesTotal) .. (gamesTotal == 1 and " game" or " games") or ""
	end

	local parent11 = card(parent4, 1, "Puzzles")
	local _, v23 = titleRow(parent11, 1, "puzzle", Theme.puzzle, "Puzzles")
	local text12 = UI.text({
		Name = "Line",
		Text = "",
		FontFace = Theme.fontMedium,
		TextSize = 13,
		TextColor3 = Theme.textDim,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Size = UDim2.new(1, 0, 0, 16),
		LayoutOrder = 2,
		Parent = parent11
	})

	local parent12 = cellRow(parent11, 3)
	local v24 = statCell(parent12, 1, udim, "bolt", Theme.rush, "Sprint 3 min")
	local v25 = statCell(parent12, 2, udim, "bolt", Theme.rush, "Sprint 5 min")
	local v26 = statCell(parent12, 3, udim, "bolt", Theme.rush, "Survival")

	local parent13 = card(parent4, 2, "Look")
	local parent14, v27 = titleRow(parent13, 1, "star", Theme.blueSoft, "Look")

	if p then
		v27.Visible = false
		local textButton = UI.new("TextButton", {
			Name = "Change",
			Text = "Change",
			FontFace = Theme.fontBold,
			TextSize = 14,
			TextColor3 = Theme.green,
			TextXAlignment = Enum.TextXAlignment.Right,
			AnchorPoint = Vector2.new(1, 0),
			Size = UDim2.new(0, 80, 1, 0),
			Position = UDim2.fromScale(1, 0),
			Parent = parent14
		})

		UI.hover(textButton, nil, { TextColor3 = Theme.greenHover }, { TextColor3 = Theme.green })
		textButton.Activated:Connect(function()
			app.pages.show("inventory")
		end)
	end

	local frame11 = UI.new("Frame", {
		Name = "Items",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 2,
		Parent = parent13
	})

	local uiGridLayout3 = Instance.new("UIGridLayout")
	uiGridLayout3.CellSize = UDim2.new(1 / 3, -6, 0, 104)
	uiGridLayout3.CellPadding = UDim2.fromOffset(8, 8)
	uiGridLayout3.SortOrder = Enum.SortOrder.LayoutOrder
	uiGridLayout3.Parent = frame11
	local v28 = {}

	for k, v29 in Cosmetics.TYPES do
		local frame12 = UI.new("Frame", {
			Name = v29.id,
			BackgroundColor3 = Theme.panelHeader,
			ClipsDescendants = true,
			LayoutOrder = k,
			Parent = frame11
		}, { UI.corner(8) })
		local frame13 = UI.new("Frame", {
			Name = "Glow",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 0.82,
			Visible = false,
			Parent = frame12
		})

		local uiGradient3 = Instance.new("UIGradient")
		uiGradient3.Rotation = 90
		uiGradient3.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(1, 0)
		})
		uiGradient3.Parent = frame13
		local frame14 = UI.new("Frame", {
			Name = "Area",
			Size = UDim2.new(1, 0, 1, -36),
			BackgroundTransparency = 1,
			Parent = frame12
		})

		local text13 = UI.text({
			Name = "Name",
			Text = "",
			FontFace = Theme.fontBold,
			TextSize = 12,
			TextColor3 = Theme.textSoft,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Size = UDim2.new(1, -8, 0, 14),
			Position = UDim2.new(0, 4, 1, -34),
			Parent = frame12
		})

		UI.text({
			Name = "Type",
			Text = v29.one,
			TextSize = 11,
			TextColor3 = Theme.textDim,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Size = UDim2.new(1, -8, 0, 13),
			Position = UDim2.new(0, 4, 1, -19),
			Parent = frame12
		})

		local frame15 = UI.new("Frame", {
			Name = "Bar",
			Size = UDim2.new(1, 0, 0, 3),
			Position = UDim2.new(0, 0, 1, -3),
			BackgroundColor3 = Theme.textMuted,
			Parent = frame12
		})

		v28[v29.id] = { glow = frame13, area = frame14, name = text13, bar = frame15 }
	end

	local frame12 = UI.new("Frame", {
		Name = "Collection",
		BackgroundColor3 = Theme.panelHeader,
		LayoutOrder = #Cosmetics.TYPES + 1,
		Parent = frame11
	}, { UI.corner(8) })
	UI.icon("crate", 28, Theme.token, {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 12),
		Parent = frame12
	})

	local text13 = UI.text({
		Name = "Value",
		Text = "",
		FontFace = Theme.fontHeavy,
		TextSize = 19,
		Size = UDim2.new(1, -8, 0, 22),
		Position = UDim2.new(0, 4, 0, 44),
		Parent = frame12
	})

	UI.text({
		Name = "Label",
		Text = "collected",
		TextSize = 11,
		TextColor3 = Theme.textDim,
		Size = UDim2.new(1, -8, 0, 13),
		Position = UDim2.new(0, 4, 0, 66),
		Parent = frame12
	})

	local bar2 = Levels2.bar(5, Theme.token)
	bar2.frame.Position = UDim2.new(0, 12, 1, -15)
	bar2.frame.Size = UDim2.new(1, -24, 0, 5)
	bar2.frame.Parent = frame12

	local function setLook(id, id2)
		local v29 = v28[id]

		if not v29 or v29.id == id2 then
			return
		end

		v29.id = id2

		if v29.holder then
			v29.holder:Destroy()
		end

		local v30 = Cosmetics.BY_ID[id2] or Cosmetics.BY_ID[Cosmetics.DEFAULT[id]]

		if not v30 then
			v29.name.Text = "None"
			return
		end

		local v31 = Cosmetics.RARITY[v30.vip and "vip" or v30.rarity] or Cosmetics.RARITY.common
		local textMuted = v30.free and Theme.textMuted or v31.color
		v29.glow.BackgroundColor3 = textMuted
		v29.glow.Visible = not v30.free
		v29.bar.BackgroundColor3 = textMuted
		v29.name.Text = v30.name
		v29.name.TextColor3 = v30.free and Theme.textDim or Theme.textSoft
		local frame13 = UI.new("Frame", {
			Name = "Holder",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Parent = v29.area
		})

		v29.holder = frame13
		local success, result = pcall(Cosmetics2.preview, v30, frame13)

		if not success then
			warn("[Chess] Profile look preview failed: " .. tostring(result))
		end

		if v30.type == "effect" and not v30.free then
			Cosmetics2.loopEffect(frame13, v30.id, 0.6)
		end
	end

	local parent15 = cellRow(parent4, 3)
	local udim2 = UDim2.new(0.5, -3, 1, 0)
	local v29 = statCell(parent15, 1, udim2, "hourglass", Theme.textSoft, "Time played")
	local v30 = statCell(parent15, 2, udim2, "bot", Theme.blueSoft, "Bots beaten")
	local v31

	if p then
		v31 = nil
	else
		v31 = UI.button({
			parent = parent4,
			name = "Gift",
			size = UDim2.new(1, 0, 0, 46),
			style = "secondary",
			icon = "gift",
			iconColor = Theme.donate,
			iconSize = 20,
			text = "Send a gift",
			textSize = 16,
			layoutOrder = 4,
			onClick = function()
				local view = v5.view

				if view and app.openGift then
					app.openGift({ userId = view.userId, name = view.name, display = view.display }, nil, "profile")
				end
			end
		})

		v31.holder.Visible = false
	end

	local v32

	if p then
		UI.button({
			parent = parent4,
			name = "History",
			size = UDim2.new(1, 0, 0, 46),
			style = "secondary",
			icon = "history",
			iconSize = 20,
			text = "Game History",
			textSize = 16,
			layoutOrder = 4,
			onClick = function()
				app.pages.show("history")
			end
		})

		UI.text({
			Name = "LevelsNote",
			Text = "Levels: XP from online games (5 moves each or more), rated puzzles and Puzzle Sprint. Every level pays tokens.",
			TextSize = 12,
			TextColor3 = Theme.textMuted,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = 5,
			Parent = parent4
		})

		v32 = UI.text({
			Name = "TestNote",
			Text = "Studio test data: stats reset when the test ends.",
			TextSize = 12,
			TextColor3 = Theme.textMuted,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, 0, 0, 16),
			Visible = false,
			LayoutOrder = 6,
			Parent = parent4
		})
	else
		v32 = nil
	end

	v5.wantTwo = false
	local function applyColumns()
		local two = v5.wantTwo and not v5.private
		v5.two = two
		list.FillDirection = two and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical
		list.Padding = UDim.new(0, two and 12 or 10)
		local udim3 = two and UDim2.new(0.5, -6, 0, 0) or UDim2.new(1, 0, 0, 0)
		parent3.Size = udim3
		parent4.Size = udim3
		uiSizeConstraint.MaxSize = Vector2.new(v5.private and 560 or 1e999, 1e999)
	end
	function v5.setColumns(wantTwo)
		if v5.wantTwo ~= wantTwo then
			v5.wantTwo = wantTwo
			applyColumns()
		end
	end

	local function layoutHead()
		local v46 = v5.private and 96 or 128
		local v47 = v10 ~= nil and v10.holder.Visible

		if not v47 then
			v47 = not (v11 == nil) and v11.holder.Visible
		end

		local v48 = v5.private and 92 or 128

		if v10 then
			v10.holder.Position = UDim2.fromOffset(12, v48)
		end

		if v11 then
			v11.holder.Position = UDim2.fromOffset(12, v48)
		end

		v46 = v47 and v48 + 52 or v46
		frame3.Size = UDim2.new(1, 0, 0, v46)
	end

	local function playingHere(): boolean -- 1 equivalent call inferred from this helper
		local v46 = v5.view

		if v46 then
			if type(v46.userId) == "number" then
				v46 = Players:GetPlayerByUserId(v46.userId)
			else
				v46 = false
			end
		end

		return v46 ~= nil and v46 ~= Players.LocalPlayer and v46:GetAttribute("Status") == "playing"
	end

	function v5.setChallenge(p2)
		v5.challengeWanted = p2 == true

		if v10 then
			local visible

			if v11 == nil or v5.view == nil then
				visible = false
			else
				visible = playingHere() -- inferred equivalent call
			end

			local holder = v10.holder
			holder.Visible = p2 == true and not visible

			if v11 then
				v11.holder.Visible = visible
			end

			layoutHead()
		end
	end

	local function setPrivate(p2) -- 1 equivalent call inferred from this helper
		v5.private = p2
		parent8.Visible = p2
		text7.Visible = not p2
		frame7.Visible = not p2
		parent5.Visible = not p2
		parent10.Visible = not p2
		parent9.Visible = not p2 and #(v5.view and v5.view.badges or {}) > 0
		parent4.Visible = not p2
		frame5.Visible = not p2
		text5.Visible = not p2
		text6.Visible = not p2
		bar.frame.Visible = not p2
		layoutHead()
		applyColumns()
	end

	function v5.setState(value, p2)
		v5.stateShown = value ~= nil
		frame.Visible = value ~= nil
		text.Text = value or ""
		button:setVisible(p2 == true)
		frame2.Visible = value == nil
	end

	function v5.updateNotice() end

	function v5.refreshStatus()
		local view = v5.view

		if not view or v5.private then
			return
		end

		local playerByUserId = Players:GetPlayerByUserId(view.userId)
		local v46

		if playerByUserId then
			v46 = v[playerByUserId:GetAttribute("Status") or "idle"] or v.idle or nil
		end

		local presence = v5.presence

		if not v46 and presence and presence.userId == view.userId and presence.online == true then
			v46 = v.idle
		end

		local v47 = {}
		frame6.Visible = v46 ~= nil

		if v46 then
			frame6.BackgroundColor3 = v46[2]
			table.insert(v47, v46[1])
		end

		local v48 = monthYear(view.joined) -- inferred equivalent call

		if v48 then
			table.insert(v47, "Joined " .. v48)
		end

		text4.Text = table.concat(v47, "  ·  ")

		if v10 then
			v5.setChallenge(v5.challengeWanted)
		end
	end

	function v5.render(view)
		v5.view = view
		setPrivate(false)
		v5.updateNotice()

		avatar.set(type(view.headshot) == "number" and { headshot = view.headshot } or {
			userId = view.userId
		})
		text2.Text = view.display or view.name or "Player"
		text3.Text = "@" .. tostring(view.name or "")
		setVip(view.vip == true)
		v6.Visible = view.vip == true
		v7.Visible = view.supporter == true
		setLbChip(view.lbTag) -- inferred equivalent call
		v5.refreshStatus()
		local v46, v47, v48 = Levels.of(view.xp or 0)
		text5.Text = "Level " .. v46
		text6.Text = string.format("%s / %s XP", commas(v47), commas(v48))
		bar.set(v47 / math.max(1, v48))
		local total = 0
		local total2 = 0
		local total3 = 0

		for _, class in Config.CLASSES do
			local v49 = view.ratings and view.ratings[class]
			local v50 = v13[class]

			if not v49 then
				continue
			end

			v50.value.Text = commas(v49.r) .. (v49.prov and string.format("<font color=\"%s\">?</font>", v4) or "")
			v50.sub.Text = (v49.n or 0) > 0
				and string.format(
					"Best %s  ·  %s %s",
					commas(v49.best or v49.r),
					commas(v49.n),
					v49.n == 1 and "game" or "games"
				)
				or "No rated games yet"

			total += v49.w or 0
			total2 += v49.d or 0
			total3 += v49.l or 0
		end

		local puzzle = view.puzzle

		if puzzle then
			v13.puzzle.value.Text = commas(puzzle.r) .. (puzzle.prov and string.format("<font color=\"%s\">?</font>", v4) or "")
			v13.puzzle.sub.Text = (puzzle.w or 0) > 0
				and string.format("Best %s  ·  %s solved", commas(puzzle.best or puzzle.r), commas(puzzle.w))
				or "No puzzles solved yet"
		end

		local games = view.games or 0
		v14.Text = commas(games) .. (games == 1 and " game" or " games")
		setResults(total, total2, total3)
		local v49 = total + total2 + total3

		if v49 > 0 then
			text8.Text = string.format(
				"Rated: <font color=\"%s\">%s won</font>  ·  <font color=\"%s\">%s drawn</font>  ·  <font color=\"%s\">%s lost</font>",
				hex(Theme.win), -- inferred equivalent call
				commas(total),
				hex(Color3.fromRGB(190, 189, 187)), -- inferred equivalent call
				commas(total2),
				hex(Color3.fromRGB(232, 92, 86)), -- inferred equivalent call
				commas(total3)
			)

			v15.Text = tostring((math.floor(total / v49 * 100 + 0.5))) .. "%"
		else
			text8.Text = "No rated games yet"
			v15.Text = "--"
		end

		local streak = view.streak or {}
		v16.Text = string.format(
			"%s <font size=\"12\" color=\"%s\">best %s</font>",
			commas(streak.cur),
			v4,
			commas(streak.best)
		)
		v21 = nil
		setBadges(view.badges)
		setRecent(view)
		local bestWin = view.bestWin
		v18.Text = commas(view.medals or 0)
		v17.Text = bestWin
			and string.format(
				"%s <font size=\"12\" color=\"%s\">%s</font>",
				commas(bestWin.r),
				v4,
				Config.CLASS_LABEL[bestWin.c] or ""
			)
			or "--"

		v23.Text = puzzle and commas(puzzle.w or 0) .. " solved" or ""
		text12.Text = puzzle
			and string.format("Best streak %s  ·  Missed %s", commas(puzzle.bestStreak or 0), commas(puzzle.l or 0))
			or ""
		local rush = view.rush or {}
		v24.Text = commas(rush.m3)
		v25.Text = commas(rush.m5)
		v26.Text = commas(rush.surv)

		for _, v50 in Cosmetics.TYPES do
			setLook(v50.id, view.look and view.look[v50.id] or Cosmetics.DEFAULT[v50.id])
		end

		local coll = view.coll or {}
		text13.Text = string.format("%s / %s", commas(coll.n), commas(coll.of))
		bar2.set((coll.n or 0) / math.max(1, coll.of or 1))

		v29.Text = timePlayed(view.playtime) -- inferred equivalent call

		if v31 then
			local holder = v31.holder
			holder.Visible = app.canGift ~= nil and app.canGift(view.userId) == true
		end

		local bots = view.bots or {}
		v30.Text = string.format(
			"%s <font size=\"12\" color=\"%s\">/ %s</font>",
			commas(bots.beaten),
			v4,
			commas(bots.of)
		)

		if v32 then
			v32.Visible = app.profile ~= nil and app.profile.offline == true
		end

		v5.checkPresence()
	end

	function v5.checkPresence()
		if not v10 then
			return
		end

		local view = v5.view
		local userId = view and view.userId

		if type(userId) ~= "number" or userId <= 0 or userId == Players.LocalPlayer.UserId then
			v5.setChallenge(false)
		elseif Players:GetPlayerByUserId(userId) then
			v5.presence = { userId = userId, online = true, t = os.clock() }
			v5.setChallenge(true)
		else
			local presence = v5.presence

			if presence and presence.userId == userId and os.clock() - presence.t < 20 then
				v5.setChallenge(presence.online ~= false)
				v5.refreshStatus()
			else
				v5.presence = nil
				v5.setChallenge(false)
				task.spawn(function()
					local request = app.request({ type = "presence", userId = userId })

					if not v5.view or v5.view.userId ~= userId then
						return
					end

					local online

					if type(request) == "table" and request.ok then
						online = request.online == true
					end

					v5.presence = { userId = userId, online = online, t = os.clock() }
					v5.setChallenge(online ~= false)
					v5.refreshStatus()
				end)
			end
		end
	end

	function v5.renderPrivate(view, options)
		v5.view = view
		local v46 = options or {}
		setPrivate(true) -- inferred equivalent call
		local v47 = (type(v46.headshot) == "number" or v46.avatar ~= nil) and v46 or {
			userId = view.userId
		}
		avatar.set(v47)
		local display = view.display or v46.display or v46.name or "Player"
		local name = view.name or v46.name or v46.display
		text2.Text = display
		text3.Text = name and "@" .. name or ""
		setVip(false) -- inferred equivalent call
		v6.Visible = false
		v7.Visible = false
		v9.Visible = false

		frame6.Visible = false
		v5.checkPresence()
	end

	function v5.clear()
		v5.view = nil
		v5.setChallenge(false)
	end

	function v5.state()
		local function texts(folder)
			local v46 = {}

			for _, label in folder:GetDescendants() do
				if label:IsA("TextLabel") and label.Name == "Value" then
					table.insert(v46, label.Parent.Name .. "=" .. label.ContentText)
				end
			end

			return table.concat(v46, " | ")
		end

		local v46 = {}

		for _, v47 in Cosmetics.TYPES do
			table.insert(v46, v47.id .. "=" .. v28[v47.id].name.Text)
		end

		local v47 = {
			state = v5.stateShown and text.Text or nil,
			userId = v5.view and v5.view.userId,
			private = v5.private == true,
			name = text2.Text,
			user = text3.Text,
			vip = v6.Visible,
			supporter = v7.Visible,
			status = text4.Text,
			level = text5.Text .. " (" .. text6.Text .. ")",
			games = v14.Text .. " / " .. text8.ContentText,
			puzzles = v23.Text .. " / " .. text12.Text,
			values = texts(frame2),
			look = table.concat(v46, ", "),
			notice = nil,
			gift = 0,
			lbTag = 0,
			badges = 0,
			recent = 0,
			watch = 0
		}
		local gift

		if not (v31 == nil or not v31.holder.Visible) then
			gift = parent4.Visible or nil
		end

		v47.gift = gift
		v47.lbTag = v9.Visible and v9.Label.Text or nil
		v47.badges = parent9.Visible and v19.Text .. " / " .. text9.ContentText .. " " .. text10.Text or nil
		v47.recent = parent10.Visible and v22.Text .. " / " .. #frame10:GetChildren() - 1 .. " rows" or nil
		local watch

		if v11 ~= nil then
			watch = v11.holder.Visible or nil
		end

		v47.watch = watch
		return v47
	end

	return v5
end

function Profile:install()
	local pages = self.pages
	local localPlayer = Players.LocalPlayer
	local v5 = { stats = true, profile = true }
	local v6 = {}
	local v7 = {}
	local v8 = {}

	local function remember(value, display, name)
		if type(value) ~= "number" or value <= 0 then
			return
		end

		local v9 = v7[value] or {}

		if type(display) == "string" and display ~= "" then
			v9.display = display
		end

		if type(name) == "string" and name ~= "" then
			v9.name = name
		end

		if v9.display or v9.name then
			v7[value] = v9
		end
	end
	local function addRecent(userId)
		local index = table.find(v8, userId)

		if index then
			table.remove(v8, index)
		end

		table.insert(v8, 1, userId)

		while #v8 > 8 do
			table.remove(v8)
		end
	end

	local function fetch(userId)
		local request = self.request({ type = "profile", userId = userId })

		if type(request) == "table" and request.ok then
			v6[userId] = { t = os.clock(), view = request }
			remember(request.userId, request.display, request.name)
		end

		return request
	end

	local function reasonOf(p)
		return v2[type(p) == "table" and p.reason or "error"] or "Couldn't load this profile right now."
	end

	local function canRetry(p): boolean -- 2 equivalent calls inferred from this helper
		return type(p) ~= "table" or p.reason ~= "none"
	end

	local frame = UI.new("Frame", {
		Name = "Wide",
		BackgroundColor3 = Theme.panel,
		Active = true,
		ClipsDescendants = true,
		Visible = false,
		ZIndex = 3,
		Parent = self.root
	}, { UI.corner(8) })
	local uiScale = Instance.new("UIScale")
	uiScale.Parent = frame
	Profile.wide = frame

	local frame2 = UI.new("Frame", {
		Name = "Header",
		Size = UDim2.new(1, 0, 0, 56),
		BackgroundColor3 = Theme.panelHeader,
		ZIndex = 2,
		Parent = frame
	})

	local imageButton = UI.new("ImageButton", {
		Name = "Back",
		Size = UDim2.fromOffset(40, 40),
		Position = UDim2.new(0, 8, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = Theme.panelLight,
		BackgroundTransparency = 1,
		Parent = frame2
	}, { UI.corner(6) })
	UI.icon("back", 24, Theme.textDim, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Parent = imageButton
	})

	UI.hover(imageButton, nil, { BackgroundTransparency = 0 }, { BackgroundTransparency = 1 })
	UI.icon("person", 24, blueSoft, {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 56, 0.5, 0),
		Parent = frame2
	})

	local text = UI.text({
		Name = "Title",
		Text = "Profile",
		FontFace = Theme.fontHeavy,
		TextSize = 21,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromScale(0, 1),
		Position = UDim2.fromOffset(88, 0),
		Parent = frame2
	})

	local frame3 = UI.new("Frame", {
		Name = "Search",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(240, 38),
		BackgroundColor3 = Theme.panelLight,
		Parent = frame2
	}, { UI.corner(UDim.new(0.5, 0)) })
	local stroke = UI.stroke(Theme.green, 1.5, 1)
	stroke.Parent = frame3
	UI.icon("search", 18, Theme.textDim, {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 12, 0.5, 0),
		Parent = frame3
	})

	local textBox = UI.new("TextBox", {
		Name = "Box",
		Text = "",
		PlaceholderText = "Search players",
		PlaceholderColor3 = Theme.textMuted,
		ClearTextOnFocus = false,
		FontFace = Theme.fontMedium,
		TextSize = 15,
		TextColor3 = Theme.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClipsDescendants = true,
		Size = UDim2.new(1, -46, 1, 0),
		Position = UDim2.fromOffset(38, 0),
		Parent = frame3
	})

	local frame4 = UI.new("Frame", {
		Name = "Suggestions",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -10, 0, 52),
		Size = UDim2.fromOffset(300, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.panelHeader,
		Visible = false,
		ZIndex = 10,
		Parent = frame
	}, {
		UI.corner(8),
		UI.stroke(Theme.divider, 1, 0),
		UI.pad(6, 6, 6, 6),
		UI.list(Enum.FillDirection.Vertical, 2)
	})

	local frame5 = UI.new("Frame", {
		Name = "Body",
		Size = UDim2.new(1, 0, 1, -56),
		Position = UDim2.fromOffset(0, 56),
		BackgroundTransparency = 1,
		Parent = frame
	})

	local page, parent2 = pages.newPage("stats", "Profile", "person", blueSoft, true)
	page.Parent = frame5
	local layout = build(self, parent2, true)
	local stats = { frame = page, layout = layout }
	pages.stats = stats

	local flag = false
	local v9 = false
	local function fetchMe() -- 1 equivalent call inferred from this helper
		if flag then
			v9 = true
			return
		end

		flag = true
		task.spawn(function()
			repeat
				v9 = false
				local v10 = fetch(localPlayer.UserId)

				if type(v10) == "table" and v10.ok and not v10.private then
					layout.setState(nil)
					layout.render(v10)
				elseif not layout.view then
					layout.setState(v2[type(v10) == "table" and v10.reason or "error"] or v2.error, canRetry(v10)) -- inferred equivalent call
				end
			until not v9

			flag = false
		end)
	end
	layout.onRetry = fetchMe
	function stats.refresh()
		layout.updateNotice()

		if not layout.view then
			local v10 = v6[localPlayer.UserId]

			if v10 and not v10.view.private then
				layout.render(v10.view)
				layout.setState(nil)
			else
				layout.setState("Loading your profile...")
			end
		end

		fetchMe() -- inferred equivalent call
	end
	stats.onShow = stats.refresh

	local page2, parent3 = pages.newPage("profile", "Profile", "person", blueSoft, true)
	page2.Parent = frame5
	local layout2 = build(self, parent3, false)
	local profile = { frame = page2, layout = layout2 }
	pages.profile = profile

	local function boardBusy(): boolean -- 2 equivalent calls inferred from this helper
		if self.inLiveGame() then
			return true
		end

		local session = self.session
		return session ~= nil
			and session.kind == "rush"
			and session.pz ~= nil
			and session.pz.run ~= nil
			and session.pz.run.reason == nil
	end

	local v10 = false
	local function hideBoard(p)
		local visible = not (p or self.isFull)

		if v10 ~= p then
			v10 = p
			self.board.frame.Visible = visible
			self.topBar.frame.Visible = visible
			self.bottomBar.frame.Visible = visible
			self.side.Visible = not p
		end

		if self.rightCard then
			self.rightCard.Visible = not p and self.rightCardWanted == true
		end

		for _, v11 in { self.topBar, self.bottomBar } do
			if v11.clockOut then
				v11.clock.Visible = not p and v11.clockVisible == true
			end
		end

		self.evalBar.Visible = visible and self.evalBar:GetAttribute("Wanted") == true

		if self.modals and self.modals.setBoardHidden then
			self.modals.setBoardHidden(not visible)
		end
	end

	local function layoutHeader(p) -- 1 equivalent call inferred from this helper
		local v11 = math.clamp(p - 200, 150, 340)
		frame3.Size = UDim2.fromOffset(v11, 38)
		frame4.Size = UDim2.fromOffset(math.max(260, v11), 0)
		text.Visible = p >= 330
	end

	local function rectOf(p) -- 1 equivalent call inferred from this helper
		local position = p.Position
		local size = p.Size
		return
			position.X.Offset,
			position.Y.Offset,
			position.X.Offset + size.X.Offset,
			position.Y.Offset + size.Y.Offset
	end

	local function layoutWide()
		if not frame.Visible then
			hideBoard(false)
			return
		end

		local uiScale2 = self.uiScale or 1

		local v11 = not boardBusy() and pages.docked ~= pages.current -- inferred equivalent call
		local v12 = nil
		local v13 = nil
		local v14 = nil
		local v15 = nil

		if v11 then
			local v16 = { self.board.frame, self.side }

			if self.rightCard and self.rightCardWanted then
				table.insert(v16, self.rightCard)
			end

			if self.topBar.frame.Parent == self.root then
				table.insert(v16, self.topBar.frame)
				table.insert(v16, self.bottomBar.frame)
			end

			if self.evalBar:GetAttribute("Wanted") == true then
				table.insert(v16, self.evalBar)
			end

			for _, v17 in v16 do
				local v18, v19, v20, v21 = rectOf(v17) -- inferred equivalent call

				if v12 then
					v12 = math.min(v12, v18) or v18
				else
					v12 = v18
				end

				if v13 then
					v13 = math.min(v13, v19) or v19
				else
					v13 = v19
				end

				if v14 then
					v14 = math.max(v14, v20) or v20
				else
					v14 = v20
				end

				if v15 then
					v15 = math.max(v15, v21) or v21
				else
					v15 = v21
				end
			end
		else
			local scale = self.panelScale.Scale
			v12 = self.side.Position.X.Offset
			v13 = self.side.Position.Y.Offset + self.panel.Position.Y.Offset
			v14 = v12 + self.panel.Size.X.Offset * scale
			v15 = v13 + self.panel.Size.Y.Offset * scale
		end

		local v16 = (v14 - v12) / uiScale2
		local v17 = (v15 - v13) / uiScale2
		uiScale.Scale = uiScale2
		frame.Position = UDim2.fromOffset(v12, v13)
		frame.Size = UDim2.fromOffset(v16, v17)
		frame:SetAttribute("Mode", v11 and "full" or "panel")
		hideBoard(v11)
		local v18 = v16 >= 600
		layout.setColumns(v18)
		layout2.setColumns(v18)
		layoutHeader(v16) -- inferred equivalent call
	end
	Profile.layoutWide = layoutWide

	local function setWide(visible) -- 1 equivalent call inferred from this helper
		frame.Visible = visible

		if not visible then
			frame4.Visible = false

			if textBox:IsFocused() then
				textBox:ReleaseFocus()
			end
		end

		layoutWide()
	end

	local v11 = false
	local show = pages.show
	function pages.show(p)
		local current = pages.current

		if v5[p] and current ~= p and not v11 then
			pages.backTo[p] = pages.nextFrom or current
		end

		pages.nextFrom = nil
		show(p)
		setWide(v5[p] == true) -- inferred equivalent call
	end

	local onLayout = pages.onLayout
	function pages.onLayout()
		onLayout()
		layoutWide()
	end

	task.spawn(function()
		local v12 = nil

		while true do
			task.wait(0.3)

			if frame.Visible then
				local v13 = boardBusy() -- inferred equivalent call

				if v13 ~= v12 then
					layoutWide()
					v12 = v13
				end
			else
				v12 = nil
			end
		end
	end)

	function self.profileBack(): boolean
		if not frame.Visible then
			return false
		end

		local current = pages.current
		local v12 = pages.backTo[current]
		local v13 = (v12 == nil or v12 == current or not pages[v12]) and (self.inLiveGame() and "game" or "home") or v12

		if v13 == "home" and not self.inLiveGame() then
			self.goHome()
			return true
		end

		v11 = true
		pages.show(v13)
		v11 = false
		return true
	end

	imageButton.Activated:Connect(self.profileBack)

	local count = 0
	local function showResult(data, p)
		if type(data) == "table" and data.ok then
			layout2.setState(nil)

			if data.private then
				layout2.renderPrivate(data, p)
			else
				layout2.render(data)
			end
		else
			layout2.setState(v2[type(data) == "table" and data.reason or "error"] or v2.error, canRetry(data)) -- inferred equivalent call
		end
	end

	function self.openProfile(userId, nextFrom, p)
		if type(userId) ~= "number" or userId ~= userId or userId == 0 then
			return
		end

		if self.modals and self.modals.top and self.modals.top() then
			self.modals.closeAll()
		end

		if userId == localPlayer.UserId then
			pages.nextFrom = nextFrom
			pages.show("stats")
		else
			local hint

			if type(p) == "table" then
				hint = p or nil
			else
				hint = nil
			end

			if hint then
				remember(userId, hint.display, hint.name)
			end

			if userId > 0 then
				addRecent(userId)
			end

			count += 1
			local v12 = count
			profile.userId = userId
			profile.hint = hint
			local v13 = v6[userId]

			if v13 and os.clock() - v13.t < 30 then
				profile.loading = false
				showResult(v13.view, hint)
			else
				layout2.clear()
				layout2.setState("Loading profile...")
				profile.loading = true
				task.spawn(function()
					local v14 = fetch(userId)

					if v12 ~= count then
						return
					end

					profile.loading = false
					showResult(v14, hint)
				end)
			end

			parent3.CanvasPosition = Vector2.zero
			pages.nextFrom = nextFrom
			pages.show("profile")
		end
	end
	function layout2.onRetry()
		if profile.userId then
			v6[profile.userId] = nil
			self.openProfile(profile.userId, nil, profile.hint)
		end
	end

	function self.profileRow(parent4, userId, p, p2, display, name)
		if type(userId) ~= "number" or userId <= 0 then
			return nil
		end

		remember(userId, display, name)
		local textButton = UI.new("TextButton", {
			Name = "Open",
			Text = "",
			BackgroundTransparency = 1,
			Size = p2 or UDim2.fromScale(1, 1),
			ZIndex = 2,
			Parent = parent4
		})

		textButton:SetAttribute("Sfx", "press")
		local backgroundColor3 = parent4.BackgroundColor3
		local function lit(p3) -- 4 equivalent calls inferred from this helper
			UI.to(parent4, p3 and UI.FAST or UI.SNAP, {
				BackgroundColor3 = p3 and Theme.buttonHover or backgroundColor3
			})
		end
		textButton.MouseEnter:Connect(function()
			lit(true) -- inferred equivalent call
		end)
		textButton.MouseLeave:Connect(function()
			lit(false) -- inferred equivalent call
		end)
		textButton.SelectionGained:Connect(function()
			lit(true) -- inferred equivalent call
		end)
		textButton.SelectionLost:Connect(function()
			lit(false) -- inferred equivalent call
		end)
		textButton.Activated:Connect(function()
			self.openProfile(userId, p, { userId = userId, display = display, name = name })
		end)
		return textButton
	end

	local searchNote = nil
	local flag2 = false
	local count2 = 0
	local fn

	local function candidates(p)
		local v12 = {}
		local set = {}
		local function add(userId, value, name)
			if type(userId) ~= "number" or userId <= 0 or set[userId] or userId == localPlayer.UserId then
				return
			end

			local v13 = string.lower(value or "")
			local v14 = string.lower(name or "")

			if p == "" or string.find(v13, p, 1, true) or string.find(v14, p, 1, true) then
				set[userId] = true
				table.insert(v12, {
					userId = userId,
					display = value or name,
					name = name
				})
			end
		end

		for _, v13 in v8 do
			local v14 = v7[v13]

			if v14 then
				add(v13, v14.display, v14.name)
			end
		end

		if p == "" then
			return v12, true
		end

		for _, v13 in Players:GetPlayers() do
			add(v13.UserId, v13.DisplayName, v13.Name)
		end

		for _, v13 in self.profile and self.profile.history or {} do
			local black = v13.color == 1 and v13.black or v13.white

			if type(black) ~= "table" then
				continue
			end

			local v14 = v7[black.u]
			add(black.u, black.n, v14 and v14.name)
		end

		for k, v13 in v7 do
			add(k, v13.display, v13.name)
		end

		return v12, false
	end

	local function dropRow(layoutOrder)
		local textButton = UI.new("TextButton", {
			Name = "Row",
			Text = "",
			Size = UDim2.new(1, 0, 0, 44),
			BackgroundColor3 = Theme.panelHeader,
			LayoutOrder = layoutOrder,
			Parent = frame4
		}, { UI.corner(6) })
		textButton:SetAttribute("Sfx", "press")
		UI.hover(textButton, nil, { BackgroundColor3 = Theme.rowActive }, {
			BackgroundColor3 = Theme.panelHeader
		})
		return textButton
	end

	local function pick(data)
		count2 += 1
		searchNote = nil
		textBox.Text = ""

		if textBox:IsFocused() then
			textBox:ReleaseFocus()
		end

		frame4.Visible = false
		self.openProfile(data.userId, nil, {
			userId = data.userId,
			display = data.display,
			name = data.name
		})
	end

	local function playerRow(count3, data)
		local parent4 = dropRow(count3)
		UI.avatar({ userId = data.userId }, 30, {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 7, 0.5, 0),
			Parent = parent4
		})

		UI.text({
			Name = "Display",
			Text = data.display or data.name or "Player",
			FontFace = Theme.fontBold,
			TextSize = 15,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Size = UDim2.new(1, -52, 0, 18),
			Position = UDim2.fromOffset(46, data.name and 5 or 13),
			Parent = parent4
		})

		if data.name then
			UI.text({
				Name = "User",
				Text = "@" .. data.name,
				TextSize = 12,
				TextColor3 = Theme.textDim,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Size = UDim2.new(1, -52, 0, 14),
				Position = UDim2.fromOffset(46, 24),
				Parent = parent4
			})
		end

		parent4.Activated:Connect(function()
			pick(data)
		end)
	end

	local function infoRow(count3, p, text2, onActivated)
		local parent4

		if onActivated then
			parent4 = dropRow(count3)
			parent4.Activated:Connect(onActivated)
		else
			parent4 = UI.new("Frame", {
				Name = "Note",
				Size = UDim2.new(1, 0, 0, 40),
				BackgroundTransparency = 1,
				LayoutOrder = count3,
				Parent = frame4
			})
		end

		UI.icon(p, 18, Theme.textDim, {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 13, 0.5, 0),
			Parent = parent4
		})

		UI.text({
			Name = "Text",
			Text = text2,
			TextSize = 14,
			TextColor3 = onActivated and Theme.textSoft or Theme.textDim,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Size = UDim2.new(1, -52, 1, 0),
			Position = UDim2.fromOffset(46, 0),
			Parent = parent4
		})

		return parent4
	end

	local function refreshDrop()
		for _, guiObject in frame4:GetChildren() do
			if guiObject:IsA("GuiObject") then
				guiObject:Destroy()
			end
		end

		local v12 = cleaned(textBox.Text) -- inferred equivalent call
		local isFocused = textBox:IsFocused()
		local count3 = 0

		if isFocused then
			local v13, v14 = candidates(string.lower(v12))

			if v14 and #v13 > 0 then
				count3 += 1
				UI.new("TextLabel", {
					Name = "Label",
					Text = "Recent",
					FontFace = Theme.fontBold,
					TextSize = 12,
					TextColor3 = Theme.textMuted,
					TextXAlignment = Enum.TextXAlignment.Left,
					Size = UDim2.new(1, 0, 0, 20),
					LayoutOrder = count3,
					Parent = frame4
				}, { UI.pad(0, 0, 0, 8) })
			end

			for i = 1, math.min(6, #v13) do
				count3 += 1
				playerRow(count3, v13[i])
			end
		end

		if v12 ~= "" and (isFocused or flag2) then
			count3 += 1

			if flag2 then
				infoRow(count3, "search", "Searching...")
			else
				infoRow(count3, "search", string.format("Search for \"%s\"", v12), function()
					fn(v12)
				end)
			end
		end

		if searchNote then
			count3 += 1
			infoRow(count3, "info", searchNote)
		end

		frame4.Visible = count3 > 0 and frame.Visible
	end

	fn = function(value)
		local name = cleaned(value) -- inferred equivalent call

		if name == "" or flag2 then
			return
		end

		local v12 = string.lower(name)

		for _, v13 in Players:GetPlayers() do
			if string.lower(v13.Name) == v12 then
				pick({ userId = v13.UserId, display = v13.DisplayName, name = v13.Name })
				return
			end
		end

		for k, v13 in v7 do
			if v13.name and string.lower(v13.name) == v12 then
				pick({ userId = k, display = v13.display, name = v13.name })
				return
			end
		end

		if #name < 3 or #name > 20 or not string.match(name, "^[%w_]+$") then
			searchNote = "Usernames are 3 to 20 letters, numbers or _."
			refreshDrop()
		else
			flag2 = true
			searchNote = nil
			refreshDrop()
			count2 += 1
			local v13 = count2
			local current = pages.current
			task.spawn(function()
				local request = self.request({ type = "findPlayer", name = name })
				flag2 = false

				if v13 ~= count2 or not frame.Visible or pages.current ~= current then
					refreshDrop()
					return
				end

				if type(request) == "table" and request.ok and type(request.userId) == "number" then
					pick({ userId = request.userId })
					return
				end

				local reason = type(request) == "table" and request.reason or "error"
				local v14 = reason == "notfound" and string.format("No player called \"%s\".", name)
					or v3[reason]
					or "Search isn't working right now. Try again soon."
				searchNote = v14
				refreshDrop()
				task.delay(5, function()
					if searchNote == v14 and not textBox:IsFocused() then
						searchNote = nil
						refreshDrop()
					end
				end)
			end)
		end
	end

	textBox.Focused:Connect(function()
		searchNote = nil
		UI.to(stroke, UI.FAST, { Transparency = 0.2 })
		refreshDrop()
	end)
	textBox:GetPropertyChangedSignal("Text"):Connect(function()
		if textBox:IsFocused() then
			count2 += 1
			searchNote = nil
			refreshDrop()
		end
	end)
	textBox.FocusLost:Connect(function(p)
		UI.to(stroke, UI.SNAP, { Transparency = 1 })

		if not p then
			task.delay(0.35, function()
				if not textBox:IsFocused() then
					refreshDrop()
				end
			end)

			return
		end

		fn(textBox.Text)
		refreshDrop()
	end)

	local refreshAll = pages.refreshAll
	function pages.refreshAll()
		refreshAll()

		if pages.current == "stats" then
			stats.refresh()
		end
	end

	local saveSettings = self.saveSettings
	function self.saveSettings(...)
		saveSettings(...)
		layout.updateNotice()
	end
	local function hook(player) -- 1 equivalent call inferred from this helper
		remember(player.UserId, player.DisplayName, player.Name)
		player:GetAttributeChangedSignal("Status"):Connect(function()
			for _, v12 in { stats, profile } do
				if v12.layout.view and v12.layout.view.userId == player.UserId and v12.frame.Visible then
					v12.layout.refreshStatus()
				end
			end
		end)
	end

	for _, v12 in Players:GetPlayers() do
		hook(v12) -- inferred equivalent call
	end

	Players.PlayerAdded:Connect(hook)
	Players.PlayerRemoving:Connect(function()
		task.defer(function()
			if profile.frame.Visible then
				layout2.refreshStatus()
			end
		end)
	end)

	function Profile.debug(data)
		if data.suggest then
			local v12 = candidates(string.lower(cleaned(data.suggest))) -- inferred equivalent call
			local v13 = {}

			for _, v14 in v12 do
				table.insert(v13, tostring(v14.display) .. " @" .. tostring(v14.name) .. " #" .. tostring(v14.userId))
			end

			return { suggestions = table.concat(v13, ", ") }
		else
			if data.search then
				textBox.Text = data.search
				fn(data.search)
				local lastTime = os.clock()

				while flag2 and os.clock() - lastTime < 6 do
					task.wait(0.1)
				end
			elseif data.userId then
				if data.fresh then
					v6[data.userId] = nil
				end

				self.openProfile(data.userId, data.from, data.hint)
			elseif data.me then
				pages.show("stats")
			end

			local lastTime = os.clock()

			while os.clock() - lastTime < 6 and (profile.loading or flag) do
				task.wait(0.1)
			end

			task.wait(0.15)
			local v12 = pages.current == "stats" and stats or profile
			local state = v12.layout.state()
			state.page = pages.current
			state.backTo = pages.current and pages.backTo[pages.current]
			state.wide = frame.Visible
				and string.format(
					"%s %dx%d",
					tostring(frame:GetAttribute("Mode")),
					math.floor(frame.AbsoluteSize.X),
					(math.floor(frame.AbsoluteSize.Y))
				)
				or "hidden"

			state.columns = v12.layout.two and 2 or 1
			state.searchNote = searchNote
			state.boardVisible = self.board.frame.Visible
			return state
		end
	end

	Profile.App = self
end

return Profile