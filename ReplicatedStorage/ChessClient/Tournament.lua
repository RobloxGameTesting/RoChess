local Players = game:GetService("Players")
game:GetService("ReplicatedStorage")

local parent = script.Parent
local Theme = require(parent.Theme)
local UI = require(parent.UI)

local Tournament = {}

local v = {
	win = nil,
	material = "draw · more material",
	time = "draw · more time",
	seed = "draw · higher seed",
	aborted = "aborted",
	bye = "bye",
	forfeit = "no-show"
}

local function mmss(p) -- 7 equivalent calls inferred from this helper
	local v2 = math.max(0, (math.floor(p)))

	if v2 >= 3600 then
		return string.format("%d:%02d:%02d", v2 // 3600, v2 % 3600 // 60, v2 % 60)
	end

	return string.format("%d:%02d", v2 // 60, v2 % 60)
end

local function ordinal(p)
	local v2 = (p % 100 < 11 or p % 100 > 13) and ({ "st", "nd", "rd" })[p % 10] or "th"

	return tostring(p) .. v2
end

function Tournament.roundName(p, p2)
	if p == p2 then
		return "Final"
	end

	if p == p2 - 1 then
		return "Semi-finals"
	end

	if p == p2 - 2 then
		return "Quarter-finals"
	end

	return "Round " .. p
end

function Tournament:install()
	local pages = self.pages
	local userId = Players.LocalPlayer.UserId
	local state = {
		view = nil,
		offset = 0,
		busy = false,
		shownEvent = false,
		lastOut = nil,
		lastRound = nil
	}
	Tournament.state = state

	local function serverTime() -- 2 equivalent calls inferred from this helper
		return os.time() + state.offset
	end

	local page, parent2 = pages.newPage("tournament", "Tournament", "crown", Theme.gold, true)
	local tournament = { frame = page }
	pages.tournament = tournament

	local frame = UI.new("Frame", {
		Name = "Head",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.panelLight,
		LayoutOrder = 1,
		Parent = parent2
	}, { UI.corner(10), UI.pad(14, 14, 14, 14), UI.list(Enum.FillDirection.Vertical, 6) })
	UI.lift(frame, 0.12)
	local text = UI.text({
		Text = "HOURLY TOURNAMENT",
		FontFace = Theme.fontBold,
		TextSize = 12,
		TextColor3 = Theme.gold,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 14),
		LayoutOrder = 1,
		Parent = frame
	})

	local text2 = UI.text({
		Text = "Next tournament",
		FontFace = Theme.fontHeavy,
		TextSize = 22,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 2,
		Parent = frame
	})

	local text3 = UI.text({
		Text = "--:--",
		FontFace = Theme.fontMono,
		TextSize = 34,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 40),
		LayoutOrder = 3,
		Parent = frame
	})

	local text4 = UI.text({
		Text = "5 min · Rated blitz · Knockout",
		RichText = true,
		TextSize = 14,
		TextColor3 = Theme.textDim,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 4,
		Parent = frame
	})

	local button = UI.button({
		parent = frame,
		name = "Action",
		size = UDim2.new(1, 0, 0, 48),
		style = "primary",
		icon = "crown",
		text = "Join",
		textSize = 18,
		layoutOrder = 5,
		onClick = function()
			tournament.act()
		end
	})

	local text5 = UI.text({
		Text = "",
		TextSize = 13,
		TextColor3 = Theme.textMuted,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 6,
		Parent = frame
	})

	local frame2 = UI.new("Frame", {
		Name = "Bracket",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Visible = false,
		LayoutOrder = 2,
		Parent = parent2
	}, { UI.list(Enum.FillDirection.Vertical, 6) })

	local frame3 = UI.new("Frame", {
		Name = "Rules",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.panelLight,
		LayoutOrder = 3,
		Parent = parent2
	}, { UI.corner(10), UI.pad(12, 14, 12, 14), UI.list(Enum.FillDirection.Vertical, 6) })
	UI.text({
		Text = "How it works",
		FontFace = Theme.fontBold,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 18),
		LayoutOrder = 0,
		Parent = frame3
	})

	for k, v2 in {
		"A new tournament starts every hour, on the hour.",
		"One knockout bracket with everyone who signs up, seeded by blitz rating. When the numbers don't fit, the top seeds skip round 1. 5 minute games, rated blitz.",
		"Win to go through. On a draw, the player with more material goes through; if material is equal, the player with more time left.",
		"Stay in the game when it starts: you'll be moved to your bracket. Missing a game counts as a loss.",
		"Medals: champion 3, runner-up 2, semi-finalists 1 (4+ players).",
		"Big brackets are split across servers. If your next game is in another server, you're moved there automatically.",
		"You need 10 rated wins to enter."
	} do
		UI.text({
			Text = "•  " .. v2,
			TextSize = 13,
			TextColor3 = Theme.textDim,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = k,
			Parent = frame3
		})
	end

	local v2 = {}
	local function playerLine(p, p2) -- 1 equivalent call inferred from this helper
		if p then
			return p2[p]
		end

		return nil
	end

	local function drawBracket(view)
		for _, guiObject in frame2:GetChildren() do
			if guiObject:IsA("GuiObject") then
				guiObject:Destroy()
			end
		end

		local v3 = {}

		for _, v4 in view.players or {} do
			v3[v4.u] = v4
			v2[v4.u] = v4.n
		end

		local v4 = self.inLiveGame()

		local v5 = {}
		local count = 0

		for i = 1, view.rounds or 0 do
			table.insert(v5, i)
		end

		local v6 = math.max(1, view.round or 1)
		local set = {}

		for _, v7 in view.partial or {} do
			set[v7] = true
		end

		table.sort(v5, function(a, b): boolean
			return (v6 <= a and a or 100 - a) < (v6 <= b and b or 100 - b)
		end)

		for _, v7 in v5 do
			local v8 = view.bracket and view.bracket[v7] or {}
			count += 1
			local text6 = Tournament.roundName(v7, view.rounds)

			if set[v7] then
				text6 ..= "  ·  your section"
			end

			if v7 == view.round and view.status == "playing" then
				text6 ..= "  ·  live"
			elseif v7 < (view.round or 0) or view.status == "done" then
				text6 ..= "  ·  done"
			end

			UI.text({
				Text = text6,
				FontFace = Theme.fontBold,
				TextSize = 14,
				TextColor3 = v7 == view.round and Theme.text or Theme.textDim,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, 0, 0, 22),
				LayoutOrder = count,
				Parent = frame2
			})

			for k, v9 in v8 do
				if not (v9.a or v9.b or not (v9.done or v7 < (view.round or 0))) then
					continue
				end

				count += 1
				local v10 = v9.a == userId or v9.b == userId
				local frame4 = UI.new("Frame", {
					Name = "Pair" .. v7 .. "_" .. k,
					Size = UDim2.new(1, 0, 0, 58),
					BackgroundColor3 = v10 and Theme.rowActive or Theme.panelLight,
					LayoutOrder = count,
					Parent = frame2
				}, { UI.corner(8) })

				if v10 then
					local stroke = UI.stroke(Theme.selEdge, 1, 0.3)
					stroke.Parent = frame4
				end

				local v11 = v9

				local function side(p, p2)
					local v12 = playerLine(p, v3) -- inferred equivalent call
					local v13

					if v11.w == nil then
						v13 = false
					else
						v13 = v11.w == p
					end

					local v14 = v11.done

					if v14 then
						if p == nil then
							v14 = false
						else
							v14 = v11.w ~= p
						end
					end

					local text7

					if v12 then
						text7 = string.format(
							"<font color=\"#%s\">%d</font>  %s  <font color=\"#%s\">%d</font>",
							Theme.textMuted:ToHex(),
							v12.s or 0,
							v12.n,
							Theme.textMuted:ToHex(),
							v12.r or 0
						)

						if view.status == "arrival" and not v12.a then
							text7 ..= "  <font color=\"#" .. Theme.textMuted:ToHex() .. "\">(joining...)</font>"
						end
					else
						text7 = (v11.done or v7 == 1) and "—" or "TBD"
					end

					UI.text({
						Text = text7,
						RichText = true,
						FontFace = v13 and Theme.fontHeavy or Theme.fontBold,
						TextSize = 15,
						TextColor3 = v13 and Theme.win or v14 and Theme.textMuted or Theme.textSoft,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextTruncate = Enum.TextTruncate.AtEnd,
						Size = UDim2.new(1, -110, 0, 20),
						Position = UDim2.fromOffset(12, p2),
						Parent = frame4
					})
				end
				side(v9.a, 7)
				side(v9.b, 31)
				local text7

				if v9.why then
					text7 = v[v9.why] or nil
				end

				if v9.live then
					local a = v9.a ~= userId and v9.a or v9.b

					if v10 or not (a and Players:GetPlayerByUserId(a)) then
						text7 = "playing"
					else
						UI.button({
							parent = frame4,
							name = "Watch",
							size = UDim2.fromOffset(88, 36),
							position = UDim2.new(1, -8, 0.5, 0),
							anchor = Vector2.new(1, 0.5),
							style = "secondary",
							icon = "eye",
							iconSize = 17,
							text = "Watch",
							textSize = 14,
							gap = 4,
							padX = 6,
							onClick = function()
								if self.watch then
									task.spawn(self.watch, a)
								end
							end
						}):setEnabled(not v4)
					end
				end

				if text7 then
					UI.text({
						Text = text7,
						TextSize = 12,
						TextColor3 = v9.live and Theme.teal or Theme.textMuted,
						TextXAlignment = Enum.TextXAlignment.Right,
						Size = UDim2.new(0, 100, 1, 0),
						Position = UDim2.new(1, -110, 0, 0),
						Parent = frame4
					})
				end
			end
		end
	end

	local function myStatus(view)
		if not view.entrant then
			return nil
		end

		if view.status == "done" and view.champion == userId then
			return "<font color=\"#" .. Theme.gold:ToHex() .. "\"><b>You won the tournament!</b></font>"
		end

		if view.out then
			if view.place == 2 then
				return "You finished <b>2nd</b>."
			end

			if view.place == 3 then
				return "You reached the <b>semi-finals</b>."
			end

			return "You're out (" .. Tournament.roundName(view.out, view.rounds or 1) .. ")."
		end

		if view.status == "arrival" then
			return "You're in. Your first game starts automatically."
		end

		if view.status == "next" then
			return "You're still in. Waiting for your opponent to join this server."
		end

		if view.status == "waiting" then
			return "You're still in. Waiting for the rest of the bracket; you'll be moved for your next game if needed."
		end

		return "You're still in. Your next game starts automatically."
	end

	local function tick()
		local view = state.view

		if not view then
			return
		end

		local v3 = serverTime() -- inferred equivalent call

		if view.phase == "lobby" then
			text3.Text = mmss((view.start or v3) - v3) -- inferred equivalent call

			local v4 = (view.closeAt or view.start or v3) <= v3

			if view.moving then
				button:setText("Moving to your bracket...")
				button:setEnabled(false)
			elseif view.joined then
				button:setText(v4 and "Starting..." or "Signed up · Leave")
				button:setStyle("secondary")
				button:setEnabled(not v4)
			elseif (view.wins or 0) < (view.need or 10) then
				button:setText(string.format(
					"Win %d rated games to enter (%d/%d)",
					view.need or 10,
					view.wins or 0,
					view.need or 10
				))
				button:setStyle("secondary")
				button:setEnabled(false)
			elseif v4 then
				button:setText("Sign-ups closed")
				button:setStyle("secondary")
				button:setEnabled(false)
			else
				button:setText("Join")
				button:setStyle("primary")
				button:setEnabled(not state.busy)
			end
		else
			local text6 = ""

			if view.status == "arrival" then
				local v4 = #(view.players or {})
				local count = 0

				for _, v5 in view.players or {} do
					if v5.a then
						count += 1
					end
				end

				text2.Text = string.format("Waiting for players  ·  %d/%d here", count, v4)

				if view.nextAt then
					text6 = mmss(view.nextAt - v3) or "" -- inferred equivalent call
				else
					text6 = ""
				end
			elseif view.status == "break" then
				text2.Text = Tournament.roundName(view.round + 1, view.rounds) .. " starts in"

				if view.nextAt then
					text6 = mmss(view.nextAt - v3) or "" -- inferred equivalent call
				else
					text6 = ""
				end
			elseif view.status == "next" then
				text2.Text = Tournament.roundName(view.round, view.rounds) .. ": waiting for players"

				if view.nextAt then
					text6 = mmss(view.nextAt - v3) or "" -- inferred equivalent call
				else
					text6 = ""
				end
			elseif view.status == "waiting" then
				text2.Text = "Waiting for the rest of the bracket"
				text6 = string.format("%d players  ·  %d rounds", view.field or 0, view.rounds or 0)
			elseif view.status == "playing" then
				text2.Text = Tournament.roundName(view.round, view.rounds) .. " in progress"
				text6 = string.format("Round %d of %d", view.round, view.rounds)
			elseif view.status == "done" then
				text2.Text = "Champion: " .. (view.champion and v2[view.champion] or "nobody")

				if view.returnAt then
					text6 = "Back to lobby in " .. mmss(view.returnAt - v3) or "" -- inferred equivalent call
				else
					text6 = ""
				end
			end

			text3.Text = text6
			local v4 = view.status == "playing" or view.status == "done" or view.status == "waiting"
			text3.TextSize = v4 and 20 or 34
			text3.FontFace = v4 and Theme.fontBold or Theme.fontMono
		end
	end

	function tournament.render()
		local view = state.view

		if not view then
			return
		end

		if view.phase == "lobby" then
			text.Text = "HOURLY TOURNAMENT"
			text2.Text = "Next tournament at " .. os.date("%H:%M", view.start or os.time())
			text3.TextSize = 34
			text3.FontFace = Theme.fontMono
			text4.Text = string.format(
				"5 min  ·  Rated blitz  ·  Knockout  ·  Your medals: <b>%d</b>",
				view.medals or 0
			)
			button.holder.Visible = true

			if view.joined then
				text5.Text = "You're signed up. Stay in the game: when it starts you'll be moved to your bracket. Finish any game before then."
			else
				text5.Text = "Sign-ups close 15 seconds before the start."
			end

			frame2.Visible = false
			frame3.Visible = true
		else
			text.Text = "HOURLY TOURNAMENT  ·  " .. os.date("%H:%M", view.start or os.time())
			text4.Text = myStatus(view) or "You're watching this bracket."
			local visible = not view.entrant or view.out ~= nil or view.status == "done"
			button.holder.Visible = visible
			button:setText("Back to lobby")
			button:setStyle("secondary")
			button:setEnabled(not (state.busy or self.inLiveGame()))
			text5.Text = view.medals == false
				and view.status ~= "arrival"
				and "No medals this time: fewer than " .. (view.minMedal or 4) .. " players turned up."
				or ""
			frame3.Visible = false
			frame2.Visible = true

			for _, v3 in view.players or {} do
				v2[v3.u] = v3.n
			end

			drawBracket(view)
		end

		tick()
	end

	local function apply(view)
		if type(view) ~= "table" or not view.phase then
			return
		end

		if type(view.now) == "number" then
			state.offset = view.now - os.time()
		end

		local view2 = state.view
		state.view = view

		if view.phase == "event" then
			if not state.shownEvent and view.entrant then
				state.shownEvent = true

				if not self.inLiveGame() then
					pages.show("tournament")
				end
			end

			if view.entrant and view2 and view2.phase == "event" then
				if view.out and not (view2.out or view.place and view.place <= 3) then
					self.toast("You're out of the tournament. Thanks for playing!")
				elseif view.out or view.status ~= "break" or view2.status ~= "playing" then
					if view.out or view.status ~= "waiting" or view2.status ~= "playing" then
						if view.status == "done" and view2.status ~= "done" and view.champion == userId then
							self.toast("You won the tournament!")
						end
					else
						self.toast("You're through!")
					end
				else
					self.toast("You're through to the " .. Tournament.roundName(view.round + 1, view.rounds) .. "!")
				end
			end
		end

		if tournament.onBanner then
			tournament.onBanner()
		end

		if page.Visible then
			tournament.render()
		end
	end
	tournament.apply = apply

	function tournament.refresh()
		task.spawn(function()
			local request = self.request({ type = "tour", action = "info" })

			if type(request) == "table" and request.ok then
				apply(request)
			end
		end)
	end

	local v3 = {
		wins = "You need 10 rated wins to enter.",
		closed = "Sign-ups for this one have closed.",
		wait = "Still loading your profile. Try again in a moment.",
		inTour = "You're already in a tournament.",
		error = "Couldn't sign you up. Try again.",
		busy = "Finish your game first."
	}

	function tournament.act()
		local view = state.view

		if not view or state.busy then
			return
		end

		local action = view.phase == "lobby" and (view.joined and "leave" or "join") or "lobby"

		state.busy = true
		button:setEnabled(false)
		task.spawn(function()
			local request = self.request({ type = "tour", action = action })
			state.busy = false

			if type(request) == "table" and request.ok and request.phase then
				apply(request)

				if action == "join" then
					self.toast("Signed up! Starts at " .. os.date("%H:%M", request.start))
				end
			elseif type(request) == "table" and request.ok and action == "lobby" then
				button:setText("Moving...")
			else
				self.toast(v3[type(request) == "table" and request.reason or "error"] or "Couldn't sign you up. Try again.")
				tournament.render()
			end
		end)
	end

	function tournament.onShow()
		tournament.render()
		tournament.refresh()
	end

	task.spawn(function()
		while true do
			task.wait(0.5)

			if page.Visible then
				pcall(tick)
			end
		end
	end)

	function self.handlers.tour(p)
		apply(p.view)
	end
	function self.handlers.tourMoving()
		self.toast("Your tournament is starting! Moving you to your bracket...")
	end
	function self.handlers.tourMedal(data)
		local n = tonumber(data.n) or 0
		local v4 = data.place == 1 and "Champion" or data.place == 2 and "Runner-up" or "Semi-finalist"
		self.toast(string.format("%s! +%d medal%s (%d total)", v4, n, n == 1 and "" or "s", tonumber(data.total) or n))
	end

	local home = pages.home

	if home and home.progress then
		local button2 = UI.button({
			parent = home.progress,
			name = "Tournament",
			size = UDim2.new(1, 0, 0, 62),
			style = "flat",
			icon = "crown",
			iconSize = 28,
			iconColor = Theme.gold,
			text = "Hourly Tournament",
			textSize = 18,
			subtext = "Every hour · 5 min knockout",
			align = Enum.HorizontalAlignment.Left,
			padX = 14,
			gap = 14,
			layoutOrder = 3,
			onClick = function()
				pages.show("tournament")
			end
		})

		tournament.banner = button2
		function tournament.onBanner()
			local view = state.view

			if not view then
				return
			end

			if view.phase == "event" then
				button2:setSubtext(view.status == "done" and "Finished · see the bracket" or "In progress · see the bracket")
				return
			end

			local v4 = (view.start or 0) - serverTime() -- inferred equivalent call

			if view.moving then
				button2:setSubtext("Moving you to your bracket...")
			elseif view.joined then
				button2:setSubtext("Signed up · starts in " .. mmss(v4)) -- inferred equivalent call
			else
				button2:setSubtext("Next at " .. os.date("%H:%M", view.start or os.time()) .. " · starts in " .. mmss(v4)) -- inferred equivalent call
			end
		end
		task.spawn(function()
			while button2.holder.Parent do
				if button2.holder.Visible and button2.holder.AbsoluteSize.Y > 0 then
					pcall(tournament.onBanner)
				end

				task.wait(1)
			end
		end)
	end

	local profile = self.handlers.profile
	local v4 = false
	function self.handlers.profile(p)
		if profile then
			profile(p)
		end

		if not v4 then
			v4 = true
			task.delay(1, tournament.refresh)
		end
	end

	local Debug = self.debug
	function self.debug(data)
		if type(data) ~= "table" or data.type ~= "tour" then
			return Debug and Debug(data)
		end

		if data.view then
			apply(data.view)
		end

		if data.refresh then
			local request = self.request({ type = "tour", action = "info" })

			if type(request) == "table" and request.ok then
				apply(request)
			end
		end

		if data.show then
			pages.show("tournament")
		end

		if data.act then
			tournament.act()
			task.wait(data.wait or 1)
		end

		local view = state.view
		return view and ({
			phase = view.phase,
			status = view.status,
			joined = view.joined,
			start = view.start,
			wins = view.wins,
			medals = view.medals,
			out = view.out,
			place = view.place,
			champion = view.champion,
			title = text2.Text,
			big = text3.Text,
			sub = text4.Text,
			button = button.label and button.label.Text
		} or nil) or nil
	end
end

return Tournament