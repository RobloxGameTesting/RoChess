local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Chess = ReplicatedStorage:WaitForChild("Chess")
local Config = require(Chess.Config)
local parent = script.Parent
local Theme = require(parent.Theme)
local UI = require(parent.UI)
local Sound = require(parent.Sound)

local function plural(p, p2) -- 2 equivalent calls inferred from this helper
	return tostring(p) .. " " .. p2 .. (p == 1 and "" or "s")
end

local function countdown(p)
	local v = math.max(0, (math.floor(p)))
	local v2 = v // 3600
	local v3 = v % 3600 // 60

	if v2 > 0 then
		return string.format("%dh %dm", v2, v3)
	end

	if v3 > 0 then
		return string.format("%dm %ds", v3, v % 60)
	end

	return string.format("%ds", v % 60)
end

local function rewardChip(parent2, p, p2, value)
	local frame = UI.new("Frame", {
		Name = "Reward",
		Size = UDim2.new(0, 0, 0, p2 + 4),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		LayoutOrder = value or 0,
		Parent = parent2
	}, { UI.list(Enum.FillDirection.Horizontal, 4, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center) })
	return frame, UI.icon("token", p2, Theme.token, {
		Name = "Icon",
		LayoutOrder = 1,
		Parent = frame
	}), (UI.text({
		Name = "Amount",
		Text = "+" .. tostring(p),
		FontFace = Theme.fontHeavy,
		TextSize = (math.floor)(p2 * 0.9),
		TextColor3 = Theme.token,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 1, 0),
		LayoutOrder = 2,
		Parent = frame
	}))
end

