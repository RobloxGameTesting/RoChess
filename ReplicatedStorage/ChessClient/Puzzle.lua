local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Chess = ReplicatedStorage:WaitForChild("Chess")
local Engine = require(Chess.Engine)
require(Chess.Config)
local parent = script.Parent
local Theme = require(parent.Theme)
local UI = require(parent.UI)
local Sound = require(parent.Sound)
local Session = require(parent.Session)

local green = Theme.green
local color = Color3.fromRGB(224, 76, 62)
local color2 = Color3.fromRGB(96, 165, 230)

local v = {
	{
		id = "m3",
		label = "3 min",
		icon = "timer",
		blurb = "Three minutes on the clock. Three mistakes and you're out."
	},
	{
		id = "m5",
		label = "5 min",
		icon = "timer",
		blurb = "Five minutes on the clock. Three mistakes and you're out."
	},
	{
		id = "surv",
		label = "Survival",
		icon = "crown",
		blurb = "No clock. Keep going until you make three mistakes."
	}
}

local v2 = {}
local Puzzle = {}

for _, v3 in v do
	v2[v3.id] = v3
end

local function sideToMove(fen): number -- 1 equivalent call inferred from this helper
	return if string.split(fen, " ")[2] == "b" then -1 else 1
end

local function fmtTime(p) -- 1 equivalent call inferred from this helper
	local v3 = math.max(0, (math.ceil(p)))
	return string.format("%d:%02d", v3 // 60, v3 % 60)
end

local function fmtNum(value)
	local v3 = tostring((math.floor(value or 0)))
	local v4 = string.reverse(string.gsub(string.reverse(v3), "(%d%d%d)", "%1,"))
	return (string.gsub(v4, "^,", ""))
end

Puzzle.fmtNum = fmtNum

function Puzzle:install()
	local pages = self.pages
	local localPlayer = Players.LocalPlayer

	local v3 = {}
	local v4 = {}

	local function meInfo(p)
		local puzzle = self.profile and self.profile.puzzle
		local v5 = {
			userId = localPlayer.UserId,
			name = localPlayer.Name,
			display = localPlayer.DisplayName,
			rating = 0,
			prov = 0
		}
		local rating

		if p and puzzle then
			rating = puzzle.r or nil
		end

		v5.rating = rating
		v5.prov = p and puzzle and puzzle.prov or nil
		return v5
	end

	local function schedule(p, duration, callback) -- 3 equivalent calls inferred from this helper
		local pz = p.pz
		pz.token += 1
		local token = pz.token
		task.delay(duration, function()
			if self.session == p and pz.token == token then
				callback()
			end
		end)
	end

	local function clearFeedback() -- 3 equivalent calls inferred from this helper
		self.board:setTint("move", nil)
		self.board:setTint("hint", nil)
		self.board:setArrow("hint", nil)
		self.board:setMoveBadge(nil)
	end

	local function playNext(object): boolean -- 2 equivalent calls inferred from this helper
		local pz = object.pz
		local v5 = pz.sol[pz.step]
		local viewPly = v5 and object:applyUci(v5)

		if not viewPly then
			return false
		end

		pz.step += 1
		object.viewPly = viewPly
		self.render()
		Sound.forMove(object.flags[viewPly])
		return true
	end

	local function runPremove(object) -- 1 equivalent call inferred from this helper
		if not self.premove then
			return
		end

		local shiftPremove = self.board:shiftPremove()
		task.defer(function()
			if self.session ~= object then
				return
			end

			if
				object:isMyTurn()
				and not object.pz.busy
				and not object.pz.done
				and object:findMove(shiftPremove.from, shiftPremove.to, shiftPremove.promo)
			then
				if not self.onBoardMove(shiftPremove.from, shiftPremove.to, shiftPremove.promo, false) then
					self.board:clearPremove()
				end
			else
				self.board:clearPremove()
			end
		end)
	end

	local function opponentMove(object, duration) -- 3 equivalent calls inferred from this helper
		local pz = object.pz
		pz.busy = true
		schedule(object, duration, function() -- inferred equivalent call
			self.board:setTint("move", nil)
			self.board:setMoveBadge(nil)
			playNext(object) -- inferred equivalent call
			pz.busy = false
			local v5 = v3[object.kind]

			if v5.onTurn then
				v5.onTurn(object)
			end

			runPremove(object) -- inferred equivalent call
		end)
	end

	local function newSession(p, p2, p3, p4)
		local myColor = -sideToMove(p2.fen) -- inferred equivalent call
		local session = Session.new(p, {
			startFen = p2.fen,
			myColor = myColor,
			white = myColor == 1 and p3 or p4,
			black = myColor == 1 and p4 or p3
		})

		session.pz = {
			data = p2,
			sol = table.clone(p2.moves),
			step = 1,
			played = {},
			busy = true,
			token = 0,
			hint = 0
		}

		return session
	end

	local function solved(state) -- 1 equivalent call inferred from this helper
		local pz = state.pz
		pz.done = true
		pz.busy = false
		pz.outcome = "solved"
		state.over = true
		self.render({ animate = false })
		v3[state.kind].onSolved(state)
	end

	local function takeBackWrong(object) -- 2 equivalent calls inferred from this helper
		local pz = object.pz

		if not pz.wrong then
			return
		end

		pz.wrong = false
		object:undo()
		object.viewPly = #object.ucis
		clearFeedback() -- inferred equivalent call
		self.premove = nil
		self.board:setPremove(nil)
		self.render()
	end

	local function applyResult(data, result)
		local pz = data.pz
		pz.reported = true

		if type(result) ~= "table" then
			return
		end

		pz.result = result

		if result.player then
			if self.profile then
				self.profile.puzzle = result.player
			end

			local white = data.myColor == 1 and data.white or data.black
			white.rating = result.player.r
			white.prov = result.player.prov

			if self.session == data then
				self.refreshBars()
			end
		end
	end

	local function adoptSolution(p, sol)
		if type(sol) ~= "table" or #sol == 0 then
			return
		end

		p.pz.sol = table.clone(sol)
		p.pz.data.moves = table.clone(sol)
		p.pz.data.live = nil
		p.pz.live = false
	end

	local function revealFirst(p, callback): boolean
		local pz = p.pz

		if not pz.live then
			return false
		end

		if pz.revealing then
			return true
		end

		pz.revealing = true
		pz.busy = true
		pz.token += 1
		task.spawn(function()
			local request = self.request({ type = "puzzleReveal", id = pz.data.id })
			pz.revealing = false
			pz.busy = false

			if self.session ~= p then
				return
			end

			if not (request and request.sol) then
				self.toast("Couldn't reach the server. Try again.")
				return
			end

			pz.missed = true
			adoptSolution(p, request.sol)
			applyResult(p, request.result)
			callback()
		end)
		return true
	end

	local judgeMove

	function self.puzzleMove(p, p2, p3, p4): boolean
		local session = self.session
		local pz = session and session.pz

		if not pz or pz.busy or pz.done or pz.wrong then
			return false
		end

		local move = session:findMove(p, p2, p3)

		if not move then
			Sound.play("illegal")
			return false
		end

		local uci = session.engine:moveToUci(move)
		local v5 = pz.sol[pz.step]
		local viewPly = session:applyMove(move)
		session.viewPly = viewPly
		local v6 = session.engine:status() == "checkmate"
		clearFeedback() -- inferred equivalent call
		self.render({
			instant = p4 and { [p2] = true } or nil
		})
		table.insert(pz.played, uci)

		if not pz.live then
			judgeMove(session, viewPly, uci == v5 or v6, v6)
			return true
		end

		pz.busy = true
		pz.token += 1
		local token = pz.token
		local run

		if session.kind == "rush" then
			run = pz.run or nil
		else
			run = nil
		end

		local v7 = run and { type = "rushMove", token = run.token, i = run.idx, uci = uci }
			or { type = "puzzleMove", id = pz.data.id, uci = uci }
		task.spawn(function()
			local request = self.request(v7)

			if self.session ~= session or pz.token ~= token then
				return
			end

			pz.busy = false

			if type(request) == "table" and not request.illegal and (not request.stale or request.sol) then
				if request.ok and not request.done then
					pz.sol[pz.step] = uci
					pz.sol[pz.step + 1] = request.reply
					judgeMove(session, viewPly, true, false)
				else
					adoptSolution(session, request.sol)
					applyResult(session, request.result)
					judgeMove(session, viewPly, request.ok == true, request.ok == true)
				end
			else
				table.remove(pz.played)
				session:undo()
				session.viewPly = #session.ucis
				self.render()

				if type(request) == "table" and request.stale and run then
					if v4.endRush then
						v4.endRush(request.over and "time" or "ended")
					end
				elseif type(request) == "table" and request.stale and v4.loadNext then
					v4.loadNext()
				else
					self.toast("Couldn't reach the server. Try that move again.")
				end
			end
		end)
		return true
	end

	judgeMove = function(session, p, p2, p3)
		local pz = session.pz
		local lastMove = session.lastMoves[p]

		if p2 then
			Sound.forMove(session.flags[p])
			pz.step += 1
			pz.hint = 0
			self.board:setTint("move", lastMove.to, green, 0.45)
			self.board:setMoveBadge(lastMove.to, green, nil, "check")

			if p3 or pz.step > #pz.sol then
				solved(session) -- inferred equivalent call
			else
				Sound.play("step")
				v3[session.kind].onStep(session)
				opponentMove(session, 0.45) -- inferred equivalent call
			end
		else
			Sound.play("error")
			pz.wrong = true
			self.board:setTint("move", lastMove.to, color, 0.4)
			self.board:setMoveBadge(lastMove.to, color, nil, "close")
			v3[session.kind].onWrong(session)
			table.remove(pz.played)
			schedule(session, 0.8, function() -- inferred equivalent call
				v3[session.kind].afterWrong(session)
			end)
		end
	end

	local function reveal(data) -- 2 equivalent calls inferred from this helper
		(data.myColor == 1 and data.black or data.white).rating = data.pz.data.rating

		if self.session == data then
			self.refreshBars()
		end
	end

	local function statusCard(parent2, layoutOrder)
		local frame = UI.new("Frame", {
			Name = "Status",
			Size = UDim2.new(1, 0, 0, 86),
			BackgroundColor3 = Theme.panelLight,
			LayoutOrder = layoutOrder,
			Parent = parent2
		}, { UI.corner(8) })
		local frame2 = UI.new("Frame", {
			Name = "Accent",
			Size = UDim2.new(0, 5, 1, -16),
			Position = UDim2.fromOffset(0, 8),
			BackgroundColor3 = Theme.divider,
			Parent = frame
		}, { UI.corner(3) })
		local frame3 = UI.new("Frame", {
			Name = "Chip",
			Size = UDim2.fromOffset(38, 38),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 18, 0.5, 0),
			BackgroundColor3 = Color3.new(1, 1, 1),
			Parent = frame
		}, { UI.corner(7) })
		local stroke = UI.stroke(Color3.fromRGB(90, 88, 85), 2, 0)
		stroke.Parent = frame3
		local icon = UI.icon("check", 26, Color3.new(1, 1, 1), {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Visible = false,
			Parent = frame3
		})

		local text = UI.text({
			Name = "Title",
			Text = "",
			FontFace = Theme.fontHeavy,
			TextSize = 22,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Size = UDim2.new(1, -80, 0, 28),
			Position = UDim2.fromOffset(68, 14),
			Parent = frame
		})

		local text2 = UI.text({
			Name = "Sub",
			Text = "",
			TextSize = 15,
			TextColor3 = Theme.textDim,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true,
			Size = UDim2.new(1, -80, 0, 36),
			Position = UDim2.fromOffset(68, 44),
			Parent = frame
		})

		local v5 = {
			white = { bg = Color3.fromRGB(245, 245, 245), accent = Theme.divider },
			black = { bg = Color3.fromRGB(32, 31, 29), accent = Theme.divider },
			good = { bg = green, accent = green, icon = "check" },
			bad = { bg = color, accent = color, icon = "close" },
			info = { bg = Theme.puzzle, accent = Theme.puzzle, icon = "puzzle" },
			rush = { bg = Theme.rush, accent = Theme.rush, icon = "bolt" },
			shown = { bg = Theme.button, accent = Theme.textDim, icon = "eye" }
		}

		local v6 = { frame = frame }
		function v6.set(kind, value, value2)
			local v7 = v5[kind] or v5.info
			local v8 = v6.kind ~= kind or text.Text ~= (value or "")
			v6.kind = kind
			UI.to(frame3, UI.SNAP, { BackgroundColor3 = v7.bg })
			stroke.Transparency = v7.icon and 1 or 0
			UI.to(frame2, UI.SNAP, { BackgroundColor3 = v7.accent })

			if v8 then
				UI.pop(frame3, 0.6, 0.22)

				if text.Text ~= (value or "") then
					task.defer(UI.textIn, text, 0.12)
					task.defer(UI.textIn, text2, 0.16)
				end
			end

			icon.Visible = v7.icon ~= nil

			if v7.icon then
				local Sprites = require(Chess.Sprites)
				Sprites.apply(icon, v7.icon)
			end

			text.Text = value or ""
			text2.Text = value2 or ""
		end
		return v6
	end

	local function buttonRow(parent2, layoutOrder, items)
		local frame = UI.new("Frame", {
			Name = "Buttons",
			Size = UDim2.new(1, 0, 0, 50),
			BackgroundTransparency = 1,
			LayoutOrder = layoutOrder,
			Parent = parent2
		}, { UI.list(Enum.FillDirection.Horizontal, 6, Enum.HorizontalAlignment.Center) })
		local buttons = {}

		for _, item in items do
			local button = UI.button({
				parent = frame,
				size = UDim2.new(0.5, -3, 1, 0),
				style = item.style or "secondary",
				icon = item.icon,
				iconSize = 20,
				text = item.text,
				textSize = 16,
				gap = 6,
				onClick = item.onClick
			})

			button:setVisible(false)
			buttons[item.key] = button
		end

		local v5 = { frame = frame, buttons = buttons }
		function v5.show(list)
			local v6 = {}

			for k, item in list do
				v6[item] = k
			end

			local count = #list

			for k, v7 in buttons do
				local layoutOrder2 = v6[k]

				if layoutOrder2 then
					v7.holder.LayoutOrder = layoutOrder2
					v7.holder.Size = UDim2.new(1 / count, (count - 1) * -6 / count, 1, 0)
				end

				v7:setVisible(layoutOrder2 ~= nil)
			end

			UI.reveal(frame, count > 0)
		end
		return v5
	end

	local v5 = { current = nil, loading = false, error = false, req = 0 }
	local startPuzzle
	local loadNext
	local giveHint
	local showSolution

	local page, parent2 = pages.newPage("puzzles", "Puzzles", "puzzle", Theme.puzzle, true)
	local puzzles = { frame = page }
	pages.puzzles = puzzles

	local v6 = statusCard(parent2, 1)

	local frame = UI.new("Frame", {
		Name = "Rating",
		Size = UDim2.new(1, 0, 0, 72),
		BackgroundColor3 = Theme.panelLight,
		LayoutOrder = 2,
		Parent = parent2
	}, { UI.corner(8) })
	UI.text({
		Text = "Puzzle Rating",
		TextSize = 13,
		TextColor3 = Theme.textDim,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(0.62, -14, 0, 16),
		Position = UDim2.fromOffset(14, 10),
		Parent = frame
	})

	local frame2 = UI.new(
		"Frame",
		{
			Size = UDim2.new(0.62, -14, 0, 36),
			Position = UDim2.fromOffset(14, 28),
			BackgroundTransparency = 1,
			Parent = frame
		},
		{ UI.list(Enum.FillDirection.Horizontal, 8, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center) }
	)
	local text = UI.text({
		Name = "Value",
		Text = "--",
		FontFace = Theme.fontHeavy,
		TextSize = 30,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromScale(0, 1),
		LayoutOrder = 1,
		Parent = frame2
	})

	local text2 = UI.text({
		Name = "Delta",
		Text = "",
		FontFace = Theme.fontHeavy,
		TextSize = 19,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromScale(0, 1),
		LayoutOrder = 2,
		Parent = frame2
	})

	UI.text({
		Text = "Streak",
		TextSize = 13,
		TextColor3 = Theme.textDim,
		TextXAlignment = Enum.TextXAlignment.Right,
		Size = UDim2.new(0.38, -14, 0, 16),
		Position = UDim2.new(0.62, 0, 0, 10),
		Parent = frame
	})

	local frame3 = UI.new(
		"Frame",
		{
			Size = UDim2.new(0.38, -14, 0, 36),
			Position = UDim2.new(0.62, 0, 0, 28),
			BackgroundTransparency = 1,
			Parent = frame
		},
		{ UI.list(Enum.FillDirection.Horizontal, 4, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center) }
	)
	local icon = UI.icon("bolt", 24, Theme.puzzle, { LayoutOrder = 1, Parent = frame3 })
	local text3 = UI.text({
		Text = "0",
		FontFace = Theme.fontHeavy,
		TextSize = 26,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromScale(0, 1),
		LayoutOrder = 2,
		Parent = frame3
	})

	local text4 = UI.text({
		Name = "Stats",
		Text = "",
		TextSize = 14,
		TextColor3 = Theme.textDim,
		Size = UDim2.new(1, 0, 0, 18),
		LayoutOrder = 3,
		Parent = parent2
	})

	local v7 = buttonRow(parent2, 4, {
		{
			key = "hint",
			icon = "bulb",
			text = "Hint",
			onClick = function()
				giveHint()
			end
		},
		{
			key = "solution",
			icon = "eye",
			text = "Solution",
			onClick = function()
				showSolution()
			end
		},
		{
			key = "retry",
			icon = "replay",
			text = "Retry",
			onClick = function()
				if v5.current then
					startPuzzle(v5.current, false)
				end
			end
		},
		{
			key = "analyze",
			icon = "search",
			text = "Analyze",
			onClick = function()
				if self.analyseCurrent then
					self.analyseCurrent()
				end
			end
		},
		{
			key = "next",
			icon = "next",
			text = "Next",
			style = "primary",
			onClick = function()
				loadNext()
			end
		}
	})

	local frame4 = UI.new("Frame", {
		Name = "Info",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.panelLight,
		Visible = false,
		LayoutOrder = 5,
		Parent = parent2
	}, { UI.corner(8), UI.pad(10, 14, 10, 14), UI.list(Enum.FillDirection.Vertical, 4) })
	local text5 = UI.text({
		Text = "",
		FontFace = Theme.fontBold,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 18),
		LayoutOrder = 1,
		Parent = frame4
	})

	local text6 = UI.text({
		Text = "",
		TextSize = 14,
		TextColor3 = Theme.textDim,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 2,
		Parent = frame4
	})

	local text7 = UI.text({
		Name = "Note",
		Text = "",
		TextSize = 13,
		TextColor3 = Theme.textMuted,
		TextWrapped = true,
		Size = UDim2.new(1, 0, 0, 18),
		LayoutOrder = 6,
		Parent = parent2
	})

	UI.button({
		parent = parent2,
		size = UDim2.new(1, 0, 0, 58),
		style = "flat",
		icon = "bolt",
		iconSize = 26,
		iconColor = Theme.rush,
		text = "Puzzle Sprint",
		textSize = 17,
		subtext = "Solve as many as you can, fast",
		align = Enum.HorizontalAlignment.Left,
		padX = 14,
		gap = 12,
		layoutOrder = 7,
		onClick = function()
			if self.openRush then
				self.openRush()
			end
		end
	})

	function puzzles.refresh()
		local puzzle = self.profile and self.profile.puzzle
		text.Text = puzzle and fmtNum(puzzle.r) .. (puzzle.prov and "?" or "") or "--"
		text3.Text = puzzle and tostring(puzzle.streak or 0) or "0"
		icon.ImageColor3 = puzzle and (puzzle.streak or 0) > 0 and Theme.puzzle or Theme.textMuted
		text4.Text = puzzle
			and string.format(
				"Solved %d  ·  Missed %d  ·  Best %s",
				puzzle.w or 0,
				puzzle.l or 0,
				fmtNum(puzzle.best or puzzle.r)
			)
			or ""

		local session = self.session
		local v8

		if session then
			v8 = session.kind == "puzzle" and session.pz
		else
			v8 = session
		end

		local result = v8 and v8.result

		if result and result.rated and result.delta then
			text2.Text = (result.delta >= 0 and "+" or "") .. tostring(result.delta)
			text2.TextColor3 = result.delta >= 0 and green or color
		else
			text2.Text = ""
		end

		v7.buttons.next:setText("Next")
		text7.Text = ""
		frame4.Visible = false

		if v5.error then
			v6.set("bad", "Couldn't load a puzzle", "Check your connection and try again.")
			v7.buttons.next:setText("Try Again")
			v7.show({ "next" })
		elseif v5.loading or not v8 then
			v6.set("info", "Loading puzzle...", "")
			v7.show({})
		else
			local v9 = session.myColor == 1 and "white" or "black"
			local v10 = session.myColor == 1 and "White" or "Black"

			if v8.done then
				if v8.outcome == "solved" and not (v8.missed and v8.rated) then
					v6.set("good", "Solved!", v8.rated and "Great job. Ready for the next one?" or "Nicely done.")
				elseif v8.outcome == "solved" then
					v6.set("good", "Solved", "You found it, but it counts as a miss this time.")
				else
					v6.set("shown", "Solution", "Study the line, then try the next one.")
				end

				v7.show({ "retry", "analyze", "next" })
				local data = v8.data
				frame4.Visible = true
				text5.Text = "Puzzle rating: " .. fmtNum(data.rating)
				text6.Text = data.themes and #data.themes > 0 and "Themes: " .. table.concat(data.themes, ", ") or ""
			elseif v8.msg == "solution" then
				v6.set("shown", "Solution", "Playing through the answer...")
				v7.show({})
			elseif v8.wrong or v8.msg == "wrong" then
				v6.set("bad", "Incorrect", "That's not it. Try again, or see the solution.")
				v7.show({ "hint", "solution", "next" })
			else
				if v8.msg == "step" then
					v6.set("good", "Correct!", "Keep going...")
				else
					v6.set(v9, v10 .. " to Move", "Find the best move for " .. v9 .. ".")
				end

				v7.show(v8.missed and { "hint", "solution", "next" } or { "hint", "solution" })
			end

			if not v8.done then
				if v8.rated then
					if not v8.reported then
						text7.Text = "Using a hint or the solution counts as a miss."
					end
				else
					text7.Text = "Practice attempt: this one isn't rated."
				end
			end
		end
	end
	puzzles.onShow = puzzles.refresh

	local function report(data)
		local pz = data.pz

		if not pz.rated or pz.reported then
			return
		end

		pz.reported = true
		local clone = table.clone(pz.played)
		local id = pz.data.id
		task.spawn(function()
			local request = self.request({ type = "puzzleResult", id = id, moves = clone })
			pz.result = request

			if request and request.player then
				if self.profile then
					self.profile.puzzle = request.player
				end

				local white = data.myColor == 1 and data.white or data.black
				white.rating = request.player.r
				white.prov = request.player.prov

				if self.session == data then
					self.refreshBars()
				end
			end

			if pages.current == "puzzles" then
				puzzles.refresh()
			end
		end)
	end

	v3.puzzle = {
		onTurn = function()
			puzzles.refresh()
		end,
		onStep = function(p)
			p.pz.msg = "step"
			puzzles.refresh()
		end,
		onWrong = function(p)
			local pz = p.pz
			pz.missed = true
			pz.msg = "wrong"
			report(p)
			puzzles.refresh()
		end,
		afterWrong = function(object)
			takeBackWrong(object) -- inferred equivalent call
			puzzles.refresh()
		end,
		onSolved = function(data)
			local pz = data.pz
			pz.msg = "solved"
			Sound.play("success")

			if not pz.missed then
				local frame5 = self.board.frame
				local frame6 = UI.new("Frame", {
					Name = "Fx",
					Size = UDim2.new(),
					BackgroundTransparency = 1,
					ZIndex = 40,
					Parent = frame5
				})
				UI.confetti(frame6, frame5.AbsoluteSize / 2, {
					count = 30,
					spread = frame5.AbsoluteSize.X * 0.35,
					zindex = 40
				})
				task.delay(2.5, frame6.Destroy, frame6)
			end

			report(data)
			reveal(data) -- inferred equivalent call
			puzzles.refresh()
		end
	}

	startPuzzle = function(current, rated)
		v5.current = current
		v5.error = false
		local v8 = newSession("puzzle", current, meInfo(true), {
			display = "Puzzle",
			icon = "puzzle",
			color = Theme.puzzle
		})
		v8.pz.rated = rated
		v8.pz.reported = not rated
		v8.pz.live = rated and current.live == true
		self.setSession(v8)
		puzzles.refresh()
		opponentMove(v8, 0.6) -- inferred equivalent call
	end

	loadNext = function()
		v5.req += 1
		local req = v5.req
		v5.loading = true
		v5.error = false
		puzzles.refresh()
		task.spawn(function()
			local request = self.request({ type = "nextPuzzle" })

			if req ~= v5.req then
				return
			end

			v5.loading = false

			if pages.current ~= "puzzles" then
				return
			end

			if request and request.fen then
				if request.player and self.profile then
					self.profile.puzzle = request.player
				end

				startPuzzle(request, true)
			else
				v5.error = true
				puzzles.refresh()
			end
		end)
	end

	giveHint = function()
		local session = self.session
		local v8

		if session then
			v8 = session.kind == "puzzle" and session.pz
		else
			v8 = session
		end

		if not v8 or v8.done or v8.busy or v8.wrong then
			return
		end

		if v8.rated and not v8.reported then
			self.toast("Hint used: this puzzle counts as a miss")
		end

		local v9 = giveHint
		local pz = session.pz
		local flag

		if pz.live then
			if not pz.revealing then
				pz.revealing = true
				pz.busy = true
				pz.token += 1
				task.spawn(function()
					local request = self.request({ type = "puzzleReveal", id = pz.data.id })
					pz.revealing = false
					pz.busy = false

					if self.session ~= session then
						return
					end

					if not (request and request.sol) then
						self.toast("Couldn't reach the server. Try again.")
						return
					end

					pz.missed = true
					adoptSolution(session, request.sol)
					applyResult(session, request.result)
					v9()
				end)
			end

			flag = true
		else
			flag = false
		end

		if flag then
			return
		end

		v8.missed = true
		report(session)
		v8.hint = math.min(2, v8.hint + 1)
		local v10 = v8.sol[v8.step]
		local algToIndex64 = Engine.algToIndex64((string.sub(v10, 1, 2)))
		local algToIndex64_2 = Engine.algToIndex64((string.sub(v10, 3, 4)))
		self.board:setTint("hint", algToIndex64, color2, 0.35)

		if v8.hint >= 2 then
			self.board:setArrow("hint", algToIndex64, algToIndex64_2, color2, 0.15)
		end

		puzzles.refresh()
	end

	showSolution = function()
		local session = self.session
		local v8

		if session then
			v8 = session.kind == "puzzle" and session.pz
		else
			v8 = session
		end

		if not v8 or v8.done or v8.msg == "solution" or v8.live and v8.busy then
			return
		end

		local v9 = showSolution
		local pz = session.pz
		local flag

		if pz.live then
			if not pz.revealing then
				pz.revealing = true
				pz.busy = true
				pz.token += 1
				task.spawn(function()
					local request = self.request({ type = "puzzleReveal", id = pz.data.id })
					pz.revealing = false
					pz.busy = false

					if self.session ~= session then
						return
					end

					if not (request and request.sol) then
						self.toast("Couldn't reach the server. Try again.")
						return
					end

					pz.missed = true
					adoptSolution(session, request.sol)
					applyResult(session, request.result)
					v9()
				end)
			end

			flag = true
		else
			flag = false
		end

		if flag then
			return
		end

		v8.missed = true
		report(session)
		v8.token += 1
		takeBackWrong(session) -- inferred equivalent call
		clearFeedback() -- inferred equivalent call
		v8.busy = true
		v8.msg = "solution"
		local token = v8.token
		puzzles.refresh()
		task.spawn(function()
			while v8.step <= #v8.sol do
				task.wait(0.65)

				if self.session ~= session or v8.token ~= token then
					return
				end

				if not playNext(session) then -- inferred equivalent call
					break
				end
			end

			v8.done = true
			v8.busy = false
			v8.outcome = "shown"
			session.over = true
			reveal(session) -- inferred equivalent call
			self.render({ animate = false })
			puzzles.refresh()
		end)
	end

	v4.loadNext = loadNext

	function self.openPuzzles()
		if self.inLiveGame() then
			return
		end

		if self.searching then
			self.cancelSearch()
		end

		self.modals.closeAll()
		self.send({ type = "status", status = "puzzle" })
		pages.show("puzzles")
		local session = self.session

		if not session or session.kind ~= "puzzle" then
			loadNext()
		end
	end

	local page2, parent3 = pages.newPage("rush", "Puzzle Sprint", "bolt", Theme.rush, true)
	local rush2 = { frame = page2 }
	pages.rush = rush2

	local frame5 = UI.new("Frame", {
		Name = "Start",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 1,
		Parent = parent3
	}, { UI.list(Enum.FillDirection.Vertical, 10) })
	local frame6 = UI.new("Frame", {
		Name = "Hero",
		Size = UDim2.new(1, 0, 0, 136),
		BackgroundColor3 = Theme.panelLight,
		LayoutOrder = 1,
		Parent = frame5
	}, { UI.corner(8) })
	UI.icon("bolt", 46, Theme.rush, {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 10),
		Parent = frame6
	})

	UI.text({
		Text = "Puzzle Sprint",
		FontFace = Theme.fontHeavy,
		TextSize = 26,
		Size = UDim2.new(1, 0, 0, 30),
		Position = UDim2.fromOffset(0, 58),
		Parent = frame6
	})

	local text8 = UI.text({
		Text = "",
		TextSize = 14,
		TextColor3 = Theme.textDim,
		TextWrapped = true,
		Size = UDim2.new(1, -28, 0, 38),
		Position = UDim2.fromOffset(14, 90),
		Parent = frame6
	})

	local v8 = {}
	local v9 = { state = "idle", mode = "m3", run = nil }
	local startRush
	local endRush
	local nextRushPuzzle

	for _, v10 in v do
		table.insert(v8, { id = v10.id, label = v10.label, icon = v10.icon, iconColor = Theme.rush })
	end

	local segmented = UI.segmented(v8, v9.mode, function(mode)
		v9.mode = mode
		rush2.refresh()
	end, 44)
	segmented.frame.LayoutOrder = 2
	segmented.frame.Parent = frame5
	local text9 = UI.text({
		Text = "",
		FontFace = Theme.fontBold,
		TextSize = 17,
		Size = UDim2.new(1, 0, 0, 22),
		LayoutOrder = 3,
		Parent = frame5
	})

	local button = UI.button({
		parent = frame5,
		size = UDim2.new(1, 0, 0, 64),
		style = "primary",
		text = "Start",
		textSize = 26,
		font = Theme.fontHeavy,
		layoutOrder = 4,
		onClick = function()
			startRush()
		end
	})

	local frame7 = UI.new("Frame", {
		Name = "Score",
		Size = UDim2.new(1, 0, 0, 96),
		BackgroundColor3 = Theme.panelLight,
		Visible = false,
		LayoutOrder = 2,
		Parent = parent3
	}, { UI.corner(8) })
	local text10 = UI.text({
		Text = "0",
		FontFace = Theme.fontHeavy,
		TextSize = 48,
		Size = UDim2.new(0.5, 0, 0, 56),
		Position = UDim2.fromOffset(0, 10),
		Parent = frame7
	})

	UI.text({
		Text = "Score",
		TextSize = 13,
		TextColor3 = Theme.textDim,
		Size = UDim2.new(0.5, 0, 0, 16),
		Position = UDim2.fromOffset(0, 70),
		Parent = frame7
	})

	UI.new("Frame", {
		Size = UDim2.new(0, 1, 1, -24),
		Position = UDim2.new(0.5, 0, 0, 12),
		BackgroundColor3 = Theme.divider,
		Parent = frame7
	})

	local text11 = UI.text({
		Text = "3:00",
		FontFace = Theme.fontMono,
		TextSize = 36,
		Size = UDim2.new(0.5, 0, 0, 56),
		Position = UDim2.new(0.5, 0, 0, 10),
		Parent = frame7
	})

	local text12 = UI.text({
		Text = "Time left",
		TextSize = 13,
		TextColor3 = Theme.textDim,
		Size = UDim2.new(0.5, 0, 0, 16),
		Position = UDim2.new(0.5, 0, 0, 70),
		Parent = frame7
	})

	local frame8 = UI.new("Frame", {
		Name = "Strikes",
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundTransparency = 1,
		Visible = false,
		LayoutOrder = 3,
		Parent = parent3
	}, { UI.list(Enum.FillDirection.Horizontal, 10, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center) })
	local v10 = {}

	for i = 1, 3 do
		local frame9 = UI.new(
			"Frame",
			{
				Size = UDim2.fromOffset(30, 30),
				BackgroundColor3 = Theme.button,
				LayoutOrder = i,
				Parent = frame8
			},
			{ UI.corner(UDim.new(1, 0)) }
		)
		v10[i] = {
			dot = frame9,
			icon = UI.icon("close", 20, Theme.textMuted, {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Parent = frame9
			})
		}
	end

	local frame9 = UI.new("Frame", {
		Name = "Over",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.panelLight,
		Visible = false,
		LayoutOrder = 4,
		Parent = parent3
	}, {
		UI.corner(8),
		UI.pad(12, 14, 14, 14),
		UI.list(Enum.FillDirection.Vertical, 8, Enum.HorizontalAlignment.Center)
	})
	local text13 = UI.text({
		Text = "",
		FontFace = Theme.fontHeavy,
		TextSize = 22,
		Size = UDim2.new(1, 0, 0, 28),
		LayoutOrder = 1,
		Parent = frame9
	})

	local text14 = UI.text({
		Text = "",
		FontFace = Theme.fontBold,
		TextSize = 16,
		TextColor3 = Theme.textDim,
		Size = UDim2.new(1, 0, 0, 20),
		LayoutOrder = 2,
		Parent = frame9
	})

	local frame10 = UI.new(
		"Frame",
		{
			Size = UDim2.new(1, 0, 0, 50),
			BackgroundTransparency = 1,
			LayoutOrder = 3,
			Parent = frame9
		},
		{ UI.list(Enum.FillDirection.Horizontal, 6, Enum.HorizontalAlignment.Center) }
	)
	UI.button({
		parent = frame10,
		size = UDim2.new(0.5, -3, 1, 0),
		style = "primary",
		icon = "replay",
		iconSize = 20,
		text = "Play Again",
		textSize = 16,
		gap = 6,
		layoutOrder = 1,
		onClick = function()
			startRush()
		end
	})

	UI.button({
		parent = frame10,
		size = UDim2.new(0.5, -3, 1, 0),
		style = "secondary",
		icon = "home",
		iconSize = 20,
		text = "Home",
		textSize = 16,
		gap = 6,
		layoutOrder = 2,
		onClick = function()
			self.goHome()
		end
	})

	local frame11 = UI.new("Frame", {
		Name = "Results",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Visible = false,
		LayoutOrder = 5,
		Parent = parent3
	})

	local uiGridLayout = Instance.new("UIGridLayout")
	uiGridLayout.CellSize = UDim2.fromOffset(34, 34)
	uiGridLayout.CellPadding = UDim2.fromOffset(6, 6)
	uiGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiGridLayout.Parent = frame11

	local button2 = UI.button({
		parent = parent3,
		size = UDim2.new(1, 0, 0, 46),
		style = "secondary",
		icon = "flag",
		iconSize = 20,
		text = "End Run",
		textSize = 16,
		gap = 6,
		layoutOrder = 6,
		onClick = function()
			endRush("ended")
		end
	})

	button2:setVisible(false)

	function rush2.clearGrid()
		for _, frame12 in frame11:GetChildren() do
			if frame12:IsA("Frame") then
				frame12:Destroy()
			end
		end
	end

	function rush2.addResult(p, layoutOrder)
		local frame12 = UI.new("Frame", {
			Name = "R" .. layoutOrder,
			BackgroundColor3 = p and green or color,
			LayoutOrder = layoutOrder,
			Parent = frame11
		}, { UI.corner(6) })
		UI.icon(p and "check" or "close", 22, Color3.new(1, 1, 1), {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Parent = frame12
		})

		UI.pop(frame12, 0.3, 0.22)
	end

	local function updateTimer()
		local run = v9.run

		if not run then
			return
		end

		if run.duration then
			text12.Text = "Time left"
			local v11 = v9.state == "running" and run.deadline - os.clock() or run.timeLeft or 0
			local text15 = fmtTime(v11) -- inferred equivalent call

			if text11.Text ~= text15 then
				text11.Text = text15
			end

			text11.TextColor3 = v11 <= 20 and color or Theme.text
		else
			text11.Text = "--:--"
			text12.Text = "Survival"
			text11.TextColor3 = Theme.text
		end
	end

	function rush2.refresh()
		local state = v9.state
		local v11 = v2[v9.mode]
		local rush = self.profile and self.profile.rush
		frame5.Visible = state == "idle" or state == "loading"
		text8.Text = v11.blurb
		segmented.set(v9.mode)
		text9.Text = "Personal best: " .. tostring(rush and rush[v9.mode] or 0)
		button:setEnabled(state == "idle" and self.profile ~= nil)
		button:setText(state == "loading" and "Starting..." or "Start")

		local run = v9.run
		local visible

		if state == "running" or state == "over" then
			visible = run ~= nil
		else
			visible = false
		end

		frame7.Visible = visible
		frame8.Visible = visible
		frame11.Visible = visible
		button2:setVisible(state == "running")
		UI.reveal(frame9, state == "over", 8, 0.18)

		if not visible then
			return
		end

		if text10.Text ~= tostring(run.score) then
			text10.Text = tostring(run.score)

			if run.score > 0 then
				UI.pop(text10, 0.6, 0.22)
			end
		end

		for k, v12 in v10 do
			local hit = k <= run.strikes

			if hit and v12.hit ~= true then
				UI.pop(v12.dot, 0.5, 0.25)
			end

			v12.hit = hit
			UI.to(v12.dot, UI.SNAP, {
				BackgroundColor3 = hit and color or Theme.button
			})
			UI.to(v12.icon, UI.SNAP, {
				ImageColor3 = hit and Color3.new(1, 1, 1) or Theme.textMuted
			})
		end

		updateTimer()

		if state == "over" then
			text13.Text = (({
				time = "Time's up!",
				strikes = "Three strikes!",
				done = "You solved them all!"
			})[run.reason] or "Run over") .. "  Score: " .. tostring(run.score)
			local final = run.final

			if final then
				if final.failed or final.valid == false then
					text14.Text = "This run couldn't be saved."
					text14.TextColor3 = color
				elseif final.newBest then
					text14.Text = "New personal best!"
					text14.TextColor3 = Theme.gold
				else
					text14.Text = "Personal best: " .. tostring(final.best or 0)
					text14.TextColor3 = Theme.textDim
				end
			else
				text14.Text = "Saving..."
				text14.TextColor3 = Theme.textDim
			end
		end
	end
	rush2.onShow = rush2.refresh

	function rush2.onFrame()
		if v9.state == "running" and v9.run then
			if v9.run.deadline and os.clock() >= v9.run.deadline then
				endRush("time")
			elseif page2.Visible then
				updateTimer()
			end
		end
	end

	v3.rush = {
		onStep = function() end,
		onWrong = function(p)
			local pz = p.pz
			local run = pz.run

			if v9.state ~= "running" or v9.run ~= run then
				return
			end

			run.strikes += 1
			table.insert(run.results, {
				id = pz.data.id,
				moves = table.clone(pz.played),
				ok = false
			})
			rush2.addResult(false, #run.results)
			rush2.refresh()
		end,
		afterWrong = function(p)
			if v9.state ~= "running" or v9.run ~= p.pz.run then
				return
			end

			if p.pz.run.strikes >= 3 then
				endRush("strikes")
			else
				nextRushPuzzle()
			end
		end,
		onSolved = function(p)
			local pz = p.pz
			local run = pz.run

			if v9.state ~= "running" or v9.run ~= run then
				return
			end

			run.score += 1

			Sound.play("success", math.min(run.score, 20) * 0.025 + 1)
			table.insert(run.results, { id = pz.data.id, moves = table.clone(pz.played), ok = true })
			rush2.addResult(true, #run.results)
			rush2.refresh()
			schedule(p, 0.35, nextRushPuzzle) -- inferred equivalent call
		end
	}

	nextRushPuzzle = function()
		local run = v9.run

		if v9.state ~= "running" or not run then
			return
		end

		run.idx += 1
		local puzzle = run.puzzles[run.idx]

		if not puzzle then
			endRush("done")
			return
		end

		if self.profile then
			local _puzzle = self.profile.puzzle
		end

		local v11 = newSession("rush", puzzle, {
			userId = localPlayer.UserId,
			name = localPlayer.Name,
			display = localPlayer.DisplayName,
			rating = nil,
			prov = nil
		}, {
			display = "Puzzle " .. run.idx,
			icon = "bolt",
			color = Theme.rush
		})
		v11.pz.run = run
		v11.pz.live = puzzle.live == true
		self.setSession(v11)
		opponentMove(v11, 0.3) -- inferred equivalent call
	end

	function v4.endRush(p)
		endRush(p)
	end
	endRush = function(reason)
		local run = v9.run

		if v9.state ~= "running" or not run then
			return
		end

		v9.state = "over"
		run.reason = reason
		local timeLeft

		if run.deadline then
			timeLeft = math.max(0, run.deadline - os.clock()) or nil
		end

		run.timeLeft = timeLeft
		local session = self.session

		if session and session.kind == "rush" and session.pz then
			session.pz.token += 1
			session.pz.done = true
			session.pz.busy = false
			session.over = true
			self.render({ animate = false })
		end

		Sound.play("finish")
		rush2.refresh()
		local results = {}

		for k, result in run.results do
			results[k] = { id = result.id, moves = result.moves }
		end

		task.spawn(function()
			local request = self.request({ type = "rushEnd", token = run.token, results = results })
			run.final = request or { failed = true }

			if request and request.rush and self.profile then
				self.profile.rush = request.rush
			end

			if request and request.newBest then
				Sound.play("unlock")
			end

			rush2.refresh()
		end)
	end

	startRush = function()
		if v9.state == "loading" or v9.state == "running" or not self.profile then
			return
		end

		v9.state = "loading"
		rush2.refresh()
		task.spawn(function()
			local request = self.request({ type = "rushStart", mode = v9.mode })

			if v9.state ~= "loading" then
				return
			end

			if request and request.puzzles then
				local run = {
					token = request.token,
					mode = request.mode,
					duration = request.duration,
					puzzles = request.puzzles,
					idx = 0,
					results = {},
					strikes = 0,
					score = 0
				}

				run.deadline = request.duration and os.clock() + request.duration or nil
				v9.run = run
				rush2.clearGrid()
				v9.state = "running"

				if pages.current ~= "rush" then
					pages.show("rush")
				end

				Sound.play("start")
				rush2.refresh()
				nextRushPuzzle()
			else
				v9.state = "idle"
				self.toast("Couldn't start Puzzle Sprint. Try again.")
				rush2.refresh()
			end
		end)
	end

	function self.openRush()
		if self.inLiveGame() then
			return
		end

		if self.searching then
			self.cancelSearch()
		end

		self.modals.closeAll()
		self.send({ type = "status", status = "puzzle" })

		if v9.state == "over" then
			v9.state = "idle"
		end

		pages.show("rush")
	end

	local goHome = self.goHome
	function self.goHome()
		if v9.state == "running" then
			endRush("left")
		end

		if v9.state == "over" or v9.state == "loading" then
			v9.state = "idle"
		end

		v5.req += 1
		v5.loading = false
		goHome()
	end

	local setSession = self.setSession
	function self.setSession(p)
		if v9.state == "running" and (not p or not p.pz or p.pz.run ~= v9.run) then
			endRush("left")
		elseif v9.state == "loading" and (not p or p.kind ~= "rush") then
			v9.state = "idle"
		end

		local board = self.board
		board.noAutoQueen = p ~= nil and (p.kind == "puzzle" or p.kind == "rush" or p.kind == "tutorial")
		return setSession(p)
	end

	local refreshAll = pages.refreshAll
	function pages.refreshAll()
		refreshAll()

		if pages.current == "puzzles" then
			puzzles.refresh()
		elseif pages.current == "rush" then
			rush2.refresh()
		end
	end

	local onFrame = pages.onFrame
	function pages.onFrame()
		onFrame()
		rush2.onFrame()
	end

	local Debug = self.debug
	function self.debug(p)
		local session = self.session

		if p.type == "puzzleState" then
			local pz = session and session.pz
			return {
				kind = session and session.kind,
				id = pz and pz.data.id,
				sol = pz and table.concat(pz.sol, " "),
				step = pz and pz.step,
				busy = pz and pz.busy,
				done = pz and pz.done,
				wrong = pz and pz.wrong,
				missed = pz and pz.missed,
				rated = pz and pz.rated,
				reported = pz and pz.reported,
				outcome = pz and pz.outcome,
				delta = pz and pz.result and pz.result.delta,
				rating = self.profile and self.profile.puzzle and self.profile.puzzle.r,
				fen = session and session.engine:getFen(),
				page = pages.current,
				rush = v9.state,
				rushScore = v9.run and v9.run.score,
				rushStrikes = v9.run and v9.run.strikes,
				rushIdx = v9.run and v9.run.idx,
				rushFinal = v9.run and v9.run.final and tostring(v9.run.final.score) .. "/" .. tostring(v9.run.final.best) .. "/" .. tostring(v9.run.final.valid)
			}
		end

		if p.type == "openPuzzles" then
			self.openPuzzles()
			return true
		end

		if p.type == "hint" then
			giveHint()
			return true
		end

		if p.type == "solution" then
			showSolution()
			return true
		end

		if p.type == "nextPuzzle" then
			loadNext()
			return true
		end

		if p.type == "retryPuzzle" then
			if v5.current then
				startPuzzle(v5.current, false)
			end
		else
			if p.type == "openRush" then
				self.openRush()
				return true
			end

			if p.type == "startRush" then
				v9.mode = p.mode or v9.mode
				startRush()
			else
				if p.type ~= "endRush" then
					return Debug(p)
				end

				endRush("ended")
			end
		end

		return true
	end
end

return Puzzle