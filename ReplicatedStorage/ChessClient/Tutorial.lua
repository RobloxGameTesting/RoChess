local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Chess = ReplicatedStorage:WaitForChild("Chess")
local Engine = require(Chess.Engine)
local Lessons = require(Chess.Lessons)
local Sprites = require(Chess.Sprites)
local parent = script.Parent
local Theme = require(parent.Theme)
local UI = require(parent.UI)
local Sound = require(parent.Sound)
local Session = require(parent.Session)

local Tutorial = {}
Tutorial.LESSONS = Lessons
local teal = Theme.teal
local color = Color3.fromRGB(224, 76, 62)
local color2 = Color3.fromRGB(96, 165, 230)
local color3 = Color3.fromRGB(255, 196, 46)

local v = {
	stars = "Collect the stars.",
	capture = "Take both black pieces.",
	check = "Give check.",
	mate = "Checkmate in one move."
}

local function sq(p) -- 2 equivalent calls inferred from this helper
	return Engine.algToIndex64(p)
end

local function blackPieces(session)
	local position = session.positions[#session.ucis]
	local count = 0

	for i = 1, 64 do
		if (position[i] or 0) < 0 then
			count += 1
		end
	end

	return count
end

function Tutorial:install()
	local pages = self.pages
	local state = {
		idx = 1,
		session = nil,
		stars = {},
		starCount = 0,
		complete = false,
		busy = false,
		finished = false,
		msg = nil,
		logged = {},
		started = false
	}

	Tutorial.state = state
	local fwd = {}

	local function report(p) -- 2 equivalent calls inferred from this helper
		if not state.logged[p] then
			state.logged[p] = true
			self.send({ type = "fx", ev = "tut", n = p })
		end
	end

	local frame = UI.new("Frame", {
		Name = "TutorialStars",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Parent = self.board.hintLayer
	})

	local function clearStars()
		for _, star in state.stars do
			star:Destroy()
		end

		state.stars = {}
		state.starCount = 0
	end

	local function placeStar(p)
		local frame2 = UI.new("Frame", {
			Name = "Star" .. p,
			Size = UDim2.fromScale(0.125, 0.125),
			Position = self.board:sqPos(p),
			BackgroundTransparency = 1,
			Parent = frame
		})

		local icon = UI.icon("star", 40, color3, {
			Name = "Icon",
			Size = UDim2.fromScale(0.6, 0.6),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Parent = frame2
		})

		UI.pop(icon, 0.4, 0.3)
		state.stars[p] = frame2
		state.starCount += 1
	end

	local function collectStar(to): boolean
		local star = state.stars[to]

		if not star then
			return false
		end

		state.stars[to] = nil
		state.starCount -= 1
		local icon = star:FindFirstChild("Icon")

		if icon then
			UI.tween(icon, 0.25, { Size = UDim2.fromScale(1.1, 1.1), ImageTransparency = 1 })
		end

		task.delay(0.3, function()
			star:Destroy()
		end)
		return true
	end

	local function repositionStars() -- 1 equivalent call inferred from this helper
		for k, star in state.stars do
			star.Position = self.board:sqPos(k)
		end
	end

	local page, parent2 = pages.newPage("basics", "The Basics", "school", Theme.textSoft, true)
	local basics = { frame = page }
	pages.basics = basics
	pages.backTo.basics = "learn"

	local frame2 = UI.new("Frame", {
		Name = "Lesson",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 1,
		Parent = parent2
	}, { UI.list(Enum.FillDirection.Vertical, 10) })

	local frame3 = UI.new("Frame", {
		Name = "Bar",
		Size = UDim2.new(1, 0, 0, 8),
		BackgroundColor3 = Theme.track,
		LayoutOrder = 1,
		Parent = frame2
	}, { UI.corner(4) })
	local frame4 = UI.new(
		"Frame",
		{ Name = "Fill", Size = UDim2.fromScale(0, 1), BackgroundColor3 = teal, Parent = frame3 },
		{ UI.corner(4) }
	)

	local frame5 = UI.new("Frame", {
		Name = "Card",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.panelLight,
		LayoutOrder = 2,
		Parent = frame2
	}, { UI.corner(14), UI.pad(16, 16, 16, 16), UI.list(Enum.FillDirection.Vertical, 10) })
	UI.lift(frame5)
	local frame6 = UI.new("Frame", {
		Name = "Head",
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundTransparency = 1,
		LayoutOrder = 1,
		Parent = frame5
	}, { UI.list(Enum.FillDirection.Horizontal, 10, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center) })
	local icon = UI.icon("wR", 44, Color3.new(1, 1, 1), { LayoutOrder = 1, Parent = frame6 })
	local text = UI.text({
		Name = "Title",
		Text = "",
		FontFace = Theme.fontHeavy,
		TextSize = 20,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Size = UDim2.new(1, -54, 1, 0),
		LayoutOrder = 2,
		Parent = frame6
	})

	local text2 = UI.text({
		Name = "Body",
		Text = "",
		FontFace = Theme.fontMedium,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 2,
		Parent = frame5
	})

	local frame7 = UI.new("Frame", {
		Name = "Feedback",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.panelLight,
		LayoutOrder = 3,
		Parent = frame2
	}, {
		UI.corner(14),
		UI.pad(12, 14, 12, 14),
		UI.list(Enum.FillDirection.Horizontal, 10, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)
	})
	UI.lift(frame7)
	local icon2 = UI.icon("star", 26, color3, { LayoutOrder = 1, Parent = frame7 })
	local text3 = UI.text({
		Name = "Text",
		Text = "",
		FontFace = Theme.fontBold,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Size = UDim2.new(1, -38, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 2,
		Parent = frame7
	})

	UI.button({
		parent = frame2,
		size = UDim2.new(1, 0, 0, 34),
		style = "ghost",
		text = "Skip tutorial",
		textSize = 15,
		layoutOrder = 4,
		onClick = function()
			fwd.showFinish()
		end
	})

	local frame8 = UI.new("Frame", {
		Name = "Finished",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Visible = false,
		LayoutOrder = 2,
		Parent = parent2
	}, { UI.list(Enum.FillDirection.Vertical, 10) })
	local frame9 = UI.new("Frame", {
		Name = "Card",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.panelLight,
		LayoutOrder = 1,
		Parent = frame8
	}, { UI.corner(14), UI.pad(16, 16, 16, 16), UI.list(Enum.FillDirection.Vertical, 8) })
	UI.lift(frame9)
	local frame10 = UI.new(
		"Frame",
		{
			Size = UDim2.new(1, 0, 0, 40),
			BackgroundTransparency = 1,
			LayoutOrder = 1,
			Parent = frame9
		},
		{ UI.list(Enum.FillDirection.Horizontal, 10, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center) }
	)
	UI.icon("trophy", 34, Theme.gold, { LayoutOrder = 1, Parent = frame10 })
	UI.text({
		Text = "You're ready!",
		FontFace = Theme.fontHeavy,
		TextSize = 20,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -46, 1, 0),
		LayoutOrder = 2,
		Parent = frame10
	})

	UI.text({
		Text = "Take turns moving. Checkmate the king to win.",
		FontFace = Theme.fontMedium,
		TextSize = 16,
		TextColor3 = Theme.textSoft,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 2,
		Parent = frame9
	})

	UI.button({
		parent = frame8,
		size = UDim2.new(1, 0, 0, 58),
		style = "primary",
		icon = "pawn",
		text = "Play",
		textSize = 20,
		layoutOrder = 2,
		onClick = function()
			fwd.leave()
			self.goHome()

			if not (self.searching or self.joining or self.inLiveGame()) then
				self.startSearch(self.selectedTc)
			end
		end
	})

	UI.button({
		parent = frame8,
		size = UDim2.new(1, 0, 0, 46),
		style = "secondary",
		icon = "bot",
		text = "Play a bot",
		textSize = 17,
		layoutOrder = 3,
		onClick = function()
			fwd.leave()
			self.startBotGame("pebble", "white")
		end
	})

	UI.button({
		parent = frame8,
		size = UDim2.new(1, 0, 0, 46),
		style = "secondary",
		icon = "school",
		text = "More lessons",
		textSize = 17,
		layoutOrder = 4,
		onClick = function()
			fwd.leave()

			if self.openLearn then
				self.openLearn()
			end
		end
	})

	local function setFeedback(p, text4)
		local v2 = "star"
		local imageColor = color3

		if p == "good" then
			imageColor = teal
			v2 = "check"
		elseif p == "bad" then
			imageColor = color
			v2 = "close"
		elseif p == "goal" then
			imageColor = Theme.textDim
			v2 = "flag"
		end

		Sprites.apply(icon2, v2)
		icon2.ImageColor3 = imageColor

		if text3.Text ~= text4 then
			text3.Text = text4
			UI.textIn(text3, 0.14)

			if p == "good" or p == "bad" then
				UI.pop(icon2, 0.5, 0.22)
			end
		end
	end

	function basics.refresh()
		frame2.Visible = not state.finished
		frame8.Visible = state.finished

		if state.finished then
			return
		end

		local v2 = #Lessons
		local lesson = Lessons[state.idx]
		UI.tween(frame4, 0.25, {
			Size = UDim2.fromScale((state.idx - 1 + (state.complete and 1 or 0)) / v2, 1)
		})
		Sprites.apply(icon, lesson.piece or "wP")
		icon.ImageColor3 = Color3.new(1, 1, 1)
		text.Text = lesson.title
		text2.Text = lesson.text

		if state.complete then
			Sprites.apply(icon2, "check")
			icon2.ImageColor3 = teal

			if text3.Text ~= "Nice!" then
				text3.Text = "Nice!"
				UI.textIn(text3, 0.14)

				UI.pop(icon2, 0.5, 0.22)
			end
		elseif state.msg == "miss" then
			Sprites.apply(icon2, "close")
			icon2.ImageColor3 = color

			if text3.Text ~= "Try again. Follow the arrow." then
				text3.Text = "Try again. Follow the arrow."
				UI.textIn(text3, 0.14)

				UI.pop(icon2, 0.5, 0.22)
			end
		elseif state.msg == "stuck" then
			Sprites.apply(icon2, "close")
			icon2.ImageColor3 = color

			if text3.Text ~= "Stuck! Starting again..." then
				text3.Text = "Stuck! Starting again..."
				UI.textIn(text3, 0.14)

				UI.pop(icon2, 0.5, 0.22)
			end
		elseif lesson.goal == "stars" then
			local text4 = "Collect the stars." .. string.format(" %d left.", state.starCount)
			Sprites.apply(icon2, "star")
			icon2.ImageColor3 = color3

			if text3.Text ~= text4 then
				text3.Text = text4
				UI.textIn(text3, 0.14)
			end
		else
			local text4 = v[lesson.goal] or ""
			local textDim = Theme.textDim

			Sprites.apply(icon2, "flag")
			icon2.ImageColor3 = textDim

			if text3.Text ~= text4 then
				text3.Text = text4
				UI.textIn(text3, 0.14)
			end
		end
	end

	local function newSession(startFen)
		local tutorial = Session.new("tutorial", {
			startFen = startFen,
			myColor = 1,
			white = self.myInfo(nil),
			black = { display = "Coach" }
		})

		state.session = tutorial
		return tutorial
	end

	local function showHint() -- 2 equivalent calls inferred from this helper
		local lesson = Lessons[state.idx]

		if lesson.hint then
			self.board:setArrow(
				"hint",
				sq(string.sub(lesson.hint, 1, 2)), -- inferred equivalent call
				sq(string.sub(lesson.hint, 3, 4)), -- inferred equivalent call
				color2,
				0.15
			)
		end
	end

	function fwd.startLesson(value)
		local idx = math.clamp(value, 1, #Lessons)
		state.idx = idx
		state.complete = false
		state.busy = false
		state.finished = false
		state.msg = nil
		local lesson = Lessons[idx]
		local session = newSession(lesson.fen)
		self.modals.closeAll()
		self.setSession(session)
		clearStars()

		for _, v2 in lesson.stars or {} do
			placeStar(sq(v2))
		end

		if pages.current ~= "basics" then
			pages.show("basics")
		end

		basics.refresh()
	end

	function fwd.showFinish()
		state.finished = true
		state.complete = false
		clearStars()
		local session = newSession(Engine.START_FEN)
		session.over = true
		self.setSession(session)

		if pages.current ~= "basics" then
			pages.show("basics")
		end

		basics.refresh()
	end

	function fwd.nextLesson()
		if not (state.idx >= #Lessons) then
			fwd.startLesson(state.idx + 1)

			return
		end

		if self.Learn and self.Learn.markDone then
			self.Learn.markDone("basics")
		end

		fwd.showFinish()
	end

	function fwd.leave()
		clearStars()
		state.session = nil
	end

	local function celebrate()
		local frame11 = self.board.frame
		local v2 = frame11.AbsolutePosition + frame11.AbsoluteSize / 2
		pcall(UI.confetti, self.gui, Vector2.new(v2.X, v2.Y), {
			count = 34,
			spread = math.max(120, frame11.AbsoluteSize.X * 0.4),
			zindex = 40
		})
	end

	function self.tutorialMove(p, p2, p3, p4): boolean
		local session = self.session

		if session ~= state.session or state.busy or state.complete or state.finished then
			return false
		end

		local move = session:findMove(p, p2, p3)

		if not move then
			Sound.play("illegal")
			return false
		end

		local lesson = Lessons[state.idx]
		local viewPly = session:applyMove(move)
		session.viewPly = viewPly
		local flag = session.flags[viewPly]
		local lastMove = session.lastMoves[viewPly]
		local instant = p4 and { [p2] = true } or nil
		self.board:setArrow("hint", nil)
		self.board:setTint("tut", nil)
		self.board:setMoveBadge(nil)

		local v2 = false
		local v3 = false
		local goal = lesson.goal

		if goal == "check" then
			v2 = session.engine:inCheck()
			v3 = not v2
		elseif goal == "castle" then
			v2 = flag.castle
			v3 = not v2
		elseif goal == "mate" then
			v2 = session.engine:status() == "checkmate"
			v3 = not v2
		elseif goal == "promote" then
			v2 = flag.promo
		elseif goal == "escape" then
			v2 = true
		end

		local v4 = not v3 and collectStar(lastMove.to)

		if v4 then
			Sound.play("step")
		end

		if goal == "stars" then
			v2 = state.starCount == 0
		elseif goal == "capture" then
			v2 = blackPieces(session) == 0
		end

		state.msg = nil

		if v3 then
			self.render({ instant = instant })
			Sound.play("error")
			self.board:setTint("tut", lastMove.to, color, 0.4)
			self.board:setMoveBadge(lastMove.to, color, nil, "close")
			state.busy = true
			state.msg = "miss"
			basics.refresh()
			task.delay(0.8, function()
				if self.session ~= session then
					return
				end

				state.busy = false
				session:undo()
				session.viewPly = #session.ucis
				self.board:setTint("tut", nil)
				self.board:setMoveBadge(nil)
				self.render()
				showHint() -- inferred equivalent call
			end)
			return true
		elseif v2 then
			state.complete = true
			session.over = true
			self.render({ instant = instant })
			Sound.forMove(flag)
			Sound.play(state.idx == #Lessons and "win" or "success")
			self.board:setTint("tut", lastMove.to, teal, 0.45)
			self.board:setMoveBadge(lastMove.to, teal, nil, "check")
			celebrate()
			report(state.idx + 1) -- inferred equivalent call
			basics.refresh()
			local idx = state.idx
			task.delay(1.3, function()
				if self.session == session and state.idx == idx and state.complete then
					fwd.nextLesson()
				end
			end)
			return true
		else
			if session.engine.side ~= 1 then
				session.engine:makeNull()
			end

			self.render({ instant = instant })

			if not v4 then
				Sound.forMove(flag)
			end

			if #session.engine:legalMoves() == 0 or goal == "capture" and not fwd.canStillCapture(session) then
				state.msg = "stuck"
				state.busy = true
				local idx = state.idx
				task.delay(1.2, function()
					if self.session == session and state.idx == idx then
						fwd.startLesson(idx)
						showHint() -- inferred equivalent call
					end
				end)
			end

			basics.refresh()
			return true
		end
	end

	function fwd.canStillCapture(p): boolean
		local position = p.positions[#p.ucis]
		local minValue = 99
		local maxValue = -1

		for i = 1, 64 do
			local v2 = position[i] or 0
			local v3 = (i - 1) // 8 + 1

			if v2 < 0 then
				minValue = math.min(minValue, v3)
			elseif v2 == 1 then
				maxValue = math.max(maxValue, v3)
			elseif v2 > 1 then
				return true
			end
		end

		return maxValue >= 0 and maxValue < minValue
	end

	local onRender = self.onRender
	function self.onRender(p)
		if onRender then
			onRender(p)
		end

		if state.session and p ~= state.session then
			fwd.leave()
		elseif next(state.stars) then
			repositionStars() -- inferred equivalent call
		end
	end

	function self.openTutorial(p)
		if self.inLiveGame() then
			self.toast("Finish your game first")
			return
		end

		if self.searching then
			self.cancelSearch()
		end

		if not state.started then
			state.started = true
			report(1) -- inferred equivalent call
		end

		if p or state.finished then
			fwd.startLesson(1)
		else
			fwd.startLesson(state.idx)
		end
	end

	function basics.onShow()
		if self.session ~= state.session and not self.inLiveGame() then
			task.defer(function()
				if pages.current == "basics" and self.session ~= state.session then
					if state.finished then
						fwd.showFinish()
					else
						fwd.startLesson(state.idx)
					end
				end
			end)
		end

		basics.refresh()
	end

	Tutorial._fwd = fwd
end

return Tutorial