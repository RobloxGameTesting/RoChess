local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Chess = ReplicatedStorage:WaitForChild("Chess")
local Engine = require(Chess.Engine)
require(Chess.Bot)
local VortexBot = require(Chess.VortexBot)
local Openings = require(Chess.Openings)
local parent = script.Parent
local Theme = require(parent.Theme)
local UI = require(parent.UI)
local Sound = require(parent.Sound)
local Session = require(parent.Session)
local MoveList = require(parent.MoveList)

local color = Color3.fromRGB(46, 196, 182)

local v = {
	stalemate = "Stalemate",
	insufficient = "Insufficient material",
	fifty = "50-move rule",
	repetition = "Threefold repetition"
}

local function validFen(value): boolean
	if type(value) ~= "string" or #value > 100 then
		return false
	end

	local v2 = string.split(value, " ")

	if #v2 < 2 or #string.split(v2[1], "/") ~= 8 then
		return false
	end

	local success, result = pcall(Engine.new, value)

	if not (success and result) then
		return false
	end

	local v3 = { [1] = 0, [-1] = 0 }

	for _, v4 in result:boardArray() do
		if v4 == 6 then
			v3[1] += 1
		elseif v4 == -6 then
			local v5 = -1
			v3[v5] += 1
		end
	end

	if v3[1] ~= 1 or v3[-1] ~= 1 then
		return false
	end

	local v4 = -result.side
	return not result:isAttacked(Engine.SQUARES[result:kingIndex64(v4)], result.side)
end

