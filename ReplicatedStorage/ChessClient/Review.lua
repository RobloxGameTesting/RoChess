local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local AdService = game:GetService("AdService")

local Chess = ReplicatedStorage:WaitForChild("Chess")
local Config = require(Chess.Config)
local Bot = require(Chess.Bot)
local VortexBot = require(Chess.VortexBot)
local Engine = require(Chess.Engine)
local Openings = require(Chess.Openings)
local parent = script.Parent
local Theme = require(parent.Theme)
local UI = require(parent.UI)
local CoachLines = require(parent.CoachLines)
local Sound = require(parent.Sound)
local SoundService = game:GetService("SoundService")

local Review = {}

local coachVoice = nil
local id = nil
local function speak(p, sound)
	if not p or p.id == id then
		return
	end

	id = p.id

	if coachVoice then
		coachVoice:Stop()
	end

	if not sound or not p.voice or p.voice == 0 then
		return
	end

	if not coachVoice then
		coachVoice = Instance.new("Sound")
		coachVoice.Name = "CoachVoice"
		coachVoice.Volume = 0.9
		coachVoice.Parent = SoundService
	end

	coachVoice.SoundId = "rbxassetid://" .. tostring(p.voice)
	coachVoice:Play()
end

local function esc(value) -- 3 equivalent calls inferred from this helper
	return (string.gsub(string.gsub(string.gsub(value, "&", "&amp;"), "<", "&lt;"), ">", "&gt;"))
end

local class2 = {
	brilliant = { label = "Excellent", color = Color3.fromRGB(150, 104, 255), symbol = "!!" },
	great = { label = "Sharp", color = Color3.fromRGB(64, 156, 255), symbol = "!" },
	best = { label = "Best", color = Color3.fromRGB(46, 196, 182), icon = "crown" },
	excellent = { label = "Strong", color = Color3.fromRGB(84, 178, 164), icon = "trend" },
	good = { label = "Good", color = Color3.fromRGB(120, 160, 170), icon = "check" },
	book = { label = "Opening", color = Color3.fromRGB(150, 130, 200), icon = "school" },
	inaccuracy = { label = "Inaccuracy", color = Color3.fromRGB(240, 200, 90), symbol = "?!" },
	mistake = { label = "Mistake", color = Color3.fromRGB(255, 150, 80), symbol = "?" },
	miss = { label = "Missed Win", color = Color3.fromRGB(236, 96, 140), icon = "flag" },
	blunder = { label = "Blunder", color = Color3.fromRGB(214, 44, 84), symbol = "??" }
}

local v = {
	"brilliant",
	"great",
	"best",
	"excellent",
	"good",
	"book",
	"inaccuracy",
	"mistake",
	"miss",
	"blunder"
}
Review.CLASS = class2

local v2 = { 1, 3, 3, 5, 9, 0 }

local function winPct(p) -- 5 equivalent calls inferred from this helper
	if not p then
		return 50
	end

	if not p.mate then
		return (2 / (math.exp(math.clamp(p.score or 0, -1200, 1200) * -0.00368208) + 1) - 1) * 50 + 50
	end

	if p.mate > 0 then
		return 100
	end

	if p.mate < 0 then
		return 0
	end

	return if (p.score or 0) > 0 then 100 else 0
end

Review.winPct = winPct

local function slice(p, p2) -- 5 equivalent calls inferred from this helper
	return table.move(p, 1, p2, 1, {})
end

local function sanOf(startFen, ucis, p, best) -- 1 equivalent call inferred from this helper
	if not best then
		return nil
	end

	local engine = Bot.buildEngine(startFen, slice(ucis, p))
	local v3 = engine:moveFromUci(best)
	return v3 and engine:moveToSan(v3) or best
end

function Review.bookPlies(p)
	local result = {}

	if p.startFen ~= nil and p.startFen ~= Engine.START_FEN then
		return result
	end

	for i = 1, #p.ucis do
		if Bot.isBook(p.ucis, i) or Openings.isBook(p, i) then
			result[i] = true
		else
			break
		end
	end

	return result
end

local function moveAccuracy(p) -- 1 equivalent call inferred from this helper
	return (math.clamp(math.exp(-0.04354 * p) * 103.1668 - 3.1669 + 1, 0, 100))
end

local function stdev(list, p, p2)
	local v3 = p2 - p + 1
	local total = 0

	for i = p, p2 do
		total += list[i]
	end

	local v4 = total / v3
	local total2 = 0

	for i = p, p2 do
		total2 += (list[i] - v4) ^ 2
	end

	return (math.sqrt(total2 / v3))
end

