local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")

local Config = require(ReplicatedStorage.Chess.Config)
local parent = script.Parent
local Theme = require(parent.Theme)
local UI = require(parent.UI)
local MoveList = require(parent.MoveList)

local v = {
	checkmate = "by checkmate",
	resignation = "by resignation",
	timeout = "on time",
	abandoned = "by abandonment",
	stalemate = "by stalemate",
	insufficient = "by insufficient material",
	repetition = "by repetition",
	fifty = "by 50-move rule",
	agreement = "by agreement",
	aborted = "",
	timeout_insufficient = "timeout vs insufficient material",
	abandoned_insufficient = "abandonment vs insufficient material"
}
local Pages = {}
Pages.REASON_TEXT = v

local function timeAgo(t) -- 1 equivalent call inferred from this helper
	local v2 = os.time() - (t or 0)

	if v2 < 60 then
		return "just now"
	end

	if v2 < 3600 then
		return tostring(v2 // 60) .. "m ago"
	end

	if v2 < 86400 then
		return tostring(v2 // 3600) .. "h ago"
	end

	return tostring(v2 // 86400) .. "d ago"
end

local function sectionLabel(text, layoutOrder, parent2)
	return UI.text({
		Text = text,
		FontFace = Theme.fontBold,
		TextSize = 14,
		TextColor3 = Theme.textDim,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 20),
		LayoutOrder = layoutOrder,
		Parent = parent2
	})
end

function Pages:build()
	local panel = self.panel

	local frame = UI.new("Frame", {
		Name = "Header",
		Size = UDim2.new(1, 0, 0, 56),
		BackgroundColor3 = Theme.panelHeader,
		BackgroundTransparency = 1,
		Parent = panel
	})

	UI.new("Frame", {
		Name = "Divider",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 12, 1, 0),
		Size = UDim2.new(1, -24, 0, 1),
		BackgroundColor3 = Theme.divider,
		Parent = frame
	})

	local imageButton = UI.new("ImageButton", {
		Name = "Back",
		Size = UDim2.fromOffset(40, 40),
		Position = UDim2.new(0, 8, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		Parent = frame
	}, { UI.corner(6) })
	UI.icon("back", 24, Theme.textDim, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Parent = imageButton
	})

	local frame2 = UI.new("Frame", {
		Name = "Title",
		Size = UDim2.new(1, -110, 1, 0),
		Position = UDim2.fromOffset(16, 0),
		BackgroundTransparency = 1,
		Parent = frame
	}, { UI.list(Enum.FillDirection.Horizontal, 10, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center) })
	local icon = UI.icon("pawn", 26, Theme.green, { LayoutOrder = 1, Parent = frame2 })
	local text = UI.text({
		Text = "Play Chess",
		FontFace = Theme.fontHeavy,
		TextSize = 22,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromScale(0, 1),
		LayoutOrder = 2,
		Parent = frame2
	})

	local imageButton2 = UI.new("ImageButton", {
		Name = "Settings",
		Size = UDim2.fromOffset(40, 40),
		Position = UDim2.new(1, -8, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 1,
		Parent = frame
	}, { UI.corner(6) })
	UI.icon("settings", 24, Theme.textDim, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Parent = imageButton2
	})

	imageButton2.Activated:Connect(function()
		self.modals.settings()
	end)

	local frame3 = UI.new("Frame", {
		Name = "Tabs",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = frame
	}, {
		UI.pad(8, 8, 8, 8),
		UI.list(Enum.FillDirection.Horizontal, 6, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)
	})

	local v2 = {}
	local v3 = { current = nil }

	for k, v4 in {
		{ id = "game", label = "Game", icon = "pawn" },
		{ id = "home", label = "New", icon = "add" },
		{ id = "players", label = "Players", icon = "group" }
	} do
		local textButton = UI.new("TextButton", {
			Name = v4.label,
			Size = UDim2.fromScale(0.25, 1),
			BackgroundColor3 = Theme.selBg,
			BackgroundTransparency = 1,
			LayoutOrder = k,
			Parent = frame3
		}, { UI.corner(UDim.new(1, 0)) })
		local icon2 = UI.icon(v4.icon, 17, Theme.textDim, {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 12, 0.5, 0),
			Parent = textButton
		})

		local text2 = UI.text({
			Text = v4.label,
			FontFace = Theme.fontBold,
			TextSize = 14,
			TextColor3 = Theme.textDim,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Size = UDim2.new(1, -38, 1, 0),
			Position = UDim2.fromOffset(34, 0),
			Parent = textButton
		})

		v2[v4.id] = { button = textButton, icon = icon2, label = text2 }
		textButton.MouseEnter:Connect(function()
			if v3.current ~= v4.id then
				UI.tween(text2, UI.FAST, { TextColor3 = Theme.textSoft })
				UI.tween(icon2, UI.FAST, { ImageColor3 = Theme.textSoft })
			end
		end)
		textButton.MouseLeave:Connect(function()
			if v3.current ~= v4.id then
				UI.tween(text2, UI.SNAP, { TextColor3 = Theme.textDim })
				UI.tween(icon2, UI.SNAP, { ImageColor3 = Theme.textDim })
			end
		end)
		textButton.Activated:Connect(function()
			if
				v4.id == "home"
				and not self.inLiveGame()
				and self.session
				and self.session.kind ~= "online"
				and self.session.kind ~= "idle"
			then
				self.goHome()
			else
				v3.show(v4.id)
			end
		end)
	end

	local v4 = { home = true, game = true, players = true }

	for _, v5 in { imageButton, imageButton2 } do
		v5.BackgroundColor3 = Theme.panelLight
		UI.hover(v5, nil, { BackgroundTransparency = 0 }, { BackgroundTransparency = 1 })
	end

	local frame4 = UI.new("Frame", {
		Name = "Body",
		Size = UDim2.new(1, 0, 1, -56),
		Position = UDim2.fromOffset(0, 56),
		BackgroundTransparency = 1,
		Parent = panel
	})

	local function newPage(name) -- 3 equivalent calls inferred from this helper
		return (UI.new("Frame", {
			Name = name,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Visible = false,
			Parent = frame4
		}))
	end

	local function scrollPage(name)
		local parent2 = newPage(name) -- inferred equivalent call
		local scroll = UI.scroll({ Size = UDim2.fromScale(1, 1), Parent = parent2 })
		local list = UI.list(Enum.FillDirection.Vertical, 12)
		list.Parent = scroll
		local padded = UI.pad(16, 16, 16, 16)
		padded.Parent = scroll
		return parent2, scroll
	end

	local v5 = {
		home = { "Play Chess", "pawn", Theme.green },
		bots = { "Play Bots", "bot", Theme.blueSoft },
		players = { "Challenge a Friend", "group", Theme.blueSoft },
		leaderboard = { "Leaderboard", "trophy", Theme.gold },
		history = { "Game History", "history", Theme.textSoft },
		game = { "Game", "pawn", Theme.green },
		watch = { "Watch Live Games", "eye", Theme.blueSoft }
	}

	function v3.newPage(name, p, p2, p3, p4)
		v5[name] = { p, p2, p3 }

		if p4 then
			return scrollPage(name)
		end

		return newPage(name) -- inferred equivalent call
	end

	local v6 = {
		bots = true,
		players = true,
		puzzles = true,
		rush = true,
		analysis = true,
		leaderboard = true,
		history = true,
		stats = true,
		learn = true
	}

	local set = {}

	function v3.show(p)
		local v7 = v3.current ~= p

		if v6[p] and not set[p] then
			set[p] = true
			self.send({ type = "fx", ev = "page", name = p })
		end

		for k, v8 in v3 do
			if not (type(v8) == "table" and v8.frame) then
				continue
			end

			if k == p then
				if v7 and v3.current ~= nil then
					v8.frame.Visible = false
					UI.reveal(v8.frame, true, 14, 0.2)
				else
					v8.frame.Visible = true
				end
			else
				UI.reveal(v8.frame, false)
			end
		end

		local session = self.session
		local v8 = self.inLiveGame and self.inLiveGame()

		if not v8 then
			if session == nil or session.kind ~= "rush" or session.pz == nil or session.pz.run == nil then
				v8 = false
			else
				v8 = session.pz.run.reason == nil
			end
		end

		if v8 then
			v3.docked = p
		elseif v7 then
			local v9 = p == "profile" or p == "stats" or self.FULL_PAGES and self.FULL_PAGES[p]
			local docked

			if not (v3.docked == nil or not (v9 and p)) then
				docked = p
			end

			v3.docked = docked
		end

		v3.current = p

		if self.refreshFull then
			self.refreshFull()
		end

		if v7 then
			UI.textIn(text, 0.12)
		end

		local v9 = v5[p] or v5.home
		text.Text = v9[1]
		local Sprites = require(ReplicatedStorage.Chess.Sprites)
		Sprites.apply(icon, v9[2])
		icon.ImageColor3 = v9[3]
		v3.refreshHeader()
		local v10 = v3[p]

		if v10 and v10.onShow then
			v10.onShow()
		end

		if self.nav then
			self.nav.refresh()
		end
	end

	function v3.refreshHeader()
		local current = v3.current
		local session = self.session
		local visible

		if session == nil then
			visible = false
		else
			visible = session.kind == "online"
		end

		local v7

		if current == "history" and v3.history ~= nil then
			v7 = v3.history.target ~= nil
		else
			v7 = false
		end

		local visible2

		if v4[current] == true then
			if current == "game" and not visible then
				visible2 = visible
			else
				visible2 = not v7
			end
		else
			visible2 = false
		end

		frame3.Visible = visible2
		frame2.Visible = not visible2

		local v8 = self.nav and self.nav.width > 0
		imageButton2.Visible = not v8

		if visible2 then
			imageButton.Visible = false
			v2.game.button.Visible = visible
			v2.home.button.Visible = not visible

			local v9 = imageButton2.Visible and 52 or 0
			frame3.Size = UDim2.new(1, -v9, 1, 0)

			for k, v10 in v2 do
				local v11 = k == current
				v10.button.Size = UDim2.new(0.5, -3, 1, 0)

				UI.tween(v10.button, UI.SNAP, {
					BackgroundTransparency = v11 and 0 or 1,
					BackgroundColor3 = Theme.selBg
				})
				UI.selected(v10.button, v11)
				UI.tween(v10.label, UI.SNAP, {
					TextColor3 = v11 and Theme.selText or Theme.textDim
				})
				UI.tween(v10.icon, UI.SNAP, {
					ImageColor3 = v11 and Theme.selIcon or Theme.textDim
				})
				UI.ink(v10.label, v11)
			end

			frame.BackgroundColor3 = Theme.panelHeader
		else
			frame.BackgroundColor3 = Theme.panelHeader

			local visible3 = current ~= "home" and not self.inLiveGame() and not v8

			if not visible3 then
				if
					current == "profile" and v3.backTo.profile ~= nil
					or current == "gift" and v3.backTo.gift == "profile"
				then
					visible3 = true
				elseif current == "history" and v3.history ~= nil then
					visible3 = v3.history.target ~= nil
				else
					visible3 = false
				end
			end

			imageButton.Visible = visible3
			frame2.Position = UDim2.fromOffset(visible3 and 54 or 16, 0)

			if current == "game" then
				local session2 = self.session

				if session2 and session2.kind == "bot" then
					text.Text = "vs " .. (Config.BOT_BY_ID[session2.bot] and Config.BOT_BY_ID[session2.bot].name or "Bot")
				elseif session2 and session2.kind == "review" then
					text.Text = "Game Breakdown"
				elseif session2 and session2.kind == "watch" then
					text.Text = "Watching" .. (session2.tc and " · " .. session2.tc.label or "")
				elseif session2 and session2.tc then
					text.Text = session2.tc.label .. (session2.rated and " · Rated" or " · Casual")
				end
			end
		end
	end

	v3.backTo = {}
	imageButton.Activated:Connect(function()
		local v7 = v3.backTo[v3.current]

		if not (v7 and v3[v7]) then
			self.goHome()

			return
		end

		if v3.current == "history" and v3.history and v3.history.target and v7 == "profile" then
			v3.nextFrom = v3.history.profileFrom
		end

		v3.show(v7)
	end)

	function v3.onLayout()
		if v3.home and v3.home.onLayout then
			v3.home.onLayout()
		end

		if v3.current then
			v3.refreshHeader()
		end
	end

	local frame28, parent3 = scrollPage("Home")
	local home = { frame = frame28 }
	v3.home = home

	local button = UI.button({
		parent = parent3,
		size = UDim2.new(1, 0, 0, 54),
		style = "secondary",
		icon = "bolt",
		text = "10 min",
		textSize = 19,
		layoutOrder = 1
	})

	UI.icon("down", 26, Theme.textDim, {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Parent = button.face
	})

	button:setVisible(false)
	local frame5 = UI.new("Frame", {
		Name = "TcGrid",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 2,
		Parent = parent3
	}, { UI.list(Enum.FillDirection.Vertical, 8) })
	local new = UI.new
	local v7 = {
		Name = "Speeds",
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = Theme.bgDark,
		LayoutOrder = 0,
		Parent = frame5
	}

	local corner = UI.corner(UDim.new(1, 0))
	local padded = UI.pad(4, 4, 4, 4)
	local list = UI.list(Enum.FillDirection.Horizontal, 4)
	list.HorizontalFlex = Enum.UIFlexAlignment.Fill
	local frame6 = new("Frame", v7, { corner, padded, list })

	local count = #Config.CLASSES
	local v8 = {}
	local framesByClass = {}
	local v9 = {}
	local v10 = {}
	local v11 = false

	for k, class in Config.CLASSES do
		local textButton = UI.new("TextButton", {
			Name = class,
			Size = UDim2.new(1 / count, -math.ceil((count - 1) * 4 / count), 1, 0),
			BackgroundColor3 = Theme.panelLight,
			BackgroundTransparency = 1,
			LayoutOrder = k,
			Parent = frame6
		}, {
			UI.corner(UDim.new(1, 0)),
			UI.list(Enum.FillDirection.Horizontal, 6, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center)
		})
		local icon2 = UI.icon(Config.CLASS_ICON[class], 16, Theme.textDim, {
			LayoutOrder = 1,
			Parent = textButton
		})
		v8[class] = {
			chip = textButton,
			text = UI.text({
				Text = Config.CLASS_LABEL[class],
				FontFace = Theme.fontBold,
				TextSize = 14,
				TextColor3 = Theme.textDim,
				AutomaticSize = Enum.AutomaticSize.X,
				Size = UDim2.fromScale(0, 1),
				LayoutOrder = 2,
				Parent = textButton
			}),
			icon = icon2
		}
		local new2 = UI.new
		local v12 = {
			Size = UDim2.new(1, 0, 0, 48),
			BackgroundTransparency = 1,
			LayoutOrder = k,
			Visible = false,
			Parent = frame5
		}

		local list2 = UI.list(Enum.FillDirection.Horizontal, 8)
		list2.HorizontalFlex = Enum.UIFlexAlignment.Fill
		local frame7 = new2("Frame", v12, { list2 })

		framesByClass[class] = frame7
		local count2 = 0

		for _, v13 in Config.TIME_CONTROLS do
			if v13.class ~= class then
				continue
			end

			count2 += 1

			v9[class] = v9[class] or Config.TC_BY_ID[Config.DEFAULT_TC].class == class and Config.DEFAULT_TC or v13.id
			local textButton2 = UI.new("TextButton", {
				Size = UDim2.new(1 / 3, -4, 1, 0),
				BackgroundColor3 = Theme.button,
				BackgroundTransparency = 0,
				Text = v13.label,
				FontFace = Theme.fontBold,
				TextSize = 16,
				TextColor3 = Theme.textSoft,
				LayoutOrder = count2,
				Parent = frame7
			}, { UI.corner(UDim.new(1, 0)) })
			v10[v13.id] = { cell = textButton2 }
			local v14 = v13
			textButton2.Activated:Connect(function()
				self.selectedTc = v14.id
				v9[class] = v14.id
				home.refresh()

				if self.session and self.session.kind == "idle" then
					self.resetIdle()
				end
			end)
		end

		textButton.Activated:Connect(function()
			local v13 = Config.TC_BY_ID[self.selectedTc]

			if v13 and v13.class == class then
				return
			end

			self.selectedTc = v9[class]
			home.refresh()

			if self.session and self.session.kind == "idle" then
				self.resetIdle()
			end
		end)
	end

	function button.callback()
		v11 = not v11
		home.refresh()
	end

	local button2 = UI.button({
		parent = parent3,
		size = UDim2.new(1, 0, 0, 56),
		style = "primary",
		text = "Find a Match",
		textSize = 20,
		radius = 27,
		icon = "search",
		font = Theme.fontHeavy,
		layoutOrder = 3,
		onClick = function()
			if not self.profile then
				return
			end

			self.startSearch(self.selectedTc)
		end
	})

	local frame7 = UI.new("Frame", {
		Name = "Searching",
		Size = UDim2.new(1, 0, 0, 128),
		BackgroundColor3 = Theme.panelLight,
		Visible = false,
		LayoutOrder = 3,
		Parent = parent3
	}, { UI.corner(14) })
	UI.lift(frame7, 0.12)
	local icon2 = UI.icon("flip", 30, Theme.green, {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 12),
		Parent = frame7
	})

	local text2 = UI.text({
		Text = "Searching for opponent...",
		FontFace = Theme.fontBold,
		TextSize = 16,
		Size = UDim2.new(1, 0, 0, 22),
		Position = UDim2.fromOffset(0, 46),
		Parent = frame7
	})

	local text3 = UI.text({
		Text = "",
		TextSize = 14,
		TextColor3 = Theme.textDim,
		Size = UDim2.new(1, 0, 0, 18),
		Position = UDim2.fromOffset(0, 68),
		Parent = frame7
	})

	local button3 = UI.button({
		parent = frame7,
		size = UDim2.new(0, 120, 0, 30),
		position = UDim2.new(0.5, 0, 1, -8),
		anchor = Vector2.new(0.5, 1),
		style = "ghost",
		text = "Cancel",
		textSize = 15,
		onClick = function()
			self.cancelSearch()
		end
	})

	local frame8 = UI.new("Frame", {
		Name = "Progress",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 4,
		Parent = parent3
	}, { UI.list(Enum.FillDirection.Vertical, 8) })
	home.progress = frame8
	local text4 = UI.text({
		Name = "Rating",
		Text = "",
		RichText = true,
		TextSize = 14,
		TextColor3 = Theme.textDim,
		Size = UDim2.new(1, 0, 0, 18),
		LayoutOrder = 2,
		Parent = frame8
	})

	home.ratingLine = text4

	UI.new("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = Theme.divider,
		LayoutOrder = 5,
		Parent = parent3
	})

	local buttons = {}
	local function menuButton(layoutOrder, icon3, p, text5, subtext, onClick)
		local button4 = UI.button({
			parent = parent3,
			size = UDim2.new(1, 0, 0, 62),
			style = "flat",
			icon = icon3,
			iconSize = 30,
			iconColor = icon3 == "heart" and p or Theme.textSoft,
			text = text5,
			textSize = 18,
			subtext = subtext,
			align = Enum.HorizontalAlignment.Left,
			padX = 14,
			gap = 14,
			layoutOrder = layoutOrder,
			onClick = onClick
		})

		buttons[layoutOrder] = button4
		return button4
	end

	home.tasksButton = menuButton(6, "calendar", Theme.tasks, "Daily Tasks", "Earn tokens every day", function()
		v3.show("tasks")
	end)
	home.tasksDot = UI.new("Frame", {
		Name = "Badge",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(1, -1, 0, 3),
		Size = UDim2.fromOffset(12, 12),
		BackgroundColor3 = Theme.red,
		Visible = false,
		ZIndex = 4,
		Parent = home.tasksButton.icon
	}, { UI.corner(UDim.new(1, 0)), UI.stroke(Theme.panelLight, 2) })
	local v12 = menuButton(7, "crate", Theme.token, "Shop", "Open crates of cosmetics", function()
		v3.show("shop")
	end)

	local Cosmetics = require(ReplicatedStorage.Chess.Cosmetics)
	local v13 = nil

	for _, v14 in Cosmetics.CRATES do
		if not v14.ends or v13 then
			continue
		end

		v13 = v14
	end

	local sublabel = v12 and v12.sublabel

	if v13 and sublabel then
		local textColor3 = sublabel.TextColor3
		task.spawn(function()
			while sublabel.Parent do
				if Cosmetics.crateLive(v13) then
					sublabel.Text = v13.crate .. " · ends in " .. Cosmetics.formatLeft(Cosmetics.crateLeft(v13))
					sublabel.TextColor3 = v13.color

					task.wait(30)
				else
					sublabel.Text = "Open crates of cosmetics"
					sublabel.TextColor3 = textColor3
					break
				end
			end
		end)
	end

	menuButton(8, "grid", Theme.blueSoft, "Inventory", "Boards, pieces, hats and effects", function()
		v3.show("inventory")
	end)

	menuButton(9, "school", Theme.textSoft, "Learn Chess", "Lessons, tactics and checkmate patterns", function()
		if self.openLearn then
			self.openLearn()
		end
	end)
	menuButton(10, "puzzle", Theme.puzzle, "Puzzles", "Solve rated puzzles", function()
		if self.openPuzzles then
			self.openPuzzles()
		end
	end)
	menuButton(11, "bolt", Theme.rush, "Puzzle Sprint", "Solve as many as you can, fast", function()
		if self.openRush then
			self.openRush()
		end
	end)
	menuButton(12, "bot", Theme.blueSoft, "Play Bots", "Challenge a computer opponent", function()
		v3.show("bots")
	end)
	menuButton(13, "group", Theme.blueSoft, "Challenge a Friend", "Friends or anyone online", function()
		v3.show("players")
	end)

	menuButton(14, "eye", Theme.blueSoft, "Watch Live Games", "Spectate games in this server", function()
		v3.show("watch")
	end)
	menuButton(15, "analysis", Theme.green, "Analysis Board", "Explore any position with the engine", function()
		if self.openAnalysis then
			self.openAnalysis(nil, {}, 0)
		end
	end)
	menuButton(16, "trophy", Theme.gold, "Leaderboard", "Top players, wins and playtime", function()
		v3.show("leaderboard")
	end)
	menuButton(17, "history", Theme.textSoft, "Game History", "Break down your recent games", function()
		v3.show("history")
	end)
	menuButton(18, "person", Theme.blueSoft, "Profile", "Your stats, ratings and look", function()
		v3.show("stats")
	end)

	menuButton(19, "heart", Theme.donate, "Donate", "Support RoChess", function()
		v3.show("donate")
	end)

	local text5 = UI.text({
		Text = "",
		TextSize = 13,
		TextColor3 = Theme.textMuted,
		Size = UDim2.new(1, 0, 0, 30),
		LayoutOrder = 21,
		Parent = parent3
	})

	local text6 = UI.text({
		Name = "OnlineStats",
		Text = "",
		RichText = true,
		TextSize = 13,
		FontFace = Theme.fontBold,
		TextColor3 = Theme.textDim,
		Size = UDim2.new(1, 0, 0, 30),
		LayoutOrder = 20,
		Parent = parent3
	})

	local function commas(p) -- 3 equivalent calls inferred from this helper
		return (tostring((math.floor(p))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
	end

	local function refreshStats()
		local chess = ReplicatedStorage.Chess
		local playing = chess:GetAttribute("Playing") or #Players:GetPlayers()
		local gamesTodayShown = chess:GetAttribute("GamesTodayShown") or chess:GetAttribute("GamesToday")
		local text7 = string.format(
			"<font color=\"#2EC4B6\">●</font>  <font color=\"#FFFFFF\">%s</font> online",
			commas(math.max(playing, #Players:GetPlayers())) -- inferred equivalent call
		)

		if gamesTodayShown then
			text7 ..= string.format("   ·   <font color=\"#FFFFFF\">%s</font> games today", commas(gamesTodayShown)) -- inferred equivalent call
		end

		local gamesAllTimeShown = chess:GetAttribute("GamesAllTimeShown") or chess:GetAttribute("GamesAllTime")

		if gamesAllTimeShown then
			text7 ..= string.format(
				"\n<font color=\"#FFFFFF\">%s</font> games played all time",
				commas(gamesAllTimeShown) -- inferred equivalent call
			)
		end

		text6.Text = text7
		text6.Size = UDim2.new(1, 0, 0, gamesAllTimeShown and 50 or 30)
	end
	ReplicatedStorage.Chess:GetAttributeChangedSignal("Playing"):Connect(refreshStats)
	ReplicatedStorage.Chess:GetAttributeChangedSignal("GamesToday"):Connect(refreshStats)
	ReplicatedStorage.Chess:GetAttributeChangedSignal("GamesAllTime"):Connect(refreshStats)
	ReplicatedStorage.Chess:GetAttributeChangedSignal("GamesTodayShown"):Connect(refreshStats)
	ReplicatedStorage.Chess:GetAttributeChangedSignal("GamesAllTimeShown"):Connect(refreshStats)
	refreshStats()

	local new2 = UI.new
	local v14 = {
		Name = "Tiles",
		Size = UDim2.new(1, 0, 0, 96),
		BackgroundTransparency = 1,
		Visible = false,
		LayoutOrder = 6,
		Parent = parent3
	}

	local list2 = UI.list(Enum.FillDirection.Horizontal, 8)
	list2.HorizontalFlex = Enum.UIFlexAlignment.Fill
	local frame9 = new2("Frame", v14, { list2 })

	local function tile(layoutOrder, p, _, p2, onActivated)
		local textButton = UI.new("TextButton", {
			Name = p2,
			Size = UDim2.new(1 / 3, -6, 1, 0),
			BackgroundColor3 = Theme.panelLight,
			BackgroundTransparency = 0,
			LayoutOrder = layoutOrder,
			Parent = frame9
		}, { UI.corner(14) })

		local icon3 = UI.icon(p, 32, Theme.textSoft, {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 16),
			Parent = textButton
		})

		local uiScale = Instance.new("UIScale")
		uiScale.Parent = textButton
		UI.text({
			Text = p2,
			FontFace = Theme.fontBold,
			TextSize = 16,
			Position = UDim2.new(0, 0, 1, -36),
			Size = UDim2.new(1, 0, 0, 22),
			Parent = textButton
		})

		local lift = UI.lift(textButton, 0.14)
		textButton.MouseEnter:Connect(function()
			UI.tween(textButton, UI.FAST, { BackgroundColor3 = Theme.rowActive })
			UI.tween(lift, UI.FAST, { Color = Theme.blueSoft })
			UI.tween(icon3, UI.FAST, { ImageColor3 = Theme.selIcon })
			UI.tween(uiScale, 0.18, { Scale = 1.04 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		end)
		textButton.MouseLeave:Connect(function()
			UI.tween(textButton, UI.SNAP, { BackgroundColor3 = Theme.panelLight })
			UI.tween(lift, UI.SNAP, { Color = Color3.new(1, 1, 1) })
			UI.tween(icon3, UI.SNAP, { ImageColor3 = Theme.textSoft })
			UI.tween(uiScale, UI.SNAP, { Scale = 1 })
		end)
		textButton.MouseButton1Down:Connect(function()
			UI.tween(uiScale, 0.08, { Scale = 0.97 })
		end)
		textButton.MouseButton1Up:Connect(function()
			UI.tween(uiScale, 0.18, { Scale = 1.04 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		end)
		textButton.Activated:Connect(onActivated)
		return textButton, icon3
	end

	local _, parent4 = tile(1, "calendar", Theme.tasks, "Tasks", function()
		v3.show("tasks")
	end)
	home.tasksTileDot = UI.new("Frame", {
		Name = "Badge",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(1, -1, 0, 3),
		Size = UDim2.fromOffset(12, 12),
		BackgroundColor3 = Theme.red,
		Visible = false,
		ZIndex = 4,
		Parent = parent4
	}, { UI.corner(UDim.new(1, 0)), UI.stroke(Theme.panelLight, 2) })
	tile(2, "bot", Theme.blueSoft, "Bots", function()
		v3.show("bots")
	end)
	tile(3, "group", Theme.blueSoft, "Friends", function()
		v3.show("players")
	end)
	function home.onLayout()
		local v15 = self.nav and self.nav.width > 0

		for _, v16 in buttons do
			v16:setVisible(not v15)
		end

		frame9.Visible = v15 == true
	end

	function home.refresh()
		local v15 = Config.TC_BY_ID[self.selectedTc]

		if not v15 then
			self.selectedTc = Config.DEFAULT_TC
			v15 = Config.TC_BY_ID[self.selectedTc]
		end

		button:setText(v15.label)

		for k, v16 in v8 do
			local visible = k == v15.class
			UI.to(v16.chip, UI.SNAP, {
				BackgroundTransparency = visible and 0 or 1
			})
			UI.to(v16.text, UI.SNAP, {
				TextColor3 = visible and Theme.text or Theme.textDim
			})
			UI.to(v16.icon, UI.SNAP, {
				ImageColor3 = visible and Theme.selIcon or Theme.textDim
			})
			framesByClass[k].Visible = visible
		end

		for k, v16 in v10 do
			local v17 = k == self.selectedTc
			UI.to(v16.cell, UI.SNAP, {
				BackgroundColor3 = v17 and Theme.selBg or Theme.unsel,
				TextColor3 = v17 and Theme.selText or Theme.textDim
			})

			UI.selected(v16.cell, v17)
			UI.ink(v16.cell, v17)
		end

		local v16 = self.searching ~= nil
		local joining = self.joining
		local v17 = v16 or joining ~= nil
		button2:setVisible(not v17)
		UI.reveal(frame7, v17, 6)
		button:setEnabled(not v17)
		button3:setVisible(v16)

		if v16 then
			text2.Text = "Searching for opponent..."
			text3.Text = Config.TC_BY_ID[self.searching.tc].label
		elseif joining then
			local v18 = Config.TC_BY_ID[joining.tc]
			local opponentLine = self.opponentLine(joining)

			if joining.phase == "found" then
				text2.Text = "Opponent found!"
				text3.Text = opponentLine == "" and "Joining game..."
					or opponentLine .. "  ·  joining game..."
					or "Joining game..."
			elseif joining.phase == "arrived" then
				text2.Text = "Starting your game..."
				text3.Text = opponentLine .. (v18 and opponentLine ~= "" and "  ·  " .. v18.label or "")
			else
				text2.Text = "Reconnecting to your game..."
				text3.Text = ""
			end
		end

		button2:setEnabled(self.profile ~= nil and not self.inLiveGame())
		button2:setText(self.profile and "Find a Match" or "Loading...")
		refreshStats()

		if self.profile then
			local rating = self.profile.ratings[v15.class]
			text4.Text = string.format(
				"Your %s rating: %d%s",
				Config.CLASS_LABEL[v15.class],
				rating.r,
				rating.prov and "?" or ""
			)
		else
			text4.Text = ""
		end

		text5.Text = self.profile and self.profile.offline and "Studio test data (not saved)" or ""
		text5.Visible = text5.Text ~= ""

		if home.afterRefresh then
			home.afterRefresh()
		end
	end

	function home.onFrame()
		if self.joining and frame7.Visible then
			icon2.Rotation = os.clock() * 300 % 360
		elseif self.searching and frame7.Visible then
			icon2.Rotation = os.clock() * 300 % 360
			local v15 = math.floor(os.clock() - self.searching.since)
			text3.Text = string.format("%s  ·  %d:%02d", Config.TC_BY_ID[self.searching.tc].label, v15 // 60, v15 % 60)

			if v15 >= 20 then
				text2.Text = "Still searching... try a bot?"
			else
				text2.Text = "Searching for opponent..."
			end
		end
	end
	Players.PlayerAdded:Connect(home.refresh)
	Players.PlayerRemoving:Connect(function()
		task.defer(home.refresh)
	end)
	ReplicatedStorage.Chess:GetAttributeChangedSignal("GlobalQueue"):Connect(home.refresh)
	home.onShow = home.refresh
	home.refresh()

	local frame29, parent5 = scrollPage("Bots")
	local bots = { frame = frame29 }
	v3.bots = bots

	local frame10 = UI.new("Frame", {
		Name = "Hero",
		Size = UDim2.new(1, 0, 0, 96),
		BackgroundTransparency = 1,
		LayoutOrder = 1,
		Parent = parent5
	})

	local avatar = UI.avatar(nil, 76, { Position = UDim2.fromOffset(0, 10), Parent = frame10 })
	local text7 = UI.text({
		Text = "",
		FontFace = Theme.fontHeavy,
		TextSize = 22,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -90, 0, 26),
		Position = UDim2.fromOffset(90, 6),
		Parent = frame10
	})

	local frame11 = UI.new(
		"Frame",
		{
			Size = UDim2.new(1, -90, 0, 54),
			Position = UDim2.fromOffset(90, 36),
			BackgroundColor3 = Color3.new(1, 1, 1),
			Parent = frame10
		},
		{ UI.corner(8), UI.pad(6, 10, 6, 10) }
	)
	local text8 = UI.text({
		Text = "",
		FontFace = Theme.fontMedium,
		TextSize = 14,
		TextColor3 = Theme.bg,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		Size = UDim2.fromScale(1, 1),
		Parent = frame11
	})

	local frame12 = UI.new("Frame", {
		Name = "Categories",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 2,
		Parent = parent5
	}, { UI.list(Enum.FillDirection.Vertical, 8) })

	local v15 = {}
	local v16 = {}

	for _, v17 in Config.BOTS do
		v15[v17.category] = v15[v17.category] or {}
		table.insert(v15[v17.category], v17)
	end

	for k, v17 in Config.BOT_CATEGORIES do
		local v18 = v15[v17.id] or {}
		local frame13 = UI.new("Frame", {
			Name = v17.name,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Theme.panelLight,
			LayoutOrder = k,
			Parent = frame12
		}, { UI.corner(8), UI.pad(8, 10, 10, 10), UI.list(Enum.FillDirection.Vertical, 6) })
		local frame14 = UI.new("Frame", {
			Size = UDim2.new(1, 0, 0, 22),
			BackgroundTransparency = 1,
			LayoutOrder = 1,
			Parent = frame13
		})

		UI.new(
			"Frame",
			{
				Size = UDim2.fromOffset(4, 16),
				Position = UDim2.new(0, 0, 0.5, -8),
				BackgroundColor3 = v17.color,
				Parent = frame14
			},
			{ UI.corner(2) }
		)
		UI.text({
			Text = v17.name,
			FontFace = Theme.fontBold,
			TextSize = 16,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(12, 0),
			Size = UDim2.new(1, -12, 1, 0),
			Parent = frame14
		})
		local minRating = 1e999
		local maxRating = 0

		for _, v19 in v18 do
			minRating = math.min(minRating, v19.rating)
			maxRating = math.max(maxRating, v19.rating)
		end

		UI.text({
			Text = #v18 > 0 and string.format("%d–%d", minRating, maxRating) or "",
			FontFace = Theme.fontMedium,
			TextSize = 13,
			TextColor3 = Theme.textDim,
			TextXAlignment = Enum.TextXAlignment.Right,
			Size = UDim2.fromScale(1, 1),
			Parent = frame14
		})

		local frame15 = UI.new("Frame", {
			Name = "Grid",
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = 2,
			Parent = frame13
		})

		local uiGridLayout = Instance.new("UIGridLayout")
		uiGridLayout.CellSize = UDim2.new(0.2, -5, 0, 74)
		uiGridLayout.CellPadding = UDim2.fromOffset(6, 4)
		uiGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uiGridLayout.Parent = frame15

		for k2, bot in v18 do
			local textButton = UI.new("TextButton", {
				Name = bot.id,
				BackgroundColor3 = Theme.rowActive,
				BackgroundTransparency = 1,
				LayoutOrder = k2,
				Parent = frame15
			}, { UI.corner(6) })
			local avatar2 = UI.avatar({ bot = bot }, 46, {
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(0.5, 0, 0, 4),
				Parent = textButton
			})

			local stroke = UI.stroke(Theme.green, 3, 1)
			stroke.Parent = avatar2.frame
			UI.text({
				Text = tostring(bot.rating),
				FontFace = Theme.fontBold,
				TextSize = 13,
				TextColor3 = Theme.textDim,
				Size = UDim2.new(1, 0, 0, 18),
				Position = UDim2.new(0, 0, 0, 53),
				Parent = textButton
			})

			v16[bot.id] = { tile = textButton, stroke = stroke, avatar = avatar2.frame }
			local v19 = bot
			local v20 = bot
			UI.hover(textButton, nil, function()
				return {
					BackgroundTransparency = self.selectedBot == v19.id and 0 or 0.6
				}
			end, function()
				return {
					BackgroundTransparency = self.selectedBot == v20.id and 0 or 1
				}
			end)
			local v21 = bot
			textButton.Activated:Connect(function()
				self.selectedBot = v21.id
				bots.refresh()
			end)
		end
	end

	sectionLabel("I play as", 3, parent5)
	local segmented = UI.segmented({
		{ id = "white", label = "White" },
		{ id = "random", label = "Random", icon = "shuffle" },
		{ id = "black", label = "Black" }
	}, self.botColor, function(botColor)
		self.botColor = botColor
	end, 42)
	segmented.frame.LayoutOrder = 4
	segmented.frame.Parent = parent5

	local text9 = UI.text({
		Text = "",
		TextSize = 14,
		TextColor3 = Theme.textDim,
		Size = UDim2.new(1, 0, 0, 18),
		LayoutOrder = 5,
		Parent = parent5
	})

	UI.button({
		parent = parent5,
		size = UDim2.new(1, 0, 0, 62),
		style = "primary",
		text = "Play",
		textSize = 26,
		font = Theme.fontHeavy,
		layoutOrder = 6,
		onClick = function()
			self.startBotGame(self.selectedBot, self.botColor)
		end
	})

	function bots.refresh()
		local bot = Config.BOT_BY_ID[self.selectedBot] or Config.BOTS[1]
		avatar.set({ bot = bot })
		text7.Text = bot.name .. "  " .. tostring(bot.rating)
		text8.Text = bot.bio

		for k, v17 in v16 do
			local on2 = k == bot.id
			local on = v17.on
			v17.on = on2
			UI.to(v17.stroke, UI.SNAP, {
				Transparency = on2 and 0 or 1
			})
			UI.to(v17.tile, UI.SNAP, {
				BackgroundTransparency = on2 and 0 or 1
			})

			if on2 and on == false then
				UI.pop(v17.avatar, 0.85, 0.18)
			end
		end

		if avatar.frame then
			UI.pop(avatar.frame, 0.9, 0.18)
		end

		UI.textIn(text7, 0.12)
		UI.textIn(text8, 0.16)
		local v17 = self.profile and self.profile.bots and self.profile.bots[bot.id]

		if v17 then
			text9.Text = string.format("Your record vs %s:  %d W  ·  %d L  ·  %d D", bot.name, v17.w, v17.l, v17.d)
		else
			text9.Text = "You haven't played " .. bot.name .. " yet"
		end

		if bot.rating >= 1600 then
			text9.Text ..= "   ·   Powered by Vortex"
		end

		segmented.set(self.botColor)
	end
	bots.onShow = bots.refresh
	bots.refresh()

	local frame30, parent6 = scrollPage("Players")
	local players = { frame = frame30 }
	v3.players = players
	local class = Config.TC_BY_ID[self.selectedTc].class

	local frame13 = UI.new("Frame", {
		Name = "Pending",
		Size = UDim2.new(1, 0, 0, 48),
		BackgroundColor3 = Theme.panelLight,
		Visible = false,
		LayoutOrder = 0,
		Parent = parent6
	}, { UI.corner(6) })
	local text10 = UI.text({
		Text = "",
		FontFace = Theme.fontMedium,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -110, 1, 0),
		Position = UDim2.fromOffset(12, 0),
		Parent = frame13
	})

	UI.button({
		parent = frame13,
		size = UDim2.fromOffset(90, 34),
		position = UDim2.new(1, -8, 0.5, 0),
		anchor = Vector2.new(1, 0.5),
		style = "secondary",
		text = "Cancel",
		textSize = 15,
		onClick = function()
			if self.pendingChallenge then
				self.send({ type = "cancelChallenge", id = self.pendingChallenge.id })
				self.pendingChallenge = nil
				players.refresh()
			end
		end
	})

	local frame14 = UI.new("Frame", {
		Name = "List",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 2,
		Parent = parent6
	}, { UI.list(Enum.FillDirection.Vertical, 6) })
	local text11 = UI.text({
		Text = "Nobody else is in this server yet.\nInvite a friend or challenge someone above!",
		TextSize = 15,
		TextColor3 = Theme.textDim,
		TextWrapped = true,
		Size = UDim2.new(1, 0, 0, 60),
		LayoutOrder = 3,
		Parent = parent6
	})

	local SocialService = game:GetService("SocialService")
	local frame15 = UI.new("Frame", {
		Name = "Invite",
		Size = UDim2.new(1, 0, 0, 64),
		BackgroundColor3 = Theme.panelLight,
		Visible = false,
		LayoutOrder = -8,
		Parent = parent6
	}, { UI.corner(6) })
	UI.lift(frame15)
	UI.icon("handshake", 28, Theme.gold, {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 14, 0.5, 0),
		Parent = frame15
	})

	UI.text({
		Text = "Invite a friend",
		FontFace = Theme.fontBold,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Size = UDim2.new(1, -190, 0, 20),
		Position = UDim2.fromOffset(54, 12),
		Parent = frame15
	})

	UI.text({
		Text = "Play chess together.",
		TextSize = 13,
		TextColor3 = Theme.textDim,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Size = UDim2.new(1, -190, 0, 16),
		Position = UDim2.fromOffset(54, 34),
		Parent = frame15
	})

	local function invite()
		local success, result = pcall(function()
			local experienceInviteOptions = Instance.new("ExperienceInviteOptions")
			experienceInviteOptions.PromptMessage = "Invite friends to play chess with you"
			SocialService:PromptGameInvite(Players.LocalPlayer, experienceInviteOptions)
		end)

		if not success then
			warn("[Chess] invite prompt: " .. tostring(result))
			self.toast("Couldn't open the invite window. Try again soon.")
		end
	end
	UI.button({
		parent = frame15,
		name = "InviteButton",
		size = UDim2.fromOffset(112, 40),
		position = UDim2.new(1, -12, 0.5, 0),
		anchor = Vector2.new(1, 0.5),
		style = "secondary",
		text = "Invite",
		textSize = 15,
		onClick = invite
	})

	local textButton = UI.new("TextButton", {
		Name = "Hit",
		Text = "",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -130, 1, 0),
		Parent = frame15
	})

	textButton:SetAttribute("Sfx", "press")
	textButton.Activated:Connect(invite)
	SocialService.GameInvitePromptClosed:Connect(function(_, list3)
		if type(list3) == "table" and #list3 > 0 then
			self.toast(#list3 == 1 and "Invite sent!" or #list3 .. " invites sent!", Theme.green)
		end
	end)
	task.spawn(function()
		local success, result = pcall(function()
			return SocialService:CanSendGameInviteAsync(Players.LocalPlayer)
		end)

		frame15.Visible = success and result == true
	end)

	sectionLabel("Challenge anyone online", -6, parent6)
	local frame16 = UI.new("Frame", {
		Name = "ChallengeByName",
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundTransparency = 1,
		LayoutOrder = -5,
		Parent = parent6
	})

	local frame17 = UI.new(
		"Frame",
		{ Size = UDim2.new(1, -132, 1, 0), BackgroundColor3 = Theme.panelLight, Parent = frame16 },
		{ UI.corner(UDim.new(1, 0)) }
	)
	UI.lift(frame17)
	UI.icon("search", 18, Theme.textDim, {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 14, 0.5, 0),
		Parent = frame17
	})

	local textBox = UI.new("TextBox", {
		Name = "Box",
		Text = "",
		PlaceholderText = "Username",
		PlaceholderColor3 = Theme.textMuted,
		ClearTextOnFocus = false,
		FontFace = Theme.fontMedium,
		TextSize = 15,
		TextColor3 = Theme.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Size = UDim2.new(1, -50, 1, 0),
		Position = UDim2.fromOffset(40, 0),
		Parent = frame17
	})

	local text12 = UI.text({
		Name = "SearchNote",
		Text = "",
		TextSize = 13,
		TextColor3 = Theme.textDim,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Visible = false,
		LayoutOrder = -4,
		Parent = parent6
	})

	local v17 = {
		invalid = "Usernames are 3 to 20 letters, numbers or _.",
		notfound = "No player with that username.",
		busy = "Too many searches. Try again in a few seconds.",
		error = "Search isn't working right now. Try again soon."
	}

	local flag = false
	local function note(value) -- 4 equivalent calls inferred from this helper
		text12.Text = value or ""
		text12.Visible = value ~= nil
	end
	local function challengeByName()
		if flag then
			return
		end

		local v18 = string.gsub(string.gsub(textBox.Text, "^%s+", ""), "%s+$", "")
		local v19 = string.gsub(v18, "^@", "")

		if v19 == "" then
			text12.Text = "Type a username to challenge them, wherever they are."
			text12.Visible = true
		else
			if self.inLiveGame() then
				self.toast("Finish your current game first")
				return
			end

			local v20 = string.lower(v19)

			for _, v21 in Players:GetPlayers() do
				if string.lower(v21.Name) == v20 or string.lower(v21.DisplayName) == v20 then
					if v21 == Players.LocalPlayer then
						text12.Text = "That's you!"
						text12.Visible = true
					else
						note() -- inferred equivalent call
						self.modals.challenge(v21)
					end

					return
				end
			end

			flag = true
			note("Looking for " .. v19 .. "...") -- inferred equivalent call
			local request = self.request({ type = "findPlayer", name = v19 })
			flag = false

			if type(request) == "table" and request.ok and type(request.userId) == "number" then
				if request.userId == Players.LocalPlayer.UserId then
					text12.Text = "That's you!"
					text12.Visible = true
				else
					note() -- inferred equivalent call
					self.modals.challenge({ UserId = request.userId, DisplayName = v19, Name = v19 })
				end
			else
				note(v17[type(request) == "table" and request.reason or "error"] or "Search isn't working right now. Try again soon.") -- inferred equivalent call
			end
		end
	end
	UI.button({
		parent = frame16,
		name = "Go",
		size = UDim2.new(0, 124, 1, 0),
		position = UDim2.fromScale(1, 0),
		anchor = Vector2.new(1, 0),
		style = "primary",
		icon = "swords",
		iconSize = 18,
		text = "Challenge",
		textSize = 15,
		gap = 4,
		padX = 6,
		onClick = function()
			task.spawn(challengeByName)
		end
	})

	textBox.FocusLost:Connect(function(p)
		if p then
			task.spawn(challengeByName)
		end
	end)

	local v18 = sectionLabel("Friends playing RoChess", -3, parent6)
	v18.Visible = false
	local frame18 = UI.new("Frame", {
		Name = "Friends",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Visible = false,
		LayoutOrder = -2,
		Parent = parent6
	}, { UI.list(Enum.FillDirection.Vertical, 6) })
	local v19 = sectionLabel("In this server", 1, parent6)
	local v20 = {}
	local lastTime = -1e999
	local v21 = false

	local function drawFriends()
		for _, frame19 in frame18:GetChildren() do
			if frame19:IsA("Frame") then
				frame19:Destroy()
			end
		end

		local count2 = 0

		for _, v22 in v20 do
			if Players:GetPlayerByUserId(v22.userId) then
				continue
			end

			count2 += 1
			local frame19 = UI.new("Frame", {
				Name = v22.name,
				Size = UDim2.new(1, 0, 0, 56),
				BackgroundColor3 = Theme.panelLight,
				LayoutOrder = count2,
				Parent = frame18
			}, { UI.corner(6) })
			UI.avatar({ userId = v22.userId }, 40, {
				Position = UDim2.new(0, 8, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				Parent = frame19
			})

			UI.text({
				Text = v22.display,
				FontFace = Theme.fontBold,
				TextSize = 16,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Size = UDim2.new(1, -170, 0, 22),
				Position = UDim2.fromOffset(58, 8),
				Parent = frame19
			})

			UI.new(
				"Frame",
				{
					Size = UDim2.fromOffset(8, 8),
					Position = UDim2.fromOffset(58, 36),
					BackgroundColor3 = Theme.green,
					Parent = frame19
				},
				{ UI.corner(UDim.new(1, 0)) }
			)
			UI.text({
				Text = "Friend · another server",
				TextSize = 13,
				TextColor3 = Theme.textDim,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, -170, 0, 16),
				Position = UDim2.fromOffset(72, 32),
				Parent = frame19
			})

			UI.button({
				parent = frame19,
				size = UDim2.fromOffset(104, 38),
				position = UDim2.new(1, -8, 0.5, 0),
				anchor = Vector2.new(1, 0.5),
				style = "primary",
				icon = "swords",
				iconSize = 18,
				text = "Challenge",
				textSize = 14,
				gap = 4,
				padX = 6,
				onClick = function()
					self.modals.challenge({
						UserId = v22.userId,
						DisplayName = v22.display,
						Name = v22.name
					})
				end
			}):setEnabled(not self.inLiveGame())

			if self.profileRow then
				self.profileRow(frame19, v22.userId, "players", UDim2.new(1, -120, 1, 0), v22.display, v22.name)
			end
		end

		v18.Visible = count2 > 0
		frame18.Visible = count2 > 0
	end

	local function loadFriends()
		if v21 or os.clock() - lastTime < 30 then
			return
		end

		v21 = true
		local success, result = pcall(function()
			return Players.LocalPlayer:GetFriendsOnline(200)
		end)

		v21 = false
		lastTime = os.clock()

		if not success or type(result) ~= "table" then
			return
		end

		table.clear(v20)

		for _, v22 in result do
			local locationType = v22.LocationType

			if not ((locationType == 1 or locationType == 4 or locationType == 5) and v22.PlaceId == game.PlaceId and type(v22.VisitorId) == "number") then
				continue
			end

			table.insert(v20, {
				userId = v22.VisitorId,
				display = v22.DisplayName or v22.UserName or "Friend",
				name = v22.UserName or ""
			})
		end

		table.sort(v20, function(a, b): boolean
			return string.lower(a.display) < string.lower(b.display)
		end)

		if frame30.Visible then
			drawFriends()
		end
	end
	function players.debugFriends(p)
		v20 = p
		drawFriends()
	end

	local v22 = {
		playing = { "In a game", Theme.loss },
		searching = { "Searching", Theme.gold },
		bot = { "Playing a bot", Theme.blueSoft },
		puzzle = { "Solving puzzles", Theme.puzzle },
		idle = { "Online", Theme.green }
	}

	function players.refresh()
		if not frame30.Visible then
			return
		end

		class = Config.TC_BY_ID[self.selectedTc].class

		for _, frame19 in frame14:GetChildren() do
			if frame19:IsA("Frame") then
				frame19:Destroy()
			end
		end

		local count2 = 0

		for _, v23 in Players:GetPlayers() do
			if v23 == Players.LocalPlayer then
				continue
			end

			count2 += 1
			local frame19 = UI.new(
				"Frame",
				{
					Name = v23.Name,
					Size = UDim2.new(1, 0, 0, 56),
					BackgroundColor3 = Theme.panelLight,
					Parent = frame14
				},
				{ UI.corner(6) }
			)
			UI.avatar({ userId = v23.UserId }, 40, {
				Position = UDim2.new(0, 8, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				Parent = frame19
			})

			local attribute = v23:GetAttribute("R_" .. class)
			UI.text({
				Text = v23.DisplayName .. (attribute and "  (" .. attribute .. (v23:GetAttribute("P_" .. class) and "?" or "") .. ")" or ""),
				FontFace = Theme.fontBold,
				TextSize = 16,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Size = UDim2.new(1, -170, 0, 22),
				Position = UDim2.fromOffset(58, 8),
				Parent = frame19
			})

			local v24 = v22[v23:GetAttribute("Status") or "idle"] or v22.idle
			UI.new(
				"Frame",
				{
					Size = UDim2.fromOffset(8, 8),
					Position = UDim2.fromOffset(58, 36),
					BackgroundColor3 = v24[2],
					Parent = frame19
				},
				{ UI.corner(UDim.new(1, 0)) }
			)
			UI.text({
				Text = v24[1],
				TextSize = 13,
				TextColor3 = Theme.textDim,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, -170, 0, 16),
				Position = UDim2.fromOffset(72, 32),
				Parent = frame19
			})

			local v25 = v23:GetAttribute("Status") == "playing"
			UI.button({
				parent = frame19,
				name = v25 and "Watch" or "Challenge",
				size = UDim2.fromOffset(104, 38),
				position = UDim2.new(1, -8, 0.5, 0),
				anchor = Vector2.new(1, 0.5),
				style = v25 and "secondary" or "primary",
				icon = v25 and "eye" or "swords",
				iconSize = 18,
				text = v25 and "Watch" or "Challenge",
				textSize = 14,
				gap = 4,
				padX = 6,
				onClick = function()
					if v25 then
						task.spawn(self.watch, v23.UserId)
					else
						self.modals.challenge(v23)
					end
				end
			}):setEnabled(not self.inLiveGame())

			if self.profileRow then
				self.profileRow(frame19, v23.UserId, "players", UDim2.new(1, -120, 1, 0), v23.DisplayName, v23.Name)
			end
		end

		text11.Visible = count2 == 0
		v19.Visible = true
		drawFriends()
		task.spawn(loadFriends)
		local pendingChallenge = self.pendingChallenge
		UI.reveal(frame13, pendingChallenge ~= nil)

		if pendingChallenge then
			text10.Text = "Challenge sent to " .. (pendingChallenge.to and pendingChallenge.to.display or "player") .. "..."
		end
	end
	players.onShow = players.refresh
	local function hook(object) -- 2 equivalent calls inferred from this helper
		object:GetAttributeChangedSignal("Status"):Connect(players.refresh)
	end

	for _, v23 in Players:GetPlayers() do
		hook(v23) -- inferred equivalent call
	end

	Players.PlayerAdded:Connect(function(player)
		hook(player) -- inferred equivalent call
		players.refresh()
	end)
	Players.PlayerRemoving:Connect(function()
		task.defer(players.refresh)
	end)

	local frame31, parent7 = scrollPage("Watch")
	local watch = { frame = frame31 }
	v3.watch = watch
	sectionLabel("Live games in this server", 0, parent7)
	local frame19 = UI.new("Frame", {
		Name = "List",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 1,
		Parent = parent7
	}, { UI.list(Enum.FillDirection.Vertical, 6) })
	local text13 = UI.text({
		Text = "",
		TextSize = 15,
		TextColor3 = Theme.textDim,
		TextWrapped = true,
		Size = UDim2.new(1, 0, 0, 60),
		Visible = false,
		LayoutOrder = 2,
		Parent = parent7
	})

	local flag2 = false
	local flag3 = false

	local function nameOf(data) -- 2 equivalent calls inferred from this helper
		if type(data) ~= "table" then
			return "?"
		end

		local v23 = data.rating and " (" .. data.rating .. (data.prov and "?" or "") .. ")" or ""
		return (data.display or data.name or "Player") .. v23
	end

	local function draw(games)
		for _, frame20 in frame19:GetChildren() do
			if frame20:IsA("Frame") then
				frame20:Destroy()
			end
		end

		local v23 = self.inLiveGame()

		for k, item in games do
			local frame20 = UI.new("Frame", {
				Name = "Game" .. k,
				Size = UDim2.new(1, 0, 0, 74),
				BackgroundColor3 = Theme.panelLight,
				LayoutOrder = k,
				Parent = frame19
			}, { UI.corner(6) })
			UI.avatar(item.white, 32, { Position = UDim2.fromOffset(8, 8), Parent = frame20 })

			UI.avatar(item.black, 32, { Position = UDim2.fromOffset(24, 34), Parent = frame20 })

			UI.text({
				Text = nameOf(item.white), -- inferred equivalent call
				FontFace = Theme.fontBold,
				TextSize = 15,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Size = UDim2.new(1, -160, 0, 18),
				Position = UDim2.fromOffset(66, 8),
				Parent = frame20
			})
			UI.text({
				Text = "vs " .. nameOf(item.black), -- inferred equivalent call
				FontFace = Theme.fontBold,
				TextSize = 15,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Size = UDim2.new(1, -160, 0, 18),
				Position = UDim2.fromOffset(66, 28),
				Parent = frame20
			})

			local v24 = Config.TC_BY_ID[item.tc]
			local v25 = {}

			if v24 then
				table.insert(v25, v24.label)
			end

			table.insert(v25, "Move " .. math.floor((tonumber(item.moves) or 0) / 2) + 1)
			local watchers = tonumber(item.watchers) or 0

			if watchers > 0 then
				table.insert(v25, watchers .. " watching")
			end

			table.insert(v25, item.rated and "Rated" or "Casual")
			UI.text({
				Text = table.concat(v25, " · "),
				TextSize = 13,
				TextColor3 = Theme.textDim,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Size = UDim2.new(1, -160, 0, 16),
				Position = UDim2.fromOffset(66, 50),
				Parent = frame20
			})

			UI.button({
				parent = frame20,
				name = "Watch",
				size = UDim2.fromOffset(86, 38),
				position = UDim2.new(1, -8, 0.5, 0),
				anchor = Vector2.new(1, 0.5),
				style = "primary",
				icon = "eye",
				iconSize = 18,
				text = "Watch",
				textSize = 14,
				gap = 4,
				padX = 6,
				onClick = function()
					task.spawn(self.watch, item.target)
				end
			}):setEnabled(not v23)
		end

		text13.Text = "No games being played in this server right now.\nCheck back in a moment!"
		text13.Visible = #games == 0
	end

	function watch.refresh()
		if not frame31.Visible then
			return
		end

		if flag2 then
			flag3 = true
			return
		end

		flag2 = true
		task.spawn(function()
			local request = self.request({ type = "liveGames" })
			flag2 = false

			if type(request) == "table" and request.ok and type(request.games) == "table" then
				draw(request.games)
			elseif #frame19:GetChildren() <= 1 then
				text13.Text = "Couldn't load live games. Try again soon."
				text13.Visible = true
			end

			if flag3 then
				flag3 = false
				task.delay(0.5, watch.refresh)
			end
		end)
	end
	watch.onShow = watch.refresh

	local v23 = false
	local function soon()
		if v23 or not frame31.Visible then
			return
		end

		v23 = true
		task.delay(0.6, function()
			v23 = false
			watch.refresh()
		end)
	end
	local function hook2(object) -- 1 equivalent call inferred from this helper
		object:GetAttributeChangedSignal("Status"):Connect(soon)
	end

	for _, v24 in Players:GetPlayers() do
		hook2(v24) -- inferred equivalent call
	end

	Players.PlayerAdded:Connect(hook2)
	Players.PlayerRemoving:Connect(soon)

	task.spawn(function()
		while true do
			task.wait(8)

			if frame31.Visible then
				watch.refresh()
			end
		end
	end)

	local frame32, parent8 = scrollPage("Leaderboard")

	local leaderboard = {
		frame = frame32,
		class = "blitz",
		ratingClass = "blitz",
		kind = "rating",
		scope = "global"
	}
	v3.leaderboard = leaderboard
	local v24 = nil
	local v25 = {
		{ id = "rating", label = "Rating", icon = "trend" },
		{ id = "wins", label = "Wins", icon = "trophy", iconColor = Theme.gold },
		{ id = "playtime", label = "Playtime", icon = "hourglass" }
	}

	if Config.TOURNAMENTS_ENABLED then
		table.insert(v25, {
			id = "medals",
			label = "Medals",
			icon = "crown",
			iconColor = Theme.gold
		})
	end

	local segmented2 = UI.segmented(v25, leaderboard.kind, function(kind)
		leaderboard.kind = kind
		local class2

		if kind == "rating" then
			class2 = leaderboard.ratingClass or "rating"
		else
			class2 = kind
		end

		leaderboard.class = class2
		v24.frame.Visible = kind == "rating"
		leaderboard.load()
	end, 40)
	segmented2.frame.LayoutOrder = -1
	segmented2.frame.Parent = parent8
	local function fmtPlaytime(rating) -- 1 equivalent call inferred from this helper
		local v26 = rating or 0

		if v26 < 60 then
			return tostring(v26) .. "m"
		end

		local v27 = math.floor(v26 / 60)

		if v27 >= 100 then
			return tostring(v27) .. "h"
		end

		return string.format("%dh %dm", v27, v26 % 60)
	end

	local segmented3 = UI.segmented({
		{ id = "global", label = "Global", icon = "globe" },
		{ id = "server", label = "This server", icon = "group" }
	}, leaderboard.scope, function(scope)
		leaderboard.scope = scope
		leaderboard.load()
	end, 38)
	segmented3.frame.LayoutOrder = 0
	segmented3.frame.Parent = parent8
	v24 = UI.segmented({
		{ id = "bullet", label = "Bullet", icon = "bullet", iconColor = Config.CLASS_COLOR.bullet },
		{ id = "blitz", label = "Blitz", icon = "bolt", iconColor = Config.CLASS_COLOR.blitz },
		{ id = "rapid", label = "Rapid", icon = "timer", iconColor = Config.CLASS_COLOR.rapid },
		{ id = "puzzle", label = "Puzzles", icon = "puzzle", iconColor = Theme.puzzle }
	}, leaderboard.ratingClass, function(p)
		leaderboard.ratingClass = p
		leaderboard.class = p
		leaderboard.load()
	end, 42)
	v24.frame.LayoutOrder = 1
	v24.frame.Parent = parent8
	local text14 = UI.text({
		Text = "",
		TextSize = 13,
		TextColor3 = Theme.textMuted,
		TextWrapped = true,
		Size = UDim2.new(1, 0, 0, 16),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 2,
		Parent = parent8
	})

	local frame20 = UI.new("Frame", {
		Name = "List",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 3,
		Parent = parent8
	}, { UI.list(Enum.FillDirection.Vertical, 2) })
	local count2 = 0
	function leaderboard.load()
		count2 += 1
		local v26 = count2

		for _, frame21 in frame20:GetChildren() do
			if frame21:IsA("Frame") then
				frame21:Destroy()
			end
		end

		text14.Text = "Loading..."
		task.spawn(function()
			local request = self.request({
				type = "leaderboard",
				class = leaderboard.class,
				scope = leaderboard.scope
			})

			if v26 ~= count2 then
				return
			end

			if not request then
				text14.Text = "Couldn't load the leaderboard."
				return
			end

			if leaderboard.scope == "server" then
				local count3 = #request.entries
				text14.Text = count3 == 1 and "1 player in this server" or tostring(count3) .. " players in this server"
			else
				text14.Text = request.isLocal and "Players in this server (global boards appear once published)"
					or "Top players worldwide"

				if #request.entries == 0 then
					if leaderboard.class == "puzzle" then
						text14.Text = "No ranked solvers yet. Solve rated puzzles to appear here!"
					elseif leaderboard.class == "wins" then
						text14.Text = "No winners yet. Win rated games to appear here!"
					elseif leaderboard.class == "playtime" then
						text14.Text = "No playtime recorded yet. Check back soon!"
					elseif leaderboard.class == "medals" then
						text14.Text = "No medals yet. Play the hourly tournament to appear here!"
					else
						text14.Text = "No ranked players yet. Play rated games to appear here!"
					end
				elseif leaderboard.class == "wins" then
					text14.Text = "Most rated wins worldwide"
				elseif leaderboard.class == "playtime" then
					text14.Text = "Most time played worldwide"
				elseif leaderboard.class == "medals" then
					text14.Text = "Most tournament medals worldwide"
				end
			end

			for k, entry in request.entries do
				local v27 = entry.userId == Players.LocalPlayer.UserId
				local frame21 = UI.new("Frame", {
					Size = UDim2.new(1, 0, 0, 44),
					BackgroundColor3 = v27 and Theme.rowActive or k % 2 == 1 and Theme.panelLight or Theme.panel,
					LayoutOrder = k,
					Parent = frame20
				}, { UI.corner(4) })
				local gold = k == 1 and Theme.gold
					or k == 2 and Color3.fromRGB(200, 200, 205)
					or k == 3 and Color3.fromRGB(205, 140, 90)
					or Theme.textDim
				UI.text({
					Text = tostring(k),
					FontFace = Theme.fontHeavy,
					TextSize = 16,
					TextColor3 = gold,
					Size = UDim2.new(0, 34, 1, 0),
					Parent = frame21
				})

				UI.avatar({ userId = entry.userId }, 32, {
					Position = UDim2.new(0, 38, 0.5, 0),
					AnchorPoint = Vector2.new(0, 0.5),
					Parent = frame21
				})

				UI.text({
					Text = entry.name or "Player",
					FontFace = Theme.fontBold,
					TextSize = 16,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd,
					Size = UDim2.new(1, -184, 1, 0),
					Position = UDim2.fromOffset(80, 0),
					Parent = frame21
				})

				local text15 = tostring(entry.rating)

				if leaderboard.class == "playtime" then
					text15 = fmtPlaytime(entry.rating) -- inferred equivalent call
				elseif leaderboard.class == "wins" then
					text15 = tostring(entry.rating) .. (entry.rating == 1 and " win" or " wins")
				elseif leaderboard.class == "medals" then
					text15 = tostring(entry.rating) .. (entry.rating == 1 and " medal" or " medals")
				end

				UI.text({
					Text = text15,
					FontFace = Theme.fontHeavy,
					TextSize = 17,
					TextXAlignment = Enum.TextXAlignment.Right,
					Size = UDim2.new(0, 90, 1, 0),
					Position = UDim2.new(1, -100, 0, 0),
					Parent = frame21
				})

				if self.profileRow then
					self.profileRow(frame21, entry.userId, "leaderboard", nil, entry.name)
				end
			end
		end)
	end
	function leaderboard.onShow()
		segmented2.set(leaderboard.kind)
		segmented3.set(leaderboard.scope)
		v24.set(leaderboard.ratingClass)
		v24.frame.Visible = leaderboard.kind == "rating"
		leaderboard.load()
	end

	local function rosterChanged()
		if leaderboard.scope == "server" and frame32.Visible then
			task.delay(1, function()
				if leaderboard.scope == "server" and frame32.Visible then
					leaderboard.load()
				end
			end)
		end
	end
	Players.PlayerAdded:Connect(rosterChanged)
	Players.PlayerRemoving:Connect(rosterChanged)

	local frame33, parent9 = scrollPage("History")

	local history2 = { frame = frame33, older = {}, target = nil }
	v3.history = history2

	local text15 = UI.text({
		Text = "No games yet. Your online games show up here.",
		TextSize = 15,
		TextColor3 = Theme.textDim,
		TextWrapped = true,
		Size = UDim2.new(1, 0, 0, 50),
		LayoutOrder = 0,
		Parent = parent9
	})

	local frame21 = UI.new("Frame", {
		Name = "More",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 1000000,
		Visible = false,
		Parent = parent9
	}, { UI.list(Enum.FillDirection.Vertical, 8) })
	local text16 = UI.text({
		Name = "Count",
		Text = "",
		TextSize = 13,
		TextColor3 = Theme.textMuted,
		TextWrapped = true,
		Size = UDim2.new(1, 0, 0, 18),
		LayoutOrder = 1,
		Parent = frame21
	})

	local count3 = 0
	local idSet = {}
	local textButtons = {}
	local total = 0
	local v26 = false
	local v27 = nil

	local function addRow(layoutOrder, item, duration)
		local color = item.color
		local target = history2.target
		local black = color == 1 and item.black or item.white
		local v28

		if item.res == "1-0" and color == 1 then
			v28 = true
		elseif item.res == "0-1" then
			v28 = color == -1
		else
			v28 = false
		end

		local v29 = item.res == "1/2-1/2"
		local textButton2 = UI.new(
			"TextButton",
			{
				Size = UDim2.new(1, 0, 0, 58),
				BackgroundColor3 = Theme.panelLight,
				LayoutOrder = layoutOrder,
				Parent = parent9
			},
			{ UI.corner(6) }
		)
		table.insert(textButtons, textButton2)
		local win = v28 and Theme.win or v29 and Theme.draw or Theme.loss
		local frame22 = UI.new("Frame", {
			Size = UDim2.fromOffset(34, 34),
			Position = UDim2.new(0, 10, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = win,
			Parent = textButton2
		}, { UI.corner(6) })
		UI.icon(v28 and "add" or v29 and "pause" or "close", 22, Color3.new(1, 1, 1), {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Rotation = v29 and 90 or 0,
			Parent = frame22
		})

		local text17 = UI.text({
			Text = (black.n or "Opponent") .. " (" .. tostring(black.r or "?") .. ")",
			FontFace = Theme.fontBold,
			TextSize = 16,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Size = UDim2.new(1, -140, 0, 22),
			Position = UDim2.fromOffset(54, 8),
			Parent = textButton2
		})

		if self.openProfile and type(black.u) == "number" and black.u ~= 0 then
			local x = TextService:GetTextSize(
				black.n or "Opponent",
				16,
				Enum.Font.BuilderSansBold,
				Vector2.new(1000, 22)
			).X
			local textButton3 = UI.new("TextButton", {
				Name = "OpenName",
				Text = "",
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(math.min(math.ceil(x) + 6, 190), 26),
				Position = UDim2.fromOffset(51, 6),
				ZIndex = 2,
				Parent = textButton2
			})

			textButton3:SetAttribute("Sfx", "press")
			local function lit(p) -- 4 equivalent calls inferred from this helper
				UI.to(text17, UI.FAST, {
					TextColor3 = p and Theme.green or Theme.text
				})
			end
			textButton3.MouseEnter:Connect(function()
				lit(true) -- inferred equivalent call
			end)
			textButton3.MouseLeave:Connect(function()
				lit(false) -- inferred equivalent call
			end)
			textButton3.SelectionGained:Connect(function()
				lit(true) -- inferred equivalent call
			end)
			textButton3.SelectionLost:Connect(function()
				lit(false) -- inferred equivalent call
			end)
			textButton3.Activated:Connect(function()
				if target then
					self.openProfile(black.u, "profile", {
						userId = black.u,
						display = black.n,
						headshot = black.h
					})
				else
					self.openProfile(black.u, "history", {
						userId = black.u,
						display = black.n,
						headshot = black.h
					})
				end
			end)
		end

		local v30 = Config.TC_BY_ID[item.tc]
		local v31 = item.mv and item.mv ~= "" and #string.split(item.mv, " ") or 0
		UI.text({
			Text = string.format(
				"%s · %s · %d moves",
				v30 and v30.label or "?",
				(v[item.why] or ""):gsub("^by ", ""),
				(v31 + 1) // 2
			),
			TextSize = 13,
			TextColor3 = Theme.textDim,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Size = UDim2.new(1, -140, 0, 18),
			Position = UDim2.fromOffset(54, 31),
			Parent = textButton2
		})

		if item.rated and item.d then
			UI.text({
				Text = (item.d >= 0 and "+" or "") .. tostring(item.d),
				FontFace = Theme.fontHeavy,
				TextSize = 16,
				TextColor3 = item.d > 0 and Theme.win or item.d < 0 and Theme.loss or Theme.textDim,
				TextXAlignment = Enum.TextXAlignment.Right,
				Size = UDim2.fromOffset(76, 22),
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -12, 0, 8),
				Parent = textButton2
			})
		end

		UI.text({
			Text = timeAgo(item.t), -- inferred equivalent call
			TextSize = 12,
			TextColor3 = Theme.textMuted,
			TextXAlignment = Enum.TextXAlignment.Right,
			Size = UDim2.fromOffset(76, 18),
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -12, 0, item.rated and item.d and 31 or 20),
			Parent = textButton2
		})

		UI.hover(textButton2, nil, { BackgroundColor3 = Theme.rowActive }, {
			BackgroundColor3 = Theme.panelLight
		})

		if duration then
			textButton2.Visible = false
			task.delay(duration, function()
				if textButton2.Parent then
					UI.reveal(textButton2, true)
				end
			end)
		end

		textButton2.Activated:Connect(function()
			self.openHistory(item)
		end)
	end

	local function updateFooter()
		total = math.max(total, count3)
		frame21.Visible = count3 > 0

		if count3 < total then
			text16.Text = string.format("Showing %d of %d games", count3, total)
			v27:setVisible(true)
		else
			text16.Text = total >= Config.MAX_HISTORY
				and string.format(
					history2.target and "Their last %d games are kept." or "Your last %d games are kept.",
					Config.MAX_HISTORY
				)
				or ""

			v27:setVisible(false)
		end

		text16.Visible = text16.Text ~= ""
	end

	local function append(items, p)
		local count4 = 0

		for _, item in items do
			if type(item) ~= "table" or item.id and idSet[item.id] then
				continue
			end

			count3 += 1
			count4 += 1

			if item.id then
				idSet[item.id] = true
			end

			local layoutOrder = count3
			local v28

			if p and count4 <= 12 then
				v28 = (count4 - 1) * 0.025 or nil
			end

			addRow(layoutOrder, item, v28)
		end
	end

	local function loadOlder()
		if v26 or total <= count3 then
			return
		end

		v26 = true
		v27:setText("Loading...")
		v27:setEnabled(false)
		local target = history2.target
		local v28

		if target then
			v28 = self.request({
				type = "playerGames",
				userId = target.userId,
				from = count3 + 1
			})

			if history2.target ~= target then
				v26 = false
				return
			end
		else
			v28 = self.request({
				type = "history",
				from = count3 + 1
			})
		end

		v26 = false
		v27:setText("Show older games")
		v27:setEnabled(true)

		if type(v28) == "table" and type(v28.entries) == "table" then
			if type(v28.total) == "number" then
				total = v28.total
			end

			for _, entry in v28.entries do
				table.insert(history2.older, entry)
			end

			append(v28.entries, true)
			updateFooter()
		else
			text16.Text = "Couldn't load older games. Try again in a moment."
			text16.Visible = true
		end
	end

	v27 = UI.button({
		parent = frame21,
		name = "ShowOlder",
		size = UDim2.new(1, 0, 0, 44),
		style = "secondary",
		icon = "history",
		text = "Show older games",
		textSize = 16,
		layoutOrder = 2,
		onClick = function()
			task.spawn(loadOlder)
		end
	})

	function history2.refresh()
		for _, v28 in textButtons do
			UI.unwrap(v28)
			v28:Destroy()
		end

		table.clear(textButtons)

		for _, button4 in parent9:GetChildren() do
			if button4:IsA("TextButton") then
				button4:Destroy()
			end
		end

		count3 = 0
		idSet = {}
		local target = history2.target

		if target then
			total = target.total or 0

			if target.loading then
				text15.Text = "Loading games..."
			elseif target.failed then
				text15.Text = "Couldn't load their games. Try again in a moment."
			else
				text15.Text = (target.display or "This player") .. " hasn't played any online games yet."
			end

			text15.Visible = #history2.older == 0
			append(history2.older, true)
			updateFooter()
		else
			text15.Text = "No games yet. Your online games show up here."
			local history = self.profile and self.profile.history or {}

			local id = history[1] and history[1].id

			if id ~= history2.firstId then
				history2.older = {}
				history2.firstId = id
			end

			total = self.profile and self.profile.historyTotal or #history
			text15.Visible = #history == 0
			append(history, true)
			append(history2.older, false)
			updateFooter()
		end
	end

	local function loadTarget(p)
		p.loading = true
		history2.refresh()
		local request = self.request({ type = "playerGames", userId = p.userId, from = 1 })

		if history2.target ~= p then
			return
		end

		p.loading = false

		if type(request) == "table" and request.ok and type(request.entries) == "table" then
			p.total = tonumber(request.total) or #request.entries
			history2.older = table.clone(request.entries)
		else
			p.failed = true
		end

		if v3.current == "history" then
			history2.refresh()
		end
	end

	history2.pendingTarget = nil

	function history2.onShow()
		local pendingTarget = history2.pendingTarget
		history2.pendingTarget = nil
		history2.older = {}
		history2.firstId = nil
		history2.target = pendingTarget

		if pendingTarget then
			v3.backTo.history = "profile"
			text.Text = (pendingTarget.display or "Player") .. "'s Games"
			task.spawn(loadTarget, pendingTarget)
		else
			v3.backTo.history = nil
			history2.refresh()
		end

		v3.refreshHeader()
	end

	function self.openPlayerGames(userId, display)
		if type(userId) ~= "number" then
			return
		end

		if userId == Players.LocalPlayer.UserId then
			v3.show("history")
			return
		end

		history2.pendingTarget = { userId = userId, display = display }
		history2.profileFrom = v3.backTo.profile

		if v3.current == "history" then
			history2.onShow()
		else
			v3.show("history")
		end
	end

	function history2.state(p)
		if p then
			loadOlder()
		end

		local count4 = 0

		for _, button4 in parent9:GetChildren() do
			if button4:IsA("TextButton") then
				count4 += 1
			end
		end

		return {
			rows = count4,
			shown = count3,
			total = total,
			footer = text16.Visible and text16.Text or "",
			button = v27.holder.Visible
		}
	end

	local v28 = newPage("Game") -- inferred equivalent call
	local Game = { frame = v28 }
	v3.game = Game

	local frame22 = UI.new("Frame", {
		Name = "Opening",
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundColor3 = Theme.panelHeader,
		BackgroundTransparency = 0.4,
		Parent = v28
	}, { UI.pad(0, 12, 0, 12) })
	local text17 = UI.text({
		Name = "OpeningName",
		Text = "",
		FontFace = Theme.fontMedium,
		TextSize = 14,
		TextColor3 = Theme.textDim,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Size = UDim2.fromScale(1, 1),
		Parent = frame22
	})

	function Game.setOpening(value)
		if text17.Text ~= (value or "") then
			text17.Text = value or ""
			UI.textIn(text17, 0.18)
		end
	end

	local frame23 = UI.new("Frame", {
		Name = "Moves",
		Size = UDim2.new(1, 0, 1, -134),
		Position = UDim2.fromOffset(0, 30),
		BackgroundTransparency = 1,
		Parent = v28
	})

	local moveList = MoveList.new(frame23)
	Game.moveList = moveList
	function moveList.onSelect(p)
		self.navigate(p)
	end

	local v29 = nil
	local fitHeight

	Game.taskSlot = UI.new("Frame", {
		Name = "TaskSlot",
		Position = UDim2.fromOffset(0, 40),
		Size = UDim2.new(1, 0, 1, -154),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Visible = false,
		Parent = v28
	}, { UI.pad(0, 10, 0, 10) })
	function Game.dockMoves(parent2, position, size)
		if parent2 then
			v29 = parent2
			frame23.Parent = parent2
			frame23.Position = position
			frame23.Size = size
		elseif v29 then
			v29 = nil
			frame23.Parent = v28
		end

		fitHeight()
	end

	fitHeight = function()
		Game.taskSlot.Visible = v29 ~= nil

		if v29 then
			frame22.Visible = true
			return
		end

		local v30 = v28.AbsoluteSize.Y / (self.uiScale or 1)

		if v30 <= 0 then
			return
		end

		local visible = v30 - 134 >= 52
		local v31 = visible and 30 or 0
		frame22.Visible = visible
		frame23.Position = UDim2.fromOffset(0, v31)
		frame23.Size = UDim2.new(1, 0, 1, -(104 + v31))
	end
	v28:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitHeight)
	task.defer(fitHeight)

	local frame24 = UI.new("Frame", {
		Name = "Strip",
		Size = UDim2.new(1, -16, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -110),
		BackgroundColor3 = Theme.panelHeader,
		Visible = false,
		ZIndex = 3,
		Parent = v28
	}, {
		UI.corner(8),
		UI.pad(10, 12, 10, 12),
		UI.list(Enum.FillDirection.Vertical, 8, Enum.HorizontalAlignment.Center),
		UI.stroke(Theme.divider, 1, 0)
	})
	local text18 = UI.text({
		Text = "",
		FontFace = Theme.fontBold,
		TextSize = 16,
		TextWrapped = true,
		RichText = true,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 1,
		ZIndex = 3,
		Parent = frame24
	})

	local frame25 = UI.new("Frame", {
		Size = UDim2.new(1, 0, 0, 38),
		BackgroundTransparency = 1,
		LayoutOrder = 2,
		ZIndex = 3,
		Parent = frame24
	}, { UI.list(Enum.FillDirection.Horizontal, 8, Enum.HorizontalAlignment.Center) })
	UI.button({
		parent = frame25,
		size = UDim2.new(0.5, -4, 1, 0),
		style = "primary",
		text = "Accept",
		textSize = 15,
		layoutOrder = 1,
		onClick = function()
			self.respondDraw(true)
		end
	})

	UI.button({
		parent = frame25,
		size = UDim2.new(0.5, -4, 1, 0),
		style = "secondary",
		text = "Decline",
		textSize = 15,
		layoutOrder = 2,
		onClick = function()
			self.respondDraw(false)
		end
	})

	for _, guiObject in frame24:GetDescendants() do
		if guiObject:IsA("GuiObject") then
			guiObject.ZIndex = 3
		end
	end

	local v30 = false

	local frame26 = UI.new("Frame", {
		Name = "Nav",
		Size = UDim2.new(1, -16, 0, 42),
		Position = UDim2.new(0, 8, 1, -100),
		BackgroundTransparency = 1,
		Parent = v28
	}, { UI.list(Enum.FillDirection.Horizontal, 4, Enum.HorizontalAlignment.Center) })
	local buttons2 = {}
	local function navButton(icon3, layoutOrder, onClick)
		local button4 = UI.button({
			parent = frame26,
			size = UDim2.new(0.2, -4, 1, 0),
			style = "flat",
			icon = icon3,
			iconSize = 26,
			iconColor = Theme.textSoft,
			layoutOrder = layoutOrder,
			onClick = onClick
		})

		table.insert(buttons2, button4)
		return button4
	end

	local chatButton = navButton("chat", 0, function()
		if self.toggleQuickChat then
			self.toggleQuickChat()
		end
	end)
	chatButton.holder.Visible = false
	Game.chatButton = chatButton
	Game.navOffset = 104
	local v31 = false
	function Game.showChat(visible)
		if v31 == visible then
			return
		end

		v31 = visible
		local v32 = visible and 6 or 5

		for _, v56 in buttons2 do
			v56.holder.Size = UDim2.new(1 / v32, -4, 1, 0)
		end

		chatButton.holder.Visible = visible

		if not visible and self.closeQuickChat then
			self.closeQuickChat()
		end
	end
	navButton("flip", 1, function()
		self.flip()
	end)
	navButton("first", 2, function()
		self.navigate(0)
	end)
	navButton("prev", 3, function()
		if self.session then
			self.navigate(self.session.viewPly - 1)
		end
	end)
	navButton("next", 4, function()
		if self.session then
			self.navigate(self.session.viewPly + 1)
		end
	end)
	navButton("last", 5, function()
		if self.session then
			self.navigate(#self.session.ucis)
		end
	end)

	local frame27 = UI.new("Frame", {
		Name = "Actions",
		Size = UDim2.new(1, -16, 0, 44),
		Position = UDim2.new(0, 8, 1, -52),
		BackgroundTransparency = 1,
		Parent = v28
	}, { UI.list(Enum.FillDirection.Horizontal, 6, Enum.HorizontalAlignment.Center) })
	local buttons3 = {}
	local function actionButton(p, icon3, text19, style, onClick)
		local button4 = UI.button({
			parent = frame27,
			size = UDim2.new(0.5, -3, 1, 0),
			style = style,
			icon = icon3,
			iconSize = 20,
			text = text19,
			textSize = 15,
			gap = 6,
			onClick = onClick
		})

		button4:setVisible(false)
		buttons3[p] = button4
		return button4
	end

	actionButton("draw", "handshake", "Draw", "secondary", function()
		self.offerDraw()
	end)
	actionButton("resign", "flag", "Resign", "secondary", function()
		self.resign()
	end)
	actionButton("abort", "close", "Abort", "secondary", function()
		self.abort()
	end)
	actionButton("hint", "bulb", "Hint", "secondary", function()
		self.hint()
	end)
	actionButton("takeback", "undo", "Undo", "secondary", function()
		self.takeback()
	end)
	actionButton("newGame", "add", "New Game", "primary", function()
		self.newGame()
	end)
	actionButton("rematch", "replay", "Rematch", "secondary", function()
		self.rematch()
	end)
	actionButton("review", "analysis", "Breakdown", "primary", function()
		if self.startReview then
			self.startReview()
		end
	end)
	actionButton("home", "home", "Home", "secondary", function()
		self.goHome()
	end)
	actionButton("analyze", "search", "Analyze", "secondary", function()
		if self.analyseCurrent then
			self.analyseCurrent()
		end
	end)

	actionButton("stopWatch", "close", "Stop Watching", "secondary", function()
		self.stopWatching()
	end)

	local function showButtons(list3)
		local v32 = {}

		for k, item in list3 do
			v32[item] = k
		end

		local count4 = #list3

		for k, v56 in buttons3 do
			local layoutOrder = v32[k]

			if layoutOrder then
				v56.holder.LayoutOrder = layoutOrder
				v56.holder.Size = UDim2.new(1 / count4, (count4 - 1) * -6 / count4, 1, 0)
			end

			v56:setVisible(layoutOrder ~= nil)
		end
	end

	local v32 = nil

	function Game.load(data)
		v30 = false
		v32 = nil
		local _ = data.kind == "idle"
		moveList:setEmptyText("")
		moveList:setMoves(data.sans)
		moveList:setCurrent(data.viewPly)
		Game.refresh()
	end

	function Game:push()
		moveList:push(self)
	end

	function Game.pop()
		moveList:pop()
	end

	function Game:setCurrent()
		moveList:setCurrent(self)
	end

	function Game.showDrawOffer(p)
		v30 = p
		Game.refresh()
	end

	function Game.setCoach(text19, color)
		v32 = text19 and { text = text19, color = color } or nil
		Game.refresh()
	end

	function Game.rematchOffered()
		buttons3.rematch:setText("Accept Rematch")
		buttons3.rematch:setStyle("primary")
	end

	function Game.refresh()
		local session = self.session

		if not session then
			return
		end

		buttons3.rematch:setText("Rematch")
		buttons3.rematch:setStyle("secondary")

		local v56 = (session.kind == "online" or session.kind == "bot") and session.over
		buttons3.review:setStyle(v56 and self.newFlow() and "secondary" or "primary")

		if session.kind == "online" and not session.over then
			if #session.ucis < 2 then
				showButtons({ "abort" })
			else
				showButtons({ "draw", "resign" })
			end
		elseif session.kind == "bot" and not session.over then
			showButtons({ "hint", "takeback", "resign" })
		elseif session.kind == "online" or session.kind == "bot" then
			if session.result == "*" or #session.ucis < 2 then
				showButtons({ "newGame", "rematch" })
			else
				showButtons({ "newGame", "rematch", "review" })
			end
		elseif session.kind == "review" then
			showButtons({ "review", "analyze", "home" })
		elseif session.kind == "watch" then
			if session.over then
				if session.result == "*" or #session.ucis < 2 then
					showButtons({ "home" })
				else
					showButtons({ "review", "analyze", "home" })
				end
			else
				showButtons({ "stopWatch" })
			end
		else
			showButtons({ "home" })
		end

		Game.showChat(self.quickChatOn ~= nil and self.quickChatOn() == true)
		local uiStroke = frame24:FindFirstChildOfClass("UIStroke")
		local text19 = text18.Text
		local visible = frame24.Visible
		local color = Theme.divider

		if v32 then
			UI.reveal(frame24, true, 6)
			frame25.Visible = false
			text18.Text = v32.text
			color = v32.color or Theme.divider
		elseif session.over and session.result then
			UI.reveal(frame24, true, 6)
			frame25.Visible = false
			local v59

			if session.result == "1-0" then
				v59 = "White won"
			elseif session.result == "0-1" then
				v59 = "Black won"
			elseif session.result == "*" then
				v59 = "Game aborted"
			else
				v59 = "Draw"
			end

			local v60 = v[session.reason or ""] or ""
			text18.Text = (session.result == "*" and "" or session.result:gsub("1/2", "½") .. "  ·  " or "") .. v59 .. (v60 == "" and "" or " " .. v60 or "")
		elseif v30 and session.kind == "online" then
			UI.reveal(frame24, true, 6)
			frame25.Visible = true
			text18.Text = "Your opponent offers a draw"
		elseif session.kind == "watch" then
			UI.reveal(frame24, true, 6)
			frame25.Visible = false
			local watchers = tonumber(session.watchers) or 0
			text18.Text = "Watching live" .. (watchers > 1 and "  ·  " .. watchers .. " watching" or "")
			color = Theme.loss
		else
			UI.reveal(frame24, false)
		end

		UI.to(uiStroke, UI.SNAP, { Color = color })

		if visible and frame24.Visible and text18.Text ~= text19 then
			UI.textIn(text18, 0.12)
		end

		v3.refreshHeader()
	end

	function v3.refreshAll()
		v3.home.refresh()

		if v3.current == "bots" then
			v3.bots.refresh()
		elseif v3.current == "players" then
			v3.players.refresh()
		elseif v3.current == "history" then
			v3.history.refresh()
		end
	end

	function v3.onFrame()
		v3.home.onFrame()
	end

	return v3
end

return Pages