local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Chess = ReplicatedStorage:WaitForChild("Chess")
local Config = require(Chess.Config)
local Cosmetics = require(Chess.Cosmetics)
local Admins = require(Chess:WaitForChild("Admins"))
local parent = script.Parent
local Theme = require(parent.Theme)
local UI = require(parent.UI)
local Sound = require(parent.Sound)

local Admin = {}

local Left = Enum.TextXAlignment.Left
local Top = Enum.TextYAlignment.Top
local Horizontal = Enum.FillDirection.Horizontal
local Vertical = Enum.FillDirection.Vertical
local Center = Enum.VerticalAlignment.Center
local color = Color3.fromRGB(232, 92, 62)
local blueSoft = Theme.blueSoft

function Admin.isAdmin(p)
	local v = p or Players.LocalPlayer
	return Admins[v.UserId] == true or RunService:IsStudio() and v.UserId <= 0
end

local function esc(p) -- 12 equivalent calls inferred from this helper
	return (string.gsub(string.gsub(string.gsub(tostring(p), "&", "&amp;"), "<", "&lt;"), ">", "&gt;"))
end

local function hex(data) -- 2 equivalent calls inferred from this helper
	return string.format(
		"#%02X%02X%02X",
		math.floor(data.R * 255),
		math.floor(data.G * 255),
		(math.floor(data.B * 255))
	)
end

local function color2(p, data) -- 20 equivalent calls inferred from this helper
	return string.format("<font color=\"%s\">%s</font>", hex(data), p) -- inferred equivalent call
end

local function ago(value)
	if type(value) ~= "number" or value <= 0 then
		return "never"
	end

	local v = os.time() - value

	if v < 90 then
		return "just now"
	end

	if v < 5400 then
		return math.floor(v / 60) .. " min ago"
	end

	if v < 172800 then
		return math.floor(v / 3600) .. " h ago"
	end

	return math.floor(v / 86400) .. " days ago"
end

local function num(p)
	local v = math.floor(tonumber(p) or 0)
	local v2 = tostring((math.abs(v)))
	local v3 = string.reverse((string.gsub(string.reverse(v2), "(%d%d%d)", "%1,")))
	local v4 = string.gsub(v3, "^,", "")
	return (v < 0 and "-" or "") .. v4
end

