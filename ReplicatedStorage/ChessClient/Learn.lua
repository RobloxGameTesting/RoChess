local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Chess = ReplicatedStorage:WaitForChild("Chess")
local Engine = require(Chess.Engine)
local Courses = require(Chess.Courses)
local Sprites = require(Chess.Sprites)
local parent = script.Parent
local Theme = require(parent.Theme)
local UI = require(parent.UI)
local Sound = require(parent.Sound)
local Session = require(parent.Session)

local Learn = {}

local teal = Theme.teal
local rowActive = Theme.rowActive
local color = Color3.fromRGB(224, 76, 62)
local color2 = Color3.fromRGB(96, 165, 230)
local color3 = Color3.fromRGB(255, 170, 0)

local v = { green = teal, blue = color2 }

local function sq(p) -- 7 equivalent calls inferred from this helper
	return Engine.algToIndex64(p)
end

local function lessonCount(p) -- 3 equivalent calls inferred from this helper
	if p.tutorial then
		return 1
	end

	return #p.lessons
end

local function lessonIds(data)
	if data.tutorial then
		return { data.id }
	end

	local ids = {}

	for _, lesson in data.lessons do
		table.insert(ids, lesson.id)
	end

	return ids
end

function Learn:install()
	local pages = self.pages
	local state = {
		done = {},
		loaded = false,
		course = nil,
		lesson = nil,
		steps = {},
		idx = 1,
		session = nil,
		cands = {},
		k = 0,
		complete = false,
		busy = false,
		msg = nil,
		misses = 0,
		finished = false,
		visit = 0,
		practice = nil,
		practiceTotal = 0,
		practiceSolved = 0,
		waiting = false,
		sent = {}
	}

	Learn.state = state
	local fwd = {}

	local function track(p, options)
		local lesson = state.lesson

		if not lesson or state.sent[p] then
			return
		end

		state.sent[p] = true
		local v2 = { type = "fx", ev = "learn", k = p, id = lesson.id }

		for k, v3 in options or {} do
			v2[k] = v3
		end

		self.send(v2)
	end

	local function doneCount(p) -- 3 equivalent calls inferred from this helper
		local count = 0

		for _, v2 in lessonIds(p) do
			if state.done[v2] then
				count += 1
			end
		end

		return count
	end

	local function label(state2)
		state2.TextXAlignment = state2.TextXAlignment or Enum.TextXAlignment.Left
		state2.TextWrapped = true
		state2.Size = state2.Size or UDim2.new(1, 0, 0, 0)
		state2.AutomaticSize = state2.AutomaticSize or Enum.AutomaticSize.Y
		return UI.text(state2)
	end

	local function iconTile(p, _, p2, parent2, value)
		local frame = UI.new("Frame", {
			Name = "Tile",
			Size = UDim2.fromOffset(p2, p2),
			BackgroundColor3 = rowActive,
			LayoutOrder = value or 1,
			Parent = parent2
		}, { UI.corner(10) })
		return
			frame,
			(UI.icon(p, (math.floor)(p2 * 0.56), Theme.textSoft, {
				Name = "Icon",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Parent = frame
			}))
	end

	local function bar(frame, layoutOrder, p, p2)
		local frame2 = UI.new("Frame", {
			Name = "Bar",
			Size = UDim2.new(1, 0, 0, 8),
			BackgroundColor3 = p2 or Theme.track,
			LayoutOrder = layoutOrder,
			Parent = frame
		}, { UI.corner(4) })
		return frame2, (UI.new("Frame", {
			Name = "Fill",
			Size = UDim2.fromScale(0, 1),
			BackgroundColor3 = p or teal,
			Parent = frame2
		}, { UI.corner(4) }))
	end

	local function card(frame, k, fn, p)
		local textButton = UI.new("TextButton", {
			Name = "Card",
			Text = "",
			AutoButtonColor = false,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Theme.panelLight,
			LayoutOrder = k,
			Parent = frame
		}, {
			UI.corner(8),
			UI.pad(12, 14, 12, 14),
			p and UI.list(
				Enum.FillDirection.Horizontal,
				12,
				Enum.HorizontalAlignment.Left,
				Enum.VerticalAlignment.Center
			) or UI.list(Enum.FillDirection.Vertical, 8)
		})

		textButton:SetAttribute("Sfx", "press")
		UI.lift(textButton, 0.12)
		UI.hover(textButton, nil, { BackgroundColor3 = Theme.rowActive }, {
			BackgroundColor3 = Theme.panelLight
		})

		if fn then
			textButton.Activated:Connect(function()
				Sound.play("press")
				fn()
			end)
		end

		return textButton
	end

	local function backLink(parent2, text, onClick)
		return UI.button({
			parent = parent2,
			size = UDim2.new(1, 0, 0, 32),
			style = "ghost",
			icon = "back",
			iconSize = 18,
			text = text,
			textSize = 15,
			align = Enum.HorizontalAlignment.Left,
			padX = 2,
			layoutOrder = 0,
			onClick = onClick
		})
	end

	local function clearRows(frame)
		for _, child in frame:GetChildren() do
			if not (child:IsA("UIListLayout") or child:IsA("UIPadding")) then
				child:Destroy()
			end
		end
	end

	local page, parent2 = pages.newPage("learn", "Learn", "school", Theme.textSoft, true)
	local learn = { frame = page }
	pages.learn = learn

	local frame = UI.new("Frame", {
		Name = "Intro",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.panelLight,
		LayoutOrder = 1,
		Parent = parent2
	}, { UI.corner(14), UI.pad(14, 16, 14, 16), UI.list(Enum.FillDirection.Vertical, 8) })
	UI.lift(frame)
	local frame2 = UI.new(
		"Frame",
		{
			Size = UDim2.new(1, 0, 0, 40),
			BackgroundTransparency = 1,
			LayoutOrder = 1,
			Parent = frame
		},
		{ UI.list(Enum.FillDirection.Horizontal, 10, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center) }
	)
	UI.icon("school", 32, Theme.textSoft, { LayoutOrder = 1, Parent = frame2 })
	UI.text({
		Text = "Learn Chess",
		FontFace = Theme.fontHeavy,
		TextSize = 20,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -46, 1, 0),
		LayoutOrder = 2,
		Parent = frame2
	})

	local v2 = label({
		Name = "Progress",
		Text = "",
		FontFace = Theme.fontMedium,
		TextSize = 16,
		TextColor3 = Theme.textSoft,
		LayoutOrder = 2,
		Parent = frame
	})

	local _, v3 = bar(frame, 3)

	local frame3 = UI.new("Frame", {
		Name = "UpNext",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.panelLight,
		LayoutOrder = 2,
		Visible = false,
		Parent = parent2
	}, { UI.corner(14), UI.pad(14, 16, 14, 16), UI.list(Enum.FillDirection.Vertical, 12) })
	UI.lift(frame3)
	local frame4 = UI.new("Frame", {
		Name = "Top",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 1,
		Parent = frame3
	}, { UI.list(Enum.FillDirection.Horizontal, 12, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center) })
	local _, v4 = iconTile("school", teal, 52, frame4, 1)
	local frame5 = UI.new("Frame", {
		Name = "Text",
		Size = UDim2.new(1, -64, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 2,
		Parent = frame4
	}, { UI.list(Enum.FillDirection.Vertical, 2) })
	local text = UI.text({
		Name = "Kicker",
		Text = "UP NEXT",
		FontFace = Theme.fontHeavy,
		TextSize = 12,
		TextColor3 = teal,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 16),
		LayoutOrder = 1,
		Parent = frame5
	})

	local v5 = label({
		Name = "Title",
		Text = "",
		FontFace = Theme.fontHeavy,
		TextSize = 20,
		LayoutOrder = 2,
		Parent = frame5
	})

	local v6 = label({
		Name = "Sub",
		Text = "",
		FontFace = Theme.fontMedium,
		TextSize = 14,
		TextColor3 = Theme.textDim,
		LayoutOrder = 3,
		Parent = frame5
	})

	local button = UI.button({
		parent = frame3,
		name = "Go",
		size = UDim2.new(1, 0, 0, 50),
		style = "primary",
		icon = "play",
		text = "Start lesson",
		textSize = 18,
		layoutOrder = 2,
		onClick = function()
			fwd.upNextGo()
		end
	})

	local v7 = nil

	local function findUpNext()
		if state.lesson and not state.finished and state.course then
			return { course = state.course, lesson = state.lesson, resume = true }
		end

		local games = self.profile and tonumber(self.profile.games) or 0

		for _, item in Courses.list do
			if item.tutorial then
				if not state.done[item.id] and games < 5 then
					return { course = item }
				end
			else
				for _, lesson in item.lessons do
					if not state.done[lesson.id] then
						return { course = item, lesson = lesson }
					end
				end
			end
		end

		return nil
	end

	local function refreshUpNext()
		local upNext = findUpNext()

		if upNext and not (upNext.resume or state.loaded) then
			upNext = nil
		end

		v7 = upNext
		frame3.Visible = upNext ~= nil

		if not upNext then
			return
		end

		local course = upNext.course
		local lesson = upNext.lesson
		Sprites.apply(v4, course.icon)
		v4.ImageColor3 = Theme.textSoft
		text.Text = upNext.resume and "CONTINUE" or "UP NEXT"
		text.TextColor3 = teal
		v5.Text = lesson and lesson.title or course.title
		v6.Text = lesson and course.title .. " · " .. lesson.sub or course.sub
		button:setText(upNext.resume and "Continue" or "Start lesson")
	end

	local frame6 = UI.new("Frame", {
		Name = "Courses",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 3,
		Parent = parent2
	}, { UI.list(Enum.FillDirection.Vertical, 8) })

	local v8 = {}

	for k, item in Courses.list do
		local parent3 = card(frame6, k, function()
			if item.tutorial then
				self.openTutorial(state.done.basics == true)
			else
				fwd.openCourse(item)
			end
		end, true)
		parent3.Name = item.id
		iconTile(item.icon, item.color, 52, parent3, 1)
		local frame7 = UI.new("Frame", {
			Name = "Text",
			Size = UDim2.new(1, -64, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = 2,
			Parent = parent3
		}, { UI.list(Enum.FillDirection.Vertical, 4) })
		local frame8 = UI.new("Frame", {
			Size = UDim2.new(1, 0, 0, 24),
			BackgroundTransparency = 1,
			LayoutOrder = 1,
			Parent = frame7
		})

		UI.text({
			Text = item.title,
			FontFace = Theme.fontHeavy,
			TextSize = 19,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Size = UDim2.new(1, -60, 1, 0),
			Parent = frame8
		})

		local text2 = UI.text({
			Name = "Count",
			Text = "",
			FontFace = Theme.fontBold,
			TextSize = 15,
			TextColor3 = Theme.textDim,
			TextXAlignment = Enum.TextXAlignment.Right,
			Size = UDim2.new(0, 56, 1, 0),
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.fromScale(1, 0),
			Parent = frame8
		})

		local sub = label({
			Name = "Sub",
			Text = item.sub,
			FontFace = Theme.fontMedium,
			TextSize = 14,
			TextColor3 = Theme.textDim,
			LayoutOrder = 2,
			Parent = frame7
		})

		local _, fill = bar(frame7, 3, teal)
		v8[item.id] = { count = text2, fill = fill, sub = sub }
	end

	function learn.refresh()
		local total = 0
		local total2 = 0

		for _, item in Courses.list do
			local v9 = lessonCount(item) -- inferred equivalent call
			local count = doneCount(item) -- inferred equivalent call
			total += v9
			total2 += count
			local v10 = v8[item.id]
			v10.count.Text = v9 <= count and "Done" or string.format("%d/%d", count, v9)
			v10.count.TextColor3 = v9 <= count and teal or Theme.textDim
			v10.fill.Size = UDim2.fromScale(v9 > 0 and count / v9 or 0, 1)

			local v11 = nil

			if item.lessons and count > 0 and count < v9 then
				for _, lesson in item.lessons do
					if not state.done[lesson.id] then
						v11 = lesson
						break
					end
				end
			end

			v10.sub.Text = v11 and "Next: " .. v11.title or item.sub
			v10.sub.TextColor3 = v11 and teal or Theme.textDim
		end

		refreshUpNext()
		v2.Text = total2 == 0
			and string.format("%d lessons, from your first moves to checkmate patterns, tactics and endgames.", total)
			or total <= total2 and "You've finished every lesson. Nice work!"
			or string.format("%d of %d lessons done.", total2, total)
		UI.tween(v3, 0.3, {
			Size = UDim2.fromScale(total > 0 and total2 / total or 0, 1)
		})
	end

	local function loadProgress() -- 2 equivalent calls inferred from this helper
		if state.loaded or state.loading then
			return
		end

		state.loading = true
		task.spawn(function()
			local request = self.request({ type = "learnInfo" })
			state.loading = false

			if type(request) == "table" and request.ok and type(request.done) == "table" then
				state.loaded = true

				for _, v9 in request.done do
					state.done[v9] = true
				end
			end

			learn.refresh()

			if pages.course and pages.current == "course" then
				pages.course.refresh()
			end
		end)
	end

	local function leaveBoard() -- 3 equivalent calls inferred from this helper
		state.visit += 1
		state.session = nil
		local session = self.session

		if session and session.kind == "tutorial" then
			self.resetIdle()
		end
	end

	function learn.onShow()
		loadProgress() -- inferred equivalent call
		leaveBoard() -- inferred equivalent call
		learn.refresh()
	end

	local page2, parent3 = pages.newPage("course", "Learn", "school", Theme.textSoft, true)
	local course2 = { frame = page2 }
	pages.course = course2
	pages.backTo.course = "learn"

	backLink(parent3, "All courses", function()
		pages.show("learn")
	end)
	local frame7 = UI.new("Frame", {
		Name = "Head",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.panelLight,
		LayoutOrder = 1,
		Parent = parent3
	}, { UI.corner(14), UI.pad(14, 16, 14, 16), UI.list(Enum.FillDirection.Vertical, 8) })
	UI.lift(frame7)
	local frame8 = UI.new(
		"Frame",
		{
			Size = UDim2.new(1, 0, 0, 52),
			BackgroundTransparency = 1,
			LayoutOrder = 1,
			Parent = frame7
		},
		{ UI.list(Enum.FillDirection.Horizontal, 12, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center) }
	)
	local _, v9 = iconTile("school", teal, 52, frame8, 1)
	local text2 = UI.text({
		Text = "",
		FontFace = Theme.fontHeavy,
		TextSize = 20,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Size = UDim2.new(1, -64, 1, 0),
		LayoutOrder = 2,
		Parent = frame8
	})

	local v10 = label({
		Text = "",
		FontFace = Theme.fontMedium,
		TextSize = 15,
		TextColor3 = Theme.textSoft,
		LayoutOrder = 2,
		Parent = frame7
	})

	local _, v11 = bar(frame7, 3)
	local frame9 = UI.new("Frame", {
		Name = "Lessons",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 2,
		Parent = parent3
	}, { UI.list(Enum.FillDirection.Vertical, 6) })

	function course2.refresh()
		local course = state.course

		if not course then
			return
		end

		Sprites.apply(v9, course.icon)
		v9.ImageColor3 = Theme.textSoft
		text2.Text = course.title
		local v12 = lessonCount(course) -- inferred equivalent call
		local count = doneCount(course) -- inferred equivalent call
		v10.Text = course.sub .. " · " .. (v12 <= count and "all done!" or string.format("%d of %d done", count, v12))
		v11.Size = UDim2.fromScale(v12 > 0 and count / v12 or 0, 1)
		clearRows(frame9)
		local id = nil

		for _, lesson in course.lessons do
			if not (id or state.done[lesson.id]) then
				id = lesson.id
			end
		end

		for k, lesson in course.lessons do
			local v13 = state.done[lesson.id] == true
			local parent4 = card(frame9, k, function()
				fwd.startLesson(course, lesson)
			end, true)
			parent4.Name = lesson.id
			local frame10 = UI.new("Frame", {
				Size = UDim2.fromOffset(40, 40),
				BackgroundColor3 = v13 and teal or rowActive,
				LayoutOrder = 1,
				Parent = parent4
			}, { UI.corner(20) })

			if v13 then
				UI.icon("check", 26, Color3.new(1, 1, 1), {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Parent = frame10
				})
			else
				UI.icon(lesson.piece or "wP", 32, Color3.new(1, 1, 1), {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Parent = frame10
				})
			end

			local frame11 = UI.new("Frame", {
				Size = UDim2.new(1, -52, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				LayoutOrder = 2,
				Parent = parent4
			}, { UI.list(Enum.FillDirection.Vertical, 2) })
			label({
				Text = string.format("%d. %s", k, lesson.title),
				FontFace = Theme.fontBold,
				TextSize = 16,
				LayoutOrder = 1,
				Parent = frame11
			})

			local v14 = lesson.practice and string.format(" · %d puzzles", lesson.practice.count) or ""
			label({
				Text = (lesson.id == id and "Up next · " or "") .. lesson.sub .. v14,
				FontFace = Theme.fontMedium,
				TextSize = 14,
				TextColor3 = lesson.id == id and teal or Theme.textDim,
				LayoutOrder = 2,
				Parent = frame11
			})
		end
	end

	function course2.onShow()
		loadProgress() -- inferred equivalent call
		leaveBoard() -- inferred equivalent call
		course2.refresh()
	end

	function fwd.openCourse(course)
		state.course = course
		pages.show("course")
	end

	local page3, parent4 = pages.newPage("lesson", "Learn", "school", Theme.textSoft, true)
	local lesson2 = { frame = page3 }
	pages.lesson = lesson2
	pages.backTo.lesson = "course"

	local v12 = backLink(parent4, "Back", function()
		pages.show("course")
	end)

	local frame10 = UI.new("Frame", {
		Name = "Run",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 1,
		Parent = parent4
	}, { UI.list(Enum.FillDirection.Vertical, 10) })
	local _, v13 = bar(frame10, 1, nil, Theme.track)

	local frame11 = UI.new("Frame", {
		Name = "Card",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.panelLight,
		LayoutOrder = 2,
		Parent = frame10
	}, { UI.corner(14), UI.pad(14, 16, 16, 16), UI.list(Enum.FillDirection.Vertical, 8) })
	UI.lift(frame11)
	local frame12 = UI.new("Frame", {
		Name = "Head",
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundTransparency = 1,
		LayoutOrder = 1,
		Parent = frame11
	}, { UI.list(Enum.FillDirection.Horizontal, 10, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center) })
	local icon = UI.icon("wP", 44, Color3.new(1, 1, 1), { LayoutOrder = 1, Parent = frame12 })
	local frame13 = UI.new(
		"Frame",
		{
			Size = UDim2.new(1, -54, 1, 0),
			BackgroundTransparency = 1,
			LayoutOrder = 2,
			Parent = frame12
		},
		{ UI.list(Enum.FillDirection.Vertical, 0, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center) }
	)
	local text3 = UI.text({
		Name = "Title",
		Text = "",
		FontFace = Theme.fontHeavy,
		TextSize = 20,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Size = UDim2.new(1, 0, 0, 26),
		LayoutOrder = 1,
		Parent = frame13
	})

	local text4 = UI.text({
		Name = "Step",
		Text = "",
		FontFace = Theme.fontBold,
		TextSize = 14,
		TextColor3 = Theme.textDim,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Size = UDim2.new(1, 0, 0, 18),
		LayoutOrder = 2,
		Parent = frame13
	})

	local v14 = label({
		Name = "Body",
		Text = "",
		FontFace = Theme.fontMedium,
		TextSize = 16,
		LayoutOrder = 2,
		Parent = frame11
	})

	local frame14 = UI.new("Frame", {
		Name = "Feedback",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.panelLight,
		LayoutOrder = 3,
		Parent = frame10
	}, {
		UI.corner(14),
		UI.pad(12, 14, 12, 14),
		UI.list(Enum.FillDirection.Horizontal, 10, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)
	})
	UI.lift(frame14)
	local icon2 = UI.icon("flag", 26, Theme.textDim, { LayoutOrder = 1, Parent = frame14 })
	local text5 = UI.text({
		Name = "Text",
		Text = "",
		FontFace = Theme.fontBold,
		TextSize = 17,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Size = UDim2.new(1, -38, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 2,
		Parent = frame14
	})

	local button2 = UI.button({
		parent = frame10,
		name = "Continue",
		size = UDim2.new(1, 0, 0, 50),
		style = "primary",
		text = "Continue",
		textSize = 18,
		layoutOrder = 4,
		onClick = function()
			fwd.nextStep()
		end
	})

	local frame15 = UI.new("Frame", {
		Name = "Tools",
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundTransparency = 1,
		LayoutOrder = 5,
		Parent = frame10
	}, { UI.list(Enum.FillDirection.Horizontal, 8) })
	local button3 = UI.button({
		parent = frame15,
		name = "Hint",
		size = UDim2.new(0.5, -4, 1, 0),
		style = "secondary",
		icon = "bulb",
		iconSize = 20,
		text = "Hint",
		textSize = 16,
		layoutOrder = 1,
		onClick = function()
			fwd.hint(true)
		end
	})

	local button4 = UI.button({
		parent = frame15,
		name = "Skip",
		size = UDim2.new(0.5, -4, 1, 0),
		style = "secondary",
		icon = "next",
		iconSize = 20,
		text = "Skip",
		textSize = 16,
		layoutOrder = 2,
		onClick = function()
			if not (state.complete or state.busy) then
				fwd.nextStep()
			end
		end
	})

	local frame16 = UI.new("Frame", {
		Name = "Done",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Visible = false,
		LayoutOrder = 2,
		Parent = parent4
	}, { UI.list(Enum.FillDirection.Vertical, 10) })
	local frame17 = UI.new("Frame", {
		Name = "Card",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.panelLight,
		LayoutOrder = 1,
		Parent = frame16
	}, { UI.corner(14), UI.pad(16, 16, 16, 16), UI.list(Enum.FillDirection.Vertical, 8) })
	UI.lift(frame17)
	local frame18 = UI.new(
		"Frame",
		{
			Size = UDim2.new(1, 0, 0, 40),
			BackgroundTransparency = 1,
			LayoutOrder = 1,
			Parent = frame17
		},
		{ UI.list(Enum.FillDirection.Horizontal, 10, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center) }
	)
	UI.icon("trophy", 34, Theme.gold, { LayoutOrder = 1, Parent = frame18 })
	UI.text({
		Text = "Lesson complete!",
		FontFace = Theme.fontHeavy,
		TextSize = 20,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -46, 1, 0),
		LayoutOrder = 2,
		Parent = frame18
	})

	local v15 = label({
		Name = "Text",
		Text = "",
		FontFace = Theme.fontMedium,
		TextSize = 17,
		TextColor3 = Theme.textSoft,
		LayoutOrder = 2,
		Parent = frame17
	})

	local button5 = UI.button({
		parent = frame16,
		name = "Next",
		size = UDim2.new(1, 0, 0, 54),
		style = "primary",
		icon = "next",
		text = "Next lesson",
		textSize = 18,
		layoutOrder = 2,
		onClick = function()
			fwd.nextLesson()
		end
	})

	UI.button({
		parent = frame16,
		name = "Again",
		size = UDim2.new(1, 0, 0, 44),
		style = "secondary",
		icon = "replay",
		text = "Practise again",
		textSize = 16,
		layoutOrder = 3,
		onClick = function()
			if state.course and state.lesson then
				fwd.startLesson(state.course, state.lesson)
			end
		end
	})

	UI.button({
		parent = frame16,
		name = "Play",
		size = UDim2.new(1, 0, 0, 44),
		style = "secondary",
		icon = "pawn",
		text = "Play a game",
		textSize = 16,
		layoutOrder = 4,
		onClick = function()
			leaveBoard() -- inferred equivalent call
			self.goHome()
		end
	})

	local function setFeedback(kind, text6)
		local v16 = "flag"
		local imageColor = Theme.textDim

		if kind == "good" then
			imageColor = teal
			v16 = "check"
		elseif kind == "bad" then
			imageColor = color
			v16 = "close"
		elseif kind == "hint" then
			imageColor = color2
			v16 = "bulb"
		elseif kind == "info" then
			imageColor = color2
			v16 = "info"
		elseif kind == "wait" then
			imageColor = Theme.textDim
			v16 = "hourglass"
		end

		Sprites.apply(icon2, v16)
		icon2.ImageColor3 = imageColor

		if text5.Text ~= text6 then
			text5.Text = text6
			UI.textIn(text5, 0.14)

			if kind == "good" or kind == "bad" then
				UI.pop(icon2, 0.5, 0.22)
			end
		end
	end

	local function curStep() -- 6 equivalent calls inferred from this helper
		return state.steps[state.idx]
	end

	local function stepColor(p) -- 3 equivalent calls inferred from this helper
		return p.color or 1
	end

	local function sideName(p): string -- 1 equivalent call inferred from this helper
		return if p == 1 then "White" else "Black"
	end

	local function lessonTotal() -- 1 equivalent call inferred from this helper
		return #state.lesson.steps + (state.lesson.practice and state.practice ~= "failed" and state.practiceTotal or 0)
	end

	local function goalText(data) -- 1 equivalent call inferred from this helper
		if data.practice then
			return "Find the best move for " .. sideName(stepColor(data)) .. "." -- inferred equivalent call
		end

		local v16 = state.k + 1
		return data.goals and data.goals[v16] or data.goal or "Your move."
	end

	function lesson2.refresh()
		local lesson = state.lesson

		if not lesson then
			return
		end

		frame10.Visible = not state.finished
		frame16.Visible = state.finished
		v12:setText(state.course and state.course.title or "Back")

		if state.finished then
			local course = state.course
			local lessonOf = fwd.nextLessonOf(course, lesson)
			button5:setText(lessonOf and "Next: " .. lessonOf.title or "Back to courses")
			local text6 = "You finished " .. lesson.title .. "."

			if state.practiceTotal > 0 and state.practice == "ready" then
				text6 ..= string.format(
					" Practice: %d of %d solved first try.",
					state.practiceSolved,
					state.practiceTotal
				)
			end

			if lessonCount(course) <= doneCount(course) then -- inferred equivalent call
				text6 ..= " That's the whole " .. course.title .. " course!"
			end

			v15.Text = text6
		else
			local v16 = math.max(1, lessonTotal()) -- inferred equivalent call
			UI.tween(v13, 0.25, {
				Size = UDim2.fromScale(math.clamp((state.idx - 1 + (state.complete and 1 or 0)) / v16, 0, 1), 1)
			})
			Sprites.apply(icon, lesson.piece or "wP")
			icon.ImageColor3 = Color3.new(1, 1, 1)
			text3.Text = lesson.title
			local v17 = curStep() -- inferred equivalent call

			if state.waiting or not v17 then
				text4.Text = "Practice"
				v14.Text = "Getting your practice puzzles ready..."
				local _textDim = Theme.textDim

				local textDim = Theme.textDim

				Sprites.apply(icon2, "hourglass")
				icon2.ImageColor3 = textDim

				if text5.Text ~= "Loading..." then
					text5.Text = "Loading..."
					UI.textIn(text5, 0.14)
				end

				button2:setVisible(false)
				frame15.Visible = false
			else
				if v17.practice then
					text4.Text = string.format(
						"Practice %d of %d · %s",
						v17.practice,
						state.practiceTotal,
						v17.theme or "Puzzle"
					)
					v14.Text = v17.practice == 1
						and "Now real puzzles from real games. They may take more than one move."
						or "Puzzle rated " .. tostring(v17.rating or "") .. ". Take your time."
				else
					text4.Text = string.format("Step %d of %d", state.idx, #lesson.steps)
					v14.Text = v17.text or ""
				end

				button2:setVisible(v17.info == true)
				frame15.Visible = not v17.info
				button3:setEnabled(not (state.complete or state.busy))
				button4:setEnabled(not (state.complete or state.busy))

				if v17.info then
					local _textDim = Theme.textDim

					Sprites.apply(icon2, "info")
					icon2.ImageColor3 = color2

					if text5.Text ~= "Read, then press Continue." then
						text5.Text = "Read, then press Continue."
						UI.textIn(text5, 0.14)
					end
				elseif state.complete then
					local text6 = v17.practice and "Solved!" or "Nice!"
					local _textDim = Theme.textDim

					Sprites.apply(icon2, "check")
					icon2.ImageColor3 = teal

					if text5.Text ~= text6 then
						text5.Text = text6
						UI.textIn(text5, 0.14)

						UI.pop(icon2, 0.5, 0.22)
					end
				else
					if state.msg then
						setFeedback(state.msg.kind, state.msg.text)
						return
					end

					local text6 = goalText(v17) -- inferred equivalent call
					local textDim = Theme.textDim

					Sprites.apply(icon2, "flag")
					icon2.ImageColor3 = textDim

					if text5.Text ~= text6 then
						text5.Text = text6
						UI.textIn(text5, 0.14)
					end
				end
			end
		end
	end

	local frame19 = UI.new("Frame", {
		Name = "LessonTints",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Parent = self.board.hintLayer
	})

	local frames = {}

	local function clearTints() -- 2 equivalent calls inferred from this helper
		for _, v16 in frames do
			v16:Destroy()
		end

		frames = {}
	end

	local function placeTint(p, color4)
		local v16 = color4 == "red"
		local frame20 = UI.new("Frame", {
			Name = "Tint" .. p,
			Size = UDim2.fromScale(0.125, 0.125),
			Position = self.board:sqPos(p),
			BackgroundColor3 = v16 and Color3.new(0, 0, 0) or v[color4] or color2,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Parent = frame19
		})

		if v16 then
			local icon3 = UI.icon("close", 40, Color3.new(1, 1, 1), {
				Name = "Cross",
				Size = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Parent = frame20
			})

			UI.pop(icon3, 0.5, 0.25)
			UI.tween(frame20, 0.15, { BackgroundTransparency = 0.5 })
		else
			local stroke = UI.stroke(Color3.new(1, 1, 1), 2, 0.35)
			stroke.Parent = frame20
			UI.tween(frame20, 0.15, { BackgroundTransparency = 0.4 })
		end

		frames[p] = frame20
	end

	local function repositionTints() -- 1 equivalent call inferred from this helper
		for k, v16 in frames do
			v16.Position = self.board:sqPos(k)
		end
	end
	local function clearMarks()
		self.board:setArrow("hint", nil)

		self.board:setArrow("lesson" .. 1, nil)
		self.board:setArrow("lesson" .. 2, nil)
		self.board:setArrow("lesson" .. 3, nil)
		self.board:setArrow("lesson" .. 4, nil)

		self.board:setTint("tut", nil)
		self.board:setMoveBadge(nil)
		clearTints() -- inferred equivalent call
	end

	local function linesOf(p)
		local result = {}

		for _, v16 in p.lines or p.line and { p.line } or {} do
			table.insert(result, v16)
		end

		return result
	end

	local function nextExpected() -- 3 equivalent calls inferred from this helper
		local cand = state.cands[1]
		return cand and cand[state.k + 1]
	end

	function fwd.hint(p)
		local expected = nextExpected() -- inferred equivalent call

		if not expected or state.complete then
			return
		end

		self.board:setArrow("hint", sq(string.sub(expected, 1, 2)), sq(string.sub(expected, 3, 4)), color2, 0.15) -- inferred equivalent call

		if p then
			state.misses += 1
			state.msg = { kind = "hint", text = "Follow the arrow." }
			lesson2.refresh()
		end
	end

	local function newSession(p)
		local myColor = stepColor(p) -- inferred equivalent call
		local myInfo = self.myInfo(nil)
		local v16 = {
			display = p.practice and "Puzzle" or "Coach"
		}
		local tutorial = Session.new("tutorial", {
			startFen = p.fen or Courses.START,
			myColor = myColor,
			white = myColor == 1 and myInfo or v16,
			black = myColor == 1 and v16 or myInfo
		})

		state.session = tutorial
		return tutorial
	end

	local function playOpponent()
		local session = state.session
		local v16 = curStep() -- inferred equivalent call
		local visit = state.visit
		local idx = state.idx

		if not session or not v16 or state.complete then
			return
		end

		local cand = state.cands[1]

		if not cand or state.k >= #cand or session.engine.side == stepColor(v16) then -- inferred equivalent call
			return
		end

		state.busy = true
		task.delay(0.55, function()
			if state.visit ~= visit or state.idx ~= idx or self.session ~= session then
				return
			end

			state.busy = false
			local v17 = cand[state.k + 1]
			local cands = {}

			for _, cand2 in state.cands do
				if cand2[state.k + 1] == v17 then
					table.insert(cands, cand2)
				end
			end

			state.cands = cands
			local viewPly = session:applyUci(v17)

			if viewPly then
				state.k += 1
				session.viewPly = viewPly
				self.render()
				Sound.forMove(session.flags[viewPly])

				if state.k >= #cand then
					fwd.completeStep()
					return
				end

				lesson2.refresh()
				playOpponent()
			else
				warn("[Learn] bad line move " .. tostring(v17) .. " in " .. tostring(state.lesson and state.lesson.id))
				fwd.nextStep()
			end
		end)
	end

	function fwd.startStep(idx)
		state.idx = idx
		state.complete = false
		state.busy = false
		state.msg = nil
		state.misses = 0
		state.k = 0
		local v16 = curStep() -- inferred equivalent call

		if v16 then
			state.waiting = false
			state.cands = linesOf(v16)
			local session = newSession(v16)

			if v16.info then
				session.over = true
			end

			self.modals.closeAll()
			self.setSession(session)
			clearMarks()

			if v16.tints then
				for i, tint in ipairs(v16.tints) do
					if i <= 24 then
						placeTint(sq(tint), v16.tints.color) -- inferred equivalent call
					end
				end
			end

			if v16.info and v16.arrows then
				for k, arrow in v16.arrows do
					if k <= 4 then
						self.board:setArrow(
							"lesson" .. k,
							sq(string.sub(arrow, 1, 2)), -- inferred equivalent call
							sq(string.sub(arrow, 3, 4)), -- inferred equivalent call
							color3,
							0.2
						)
					end
				end
			end

			if pages.current ~= "lesson" then
				pages.show("lesson")
			end

			lesson2.refresh()
			playOpponent()
		else
			state.waiting = true
			lesson2.refresh()
		end
	end

	function fwd.completeStep()
		local v16 = curStep() -- inferred equivalent call
		local session = state.session
		state.complete = true
		state.busy = false

		if session then
			session.over = true
			self.render()
			local lastMove = session.lastMoves[#session.ucis]

			if lastMove then
				self.board:setTint("tut", lastMove.to, teal, 0.45)
				self.board:setMoveBadge(lastMove.to, teal, nil, "check")
			end
		end

		self.board:setArrow("hint", nil)
		Sound.play("success")

		if v16 and v16.practice and state.misses == 0 then
			state.practiceSolved += 1
		end

		lesson2.refresh()
		local visit = state.visit
		local idx = state.idx
		task.delay(1.1, function()
			if state.visit == visit and state.idx == idx and state.complete then
				fwd.nextStep()
			end
		end)
	end

	function fwd.nextStep()
		if not state.lesson then
			return
		end

		if state.idx == 1 then
			track("step")
		end

		if state.idx == #state.lesson.steps then
			track("taught")
		end

		local v16

		if #state.lesson.steps > state.idx then
			v16 = true
		else
			v16 = state.lesson.practice

			if v16 then
				if state.practice == "loading" then
					v16 = true
				elseif state.practice == "ready" then
					v16 = state.idx < #state.steps
				else
					v16 = false
				end
			end
		end

		if v16 then
			fwd.startStep(state.idx + 1)
		else
			fwd.finishLesson()
		end
	end

	function Learn.markDone(id)
		if not id or state.done[id] then
			return
		end

		state.done[id] = true
		task.spawn(function()
			self.request({ type = "learnDone", id = id })
		end)
		learn.refresh()
	end

	function fwd.finishLesson()
		state.finished = true
		state.complete = false
		state.waiting = false
		clearMarks()

		if state.session then
			state.session.over = true
			self.render()
		end

		Learn.markDone(state.lesson.id)
		track("done", {
			s = state.practiceSolved,
			t = state.practice == "ready" and state.practiceTotal or 0
		})
		Sound.play("win")
		local frame20 = self.board.frame
		local v16 = frame20.AbsolutePosition + frame20.AbsoluteSize / 2
		pcall(UI.confetti, self.gui, Vector2.new(v16.X, v16.Y), {
			count = 40,
			spread = math.max(120, frame20.AbsoluteSize.X * 0.45),
			zindex = 40
		})
		lesson2.refresh()
	end

	function fwd.nextLessonOf(p, p2)
		if not (p and p.lessons) then
			return nil
		end

		for k, lesson in p.lessons do
			if lesson == p2 then
				return p.lessons[k + 1]
			end
		end

		return nil
	end

	function fwd.nextLesson()
		local lessonOf = fwd.nextLessonOf(state.course, state.lesson)

		if lessonOf then
			fwd.startLesson(state.course, lessonOf)
		else
			pages.show("learn")
		end
	end

	local function practiceSteps(puzzles)
		local result = {}

		for _, item in puzzles do
			if not (type(item) == "table" and type(item.fen) == "string" and type(item.moves) == "table") then
				continue
			end

			if not (#item.moves >= 2) then
				continue
			end

			local success, result2 = pcall(Engine.new, item.fen)

			if success then
				table.insert(result, {
					fen = item.fen,
					color = -result2.side,
					line = item.moves,
					mate = true,
					practice = #result + 1,
					theme = item.theme,
					rating = item.rating
				})
			end
		end

		return result
	end

	function fwd.startLesson(course, lesson)
		if self.inLiveGame() then
			self.toast("Finish your game first")
			return
		end

		if self.searching then
			self.cancelSearch()
		end

		state.visit += 1

		state.run = (state.run or 0) + 1
		local run = state.run
		state.course = course
		state.lesson = lesson
		state.finished = false
		state.steps = table.clone(lesson.steps)
		state.sent = {}
		track("start")
		state.practiceSolved = 0
		state.practiceTotal = lesson.practice and lesson.practice.count or 0
		state.practice = nil

		if lesson.practice then
			state.practice = "loading"
			task.spawn(function()
				local request = self.request({ type = "learnPractice", id = lesson.id })

				if state.run ~= run then
					return
				end

				local v16 = type(request) == "table"
					and request.ok
					and type(request.puzzles) == "table"
					and practiceSteps(request.puzzles)
					or {}

				if #v16 == 0 then
					state.practice = "failed"
					state.practiceTotal = 0
				else
					state.practice = "ready"
					state.practiceTotal = #v16

					for _, v17 in v16 do
						table.insert(state.steps, v17)
					end
				end

				if not state.waiting or pages.current ~= "lesson" then
					lesson2.refresh()
				elseif state.practice == "ready" then
					fwd.startStep(state.idx)
				else
					fwd.finishLesson()
				end
			end)
		end

		fwd.startStep(1)
	end

	local function onMove(p, p2, p3, p4): boolean
		local session = self.session
		local v16 = curStep() -- inferred equivalent call

		if not v16 or state.busy or state.complete or state.finished then
			return false
		end

		local move = session:findMove(p, p2, p3)

		if not move then
			Sound.play("illegal")
			return false
		end

		local v17 = session.engine:moveToUci(move)
		local cands = {}

		for _, cand in state.cands do
			if cand[state.k + 1] == v17 then
				table.insert(cands, cand)
			end
		end

		local viewPly = session:applyMove(move)
		session.viewPly = viewPly
		local flag = session.flags[viewPly]
		local lastMove = session.lastMoves[viewPly]
		local instant = p4 and { [p2] = true } or nil
		self.board:setArrow("hint", nil)
		self.board:setTint("tut", nil)
		self.board:setMoveBadge(nil)
		local v18 = session.engine:status() == "checkmate"
		state.msg = nil

		if #cands > 0 then
			state.cands = cands
			state.k += 1
			self.render({ instant = instant })
			Sound.forMove(flag)
			local v19 = false

			for _, v20 in cands do
				if #v20 <= state.k then
					v19 = true
				end
			end

			if v19 or v18 then
				fwd.completeStep()
			else
				state.msg = v16.practice and { kind = "good", text = "Good move! Keep going." } or nil
				lesson2.refresh()
				playOpponent()
			end

			return true
		elseif v16.any and state.k == 0 or v16.mate and v18 then
			state.k += 1
			self.render({ instant = instant })
			Sound.forMove(flag)
			fwd.completeStep()
			return true
		else
			self.render({ instant = instant })
			Sound.play("error")
			self.board:setTint("tut", lastMove.to, color, 0.4)
			self.board:setMoveBadge(lastMove.to, color, nil, "close")
			state.busy = true
			state.misses += 1
			state.msg = {
				kind = "bad",
				text = v16.wrong and v16.wrong[v17] or v16.practice and "Not the best move. Try again." or "Not quite. Try again."
			}
			lesson2.refresh()
			local visit = state.visit
			local idx = state.idx
			task.delay(0.8, function()
				if state.visit ~= visit or state.idx ~= idx or self.session ~= session then
					return
				end

				state.busy = false
				session:undo()
				session.viewPly = #session.ucis
				self.board:setTint("tut", nil)
				self.board:setMoveBadge(nil)
				self.render()

				if not v16.practice or state.misses >= 2 then
					fwd.hint(false)
				end

				lesson2.refresh()
			end)
			return true
		end
	end

	local tutorialMove = self.tutorialMove
	function self.tutorialMove(p, p2, p3, p4)
		if state.session and self.session == state.session then
			return onMove(p, p2, p3, p4)
		end

		if tutorialMove then
			return tutorialMove(p, p2, p3, p4)
		end

		return false
	end

	local onRender = self.onRender
	function self.onRender(p)
		if onRender then
			onRender(p)
		end

		if next(frames) then
			if p == state.session then
				repositionTints() -- inferred equivalent call
			else
				clearTints() -- inferred equivalent call
			end
		end

		if state.session and p ~= state.session then
			state.session = nil
			state.visit += 1

			self.board:setArrow("lesson" .. 1, nil)
			self.board:setArrow("lesson" .. 2, nil)
			self.board:setArrow("lesson" .. 3, nil)
			self.board:setArrow("lesson" .. 4, nil)
		end
	end

	function lesson2.onShow()
		if state.lesson and not state.finished and self.session ~= state.session and not self.inLiveGame() then
			task.defer(function()
				if
					pages.current == "lesson"
					and self.session ~= state.session
					and state.lesson
					and not state.finished
				then
					state.visit += 1

					if state.practice == "failed" and state.idx > #state.steps then
						fwd.finishLesson()
					else
						fwd.startStep(state.idx)
					end
				end
			end)
		end

		lesson2.refresh()
	end

	function fwd.resume()
		if not state.lesson or state.finished then
			return
		end

		if self.inLiveGame() then
			self.toast("Finish your game first")
		else
			pages.show("lesson")
		end
	end

	function fwd.upNextGo()
		local v16 = v7

		if not v16 then
			return
		end

		if v16.resume then
			fwd.resume()
		elseif v16.lesson then
			fwd.startLesson(v16.course, v16.lesson)
		else
			self.openTutorial(false)
		end
	end

	function self.openLearn()
		if self.inLiveGame() then
			self.toast("Finish your game first")
		else
			pages.show("learn")
		end
	end

	function Learn.debug(data)
		if data.reset then
			local request = self.request({ type = "learnReset" })

			if type(request) == "table" and request.ok then
				state.done = {}
				learn.refresh()
			end
		end

		if type(data.mark) == "table" then
			for _, v16 in data.mark do
				Learn.markDone(v16)
			end
		end

		if data.open then
			self.openLearn()
		end

		if data.course then
			for _, item in Courses.list do
				if item.id == data.course then
					fwd.openCourse(item)
				end
			end
		end

		if data.lesson then
			local v16 = Courses.lesson[data.lesson]

			if v16 and v16.steps then
				fwd.startLesson(Courses.courseOf[data.lesson], v16)
			end
		end

		if data.play then
			local v16 = type(data.play) == "string" and data.play or nextExpected() -- inferred equivalent call

			if v16 then
				local v17 = ({ q = 5, r = 4, b = 3, n = 2 })[string.sub(v16, 5, 5)]
				self.tutorialMove(sq(string.sub(v16, 1, 2)), sq(string.sub(v16, 3, 4)), v17, false) -- inferred equivalent call
			end
		end

		if data.next then
			fwd.nextStep()
		end

		if data.upNext then
			fwd.upNextGo()
		end

		local v16 = curStep() -- inferred equivalent call
		local v17 = {
			upNext = frame3.Visible and text.Text .. ": " .. v5.Text or nil,
			page = pages.current,
			lesson = state.lesson and state.lesson.id,
			idx = state.idx,
			steps = #state.steps,
			info = v16 and v16.info or false,
			practice = state.practice,
			practiceTotal = state.practiceTotal,
			solved = state.practiceSolved,
			k = state.k,
			complete = state.complete,
			busy = state.busy,
			finished = state.finished,
			waiting = state.waiting,
			msg = state.msg and state.msg.text,
			feedback = text5.Text,
			next = nextExpected(), -- inferred equivalent call
			fen = self.session and self.session.engine:getFen(),
			done = 0
		}

		local v18 = {}

		for k in state.done do
			table.insert(v18, k)
		end

		v17.done = table.concat(v18, ",")
		return v17
	end

	Learn._fwd = fwd
end

return Learn