local function gameAccuracy(win, list, list2, count)
	local v3 = {}

	for i = 0, count do
		v3[i + 1] = win[i]
	end

	local v4 = count + 1
	local v5 = math.clamp(count // 10, 2, 8)

	local v6 = { [1] = 0, [-1] = 0 }
	local v7 = { [1] = 0, [-1] = 0 }
	local v8 = { [1] = 0, [-1] = 0 }
	local v9 = { [1] = 0, [-1] = 0 }
	local result = { [1] = 0, [-1] = 0 }

	for i = 1, count do
		local item = list[i]

		if not item then
			continue
		end

		local v10, v11

		if v4 <= v5 then
			v10 = v4
			v11 = 1
		elseif i <= v5 - 2 then
			v10 = v5
			v11 = 1
		else
			v11 = i - v5 + 2
			v10 = v11 + v5 - 1
		end

		local v12 = math.clamp(stdev(v3, v11, v10), 0.5, 12)
		local item2 = list2[i]
		v6[item2] += item * v12
		v7[item2] += v12
		v8[item2] += 1 / math.max(item, 1)
		v9[item2] += 1
	end

	for k, v10 in { 1, -1 } do
		if v9[v10] > 0 then
			result[v10] = math.clamp((v6[v10] / v7[v10] + v9[v10] / v8[v10]) / 2, 0, 100)
		end
	end

	return result
end

local function mateFor(p, p2) -- 5 equivalent calls inferred from this helper
	if p and p.mate and p.mate ~= 0 and (p.mate > 0) == (p2 == 1) then
		return (math.abs(p.mate))
	end

	return nil
end

local function moverOf(p, p2): number -- 3 equivalent calls inferred from this helper
	if p.positions[p2 - 1][p.lastMoves[p2].from] > 0 then
		return 1
	end

	return -1
end

local function judge(p, p2, i)
	local v3 = p2[i - 1] or {}
	local v4

	if v3.best == nil then
		v4 = false
	else
		v4 = p.ucis[i] == v3.best
	end

	local selected = winPct(v3.cmpBest or v3) -- inferred equivalent call
	local selected2

	if v4 and selected then
		selected2 = selected
	else
		local v5

		if v3.played then
			selected2 = winPct(v3.played) -- inferred equivalent call

			if not selected2 then
				v5 = p2[i]
				selected2 = winPct(v5) -- inferred equivalent call
			end
		else
			v5 = p2[i]
			selected2 = winPct(v5) -- inferred equivalent call
		end
	end

	if moverOf(p, i) == -1 then -- inferred equivalent call
		selected = 100 - selected
		selected2 = 100 - selected2
	end

	return math.max(0, selected - selected2), selected, selected2, v4, v3
end

function Review.compute(data, evals)
	local count = #data.ucis
	local v3 = {
		done = true,
		evals = evals,
		classes = {},
		accuracy = { [1] = 0, [-1] = 0 },
		counts = { [1] = {}, [-1] = {} },
		win = {},
		bestSan = {},
		missMate = {},
		drops = {}
	}

	for i = 0, count do
		local win = v3.win
		win[i] = winPct(evals[i]) -- inferred equivalent call
	end

	local bookPlies = Review.bookPlies(data)
	local v4 = {}
	local v5 = {}

	for i = 1, count do
		local v6 = moverOf(data, i) -- inferred equivalent call
		v4[i] = v6
		local v7, v8, v9, v10, v11 = judge(data, evals, i)

		if v11.firstDrop and not v10 and v7 >= 0.6 then
			v7 = (2 * v7 + v11.firstDrop) / 3
		end

		local best = v11.best
		local v12 = v11.legal == 1
		local v13

		if bookPlies[i] then
			v7 = 0
			v13 = "book"
		elseif v12 then
			v13 = "best"
		else
			local class = v3.classes[i - 1]

			if v10 or v7 < 0.6 then
				v13 = "best"
				local v14 = data.flags[i]
					and data.flags[i].capture
					and data.flags[i - 1]
					and data.flags[i - 1].capture
					and data.lastMoves[i - 1]
					and data.lastMoves[i - 1].to == data.lastMoves[i].to
				local v15 = mateFor(v11, v6) ~= nil -- inferred equivalent call
				local v16 = nil
				local function materialLoss() -- 1 equivalent call inferred from this helper
					local v17 = v16

					if not v17 then
						v17 = Bot.materialLoss(data.startFen, slice(data.ucis, i - 1), data.ucis[i]) -- inferred equivalent call
					end

					v16 = v17
					return v16
				end

				local v17, materialLoss2, startFen, ucis, v18

				if v9 >= 50 and (v8 <= 92 or v15 and v11.onlyMove == true) then
					if materialLoss() >= 200 then -- inferred equivalent call
						v13 = "brilliant"
					elseif
						v10
						and v11.onlyMove == true
						and not v15
						and not v14
						and v8 >= 30
						and (v11.legal or 0) >= 3
					then
						v17 = v16

						if not v17 then
							materialLoss2 = Bot.materialLoss
							startFen = data.startFen
							ucis = data.ucis
							v18 = i - 1
							v17 = materialLoss2(startFen, slice(ucis, v18), data.ucis[i]) -- inferred equivalent call
						end

						v16 = v17
						v13 = v16 > -200 and "great" or v13
					end
				elseif v10 and v11.onlyMove == true and not v15 and not v14 and v8 >= 30 and (v11.legal or 0) >= 3 then
					v17 = v16

					if not v17 then
						materialLoss2 = Bot.materialLoss
						startFen = data.startFen
						ucis = data.ucis
						v18 = i - 1
						v17 = materialLoss2(startFen, slice(ucis, v18), data.ucis[i]) -- inferred equivalent call
					end

					v16 = v17
					v13 = v16 > -200 and "great" or v13
				end
			elseif v7 < 2.5 then
				v13 = "excellent"
			elseif v7 < 6 then
				v13 = "good"
			elseif v7 < 11 then
				v13 = "inaccuracy"
			elseif v7 < 20 then
				v13 = "mistake"
			else
				v13 = "blunder"
			end

			if v13 ~= "best" and v13 ~= "brilliant" and v13 ~= "great" and v9 >= 30 then
				local v14 = mateFor(v11, v6) -- inferred equivalent call
				local v15 = v11.played and mateFor(v11.played, v6) ~= nil -- inferred equivalent call

				if v14 and v14 <= 3 and not v15 and v7 >= 6 then
					v3.missMate[i] = v14
					v13 = "miss"
				elseif
					(v13 == "mistake" or v13 == "blunder")
					and v8 >= 60
					and (class == "inaccuracy" or class == "mistake" or class == "blunder" or class == "miss")
				then
					v13 = "miss"
				end
			end
		end

		if not v12 then
			v5[i] = moveAccuracy(v7) -- inferred equivalent call
		end

		v3.drops[i] = v7
		v3.classes[i] = v13
		v3.counts[v6][v13] = (v3.counts[v6][v13] or 0) + 1

		if not (v13 ~= "best" and v13 ~= "book" and v13 ~= "brilliant" and v13 ~= "great") then
			continue
		end

		if not best then
			continue
		end

		local bestSan = v3.bestSan
		best = sanOf(data.startFen, data.ucis, i - 1, best) -- inferred equivalent call
		bestSan[i] = best
	end

	v3.accuracy = gameAccuracy(v3.win, v5, v4, count)
	return v3
end

Review.BUDGET = 9
Review.BOOK_TIME = 0.04
Review.MIN_TIME = 0.1
Review.MAX_TIME = 0.4
Review.SLICE = 0.01

Review.SERVER_SECS_PER_PLY = 0.05

Review.VERIFY_DROP = 9
Review.VERIFY_MAX = 24
Review.VERIFY_BUDGET = 6
Review.VERIFY_MIN_TIME = 0.35
Review.VERIFY_MAX_TIME = 1

function Review.analyseGame(p, cancelled, callback, options)
	local v3 = options or {}

	if v3.slice ~= false and not v3.local_ then
		local v4 = true
		local v5 = 0

		if callback then
			task.spawn(function()
				local lastTime = os.clock()
				local v6 = math.max(2, #p.ucis * Review.SERVER_SECS_PER_PLY)

				while v4 and not (cancelled and cancelled()) do
					v5 = (1 - math.exp(-(os.clock() - lastTime) / v6)) * 0.9
					callback(v5)
					task.wait(0.1)
				end
			end)
		end

		local success, result = pcall(VortexBot.reviewGame, p.startFen, p.ucis)
		v4 = false

		if cancelled and cancelled() then
			return nil
		end

		if success and result then
			if callback then
				callback(1)
			end

			return result
		elseif callback and v5 > 0 then
			local v6 = v5
			local v7 = callback
			callback = function(p2)
				v7(v6 + (1 - v6) * p2)
			end
		end
	end

	local count = #p.ucis
	local bookPlies = Review.bookPlies(p)
	local v4 = 1

	for i = 0, count - 1 do
		if not bookPlies[i + 1] then
			v4 += 1
		end
	end

	local v5 = math.clamp((v3.budget or Review.BUDGET) / v4, Review.MIN_TIME, Review.MAX_TIME)
	local slice2 = v3.slice

	if slice2 == nil then
		slice2 = Review.SLICE
	end

	local result = {}
	local count2 = 0

	for i = count, 0, -1 do
		if cancelled and cancelled() then
			return nil
		end

		local v6

		if bookPlies[i + 1] then
			v6 = Review.BOOK_TIME or v5
		else
			v6 = v5
		end

		result[i] = Bot.review(p.startFen, slice(p.ucis, i), p.ucis[i + 1], v6, 18, { -- inferred equivalent call
			cancelled = cancelled,
			slice = slice2,
			cpuTime = true
		})

		count2 += 1

		if callback then
			callback(count2 * 0.85 / (count + 1))
		end
	end

	local v6 = {}

	for i = 1, count do
		if bookPlies[i] or not result[i - 1] or not result[i - 1].best or not ((result[i - 1].legal or 0) > 1) then
			continue
		end

		local raw, v7, v8, v9, v10 = judge(p, result, i)
		local v11 = moverOf(p, i) -- inferred equivalent call
		local v12 = not v9

		if v12 then
			v12 = mateFor(v10, v11) and not mateFor(v10.played, v11) and v8 >= 30 -- inferred equivalent call
		end

		if v9 or not (Review.VERIFY_DROP <= raw or v12) then
			continue
		end

		table.insert(v6, {
			i = i,
			raw = raw,
			drop = raw + (v12 and 100 or 0)
		})
	end

	table.sort(v6, function(a, b): boolean
		return a.drop > b.drop
	end)

	while #v6 > Review.VERIFY_MAX do
		table.remove(v6)
	end

	table.sort(v6, function(a, b): boolean
		return a.i > b.i
	end)

	local v7 = math.clamp(
		math.min(v5 * 3, Review.VERIFY_BUDGET / math.max(1, #v6)),
		Review.VERIFY_MIN_TIME,
		Review.VERIFY_MAX_TIME
	)

	for k, v8 in v6 do
		if cancelled and cancelled() then
			return nil
		end

		local i = v8.i
		local v9 = Bot.review(p.startFen, slice(p.ucis, i - 1), p.ucis[i], v7, 24, { -- inferred equivalent call
			cancelled = cancelled,
			slice = slice2,
			cpuTime = true,
			playedShare = 0.6
		})

		if v9.best and (v9.depth or 0) >= (result[i - 1].depth or 0) then
			v9.verified = true
			v9.firstDrop = v8.raw
			result[i - 1] = v9
		end

		if callback then
			callback(0.85 + 0.15 * k / #v6)
		end
	end

	return result
end

function Review:install()
	local pages = self.pages
	local page, parent4 = pages.newPage("review", "Game Breakdown", "analysis", Theme.green, true)
	local review2 = { frame = page }
	pages.review = review2

	local frame = UI.new("Frame", {
		Name = "Progress",
		Size = UDim2.new(1, 0, 0, 150),
		BackgroundColor3 = Theme.panelLight,
		LayoutOrder = 1,
		Parent = parent4
	}, { UI.corner(8) })
	local icon = UI.icon("analysis", 40, Theme.green, {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 16),
		Parent = frame
	})

	UI.text({
		Text = "Analyzing your game...",
		FontFace = Theme.fontBold,
		TextSize = 18,
		Size = UDim2.new(1, 0, 0, 24),
		Position = UDim2.fromOffset(0, 64),
		Parent = frame
	})

	local frame2 = UI.new(
		"Frame",
		{
			Size = UDim2.new(1, -40, 0, 10),
			Position = UDim2.new(0, 20, 0, 100),
			BackgroundColor3 = Theme.button,
			Parent = frame
		},
		{ UI.corner(5) }
	)
	local frame3 = UI.new("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = Theme.green,
		Parent = frame2
	}, {
		UI.corner(5)
	})
	local text = UI.text({
		Text = "0%",
		TextSize = 14,
		TextColor3 = Theme.textDim,
		Size = UDim2.new(1, 0, 0, 18),
		Position = UDim2.fromOffset(0, 118),
		Parent = frame
	})

	local frame4 = UI.new("Frame", {
		Name = "Summary",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Visible = false,
		LayoutOrder = 2,
		Parent = parent4
	}, { UI.list(Enum.FillDirection.Vertical, 10) })

	local frame5 = UI.new("Frame", {
		Name = "Accuracy",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 1,
		Parent = frame4
	}, { UI.list(Enum.FillDirection.Vertical, 6) })
	UI.text({
		Text = "Accuracy",
		FontFace = Theme.fontBold,
		TextSize = 13,
		TextColor3 = Theme.textDim,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 16),
		LayoutOrder = 0,
		Parent = frame5
	})

	local v3 = {}

	for i = 1, 2 do
		local frame6 = UI.new(
			"Frame",
			{
				Size = UDim2.new(1, 0, 0, 58),
				BackgroundColor3 = Theme.panelLight,
				LayoutOrder = i,
				Parent = frame5
			},
			{ UI.corner(12) }
		)
		UI.lift(frame6, 0.12)
		local avatar = UI.avatar(nil, 38, {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 10, 0.5, 0),
			Parent = frame6
		})

		local text2 = UI.text({
			Text = "",
			FontFace = Theme.fontBold,
			TextSize = 15,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Size = UDim2.new(1, -150, 0, 18),
			Position = UDim2.fromOffset(58, 10),
			Parent = frame6
		})

		local frame7 = UI.new("Frame", {
			Name = "Track",
			Size = UDim2.new(1, -150, 0, 8),
			Position = UDim2.fromOffset(58, 36),
			BackgroundColor3 = Theme.track,
			Parent = frame6
		}, { UI.corner(UDim.new(1, 0)) })
		local frame8 = UI.new("Frame", {
			Name = "Fill",
			Size = UDim2.fromScale(0, 1),
			BackgroundColor3 = Theme.teal or Theme.green,
			Parent = frame7
		}, { UI.corner(UDim.new(1, 0)) })
		local frame9 = UI.new("Frame", {
			Name = "Score",
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -10, 0.5, 0),
			Size = UDim2.fromOffset(74, 38),
			BackgroundColor3 = Theme.teal or Theme.green,
			Parent = frame6
		}, { UI.corner(UDim.new(1, 0)) })
		local text3 = UI.text({
			Text = "--",
			FontFace = Theme.fontHeavy,
			TextSize = 20,
			TextColor3 = Color3.new(1, 1, 1),
			Size = UDim2.fromScale(1, 1),
			Parent = frame9
		})

		UI.ink(text3, true)

		local textButton = UI.new("TextButton", {
			Name = "Open",
			Text = "",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -96, 1, 0),
			ZIndex = 2,
			Visible = false,
			Parent = frame6
		})

		textButton:SetAttribute("Sfx", "press")
		v3[i] = {
			avatar = avatar,
			name = text2,
			value = text3,
			box = frame9,
			fill = frame8,
			open = textButton
		}
		textButton.Activated:Connect(function()
			local info = v3[i].info

			if info and self.openProfile then
				self.openProfile(info.userId, nil, info)
			end
		end)
	end

	local textButton = UI.new("TextButton", {
		Name = "Graph",
		Size = UDim2.new(1, 0, 0, 74),
		BackgroundColor3 = Color3.fromRGB(50, 52, 57),
		ClipsDescendants = true,
		LayoutOrder = 3,
		Selectable = false,
		Parent = frame4
	}, { UI.corner(6) })
	local frame6 = UI.new("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Parent = textButton
	})

	local frame7 = UI.new("Frame", {
		Size = UDim2.new(0, 2, 1, 0),
		BackgroundColor3 = Theme.green,
		ZIndex = 3,
		Parent = textButton
	})

	UI.new("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.fromScale(0, 0.5),
		BackgroundColor3 = Color3.fromRGB(120, 118, 115),
		BackgroundTransparency = 0.5,
		ZIndex = 2,
		Parent = textButton
	})

	textButton.Activated:Connect(function()
		local session = self.session

		if not (session and session.review and session.review.done) then
			return
		end

		local UserInputService = game:GetService("UserInputService")
		local mouseLocation = UserInputService:GetMouseLocation()
		local GuiService = game:GetService("GuiService")
		local guiInset = GuiService:GetGuiInset()
		local v4 = (mouseLocation.X - textButton.AbsolutePosition.X) / textButton.AbsoluteSize.X
		_ = guiInset
		self.navigate((math.clamp(math.floor(v4 * (#session.ucis + 1)), 0, #session.ucis)))
		pages.show("game")
	end)

	local frame8 = UI.new("Frame", {
		Name = "Counts",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.panelLight,
		LayoutOrder = 6,
		Parent = frame4
	}, { UI.corner(8), UI.list(Enum.FillDirection.Vertical, 0), UI.pad(6, 12, 6, 12) })
	local v4 = {}

	for k, v5 in v do
		local v6 = class2[v5]
		local frame9 = UI.new("Frame", {
			Size = UDim2.new(1, 0, 0, 28),
			BackgroundTransparency = 1,
			LayoutOrder = k,
			Parent = frame8
		})

		local text2 = UI.text({
			Text = "0",
			FontFace = Theme.fontBold,
			TextSize = 16,
			TextColor3 = v6.color,
			Size = UDim2.new(0, 40, 1, 0),
			Parent = frame9
		})

		local frame10 = UI.new(
			"Frame",
			{
				Size = UDim2.new(1, -80, 1, 0),
				Position = UDim2.fromOffset(40, 0),
				BackgroundTransparency = 1,
				Parent = frame9
			},
			{ UI.list(
					Enum.FillDirection.Horizontal,
					8,
					Enum.HorizontalAlignment.Center,
					Enum.VerticalAlignment.Center
				) }
		)
		local frame11 = UI.new(
			"Frame",
			{
				Size = UDim2.fromOffset(20, 20),
				BackgroundColor3 = v6.color,
				LayoutOrder = 1,
				Parent = frame10
			},
			{ UI.corner(UDim.new(0.3, 0)) }
		)

		if v6.icon then
			UI.icon(v6.icon, 14, Color3.new(1, 1, 1), {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Parent = frame11
			})
		else
			UI.text({
				Text = v6.symbol,
				FontFace = Theme.fontHeavy,
				TextSize = 11,
				Size = UDim2.fromScale(1, 1),
				Parent = frame11
			})
		end

		UI.text({
			Text = v6.label,
			FontFace = Theme.fontMedium,
			TextSize = 15,
			TextColor3 = Theme.textSoft,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.fromScale(0, 1),
			LayoutOrder = 2,
			Parent = frame10
		})

		v4[v5] = {
			left = text2,
			right = UI.text({
				Text = "0",
				FontFace = Theme.fontBold,
				TextSize = 16,
				TextColor3 = v6.color,
				Size = UDim2.new(0, 40, 1, 0),
				Position = UDim2.new(1, -40, 0, 0),
				Parent = frame9
			})
		}
	end

	UI.button({
		parent = frame4,
		size = UDim2.new(1, 0, 0, 56),
		style = "primary",
		icon = "play",
		text = "Review Moves",
		textSize = 20,
		layoutOrder = 4,
		onClick = function()
			local session = self.session

			if session then
				self.navigate(0)
			end

			pages.show("game")

			if session then
				self.render({ animate = false })
			end
		end
	})

	local frame9 = UI.new("Frame", {
		Name = "FreeNote",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.panelLight,
		Visible = false,
		LayoutOrder = 5,
		Parent = frame4
	}, { UI.corner(10), UI.pad(8, 4, 8, 12) })
	UI.lift(frame9, 0.1)
	local text2 = UI.text({
		Name = "Text",
		Text = "",
		TextSize = 13,
		TextColor3 = Theme.textDim,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Size = UDim2.new(1, -108, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = frame9
	})

	local textButton2 = UI.new("TextButton", {
		Name = "GetUnlimited",
		Text = "Get unlimited",
		FontFace = Theme.fontBold,
		TextSize = 13,
		TextColor3 = Theme.blueSoft or Theme.green,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 104, 1, 0),
		Parent = frame9
	})

	textButton2:SetAttribute("Sfx", "press")
	UI.hover(textButton2, nil, { TextColor3 = Theme.text }, {
		TextColor3 = Theme.blueSoft or Theme.green
	})
	textButton2.Activated:Connect(function()
		self.send({ type = "fx", ev = "reviewCard", what = "notePass", card = "note" })

		if not pcall(function()
			MarketplaceService:PromptGamePassPurchase(Players.LocalPlayer, Config.REVIEW_PASS)
		end) then
			self.toast("Couldn't open the purchase. Try again in a moment.", Theme.loss)
		end
	end)
	local function untilText(p) -- 1 equivalent call inferred from this helper
		local v5 = math.max(0, (math.floor(p)))
		local v6 = v5 // 3600
		local v7 = v5 % 3600 // 60

		if v6 > 0 then
			return v6 .. "h " .. v7 .. "m"
		end

		return math.max(1, v7) .. "m"
	end

	local button = UI.button({
		name = "NewGame",
		parent = frame4,
		size = UDim2.new(1, 0, 0, 46),
		style = "secondary",
		icon = "add",
		text = "New Game",
		textSize = 17,
		layoutOrder = 7,
		onClick = function()
			self.newGame()
		end
	})

	button.holder.Visible = false
	UI.button({
		parent = frame4,
		size = UDim2.new(1, 0, 0, 46),
		style = "secondary",
		icon = "search",
		text = "Analysis Board",
		textSize = 17,
		layoutOrder = 8,
		onClick = function()
			if self.analyseCurrent then
				self.analyseCurrent()
			end
		end
	})

	local function drawGraph(session)
		frame6:ClearAllChildren()
		local review = session.review
		local count = #session.ucis
		local v5 = 1 / (count + 1)

		for i = 0, count do
			local v6 = review.win[i] / 100
			UI.new("Frame", {
				Size = UDim2.new(v5, 1, v6, 0),
				AnchorPoint = Vector2.new(0, 1),
				Position = UDim2.fromScale(i * v5, 1),
				BackgroundColor3 = Color3.fromRGB(238, 238, 238),
				Parent = frame6
			})

			local class = review.classes[i]

			if
				class == "blunder"
				or class == "mistake"
				or class == "brilliant"
				or class == "great"
				or class == "miss"
			then
				UI.new("Frame", {
					Size = UDim2.fromOffset(6, 6),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new((i + 0.5) * v5, 0, 1 - v6, 0),
					BackgroundColor3 = class2[class].color,
					ZIndex = 2,
					Parent = frame6
				}, { UI.corner(UDim.new(1, 0)) })
			end
		end
	end

	function review2.refresh()
		local session = self.session

		if session and session.review then
			local review = session.review

			if review.done then
				frame.Visible = false
				local v5 = not frame4.Visible or review2.shownFor ~= review
				review2.shownFor = review
				button.holder.Visible = self.newFlow()
				local reviewFree = tonumber(session.reviewFree)
				frame9.Visible = reviewFree ~= nil

				if frame9.Visible then
					text2.Text = "Today's free breakdown. Next one in " .. untilText(reviewFree - self.serverNow()) .. "." -- inferred equivalent call

					if v5 then
						self.send({ type = "fx", ev = "reviewCard", what = "note", card = "note" })
					end
				end

				UI.reveal(frame4, true, 10, 0.18)

				local v6 = { session.myColor or session.viewColor or 1, -(session.myColor or session.viewColor or 1) }

				for k, v7 in v6 do
					local white = v7 == 1 and session.white or session.black
					local v8 = v3[k]
					v8.avatar.set(white)
					v8.name.Text = white.display or white.name or ""

					v8.info = white
					local open = v8.open
					local visible

					if self.openProfile == nil then
						visible = false
					else
						visible = not white.bot

						if visible then
							if type(white.userId) == "number" then
								visible = white.userId ~= 0
							else
								visible = false
							end
						end
					end

					open.Visible = visible

					if v5 then
						local numberValue = Instance.new("NumberValue")
						local value = v8.value
						value.Text = "0.0"
						numberValue.Changed:Connect(function(p)
							value.Text = string.format("%.1f", p)
						end)
						UI.tween(numberValue, 0.6, { Value = review.accuracy[v7] }, Enum.EasingStyle.Quart).Completed:Connect(function()
							value.Text = string.format("%.1f", review.accuracy[v7])
							numberValue:Destroy()
						end)
						UI.pop(v8.box, 0.85, 0.22)
					else
						v8.value.Text = string.format("%.1f", review.accuracy[v7])
					end

					local v9 = review.accuracy[v7] or 0
					local teal = v9 >= 80 and (Theme.teal or Theme.green)
						or v9 >= 60 and Color3.fromRGB(240, 176, 64)
						or Theme.coral
						or Theme.green
					v8.box.BackgroundColor3 = teal
					v8.value.TextColor3 = Color3.new(1, 1, 1)
					v8.fill.BackgroundColor3 = teal

					if v5 then
						v8.fill.Size = UDim2.fromScale(0, 1)
						UI.tween(v8.fill, 0.6, {
							Size = UDim2.fromScale(math.clamp(v9 / 100, 0, 1), 1)
						}, Enum.EasingStyle.Quart)
					else
						v8.fill.Size = UDim2.fromScale(math.clamp(v9 / 100, 0, 1), 1)
					end
				end

				for k, v7 in v4 do
					v7.left.Text = tostring(review.counts[v6[1]][k] or 0)
					v7.right.Text = tostring(review.counts[v6[2]][k] or 0)
				end

				drawGraph(session)
			else
				frame.Visible = true
				frame4.Visible = false
				UI.tween(frame3, 0.2, {
					Size = UDim2.fromScale(review.progress or 0, 1)
				})
				text.Text = string.format("%d%%", (math.floor((review.progress or 0) * 100)))
			end
		else
			frame.Visible = false
			frame4.Visible = false
		end
	end
	review2.onShow = review2.refresh

	function review2.onFrame()
		local session = self.session

		if page.Visible and session and session.review and not session.review.done then
			icon.Rotation = math.sin(os.clock() * 4) * 12
		end

		if session and session.review and session.review.done then
			UI.to(frame7, UI.SNAP, {
				Position = UDim2.new((session.viewPly + 0.5) / (#session.ucis + 1), -1, 0, 0)
			})
		end
	end

	function Review.onRender(object)
		local review = object and object.review

		if not (review and review.done) then
			return
		end

		local viewPly = object.viewPly
		local eval = review.evals[viewPly]
		self.setEval(eval and eval.score or 0, eval and eval.mate)
		local board = self.board
		board:setArrow("best", nil)
		local sound = self.settings.sound ~= false

		if viewPly == 0 then
			board:setMoveBadge(nil)
			local v5 = CoachLines.pick("intro", #object.ucis)
			self.pages.game.setCoach(
				esc(v5.text) .. "\n<font size=\"13\" color=\"#989795\">Step through the game to see how each move rated.</font>", -- inferred equivalent call
				Theme.divider
			)

			speak(v5, sound)
		else
			local class = review.classes[viewPly]
			local v5 = class2[class]
			board:setMoveBadge(object.lastMoves[viewPly].to, v5.color, v5.symbol, v5.icon)
			local san = object.sans[viewPly]
			local v6

			if class == "brilliant" then
				v6 = san .. " is excellent!"
			elseif class == "great" then
				v6 = san .. " is a sharp move!"
			elseif class == "best" then
				v6 = san .. " is the best move"
			elseif class == "book" then
				local v7 = Openings.forSession(object, viewPly)
				v6 = san .. " is an opening move" .. (v7 and "  ·  " .. v7 or "")
			elseif class == "excellent" or class == "good" then
				v6 = san .. " is " .. string.lower(v5.label)
			elseif class == "miss" then
				local v7 = review.missMate and review.missMate[viewPly]
				v6 = san .. (v7 and (v7 == 1 and " misses mate in 1" or " misses mate in " .. v7 or " misses a chance") or " misses a chance")
			else
				v6 = san .. " is a" .. (class == "inaccuracy" and "n " or " ") .. string.lower(v5.label)
			end

			local v7 = review.bestSan[viewPly]

			if v7 and class ~= "excellent" and class ~= "good" then
				v6 ..= ". " .. v7 .. " was best."
			elseif v7 then
				v6 ..= " (best: " .. v7 .. ")"
			end

			local v8

			if viewPly == #object.ucis then
				if string.find(san, "#", 1, true) then
					v8 = object:engineAt(viewPly).side == (object.myColor or 1) and "loss" or "checkmate"
				else
					v8 = object.result == "1/2-1/2" and "draw"
						or (object.result == "1-0" or object.result == "0-1")
						and ((object.result == "1-0") == ((object.myColor or 1) == 1) and "win" or "loss")
						or class
				end
			else
				v8 = class
			end

			local v9 = CoachLines.pick(v8, viewPly) or CoachLines.pick(class, viewPly)
			local v10 = "<b>" .. esc(v6) .. "</b>" -- inferred equivalent call

			if v9 then
				v10 ..= "\n<font face=\"BuilderSans\" weight=\"500\" color=\"#DCDBD9\">" .. esc(v9.text) .. "</font>" -- inferred equivalent call
			end

			self.pages.game.setCoach(v10, v5.color)
			speak(v9, sound)
			local eval2 = review.evals[viewPly - 1]

			if eval2 and eval2.best and object.ucis[viewPly] ~= eval2.best and class ~= "book" then
				board:setArrow(
					"best",
					Engine.algToIndex64((string.sub(eval2.best, 1, 2))),
					Engine.algToIndex64((string.sub(eval2.best, 3, 4))),
					Color3.fromRGB(46, 196, 182),
					0.25
				)
			end
		end
	end

	function Review.applyBadges(p)
		local review = p.review

		if not (review and review.done) then
			return
		end

		local moveList = self.pages.game.moveList

		for k, class in review.classes do
			local v5 = class2[class]

			if class ~= "best" and class ~= "excellent" and class ~= "good" then
				moveList:setBadge(k, v5.color, v5.symbol, v5.icon)
			end
		end
	end

	local v5 = utf8.char(57346)

	local priceInRobux = nil
	local flag = false

	local function cardEvent(what, card) -- 11 equivalent calls inferred from this helper
		self.send({ type = "fx", ev = "reviewCard", what = what, card = card })
	end

	local function trackClose(card, reviewPending, card2) -- 1 equivalent call inferred from this helper
		if not card then
			return
		end

		local v6 = false
		card.AncestryChanged:Connect(function(p, parent2)
			if parent2 == nil and not v6 then
				v6 = true

				if self.reviewPending == reviewPending then
					cardEvent("close", card2) -- inferred equivalent call
				end
			end
		end)
	end

	local function reviewJob(p)
		local reviewJob2 = p.reviewJob

		if reviewJob2 and not reviewJob2.failed then
			return reviewJob2
		end

		local reviewJob3 = { done = false, progress = 0 }
		local v6 = {}
		function reviewJob3.on(p2)
			v6[p2] = true
			return function()
				v6[p2] = nil
			end
		end

		local function emit(p2, p3)
			for callback in table.clone(v6) do
				task.spawn(callback, p2, p3)
			end
		end
		p.reviewJob = reviewJob3
		task.spawn(function()
			local function cancelled(): boolean
				return self.session ~= p
			end

			local success, result = pcall(function()
				local analyseGame = Review.analyseGame(p, cancelled, function(progress)
					reviewJob3.progress = progress
					emit("progress", progress)
				end)

				if self.session ~= p or not analyseGame then
					reviewJob3.failed = "cancelled"
					return
				end

				local success, result = pcall(Review.compute, p, analyseGame)

				if not success then
					warn("[Chess] Game Breakdown compute failed, retrying locally: " .. tostring(result))
					local analyseGame2 = Review.analyseGame(p, cancelled, nil, {
						slice = Review.SLICE,
						local_ = true
					})

					if self.session ~= p or not analyseGame2 then
						reviewJob3.failed = "cancelled"
						return
					end

					result = Review.compute(p, analyseGame2)
				end

				reviewJob3.result = result
			end)

			if not success then
				warn("[Chess] Game Breakdown failed: " .. tostring(result))
				reviewJob3.failed = "error"
				reviewJob3.result = nil
			end

			reviewJob3.done = true
			emit("done")
		end)
		return reviewJob3
	end

	Review.job = reviewJob

	local function waitText(p) -- 2 equivalent calls inferred from this helper
		local v6 = math.max(0, (math.floor(p)))
		local v7 = v6 // 3600
		local v8 = v6 % 3600 // 60

		if v7 > 0 then
			return v7 .. "h " .. v8 .. "m"
		end

		return math.max(1, v8) .. "m"
	end

	local function passText() -- 2 equivalent calls inferred from this helper
		return "Infinite Game Breakdown   " .. v5 .. " " .. tostring(priceInRobux or Config.REVIEW_PASS_ROBUX)
	end

	local function showLockedClassic(reviewPending, p)
		local modals = self.modals
		self.reviewPending = reviewPending
		local modal = modals.openModal("ReviewLocked", 340)
		local parent2 = modal.Parent

		if parent2 then
			local v6 = false
			local card = "classic"
			parent2.AncestryChanged:Connect(function(p2, parent3)
				if parent3 == nil and not v6 then
					v6 = true

					if self.reviewPending == reviewPending then
						cardEvent("close", card) -- inferred equivalent call
					end
				end
			end)
		end

		local list = UI.list(Enum.FillDirection.Vertical, 12, Enum.HorizontalAlignment.Center)
		list.Parent = modal
		local padded = UI.pad(22, 20, 20, 20)
		padded.Parent = modal
		modals.closeButton(modal, "ReviewLocked")
		UI.icon("analysis", 44, Theme.green, { LayoutOrder = 1, Parent = modal })
		UI.text({
			Text = "Daily free breakdown used",
			FontFace = Theme.fontHeavy,
			TextSize = 22,
			Size = UDim2.new(1, 0, 0, 28),
			LayoutOrder = 2,
			Parent = modal
		})

		local FREE_REVIEWS_PER_DAY = Config.FREE_REVIEWS_PER_DAY
		UI.text({
			Text = "You get " .. FREE_REVIEWS_PER_DAY .. " free Game Breakdown" .. (FREE_REVIEWS_PER_DAY == 1 and "" or "s") .. " a day. Watch a short video ad to unlock this one, or get Infinite Game Breakdown for every game.",
			TextSize = 15,
			TextColor3 = Theme.textSoft,
			TextWrapped = true,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = 3,
			Parent = modal
		})

		local button2 = UI.button({
			name = "ReviewPass",
			parent = modal,
			size = UDim2.new(1, 0, 0, 50),
			style = "primary",
			text = passText(), -- inferred equivalent call
			textSize = 17,
			layoutOrder = 4,
			onClick = function()
				cardEvent("pass", "classic") -- inferred equivalent call

				if not pcall(function()
					MarketplaceService:PromptGamePassPurchase(Players.LocalPlayer, Config.REVIEW_PASS)
				end) then
					self.toast("Couldn't open the purchase. Try again in a moment.", Theme.loss)
				end
			end
		})

		if not priceInRobux then
			task.spawn(function()
				local success, productInfoAsync = pcall(
					MarketplaceService.GetProductInfoAsync,
					MarketplaceService,
					Config.REVIEW_PASS,
					Enum.InfoType.GamePass
				)

				if success and productInfoAsync and tonumber(productInfoAsync.PriceInRobux) then
					priceInRobux = productInfoAsync.PriceInRobux

					if button2.holder.Parent then
						button2:setText(passText()) -- inferred equivalent call
					end
				end
			end)
		end

		local v6 = nil
		local function adReset(p2, p3) -- 7 equivalent calls inferred from this helper
			if v6 and v6.holder.Parent then
				v6:setText(p2)
				v6:setEnabled(p3)
			end
		end
		v6 = UI.button({
			name = "ReviewAd",
			parent = modal,
			size = UDim2.new(1, 0, 0, 46),
			style = "secondary",
			icon = "play",
			text = "Looking for an ad...",
			textSize = 16,
			layoutOrder = 5,
			onClick = function()
				if flag then
					return
				end

				flag = true
				cardEvent("ad", "classic") -- inferred equivalent call
				adReset("Loading ad...", false) -- inferred equivalent call
				task.spawn(function()
					local request = self.request({ type = "reviewAd" })
					flag = false
					local result = request and request.result

					if result == "ShowCompleted" then
						adReset("Unlocking breakdown...", false) -- inferred equivalent call
						task.delay(20, function()
							if self.reviewPending == reviewPending and v6.holder.Parent then
								adReset("Watch an ad: 1 breakdown", true) -- inferred equivalent call
								self.toast("Your breakdown will unlock as soon as Roblox sends the reward.")
							end
						end)
					elseif result == "ShowInterrupted" then
						adReset("Watch an ad: 1 breakdown", true) -- inferred equivalent call
						self.toast("The ad was closed early, so it didn't unlock a breakdown.", Theme.loss)
					else
						adReset("No ad available right now", false) -- inferred equivalent call
						self.toast("No ad available right now. Try again later.", Theme.loss)
					end
				end)
			end
		})

		v6:setEnabled(false)

		if p.ad then
			task.spawn(function()
				local success, adAvailabilityNowAsync = pcall(
					AdService.GetAdAvailabilityNowAsync,
					AdService,
					Enum.AdFormat.RewardedVideo
				)

				if
					success
					and adAvailabilityNowAsync
					and adAvailabilityNowAsync.AdAvailabilityResult == Enum.AdAvailabilityResult.IsAvailable
				then
					adReset("Watch an ad: 1 breakdown", true) -- inferred equivalent call
				else
					cardEvent("noAd", "classic") -- inferred equivalent call
					adReset("No ad available right now", false) -- inferred equivalent call
				end
			end)
		else
			v6:setVisible(false)
		end

		if tonumber(p.resetAt) then
			UI.text({
				Text = "Next free breakdown in " .. waitText(p.resetAt - self.serverNow()), -- inferred equivalent call
				TextSize = 13,
				TextColor3 = Theme.textDim,
				Size = UDim2.new(1, 0, 0, 16),
				LayoutOrder = 6,
				Parent = modal
			})
		end
	end

	local v6 = { preview = true, static = true, classic = true }

	local v7 = { "brilliant", "great", "miss", "blunder", "mistake" }
	local v8 = {
		brilliant = { "Excellent move", "Excellent moves" },
		great = { "Sharp move", "Sharp moves" },
		best = { "Best move", "Best moves" },
		excellent = { "Strong move", "Strong moves" },
		mistake = { "Mistake", "Mistakes" },
		miss = { "Missed win", "Missed wins" },
		blunder = { "Blunder", "Blunders" }
	}

	local count = 0

	local function accTint(p) -- 2 equivalent calls inferred from this helper
		return p >= 80 and (Theme.teal or Theme.green)
			or p >= 60 and Color3.fromRGB(240, 176, 64)
			or Theme.coral
			or Theme.green
	end

	local function classBadge(p, p2, frame10, value)
		local v9 = class2[p]
		local frame11 = UI.new("Frame", {
			Name = "Badge",
			Size = UDim2.fromOffset(p2, p2),
			BackgroundColor3 = v9.color,
			LayoutOrder = value or 1,
			Parent = frame10
		}, { UI.corner(UDim.new(0.3, 0)) })

		if v9.icon then
			UI.icon(v9.icon, (math.floor)(p2 * 0.7), Color3.new(1, 1, 1), {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Parent = frame11
			})
			return frame11
		end

		UI.text({
			Text = v9.symbol,
			FontFace = Theme.fontHeavy,
			TextSize = (math.floor)(p2 * 0.55),
			Size = UDim2.fromScale(1, 1),
			Parent = frame11
		})

		return frame11
	end

	local function momentChip(frame10, p, p2, k)
		local v9 = class2[p]
		local frame11 = UI.new("Frame", {
			Name = "Chip",
			Size = UDim2.fromOffset(0, 30),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundColor3 = v9.color,
			BackgroundTransparency = p2 and 0.8 or 0.9,
			LayoutOrder = k,
			Parent = frame10
		}, {
			UI.corner(UDim.new(1, 0)),
			UI.pad(0, 12, 0, 5),
			UI.list(Enum.FillDirection.Horizontal, 6, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)
		})

		local v10 = classBadge(p, 20, frame11, 1)
		local v11 = v8[p] or { v9.label, v9.label }
		UI.text({
			Name = "Label",
			Text = p2 and string.format("%d %s", p2, p2 == 1 and v11[1] or v11[2]) or "? " .. v11[2],
			FontFace = Theme.fontBold,
			TextSize = 14,
			TextColor3 = p2 and Theme.text or Theme.textDim,
			Size = UDim2.fromOffset(0, 30),
			AutomaticSize = Enum.AutomaticSize.X,
			LayoutOrder = 2,
			Parent = frame11
		})

		if not p2 then
			v10.BackgroundTransparency = 0.45
		end

		return frame11
	end

	local function accuracyTile(frame10, p, layoutOrder, p2)
		local frame11 = UI.new("Frame", {
			Name = "Player" .. layoutOrder,
			Size = UDim2.new(0.5, -4, 1, 0),
			BackgroundColor3 = Theme.panel,
			LayoutOrder = layoutOrder,
			Parent = frame10
		}, { UI.corner(10) })
		UI.lift(frame11, 0.1)
		UI.avatar(p, 24, { Position = UDim2.fromOffset(8, 8), Parent = frame11 })
		UI.text({
			Name = "PlayerName",
			Text = p and (p.display or p.name or "") or "",
			FontFace = Theme.fontBold,
			TextSize = 13,
			TextColor3 = Theme.textSoft,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Size = UDim2.new(1, -46, 0, 24),
			Position = UDim2.fromOffset(38, 8),
			Parent = frame11
		})
		local v9 = p2 and 30 or 34
		local frame12 = UI.new("Frame", {
			Name = "Box",
			Size = UDim2.new(1, -16, 0, v9),
			Position = UDim2.new(0, 8, 1, -(v9 + 8)),
			BackgroundColor3 = Theme.track,
			Parent = frame11
		}, { UI.corner(UDim.new(1, 0)) })
		local text3 = UI.text({
			Name = "Value",
			Text = "",
			FontFace = Theme.fontHeavy,
			TextSize = p2 and 18 or 20,
			TextColor3 = Color3.new(1, 1, 1),
			Size = UDim2.fromScale(1, 1),
			Parent = frame12
		})

		local icon2 = UI.icon("lock", 16, Theme.textDim, {
			Name = "Lock",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Visible = false,
			Parent = frame12
		})

		local frame13 = UI.new("Frame", {
			Name = "Dots",
			Size = UDim2.fromOffset(30, 8),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundTransparency = 1,
			Parent = frame12
		}, { UI.list(
				Enum.FillDirection.Horizontal,
				5,
				Enum.HorizontalAlignment.Center,
				Enum.VerticalAlignment.Center
			) })
		local frames = {}

		for i = 1, 3 do
			frames[i] = UI.new("Frame", {
				Size = UDim2.fromOffset(6, 6),
				BackgroundColor3 = Theme.text,
				BackgroundTransparency = 0.75,
				LayoutOrder = i,
				Parent = frame13
			}, { UI.corner(UDim.new(1, 0)) })
		end

		return {
			box = frame12,
			value = text3,
			lock = icon2,
			dots = frame13,
			dotList = frames
		}
	end

	local function previewPanel(parent2, reviewPending, layoutOrder, compact)
		local frame10 = UI.new("Frame", {
			Name = "Preview",
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Theme.panelLight,
			LayoutOrder = layoutOrder,
			Parent = parent2
		}, { UI.corner(14), UI.pad(10, 12, 12, 12), UI.list(Enum.FillDirection.Vertical, 6) })
		UI.lift(frame10, 0.12)
		local function caption(text3, layoutOrder2)
			return UI.text({
				Text = text3,
				FontFace = Theme.fontBold,
				TextSize = 13,
				TextColor3 = Theme.textDim,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, 0, 0, 16),
				LayoutOrder = layoutOrder2,
				Parent = frame10
			})
		end

		caption("Accuracy", 1)
		local frame11 = UI.new("Frame", {
			Name = "Players",
			Size = UDim2.new(1, 0, 0, compact and 76 or 82),
			BackgroundTransparency = 1,
			LayoutOrder = 2,
			Parent = frame10
		}, { UI.list(Enum.FillDirection.Horizontal, 8) })
		local myColor = reviewPending.myColor or reviewPending.viewColor or 1
		local v9 = {
			{
				color = myColor,
				t = accuracyTile(frame11, myColor == 1 and reviewPending.white or reviewPending.black, 1, compact)
			},
			{
				color = -myColor,
				t = accuracyTile(frame11, myColor == 1 and reviewPending.black or reviewPending.white, 2, compact)
			}
		}

		local frame12 = UI.new("Frame", {
			Name = "Bar",
			Size = UDim2.new(1, 0, 0, 4),
			BackgroundColor3 = Theme.track,
			LayoutOrder = 3,
			Parent = frame10
		}, { UI.corner(UDim.new(1, 0)) })
		local frame13 = UI.new(
			"Frame",
			{
				Name = "Fill",
				Size = UDim2.fromScale(0, 1),
				BackgroundColor3 = Theme.green,
				Parent = frame12
			},
			{ UI.corner(UDim.new(1, 0)) }
		)
		caption("Your key moments", 4)
		local frame14 = UI.new("Frame", {
			Name = "Moments",
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = 5,
			Parent = frame10
		})

		local list = UI.list(
			Enum.FillDirection.Horizontal,
			6,
			Enum.HorizontalAlignment.Left,
			Enum.VerticalAlignment.Center
		)
		pcall(function()
			list.Wraps = true
		end)
		list.Parent = frame14
		local frame15 = UI.new("Frame", {
			Name = "LockLine",
			Size = UDim2.new(1, 0, 0, 18),
			BackgroundTransparency = 1,
			LayoutOrder = 6,
			Parent = frame10
		}, { UI.list(Enum.FillDirection.Horizontal, 6, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center) })
		UI.icon("lock", 14, Theme.textDim, { LayoutOrder = 1, Parent = frame15 })
		local text3 = UI.text({
			Name = "Text",
			Text = "Finding your best and worst moves...",
			TextSize = 13,
			TextColor3 = Theme.textDim,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Size = UDim2.new(1, -20, 1, 0),
			LayoutOrder = 2,
			Parent = frame15
		})

		local function clearChips()
			for i, guiObject in frame14:GetChildren() do
				if guiObject:IsA("GuiObject") then
					guiObject:Destroy()
				end
			end
		end
		local function hideDots() -- 2 equivalent calls inferred from this helper
			for k, v10 in v9 do
				v10.t.dots.Visible = false
			end
		end

		local v10 = "waiting"
		local v11 = {}

		for k, v12 in { 112, 96, 84 } do
			local frame16 = UI.new("Frame", {
				Name = "Placeholder",
				Size = UDim2.fromOffset(v12, 30),
				BackgroundColor3 = Theme.track,
				BackgroundTransparency = 0.2,
				LayoutOrder = k,
				Parent = frame14
			}, { UI.corner(UDim.new(1, 0)) })
			task.spawn(function()
				task.wait(0.12 * k)

				while frame16.Parent and v10 == "waiting" do
					UI.tween(frame16, 0.5, { BackgroundTransparency = 0.7 }, Enum.EasingStyle.Sine)
					task.wait(0.55)

					if not frame16.Parent then
						break
					end

					UI.tween(frame16, 0.5, { BackgroundTransparency = 0.2 }, Enum.EasingStyle.Sine)
					task.wait(0.55)
				end
			end)
		end

		task.spawn(function()
			local v12 = 0

			while v10 == "waiting" and frame10.Parent do
				v12 = v12 % 3 + 1

				for k, v13 in v9 do
					for k2, dot in v13.t.dotList do
						UI.tween(dot, 0.18, {
							BackgroundTransparency = k2 == v12 and 0 or 0.75
						})
					end
				end

				task.wait(0.3)
			end
		end)

		function v11.progress(value)
			if v10 == "waiting" then
				UI.tween(frame13, 0.2, {
					Size = UDim2.fromScale(math.clamp(value or 0, 0, 1), 1)
				})
			end
		end

		function v11.result(p, p2)
			v10 = "result"
			hideDots() -- inferred equivalent call

			if p2 then
				UI.tween(frame13, 0.15, { Size = UDim2.fromScale(1, 1) })
				task.delay(0.2, function()
					if frame12.Parent then
						UI.tween(frame12, 0.25, { BackgroundTransparency = 1 })
						UI.tween(frame13, 0.25, { BackgroundTransparency = 1 })
					end
				end)
			else
				frame12.BackgroundTransparency = 1
				frame13.BackgroundTransparency = 1
			end

			for k, v12 in v9 do
				local v13 = p.accuracy[v12.color] or 0
				local value = v12.t.value
				v12.t.lock.Visible = false

				if p2 then
					UI.tween(v12.t.box, 0.3, { BackgroundColor3 = accTint(v13) }) -- inferred equivalent call

					local numberValue = Instance.new("NumberValue")
					numberValue.Changed:Connect(function(p3)
						value.Text = string.format("%.1f", p3)
					end)
					value.Text = "0.0"
					UI.tween(numberValue, 0.7, { Value = v13 }, Enum.EasingStyle.Quart).Completed:Connect(function()
						value.Text = string.format("%.1f", v13)
						numberValue:Destroy()
					end)
					UI.pop(v12.t.box, 0.85, 0.22)
				else
					v12.t.box.BackgroundColor3 = accTint(v13) -- inferred equivalent call
					value.Text = string.format("%.1f", v13)
				end
			end

			clearChips()
			local v12 = p.counts and p.counts[myColor] or {}
			local v13 = {}

			for k, v14 in v7 do
				if (v12[v14] or 0) > 0 and #v13 < 3 then
					table.insert(v13, v14)
				end
			end

			local v14 = #v13 > 0

			if not v14 then
				for k, v15 in { "best", "excellent" } do
					if (v12[v15] or 0) > 0 then
						table.insert(v13, v15)
					end
				end
			end

			for k, v15 in v13 do
				local v16 = momentChip(frame14, v15, v12[v15], k)

				if not p2 then
					continue
				end

				v16.Visible = false
				task.delay(0.3 + 0.12 * k, function()
					if v16.Parent then
						UI.reveal(v16, true, 0, 0.22)
					end
				end)
			end

			text3.Text = v14 and "Unlock to see where they happened, with the coach"
				or "Unlock to replay every move with the coach"
		end

		function v11.locked()
			v10 = "locked"
			hideDots() -- inferred equivalent call
			frame12.BackgroundTransparency = 1
			frame13.BackgroundTransparency = 1

			for k, v12 in v9 do
				v12.t.value.Text = ""
				v12.t.box.BackgroundColor3 = Theme.track
				v12.t.lock.Visible = true
			end

			clearChips()

			for k, v12 in { "brilliant", "mistake", "blunder" } do
				momentChip(frame14, v12, nil, k)
			end

			text3.Text = "Unlock to see your accuracy and every move rated"
		end
		return v11
	end

	local function passButton(parent2, layoutOrder, compact, onClick)
		local button2 = UI.button({
			name = "ReviewPass",
			parent = parent2,
			size = UDim2.new(1, 0, 0, 60),
			style = "primary",
			icon = not compact and "analysis" or nil,
			iconSize = 24,
			text = "Infinite Game Breakdown",
			subtext = "Unlimited breakdowns, forever",
			subtextSize = 12,
			textSize = compact and 17 or 18,
			font = Theme.fontHeavy,
			padX = compact and 10 or 14,
			layoutOrder = layoutOrder,
			onClick = onClick
		})

		if button2.sublabel then
			button2.sublabel.TextColor3 = Color3.fromRGB(226, 236, 252)
			button2.sublabel.FontFace = Theme.fontMedium
		end

		local frame10 = UI.new("Frame", {
			Name = "Price",
			Size = UDim2.fromOffset(0, 30),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundColor3 = Theme.greenShadow,
			LayoutOrder = 3,
			Parent = button2.content
		}, { UI.corner(UDim.new(1, 0)), UI.pad(0, 10, 0, 10) })
		local text3 = UI.text({
			Name = "Label",
			Text = v5 .. " " .. tostring(priceInRobux or Config.REVIEW_PASS_ROBUX),
			FontFace = Theme.fontHeavy,
			TextSize = 16,
			Size = UDim2.fromScale(0, 1),
			AutomaticSize = Enum.AutomaticSize.X,
			Parent = frame10
		})

		button2.face.ClipsDescendants = true
		local frame11 = UI.new("Frame", {
			Name = "Shine",
			Size = UDim2.new(0, 36, 2, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0, -40, 0.5, 0),
			Rotation = 18,
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 0.8,
			ZIndex = 0,
			Parent = button2.face
		})

		local uiGradient = Instance.new("UIGradient")
		uiGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.5, 0.15),
			NumberSequenceKeypoint.new(1, 1)
		})

		uiGradient.Parent = frame11
		task.spawn(function()
			task.wait(1.2)

			while frame11.Parent do
				frame11.Position = UDim2.new(0, -40, 0.5, 0)
				UI.tween(
					frame11,
					0.7,
					{ Position = UDim2.new(1, 40, 0.5, 0) },
					Enum.EasingStyle.Quad,
					Enum.EasingDirection.InOut
				)
				task.wait(3.6)
			end
		end)
		return button2, text3
	end

	function Review.showLocked(reviewPending, options)
		local v9 = options or {}
		local v10 = v6[v9.card] and v9.card or "preview"

		if v10 == "classic" then
			showLockedClassic(reviewPending, v9)
			cardEvent("shown", v10) -- inferred equivalent call
		else
			local modals = self.modals
			self.reviewPending = reviewPending
			local v11

			if v10 == "preview" then
				v11 = reviewPending.reviewJob

				if not v11 or v11.failed then
					if count < (Config.REVIEW_PREVIEWS_PER_SESSION or 1e999) then
						count += 1
						v11 = reviewJob(reviewPending)
					else
						v10 = "static"
						v11 = nil
					end
				end
			else
				v11 = nil
			end

			local compact = self.compact == true
			local parent2, v12 = modals.openModal("ReviewLocked", compact and 620 or 372, {
				fitWidth = true
			})
			modals.closeButton(parent2, "ReviewLocked")
			local uiCorner = v12.card:FindFirstChildOfClass("UICorner")

			if uiCorner then
				uiCorner.CornerRadius = UDim.new(0, 14)
			end

			cardEvent("shown", v10) -- inferred equivalent call
			trackClose(v12.card, reviewPending, v10) -- inferred equivalent call
			local v13

			if compact then
				local padded = UI.pad(14, 16, 14, 16)
				padded.Parent = parent2
				local list = UI.list(
					Enum.FillDirection.Horizontal,
					16,
					Enum.HorizontalAlignment.Left,
					Enum.VerticalAlignment.Center
				)
				list.Parent = parent2
				v13 = UI.new("Frame", {
					Name = "Left",
					Size = UDim2.new(0.55, -8, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					LayoutOrder = 1,
					Parent = parent2
				}, { UI.list(Enum.FillDirection.Vertical, 8) })
				parent2 = UI.new("Frame", {
					Name = "Right",
					Size = UDim2.new(0.45, -8, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					LayoutOrder = 2,
					Parent = parent2
				}, { UI.list(Enum.FillDirection.Vertical, 10) })
			else
				local padded = UI.pad(16, 18, 18, 18)
				padded.Parent = parent2
				local list = UI.list(Enum.FillDirection.Vertical, 12)
				list.Parent = parent2
				v13 = parent2
			end

			local count2 = 0
			local function nextOrder() -- 6 equivalent calls inferred from this helper
				count2 += 1
				return count2
			end

			local frame10 = UI.new("Frame", {
				Name = "Head",
				Size = UDim2.new(1, -36, 0, 18),
				BackgroundTransparency = 1,
				LayoutOrder = nextOrder(), -- inferred equivalent call
				Parent = parent2
			}, { UI.list(
					Enum.FillDirection.Horizontal,
					6,
					Enum.HorizontalAlignment.Left,
					Enum.VerticalAlignment.Center
				) })
			UI.icon("analysis", 18, Theme.blueSoft or Theme.green, {
				LayoutOrder = 1,
				Parent = frame10
			})
			UI.text({
				Text = "GAME BREAKDOWN",
				FontFace = Theme.fontHeavy,
				TextSize = 13,
				TextColor3 = Theme.blueSoft or Theme.green,
				AutomaticSize = Enum.AutomaticSize.X,
				Size = UDim2.fromScale(0, 1),
				LayoutOrder = 2,
				Parent = frame10
			})

			local frame11 = UI.new("Frame", {
				Name = "TitleBlock",
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				LayoutOrder = nextOrder(), -- inferred equivalent call
				Parent = parent2
			}, { UI.list(Enum.FillDirection.Vertical, 3) })
			local text3 = UI.text({
				Name = "Title",
				Text = "",
				FontFace = Theme.fontHeavy,
				TextSize = compact and 22 or 24,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextWrapped = true,
				Size = UDim2.new(1, compact and 0 or -24, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				LayoutOrder = 1,
				Parent = frame11
			})

			if not compact then
				UI.text({
					Name = "Sub",
					Text = "Every move rated, with the coach explaining why.",
					TextSize = 14,
					TextColor3 = Theme.textSoft,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextWrapped = true,
					Size = UDim2.new(1, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					LayoutOrder = 2,
					Parent = frame11
				})
			end

			local v14

			if compact then
				v14 = 1
			else
				v14 = nextOrder() -- inferred equivalent call
			end

			local v15 = previewPanel(v13, reviewPending, v14, compact)

			local v16, v17 = passButton(parent2, nextOrder(), compact, function() -- inferred equivalent call
				cardEvent("pass", v10) -- inferred equivalent call

				if not pcall(function()
					MarketplaceService:PromptGamePassPurchase(Players.LocalPlayer, Config.REVIEW_PASS)
				end) then
					self.toast("Couldn't open the purchase. Try again in a moment.", Theme.loss)
				end
			end)

			if not priceInRobux then
				task.spawn(function()
					local success, productInfoAsync = pcall(
						MarketplaceService.GetProductInfoAsync,
						MarketplaceService,
						Config.REVIEW_PASS,
						Enum.InfoType.GamePass
					)

					if success and productInfoAsync and tonumber(productInfoAsync.PriceInRobux) then
						priceInRobux = productInfoAsync.PriceInRobux

						if v17.Parent then
							v17.Text = v5 .. " " .. tostring(priceInRobux)
						end
					end
				end)
			end

			local faces = { v16.face }

			if v9.ad then
				local v18 = nil
				local function adState(p)
					if not (v18 and v18.holder.Parent) then
						return
					end

					if p == "ready" then
						v18:setText("Watch a short ad")
						v18:setSubtext("Free: unlocks this breakdown")
						v18:setEnabled(true)
					else
						if p == "loading" then
							v18:setText("Loading ad...")
						elseif p == "unlocking" then
							v18:setText("Unlocking breakdown...")
						else
							v18:setText("No ad right now")
							v18:setSubtext("Try again later")
						end

						v18:setEnabled(false)
					end
				end
				v18 = UI.button({
					name = "ReviewAd",
					parent = parent2,
					size = UDim2.new(1, 0, 0, 52),
					style = "secondary",
					icon = "play",
					text = "Checking for an ad...",
					subtext = "Free: unlocks this breakdown",
					subtextSize = 12,
					textSize = 16,
					layoutOrder = nextOrder(), -- inferred equivalent call
					onClick = function()
						if flag then
							return
						end

						flag = true
						cardEvent("ad", v10) -- inferred equivalent call

						if v18 and v18.holder.Parent then
							v18:setText("Loading ad...")
							v18:setEnabled(false)
						end

						task.spawn(function()
							local request = self.request({ type = "reviewAd" })
							flag = false
							local result = request and request.result

							if result == "ShowCompleted" then
								if v18 and v18.holder.Parent then
									v18:setText("Unlocking breakdown...")
									v18:setEnabled(false)
								end

								task.delay(20, function()
									if self.reviewPending == reviewPending and v18.holder.Parent then
										if v18 and v18.holder.Parent then
											v18:setText("Watch a short ad")
											v18:setSubtext("Free: unlocks this breakdown")
											v18:setEnabled(true)
										end

										self.toast("Your breakdown will unlock as soon as Roblox sends the reward.")
									end
								end)
							elseif result == "ShowInterrupted" then
								if v18 and v18.holder.Parent then
									v18:setText("Watch a short ad")
									v18:setSubtext("Free: unlocks this breakdown")
									v18:setEnabled(true)
								end

								self.toast("The ad was closed early, so it didn't unlock a breakdown.", Theme.loss)
							else
								if v18 and v18.holder.Parent then
									v18:setText("No ad right now")
									v18:setSubtext("Try again later")
									v18:setEnabled(false)
								end

								self.toast("No ad available right now. Try again later.", Theme.loss)
							end
						end)
					end
				})

				v18:setEnabled(false)
				table.insert(faces, v18.face)

				task.spawn(function()
					local success, adAvailabilityNowAsync = pcall(
						AdService.GetAdAvailabilityNowAsync,
						AdService,
						Enum.AdFormat.RewardedVideo
					)

					if
						success
						and adAvailabilityNowAsync
						and adAvailabilityNowAsync.AdAvailabilityResult == Enum.AdAvailabilityResult.IsAvailable
					then
						if v18 then
							if not v18.holder.Parent then
								return
							end

							v18:setText("Watch a short ad")
							v18:setSubtext("Free: unlocks this breakdown")
							v18:setEnabled(true)
						end
					else
						cardEvent("noAd", v10) -- inferred equivalent call

						if v18.holder.Parent then
							v18:setVisible(false)
						end
					end
				end)
			end

			if tonumber(v9.resetAt) then
				UI.text({
					Name = "Footer",
					Text = "You've used today's free breakdown. Next one in " .. waitText(v9.resetAt - self.serverNow()) .. ".", -- inferred equivalent call
					TextSize = 12,
					TextColor3 = Theme.textMuted,
					TextWrapped = true,
					TextXAlignment = compact and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center,
					Size = UDim2.new(1, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					LayoutOrder = nextOrder(), -- inferred equivalent call
					Parent = parent2
				})
			end

			for k, parent3 in faces do
				local popScale = Instance.new("UIScale")
				popScale.Name = "PopScale"
				popScale.Scale = 0.01
				popScale.Parent = parent3
				task.delay(0.15 + 0.08 * (k - 1), function()
					if parent3.Parent then
						UI.pop(parent3, 0.6, 0.28)
					end
				end)
			end

			local function setTitle(text4, p) -- 4 equivalent calls inferred from this helper
				text3.Text = text4

				if p then
					UI.textIn(text3, 0.25)
				end
			end

			if v11 then
				if v11.done and v11.result then
					setTitle("Your breakdown is ready") -- inferred equivalent call
					v15.result(v11.result, false)
				elseif v11.done then
					setTitle("Unlock this breakdown") -- inferred equivalent call
					v15.locked()
				else
					setTitle("Breaking down your game...") -- inferred equivalent call
					v15.progress(v11.progress)
					local v18 = nil
					v18 = v11.on(function(p, p2)
						if not v12.card.Parent then
							v18()
							return
						end

						if p == "progress" then
							v15.progress(p2)
							return
						end

						v18()

						if v11.result then
							text3.Text = "Your breakdown is ready"

							UI.textIn(text3, 0.25)

							v15.result(v11.result, true)
							Sound.play("step")
							cardEvent("ready", v10) -- inferred equivalent call
						else
							text3.Text = "Unlock this breakdown"

							UI.textIn(text3, 0.25)

							v15.locked()
						end
					end)
				end
			else
				setTitle("Unlock this breakdown") -- inferred equivalent call
				v15.locked()
			end
		end
	end

	function self.handlers.reviewUnlocked(p)
		Sound.play("unlock")
		local reviewPending = self.reviewPending
		self.reviewPending = nil

		if self.modals.isOpen("ReviewLocked") then
			self.modals.close("ReviewLocked")
		end

		if not reviewPending or self.session ~= reviewPending or not reviewPending.over or reviewPending.review then
			self.toast(
				p.pass and "Infinite Game Breakdown unlocked!" or "You have a Game Breakdown saved for your next game.",
				Theme.green
			)

			return
		end

		self.toast(p.pass and "Infinite Game Breakdown unlocked!" or "Game Breakdown unlocked!", Theme.green)
		self.startReview()
	end

	function self.startReview()
		local session = self.session

		if not session or not session.over or #session.ucis < 2 then
			self.toast("Play a few moves first!")
			return
		end

		self.modals.closeAll()

		if session.review then
			pages.show("review")
			return
		end

		if self.reviewChecking then
			return
		end

		if not session.reviewKey then
			local reviewKey = session.id or session.historyEntry and session.historyEntry.id

			if not reviewKey then
				local HttpService = game:GetService("HttpService")
				reviewKey = HttpService:GenerateGUID(false)
			end

			session.reviewKey = reviewKey
		end

		self.reviewChecking = true
		local request = self.request({ type = "reviewStart", id = session.reviewKey })
		self.reviewChecking = false

		if self.session ~= session then
			return
		end

		if request and request.ok == false and request.locked then
			Review.showLocked(session, request)
			return
		end

		self.reviewPending = nil
		local reviewFree

		if request and request.how == "free" and (tonumber(request.free) or 0) == 0 then
			reviewFree = tonumber(request.resetAt) or nil
		end

		session.reviewFree = reviewFree

		local v9 = reviewJob(session)
		local function finish()
			session.review = v9.result
			self.send({ type = "fx", ev = "reviewDone" })
			Review.applyBadges(session)
			review2.refresh()
			self.render({ animate = false })
		end

		if v9.done and v9.result then
			session.review = v9.result
			pages.show("review")
			finish()
		else
			local review = { done = false, progress = v9.progress }
			session.review = review
			pages.show("review")
			local v10 = nil
			v10 = v9.on(function(p, progress)
				if session.review ~= review then
					v10()
				elseif p == "progress" then
					review.progress = progress

					if pages.current == "review" then
						review2.refresh()
					end
				else
					v10()

					if v9.result then
						finish()
						return
					end

					session.review = nil

					if v9.failed == "error" and self.session == session then
						self.toast("Game Breakdown hit a problem. Tap Game Breakdown to try again.", Theme.loss)
						pages.show("game")
					end
				end
			end)
		end
	end

	local onRender = self.onRender
	function self.onRender(p)
		if onRender then
			onRender(p)
		end

		Review.onRender(p)
	end

	local onFrame = pages.onFrame
	function pages.onFrame()
		onFrame()
		review2.onFrame()
	end
end

return Review