local function installAnnounce(app) -- 1 equivalent call inferred from this helper
	local v = nil
	function app.handlers.announce(data)
		if type(data.text) ~= "string" then
			return
		end

		if v then
			v:Destroy()
		end

		local x = app.gui.AbsoluteSize.X
		local inset = app.topbar and app.topbar.inset or 0
		local frame = UI.new("Frame", {
			Name = "Announcement",
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, inset + 10),
			Size = UDim2.new(0, math.min(560, x - 32), 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Theme.panelHeader,
			ZIndex = 40,
			Parent = app.gui
		}, { UI.corner(10), UI.pad(12, 16, 12, 16), UI.list(Horizontal, 12, nil, Center) })
		local stroke = UI.stroke(data.restart and color or Theme.gold, 2, 0)
		stroke.Parent = frame

		local by = tonumber(data.by)
		local byName

		if type(data.byName) == "string" and data.byName ~= "" then
			byName = data.byName or nil
		end

		local v2

		if by == nil or not (by > 0) then
			v2 = false
		else
			v2 = not data.restart
		end

		local v3 = 26

		if v2 then
			v3 = 40
			local imageLabel = UI.new("ImageLabel", {
				Name = "Sender",
				Image = string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150", by),
				Size = UDim2.fromOffset(v3, v3),
				BackgroundColor3 = Theme.panelLight,
				LayoutOrder = 1,
				ZIndex = 41,
				Parent = frame
			}, { UI.corner(UDim.new(0.5, 0)) })
			local stroke_2 = UI.stroke(Theme.gold, 1.5, 0)
			stroke_2.Parent = imageLabel
		else
			UI.icon(data.restart and "bolt" or "trophy", 26, data.restart and color or Theme.gold, {
				LayoutOrder = 1,
				Parent = frame
			})
		end

		local frame2 = UI.new("Frame", {
			Name = "Body",
			Size = UDim2.new(1, -(v3 + 14), 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = 2,
			Parent = frame
		}, { UI.list(Vertical, 2) })

		if v2 and byName then
			UI.text({
				Name = "From",
				Text = "@" .. byName,
				FontFace = Theme.fontBold,
				TextSize = 14,
				TextColor3 = Theme.gold,
				TextXAlignment = Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Size = UDim2.new(1, 0, 0, 16),
				LayoutOrder = 1,
				Parent = frame2
			})
		end

		local text = UI.text({
			Name = "Text",
			Text = data.text,
			FontFace = Theme.fontBold,
			TextSize = 17,
			TextWrapped = true,
			TextXAlignment = Left,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = 2,
			Parent = frame2
		})

		v = frame

		local v4 = false
		local function close()
			if v4 or not frame.Parent then
				return
			end

			v4 = true
			UI.fadeOut(frame, 0.2, -6, function()
				frame:Destroy()
			end)
		end
		frame.Active = true
		frame.InputBegan:Connect(function(input)
			local userInputType = input.UserInputType

			if
				(userInputType == Enum.UserInputType.MouseButton1 or userInputType == Enum.UserInputType.Touch)
				and not v4
			then
				if not frame.Parent then
					return
				end

				v4 = true
				UI.fadeOut(frame, 0.2, -6, function()
					frame:Destroy()
				end)
			end
		end)
		Sound.play("toast")
		UI.pop(frame, 0.85, 0.25)
		local restart = tonumber(data.restart)
		local v5 = os.clock() + math.clamp(tonumber(data.duration) or 8, 3, 60)
		task.spawn(function()
			while frame.Parent and not v4 do
				if restart then
					local v6 = math.max(0, restart - math.floor((workspace:GetServerTimeNow())))
					text.Text = data.text .. (v6 > 0 and string.format("  (%ds)", v6) or "")

					if v6 <= 0 and v5 < os.clock() then
						break
					end
				elseif v5 < os.clock() then
					break
				end

				task.wait(0.25)
			end

			if not v4 then
				if not frame.Parent then
					return
				end

				v4 = true
				UI.fadeOut(frame, 0.2, -6, function()
					frame:Destroy()
				end)
			end
		end)
	end
end

function Admin.install(app)
	Admin.App = app
	installAnnounce(app) -- inferred equivalent call

	if not Admin.isAdmin() then
		return
	end

	local function call(op, options)
		local v = options or {}
		v.type = "admin"
		v.op = op
		local request = app.request(v)

		if type(request) == "table" then
			return request
		end

		return { ok = false, reason = "No answer from the server." }
	end

	local function toast(p, ok) -- 12 equivalent calls inferred from this helper
		app.toast(p, ok == false and Theme.loss or ok and Theme.green or nil, 3)
	end

	local function card(scroll, text, value, p)
		local frame = UI.new("Frame", {
			Name = text or "Card",
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Theme.panelLight,
			LayoutOrder = value or 0,
			Parent = scroll
		}, { UI.corner(8), UI.pad(12, 12, 12, 12), UI.list(Vertical, 8) })

		if text then
			UI.text({
				Name = "Title",
				Text = text,
				FontFace = Theme.fontBold,
				TextSize = 16,
				TextColor3 = p or Theme.text,
				TextXAlignment = Left,
				Size = UDim2.new(1, 0, 0, 20),
				LayoutOrder = 0,
				Parent = frame
			})
		end

		return frame
	end

	local function row(parent2, value, value2)
		return UI.new("Frame", {
			Name = "Row",
			Size = UDim2.new(1, 0, 0, value2 or 38),
			BackgroundTransparency = 1,
			LayoutOrder = value or 0,
			Parent = parent2
		}, { UI.list(Horizontal, 8, nil, Center) })
	end

	local function wrapRow(parent2, value)
		local frame = UI.new("Frame", {
			Name = "Buttons",
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = value or 0,
			Parent = parent2
		})

		local list = UI.list(Horizontal, 8, nil, Center)
		list.Wraps = true
		list.Parent = frame
		return frame
	end

	local function label(parent2, text, value, value2, p)
		return UI.text({
			Name = "Label",
			Text = text,
			RichText = true,
			FontFace = Theme.fontMedium,
			TextSize = value2 or 14,
			TextColor3 = p or Theme.textDim,
			TextWrapped = true,
			TextXAlignment = Left,
			TextYAlignment = Top,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = value or 0,
			Parent = parent2
		})
	end

	local function input(parent2, value, udim, value2)
		local frame = UI.new("Frame", {
			Name = "Input",
			Size = udim or UDim2.new(0, 120, 0, 34),
			BackgroundColor3 = Theme.panelHeader,
			LayoutOrder = value2 or 0,
			Parent = parent2
		}, { UI.corner(6) })
		local stroke = UI.stroke(Theme.divider, 1, 0)
		stroke.Parent = frame
		local textBox = UI.new("TextBox", {
			Name = "Box",
			Text = "",
			PlaceholderText = value or "",
			PlaceholderColor3 = Theme.textMuted,
			ClearTextOnFocus = false,
			FontFace = Theme.fontMedium,
			TextSize = 15,
			TextColor3 = Theme.text,
			TextXAlignment = Left,
			ClipsDescendants = true,
			Size = UDim2.new(1, -16, 1, 0),
			Position = UDim2.fromOffset(8, 0),
			Parent = frame
		})

		textBox.Focused:Connect(function()
			UI.tween(stroke, UI.FAST, { Color = blueSoft })
		end)
		textBox.FocusLost:Connect(function()
			UI.tween(stroke, UI.SNAP, { Color = Theme.divider })
		end)
		return textBox, frame
	end

	local function btn(parent2, p, value, value2, value3, callback, p2)
		local v = nil
		local lastTime = 0
		v = UI.button({
			parent = parent2,
			name = p,
			text = p,
			size = UDim2.fromOffset(value or 110, 36),
			style = value2 or "secondary",
			textSize = 14,
			padX = 6,
			layoutOrder = value3 or 0,
			onClick = function()
				if v.busy then
					return
				end

				if p2 then
					if os.clock() - lastTime > 3 then
						lastTime = os.clock()
						v:setText("Sure?")
						task.delay(3, function()
							if os.clock() - lastTime >= 2.95 then
								v:setText(p)
							end
						end)
						return
					end

					lastTime = 0
					v:setText(p)
				end

				v.busy = true
				v:setEnabled(false)
				task.spawn(function()
					local success, result = pcall(callback)

					if not success then
						warn("[Admin] " .. tostring(result))
						toast(tostring(result), false) -- inferred equivalent call
					end

					v.busy = false

					if v.holder.Parent then
						v:setEnabled(true)
					end
				end)
			end
		})

		return v
	end

	local function output(parent2, value, p)
		local scroll = UI.scroll({
			Name = "Output",
			Size = p and UDim2.new(1, 0, 0, p) or UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Theme.bgDark,
			BackgroundTransparency = 0,
			ScrollingDirection = Enum.ScrollingDirection.XY,
			AutomaticCanvasSize = Enum.AutomaticSize.XY,
			HorizontalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
			LayoutOrder = value or 0,
			Parent = parent2
		})

		local corner = UI.corner(6)
		corner.Parent = scroll
		local padded = UI.pad(8, 10, 8, 10)
		padded.Parent = scroll
		local textBox = UI.new("TextBox", {
			Name = "Text",
			Text = "",
			TextEditable = false,
			ClearTextOnFocus = false,
			MultiLine = true,
			FontFace = Theme.fontMono,
			TextSize = 12,
			TextColor3 = Theme.textSoft,
			TextXAlignment = Left,
			TextYAlignment = Top,
			AutomaticSize = Enum.AutomaticSize.XY,
			Size = UDim2.new(),
			Parent = scroll
		})

		local v = { frame = scroll, text = textBox }
		function v.set(value2, p2)
			textBox.Text = tostring(value2 or "")
			textBox.TextColor3 = p2 or Theme.textSoft
			scroll.CanvasPosition = Vector2.zero
		end
		return v
	end

	local function clear(instance)
		for _, child in instance:GetChildren() do
			if child:IsA("UIListLayout") or child:IsA("UIPadding") or child:IsA("UIGridLayout") then
				continue
			end

			child:Destroy()
		end
	end

	local function headshot(userId, p, options)
		local imageLabel = UI.new("ImageLabel", {
			Name = "Headshot",
			Size = UDim2.fromOffset(p, p),
			BackgroundColor3 = Color3.fromRGB(70, 68, 65),
			BackgroundTransparency = 0,
			Image = type(userId) == "number" and userId > 0 and string.format(
				"rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150",
				userId
			) or ""
		}, { UI.corner(((math.max)(4, p // 8))) })

		for k, v in options or {} do
			imageLabel[k] = v
		end

		return imageLabel
	end

	local function segmented(parent2, p, p2, value, value2, fn) -- 1 equivalent call inferred from this helper
		local segmented2 = UI.segmented(p, p2, fn, value2 or 34)
		segmented2.frame.LayoutOrder = value or 0
		segmented2.frame.Parent = parent2
		return segmented2
	end

	local textButton = UI.new("TextButton", {
		Name = "AdminPanel",
		Text = "",
		AutoButtonColor = false,
		Selectable = false,
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.4,
		ZIndex = 25,
		Visible = false,
		Parent = app.gui
	})

	textButton:SetAttribute("Sfx", "none")
	local frame = UI.new("Frame", {
		Name = "Panel",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(900, 640),
		BackgroundColor3 = Theme.panel,
		Active = true,
		Parent = textButton
	}, { UI.corner(10) })
	local stroke = UI.stroke(Theme.divider, 1, 0)
	stroke.Parent = frame

	local frame2 = UI.new(
		"Frame",
		{
			Name = "Header",
			Size = UDim2.new(1, 0, 0, 48),
			BackgroundColor3 = Theme.panelHeader,
			Parent = frame
		},
		{ UI.corner(10) }
	)
	UI.icon("settings", 24, color, {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 14, 0.5, 0),
		Parent = frame2
	})
	UI.text({
		Text = "RoChess Admin",
		FontFace = Theme.fontHeavy,
		TextSize = 20,
		TextXAlignment = Left,
		Position = UDim2.fromOffset(46, 0),
		Size = UDim2.new(0, 200, 1, 0),
		Parent = frame2
	})

	local text = UI.text({
		Name = "Server",
		Text = "",
		FontFace = Theme.fontMono,
		TextSize = 12,
		TextColor3 = Theme.textMuted,
		TextXAlignment = Enum.TextXAlignment.Right,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -56, 0, 0),
		Size = UDim2.new(0, 300, 1, 0),
		Parent = frame2
	})

	UI.button({
		parent = frame2,
		name = "Close",
		icon = "close",
		iconSize = 18,
		size = UDim2.fromOffset(36, 34),
		position = UDim2.new(1, -10, 0.5, 0),
		anchor = Vector2.new(1, 0.5),
		style = "ghost",
		padX = 0,
		onClick = function()
			Admin.close()
		end
	})

	local v = {
		{ id = "players", label = "Players", icon = "person" },
		{ id = "anticheat", label = "Anticheat", icon = "search" },
		{ id = "servers", label = "Servers", icon = "grid" },
		{ id = "economy", label = "Economy", icon = "token" },
		{ id = "log", label = "Log", icon = "history" }
	}

	local frame3 = UI.new("Frame", {
		Name = "Tabs",
		Position = UDim2.fromOffset(10, 56),
		Size = UDim2.new(1, -20, 0, 40),
		BackgroundTransparency = 1,
		Parent = frame
	})

	local v2 = "players"

	local segmented2 = UI.segmented(v, v2, function(p)
		Admin.tab(p)
	end, 40)
	segmented2.frame.Parent = frame3

	local frame4 = UI.new("Frame", {
		Name = "Body",
		Position = UDim2.fromOffset(10, 104),
		Size = UDim2.new(1, -20, 1, -114),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent = frame
	})
	local framesById = {}

	local v3 = {}

	for _, v4 in v do
		framesById[v4.id] = UI.new("Frame", {
			Name = v4.id,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Visible = v4.id == v2,
			Parent = frame4
		})
	end

	local v4 = {}
	local function layout()
		local absoluteSize = app.gui.AbsoluteSize
		local inset = app.topbar and app.topbar.inset or 0
		local v5 = math.min(absoluteSize.X - 16, 1120)
		local v6 = math.min(absoluteSize.Y - inset - 16, 800)
		frame.Size = UDim2.fromOffset(v5, v6)
		frame.Position = UDim2.new(0.5, 0, 0.5, inset / 2)

		for _, v7 in v4 do
			v7(v5, v6)
		end
	end
	app.gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		if textButton.Visible then
			layout()
		end
	end)

	function Admin.tab(p)
		v2 = p
		segmented2.set(p)

		for k, v5 in framesById do
			v5.Visible = k == p
		end

		if v3[p] then
			task.spawn(v3[p])
		end
	end

	function Admin.open(p)
		layout()
		textButton.Visible = true
		UI.pop(frame, 0.96, 0.18)
		Admin.tab(p or v2)
		task.spawn(function()
			local v5 = call("me")

			if v5.ok then
				text.Text = string.format(
					"%s  v%s%s%s",
					v5.studio and "studio" or string.sub(tostring(v5.job), 1, 8),
					tostring(v5.version),
					v5.offline and "  test data" or "",
					v5.restarting and "  RESTARTING" or ""
				)
			end
		end)
	end

	function Admin.close()
		textButton.Visible = false
	end

	function Admin.toggle()
		if textButton.Visible then
			Admin.close()
		else
			Admin.open()
		end
	end

	local lookupUser

	local players = framesById.players
	local frame5 = UI.new(
		"Frame",
		{
			Name = "Left",
			Size = UDim2.new(0, 270, 1, 0),
			BackgroundColor3 = Theme.panelLight,
			Parent = players
		},
		{ UI.corner(8), UI.pad(10, 10, 10, 10) }
	)
	local frame6 = UI.new(
		"Frame",
		{
			Name = "Search",
			Size = UDim2.new(1, 0, 0, 36),
			BackgroundTransparency = 1,
			Parent = frame5
		},
		{ UI.list(Horizontal, 6, nil, Center) }
	)
	local v5 = input(frame6, "Username or user id", UDim2.new(1, -72, 0, 34), 1)
	btn(frame6, "Find", 66, "primary", 2, function()
		lookupUser(v5.Text)
	end)
	v5.FocusLost:Connect(function(p)
		if p and #v5.Text > 0 then
			task.spawn(lookupUser, v5.Text)
		end
	end)
	local frame7 = UI.new("Frame", {
		Name = "HereHead",
		Position = UDim2.fromOffset(0, 46),
		Size = UDim2.new(1, 0, 0, 28),
		BackgroundTransparency = 1,
		Parent = frame5
	})

	UI.text({
		Text = "In this server",
		FontFace = Theme.fontBold,
		TextSize = 14,
		TextColor3 = Theme.textDim,
		TextXAlignment = Left,
		Size = UDim2.new(1, -80, 1, 0),
		Parent = frame7
	})

	local scroll = UI.scroll({
		Name = "Here",
		Position = UDim2.fromOffset(0, 78),
		Size = UDim2.new(1, 0, 1, -78),
		Parent = frame5
	})

	local list = UI.list(Vertical, 4)
	list.Parent = scroll

	local function refreshHere()
		local v6 = call("serverPlayers")
		clear(scroll)

		if not v6.ok then
			label(scroll, v6.reason or "Couldn't load the players.", 1)
			return
		end

		for k, player in v6.players do
			local textButton2 = UI.new("TextButton", {
				Name = player.name,
				Size = UDim2.new(1, -6, 0, 44),
				BackgroundColor3 = Theme.panelHeader,
				LayoutOrder = k,
				Parent = scroll
			}, { UI.corner(6) })
			headshot(player.userId, 32, { Position = UDim2.fromOffset(6, 6), Parent = textButton2 })
			local text2 = UI.text
			local v7 = esc(player.display) -- inferred equivalent call
			local v8

			if player.vip then
				v8 = color2("  VIP", Theme.vip) or "" -- inferred equivalent call
			else
				v8 = ""
			end

			local v9

			if player.purgatory then
				v9 = color2("  PURG", color) or "" -- inferred equivalent call
			else
				v9 = ""
			end

			text2({
				Text = v7 .. v8 .. v9,
				RichText = true,
				FontFace = Theme.fontBold,
				TextSize = 14,
				TextXAlignment = Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Position = UDim2.fromOffset(46, 5),
				Size = UDim2.new(1, -52, 0, 18),
				Parent = textButton2
			})

			local v10 = {}

			if player.level then
				table.insert(v10, "Lv " .. player.level)
			end

			if player.rating then
				table.insert(v10, (tostring(player.rating)))
			end

			if player.tokens then
				table.insert(v10, num(player.tokens) .. " tk")
			end

			if player.busy then
				table.insert(v10, "in a game")
			end

			if not player.loaded then
				table.insert(v10, "loading")
			end

			UI.text({
				Text = "@" .. player.name .. "  " .. table.concat(v10, " · "),
				FontFace = Theme.font,
				TextSize = 12,
				TextColor3 = Theme.textDim,
				TextXAlignment = Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Position = UDim2.fromOffset(46, 23),
				Size = UDim2.new(1, -52, 0, 16),
				Parent = textButton2
			})

			UI.hover(textButton2, textButton2, { BackgroundColor3 = Theme.rowActive }, {
				BackgroundColor3 = Theme.panelHeader
			})
			textButton2.Activated:Connect(function()
				v5.Text = player.name
				task.spawn(lookupUser, player.userId)
			end)
		end

		if #v6.players == 0 then
			label(scroll, "Nobody here.", 1)
		end
	end
	UI.button({
		parent = frame7,
		name = "Refresh",
		text = "Refresh",
		textSize = 13,
		size = UDim2.fromOffset(72, 26),
		position = UDim2.new(1, 0, 0, 0),
		anchor = Vector2.new(1, 0),
		style = "flat",
		padX = 4,
		onClick = function()
			task.spawn(refreshHere)
		end
	})

	local scroll2 = UI.scroll({
		Name = "Right",
		Position = UDim2.fromOffset(280, 0),
		Size = UDim2.new(1, -280, 1, 0),
		Parent = players
	})

	local list_2 = UI.list(Vertical, 10)
	list_2.Parent = scroll2
	local padded = UI.pad(0, 8, 8, 0)
	padded.Parent = scroll2

	table.insert(v4, function(p)
		if p - 20 < 700 then
			frame5.Size = UDim2.new(1, 0, 0, 230)
			scroll2.Position = UDim2.fromOffset(0, 240)
			scroll2.Size = UDim2.new(1, 0, 1, -240)
		else
			frame5.Size = UDim2.new(0, 270, 1, 0)
			scroll2.Position = UDim2.fromOffset(280, 0)
			scroll2.Size = UDim2.new(1, -280, 1, 0)
		end
	end)

	local function emptyState(p) -- 2 equivalent calls inferred from this helper
		clear(scroll2)
		label(card(scroll2, nil, 1), p, 1, 15)
	end

	clear(scroll2)
	label(
		card(scroll2, nil, 1),
		"Look someone up by username or user id (online or not), or pick someone in this server.",
		1,
		15
	)

	local notify = true
	local userId = nil

	local function showProfile(data)
		clear(scroll2)
		local userId2 = data.userId
		local profile = data.profile

		local parent2 = card(scroll2, nil, 1)
		local frame8 = UI.new("Frame", {
			Size = UDim2.new(1, 0, 0, 72),
			BackgroundTransparency = 1,
			LayoutOrder = 1,
			Parent = parent2
		})
		headshot(userId2, 72, { Parent = frame8 })
		UI.text({
			Text = esc(data.display) .. "  " .. color2("@" .. esc(data.name), Theme.textDim), -- inferred equivalent call
			RichText = true,
			FontFace = Theme.fontHeavy,
			TextSize = 20,
			TextXAlignment = Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Position = UDim2.fromOffset(84, 2),
			Size = UDim2.new(1, -84, 0, 26),
			Parent = frame8
		})

		local v6 = {}
		local function chip(p, p2) -- 9 equivalent calls inferred from this helper
			table.insert(v6, color2(p, p2))
		end

		if data.online and data.online.here then
			chip("● online here", Theme.green) -- inferred equivalent call
		elseif data.online then
			chip("● online (server " .. string.sub(tostring(data.online.job), 1, 8) .. ")", Theme.green) -- inferred equivalent call
		elseif data.found then
			chip("offline, last seen " .. ago(data.lastSeen), Theme.textDim) -- inferred equivalent call
		else
			chip("never played RoChess", Theme.textDim) -- inferred equivalent call
		end

		if profile and profile.vip then
			chip("VIP" .. (profile.vipGift and (profile.vipGift.admin and " (admin)" or " (gift)") or ""), Theme.vip) -- inferred equivalent call
		end

		if data.purgatory then
			chip(data.probation and "PROBATION" or "PURGATORY", color) -- inferred equivalent call
		end

		if data.cleared then
			chip("released (no auto flags)", blueSoft) -- inferred equivalent call
		end

		if data.ban and data.ban.banned then
			chip("BANNED" .. (data.ban.ends and " until " .. os.date("%d %b", data.ban.ends) or ""), Theme.loss) -- inferred equivalent call
		end

		if data.admin then
			chip("admin", color) -- inferred equivalent call
		end

		UI.text({
			Text = string.format("id %d    %s", userId2, table.concat(v6, "   ")),
			RichText = true,
			FontFace = Theme.fontMedium,
			TextSize = 14,
			TextColor3 = Theme.textDim,
			TextXAlignment = Left,
			TextYAlignment = Top,
			TextWrapped = true,
			Position = UDim2.fromOffset(84, 32),
			Size = UDim2.new(1, -84, 0, 40),
			Parent = frame8
		})

		if profile then
			local v7 = {}
			local v8 = {}

			for _, class in Config.CLASSES do
				local rating = profile.ratings[class]

				if rating then
					table.insert(
						v7,
						string.format(
							"%s <b>%d</b> (%d games, %d/%d/%d, best %d)",
							class,
							rating.r,
							rating.n,
							rating.w,
							rating.l,
							rating.d,
							rating.best
						)
					)
				end
			end

			table.insert(v8, table.concat(v7, "    "))

			if profile.puzzle then
				table.insert(
					v8,
					string.format(
						"puzzles <b>%d</b> (%d of %d solved, best run %d)    sprint %s / %s / %s",
						profile.puzzle.r,
						profile.puzzle.w,
						profile.puzzle.n,
						profile.puzzle.bestStreak,
						tostring(profile.rush and profile.rush.m3 or 0),
						tostring(profile.rush and profile.rush.m5 or 0),
						(tostring(profile.rush and profile.rush.surv or 0))
					)
				)
			end

			table.insert(
				v8,
				string.format(
					"level <b>%d</b> (%s XP)    games %s    playtime %.1f h    joined %s",
					profile.level,
					num(profile.xp),
					num(profile.games),
					profile.playtime / 3600,
					profile.created and os.date("%d %b %Y", profile.created) or "?"
				)
			)
			table.insert(
				v8,
				string.format(
					"tokens %s    earned %s    bought %s    gifted %s    admin %s",
					color2("<b>" .. num(profile.tokens) .. "</b>", Theme.token), -- inferred equivalent call
					num(profile.tokensEarned),
					num(profile.tokensBought),
					num(profile.tokensGifted),
					num(profile.tokensAdmin)
				)
			)

			local v9 = num(profile.crates)
			local v10 = num(profile.inv)
			local v11 = num(profile.donated)
			local v12 = num(profile.giftsSent)
			local v13 = profile.reviewGift
				and (profile.reviewGift.admin and "unlimited (admin)" or "unlimited (gift)")
				or "pass / daily"
			local v14

			if profile.abort then
				v14 = color2("    abort probation", color) or "" -- inferred equivalent call
			else
				v14 = ""
			end

			table.insert(
				v8,
				string.format(
					"crates %s    items %s    donated %s R$    gifts sent %s    Game Breakdown %s%s",
					v9,
					v10,
					v11,
					v12,
					v13,
					v14
				)
			)

			label(parent2, table.concat(v8, "\n"), 2, 14, Theme.textSoft)
		end

		local function edit(p, value)
			p.uid = userId2
			p.notify = notify
			local v7 = call("edit", p)

			if v7.ok then
				toast( -- inferred equivalent call
					(v7.applied and "Done: " or "Queued (applies when they join): ") .. (v7.text or value or ""),
					true
				)
				task.delay(v7.applied and 1.2 or 0.2, function()
					if userId == userId2 then
						lookupUser(userId2, true)
					end
				end)
			else
				toast(v7.reason or "Didn't work.", false) -- inferred equivalent call
			end
		end

		local parent3 = card(scroll2, "Tokens & XP", 2, Theme.token)
		local parent4 = row(parent3, 1)
		local v7 = input(parent4, "Amount", UDim2.new(0, 100, 0, 34), 1)
		btn(parent4, "Give tokens", 110, "primary", 2, function()
			edit({ k = "tokens", n = tonumber(v7.Text) })
		end)
		btn(parent4, "Take tokens", 110, "danger", 3, function()
			local text2 = tonumber(v7.Text)
			edit({
				k = "tokens",
				n = text2 and -math.abs(text2)
			})
		end, true)
		local parent5 = row(parent3, 2)
		local v8 = input(parent5, "XP", UDim2.new(0, 100, 0, 34), 1)
		btn(parent5, "Give XP", 110, "primary", 2, function()
			edit({ k = "xp", n = tonumber(v8.Text) })
		end)
		btn(parent5, "Take XP", 110, "danger", 3, function()
			local text2 = tonumber(v8.Text)
			edit({
				k = "xp",
				n = text2 and -math.abs(text2)
			})
		end, true)
		local parent6 = row(parent3, 3, 28)
		local v9 = UI.toggle(notify, function(p)
			notify = p
		end)
		v9.frame.LayoutOrder = 1
		v9.frame.Parent = parent6
		UI.text({
			Text = "Tell them in game when they get something",
			TextSize = 14,
			TextColor3 = Theme.textDim,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.new(0, 0, 1, 0),
			LayoutOrder = 2,
			Parent = parent6
		})

		local parent7 = card(scroll2, "Cosmetics", 3, Theme.blueSoft)
		local parent8 = row(parent7, 1)
		local v10 = input(parent8, "Item id (type to search)", UDim2.new(1, -244, 0, 34), 1)
		btn(parent8, "Give", 110, "primary", 2, function()
			edit({
				k = "give",
				ids = { v10.Text }
			})
		end)
		btn(parent8, "Take", 110, "danger", 3, function()
			edit({
				k = "take",
				ids = { v10.Text }
			})
		end, true)
		local parent9 = wrapRow(parent7, 2)
		local function suggest()
			clear(parent9)
			local text2 = string.lower(v10.Text)

			if #text2 < 1 then
				return
			end

			local count = 0

			for _, v11 in Cosmetics.ITEMS do
				if v11.free or v11.vip then
					continue
				end

				local name = tostring(v11.name or v11.id)

				if not (string.find(string.lower(v11.id), text2, 1, true) or string.find(string.lower(name), text2, 1, true)) then
					continue
				end

				count += 1
				UI.new("TextButton", {
					Text = string.format(
						"%s  <font color=\"%s\">%s · %s</font>",
						esc(name), -- inferred equivalent call
						hex(Theme.textMuted), -- inferred equivalent call
						tostring(v11.type),
						(tostring(v11.rarity))
					),
					RichText = true,
					FontFace = Theme.fontMedium,
					TextSize = 13,
					TextColor3 = Theme.textSoft,
					AutomaticSize = Enum.AutomaticSize.X,
					Size = UDim2.new(0, 0, 0, 26),
					BackgroundColor3 = Theme.panelHeader,
					BackgroundTransparency = 0,
					LayoutOrder = count,
					Parent = parent9
				}, { UI.corner(13), UI.pad(0, 10, 0, 10) }).Activated:Connect(function()
					v10.Text = v11.id
				end)

				if count >= 8 then
					break
				end
			end
		end
		v10:GetPropertyChangedSignal("Text"):Connect(suggest)
		local parent10 = wrapRow(parent7, 3)
		btn(parent10, "Give every item", 140, "secondary", 1, function()
			edit({ k = "give", ids = "all" })
		end, true)
		btn(parent10, "Take every item", 140, "danger", 2, function()
			edit({ k = "take", ids = "all" })
		end, true)

		local parent11 = card(scroll2, "VIP & Game Breakdown", 4, Theme.vip)
		local parent12 = wrapRow(parent11, 1)
		btn(parent12, "Give VIP", 120, "gold", 1, function()
			edit({ k = "vip", on = true })
		end)
		btn(parent12, "Remove VIP", 120, "secondary", 2, function()
			edit({ k = "vip", on = false })
		end, true)
		btn(parent12, "Give Review", 120, "primary", 3, function()
			edit({ k = "review", on = true })
		end)
		btn(parent12, "Remove Review", 130, "secondary", 4, function()
			edit({ k = "review", on = false })
		end, true)
		label(
			parent11,
			"Removing only takes away what was given (admin or gift); a bought pass still counts.",
			2,
			12,
			Theme.textMuted
		)

		local parent13 = card(scroll2, "Ratings", 5, blueSoft)
		local v11 = {}

		for _, class in Config.CLASSES do
			table.insert(v11, {
				id = class,
				label = string.upper((string.sub(class, 1, 1))) .. string.sub(class, 2)
			})
		end

		table.insert(v11, { id = "puzzle", label = "Puzzles" })
		table.insert(v11, { id = "all", label = "All games" })
		local class = Config.CLASSES[1]
		local function fn(p)
			class = p
		end

		segmented(parent13, v11, class, 1, nil, fn) -- inferred equivalent call
		local parent14 = row(parent13, 2)
		local v12 = input(parent14, "New rating", UDim2.new(0, 120, 0, 34), 1)
		v12.Text = tostring(Config.DEFAULT_RATING)
		btn(parent14, "Set rating", 120, "danger", 2, function()
			edit({ k = "rating", class = class, r = tonumber(v12.Text) })
		end, true)
		label(
			parent13,
			"Sets the rating and best to this, keeps games played; the boards update when it's applied.",
			3,
			12,
			Theme.textMuted
		)

		local parent15 = card(scroll2, "Moderation", 6, color)
		local parent16 = row(parent15, 1)
		local v13 = input(parent16, "Reason (shown to them for kicks and bans)", UDim2.new(1, -110, 0, 34), 1)
		local v14 = input(parent16, "Ban days", UDim2.new(0, 100, 0, 34), 2)
		local parent17 = wrapRow(parent15, 2)
		btn(parent17, "Kick", 90, "secondary", 1, function()
			local v15 = call("kick", { uid = userId2, reason = v13.Text })
			local v16

			if v15.ok then
				v16 = v15.here and "Kicked." or "Kick sent to their server."
			else
				v16 = v15.reason or "Didn't work."
			end

			toast(v16, v15.ok) -- inferred equivalent call
		end, true)
		btn(parent17, "Ban", 90, "danger", 2, function()
			local v15 = call("ban", {
				uid = userId2,
				on = true,
				reason = v13.Text,
				days = tonumber(v14.Text)
			})
			toast(v15.ok and "Banned from RoChess." or v15.reason or "Didn't work.", v15.ok) -- inferred equivalent call

			if v15.ok then
				lookupUser(userId2, true)
			end
		end, true)
		btn(parent17, "Unban", 90, "secondary", 3, function()
			local v15 = call("ban", { uid = userId2, on = false })
			toast(v15.ok and "Unbanned." or v15.reason or "Didn't work.", v15.ok) -- inferred equivalent call

			if v15.ok then
				lookupUser(userId2, true)
			end
		end, true)
		local v15 = nil
		local function ac(action, options)
			local v16 = { action = action, uid = userId2 }

			for k, v17 in options or {} do
				v16[k] = v17
			end

			local v17 = call("ac", v16)

			if not v15 then
				return v17
			end

			local set = v15.set
			local text2 = v17.ok and v17.text or v17.reason or "Didn't work."
			local v18

			if not v17.ok then
				v18 = Theme.loss or nil
			end

			set(text2, v18)

			return v17
		end

		local parent18 = wrapRow(parent15, 3)
		btn(parent18, "To purgatory", 130, "danger", 1, function()
			local v16 = ac("send", { reason = v13.Text })
			toast(v16.ok and v16.text or v16.reason or "Didn't work.", v16.ok) -- inferred equivalent call
		end, true)
		btn(parent18, "Release", 100, "secondary", 2, function()
			local v16 = ac("release")
			toast(v16.ok and v16.text or v16.reason or "Didn't work.", v16.ok) -- inferred equivalent call
		end, true)
		btn(parent18, "Auto checks on", 130, "secondary", 3, function()
			ac("unclear")
		end)
		btn(parent18, "Cheat review", 130, "primary", 4, function()
			v15.set("Scanning up to 10 of their recent rated wins and draws with the engine... this can take a minute.")
			ac("review")
		end)
		btn(parent18, "Refresh record", 130, "flat", 5, function()
			ac("inspect")
		end)
		v15 = output(parent15, 4, 230)
		v15.set(data.ac or "No anticheat record.")
		label(
			parent15,
			"Purgatory is silent: fallback opponents only, off the boards. Kick and ban are visible to them.",
			5,
			12,
			Theme.textMuted
		)

		if profile and #profile.history > 0 then
			local parent19 = card(scroll2, string.format("Recent games (%d saved)", profile.historyN), 7)
			local v16 = {}

			for _, v17 in profile.history do
				local v18, loss, draw

				if v17.result == "win" then
					v18 = color2("win ", Theme.win) -- inferred equivalent call

					if not v18 then
						if v17.result == "loss" then
							loss = Theme.loss
							v18 = color2("loss", loss) -- inferred equivalent call

							if not v18 then
								draw = Theme.draw
								v18 = color2("draw", draw) -- inferred equivalent call
							end
						else
							draw = Theme.draw
							v18 = color2("draw", draw) -- inferred equivalent call
						end
					end
				elseif v17.result == "loss" then
					loss = Theme.loss
					v18 = color2("loss", loss) -- inferred equivalent call

					if not v18 then
						draw = Theme.draw
						v18 = color2("draw", draw) -- inferred equivalent call
					end
				else
					draw = Theme.draw
					v18 = color2("draw", draw) -- inferred equivalent call
				end

				local v19 = os.date("%d %b %H:%M", v17.t or 0)

				local tc = tostring(v17.tc)
				local v20 = v17.rated and "rated" or "casual"
				table.insert(
					v16,
					string.format(
						"%s  %s  %-5s %s  vs %s (%s)  %s, %d moves",
						v19,
						v18,
						tc,
						v20,
						esc(v17.opp and v17.opp.n or "?"), -- inferred equivalent call
						tostring(v17.opp and v17.opp.r or "?") .. (v17.opp and tonumber(v17.opp.u) and v17.opp.u < 0 and ", fallback" or ""),
						tostring(v17.why or ""),
						v17.moves or 0
					)
				)
			end

			label(parent19, table.concat(v16, "\n"), 1, 13, Theme.textSoft)
		end

		if data.pending and #data.pending > 0 then
			local parent19 = card(scroll2, string.format("Waiting for them to join (%d)", #data.pending), 8, Theme.gold)
			local v16 = {}

			for _, v17 in data.pending do
				table.insert(v16, "• " .. esc(v17.text) .. "  " .. color2(ago(v17.t), Theme.textMuted)) -- inferred equivalent call
			end

			label(parent19, table.concat(v16, "\n"), 1, 13, Theme.textSoft)
			btn(wrapRow(parent19, 2), "Cancel all", 110, "danger", 1, function()
				local v17 = call("cancelPending", { uid = userId2 })
				toast(v17.ok and "Cancelled " .. tostring(v17.n) .. " changes." or v17.reason or "Didn't work.", v17.ok) -- inferred equivalent call
				lookupUser(userId2, true)
			end, true)
		end
	end

	local count = 0
	lookupUser = function(p, p2)
		if p == nil or p == "" then
			return
		end

		count += 1
		local v6 = count

		if not p2 then
			emptyState("Looking up " .. esc(tostring(p)) .. "...") -- inferred equivalent call
		end

		local v7 = call("lookup", { q = p })

		if v6 ~= count then
			return
		end

		if v7.ok then
			userId = v7.userId
			local canvasPosition = scroll2.CanvasPosition
			showProfile(v7)

			if p2 then
				scroll2.CanvasPosition = canvasPosition
			end
		else
			emptyState(color2(esc(v7.reason or "Couldn't look them up."), Theme.loss)) -- inferred equivalent call
		end
	end
	Admin.lookup = lookupUser

	v3.players = refreshHere

	local anticheat = framesById.anticheat
	local frame8 = UI.new("Frame", {
		Name = "Controls",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = anticheat
	}, { UI.list(Vertical, 8) })
	local v6 = nil
	local function run(p) -- 6 equivalent calls inferred from this helper
		v6.set("Working...")
		local v7 = call("ac", p)
		local set = v6.set
		local text2 = v7.ok and v7.text or v7.reason or "Didn't work."
		local v8

		if not v7.ok then
			v8 = Theme.loss or nil
		end

		set(text2, v8)
	end
	local parent2 = wrapRow(frame8, 1)
	btn(parent2, "Purgatory & reports", 170, "secondary", 1, function()
		run({ action = "list", n = 50 }) -- inferred equivalent call
	end)
	btn(parent2, "Review list", 120, "secondary", 2, function()
		run({ action = "suspects", n = 40 }) -- inferred equivalent call
	end)
	btn(parent2, "Puzzle board check", 160, "secondary", 3, function()
		run({ action = "sweep", n = 50 }) -- inferred equivalent call
	end)
	btn(parent2, "Puzzle board sweep", 160, "danger", 4, function()
		run({ action = "sweepApply", n = 50 }) -- inferred equivalent call
	end, true)
	btn(parent2, "/review check", 130, "flat", 5, function()
		run({ action = "reviewCheck", hours = 12 }) -- inferred equivalent call
	end)
	local parent3 = row(frame8, 2)
	local v7 = input(parent3, "Username or user id", UDim2.new(0, 220, 0, 34), 1)
	btn(parent3, "Inspect", 100, "primary", 2, function()
		run({ -- inferred equivalent call
			action = "inspect",
			uid = tonumber(v7.Text) or v7.Text
		})
	end)
	btn(parent3, "Open player", 120, "secondary", 3, function()
		Admin.tab("players")
		lookupUser(v7.Text)
	end)
	local frame9 = UI.new("Frame", {
		Name = "OutHolder",
		Position = UDim2.fromOffset(0, 100),
		Size = UDim2.new(1, 0, 1, -100),
		BackgroundTransparency = 1,
		Parent = anticheat
	})

	v6 = output(frame9, 1)
	v6.set("Pick a list above, or inspect a player. Purgatory changes reach players in other servers within a few minutes.")
	frame8:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		local v8 = frame8.AbsoluteSize.Y + 10
		frame9.Position = UDim2.fromOffset(0, v8)
		frame9.Size = UDim2.new(1, 0, 1, -v8)
	end)

	local servers = framesById.servers
	local scroll3 = UI.scroll({ Name = "Scroll", Size = UDim2.fromScale(1, 1), Parent = servers })
	local list_3 = UI.list(Vertical, 10)
	list_3.Parent = scroll3
	local padded_2 = UI.pad(0, 8, 8, 0)
	padded_2.Parent = scroll3

	local v8 = label(card(scroll3, "Overview", 1), "...", 1, 14, Theme.textSoft)

	local parent4 = card(scroll3, "Announcement", 2, Theme.gold)
	local parent5 = row(parent4, 1)
	local v9 = input(parent5, "Message for everyone (up to 200 letters)", UDim2.new(1, -90, 0, 34), 1)
	local v10 = input(parent5, "Seconds", UDim2.new(0, 82, 0, 34), 2)
	v10.Text = "8"
	local scope = "here"
	local v11 = scope
	local function fn(p)
		scope = p
	end

	local segmented3 = UI.segmented({
		{ id = "here", label = "This server" },
		{ id = "all", label = "All servers" }
	}, v11, fn, 34)
	segmented3.frame.LayoutOrder = 2
	segmented3.frame.Parent = parent4

	btn(wrapRow(parent4, 3), "Send", 100, "primary", 1, function()
		local v12 = call("announce", {
			text = v9.Text,
			duration = tonumber(v10.Text),
			scope = scope
		})
		local v13

		if v12.ok then
			v13 = scope == "all" and "Sent to every server." or "Sent."
		else
			v13 = v12.reason or "Didn't work."
		end

		toast(v13, v12.ok) -- inferred equivalent call
	end, true)

	local parent6 = card(scroll3, "Restart (soft)", 3, color)
	label(
		parent6,
		"Counts down, then moves everyone to fresh servers. Players in a game go when it ends (10 min at most). New games start on fresh servers meanwhile.",
		1,
		13,
		Theme.textMuted
	)
	local parent7 = row(parent6, 2)
	local v12 = input(parent7, "Seconds", UDim2.new(0, 90, 0, 34), 1)
	v12.Text = "60"
	local v13 = input(parent7, "Message (optional)", UDim2.new(1, -98, 0, 34), 2)
	local scope2 = "here"
	local v14 = scope2
	local function fn2(p)
		scope2 = p
	end

	local segmented4 = UI.segmented({
		{ id = "here", label = "This server" },
		{ id = "all", label = "All servers" }
	}, v14, fn2, 34)
	segmented4.frame.LayoutOrder = 3
	segmented4.frame.Parent = parent6

	btn(wrapRow(parent6, 4), "Restart", 110, "danger", 1, function()
		local v15 = call("restart", { scope = scope2, delay = tonumber(v12.Text), text = v13.Text })
		toast(v15.ok and "Restart started." or v15.reason or "Didn't work.", v15.ok) -- inferred equivalent call
	end, true)

	local parent8 = card(scroll3, "Servers", 4)
	local frame10 = UI.new("Frame", {
		Name = "List",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 2,
		Parent = parent8
	}, { UI.list(Vertical, 4) })

	local function refresh()
		v8.Text = "Loading..."
		local v15 = call("servers")

		if v15.ok then
			local v16 = string.format(
				"<b>%s</b> playing (counter)    <b>%s</b> in %s listed servers    games today <b>%s</b>    all time <b>%s</b>",
				num(v15.playing),
				num(v15.total),
				num(v15.count),
				num(v15.gamesToday),
				num(v15.gamesAllTime)
			)

			local v17 = v15.job == "" and "studio" or v15.job or "studio"
			local version = tostring(v15.version)
			local latest = tostring(v15.latest)
			local v18

			if v15.outdated then
				v18 = color2("  outdated", color) or "" -- inferred equivalent call
			else
				v18 = ""
			end

			local here = v15.here
			local v19 = v15.uptime / 3600
			local v20

			if v15.restarting then
				v20 = color2("  RESTARTING", color) or "" -- inferred equivalent call
			else
				v20 = ""
			end

			v8.Text = table.concat(
				{
					v16,
					string.format(
						"this server: %s    v%s (latest v%s)%s    %d players    up %.1f h%s",
						v17,
						version,
						latest,
						v18,
						here,
						v19,
						v20
					)
				},
				"\n"
			)

			clear(frame10)

			for k, v21 in v15.top do
				local frame11 = UI.new("Frame", {
					Size = UDim2.new(1, 0, 0, 34),
					BackgroundColor3 = k % 2 == 0 and Theme.rowAlt or Theme.row,
					LayoutOrder = k,
					Parent = frame10
				}, { UI.corner(4) })
				UI.new("TextBox", {
					Text = v21.job,
					TextEditable = false,
					ClearTextOnFocus = false,
					FontFace = Theme.fontMono,
					TextSize = 12,
					TextColor3 = v21.job == v15.job and Theme.green or Theme.textSoft,
					TextXAlignment = Left,
					Position = UDim2.fromOffset(10, 0),
					Size = UDim2.new(1, -200, 1, 0),
					ClipsDescendants = true,
					Parent = frame11
				})

				UI.text({
					Text = v21.n .. " players",
					FontFace = Theme.fontBold,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Right,
					AnchorPoint = Vector2.new(1, 0),
					Position = UDim2.new(1, -106, 0, 0),
					Size = UDim2.new(0, 80, 1, 0),
					Parent = frame11
				})

				local frame12 = UI.new("Frame", {
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -4, 0.5, 0),
					Size = UDim2.fromOffset(96, 30),
					BackgroundTransparency = 1,
					Parent = frame11
				}, { UI.list(Horizontal, 0) })
				local btn_2 = btn(frame12, "Restart", 96, "danger", 1, function()
					local v22 = call("restart", {
						scope = "job",
						job = v21.job,
						delay = tonumber(v12.Text),
						text = v13.Text
					})
					toast(v22.ok and "Restart sent to that server." or v22.reason or "Didn't work.", v22.ok) -- inferred equivalent call
				end, true)
				btn_2.holder.Size = UDim2.fromOffset(96, 30)
			end

			if #v15.top == 0 then
				label(frame10, "No servers listed yet (Studio has its own empty list).", 1)
			elseif v15.count > #v15.top then
				label(
					frame10,
					string.format("Busiest %d of %d shown.", #v15.top, v15.count),
					#v15.top + 1,
					12,
					Theme.textMuted
				)
			end
		else
			v8.Text = color2(esc(v15.reason or "Couldn't load."), Theme.loss) -- inferred equivalent call
		end
	end
	btn(row(parent8, 1, 38), "Refresh", 100, "flat", 1, refresh)
	v3.servers = refresh

	local economy = framesById.economy
	local scroll4 = UI.scroll({ Name = "Scroll", Size = UDim2.fromScale(1, 1), Parent = economy })
	local list_4 = UI.list(Vertical, 10)
	list_4.Parent = scroll4
	local padded_3 = UI.pad(0, 8, 8, 0)
	padded_3.Parent = scroll4
	local v15 = label(card(scroll4, "Numbers", 1, Theme.token), "...", 1, 14, Theme.textSoft)
	local parent9 = card(scroll4, "Codes (Creator Hub > Configs > \"codes\")", 2, Theme.green)
	local parent10 = row(parent9, 1)
	local v16 = input(parent10, "Check a code", UDim2.new(0, 220, 0, 34), 1)
	local text2 = UI.text({
		Text = "",
		RichText = true,
		TextSize = 14,
		TextColor3 = Theme.textSoft,
		TextXAlignment = Left,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 1, 0),
		LayoutOrder = 2,
		Parent = parent10
	})
	local frame11 = UI.new("Frame", {
		Name = "List",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 2,
		Parent = parent9
	}, { UI.list(Vertical, 2) })
	local v17 = {}
	local v18 = {
		live = Theme.green,
		soon = Theme.gold,
		expired = Theme.textMuted,
		off = Theme.loss
	}
	local function codeLine(data)
		local v19 = {}

		if (data.tokens or 0) > 0 then
			table.insert(v19, data.tokens .. " tokens")
		end

		if (data.xp or 0) > 0 then
			table.insert(v19, data.xp .. " XP")
		end

		if type(data.items) == "table" and #data.items > 0 then
			table.insert(v19, table.concat(data.items, ", "))
		end

		local v20 = ""

		if data.starts then
			v20 ..= "  from " .. os.date("!%d %b %H:%M", data.starts) .. " UTC"
		end

		if data.expires then
			v20 ..= "  until " .. os.date("!%d %b %H:%M", data.expires) .. " UTC"
		end

		if data.src ~= "config" then
			v20 ..= "  (" .. tostring(data.src) .. ")"
		end

		return string.format(
			"<b>%s</b>  %s  %s%s",
			esc(data.code), -- inferred equivalent call
			color2(data.state, v18[data.state] or Theme.textDim), -- inferred equivalent call
			esc(table.concat(v19, " + ")), -- inferred equivalent call
			color2(v20, Theme.textMuted)
		)
	end

	v16:GetPropertyChangedSignal("Text"):Connect(function()
		local v19 = string.upper((string.gsub(v16.Text, "%s+", "")))

		if v19 == "" then
			text2.Text = ""
			return
		end

		for _, v20 in v17 do
			if v20.code == v19 then
				text2.Text = codeLine(v20)
				return
			end
		end

		text2.Text = color2("no such code", Theme.loss) -- inferred equivalent call
	end)
	local function refresh2()
		v15.Text = "Loading..."
		local v19 = call("economy")

		if v19.ok then
			local here = v19.here
			local v20 = {}

			for _, rarity in v19.rarities do
				table.insert(
					v20,
					string.format(
						"%s %s%s",
						tostring(rarity.name or rarity.id),
						rarity.weight and tostring(rarity.weight) or "?",
						rarity.refund and " (dup refund " .. rarity.refund .. ")" or ""
					)
				)
			end

			local v21 = {}

			for k, item in v19.items do
				table.insert(v21, k .. " " .. item)
			end

			table.sort(v21)
			v15.Text = table.concat({
				string.format(
					"experience: <b>%s</b> playing    games today <b>%s</b>    all time <b>%s</b>",
					num(v19.playing),
					num(v19.gamesToday),
					num(v19.gamesAllTime)
				),
				string.format(
					"this server: %d players    %s tokens held (avg %s)    %d VIP    avg level %.1f    %s crates opened",
					here.players,
					num(here.tokens),
					here.players > 0 and num(here.tokens / here.players) or "0",
					here.vip,
					here.players > 0 and here.levels / here.players or 0,
					num(here.crates)
				),
				string.format(
					"crates: %s tokens    odds: %s    tokens for sale: %s",
					tostring(v19.cratePrice),
					table.concat(v20, ", "),
					v19.tokensForSale and "yes (crates count as paid random items)" or "no"
				),
				"catalogue: " .. table.concat(v21, ", ")
			}, "\n")

			v17 = v19.codes or {}
			clear(frame11)

			for k, v22 in v17 do
				label(frame11, codeLine(v22), k, 14, Theme.textSoft)
			end

			if #v17 == 0 then
				label(frame11, "No codes.", 1)
			end
		else
			v15.Text = color2(esc(v19.reason or "Couldn't load."), Theme.loss) -- inferred equivalent call
		end
	end
	v3.economy = refresh2

	local log = framesById.log
	local v19 = row(log, 1, 40)
	local v20 = nil
	local function refresh3()
		v20.set("Loading...")
		local v21 = call("log")

		if not v21.ok then
			v20.set(v21.reason or "Couldn't load.", Theme.loss)
			return
		end

		local v22 = {}

		for _, entry in v21.entries do
			table.insert(
				v22,
				string.format(
					"%s  %-8s  %-14s %-12s %s",
					os.date("%d %b %H:%M", entry.t or 0),
					tostring(entry.job or ""),
					tostring(entry.op),
					entry.u and tostring(entry.u) or "",
					(tostring(entry.d or ""))
				)
			)
		end

		v20.set(#v22 > 0 and table.concat(v22, "\n") or "Nothing yet.")
	end
	btn(v19, "Refresh", 100, "flat", 1, refresh3)
	v20 = output(
		UI.new("Frame", {
			Position = UDim2.fromOffset(0, 48),
			Size = UDim2.new(1, 0, 1, -48),
			BackgroundTransparency = 1,
			Parent = log
		}),
		1
	)
	v3.log = refresh3

	UserInputService.InputBegan:Connect(function(input2, gameProcessed)
		if input2.KeyCode == Enum.KeyCode.F2 and not UserInputService:GetFocusedTextBox() then
			Admin.toggle()
		elseif input2.KeyCode == Enum.KeyCode.Escape and textButton.Visible and not gameProcessed then
			Admin.close()
		end
	end)
	local textButton2 = UI.new("TextButton", {
		Name = "AdminButton",
		Text = "ADMIN",
		FontFace = Theme.fontHeavy,
		TextSize = 12,
		TextColor3 = Theme.text,
		BackgroundColor3 = color,
		BackgroundTransparency = 0.15,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 8, 1, -8),
		Size = UDim2.fromOffset(58, 24),
		ZIndex = 24,
		Visible = false,
		Parent = app.gui
	}, { UI.corner(6) })
	textButton2.Activated:Connect(Admin.toggle)
	task.spawn(function()
		while app.gui.Parent do
			textButton2.Visible = not textButton.Visible and (not app.nav or app.nav.width == 0)

			local topbar = app.topbar

			if topbar and topbar.inset > 0 and topbar.left < app.gui.AbsoluteSize.X - 80 then
				textButton2.AnchorPoint = Vector2.new(0, 0.5)
				textButton2.Position = UDim2.fromOffset(topbar.left, (math.floor(topbar.inset / 2)))
			else
				textButton2.AnchorPoint = Vector2.new(0, 1)
				textButton2.Position = UDim2.new(0, 8, 1, -8)
			end

			task.wait(1)
		end
	end)
end

return Admin