return {
	install = function(self)
		local pages = self.pages
		self.tasks = nil

		local page, parent2 = pages.newPage("tasks", "Daily Tasks", "calendar", Theme.tasks, true)
		local tasks2 = { frame = page }
		pages.tasks = tasks2

		local frame = UI.new("Frame", {
			Name = "Balance",
			Size = UDim2.new(1, 0, 0, 74),
			BackgroundColor3 = Theme.panelLight,
			LayoutOrder = 1,
			Parent = parent2
		}, { UI.corner(8) })
		local icon = UI.icon("token", 46, Theme.token, {
			Name = "Token",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0, 37, 0.5, 0),
			Parent = frame
		})

		UI.text({
			Text = "Your tokens",
			TextSize = 14,
			TextColor3 = Theme.textDim,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, -80, 0, 18),
			Position = UDim2.fromOffset(72, 12),
			Parent = frame
		})

		local text = UI.text({
			Name = "Amount",
			Text = "0",
			FontFace = Theme.fontHeavy,
			TextSize = 30,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, -80, 0, 34),
			Position = UDim2.fromOffset(72, 28),
			Parent = frame
		})

		local text2 = UI.text({
			Name = "Reset",
			Text = "",
			RichText = true,
			TextSize = 14,
			TextColor3 = Theme.textDim,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, 0, 0, 18),
			LayoutOrder = 2,
			Parent = parent2
		})

		local rowsById = {}

		local function makeRow(k, def)
			local frame2 = UI.new("Frame", {
				Name = "Task_" .. def.id,
				Size = UDim2.new(1, 0, 0, 88),
				BackgroundColor3 = Theme.panelLight,
				LayoutOrder = 10 + k,
				Parent = parent2
			}, { UI.corner(8) })
			local stroke = UI.stroke(Theme.green, 1.5, 1)
			stroke.Parent = frame2
			local icon2 = UI.icon(def.icon, 32, def.color or Theme.text, {
				Name = "Icon",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromOffset(30, 26),
				Parent = frame2
			})

			local text3 = UI.text({
				Name = "Label",
				Text = def.label,
				FontFace = Theme.fontBold,
				TextSize = 17,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Size = UDim2.new(1, -130, 0, 24),
				Position = UDim2.fromOffset(56, 14),
				Parent = frame2
			})

			local frame3 = UI.new("Frame", {
				Name = "Right",
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -12, 0, 14),
				Size = UDim2.fromOffset(70, 24),
				BackgroundTransparency = 1,
				Parent = frame2
			}, { UI.list(
					Enum.FillDirection.Horizontal,
					4,
					Enum.HorizontalAlignment.Right,
					Enum.VerticalAlignment.Center
				) })
			local chip, chipIcon, chipAmount = rewardChip(frame3, def.reward, 20, 1)
			local icon3 = UI.icon("check", 24, Theme.green, {
				Name = "Check",
				Visible = false,
				LayoutOrder = 2,
				Parent = frame3
			})

			local frame4 = UI.new("Frame", {
				Name = "Bar",
				Position = UDim2.fromOffset(56, 50),
				Size = UDim2.new(1, -68, 0, 22),
				BackgroundColor3 = Theme.track,
				Parent = frame2
			}, { UI.corner(UDim.new(1, 0)) })
			local frame5 = UI.new(
				"Frame",
				{
					Name = "Fill",
					Size = UDim2.fromScale(0, 1),
					BackgroundColor3 = Theme.tasks,
					Parent = frame4
				},
				{ UI.corner(UDim.new(1, 0)) }
			)
			local text4 = UI.text({
				Name = "Count",
				Text = "0 / " .. def.goal,
				FontFace = Theme.fontBold,
				TextSize = 14,
				TextStrokeTransparency = 0.6,
				Size = UDim2.fromScale(1, 1),
				ZIndex = 2,
				Parent = frame4
			})

			local frame6 = UI.new("Frame", {
				Name = "ClaimHolder",
				Position = UDim2.fromOffset(56, 46),
				Size = UDim2.new(1, -68, 0, 32),
				BackgroundTransparency = 1,
				Visible = false,
				Parent = frame2
			})

			local row = {
				def = def,
				frame = frame2,
				stroke = stroke,
				icon = icon2,
				label = text3,
				chip = chip,
				chipIcon = chipIcon,
				chipAmount = chipAmount,
				check = icon3,
				bar = frame4,
				fill = frame5,
				count = text4,
				claimHolder = frame6,
				shown = nil
			}

			row.claim = UI.button({
				parent = frame6,
				name = "Claim",
				size = UDim2.fromScale(1, 1),
				style = "primary",
				text = "Claim",
				textSize = 17,
				sfx = "none",
				onClick = function()
					tasks2.claim(def.id)
				end
			})

			rowsById[def.id] = row
			return row
		end

		local v = {}

		for k, v2 in Config.DAILY_TASKS do
			makeRow(k, v2)
		end

		UI.text({
			Name = "Note",
			Text = "Online games count once both players have made 5 moves. Games against bots don't count. Spend tokens on crates in the Shop.",
			TextSize = 12,
			TextColor3 = Theme.textMuted,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = 30,
			Parent = parent2
		})

		local function progress(id) -- 4 equivalent calls inferred from this helper
			local tasks = self.tasks
			return tasks and tonumber(tasks.p and tasks.p[id]) or 0
		end

		local function claimed(id): boolean -- 3 equivalent calls inferred from this helper
			local tasks = self.tasks
			return tasks ~= nil and tasks.c ~= nil and tasks.c[id] == true
		end

		local function ready(p): boolean -- 2 equivalent calls inferred from this helper
			return progress(p.id) >= p.goal and not claimed(p.id) -- inferred equivalent call
		end

		function tasks2.claimable()
			local count = 0

			for _, v2 in Config.DAILY_TASKS do
				if ready(v2) then -- inferred equivalent call
					count += 1
				end
			end

			return count
		end

		local function drawRow(state, p)
			local def = state.def
			local shown = math.min(progress(def.id), def.goal) -- inferred equivalent call
			local v2 = def.goal <= shown
			local visible2 = claimed(def.id) -- inferred equivalent call
			local v3 = v2 and not visible2
			state.count.Text = visible2 and "Claimed" or string.format("%d / %d", shown, def.goal)
			local udim = UDim2.fromScale(def.goal > 0 and shown / def.goal or 0, 1)

			if p and state.shown ~= nil and state.shown ~= shown then
				UI.tween(state.fill, 0.5, { Size = udim }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
			else
				state.fill.Size = udim
			end

			state.fill.BackgroundColor3 = v2 and Theme.green or Theme.tasks
			state.shown = shown
			state.bar.Visible = not v3
			local visible = state.claimHolder.Visible

			if v3 then
				UI.reveal(state.claimHolder, true, 4)

				if not visible and p then
					UI.pop(state.claim.face, 0.85, 0.25)
				end
			else
				state.claimHolder.Visible = false
			end

			state.claim:setEnabled(not v[def.id])
			state.chip.Visible = not visible2
			state.chipAmount.Text = "+" .. tostring(Config.vipTokens(def.reward, self.isVip()))
			state.check.Visible = visible2
			UI.to(state.stroke, UI.SNAP, {
				Transparency = v3 and 0.2 or 1
			})
			local v4 = visible2 and 0.45 or 0
			UI.to(state.label, UI.SNAP, { TextTransparency = v4 })
			UI.to(state.icon, UI.SNAP, { ImageTransparency = v4 })
		end

		local v2 = nil
		local function drawBalance(p)
			local tokens = self.tasks and tonumber(self.tasks.tokens) or 0

			if p and v2 and v2 < tokens then
				UI.countTo(text, v2, tokens, 0.6, "%d", "tick")
				task.delay(0.6, UI.pop, text, 0.8, 0.25)
			else
				text.Text = tostring(tokens)
			end

			v2 = tokens
		end

		local function drawReset()
			local tasks = self.tasks

			if tasks and tasks.resetAt then
				local v3 = tasks.resetAt - self.serverNow()
				text2.Text = string.format("New tasks in <font color=\"#FFFFFF\">%s</font>", countdown(v3)) .. (self.isVip() and "   <font color=\"#FFCC40\"><b>VIP: double tokens</b></font>" or "")
			else
				text2.Text = ""
			end
		end

		local function drawEntryPoints()
			local claimable = tasks2.claimable()

			if self.nav and self.nav.setBadge then
				self.nav.setBadge("tasks", claimable > 0)
			end

			local home = pages.home

			if home and home.tasksButton then
				local v3

				if self.tasks then
					if claimable > 0 then
						v3 = plural(claimable, "reward") .. " ready to claim!" -- inferred equivalent call
					else
						local count = 0

						for _, v4 in Config.DAILY_TASKS do
							if progress(v4.id) < v4.goal then -- inferred equivalent call
								count += 1
							end
						end

						v3 = count == 0 and "All done for today" or plural(count, "task") .. " left today" -- inferred equivalent call
					end
				else
					v3 = "Earn tokens every day"
				end

				home.tasksButton:setSubtext(v3)

				if home.tasksDot then
					home.tasksDot.Visible = claimable > 0
				end

				if home.tasksTileDot then
					home.tasksTileDot.Visible = claimable > 0
				end
			end
		end

		local v3 = {}
		local v4 = nil
		local function buildMini(taskSlot)
			local frame2 = UI.new(
				"Frame",
				{
					Name = "MiniTasks",
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					Parent = taskSlot
				},
				{ UI.list(Enum.FillDirection.Vertical, 8) }
			)
			local frame3 = UI.new("Frame", {
				Name = "Head",
				Size = UDim2.new(1, 0, 0, 26),
				BackgroundTransparency = 1,
				LayoutOrder = 0,
				Parent = frame2
			})

			UI.icon("calendar", 18, Theme.tasks, {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0, 0.5),
				Parent = frame3
			})

			UI.text({
				Text = "Daily Tasks",
				FontFace = Theme.fontBold,
				TextSize = 16,
				TextXAlignment = Enum.TextXAlignment.Left,
				Position = UDim2.fromOffset(26, 0),
				Size = UDim2.new(0.6, -26, 1, 0),
				Parent = frame3
			})

			v4 = UI.text({
				Text = "",
				FontFace = Theme.fontMedium,
				TextSize = 12,
				TextColor3 = Theme.textMuted,
				TextXAlignment = Enum.TextXAlignment.Right,
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.fromScale(1, 0),
				Size = UDim2.new(0.4, 0, 1, 0),
				Parent = frame3
			})

			for k, def in Config.DAILY_TASKS do
				local frame4 = UI.new("Frame", {
					Name = def.id,
					Size = UDim2.new(1, 0, 0, 54),
					BackgroundColor3 = Theme.panelLight,
					LayoutOrder = k,
					Parent = frame2
				}, { UI.corner(12) })
				UI.lift(frame4, 0.1)
				local icon2 = UI.icon(def.icon, 22, def.color, {
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.new(0, 12, 0.5, 0),
					Parent = frame4
				})

				local text3 = UI.text({
					Text = def.label,
					FontFace = Theme.fontBold,
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd,
					Position = UDim2.fromOffset(44, 8),
					Size = UDim2.new(1, -130, 0, 18),
					Parent = frame4
				})

				local frame5 = UI.new("Frame", {
					Name = "Bar",
					Position = UDim2.fromOffset(44, 32),
					Size = UDim2.new(1, -130, 0, 8),
					BackgroundColor3 = Theme.track,
					Parent = frame4
				}, { UI.corner(UDim.new(1, 0)) })
				local frame6 = UI.new(
					"Frame",
					{
						Name = "Fill",
						Size = UDim2.fromScale(0, 1),
						BackgroundColor3 = Theme.tasks,
						Parent = frame5
					},
					{ UI.corner(UDim.new(1, 0)) }
				)
				local text4 = UI.text({
					Text = "",
					FontFace = Theme.fontBold,
					TextSize = 13,
					TextColor3 = Theme.textDim,
					TextXAlignment = Enum.TextXAlignment.Right,
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -12, 0.5, 0),
					Size = UDim2.fromOffset(74, 20),
					Parent = frame4
				})

				local frame7 = UI.new("Frame", {
					Name = "Claim",
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -10, 0.5, 0),
					Size = UDim2.fromOffset(74, 36),
					BackgroundTransparency = 1,
					Visible = false,
					Parent = frame4
				})

				local button = UI.button({
					parent = frame7,
					size = UDim2.fromScale(1, 1),
					style = "primary",
					text = "Claim",
					textSize = 15,
					sfx = "none",
					onClick = function()
						tasks2.claim(def.id)
					end
				})

				v3[def.id] = {
					def = def,
					label = text3,
					icon = icon2,
					fill = frame6,
					count = text4,
					claimHolder = frame7,
					claim = button
				}
			end
		end
		local function drawMini(data, p)
			local def = data.def
			local v5 = math.min(progress(def.id), def.goal) -- inferred equivalent call
			local v6 = def.goal <= v5
			local v7 = claimed(def.id) -- inferred equivalent call
			local udim = UDim2.fromScale(def.goal > 0 and v5 / def.goal or 0, 1)

			if p then
				UI.tween(data.fill, 0.5, { Size = udim }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
			else
				data.fill.Size = udim
			end

			data.fill.BackgroundColor3 = v6 and Theme.green or Theme.tasks
			local visible = v6 and not v7
			data.claimHolder.Visible = visible
			data.claim:setEnabled(not v[def.id])
			data.count.Visible = not visible
			data.count.Text = v7 and "Claimed"
				or string.format("%d / %d  +%d", v5, def.goal, Config.vipTokens(def.reward, self.isVip()))
			local v8 = v7 and 0.45 or 0
			data.label.TextTransparency = v8
			data.icon.ImageTransparency = v8
		end

		if pages.game and pages.game.taskSlot then
			buildMini(pages.game.taskSlot)
		end

		function tasks2.refresh(p)
			for _, v5 in rowsById do
				drawRow(v5, p)
			end

			for _, v5 in v3 do
				drawMini(v5, p)
			end

			if v4 then
				local tasks = self.tasks
				v4.Text = tasks and tasks.resetAt and "New in " .. countdown(tasks.resetAt - self.serverNow()) or ""
			end

			drawBalance(p)
			drawReset()
			drawEntryPoints()
		end

		local function iconToast(p, p2, p3, p4)
			local toast = self.toast(p, p2, p3)

			if not toast then
				return toast
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

			if p4 then
				rewardChip(toast, p4, 20, 2)
			end

			return toast
		end

		function tasks2.paidToast(p)
			Sound.play("currency")
			iconToast("Unclaimed rewards from yesterday", Theme.token, 4, p)
		end

		function tasks2.apply(tasks, p)
			if type(tasks) ~= "table" then
				return
			end

			self.tasks = tasks
			tasks2.refresh(p and page.Visible)

			if tasks.paid then
				tasks2.paidToast(tasks.paid)
				tasks.paid = nil
			end
		end

		function tasks2.claim(id)
			local v5 = rowsById[id]

			if v5 and not v[id] and ready(v5.def) then -- inferred equivalent call
				v[id] = true
				v5.claim:setEnabled(false)
				task.spawn(function()
					local request = self.request({ type = "claimTask", id = id })
					v[id] = nil

					if type(request) == "table" then
						if request.ok then
							Sound.play("currency")
							task.delay(0.2, Sound.play, "unlock")

							if page.Visible then
								local v6 = v5.claimHolder.AbsolutePosition + v5.claimHolder.AbsoluteSize / 2 - self.gui.AbsolutePosition
								local frame2 = UI.new("Frame", {
									Name = "TaskFx",
									Size = UDim2.new(),
									BackgroundTransparency = 1,
									ZIndex = 50,
									Parent = self.gui
								})
								UI.confetti(frame2, v6, {
									count = 22 + 6 * (request.reward or 1),
									spread = 140,
									zindex = 50,
									colors = {
										Theme.token,
										Theme.gold,
										Color3.fromRGB(255, 230, 150),
										Color3.new(1, 1, 1)
									}
								})

								task.delay(2.5, frame2.Destroy, frame2)
								UI.pop(icon, 0.6, 0.35)
							end
						end

						tasks2.apply(request.tasks, true)
					else
						v5.claim:setEnabled(true)
						self.toast("Couldn't claim that. Try again in a moment.", Theme.loss)
					end
				end)
			end
		end

		function self.handlers.tasksDone(p)
			task.delay(1.6, function()
				if tonumber(p.paid) then
					tasks2.paidToast(p.paid)
				end

				for k, v5 in type(p.done) == "table" and p.done or {} do
					local v6 = Config.TASK_BY_ID[v5]

					if v6 then
						task.delay((k - 1) * 0.5, function()
							Sound.play("success")
							iconToast(
								"Task done: " .. v6.label,
								Theme.green,
								4,
								Config.vipTokens(v6.reward, self.isVip())
							)
						end)
					end
				end
			end)
		end

		local profile = self.handlers.profile
		function self.handlers.profile(p)
			profile(p)

			if p.tasks then
				tasks2.apply(p.tasks, true)
			end
		end

		local flag = false
		local function fetch() -- 2 equivalent calls inferred from this helper
			if flag then
				return
			end

			flag = true
			task.spawn(function()
				local request = self.request({ type = "tasks" })
				flag = false

				if type(request) == "table" then
					tasks2.apply(request, true)
				end
			end)
		end

		function tasks2.onShow()
			tasks2.refresh(false)
			fetch() -- inferred equivalent call
		end

		local resetAt = nil
		task.spawn(function()
			while page.Parent do
				task.wait(1)
				local tasks = self.tasks

				if not (tasks and tasks.resetAt) then
					continue
				end

				if page.Visible then
					drawReset()
				end

				if not (self.serverNow() >= tasks.resetAt + 1 and resetAt ~= tasks.resetAt) then
					continue
				end

				resetAt = tasks.resetAt
				fetch() -- inferred equivalent call
			end
		end)

		function tasks2.state()
			local v5 = {
				tokens = text.Text,
				reset = text2.ContentText,
				claimable = tasks2.claimable(),
				rows = {}
			}

			for _, v6 in Config.DAILY_TASKS do
				local v7 = rowsById[v6.id]
				v5.rows[v6.id] = {
					count = v7.count.Text,
					bar = v7.bar.Visible,
					claim = v7.claimHolder.Visible,
					check = v7.check.Visible
				}
			end

			local home = pages.home
			v5.homeSub = home and home.tasksButton and home.tasksButton.sublabel and home.tasksButton.sublabel.Text
			return v5
		end

		tasks2.refresh(false)
	end
}