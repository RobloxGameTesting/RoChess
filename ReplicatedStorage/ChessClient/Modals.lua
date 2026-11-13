local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Config = require(ReplicatedStorage.Chess.Config)
local parent = script.Parent
local Theme = require(parent.Theme)
local UI = require(parent.UI)
local Sound = require(parent.Sound)

return {
	build = function(data)
		local v = {}
		local v2 = {}
		local count = 0
		local v3 = {}

		local v4 = false

		local Pages = require(parent.Pages)
		local REASON_TEXT = Pages.REASON_TEXT

		local function screenScale() -- 1 equivalent call inferred from this helper
			local absoluteSize = data.gui.AbsoluteSize
			return (math.clamp(math.min(absoluteSize.X / 520, absoluteSize.Y / 640), 0.6, 1.15))
		end

		local function close(p, p2, p3)
			local v5 = v2[p]

			if not v5 then
				return
			end

			v2[p] = nil

			if p3 and not p2 then
				Sound.play("close")
			end

			v5.closing = true

			if p2 then
				if v5.dim then
					v5.dim:Destroy()
				end

				v5.card:Destroy()
			else
				v5.card.Interactable = false

				if v5.dim then
					v5.dim.Active = false
					UI.tween(v5.dim, 0.1, { BackgroundTransparency = 1 })
				end

				local tween = UI.tween(v5.scale, 0.1, {
					Scale = v5.scale.Scale * 0.9
				}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
				UI.tween(v5.card, 0.1, { BackgroundTransparency = 0.4 })
				tween.Completed:Connect(function()
					if v5.dim then
						v5.dim:Destroy()
					end

					v5.card:Destroy()
				end)
			end
		end
		v.close = close

		local function contentHeight(state, scale) -- 1 equivalent call inferred from this helper
			local scroller = state.scroller
			local uiListLayout = scroller:FindFirstChildOfClass("UIListLayout")

			if not uiListLayout or scale <= 0 then
				return 0
			end

			local v5 = uiListLayout.AbsoluteContentSize.Y / scale
			local uiPadding = scroller:FindFirstChildOfClass("UIPadding")

			if uiPadding then
				v5 += uiPadding.PaddingTop.Offset + uiPadding.PaddingBottom.Offset
			end

			return (math.ceil(v5))
		end

		local function place(state)
			local v5, v6

			if state.anchor == "board" then
				local frame = data.board.frame
				local v7 = frame.AbsolutePosition + frame.AbsoluteSize / 2 - data.modalLayer.AbsolutePosition
				state.card.Position = UDim2.fromOffset(v7.X, v7.Y)
				v5 = math.clamp(frame.AbsoluteSize.X / 470, 0.62, 1.1)

				if data.compact or data.portrait then
					v5 = math.max(v5, (math.min(1.1, frame.AbsoluteSize.X * 0.92 / state.card.Size.X.Offset)))
				end

				v6 = frame.AbsoluteSize.Y - 16
			else
				local absoluteSize = data.modalLayer.AbsoluteSize
				v5 = screenScale() -- inferred equivalent call

				if data.compact then
					v5 = math.max(v5, (math.min(1, (absoluteSize.X - 24) / state.card.Size.X.Offset)))
				end

				if state.fitWidth and data.portrait then
					v5 = math.max(v5, (math.min(1, (absoluteSize.X - 24) / state.card.Size.X.Offset)))
				end

				local v7 = 12
				local topbar = data.topbar

				if topbar and topbar.inset > 0 then
					local v8 = state.card.Size.X.Offset * v5 / 2

					if absoluteSize.X / 2 - v8 < topbar.left or absoluteSize.X / 2 + v8 > topbar.right then
						v7 = topbar.inset + 6
					end
				end

				v6 = absoluteSize.Y - v7 - 12
				state.card.Position = UDim2.fromOffset(math.floor(absoluteSize.X / 2), (math.floor(v7 + v6 / 2)))
			end

			local scale = state.scale.Scale

			if state.scroller then
				local v7 = contentHeight(state, scale) -- inferred equivalent call

				if v7 > 0 then
					if v6 < v7 * v5 then
						local v8 = v6 / v7

						if v5 * 0.8 <= v8 then
							v5 = v8
						else
							v7 = math.floor(v6 / v5)
						end
					end

					if state.scroller.Size.Y.Offset ~= v7 then
						state.scroller.Size = UDim2.new(1, 0, 0, v7)
					end
				end
			else
				local v7 = scale > 0 and state.card.AbsoluteSize.Y / scale or 0

				if v7 > 0 and v6 < v7 * v5 then
					v5 = math.max(0.45, v6 / v7)
				end
			end

			if state.popping then
				state.target = v5
			elseif math.abs(state.scale.Scale - v5) > 0.004 then
				state.scale.Scale = v5
			end
		end

		local function openModal(name, p, options)
			local v5 = options or {}
			local v6 = v2[name]

			if v6 then
				v2[name] = nil

				v6.closing = true

				if v6.dim then
					v6.dim:Destroy()
				end

				v6.card:Destroy()
			end

			local textButton

			if v5.dim ~= false then
				textButton = UI.new("TextButton", {
					Name = name .. "Dim",
					Size = UDim2.fromScale(1, 1),
					BackgroundColor3 = Color3.new(0, 0, 0),
					BackgroundTransparency = 0.45,
					Text = "",
					AutoButtonColor = false,
					Selectable = false,
					Parent = data.modalLayer
				})

				if v5.dismissable ~= false then
					textButton.Activated:Connect(function()
						close(name, false, true)
					end)
				end
			end

			local frame = UI.new("Frame", {
				Name = name,
				Size = UDim2.fromOffset(p, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Theme.panel,
				Parent = data.modalLayer
			}, { UI.corner(10), UI.stroke(Color3.new(0, 0, 0), 2, 0.6) })
			local uiScale = Instance.new("UIScale")
			uiScale.Parent = frame
			local content

			if v5.scroll then
				content = UI.scroll({
					Name = "Content",
					Size = UDim2.new(1, 0, 0, 0),
					ScrollBarThickness = 4,
					Parent = frame
				})
			else
				content = UI.new("Frame", {
					Name = "Content",
					Size = UDim2.new(1, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					Parent = frame
				})
			end

			count += 1
			local v7 = {
				dim = textButton,
				card = frame,
				scale = uiScale,
				anchor = v5.anchor,
				content = content,
				scroller = 0,
				name = 0,
				seq = 0,
				dismissable = 0,
				fitWidth = 0
			}
			local scroller

			if v5.scroll then
				scroller = content or nil
			end

			v7.scroller = scroller
			v7.name = name
			v7.seq = count
			v7.dismissable = v5.dismissable ~= false
			v7.fitWidth = v5.fitWidth == true

			v2[name] = v7

			if v7.anchor == "board" and v4 then
				frame.Visible = false

				if textButton then
					textButton.Visible = false
				end
			end

			place(v7)

			if v5.sfx ~= false then
				Sound.play("open")
			end

			if textButton then
				textButton.BackgroundTransparency = 1
				UI.tween(textButton, UI.SNAP, { BackgroundTransparency = 0.45 })
			end

			v7.popping = true
			v7.target = uiScale.Scale
			uiScale.Scale = v7.target * 0.82
			task.spawn(function()
				task.wait()

				if v2[name] ~= v7 then
					return
				end

				v7.popping = false
				uiScale.Scale = 1
				place(v7)
				v7.target = uiScale.Scale
				uiScale.Scale = v7.target * 0.82
				v7.popping = true
				UI.tween(uiScale, UI.POP, { Scale = v7.target }, Enum.EasingStyle.Back, Enum.EasingDirection.Out).Completed:Wait()
				v7.popping = false

				if v2[name] == v7 then
					place(v7)
				end
			end)
			local v8 = false
			local function refit()
				if v8 or v2[name] ~= v7 then
					return
				end

				v8 = true
				place(v7)
				local absoluteSize = frame.AbsoluteSize

				task.spawn(function()
					task.wait()
					v8 = false

					if frame.Parent and frame.AbsoluteSize ~= absoluteSize then
						refit()
					end
				end)
			end
			frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(refit)

			if v7.scroller then
				content:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(refit)
			end

			return content, v7
		end

		local function closeButton(_, p)
			local card = v2[p].card
			local imageButton = UI.new("ImageButton", {
				Name = "Close",
				Size = UDim2.fromOffset(34, 34),
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -8, 0, 8),
				BackgroundTransparency = 1,
				ZIndex = 5,
				Parent = card
			})

			UI.icon("close", 22, Theme.textDim, {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				ZIndex = 5,
				Parent = imageButton
			})

			imageButton.MouseEnter:Connect(function()
				UI.tween(imageButton, UI.FAST, { Rotation = 90 })
			end)
			imageButton.MouseLeave:Connect(function()
				UI.tween(imageButton, UI.SNAP, { Rotation = 0 })
			end)
			imageButton:SetAttribute("Sfx", "none")
			imageButton.Activated:Connect(function()
				close(p, false, true)
			end)
			return imageButton
		end

		v.openModal = openModal
		v.closeButton = closeButton
		function v.isOpen(p): boolean
			return v2[p] ~= nil
		end

		function v.setBoardHidden(p)
			local v5 = p == true

			if v5 == v4 then
				return
			end

			v4 = v5

			for _, v6 in v2 do
				if v6.anchor ~= "board" then
					continue
				end

				v6.card.Visible = not v5

				if v6.dim then
					v6.dim.Visible = not v5
				end

				if not v5 then
					place(v6)
				end
			end
		end

		local function cascade(folder, value)
			local buttons = {}

			for _, button in folder:GetDescendants() do
				if not (button.Name == "Face" and button:IsA("GuiButton") and button.AnchorPoint == Vector2.new(0.5, 0.5)) then
					continue
				end

				table.insert(buttons, button)
			end

			local function key(p) -- 2 equivalent calls inferred from this helper
				local parent2 = p.Parent

				if parent2.Parent == folder then
					return parent2.LayoutOrder * 100
				end

				return parent2.Parent.LayoutOrder * 100 + parent2.LayoutOrder
			end

			table.sort(buttons, function(a, b): boolean
				return key(a) < key(b) -- inferred equivalent call
			end)

			for k, parent2 in buttons do
				local popScale = parent2:FindFirstChild("PopScale") or Instance.new("UIScale")
				popScale.Name = "PopScale"
				popScale.Scale = 0.01
				popScale.Parent = parent2
				task.delay((value or 0.15) + 0.08 * (k - 1), function()
					if parent2.Parent then
						UI.pop(parent2, 0.6, 0.28)
					end
				end)
			end
		end

		function v.relayout()
			for _, v5 in v2 do
				place(v5)
			end
		end

		function v.top()
			local v5 = nil

			for _, v6 in v2 do
				if v6.closing or not v6.card.Parent or not v6.card.Visible or not (not v5 or v6.seq > v5.seq) then
					continue
				end

				v5 = v6
			end

			return v5
		end

		function v.closeAll()
			for k in v2 do
				close(k)
			end
		end

		function v.gameOver(data2)
			local session = data2.session

			if session and session.cancelled then
				return
			end

			local parent2, v5 = openModal("GameOver", 310, {
				anchor = "board",
				dim = false,
				sfx = false
			})
			local list = UI.list(Enum.FillDirection.Vertical, 0, Enum.HorizontalAlignment.Center)
			list.Parent = parent2
			local myColor = session.myColor
			local result = data2.result
			local v6

			if result == "1-0" and myColor == 1 then
				v6 = true
			elseif result == "0-1" then
				v6 = myColor == -1
			else
				v6 = false
			end

			local v7

			if result == "1-0" and myColor == -1 then
				v7 = true
			elseif result == "0-1" then
				v7 = myColor == 1
			else
				v7 = false
			end

			local text3 = result == "*" and "Game Aborted"
				or v6 and "You Won!"
				or v7
				and (session.kind == "bot" and (Config.BOT_BY_ID[session.bot] and Config.BOT_BY_ID[session.bot].name or "Bot") .. " Won" or "You Lost")
				or "Draw"

			local green = v6 and Theme.green or Color3.fromRGB(64, 62, 58)
			local frame = UI.new("Frame", {
				Name = "Head",
				Size = UDim2.new(1, 0, 0, 86),
				BackgroundColor3 = green,
				LayoutOrder = 1,
				Parent = parent2
			}, { UI.corner(10) })
			UI.new("Frame", {
				Size = UDim2.new(1, 0, 0, 12),
				Position = UDim2.new(0, 0, 1, -12),
				BackgroundColor3 = green,
				Parent = frame
			})

			local frame2 = UI.new(
				"Frame",
				{
					Size = UDim2.new(1, 0, 0, 36),
					Position = UDim2.fromOffset(0, 14),
					BackgroundTransparency = 1,
					Parent = frame
				},
				{ UI.list(
						Enum.FillDirection.Horizontal,
						8,
						Enum.HorizontalAlignment.Center,
						Enum.VerticalAlignment.Center
					) }
			)

			if v6 then
				local icon = UI.icon("trophy", 30, Theme.gold, { LayoutOrder = 1, Parent = frame2 })
				icon.Rotation = -25
				UI.tween(icon, 0.35, { Rotation = 0 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0.1)
				task.defer(UI.pop, icon, 0.3, 0.35)

				task.delay(0.6, function()
					if icon.Parent then
						UI.tween(icon, 0.12, { Rotation = 14 }).Completed:Wait()
						UI.tween(icon, 0.4, { Rotation = 0 }, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
					end
				end)
			end

			if result ~= "*" then
				task.delay(0.2, Sound.play, v6 and "win" or v7 and "lose" or "draw")
			end

			if v6 then
				local frame3 = UI.new("Frame", {
					Name = "Fx",
					Size = UDim2.new(),
					BackgroundTransparency = 1,
					ZIndex = 20,
					Parent = v5.card
				})

				task.delay(0.12, function()
					if frame3.Parent then
						UI.confetti(frame3, Vector2.new(155, 40), { count = 34, spread = 170 })
					end
				end)
				task.delay(0.45, function()
					if frame3.Parent then
						UI.confetti(frame3, Vector2.new(155, 40), { count = 18, spread = 120 })
					end
				end)
			end

			local text = UI.text({
				Text = text3,
				FontFace = Theme.fontHeavy,
				TextSize = 30,
				AutomaticSize = Enum.AutomaticSize.X,
				Size = UDim2.fromScale(0, 1),
				LayoutOrder = 2,
				Parent = frame2
			})

			text.TextSize = v6 and 44 or 37
			UI.tween(text, v6 and 0.4 or 0.3, { TextSize = 30 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			UI.text({
				Text = REASON_TEXT[data2.reason or ""] or "",
				FontFace = Theme.fontMedium,
				TextSize = 16,
				TextColor3 = v6 and Color3.fromRGB(230, 245, 215) or Theme.textDim,
				Size = UDim2.new(1, 0, 0, 20),
				Position = UDim2.fromOffset(0, 52),
				Parent = frame
			})

			local imageLabel = closeButton(parent2, "GameOver"):FindFirstChildOfClass("ImageLabel")
			imageLabel.ImageColor3 = Color3.new(1, 1, 1)

			local frame3 = UI.new("Frame", {
				Name = "Players",
				Size = UDim2.new(1, 0, 0, 112),
				BackgroundTransparency = 1,
				LayoutOrder = 2,
				Parent = parent2
			})

			local function side(data3, p, p2, data4, p3)
				local v8

				if result == "1-0" and p == 1 then
					v8 = true
				elseif result == "0-1" then
					v8 = p == -1
				else
					v8 = false
				end

				local avatar = UI.avatar(data3, 58, {
					AnchorPoint = Vector2.new(0.5, 0),
					Position = UDim2.new(p2, 0, 0, 14),
					Parent = frame3
				})

				if v8 then
					local stroke = UI.stroke(Theme.green, 3, 0)
					stroke.Parent = avatar.frame

					stroke.Color = Theme.gold
					stroke.Thickness = 5
					UI.tween(
						stroke,
						0.6,
						{ Color = Theme.green, Thickness = 3 },
						Enum.EasingStyle.Quad,
						Enum.EasingDirection.Out
					)
					task.defer(UI.pop, avatar.frame, 0.7, 0.35)
				end

				UI.text({
					Text = data3.display or data3.name or "",
					FontFace = Theme.fontBold,
					TextSize = 14,
					TextTruncate = Enum.TextTruncate.AtEnd,
					Size = UDim2.new(0.42, 0, 0, 18),
					AnchorPoint = Vector2.new(0.5, 0),
					Position = UDim2.new(p2, 0, 0, 76),
					Parent = frame3
				})

				local userId = data3.userId

				if data.openProfile and not data3.bot and type(userId) == "number" and userId ~= 0 then
					local textButton

					if session.kind == "online" then
						textButton = UI.new("TextButton", {
							Name = "Open",
							Text = "",
							BackgroundTransparency = 1,
							AnchorPoint = Vector2.new(0.5, 0),
							Size = UDim2.new(0.42, 0, 0, 84),
							Position = UDim2.new(p2, 0, 0, 10),
							ZIndex = 3,
							Parent = frame3
						})

						textButton:SetAttribute("Sfx", "press")
						textButton.Activated:Connect(function()
							data.openProfile(userId, nil, data3)
						end)
					else
						local Players2 = game:GetService("Players")

						if userId == Players2.LocalPlayer.UserId then
							textButton = UI.new("TextButton", {
								Name = "Open",
								Text = "",
								BackgroundTransparency = 1,
								AnchorPoint = Vector2.new(0.5, 0),
								Size = UDim2.new(0.42, 0, 0, 84),
								Position = UDim2.new(p2, 0, 0, 10),
								ZIndex = 3,
								Parent = frame3
							})

							textButton:SetAttribute("Sfx", "press")
							textButton.Activated:Connect(function()
								data.openProfile(userId, nil, data3)
							end)
						end
					end
				end

				if data4 then
					local delta = data4.delta
					local v9 = (data4.prov and "?" or "") .. "  " .. (delta >= 0 and "+" or "") .. tostring(delta)
					local text2 = UI.text({
						Text = tostring(data4.new) .. v9,
						FontFace = Theme.fontBold,
						TextSize = 13,
						TextColor3 = delta > 0 and Theme.win or delta < 0 and Theme.loss or Theme.textDim,
						Size = UDim2.new(0.42, 0, 0, 16),
						AnchorPoint = Vector2.new(0.5, 0),
						Position = UDim2.new(p2, 0, 0, 94),
						Parent = frame3
					})

					if delta ~= 0 and type(data4.new) == "number" then
						text2.Text = tostring(data4.new - delta) .. v9
						task.delay(0.35, function()
							if text2.Parent then
								UI.countTo(text2, data4.new - delta, data4.new, 0.7, "%d" .. v9:gsub("%%", "%%%%"), p3)
								task.delay(0.7, UI.pop, text2, 1.3, 0.25)
							end
						end)
					end
				elseif data3.rating then
					UI.text({
						Text = tostring(data3.rating),
						TextSize = 13,
						TextColor3 = Theme.textDim,
						Size = UDim2.new(0.42, 0, 0, 16),
						AnchorPoint = Vector2.new(0.5, 0),
						Position = UDim2.new(p2, 0, 0, 94),
						Parent = frame3
					})
				end
			end
			local v8 = myColor or 1
			local white = v8 == 1 and session.white or session.black
			local black = v8 == 1 and session.black or session.white
			side(white, v8, 0.25, data2.mine, "tick")
			side(black, -v8, 0.75, data2.theirs)
			UI.text({
				Text = "vs",
				FontFace = Theme.fontHeavy,
				TextSize = 18,
				TextColor3 = Theme.textMuted,
				Size = UDim2.fromOffset(40, 58),
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(0.5, 0, 0, 14),
				Parent = frame3
			})

			if data.levelsGameOver then
				local success, result2 = pcall(data.levelsGameOver, parent2, data2, 3)

				if not success then
					warn("[Chess] level / rank rows: " .. tostring(result2))
				end
			end

			local frame4 = UI.new("Frame", {
				Name = "Buttons",
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				LayoutOrder = 4,
				Parent = parent2
			}, { UI.list(Enum.FillDirection.Vertical, 8), UI.pad(4, 16, 16, 16) })

			if session.kind == "online" and result ~= "*" and session.id then
				local display = black and (black.display or black.name or "opponent") or "opponent"
				local v9 = data.reportedGames and data.reportedGames[session.id]
				local flag = false
				local textButton = UI.new("TextButton", {
					Name = "Report",
					Text = v9 and "Reported" or "Report " .. display,
					FontFace = Theme.fontMedium,
					TextSize = 13,
					TextColor3 = Theme.textMuted,
					BackgroundTransparency = 1,
					AutoButtonColor = false,
					TextTruncate = Enum.TextTruncate.AtEnd,
					Size = UDim2.new(1, 0, 0, 30),
					LayoutOrder = 5,
					Parent = parent2
				})

				local padded = UI.pad(0, 16, 8, 16)
				padded.Parent = textButton
				textButton.Active = not v9
				textButton.Activated:Connect(function()
					if v9 then
						return
					end

					if flag then
						v9 = true
						data.reportGame(session.id)
						textButton.Text = "Reported"
						textButton.TextColor3 = Theme.textMuted
						textButton.Active = false
					else
						flag = true
						textButton.Text = "Report " .. display .. " for cheating? Tap again"
						textButton.TextColor3 = Theme.loss
						task.delay(4, function()
							if flag and not v9 and textButton.Parent then
								flag = false
								textButton.Text = "Report " .. display
								textButton.TextColor3 = Theme.textMuted
							end
						end)
					end
				end)
			end

			if data.newFlow() then
				local v9 = session.kind == "bot"
				UI.button({
					name = "PlayAgain",
					parent = frame4,
					size = UDim2.new(1, 0, 0, 54),
					style = "primary",
					icon = "play",
					text = "Play Again",
					textSize = 20,
					layoutOrder = 1,
					onClick = function()
						close("GameOver")

						if v9 then
							data.rematch()
						else
							data.newGame()
						end
					end
				})

				local frame5 = UI.new(
					"Frame",
					{
						Size = UDim2.new(1, 0, 0, 46),
						BackgroundTransparency = 1,
						LayoutOrder = 2,
						Parent = frame4
					},
					{ UI.list(Enum.FillDirection.Horizontal, 8) }
				)
				local v10 = result ~= "*"
				local udim = v10 and UDim2.new(0.5, -4, 1, 0) or UDim2.new(1, 0, 1, 0)
				v.rematchButton = nil

				if v9 then
					UI.button({
						name = "NewBot",
						parent = frame5,
						size = udim,
						style = "secondary",
						text = "New Bot",
						textSize = 16,
						layoutOrder = 1,
						onClick = function()
							close("GameOver")
							data.goHome()
							data.pages.show("bots")
						end
					})
				else
					v.rematchButton = UI.button({
						name = "Rematch",
						parent = frame5,
						size = udim,
						style = "secondary",
						text = "Rematch",
						textSize = 16,
						layoutOrder = 1,
						onClick = function(object)
							data.rematch()
							object:setText("Rematch sent")
							object:setEnabled(false)
						end
					})
				end

				if v10 then
					UI.button({
						name = "GameReview",
						parent = frame5,
						size = udim,
						style = "secondary",
						text = "Game Breakdown",
						textSize = 16,
						layoutOrder = 2,
						onClick = function()
							close("GameOver")

							if data.startReview then
								data.startReview()
							end
						end
					})
				end

				cascade(frame4, 0.25)
			else
				if result ~= "*" then
					UI.button({
						parent = frame4,
						size = UDim2.new(1, 0, 0, 54),
						style = "primary",
						icon = "analysis",
						text = "Game Breakdown",
						textSize = 20,
						layoutOrder = 1,
						onClick = function()
							close("GameOver")

							if data.startReview then
								data.startReview()
							end
						end
					})
				end

				local frame5 = UI.new(
					"Frame",
					{
						Size = UDim2.new(1, 0, 0, 46),
						BackgroundTransparency = 1,
						LayoutOrder = 2,
						Parent = frame4
					},
					{ UI.list(Enum.FillDirection.Horizontal, 8) }
				)

				local text2 = session.kind == "bot" and "New Bot"
					or "New " .. (session.tc and session.tc.label or "Game")

				UI.button({
					parent = frame5,
					size = UDim2.new(0.5, -4, 1, 0),
					style = "secondary",
					text = text2,
					textSize = 16,
					layoutOrder = 1,
					onClick = function()
						close("GameOver")

						if session.kind ~= "bot" then
							data.newGame()

							return
						end

						data.goHome()
						data.pages.show("bots")
					end
				})

				v.rematchButton = UI.button({
					parent = frame5,
					size = UDim2.new(0.5, -4, 1, 0),
					style = "secondary",
					text = "Rematch",
					textSize = 16,
					layoutOrder = 2,
					onClick = function(object)
						data.rematch()

						if session.kind == "online" then
							object:setText("Rematch sent")
							object:setEnabled(false)
						end
					end
				})

				cascade(frame4, 0.25)
			end
		end

		function v.rematchOffered()
			local rematchButton = v.rematchButton

			if rematchButton and rematchButton.holder.Parent then
				rematchButton:setText("Accept Rematch")
				rematchButton:setStyle("primary")
				rematchButton:setEnabled(true)
			end
		end

		function v.confirm(text, value, callback, value2)
			local parent2 = openModal("Confirm", 320)
			local list = UI.list(Enum.FillDirection.Vertical, 14)
			list.Parent = parent2
			local padded = UI.pad(22, 20, 20, 20)
			padded.Parent = parent2
			UI.text({
				Text = text,
				FontFace = Theme.fontBold,
				TextSize = 18,
				TextWrapped = true,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				LayoutOrder = 1,
				Parent = parent2
			})

			local frame = UI.new(
				"Frame",
				{
					Size = UDim2.new(1, 0, 0, 46),
					BackgroundTransparency = 1,
					LayoutOrder = 2,
					Parent = parent2
				},
				{ UI.list(Enum.FillDirection.Horizontal, 8) }
			)
			UI.button({
				parent = frame,
				size = UDim2.new(0.5, -4, 1, 0),
				style = "secondary",
				text = value2 == "primary" and "Not now" or "Cancel",
				textSize = 16,
				layoutOrder = 1,
				onClick = function()
					close("Confirm")
				end
			})

			UI.button({
				parent = frame,
				size = UDim2.new(0.5, -4, 1, 0),
				style = value2 or "danger",
				text = value or "Yes",
				textSize = 16,
				layoutOrder = 2,
				onClick = function()
					close("Confirm")
					callback()
				end
			})
		end

		function v.settings()
			local parent2 = openModal("Settings", 420, { scroll = true })
			local list = UI.list(Enum.FillDirection.Vertical, 12)
			list.Parent = parent2
			local padded = UI.pad(18, 20, 20, 20)
			padded.Parent = parent2
			closeButton(parent2, "Settings")
			UI.text({
				Text = "Settings",
				FontFace = Theme.fontHeavy,
				TextSize = 24,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, 0, 0, 30),
				LayoutOrder = 1,
				Parent = parent2
			})

			UI.text({
				Text = "Board",
				FontFace = Theme.fontBold,
				TextSize = 15,
				TextColor3 = Theme.textDim,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, 0, 0, 18),
				LayoutOrder = 2,
				Parent = parent2
			})

			local frame = UI.new("Frame", {
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				LayoutOrder = 3,
				Parent = parent2
			})

			local uiGridLayout = Instance.new("UIGridLayout")
			uiGridLayout.CellSize = UDim2.new(0.25, -8, 0, 92)
			uiGridLayout.CellPadding = UDim2.fromOffset(8, 8)
			uiGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
			uiGridLayout.Parent = frame
			local strokesById = {}
			local function refreshSwatches() -- 2 equivalent calls inferred from this helper
				for k, v5 in strokesById do
					v5.Transparency = k == data.settings.theme and 0 or 1
				end
			end

			for k, v5 in Config.BOARD_THEMES do
				if not (not v5.crate or data.owns and data.owns(v5.id)) then
					continue
				end

				local textButton = UI.new("TextButton", {
					Name = v5.id,
					BackgroundTransparency = 1,
					LayoutOrder = k,
					Parent = frame
				})

				local frame2 = UI.new("Frame", {
					Size = UDim2.fromOffset(64, 64),
					AnchorPoint = Vector2.new(0.5, 0),
					Position = UDim2.new(0.5, 0, 0, 2),
					BackgroundColor3 = v5.light,
					Parent = textButton
				}, { UI.corner(4) })

				for i = 0, 3 do
					local v6 = i % 2
					local v7 = i // 2
					UI.new("Frame", {
						Size = UDim2.fromScale(0.5, 0.5),
						Position = UDim2.fromScale(v6 * 0.5, v7 * 0.5),
						BackgroundColor3 = (v6 + v7) % 2 == 0 and v5.light or v5.dark,
						Parent = frame2
					})
				end

				local stroke = UI.stroke(Theme.green, 3, 1)
				stroke.Parent = frame2
				strokesById[v5.id] = stroke
				UI.text({
					Text = v5.name,
					TextSize = 13,
					TextColor3 = Theme.textDim,
					Size = UDim2.new(1, 0, 0, 18),
					Position = UDim2.fromOffset(0, 70),
					Parent = textButton
				})

				textButton.Activated:Connect(function()
					data.settings.theme = v5.id
					refreshSwatches() -- inferred equivalent call
					data.saveSettings()

					if data.cos and data.cos.eq then
						data.cos.eq.board = v5.id
					end
				end)
			end

			refreshSwatches() -- inferred equivalent call
			local v5 = {
				{ "sound", "Sound effects" },
				{ "music", "Background music" },
				{ "showLegal", "Show legal moves" },
				{ "coords", "Show coordinates" },
				{ "highlightLast", "Highlight last move" },
				{ "animate", "Piece animations" },
				{ "premove", "Allow premoves" },
				{ "autoQueen", "Always promote to queen" },
				{ "confirmResign", "Confirm before resigning" },
				{ "quickChat", "Quick chat in games" },
				{ "allowChallenges", "Accept challenges" }
			}

			if UserInputService.TouchEnabled or UserInputService.GamepadEnabled then
				table.insert(v5, 3, { "vibration", "Vibration" })
			end

			local frame2 = UI.new("Frame", {
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				LayoutOrder = 4,
				Parent = parent2
			}, { UI.list(Enum.FillDirection.Vertical, 2) })

			for k, v6 in v5 do
				local v7 = v6[1]
				local text = v6[2]
				local frame3 = UI.new("Frame", {
					Size = UDim2.new(1, 0, 0, 38),
					BackgroundTransparency = 1,
					LayoutOrder = k,
					Parent = frame2
				})

				UI.text({
					Text = text,
					FontFace = Theme.fontMedium,
					TextSize = 16,
					TextXAlignment = Enum.TextXAlignment.Left,
					Size = UDim2.new(1, -60, 1, 0),
					Parent = frame3
				})

				local v8 = UI.toggle(data.settings[v7], function(p)
					data.settings[v7] = p
					data.saveSettings()
				end)
				v8.frame.AnchorPoint = Vector2.new(1, 0.5)
				v8.frame.Position = UDim2.new(1, 0, 0.5, 0)
				v8.frame.Parent = frame3
			end
		end

		function v.welcome()
			local compact = data.compact == true
			local parent2 = openModal("Welcome", compact and 620 or 400, { dismissable = false })
			data.send({ type = "fx", ev = "welcomeShown" })
			local list = UI.list(Enum.FillDirection.Vertical, 10)
			list.Parent = parent2
			local padded = UI.pad(22, 20, 20, 20)
			padded.Parent = parent2
			UI.text({
				Text = "Welcome to RoChess!",
				FontFace = Theme.fontHeavy,
				TextSize = 24,
				TextWrapped = true,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				LayoutOrder = 1,
				Parent = parent2
			})

			UI.text({
				Text = "Do you know how to play chess?",
				TextSize = 16,
				TextColor3 = Theme.textDim,
				Size = UDim2.new(1, 0, 0, 22),
				LayoutOrder = 2,
				Parent = parent2
			})

			if compact then
				parent2 = UI.new("Frame", {
					Name = "Choices",
					Size = UDim2.new(1, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					LayoutOrder = 3,
					Parent = parent2
				})

				local uiGridLayout = Instance.new("UIGridLayout")
				uiGridLayout.CellSize = UDim2.new(0.5, -5, 0, 76)
				uiGridLayout.CellPadding = UDim2.fromOffset(10, 10)
				uiGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
				uiGridLayout.Parent = parent2
			end

			UI.button({
				parent = parent2,
				size = UDim2.new(1, 0, 0, 76),
				style = "secondary",
				icon = "school",
				iconSize = 32,
				iconColor = Theme.green,
				text = "I don't know how to play",
				textSize = 18,
				subtext = "Learn the basics in a quick tutorial",
				align = Enum.HorizontalAlignment.Left,
				padX = compact and 12 or 16,
				gap = compact and 12 or 14,
				layoutOrder = 4,
				onClick = function()
					data.send({ type = "skill", level = "new", via = "tutorial" })
					close("Welcome")

					if data.openTutorial then
						data.openTutorial(true)
					end
				end
			})

			UI.button({
				parent = parent2,
				size = UDim2.new(1, 0, 0, 76),
				style = "secondary",
				icon = "pawn",
				iconSize = 32,
				iconColor = Theme.green,
				text = "I know how to play",
				textSize = 18,
				subtext = "Pick your level and start playing",
				align = Enum.HorizontalAlignment.Left,
				padX = compact and 12 or 16,
				gap = compact and 12 or 14,
				layoutOrder = 5,
				onClick = function()
					close("Welcome")
					v.skill({ known = true })
				end
			})
		end

		function v.skill(options)
			local v5 = options or {}

			local compact = data.compact == true
			local parent2 = openModal("Skill", compact and 660 or 400, { dismissable = false })
			data.send({ type = "fx", ev = "skillShown" })
			local list = UI.list(Enum.FillDirection.Vertical, 10)
			list.Parent = parent2
			local padded = UI.pad(22, 20, 18, 20)
			padded.Parent = parent2
			UI.text({
				Text = v5.known and "What's your chess level?" or "Welcome! What's your chess level?",
				FontFace = Theme.fontHeavy,
				TextSize = 22,
				TextWrapped = true,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				LayoutOrder = 1,
				Parent = parent2
			})

			UI.text({
				Text = "We'll use this to find you fair opponents.",
				TextSize = 15,
				TextColor3 = Theme.textDim,
				Size = UDim2.new(1, 0, 0, 20),
				LayoutOrder = 2,
				Parent = parent2
			})

			local function picked() -- 2 equivalent calls inferred from this helper
				close("Skill")

				if data.newFlow() and not (data.searching or data.joining or data.inLiveGame()) then
					data.startSearch(data.selectedTc)
				end
			end
			local v6 = { "pawn", "school", "trend", "crown" }
			local parent3

			if compact then
				parent3 = UI.new("Frame", {
					Name = "Levels",
					Size = UDim2.new(1, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					LayoutOrder = 3,
					Parent = parent2
				})

				local uiGridLayout = Instance.new("UIGridLayout")
				uiGridLayout.CellSize = UDim2.new(0.5, -5, 0, 62)
				uiGridLayout.CellPadding = UDim2.fromOffset(10, 10)
				uiGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
				uiGridLayout.Parent = parent3
			else
				parent3 = parent2
			end

			for k, v7 in Config.SKILL_LEVELS do
				if not v5.known or v7.id ~= "new" then
					UI.button({
						parent = parent3,
						size = UDim2.new(1, 0, 0, 62),
						style = "secondary",
						icon = v6[k],
						iconSize = compact and 26 or 28,
						iconColor = Theme.green,
						text = v7.label,
						textSize = 18,
						subtext = v7.sub,
						align = Enum.HorizontalAlignment.Left,
						padX = compact and 12 or 16,
						gap = compact and 12 or 14,
						layoutOrder = 2 + k,
						onClick = function()
							data.send({ type = "skill", level = v7.id })
							picked() -- inferred equivalent call
						end
					})
				end
			end

			UI.button({
				parent = parent2,
				size = UDim2.new(1, 0, 0, 34),
				style = "ghost",
				text = "Skip",
				textSize = 15,
				layoutOrder = 10,
				onClick = function()
					data.send({ type = "skill", level = "skip" })
					picked() -- inferred equivalent call
				end
			})

			if v5.known then
				UI.button({
					parent = parent2,
					size = UDim2.new(1, 0, 0, 30),
					style = "ghost",
					icon = "back",
					iconSize = 18,
					text = "Back",
					textSize = 14,
					layoutOrder = 11,
					onClick = function()
						close("Skill")
						v.welcome()
					end
				})
			end
		end

		function v.challenge(player)
			if data.inLiveGame() then
				data.toast("Finish your current game first")
				return
			end

			local parent2 = openModal("Challenge", 400, { scroll = true })
			local list = UI.list(Enum.FillDirection.Vertical, 12)
			list.Parent = parent2
			local padded = UI.pad(18, 20, 20, 20)
			padded.Parent = parent2
			closeButton(parent2, "Challenge")
			local frame = UI.new(
				"Frame",
				{
					Size = UDim2.new(1, 0, 0, 48),
					BackgroundTransparency = 1,
					LayoutOrder = 1,
					Parent = parent2
				},
				{ UI.list(
						Enum.FillDirection.Horizontal,
						12,
						Enum.HorizontalAlignment.Left,
						Enum.VerticalAlignment.Center
					) }
			)
			local avatar = UI.avatar({ userId = player.UserId }, 44, {
				LayoutOrder = 1,
				Parent = frame
			})
			local text = UI.text({
				Text = "Challenge " .. player.DisplayName,
				FontFace = Theme.fontHeavy,
				TextSize = 20,
				AutomaticSize = Enum.AutomaticSize.X,
				Size = UDim2.fromScale(0, 1),
				LayoutOrder = 2,
				Parent = frame
			})

			if data.openProfile then
				for _, parent3 in { avatar.frame, text } do
					local textButton = UI.new("TextButton", {
						Name = "Open",
						Text = "",
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(1, 1),
						ZIndex = 3,
						Parent = parent3
					})

					textButton:SetAttribute("Sfx", "press")
					textButton.Activated:Connect(function()
						data.openProfile(player.UserId, nil, {
							userId = player.UserId,
							display = player.DisplayName,
							name = player.Name
						})
					end)
				end
			end

			local tc = data.selectedTc
			local frame2 = UI.new("Frame", {
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				LayoutOrder = 2,
				Parent = parent2
			})

			local uiGridLayout = Instance.new("UIGridLayout")
			uiGridLayout.CellSize = UDim2.new(1 / 3, -6, 0, 40)
			uiGridLayout.CellPadding = UDim2.fromOffset(6, 6)
			uiGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
			uiGridLayout.Parent = frame2
			local v5 = {}
			local function refresh() -- 2 equivalent calls inferred from this helper
				for k, v6 in v5 do
					v6.stroke.Transparency = k == tc and 0 or 1
				end
			end

			for k, v6 in Config.TIME_CONTROLS do
				local textButton = UI.new(
					"TextButton",
					{ BackgroundColor3 = Theme.button, LayoutOrder = k, Parent = frame2 },
					{
						UI.corner(5),
						UI.list(
							Enum.FillDirection.Horizontal,
							5,
							Enum.HorizontalAlignment.Center,
							Enum.VerticalAlignment.Center
						)
					}
				)
				UI.icon(Config.CLASS_ICON[v6.class], 16, Config.CLASS_COLOR[v6.class], {
					LayoutOrder = 1,
					Parent = textButton
				})
				UI.text({
					Text = v6.label,
					FontFace = Theme.fontBold,
					TextSize = 15,
					AutomaticSize = Enum.AutomaticSize.X,
					Size = UDim2.fromScale(0, 1),
					LayoutOrder = 2,
					Parent = textButton
				})

				local stroke = UI.stroke(Theme.green, 2, 1)
				stroke.Parent = textButton
				v5[v6.id] = { stroke = stroke }
				textButton.Activated:Connect(function()
					tc = v6.id
					refresh() -- inferred equivalent call
				end)
			end

			refresh() -- inferred equivalent call
			local color = "random"
			local segmented = UI.segmented({
				{ id = "white", label = "White" },
				{ id = "random", label = "Random", icon = "shuffle" },
				{ id = "black", label = "Black" }
			}, color, function(p)
				color = p
			end, 40)
			segmented.frame.LayoutOrder = 3
			segmented.frame.Parent = parent2
			local rated = true
			local frame3 = UI.new("Frame", {
				Size = UDim2.new(1, 0, 0, 34),
				BackgroundTransparency = 1,
				LayoutOrder = 4,
				Parent = parent2
			})

			UI.text({
				Text = "Rated game",
				FontFace = Theme.fontMedium,
				TextSize = 16,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, -60, 1, 0),
				Parent = frame3
			})

			local v6 = UI.toggle(true, function(p)
				rated = p
			end)
			v6.frame.AnchorPoint = Vector2.new(1, 0.5)
			v6.frame.Position = UDim2.new(1, 0, 0.5, 0)
			v6.frame.Parent = frame3
			UI.button({
				parent = parent2,
				size = UDim2.new(1, 0, 0, 54),
				style = "primary",
				icon = "swords",
				text = "Send Challenge",
				textSize = 20,
				layoutOrder = 5,
				onClick = function()
					data.send({
						type = "challenge",
						target = player.UserId,
						name = player.DisplayName,
						tc = tc,
						color = color,
						rated = rated
					})

					if not Players:GetPlayerByUserId(player.UserId) then
						data.toast("Sending your challenge to " .. player.DisplayName .. "...")
					end

					close("Challenge")
				end
			})
		end

		function v.incomingChallenge(data2)
			v.challengeGone(data2.id)
			local v5 = Config.TC_BY_ID[data2.tc]
			local frame = UI.new("Frame", {
				Name = "Incoming",
				Size = UDim2.new(0, 340, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = Theme.panelHeader,
				Parent = data.toastLayer
			}, {
				UI.corner(10),
				UI.stroke(Theme.green, 2, 0.2),
				UI.pad(12, 12, 12, 12),
				UI.list(Enum.FillDirection.Vertical, 10)
			})
			local frame2 = UI.new("Frame", {
				Size = UDim2.new(1, 0, 0, 44),
				BackgroundTransparency = 1,
				LayoutOrder = 1,
				Parent = frame
			})

			UI.avatar({ userId = data2.from.userId }, 44, { Parent = frame2 })

			if data.openProfile and type(data2.from.userId) == "number" then
				local textButton = UI.new("TextButton", {
					Name = "Open",
					Text = "",
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
					ZIndex = 3,
					Parent = frame2
				})

				textButton:SetAttribute("Sfx", "press")
				textButton.Activated:Connect(function()
					data.openProfile(data2.from.userId, nil, {
						userId = data2.from.userId,
						display = data2.from.display
					})
				end)
			end

			UI.text({
				Text = string.format("%s (%d) challenges you!", data2.from.display, data2.from.rating or 0),
				FontFace = Theme.fontBold,
				TextSize = 15,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Size = UDim2.new(1, -54, 0, 22),
				Position = UDim2.fromOffset(54, 0),
				Parent = frame2
			})

			local v6 = data2.color == "white" and "Black" or data2.color == "black" and "White" or "Random colour"
			UI.text({
				Text = string.format(
					"%s · %s · You: %s",
					v5 and v5.label or "?",
					data2.rated and "Rated" or "Casual",
					v6
				),
				TextSize = 13,
				TextColor3 = Theme.textDim,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, -54, 0, 18),
				Position = UDim2.fromOffset(54, 24),
				Parent = frame2
			})

			local frame3 = UI.new(
				"Frame",
				{
					Size = UDim2.new(1, 0, 0, 40),
					BackgroundTransparency = 1,
					LayoutOrder = 2,
					Parent = frame
				},
				{ UI.list(Enum.FillDirection.Horizontal, 8) }
			)
			UI.button({
				parent = frame3,
				size = UDim2.new(0.5, -4, 1, 0),
				style = "primary",
				text = "Accept",
				textSize = 16,
				layoutOrder = 1,
				onClick = function()
					if data.inLiveGame() then
						data.toast("Finish your current game first")
						return
					end

					data.send({ type = "challengeResponse", id = data2.id, accept = true })
					v.challengeGone(data2.id)
				end
			})

			UI.button({
				parent = frame3,
				size = UDim2.new(0.5, -4, 1, 0),
				style = "secondary",
				text = "Decline",
				textSize = 16,
				layoutOrder = 2,
				onClick = function()
					data.send({ type = "challengeResponse", id = data2.id, accept = false })
					v.challengeGone(data2.id)
				end
			})

			local frame4 = UI.new(
				"Frame",
				{
					Size = UDim2.new(1, 0, 0, 4),
					BackgroundColor3 = Theme.button,
					LayoutOrder = 3,
					Parent = frame
				},
				{ UI.corner(2) }
			)
			local frame5 = UI.new(
				"Frame",
				{ Size = UDim2.fromScale(1, 1), BackgroundColor3 = Theme.green, Parent = frame4 },
				{ UI.corner(2) }
			)
			UI.tween(frame5, data2.ttl or 30, { Size = UDim2.fromScale(0, 1) }, Enum.EasingStyle.Linear)
			v3[data2.id] = frame
			UI.fadeIn(frame, UI.SNAP)
			task.delay((data2.ttl or 30) + 1, function()
				v.challengeGone(data2.id)
			end)
		end

		function v.challengeGone(p)
			local v5 = v3[p]

			if v5 then
				v3[p] = nil
				UI.fadeOut(v5, 0.12)
			end
		end

		return v
	end
}