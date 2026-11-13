local parent = script.Parent
local Theme = require(parent.Theme)
local UI = require(parent.UI)
local TextService = game:GetService("TextService")

local v = {
	home = "play",
	game = "play",
	players = "play",
	puzzles = "puzzles",
	rush = "puzzles",
	bots = "play",
	analysis = "analysis",
	review = "analysis",
	leaderboard = "leaderboard",
	stats = "stats",
	history = "play",
	donate = "donate",
	donors = "donate",
	tasks = "play",
	shop = "shop",
	codes = "shop",
	gift = "shop",
	inventory = "inventory",
	watch = "watch",
	tournament = "tournament",
	learn = "learn",
	course = "learn",
	lesson = "learn",
	basics = "learn"
}
return {
	build = function(data)
		local v2 = { width = 0, height = 0, iconsOnly = false }

		local function busyToast() -- 2 equivalent calls inferred from this helper
			data.toast("Finish your game first")
		end

		local v3 = {
			{
				id = "play",
				label = "Play",
				icon = "pawn",
				action = function()
					if data.inLiveGame() then
						data.pages.show("game")
					else
						data.goHome()
					end
				end
			},
			{
				id = "watch",
				label = "Watch",
				icon = "eye",
				busy = true,
				action = function()
					data.pages.show("watch")
				end
			},
			{
				id = "shop",
				label = "Shop",
				icon = "crate",
				action = function()
					data.pages.show("shop")
				end
			},
			{
				id = "inventory",
				label = "Inventory",
				icon = "tophat",
				action = function()
					data.pages.inventory.show(data.pages.inventory.kind or "board")
				end
			},
			{
				id = "puzzles",
				label = "Puzzles",
				icon = "puzzle",
				busy = true,
				action = function()
					data.openPuzzles()
				end
			},
			{
				id = "learn",
				label = "Learn",
				icon = "school",
				busy = true,
				action = function()
					if data.openLearn then
						data.openLearn()
					else
						data.openTutorial()
					end
				end
			},
			{
				id = "analysis",
				label = "Analysis",
				icon = "analysis",
				busy = true,
				action = function()
					data.openAnalysis(nil, {}, 0)
				end
			},
			{
				id = "leaderboard",
				label = "Rankings",
				icon = "trophy",
				action = function()
					data.pages.show("leaderboard")
				end
			},
			{
				id = "stats",
				label = "Profile",
				icon = "person",
				action = function()
					data.pages.show("stats")
				end
			}
		}

		local ReplicatedStorage = game:GetService("ReplicatedStorage")

		if require(ReplicatedStorage.Chess.Config).TOURNAMENTS_ENABLED then
			table.insert(v3, 3, {
				id = "tournament",
				label = "Tournament",
				icon = "crown",
				action = function()
					data.pages.show("tournament")
				end
			})
		end

		local RunService = game:GetService("RunService")
		local Players = game:GetService("Players")
		local localPlayer = Players.LocalPlayer
		local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
		local Admins = require(ReplicatedStorage2.Chess:WaitForChild("Admins"))

		if Admins[localPlayer.UserId] == true or RunService:IsStudio() and localPlayer.UserId <= 0 then
			table.insert(v3, {
				id = "admin",
				label = "Admin",
				icon = "settings",
				action = function()
					if data.Admin and data.Admin.toggle then
						data.Admin.toggle()
					end
				end
			})
		end

		local frame = UI.new("Frame", {
			Name = "Nav",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 48),
			ZIndex = 2,
			Parent = data.root
		})

		v2.frame = frame

		local textButton = UI.new("TextButton", {
			Name = "Logo",
			Text = "",
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(170, 48),
			ZIndex = 3,
			Parent = frame
		})

		local frame2 = UI.new("Frame", {
			Name = "Badge",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.fromOffset(38, 38),
			BackgroundColor3 = Color3.new(1, 1, 1),
			ZIndex = 3,
			Parent = textButton
		}, { UI.corner(UDim.new(0.3, 0)), UI.stroke(Theme.selEdge, 1, 0.55) })
		local uiGradient = Instance.new("UIGradient")
		uiGradient.Rotation = 45
		uiGradient.Color = ColorSequence.new(Color3.fromRGB(40, 54, 82), Color3.fromRGB(24, 32, 50))
		uiGradient.Parent = frame2
		UI.icon("rook", 26, Theme.selIcon, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			ZIndex = 4,
			Parent = frame2
		})

		local hex = (Theme.coral or Theme.green):ToHex()
		local text = UI.text({
			Text = "RoChess<font color=\"#" .. hex .. "\">!</font>",
			RichText = true,
			FontFace = Theme.fontLogo or Theme.fontHeavy,
			TextSize = 24,
			TextColor3 = Theme.text,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(48, 0),
			Size = UDim2.new(1, -48, 1, 0),
			ZIndex = 3,
			Parent = textButton
		})

		textButton.Activated:Connect(function()
			v3[1].action()
		end)

		local frame3 = UI.new("Frame", {
			Name = "Dock",
			BackgroundColor3 = Theme.paneTop,
			BackgroundTransparency = Theme.glass or 0.12,
			Size = UDim2.fromOffset(400, 48),
			ZIndex = 3,
			Parent = frame
		}, {
			UI.corner(UDim.new(1, 0)),
			UI.pad(5, 5, 5, 5),
			UI.list(Enum.FillDirection.Horizontal, 4, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)
		})

		UI.depth(frame3)

		local function makePill(data2, k)
			local textButton2 = UI.new("TextButton", {
				Name = data2.id,
				Text = "",
				BackgroundColor3 = Theme.coral or Theme.green,
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(60, 38),
				LayoutOrder = k,
				ZIndex = 4,
				Parent = frame3
			}, { UI.corner(UDim.new(1, 0)) })
			local icon = UI.icon(data2.icon, 21, Theme.textDim, {
				Name = "Icon",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				ZIndex = 5,
				Parent = textButton2
			})

			local text2 = UI.text({
				Name = "Label",
				Text = data2.label,
				FontFace = Theme.fontBold,
				TextSize = 16,
				TextColor3 = Theme.textDim,
				Size = UDim2.fromScale(1, 1),
				ZIndex = 5,
				Parent = textButton2
			})

			local pill = {
				button = textButton2,
				icon = icon,
				label = text2,
				active = false,
				labelW = math.ceil(TextService:GetTextSize(
					data2.label,
					16,
					Enum.Font.BuilderSansBold,
					Vector2.new(1000, 100)
				).X) + 28
			}
			textButton2.MouseEnter:Connect(function()
				if not pill.active then
					UI.tween(textButton2, UI.FAST, {
						BackgroundTransparency = 0,
						BackgroundColor3 = Theme.navHover
					})
				end

				UI.tween(text2, UI.FAST, { TextColor3 = Theme.text })
				UI.tween(icon, UI.FAST, { ImageColor3 = Theme.text })
			end)
			textButton2.MouseLeave:Connect(function()
				v2.paint(pill)
			end)
			textButton2.Activated:Connect(function()
				if data2.busy and data.inLiveGame() then
					busyToast() -- inferred equivalent call
				else
					data2.action()
				end
			end)
			return pill
		end

		local v4 = {}

		for k, v5 in v3 do
			v4[v5.id] = makePill(v5, k)
		end

		function v2.paint(data2)
			if not Theme.coral then
				local _green = Theme.green
			end

			UI.tween(data2.button, UI.SNAP, {
				BackgroundTransparency = data2.active and 0 or 1,
				BackgroundColor3 = data2.active and Theme.selBg or Theme.navHover
			})

			UI.selected(data2.button, data2.active)
			local selText = data2.active and Theme.selText or Theme.textDim
			UI.tween(data2.label, UI.SNAP, { TextColor3 = selText })
			UI.tween(data2.icon, UI.SNAP, { ImageColor3 = selText })
			UI.ink(data2.label, data2.active)
		end

		local frame4 = UI.new("Frame", {
			Name = "Right",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0),
			Size = UDim2.fromOffset(96, 48),
			ZIndex = 3,
			Parent = frame
		}, { UI.list(Enum.FillDirection.Horizontal, 8, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center) })
		local function round(name, p, p2, layoutOrder, onActivated)
			local textButton2 = UI.new("TextButton", {
				Name = name,
				Text = "",
				BackgroundColor3 = Theme.nav,
				Size = UDim2.fromOffset(44, 44),
				LayoutOrder = layoutOrder,
				ZIndex = 4,
				Parent = frame4
			}, { UI.corner(UDim.new(1, 0)) })
			local icon = UI.icon(p, 20, p2, {
				Name = "Icon",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				ZIndex = 5,
				Parent = textButton2
			})

			textButton2.MouseEnter:Connect(function()
				UI.tween(textButton2, UI.FAST, { BackgroundColor3 = Theme.navHover })
			end)
			textButton2.MouseLeave:Connect(function()
				UI.tween(textButton2, UI.SNAP, { BackgroundColor3 = Theme.nav })
			end)
			textButton2.Activated:Connect(onActivated)
			return { button = textButton2, icon = icon }
		end

		local v5 = round("Donate", "heart", Theme.donate, 1, function()
			data.pages.show("donate")
		end)
		round("Settings", "settings", Theme.textDim, 2, function()
			data.modals.settings()
		end)

		function v2.press(p): boolean
			if p == "logo" then
				v3[1].action()
				return true
			elseif p == "donate" then
				data.pages.show("donate")
				return true
			end

			for _, v6 in v3 do
				if v6.id == p then
					if v6.busy and data.inLiveGame() then
						busyToast() -- inferred equivalent call
					else
						v6.action()
					end

					return true
				end
			end

			return false
		end

		function v2.layout(p, width)
			local topbar = data.topbar or { inset = 0, left = 0, right = width }

			if p and not (width < 760) then
				frame.Visible = true
				local inset = topbar.inset or 0
				local v6, v7, v8

				if inset > 0 then
					v6 = math.max(12, (math.min(topbar.left or 12, width))) + 4
					v7 = math.min(width, topbar.right or width) - 12
					v8 = math.max(4, (math.floor((inset - 48) / 2)))
				else
					v7 = width - 16
					v8 = 10
					v6 = 16
				end

				frame.Position = UDim2.fromOffset(0, v8)
				frame.Size = UDim2.new(1, 0, 0, 48)
				textButton.Position = UDim2.fromOffset(v6, 0)
				frame4.Position = UDim2.fromOffset(v7, 0)

				local count = #v3
				local v9 = (count - 1) * 4 + 10
				local v10 = (count - 1) * 4 + 10 + count * 38

				for _, v11 in v3 do
					v9 += v4[v11.id].labelW
				end

				local function room(p2) -- 2 equivalent calls inferred from this helper
					return v7 - 96 - 16 - (v6 + p2 + 16)
				end

				local visible = true
				local v11

				if room(170) < v9 then -- inferred equivalent call
					v11 = true

					if room(170) < v10 then -- inferred equivalent call
						visible = false
					end
				else
					v11 = false
				end

				v2.iconsOnly = v11
				text.Visible = visible
				local v12 = visible and 170 or 38
				textButton.Size = UDim2.fromOffset(v12, 48)

				for _, v13 in v3 do
					local v14 = v4[v13.id]
					v14.label.Visible = not v11
					v14.icon.Visible = v11
					v14.button.Size = UDim2.fromOffset(v11 and 38 or v14.labelW, 38)
				end

				v9 = v11 and v10 or v9
				local v13 = math.clamp(
					math.floor((width - v9) / 2),
					v6 + v12 + 16,
					(math.max(v6 + v12 + 16, v7 - 96 - 16 - v9))
				)
				frame3.Position = UDim2.fromOffset(v13, 0)
				frame3.Size = UDim2.fromOffset(v9, 48)
				v2.width = width
				v2.height = 48
				return v8 + 48
			end

			frame.Visible = false
			v2.width = 0
			v2.height = 0
			return 0
		end

		function v2.setBadge(p, p2)
			local v6 = p == "tasks" and "play" or p

			local v7 = v4[v6]
			local button = v7 and v7.button

			if not button then
				if v6 == "donate" then
					button = v5.button or nil
				else
					button = nil
				end
			end

			if not button then
				return
			end

			local badge = button:FindFirstChild("Badge")

			if p2 and not badge then
				local frame5 = UI.new("Frame", {
					Name = "Badge",
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(1, -4, 0, 4),
					Size = UDim2.fromOffset(10, 10),
					BackgroundColor3 = Theme.red,
					ZIndex = 6,
					Parent = button
				}, { UI.corner(UDim.new(1, 0)), UI.stroke(Theme.nav, 2) })
				UI.pop(frame5, 0.3, 0.3)
			elseif not p2 and badge then
				badge:Destroy()
			end
		end

		function v2.refresh()
			local current = data.pages and data.pages.current or "home"
			local v6 = v[current]

			if not v6 and data.pages and data.pages.backTo and data.pages.backTo[current] then
				v6 = v[data.pages.backTo[current]]
			end

			for k, v7 in v4 do
				v7.active = k == v6
				v2.paint(v7)
			end
		end

		return v2
	end
}