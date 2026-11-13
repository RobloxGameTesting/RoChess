local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Theme = require(script.Parent.Theme)
local UI = require(script.Parent.UI)

local vector2s = {
	[Enum.KeyCode.DPadUp] = Vector2.new(0, -1),
	[Enum.KeyCode.DPadDown] = Vector2.new(0, 1),
	[Enum.KeyCode.DPadLeft] = Vector2.new(-1, 0),
	[Enum.KeyCode.DPadRight] = Vector2.new(1, 0)
}

local v = {
	Vector2.new(1, 0),
	Vector2.new(1, -1),
	Vector2.new(0, -1),
	Vector2.new(-1, -1),
	Vector2.new(-1, 0),
	Vector2.new(-1, 1),
	Vector2.new(0, 1),
	Vector2.new(1, 1)
}

local function isPad(p) -- 3 equivalent calls inferred from this helper
	return p and string.sub(p.Name, 1, 7) == "Gamepad"
end

local set = {
	[Enum.UserInputType.MouseButton1] = true,
	[Enum.UserInputType.MouseButton2] = true,
	[Enum.UserInputType.MouseMovement] = true,
	[Enum.UserInputType.MouseWheel] = true,
	[Enum.UserInputType.Touch] = true,
	[Enum.UserInputType.Keyboard] = true
}
return {
	install = function(self)
		local gamepad = {}
		self.gamepad = gamepad
		local gui = self.gui
		local board = self.board
		local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

		local active = false
		local focus = "ui"
		local wantBoard = true
		local v2 = nil
		local v3 = Enum.UserInputType.Gamepad1
		local v4 = {}
		local v5 = nil
		local v6 = 0
		local v7 = nil

		pcall(function()
			GuiService.AutoSelectGuiEnabled = false
		end)

		playerGui.SelectionImageObject = UI.new(
			"Frame",
			{
				Name = "ChessSelection",
				Size = UDim2.new(1, 6, 1, 6),
				Position = UDim2.fromOffset(-3, -3),
				BackgroundTransparency = 1
			},
			{ UI.corner(8), UI.stroke(Theme.green, 3, 0) }
		)

		local function shown(instance)
			if not (instance and instance.Parent) then
				return false
			end

			while instance and instance ~= gui do
				if instance:IsA("GuiObject") then
					if
						not instance.Visible
						or instance.Interactable == false
						or instance:IsA("CanvasGroup") and instance.GroupTransparency > 0.95
					then
						return false
					end
				end

				instance = instance.Parent
			end

			return instance == gui and gui.Enabled
		end

		local function usable(guiObject) -- 4 equivalent calls inferred from this helper
			local v8

			if guiObject == nil then
				return false
			end

			v8 = guiObject:IsA("GuiObject") and guiObject.Selectable

			if v8 then
				if guiObject.AbsoluteSize.X > 1 and guiObject.AbsoluteSize.Y > 1 then
					return shown(guiObject)
				end

				return false
			end

			return v8
		end

		local function inside(selectedObject, ancestor) -- 3 equivalent calls inferred from this helper
			return selectedObject ~= nil
				and ancestor ~= nil
				and (selectedObject == ancestor or selectedObject:IsDescendantOf(ancestor))
		end

		local v8 = { Close = true, Back = true, Settings = true }

		local function firstIn(folder)
			if not folder then
				return nil
			end

			local v9 = nil
			local v10 = nil
			local v11 = nil
			local v12 = nil
			local v13 = nil

			for _, guiObject in folder:GetDescendants() do
				if not (guiObject:IsA("GuiObject") and guiObject.Selectable and usable(guiObject)) then -- inferred equivalent call
					continue
				end

				local absolutePosition = guiObject.AbsolutePosition
				local v14 = math.floor(absolutePosition.Y / 8) * 100000 + absolutePosition.X

				if v8[guiObject.Name] then
					v9 = v9 or guiObject
				elseif guiObject.Name == "Face" then
					if not v12 or v14 < v13 then
						v13 = v14
						v12 = guiObject
					end
				elseif not v10 or v14 < v11 then
					v11 = v14
					v10 = guiObject
				end
			end

			return v12 or v10 or v9
		end

		local function aDown() -- 1 equivalent call inferred from this helper
			local success, result = pcall(function()
				return UserInputService:IsGamepadButtonDown(v3, Enum.KeyCode.ButtonA)
			end)

			return success and result
		end

		local function select(selectedObject) -- 6 equivalent calls inferred from this helper
			if selectedObject and GuiService.SelectedObject ~= selectedObject then
				GuiService.SelectedObject = selectedObject
			end
		end

		local function currentPage() -- 1 equivalent call inferred from this helper
			local pages = self.pages
			local v9 = pages and pages.current and pages[pages.current]
			return type(v9) == "table" and v9.frame or nil
		end

		local function defaultUi()
			local pages = self.pages
			local v9 = pages and pages.current and pages[pages.current]
			local v10

			if type(v9) == "table" then
				v10 = v9.frame or nil
			end

			return firstIn(v10) or firstIn(self.panel) or firstIn(self.root)
		end

		local function boardOk() -- 4 equivalent calls inferred from this helper
			return board.interactive and shown(board.frame)
		end

		local function lockGroup(instance)
			if instance and not instance:GetAttribute("PadLocked") then
				instance:SetAttribute("PadLocked", true)
				instance.SelectionGroup = true
				instance.SelectionBehaviorUp = Enum.SelectionBehavior.Stop
				instance.SelectionBehaviorDown = Enum.SelectionBehavior.Stop
				instance.SelectionBehaviorLeft = Enum.SelectionBehavior.Stop
				instance.SelectionBehaviorRight = Enum.SelectionBehavior.Stop
			end
		end

		local function defaultCursor() -- 3 equivalent calls inferred from this helper
			if board.selected then
				return board.selected
			end

			return if board.flipped then 53 else 13
		end

		local function ensureCursor() -- 2 equivalent calls inferred from this helper
			local cursor = board:ensureCursor()

			if not cursor.sq then
				board:setCursor(defaultCursor()) -- inferred equivalent call
			end

			return cursor
		end

		local function stepCursor(p) -- 4 equivalent calls inferred from this helper
			if not board:ensureCursor().sq then
				board:setCursor(defaultCursor()) -- inferred equivalent call
			end

			board:moveCursor(p.X, p.Y)
		end

		local function stickPos(p)
			local success, result = pcall(function()
				return UserInputService:GetGamepadState(v3)
			end)

			if success and result then
				for _, v9 in result do
					if v9.KeyCode == p then
						return Vector2.new(v9.Position.X, v9.Position.Y)
					end
				end
			end

			return Vector2.zero
		end

		local function heldDir()
			local total = Vector2.zero

			for k, v9 in vector2s do
				if v4[k] then
					total += v9
				end
			end

			if total.Magnitude > 0 then
				return Vector2.new(math.sign(total.X), (math.sign(total.Y)))
			end

			local v9 = stickPos(Enum.KeyCode.Thumbstick1)

			if v9.Magnitude < 0.55 then
				return nil
			end

			return v[math.round(math.atan2(v9.Y, v9.X) / 0.7853981633974483) % 8 + 1]
		end

		local frame = UI.new("Frame", {
			Name = "PadHints",
			Size = UDim2.fromOffset(0, 32),
			AutomaticSize = Enum.AutomaticSize.X,
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, -6),
			BackgroundColor3 = Theme.panelHeader,
			BackgroundTransparency = 0.08,
			Visible = false,
			ZIndex = 26,
			Parent = gui
		}, {
			UI.corner(16),
			UI.pad(0, 14, 0, 14),
			UI.list(Enum.FillDirection.Horizontal, 18, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center)
		})

		local hints = nil

		local v9 = {
			[Enum.KeyCode.ButtonA] = "A",
			[Enum.KeyCode.ButtonB] = "B",
			[Enum.KeyCode.ButtonX] = "X",
			[Enum.KeyCode.ButtonY] = "Y",
			[Enum.KeyCode.ButtonL1] = "LB",
			[Enum.KeyCode.ButtonR1] = "RB",
			[Enum.KeyCode.ButtonSelect] = "View"
		}

		local function glyph(p, frame2, k)
			local success, result = pcall(function()
				return UserInputService:GetImageForKeyCode(p)
			end)

			if success and type(result) == "string" and result ~= "" then
				UI.new("ImageLabel", {
					Name = "Glyph",
					Size = UDim2.fromOffset(22, 22),
					Image = result,
					ScaleType = Enum.ScaleType.Fit,
					LayoutOrder = k,
					ZIndex = 26,
					Parent = frame2
				})
				return
			end

			local frame3 = UI.new("Frame", {
				Name = "Glyph",
				Size = UDim2.fromOffset(0, 22),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundColor3 = Theme.button,
				LayoutOrder = k,
				ZIndex = 26,
				Parent = frame2
			}, { UI.corner(11), UI.pad(0, 7, 0, 7) })
			UI.text({
				Text = v9[p] or p.Name,
				FontFace = Theme.fontBold,
				TextSize = 13,
				Size = UDim2.fromScale(0, 1),
				AutomaticSize = Enum.AutomaticSize.X,
				ZIndex = 26,
				Parent = frame3
			})
		end

		local function setHints(items)
			local v10 = {}

			for _, item in items do
				local names = {}

				for _, v11 in item[1] do
					table.insert(names, v11.Name)
				end

				table.insert(v10, table.concat(names, "+") .. "=" .. item[2])
			end

			local joined = table.concat(v10, "|")

			if joined == hints then
				return
			end

			hints = joined

			for _, guiObject in frame:GetChildren() do
				if guiObject:IsA("GuiObject") then
					guiObject:Destroy()
				end
			end

			for k, item in items do
				local frame2 = UI.new("Frame", {
					Name = "Hint",
					Size = UDim2.fromScale(0, 1),
					AutomaticSize = Enum.AutomaticSize.X,
					BackgroundTransparency = 1,
					LayoutOrder = k,
					ZIndex = 26,
					Parent = frame
				}, { UI.list(
						Enum.FillDirection.Horizontal,
						5,
						Enum.HorizontalAlignment.Left,
						Enum.VerticalAlignment.Center
					) })

				for k2, v11 in item[1] do
					glyph(v11, frame2, k2)
				end

				UI.text({
					Text = item[2],
					FontFace = Theme.fontBold,
					TextSize = 15,
					TextColor3 = Theme.textSoft,
					Size = UDim2.fromScale(0, 1),
					AutomaticSize = Enum.AutomaticSize.X,
					LayoutOrder = 10,
					ZIndex = 26,
					Parent = frame2
				})
			end
		end

		local keyCode = Enum.KeyCode
		local function refreshHints()
			local session = self.session
			local v10

			if session == nil or session.ucis == nil then
				v10 = false
			else
				v10 = #session.ucis > 0
			end

			local v11 = {}

			if focus == "board" then
				table.insert(v11, {
					{ keyCode.ButtonA },
					board.selected and "Move" or "Pick up"
				})
				table.insert(v11, {
					{ keyCode.ButtonB },
					board.selected and "Cancel" or "Menu"
				})
				table.insert(v11, {
					{ keyCode.ButtonX },
					"Mark"
				})
				table.insert(v11, {
					{ keyCode.ButtonY },
					"Flip"
				})

				if v10 then
					table.insert(v11, {
						{ keyCode.ButtonL1, keyCode.ButtonR1 },
						"Moves"
					})
				end
			elseif focus == "promo" then
				table.insert(v11, {
					{ keyCode.ButtonA },
					"Promote"
				})
				table.insert(v11, {
					{ keyCode.ButtonB },
					"Cancel"
				})
			elseif focus == "modal" then
				table.insert(v11, {
					{ keyCode.ButtonA },
					"Choose"
				})
				local top = self.modals.top()

				if top and top.dismissable then
					table.insert(v11, {
						{ keyCode.ButtonB },
						"Close"
					})
				end
			else
				table.insert(v11, {
					{ keyCode.ButtonA },
					"Choose"
				})

				if boardOk() then -- inferred equivalent call
					table.insert(v11, {
						{ keyCode.ButtonB },
						"Board"
					})
				elseif self.pages and self.pages.current ~= "home" and not self.inLiveGame() then
					table.insert(v11, {
						{ keyCode.ButtonB },
						"Back"
					})
				end

				if session then
					table.insert(v11, {
						{ keyCode.ButtonY },
						"Flip"
					})
				end

				if v10 then
					table.insert(v11, {
						{ keyCode.ButtonL1, keyCode.ButtonR1 },
						"Moves"
					})
				end
			end

			setHints(v11)
		end

		local function setFocus(p) -- 1 equivalent call inferred from this helper
			if focus == p then
				return
			end

			focus = p

			if p ~= "board" then
				board:showCursor(false)

				return
			end

			GuiService.SelectedObject = nil

			if not board:ensureCursor().sq then
				board:setCursor(defaultCursor()) -- inferred equivalent call
			end

			board:showCursor(true)
		end

		local function setActive(visible) -- 5 equivalent calls inferred from this helper
			if active == visible then
				return
			end

			active = visible
			frame.Visible = visible
			hints = nil
			self.hintReserve = visible and 44 or 0

			if visible then
				focus = "none"
			else
				board:showCursor(false)
				GuiService.SelectedObject = nil
				table.clear(v4)
				v5 = nil
			end

			self.layout()
		end
		gamepad.setActive = setActive

		local function back()
			if focus == "promo" then
				local promoState = board.promoState

				if promoState and promoState.cancelPick then
					promoState.cancelPick()
				end
			elseif focus == "modal" then
				local top = self.modals.top()

				if top and top.dismissable then
					self.modals.close(top.name)
				end
			elseif focus == "board" then
				if board.selected then
					board:deselect()
				else
					wantBoard = false
				end
			else
				if self.profileBack and self.profileBack() then
					return
				end

				if boardOk() then -- inferred equivalent call
					wantBoard = true
				elseif self.pages and self.pages.current ~= "home" and not self.inLiveGame() then
					self.goHome()
				end
			end
		end

		local function onButton(keyCode2)
			local session = self.session

			if keyCode2 == keyCode.ButtonA then
				if focus == "board" then
					board:pressSquare(ensureCursor().sq) -- inferred equivalent call
				end
			elseif keyCode2 == keyCode.ButtonB then
				back()
			elseif keyCode2 == keyCode.ButtonX then
				if focus == "board" then
					board:toggleMark(ensureCursor().sq) -- inferred equivalent call
				end
			elseif keyCode2 == keyCode.ButtonY then
				if session and (focus == "board" or focus == "ui") then
					self.flip()
				end
			elseif keyCode2 == keyCode.ButtonL1 then
				if session then
					self.navigate(session.viewPly - 1)
				end
			elseif keyCode2 == keyCode.ButtonR1 then
				if session then
					self.navigate(session.viewPly + 1)
				end
			elseif keyCode2 == keyCode.ButtonL2 then
				if session then
					self.navigate(0)
				end
			elseif keyCode2 == keyCode.ButtonR2 then
				if session then
					self.navigate(#session.ucis)
				end
			elseif keyCode2 == keyCode.ButtonSelect then
				if focus == "board" then
					wantBoard = false
				elseif focus == "ui" and boardOk() then -- inferred equivalent call
					wantBoard = true
				end
			elseif vector2s[keyCode2] and focus == "board" then
				v4[keyCode2] = true
				local v10 = heldDir()

				if v10 then
					stepCursor(v10) -- inferred equivalent call
					v5 = v10
					v6 = os.clock() + 0.28
				end

				return
			end

			if vector2s[keyCode2] then
				v4[keyCode2] = true
			end
		end
		gamepad.press = onButton

		UserInputService.LastInputTypeChanged:Connect(function(p)
			if isPad(p) then -- inferred equivalent call
				v3 = p
				setActive(true) -- inferred equivalent call
			elseif set[p] then
				setActive(false) -- inferred equivalent call
			end
		end)

		UserInputService.InputBegan:Connect(function(input)
			if not isPad(input.UserInputType) then -- inferred equivalent call
				return
			end

			v3 = input.UserInputType
			setActive(true) -- inferred equivalent call

			if GuiService.MenuIsOpen or UserInputService:GetFocusedTextBox() then
				return
			end

			onButton(input.KeyCode)
		end)

		UserInputService.InputEnded:Connect(function(input)
			if vector2s[input.KeyCode] then
				v4[input.KeyCode] = nil
			end
		end)

		local function scrollTarget()
			local scrollingFrame = GuiService.SelectedObject

			while scrollingFrame and scrollingFrame ~= gui do
				if scrollingFrame:IsA("ScrollingFrame") then
					return scrollingFrame
				end

				scrollingFrame = scrollingFrame.Parent
			end

			local folder = currentPage() -- inferred equivalent call

			if folder then
				for _, scrollingFrame2 in folder:GetDescendants() do
					if scrollingFrame2:IsA("ScrollingFrame") and shown(scrollingFrame2) then
						return scrollingFrame2
					end
				end
			end

			return nil
		end

		local function step(p)
			if not active then
				return
			end

			local session = self.session

			if session ~= v2 then
				v2 = session

				if session then
					wantBoard = true
					local cursor = board:ensureCursor()
					cursor.sq = nil
				end
			end

			local promoState = board.promoState
			local v10 = self.modals and self.modals.top()
			setFocus(promoState and "promo" or v10 and "modal" or wantBoard and boardOk() and "board" or "ui") -- inferred equivalent call
			local selectedObject = GuiService.SelectedObject
			local v11 = aDown() -- inferred equivalent call

			if focus == "board" then
				if selectedObject then
					GuiService.SelectedObject = nil
				end

				local v12 = heldDir()

				if v12 then
					if v12 == v5 then
						local now = os.clock()

						if v6 <= now then
							stepCursor(v12) -- inferred equivalent call
							v6 = os.clock() + 0.085
						end
					else
						v5 = v12
						stepCursor(v12) -- inferred equivalent call
						v6 = os.clock() + 0.28
					end
				else
					v5 = nil
				end
			elseif not v11 then
				if focus == "promo" then
					lockGroup(promoState.column)

					if v7 == promoState then
						local v12 = inside(selectedObject, promoState.column) -- inferred equivalent call
						local v13

						if v12 then
							if not usable(selectedObject) then -- inferred equivalent call
								v13 = promoState.items[1] or firstIn(promoState.column)
								select(v13) -- inferred equivalent call
							end
						else
							v13 = promoState.items[1] or firstIn(promoState.column)
							select(v13) -- inferred equivalent call
						end
					else
						local item = promoState.items[1]

						if item and item.AbsoluteSize.X > 4 then
							v7 = promoState
							GuiService.SelectedObject = item
						elseif selectedObject then
							GuiService.SelectedObject = nil
						end
					end
				elseif focus == "modal" then
					lockGroup(v10.card)
					local v12 = inside(selectedObject, v10.card) -- inferred equivalent call
					local v13

					if v12 then
						if not usable(selectedObject) then -- inferred equivalent call
							v13 = firstIn(v10.card)
							select(v13) -- inferred equivalent call
						end
					else
						v13 = firstIn(v10.card)
						select(v13) -- inferred equivalent call
					end
				else
					local v12 = usable(selectedObject) -- inferred equivalent call
					local v13, pages, v14, frame2, v15

					if v12 then
						if inside(selectedObject, self.modalLayer) then -- inferred equivalent call
							v13 = firstIn
							pages = self.pages
							v14 = pages and pages.current and pages[pages.current]

							if type(v14) == "table" then
								frame2 = v14.frame or nil
							end

							v15 = v13(frame2) or firstIn(self.panel) or firstIn(self.root)
							select(v15) -- inferred equivalent call
						end
					else
						v13 = firstIn
						pages = self.pages
						v14 = pages and pages.current and pages[pages.current]

						if type(v14) == "table" then
							frame2 = v14.frame or nil
						end

						v15 = v13(frame2) or firstIn(self.panel) or firstIn(self.root)
						select(v15) -- inferred equivalent call
					end
				end
			end

			if focus ~= "board" then
				local v12 = stickPos(Enum.KeyCode.Thumbstick2)
				local v13 = math.abs(v12.Y) > 0.2 and scrollTarget()

				if v13 then
					local v14 = math.max(0, v13.AbsoluteCanvasSize.Y - v13.AbsoluteWindowSize.Y)
					local v15 = math.clamp(v13.CanvasPosition.Y - v12.Y * 1100 * p, 0, v14)
					v13.CanvasPosition = Vector2.new(v13.CanvasPosition.X, v15)
				end
			end

			refreshHints()
		end
		RunService.Heartbeat:Connect(function(dt)
			local success, result = pcall(step, dt)

			if not success then
				warn("[Chess] gamepad: " .. tostring(result))
			end
		end)

		function gamepad.state()
			local cursor = board.cursor
			local selectedObject = GuiService.SelectedObject
			return {
				active = active,
				focus = focus,
				wantBoard = wantBoard,
				cursor = cursor and cursor.sq,
				cursorShown = cursor and cursor.on or false,
				selectedSq = board.selected,
				selectedObject = selectedObject and selectedObject:GetFullName() or nil,
				hints = hints
			}
		end

		function gamepad.move(p, p2)
			if focus == "board" then
				stepCursor(Vector2.new(p, p2)) -- inferred equivalent call
			end
		end

		local lastInputType = UserInputService:GetLastInputType()

		if isPad(lastInputType) then -- inferred equivalent call
			v3 = lastInputType
			setActive(true) -- inferred equivalent call
		elseif
			GuiService:IsTenFootInterface()
			or UserInputService.GamepadEnabled
			and not (UserInputService.KeyboardEnabled or UserInputService.TouchEnabled)
		then
			setActive(true) -- inferred equivalent call
		end

		return gamepad
	end
}