return {
	["validFen"] = validFen,
	install = function(self)
		local pages = self.pages

		local page = pages.newPage("analysis", "Analysis", "analysis", Theme.green, false)
		local analysis2 = { frame = page }
		pages.analysis = analysis2

		local frame = UI.new("Frame", {
			Name = "Engine",
			Size = UDim2.new(1, -16, 0, 66),
			Position = UDim2.fromOffset(8, 8),
			BackgroundColor3 = Theme.panelLight,
			Parent = page
		}, { UI.corner(8) })
		local frame2 = UI.new("Frame", {
			Name = "Eval",
			Size = UDim2.fromOffset(74, 42),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 10, 0.5, 0),
			BackgroundColor3 = Color3.new(1, 1, 1),
			Parent = frame
		}, { UI.corner(5) })
		local text = UI.text({
			Text = "0.00",
			FontFace = Theme.fontHeavy,
			TextSize = 20,
			TextColor3 = Theme.bg,
			Size = UDim2.fromScale(1, 1),
			Parent = frame2
		})

		local text2 = UI.text({
			Text = "",
			FontFace = Theme.fontBold,
			TextSize = 16,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Size = UDim2.new(1, -164, 0, 20),
			Position = UDim2.fromOffset(96, 12),
			Parent = frame
		})

		local text3 = UI.text({
			Text = "",
			TextSize = 13,
			TextColor3 = Theme.textDim,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, -164, 0, 16),
			Position = UDim2.fromOffset(96, 36),
			Parent = frame
		})

		local v2 = true
		local v3 = UI.toggle(true, function(p)
			v2 = p
			analysis2.lastKey = nil

			if self.session and self.session.kind == "analysis" then
				analysis2.onRender(self.session)
			end
		end)
		v3.frame.AnchorPoint = Vector2.new(1, 0)
		v3.frame.Position = UDim2.new(1, -12, 0, 12)
		v3.frame.Parent = frame
		UI.text({
			Text = "Engine",
			TextSize = 12,
			TextColor3 = Theme.textDim,
			Size = UDim2.fromOffset(52, 14),
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -7, 0, 40),
			Parent = frame
		})

		local text4 = UI.text({
			Name = "Opening",
			Text = "",
			FontFace = Theme.fontMedium,
			TextSize = 14,
			TextColor3 = Theme.textDim,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Size = UDim2.new(1, -24, 0, 22),
			Position = UDim2.fromOffset(12, 80),
			Parent = page
		})

		local frame3 = UI.new("Frame", {
			Name = "Moves",
			Size = UDim2.new(1, 0, 1, -250),
			Position = UDim2.fromOffset(0, 106),
			BackgroundTransparency = 1,
			Parent = page
		})

		local moveList = MoveList.new(frame3)
		moveList:setEmptyText("Move a piece to start analysing.")
		analysis2.moveList = moveList
		function moveList.onSelect(p)
			self.navigate(p)
		end

		local frame4 = UI.new("Frame", {
			Name = "Nav",
			Size = UDim2.new(1, -16, 0, 42),
			Position = UDim2.new(0, 8, 1, -140),
			BackgroundTransparency = 1,
			Parent = page
		}, { UI.list(Enum.FillDirection.Horizontal, 4, Enum.HorizontalAlignment.Center) })

		for k, v4 in {
			{
				"flip",
				function()
					self.flip()
				end
			},
			{
				"first",
				function()
					self.navigate(0)
				end
			},
			{
				"prev",
				function()
					if self.session then
						self.navigate(self.session.viewPly - 1)
					end
				end
			},
			{
				"next",
				function()
					if self.session then
						self.navigate(self.session.viewPly + 1)
					end
				end
			},
			{
				"last",
				function()
					if self.session then
						self.navigate(#self.session.ucis)
					end
				end
			}
		} do
			UI.button({
				parent = frame4,
				size = UDim2.new(0.2, -4, 1, 0),
				style = "flat",
				icon = v4[1],
				iconSize = 26,
				iconColor = Theme.textSoft,
				layoutOrder = k,
				onClick = v4[2]
			})
		end

		local frame5 = UI.new("Frame", {
			Name = "Actions",
			Size = UDim2.new(1, -16, 0, 42),
			Position = UDim2.new(0, 8, 1, -92),
			BackgroundTransparency = 1,
			Parent = page
		}, { UI.list(Enum.FillDirection.Horizontal, 6, Enum.HorizontalAlignment.Center) })
		local function syncList(data) -- 2 equivalent calls inferred from this helper
			moveList:setMoves(data.sans)
			moveList:setCurrent(data.viewPly, true)
			analysis2.listVersion = data.version
		end
		UI.button({
			parent = frame5,
			size = UDim2.new(1 / 3, -4, 1, 0),
			style = "secondary",
			icon = "undo",
			iconSize = 20,
			text = "Undo",
			textSize = 15,
			gap = 6,
			layoutOrder = 1,
			onClick = function()
				local session = self.session

				if session and session.kind == "analysis" and #session.ucis > 0 then
					session:undo()
					session.viewPly = math.min(session.viewPly, #session.ucis)
					syncList(session) -- inferred equivalent call
					self.render()
				end
			end
		})

		UI.button({
			parent = frame5,
			size = UDim2.new(1 / 3, -4, 1, 0),
			style = "secondary",
			icon = "replay",
			iconSize = 20,
			text = "Reset",
			textSize = 15,
			gap = 6,
			layoutOrder = 2,
			onClick = function()
				local session = self.session

				if session and session.kind == "analysis" then
					self.openAnalysis(session.baseFen, session.baseUcis, #session.baseUcis, {
						white = session.white,
						black = session.black,
						myColor = session.myColor
					})
				end
			end
		})

		UI.button({
			parent = frame5,
			size = UDim2.new(1 / 3, -4, 1, 0),
			style = "secondary",
			icon = "add",
			iconSize = 20,
			text = "New",
			textSize = 15,
			gap = 6,
			layoutOrder = 3,
			onClick = function()
				self.openAnalysis(nil, {}, 0)
			end
		})

		local textBox = UI.new("TextBox", {
			Name = "Fen",
			Size = UDim2.new(1, -16, 0, 32),
			Position = UDim2.new(0, 8, 1, -40),
			BackgroundColor3 = Theme.bgDark,
			FontFace = Font.fromEnum(Enum.Font.RobotoMono),
			TextSize = 12,
			TextColor3 = Theme.textSoft,
			PlaceholderText = "Paste a FEN and press Enter",
			PlaceholderColor3 = Theme.textMuted,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ClearTextOnFocus = false,
			Text = "",
			Parent = page
		}, { UI.corner(5), UI.pad(0, 8, 0, 8), UI.stroke(Theme.divider, 1, 0) })
		textBox.FocusLost:Connect(function(p)
			local session = self.session

			if p then
				local v4 = string.gsub(string.gsub(textBox.Text, "^%s+", ""), "%s+$", "")

				if validFen(v4) then
					self.openAnalysis(v4, {}, 0)
					self.toast("Position loaded")
				else
					self.toast("That FEN doesn't look valid", Theme.loss)

					if session and session.kind == "analysis" then
						textBox.Text = session:engineAt(session.viewPly):getFen()
					end
				end
			elseif session and session.kind == "analysis" then
				textBox.Text = session:engineAt(session.viewPly):getFen()
			end
		end)

		local function fitHeight()
			local v4 = page.AbsoluteSize.Y / (self.uiScale or 1)

			if v4 <= 0 then
				return
			end

			local visible = v4 >= 310
			local v5 = visible and 44 or 0
			local v6 = 100 + v5
			local visible2 = 106 + v6 + 40 <= v4
			local v7 = visible2 and 106 or 80
			textBox.Visible = visible
			text4.Visible = visible2
			frame3.Visible = v4 - v7 - v6 >= 24
			frame3.Position = UDim2.fromOffset(0, v7)
			frame3.Size = UDim2.new(1, 0, 1, -(v7 + v6))
			frame4.Position = UDim2.new(0, 8, 1, -v6 + 4)
			frame5.Position = UDim2.new(0, 8, 1, -(50 + v5) + 2)
		end
		page:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitHeight)
		task.defer(fitHeight)

		local count = 0

		local function showResult(object, viewPly, data)
			local board = self.board

			if data.terminal == "checkmate" then
				self.setEval(data.score, 0)
				text.Text = data.score > 0 and "1-0" or "0-1"
				text2.Text = "Checkmate"
				text3.Text = (data.score > 0 and "White" or "Black") .. " wins"
				board:setArrow("best", nil)
			elseif data.terminal then
				self.setEval(0)
				text.Text = "½-½"
				text2.Text = "Draw"
				text3.Text = v[data.terminal] or ""
				board:setArrow("best", nil)
			else
				self.setEval(data.score or 0, data.mate)

				if data.mate then
					text.Text = (data.mate > 0 and "+M" or "-M") .. tostring((math.abs(data.mate)))
				else
					text.Text = string.format("%+.2f", (data.score or 0) / 100)
				end

				local engineAt = object:engineAt(viewPly)
				local v4 = data.best and engineAt:moveFromUci(data.best)

				if v4 then
					text2.Text = "Best move: " .. engineAt:moveToSan(v4)
					board:setArrow(
						"best",
						Engine.algToIndex64((string.sub(data.best, 1, 2))),
						Engine.algToIndex64((string.sub(data.best, 3, 4))),
						color,
						0.2
					)
				else
					text2.Text = ""
					board:setArrow("best", nil)
				end

				text3.Text = "Depth " .. tostring(data.depth or 0)
			end

			local v4

			if data.mate and data.mate ~= 0 then
				v4 = data.mate > 0
			else
				v4 = (data.score or 0) >= 0
			end

			frame2.BackgroundColor3 = v4 and Color3.new(1, 1, 1) or Color3.fromRGB(40, 39, 37)
			text.TextColor3 = v4 and Theme.bg or Color3.new(1, 1, 1)
		end

		local function analyse(object)
			count += 1
			local v4 = count
			local viewPly = object.viewPly
			local function stale(): boolean -- 2 equivalent calls inferred from this helper
				return v4 ~= count or self.session ~= object
			end

			if v2 then
				text3.Text = "Analysing..."

				self.board:setArrow("best", nil)
				text2.Text = ""
				local v5 = table.move(object.ucis, 1, viewPly, 1, {})
				task.delay(0.1, function()
					if stale() then -- inferred equivalent call
						return
					end

					for _, v6 in { 0.35, 1.6 } do
						local analyse2 = VortexBot.analyse(object.startFen, v5, v6, 22, {
							cancelled = stale
						})

						if stale() then -- inferred equivalent call
							break
						end

						showResult(object, viewPly, analyse2)

						if analyse2.terminal or analyse2.mate then
							break
						end
					end
				end)
			else
				self.setEval(nil)
				self.board:setArrow("best", nil)
				text.Text = "--"
				frame2.BackgroundColor3 = Theme.button
				text.TextColor3 = Theme.textDim
				text2.Text = "Engine off"
				text3.Text = ""
			end
		end

		function analysis2.onRender(object)
			if analysis2.listVersion == object.version and analysis2.listSession == object then
				moveList:setCurrent(object.viewPly)
			else
				analysis2.listSession = object
				syncList(object) -- inferred equivalent call
			end

			if not textBox:IsFocused() then
				textBox.Text = object:engineAt(object.viewPly):getFen()
			end

			text4.Text = Openings.forSession(object, object.viewPly)
				or object.viewPly == 0
				and (object.startFen == nil or object.startFen == Engine.START_FEN)
				and "Starting position"
				or ""
			local lastKey = tostring(object.version) .. ":" .. tostring(object.viewPly)

			if analysis2.lastKey ~= lastKey or analysis2.lastSession ~= object then
				analysis2.lastKey = lastKey
				analysis2.lastSession = object
				analyse(object)
			end
		end

		local onRender = self.onRender
		function self.onRender(p)
			if onRender then
				onRender(p)
			end

			if p and p.kind == "analysis" then
				analysis2.onRender(p)
			end
		end

		function self.analysisMove(p, p2, p3, p4): boolean
			local session = self.session
			local viewPly = session.viewPly
			local moveAt = session:findMoveAt(viewPly, p, p2, p3)

			if not moveAt then
				Sound.play("illegal")
				return false
			end

			local v4 = session:engineAt(viewPly):moveToUci(moveAt)
			local instant = p4 and { [p2] = true } or nil

			if viewPly < #session.ucis and session.ucis[viewPly + 1] == v4 then
				session.viewPly = viewPly + 1
				self.render({ instant = instant })
				Sound.forMove(session.flags[viewPly + 1])
				return true
			else
				session:truncate(viewPly)
				local viewPly2 = session:applyUci(v4)

				if not viewPly2 then
					return false
				end

				session.viewPly = viewPly2
				self.render({ instant = instant })
				Sound.forMove(session.flags[viewPly2])
				return true
			end
		end

		function self.openAnalysis(baseFen, options, p, options2)
			if self.inLiveGame() then
				return
			end

			if self.searching then
				self.cancelSearch()
			end

			self.modals.closeAll()
			local v4 = options2 or {}
			local analysis = Session.new("analysis", {
				startFen = baseFen,
				ucis = options or {},
				white = v4.white or { display = "White" },
				black = v4.black or { display = "Black" },
				myColor = v4.myColor
			})

			analysis.baseFen = baseFen
			analysis.baseUcis = table.clone(analysis.ucis)
			analysis.viewPly = math.clamp(p or #analysis.ucis, 0, #analysis.ucis)
			analysis2.lastKey = nil
			self.setSession(analysis)
			pages.show("analysis")
		end

		function self.analyseCurrent()
			local session = self.session

			if not session then
				return self.openAnalysis(nil, {}, 0)
			end

			self.openAnalysis(session.startFen, table.clone(session.ucis), session.viewPly, {
				white = session.white,
				black = session.black,
				myColor = session.myColor
			})
		end

		local Debug = self.debug
		function self.debug(data)
			local session = self.session

			if data.type == "openAnalysis" then
				self.openAnalysis(data.fen, data.ucis or {}, data.ply)
				return true
			end

			if data.type == "analyseCurrent" then
				self.analyseCurrent()
				return true
			end

			if data.type == "analysisState" then
				return {
					kind = session and session.kind,
					line = session and table.concat(session.sans, " "),
					viewPly = session and session.viewPly,
					eval = text.Text,
					best = text2.Text,
					depth = text3.Text,
					fen = textBox.Text,
					page = pages.current
				}
			end

			if data.type ~= "loadFen" then
				return Debug(data)
			end

			textBox.Text = data.fen

			if not validFen(data.fen) then
				return false
			end

			self.openAnalysis(data.fen, {}, 0)
			return true
		end
	end
}