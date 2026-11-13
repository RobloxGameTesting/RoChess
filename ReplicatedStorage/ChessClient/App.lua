local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Chess = ReplicatedStorage:WaitForChild("Chess")
local Config = require(Chess.Config)
local Engine = require(Chess.Engine)
local Bot = require(Chess.Bot)
local VortexBot = require(Chess.VortexBot)
local Openings = require(Chess.Openings)
local Levels = require(Chess.Levels)

local parent = script.Parent
local Theme = require(parent.Theme)
local UI = require(parent.UI)
local Sound = require(parent.Sound)
local Haptics = require(parent.Haptics)
local BoardView = require(parent.BoardView)
local PlayerBar = require(parent.PlayerBar)
local Session = require(parent.Session)
local Music = require(parent.Music)

local App = {}

local LocalPlayer = Players.LocalPlayer
local v = nil

App.player = LocalPlayer
App.Haptics = Haptics
App.settings = table.clone(Config.DEFAULT_SETTINGS)
App.profile = nil
App.session = nil
App.searching = nil

App.joining = nil
App.selectedTc = Config.DEFAULT_TC
App.selectedBot = "jasper"
App.botColor = "white"
App.flipOverride = false
App.premove = nil

local function serverNow() -- 5 equivalent calls inferred from this helper
	return workspace:GetServerTimeNow()
end

App.serverNow = serverNow

local v2 = nil
local v3 = nil
local function onFocus(p) -- 1 equivalent call inferred from this helper
	if p then
		v2 = serverNow() -- inferred equivalent call
	else
		v3 = serverNow() -- inferred equivalent call
	end
end
UserInputService.WindowFocusReleased:Connect(function()
	v2 = serverNow() -- inferred equivalent call
end)
UserInputService.WindowFocused:Connect(function()
	onFocus() -- inferred equivalent call
end)
App._focusEvent = onFocus

local function focusFlag(turnStart): number -- 1 equivalent call inferred from this helper
	if type(turnStart) ~= "number" then
		return 0
	end

	if v2 and turnStart <= v2 then
		return 1
	end

	return if v3 and turnStart <= v3 then 2 else 0
end

App._focusFlag = focusFlag

function App.send(p)
	if v then
		v.Action:FireServer(p)
	end
end

function App.request(p)
	if not v then
		return nil
	end

	local success, result = pcall(function()
		return v.Request:InvokeServer(p)
	end)

	return success and result or nil
end

function App.newFlow(): boolean
	return not App.profile or App.profile.flow ~= "FlowA"
end

function App.myInfo(p)
	local r

	if App.profile and p then
		local rating = App.profile.ratings[p]
		r = rating and rating.r
	end

	local xp = App.profile and tonumber(App.profile.xp)
	return {
		userId = LocalPlayer.UserId,
		name = LocalPlayer.Name,
		display = LocalPlayer.DisplayName,
		rating = r,
		prov = App.profile and p and App.profile.ratings[p] and App.profile.ratings[p].prov,
		lvl = xp and Levels.of(xp) or nil,
		vip = App.isVip() or nil,
		lbTag = App.profile and App.profile.lbTag or nil
	}
end

function App.isVip(): boolean
	return App.profile ~= nil and App.profile.vip == true
end

function App.build()
	pcall(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
	end)

	task.spawn(function()
		for _ = 1, 40 do
			if pcall(StarterGui.SetCore, StarterGui, "ChatActive", false) then
				break
			end

			task.wait(0.25)
		end
	end)

	local screenGui = UI.new("ScreenGui", {
		Name = "ChessUI",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = LocalPlayer:WaitForChild("PlayerGui")
	})

	App.gui = screenGui
	App.bgFrame = UI.new("Frame", {
		Name = "Background",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme.bg,
		ZIndex = 0,
		Parent = screenGui
	})

	App.root = UI.new("Frame", {
		Name = "Root",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 1,
		Parent = screenGui
	})

	App.board = BoardView.new(App.root, App.settings)
	App.topBar = PlayerBar.new(App.root)
	App.bottomBar = PlayerBar.new(App.root)

	local function relayout()
		if App.layout then
			App.layout()
		end
	end
	App.topBar.onRows = relayout
	App.bottomBar.onRows = relayout

	App.evalBar = UI.new(
		"Frame",
		{
			Name = "EvalBar",
			BackgroundColor3 = Color3.fromRGB(41, 43, 47),
			Visible = false,
			Parent = App.root
		},
		{ UI.corner(3) }
	)
	App.evalFill = UI.new("Frame", {
		Name = "White",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.fromScale(1, 0.5),
		BackgroundColor3 = Color3.fromRGB(240, 240, 240),
		Parent = App.evalBar
	}, { UI.corner(3) })
	App.evalText = UI.text({
		Name = "Score",
		Size = UDim2.new(1, 0, 0, 16),
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, -2),
		FontFace = Theme.fontBold,
		TextSize = 10,
		TextColor3 = Theme.bg,
		ZIndex = 2,
		Parent = App.evalBar
	})

	App.side = UI.new("Frame", { Name = "Side", BackgroundTransparency = 1, Parent = App.root })

	App.panel = UI.new("Frame", {
		Name = "Panel",
		BackgroundColor3 = Theme.panel,
		BackgroundTransparency = Theme.glass or 0.12,
		ClipsDescendants = true,
		Parent = App.side
	}, { UI.corner(Theme.radius or 14) })

	App.rightCard = UI.new("Frame", {
		Name = "RightCard",
		BackgroundColor3 = Theme.panel,
		BackgroundTransparency = Theme.glass or 0.12,
		ClipsDescendants = false,
		Visible = false,
		Parent = App.root
	}, { UI.corner(Theme.radius or 14) })
	App.panelScale = Instance.new("UIScale")
	App.panelScale.Parent = App.panel

	UI.depth(App.panel, Theme.paneTop)
	UI.depth(App.rightCard, Theme.paneTop)
	UI.shadow(App.panel, App.root, 14)
	UI.shadow(App.rightCard, App.root, 14)
	UI.shadow(App.board.frame, App.root, 14)

	App.modalLayer = UI.new("Frame", {
		Name = "Modals",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 20,
		Parent = screenGui
	})

	App.toastLayer = UI.new("Frame", {
		Name = "Toasts",
		Size = UDim2.new(0, 360, 1, 0),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 0),
		BackgroundTransparency = 1,
		ZIndex = 30,
		Parent = screenGui
	}, { UI.list(Enum.FillDirection.Vertical, 8, Enum.HorizontalAlignment.Center) })
	App.toastPad = UI.pad(60, 0, 0, 0)
	App.toastPad.Parent = App.toastLayer

	local board = App.board
	function board.getTargets(p)
		local session = App.session

		if session and session.kind == "analysis" then
			return session:targetsAt(session.viewPly, p)
		end

		return session and session:targets(p) or {}
	end

	function board.onMove(p, p2, p3, p4)
		return App.onBoardMove(p, p2, p3, p4)
	end

	function board.onPremove(premove)
		App.premove = premove
	end

	App.Nav = require(parent.Nav)
	App.nav = App.Nav.build(App)
	App.Pages = require(parent.Pages)
	App.Modals = require(parent.Modals)
	App.pages = App.Pages.build(App)
	App.modals = App.Modals.build(App)
	App.Review = require(parent.Review)
	App.Review.install(App)
	App.Puzzle = require(parent.Puzzle)
	App.Puzzle.install(App)
	App.Analysis = require(parent.Analysis)
	App.Analysis.install(App)

	App.Tutorial = require(parent.Tutorial)
	App.Tutorial.install(App)

	App.Learn = require(parent.Learn)
	App.Learn.install(App)

	if Config.TOURNAMENTS_ENABLED then
		App.Tournament = require(parent.Tournament)
		App.Tournament.install(App)
	end

	App.Profile = require(parent.Profile)
	App.Profile.install(App)
	App.Donate = require(parent.Donate)
	App.Donate.install(App)
	App.Tasks = require(parent.Tasks)
	App.Tasks.install(App)
	App.Cosmetics = require(parent.Cosmetics)
	App.Shop = require(parent.Shop)
	App.Shop.install(App)
	App.Levels = require(parent.Levels)
	App.Levels.install(App)
	App.QuickChat = require(parent.QuickChat)
	App.QuickChat.install(App)
	App.Codes = require(parent.Codes)
	App.Codes.install(App)
	App.Vip = require(parent.Vip)
	App.Vip.install(App)

	App.Gifts = require(parent.Gifts)
	App.Gifts.install(App)

	App.Admin = require(parent.Admin)
	App.Admin.install(App)
	App.Gamepad = require(parent.Gamepad)
	App.Gamepad.install(App)

	screenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(App.layout)

	pcall(function()
		GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(App.layout)
	end)

	for _, duration in { 0.5, 2, 5 } do
		task.delay(duration, App.layout)
	end

	App.resetIdle()
	App.layout()
	App.pages.show("home")
end

App.FULL_PAGES = { shop = true }
function App.fullPage(): boolean
	local pages = App.pages
	return pages ~= nil
		and App.FULL_PAGES[pages.current] == true
		and not App.inLiveGame()
		and pages.docked ~= pages.current
end

function App.refreshFull()
	local pages = App.pages

	if pages and App.inLiveGame() and App.FULL_PAGES[pages.current] then
		pages.docked = pages.current
	end

	if App.gui and App.fullPage() ~= (App.isFull == true) then
		App.layout()
	end
end

function App.layout()
	local gui = App.gui
	local absoluteSize = gui.AbsoluteSize
	local x = absoluteSize.X
	local y = absoluteSize.Y

	if x < 50 or y < 50 then
		return
	end

	local y2 = GuiService:GetGuiInset().Y
	local v4 = y < 520 and 6 or 12

	local hintReserve = App.hintReserve or 0
	local portrait = x < y * 1.05

	local compact = not portrait and y < 480
	App.compact = compact
	App.portrait = portrait
	local v5 = y < 620 and 12 or 16

	local left = x
	local right = x

	if y2 > 0 then
		local success, result = pcall(function()
			return GuiService.TopbarInset
		end)

		if success and result and result.Width > 0 then
			local x2 = gui.AbsolutePosition.X
			left = result.Min.X - x2 + 8
			right = result.Max.X - x2
		end
	end

	local function topFor(p, p2) -- 2 equivalent calls inferred from this helper
		if y2 <= 0 or left <= p and p2 <= right then
			return v4
		end

		return y2 + v4
	end

	App.topbar = { inset = y2, left = left, right = right }

	local v6 = not App.nav and 0 or App.nav.layout(not (portrait or compact), x, y)

	local fullPage = App.fullPage()
	local isFull = App.isFull == true
	App.isFull = fullPage

	if fullPage ~= isFull then
		App.board.frame.Visible = not fullPage

		App.topBar.frame.Visible = not fullPage
		App.bottomBar.frame.Visible = not fullPage

		if App.modals and App.modals.setBoardHidden then
			App.modals.setBoardHidden(fullPage)
		end
	end

	local visible

	if App.evalBar:GetAttribute("Wanted") == true then
		visible = not fullPage
	else
		visible = false
	end

	local v7 = visible and (compact and 18 or 20) or 0
	local v8 = visible and 6 or 0

	if fullPage then
		local v9 = math.max(y2, v6) + v4
		local v10 = x - v4
		local v11 = math.max(120, y - v9 - v4 - hintReserve)
		local v12 = math.clamp(math.floor(x * 0.28), 300, 420)
		App.side.Position = UDim2.fromOffset(v4, v9)
		App.side.Size = UDim2.fromOffset(v10 - v4, v11)
		App.layoutPanel(v10 - v4, v11, 0, (v10 - v4) * 330 / v12)
		App.rightCard.Visible = false
		App.rightCardWanted = false
		App.topBar:setClockOut(nil)
		App.bottomBar:setClockOut(nil)
		local Game = App.pages and App.pages.game

		if Game and Game.dockMoves then
			Game.dockMoves(nil)
		end
	elseif portrait then
		local v9 = y2 + v4
		local v10 = y - v9 - v4 - hintReserve
		local v11 = math.clamp(math.floor(x * 0.09), 34, 46)
		local v12 = math.max(
			160,
			math.floor(math.min(x - 2 * v4 - v7 - v8, math.floor(v10 * 0.62) - (v11 + 4) * 2) / 8) * 8
		)
		local v13 = math.floor((x - v12 - v7 - v8) / 2) + v7 + v8
		App.topBar.frame.Parent = App.root
		App.bottomBar.frame.Parent = App.root
		App.topBar.frame.Position = UDim2.fromOffset(v13, v9)
		App.topBar:layout(v12, v11)
		App.board.frame.Position = UDim2.fromOffset(v13, v9 + v11 + 4)
		App.board.frame.Size = UDim2.fromOffset(v12, v12)
		App.bottomBar.frame.Position = UDim2.fromOffset(v13, v9 + v11 + 4 + v12 + 4)
		App.bottomBar:layout(v12, v11)
		local v14 = v9 + (v11 + 4) * 2 + v12 + v5
		local v15 = math.max(120, y - v14 - v4 - hintReserve)
		App.side.Position = UDim2.fromOffset(v4, v14)
		App.side.Size = UDim2.fromOffset(x - 2 * v4, v15)
		App.layoutPanel(x - 2 * v4, v15, 0)
		App.evalBar.Position = UDim2.fromOffset(v13 - v7 - v8, v9 + v11 + 4)
		App.evalBar.Size = UDim2.fromOffset(v7, v12)
	elseif compact then
		local function place(p)
			local v9 = math.max(
				160,
				math.floor(math.min(y - p - v4 - hintReserve, x - 2 * v4 - 280 - v5 - v7 - v8) / 8) * 8
			)
			local v10 = math.min(460, x - 2 * v4 - v5 - v7 - v8 - v9)
			local v11 = v10 + v5 + v7 + v8 + v9
			local v12 = v4 + math.max(0, (math.floor((x - 2 * v4 - v11) / 2)))
			return v9, v10, v12, v12 + v10 + v5 + v7 + v8
		end

		local v9, v10, v11, v12 = place(v4)
		local v13 = topFor(v12, v12 + v9) -- inferred equivalent call

		if v4 < v13 then
			v9, v10, v11, v12 = place(v13)
		end

		local v14 = v13 + math.max(0, (math.floor((y - v13 - v4 - hintReserve - v9) / 2)))
		App.board.frame.Position = UDim2.fromOffset(v12, v14)
		App.board.frame.Size = UDim2.fromOffset(v9, v9)
		App.evalBar.Position = UDim2.fromOffset(v12 - v7 - v8, v14)
		App.evalBar.Size = UDim2.fromOffset(v7, v9)
		local v15 = topFor(v11, v11 + v10) -- inferred equivalent call
		local v16 = y - v15 - v4 - hintReserve
		local v17 = math.clamp(math.floor(v16 * 0.13), 32, 42)
		App.side.Position = UDim2.fromOffset(v11, v15)
		App.side.Size = UDim2.fromOffset(v10, v16)
		App.topBar.frame.Parent = App.side
		App.bottomBar.frame.Parent = App.side
		App.topBar.frame.Position = UDim2.fromOffset(0, 0)
		App.topBar:layout(v10, v17)
		App.bottomBar.frame.Position = UDim2.fromOffset(0, v16 - v17)
		App.bottomBar:layout(v10, v17)
		App.layoutPanel(v10, v16 - (v17 + 6) * 2, v17 + 6)
	else
		local v9 = math.max(y2, v6) + v4
		local v10 = y - v9 - v4 - hintReserve

		local v11 = v5 + 12

		local v12 = math.clamp(math.floor(x * 0.25), 330, 380)
		local v13 = math.clamp(math.floor(x * 0.19), 256, 300)
		local v14 = math.max(160, math.floor(math.min(v10, x - 2 * v4 - v12 - v13 - 2 * v11 - v7 - v8) / 8) * 8)
		local v15 = v12 + v11 + v7 + v8 + v14 + v11 + v13
		local v16 = v4 + math.max(0, (math.floor((x - 2 * v4 - v15) / 2)))
		local v17 = v16 + v12 + v11 + v7 + v8
		local v18 = v9 + math.max(0, (math.floor((v10 - v14) / 2)))
		App.board.frame.Position = UDim2.fromOffset(v17, v18)
		App.board.frame.Size = UDim2.fromOffset(v14, v14)
		App.evalBar.Position = UDim2.fromOffset(v17 - v7 - v8, v18)
		App.evalBar.Size = UDim2.fromOffset(v7, v14)

		App.side.Position = UDim2.fromOffset(v16, v18)
		App.side.Size = UDim2.fromOffset(v12, v14)

		App.layoutPanel(v12, v14, 0, 330)

		local v19 = v17 + v14 + v11
		local v20 = math.clamp(math.floor(v14 * 0.075), 36, 48)
		local v21 = math.min(v13, (math.floor(v20 * 3.3)))

		local v22 = (App.topBar.clockVisible or App.bottomBar.clockVisible or App.topBar.reportBtn.Visible or App.bottomBar.reportBtn.Visible)
			and v20 + 10
			or 0
		local v23 = v18 + v22
		local v24 = v14 - 2 * v22
		local rightCard = App.rightCard
		App.rightCardWanted = true

		rightCard.Visible = App.side.Visible
		rightCard.Position = UDim2.fromOffset(v19, v23)
		rightCard.Size = UDim2.fromOffset(v13, v24)

		local v25 = math.clamp(math.floor(v24 * 0.12), 46, 58)
		App.topBar:setCard(false)
		App.bottomBar:setCard(false)
		App.topBar.frame.Parent = rightCard
		App.bottomBar.frame.Parent = rightCard
		App.topBar:setClockOut(App.root)
		App.bottomBar:setClockOut(App.root)
		App.topBar.frame.Position = UDim2.fromOffset(12, 12)
		App.topBar:layout(v13 - 24, v25)
		App.bottomBar.frame.Position = UDim2.fromOffset(12, v24 - 12 - v25)
		App.bottomBar:layout(v13 - 24, v25)

		local function placeRow(object, p)
			local reportWidth = object:reportWidth(v20)
			local v26 = object.clockVisible and v21 or 0
			local v27 = reportWidth + (reportWidth > 0 and v26 > 0 and 8 or 0) + v26
			local v28 = v19 + math.floor((v13 - v27) / 2)
			object:placeReport(v28, p, v20)
			object:placeClock(v28 + v27 - v26, p, v21, v20)
		end
		placeRow(App.topBar, v18)
		placeRow(App.bottomBar, v18 + v14 - v20)

		local Game = App.pages and App.pages.game

		if Game and Game.dockMoves then
			local v26 = v25 + 12 + 10
			Game.dockMoves(rightCard, UDim2.fromOffset(0, v26), UDim2.new(1, 0, 0, (math.max(40, v24 - v26 * 2))))
		end
	end

	if portrait or compact then
		App.topBar:setCard(false)
		App.bottomBar:setCard(false)
		App.topBar:setClockOut(nil)
		App.bottomBar:setClockOut(nil)
		App.rightCard.Visible = false
		App.rightCardWanted = false
		local Game = App.pages and App.pages.game

		if Game and Game.dockMoves then
			Game.dockMoves(nil)
		end
	end

	App.evalBar.Visible = visible
	App.boardRect = { pos = App.board.frame.AbsolutePosition, size = App.board.frame.AbsoluteSize }

	if App.pages and App.pages.onLayout then
		App.pages.onLayout()
	end

	if App.modals and App.modals.relayout then
		App.modals.relayout()
	end
end

function App.layoutPanel(p, p2, p3, value)
	local v4 = GuiService:IsTenFootInterface() and 1.45 or 1.2
	local v5

	if App.portrait or App.compact then
		local v6 = App.isFull and App.compact and 300 or App.compact and 220 or 270
		v5 = math.clamp(math.min(p / 360, p2 / v6), 0.78, 1.05)
	else
		v5 = math.clamp(math.min(p / (value or 360), p2 / 420), 0.78, v4)
	end

	App.panelScale.Scale = v5
	App.panel.Position = UDim2.fromOffset(0, p3)
	App.panel.Size = UDim2.fromOffset(p / v5, p2 / v5)
	App.uiScale = v5
end

function App.toast(text, p, value)
	local frame = UI.new("Frame", {
		Name = "Toast",
		Size = UDim2.new(0, 0, 0, 40),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = Theme.panelHeader,
		Parent = App.toastLayer
	}, { UI.corner(8), UI.pad(0, 16, 0, 16), UI.stroke(p or Theme.divider, 1, 0.2) })
	UI.text({
		Text = text,
		FontFace = Theme.fontBold,
		TextSize = 16,
		TextColor3 = Theme.text,
		Size = UDim2.fromScale(0, 1),
		AutomaticSize = Enum.AutomaticSize.X,
		Parent = frame
	})

	frame.BackgroundTransparency = 0.05
	Sound.play("toast")
	UI.pop(frame, 0.8, UI.POP)
	UI.fadeIn(frame, UI.SNAP)
	task.delay(value or 2.6, function()
		if frame.Parent then
			UI.fadeOut(frame, 0.18)
		end
	end)
	return frame
end

function App.bottomColor()
	local session = App.session

	local myColor = session and (session.myColor or session.viewColor) or 1

	if App.flipOverride then
		myColor = -myColor
	end

	return myColor
end

function App.refreshBars()
	local session = App.session

	if not session then
		return
	end

	local bottomColor = App.bottomColor()
	local material, v4, v5 = session:material(session.viewPly)
	local v6

	if session.kind == "puzzle" or session.kind == "rush" then
		v6 = true
	elseif session.startFen == nil then
		v6 = false
	else
		v6 = session.startFen ~= Engine.START_FEN
	end

	local function fill(object, p)
		local white = p == 1 and session.white or session.black
		object:setPlayer(white)

		if v6 then
			object:setCaptured({}, 0)
		else
			object:setCaptured(p == 1 and material or v4, p == 1 and math.max(0, v5) or math.max(0, -v5))
		end

		object:showClock(session.clocks ~= nil)

		local userId = white and white.userId

		if
			App.openProfile
			and white
			and not white.bot
			and type(userId) == "number"
			and userId ~= 0
			and (session.kind == "online" or session.kind == "review" or session.kind == "watch" or userId == LocalPlayer.UserId)
		then
			object:setOpen(function()
				App.openProfile(userId, nil, white)
			end)
		else
			object:setOpen(nil)
		end

		if session.kind ~= "online" or not session.id or not session.myColor or p == session.myColor then
			object:setReport(nil)

			return
		end

		local id = session.id
		local display = white and (white.display or white.name or "your opponent") or "your opponent"
		object:setReport(function()
			App.modals.confirm("Report " .. display .. " for cheating?", "Report", function()
				App.reportGame(id)
			end)
		end, App.reportedGames and App.reportedGames[id])
	end
	fill(App.bottomBar, bottomColor)
	fill(App.topBar, -bottomColor)
	App.barColor = {
		[App.bottomBar] = bottomColor,
		[App.topBar] = -bottomColor
	}
	App.board:setFlipped(bottomColor == -1)
	App.updateClocks()
end

function App.render(options)
	local v4 = options or {}
	local session = App.session

	if not session then
		return
	end

	local viewPly = session.viewPly
	local board = App.board
	App.refreshBars()
	board:setLoadouts(App.loadoutFor(session, 1), App.loadoutFor(session, -1))
	board:setPosition(session.positions[viewPly], session.lastMoves[viewPly], {
		animate = v4.animate ~= false,
		instant = v4.instant
	})
	board:setCheck(session.checks[viewPly])
	local v5 = viewPly == #session.ucis
	local v6 = session.kind == "online"
		or session.kind == "bot"
		or session.kind == "puzzle"
		or session.kind == "rush"
		or session.kind == "tutorial"
	local v7 = session.kind == "analysis"
	local v8 = v7 or v5 and not session.over and v6 and session.myColor ~= nil

	board:setMovable(v7 and 2 or session.myColor or 0)
	board:setTurn(v7 and session:sideAt(viewPly) or session.engine.side)
	board:setInteractive(v8 and true or false)

	if not v8 and App.premove then
		App.premove = nil
		board:setPremove(nil)
	end

	if App.pages and App.pages.game then
		App.pages.game.setCurrent(viewPly)
		App.pages.game.setOpening(Openings.forSession(session, viewPly))
	end

	if App.onRender then
		App.onRender(session)
	end
end

function App.myLoadout()
	local eq = App.cos and App.cos.eq

	if eq then
		return { pieces = eq.pieces, accessory = eq.accessory, effect = eq.effect }
	end

	return nil
end

function App.loadoutFor(data, p)
	local v4 = App.myLoadout() or {}
	local white = p == 1 and data.white or data.black
	local v5

	if white and white.cos then
		v5 = white.cos
	else
		v5 = (p ~= (data.myColor or 1) or data.othersGame) and {} or v4
	end

	return { pieces = v4.pieces, accessory = v5.accessory, effect = v5.effect }
end

function App.moveEffect(object, p)
	local flag = object.flags[p]

	if not flag then
		return
	end

	local v4

	if flag.san == nil then
		v4 = false
	else
		v4 = string.find(flag.san, "#", 1, true) ~= nil
	end

	if not (flag.capture or v4) then
		return
	end

	local loadoutFor = App.loadoutFor(object, object:sideAt(p - 1))
	local effect = loadoutFor and loadoutFor.effect

	if not effect then
		return
	end

	if v4 and object.checks[p] then
		if App.board:playEffect(object.checks[p], effect, true) then
			App.mateEffectAt = os.clock()
		end
	elseif object.lastMoves[p] then
		App.board:playEffect(object.lastMoves[p].to, effect, false)
	end
end

function App.afterMateEffect(callback)
	if not (App.mateEffectAt and os.clock() - App.mateEffectAt < 0.8) then
		callback()

		return
	end

	App.mateEffectAt = nil
	local session = App.session
	task.delay(1.3, function()
		if App.session == session then
			callback()
		end
	end)
end

function App.applyCosmetics()
	local eq = App.cos and App.cos.eq or {}

	if App.bgFrame and App.bgFrame:GetAttribute("Bg") ~= eq.background then
		App.bgFrame:SetAttribute("Bg", eq.background)
		App.Cosmetics.applyBackground(App.bgFrame, eq.background)

		local children = {}

		for _, child in App.root:GetChildren() do
			if not (child.Name == "Nav" or child.Name == "Side" or child.Name == "RightCard" or child.Name == "Wide" or child.Name == "Clock") then
				continue
			end

			table.insert(children, child)
		end

		App.Cosmetics.tintUI(children, eq.background)
	end

	local session = App.session

	if session then
		App.board:setLoadouts(App.loadoutFor(session, 1), App.loadoutFor(session, -1))
	end
end

function App.setSession(session)
	local session2 = App.session

	if session2 and session2 ~= session and session2.kind == "watch" and (not session or session.kind ~= "watch") then
		App.send({ type = "unwatch" })
	end

	if session2 and session2 ~= session then
		session2.cancelled = true

		if App.modals then
			App.modals.close("GameOver", true)
		end
	end

	App.session = session
	App.premove = nil
	App.board:setPremove(nil)
	App.board:clearAnnotations()
	App.board:setArrow("hint", nil)
	App.board:setArrow("best", nil)
	App.board:setMoveBadge(nil)
	App.board:clearTints()
	App.flipOverride = false
	App.lowTimeWarned = false
	App.setEval(nil)
	App.topBar:setStatus("")
	App.bottomBar:setStatus("")

	if App.pages and App.pages.game then
		App.pages.game.load(session)
	end

	App.render({ animate = false })
	App.refreshFull()
end

function App.navigate(value)
	local session = App.session

	if not session then
		return
	end

	local viewPly = math.clamp(value, 0, #session.ucis)

	if viewPly == session.viewPly then
		return
	end

	local animate = math.abs(viewPly - session.viewPly) == 1
	local v4 = session.viewPly < viewPly
	session.viewPly = viewPly
	App.render({ animate = animate })

	if animate and v4 and session.flags[viewPly] then
		Sound.forMove(session.flags[viewPly])
	end
end

function App.flip()
	App.flipOverride = not App.flipOverride
	App.render({ animate = false })

	local lastEval = App.lastEval

	if lastEval and App.evalBar:GetAttribute("Wanted") then
		App.setEval(lastEval.score, lastEval.mate)
	end
end

function App.setEval(score, mate)
	App.lastEval = score ~= nil and ({ score = score, mate = mate } or nil) or nil

	if score == nil then
		App.evalBar:SetAttribute("Wanted", false)

		if App.evalBar.Visible then
			App.layout()
		end
	else
		if not App.evalBar:GetAttribute("Wanted") then
			App.evalBar:SetAttribute("Wanted", true)
			App.layout()
		end

		local v4, text

		if mate == 0 then
			mate = score > 0 and 1 or -1
			v4 = mate > 0 and 1 or 0
			text = mate > 0 and "1-0" or "0-1"
		elseif mate then
			v4 = mate > 0 and 1 or 0
			text = "M" .. math.abs(mate)
		else
			v4 = math.clamp(1 / (math.exp(-0.00368208 * score) + 1), 0.04, 0.96)
			text = string.format("%.1f", math.abs(score) / 100)
		end

		local v5 = App.bottomColor() == -1
		App.evalFill.AnchorPoint = v5 and Vector2.new(0, 0) or Vector2.new(0, 1)
		App.evalFill.Position = v5 and UDim2.fromScale(0, 0) or UDim2.fromScale(0, 1)
		UI.tween(App.evalFill, 0.28, { Size = UDim2.fromScale(1, v4) }, Enum.EasingStyle.Quart)
		local v6 = mate and mate > 0 and true or not mate and score >= 0
		App.evalText.Text = text
		App.evalText.TextColor3 = v6 and Theme.bg or Color3.fromRGB(230, 230, 230)
		local v7

		if v6 then
			v7 = not v5 or not v6 and v5
		else
			v7 = not v6 and v5
		end

		if App.evalText:GetAttribute("AtBottom") ~= v7 then
			App.evalText:SetAttribute("AtBottom", v7)
			App.evalText.AnchorPoint = v7 and Vector2.new(0, 1) or Vector2.new(0, 0)
			App.evalText.Position = v7 and UDim2.new(0, 0, 1, -2) or UDim2.new(0, 0, 0, 2)
			UI.textIn(App.evalText, 0.15)
		end
	end
end

local v4 = {}
function App.updateClocks()
	local session = App.session

	if not session then
		return
	end

	local v5 = serverNow() -- inferred equivalent call
	local topBar = App.topBar
	local bottomBar = App.bottomBar
	v4[1] = topBar
	v4[2] = bottomBar

	for _, v6 in v4 do
		local v7 = App.barColor and App.barColor[v6]

		if not (v7 and session.clocks) then
			continue
		end

		local clockFor = session:clockFor(v7, v5)
		local v8 = not session.over

		if v8 then
			if session.engine.side == v7 then
				v8 = session.kind ~= "idle"
			else
				v8 = false
			end
		end

		v6:setClock(clockFor, v8, v7, session.tc and session.tc.base)

		if not (v8 and v7 == session.myColor and clockFor < 10000 and #session.ucis >= 2) then
			continue
		end

		if App.lowTimeWarned or not session.tc or not (session.tc.base >= 60) then
			continue
		end

		App.lowTimeWarned = true
		Sound.play("lowtime")
	end

	local v6

	if session.kind == "online" then
		v6 = not session.over

		if v6 then
			if #session.ucis < 2 then
				v6 = session.deadline ~= nil
			else
				v6 = false
			end
		end
	else
		v6 = false
	end

	if v6 then
		local v7 = math.max(0, (math.ceil(session.deadline - v5)))
		local side = session.engine.side

		for _, v8 in v4 do
			if App.barColor[v8] == side then
				v8:setStatus(tostring(v7) .. "s to move", Theme.gold)
			elseif not App.disconnectDeadline then
				v8:setStatus("")
			end
		end

		App.firstMoveShown = true
	elseif App.firstMoveShown then
		App.firstMoveShown = nil

		if not App.disconnectDeadline then
			App.topBar:setStatus("")
			App.bottomBar:setStatus("")
		end
	end

	if App.disconnectDeadline and session.kind == "online" and not session.over then
		local v7 = math.max(0, (math.ceil(App.disconnectDeadline - v5)));
		(App.barColor[App.topBar] == -(session.myColor or 1) and App.topBar or App.bottomBar):setStatus(
			"Disconnected " .. v7 .. "s",
			Theme.loss
		)
	end
end

local object = setmetatable({}, { __mode = "k" })

local count = 0
UserInputService.InputBegan:Connect(function()
	count += 1
end)

local v5 = nil
local v6 = {
	game = nil,
	e = {},
	a = {},
	ne = 0,
	na = 0,
	d = 0,
	m = 0
}
local v7 = 0

local function fenKey(value)
	local v8 = string.split(value, " ")
	return table.concat({
		v8[1] or "",
		v8[2] or "",
		v8[3] or "",
		v8[4] or ""
	}, " ")
end

local function liveTurn() -- 2 equivalent calls inferred from this helper
	local v8 = v5

	if v8 and not v8.over and object[v8] and #v8.ucis >= 10 and v8:isMyTurn() then
		return v8
	end

	return nil
end

local function tripPly(p, p2)
	if v6.game ~= p2.id then
		v6.game = p2.id
		v6.e = {}
		v6.a = {}
		v6.ne = 0
		v6.na = 0
	end

	local count2 = #p2.ucis

	if not v6[p][count2] then
		v6[p][count2] = true
		local v8 = v6
		local v9 = "n" .. p
		v8[v9] += 1
	end
end

local function tripCode(session) -- 2 equivalent calls inferred from this helper
	local v8, v9

	if v6.game == session.id then
		v8 = v6.ne
		v9 = v6.na
	else
		v8 = 0
		v9 = 0
	end

	return math.min(v8, 63) + math.min(v9, 63) * 64 + math.min(v6.d, 63) * 4096 + math.min(v6.m, 63) * 262144
end

function Bot.onSearch(object2)
	local v8 = liveTurn() -- inferred equivalent call

	if v8 and fenKey(object2:getFen()) == fenKey(v8.engine:getFen()) then
		tripPly("e", v8)
	end
end

local function watchArrows(board) -- 1 equivalent call inferred from this helper
	local setArrow = board.setArrow
	function board:setArrow(value, p, p2, ...)
		if p and p2 and (type(value) ~= "string" or string.sub(value, 1, 1) ~= "u") then
			local v8 = liveTurn() -- inferred equivalent call
			local v9

			if v8 then
				if App.session == v8 then
					v9 = self.position and self.position[p]
				else
					v9 = false
				end
			else
				v9 = v8
			end

			if type(v9) == "number" and math.sign(v9) == v8.myColor then
				tripPly("a", v8)
			end
		end

		return setArrow(self, value, p, p2, ...)
	end
end

local function ownMove(p, p2, p3) -- 2 equivalent calls inferred from this helper
	v7 += 1
	local success, result = xpcall(App.onBoardMove, debug.traceback, p, p2, p3, false)
	v7 -= 1

	if not success then
		error(result, 0)
	end

	return result
end

local function packMove(k, c, value, count2, count3)
	local function sqv(p) -- 2 equivalent calls inferred from this helper
		return string.byte(value, 1 + 2 * p) - 97 + (tonumber((string.sub(value, 2 + 2 * p, 2 + 2 * p))) - 1) * 8
	end

	local v8 = { f = sqv(0), t = sqv(1), p = math.clamp(count3, 0, 63) } -- inferred equivalent call
	local v9 = {
		v8[string.sub(c.o, 1, 1)],
		v8[string.sub(c.o, 2, 2)],
		v8[string.sub(c.o, 3, 3)],
		nil
	}

	local v10 = string.sub(value, 5, 5)

	if v10 ~= "" then
		v9[4] = 63 + string.find("qrbn", v10, 1, true)
	end

	local v11 = {}

	for k2, v12 in v9 do
		local v13 = (v12 + count2 * c.s + (k2 - 1) * 13) % #k
		v11[k2] = string.sub(k, v13 + 1, v13 + 1)
	end

	return table.concat(v11)
end

local function sendUci(value): boolean
	local session = App.session

	if not session or session.kind ~= "online" or type(value) ~= "string" then
		return false
	end

	App.send({
		type = "move",
		id = session.id,
		uci = string.lower(value),
		ply = #session.ucis
	})
	return true
end

App.playMove = sendUci
App.submitMove = sendUci
function App.makeMove(value, value2, p)
	if type(value) ~= "number" or type(value2) ~= "number" then
		return sendUci(tostring(value) .. tostring(value2 or "") .. tostring(p or ""))
	end

	local function alg(value3) -- 2 equivalent calls inferred from this helper
		return string.char(97 + (value3 - 1) % 8) .. tostring(8 - (value3 - 1) // 8)
	end

	return sendUci(alg(value) .. alg(value2) .. (({ [5] = "q", [4] = "r", [3] = "b", [2] = "n" })[p or 0] or "")) -- inferred equivalent call
end

function App.onBoardMove(p, p2, p3, p4)
	local session = App.session

	if session and session == v5 and not session.over and v7 == 0 and not BoardView.fromInput() then
		v6.m += 1
	end

	if session and session.kind == "analysis" and App.analysisMove then
		return App.analysisMove(p, p2, p3, p4)
	end

	if not session or session.over or session.viewPly ~= #session.ucis or not session:isMyTurn() then
		return false
	end

	if (session.kind == "puzzle" or session.kind == "rush") and App.puzzleMove then
		return App.puzzleMove(p, p2, p3, p4)
	end

	if session.kind == "tutorial" and App.tutorialMove then
		return App.tutorialMove(p, p2, p3, p4)
	end

	if session.kind ~= "online" and session.kind ~= "bot" then
		return false
	end

	local move = session:findMove(p, p2, p3)

	if not move then
		Sound.play("illegal")
		return false
	end

	local count2 = #session.ucis
	local turnStart = serverNow() -- inferred equivalent call
	local bl

	if session.kind == "online" then
		bl = focusFlag(session.turnStart) or nil -- inferred equivalent call
	end

	if session.kind == "online" and session.clocks and count2 >= 2 then
		session.clocks[session.myColor] = math.max(
			0,
			session.clocks[session.myColor] - (turnStart - session.turnStart) * 1000
		) + (session.tc and session.tc.inc or 0) * 1000
	end

	session.turnStart = turnStart
	local v8 = session:applyMove(move)

	if session.kind == "online" then
		local v9 = object[session]

		if v9 then
			local v10 = { type = v9.c.t, id = session.id, ply = count2, bl = bl }
			v10[v9.c.f] = packMove(v9.k, v9.c, session.ucis[v8], count2, count)
			count = 0
			local cs = tripCode(session) -- inferred equivalent call

			if cs > 0 then
				v10.cs = cs
			end

			App.send(v10)
		else
			App.send({ type = "sync" })
		end
	elseif session.kind == "bot" then
		session.myMoves = (session.myMoves or 0) + 1
		local myMoves = session.myMoves

		if myMoves == 1 or myMoves == 3 or myMoves == 5 or myMoves == 10 or myMoves == 20 then
			App.send({ type = "fx", ev = "botMove", n = myMoves })
		end
	end

	App.board:setArrow("hint", nil)
	App.afterMove(v8, {
		mine = true,
		instant = p4 and { [p2] = true } or nil
	})
	return true
end

function App.afterMove(viewPly, options)
	local v8 = options or {}
	local session = App.session
	local mine = v8.mine or session.viewPly == viewPly - 1
	App.pages.game.push(session.sans[viewPly])

	if mine then
		session.viewPly = viewPly
		App.render({ instant = v8.instant })
		local success, result = pcall(App.moveEffect, session, viewPly)

		if not success then
			warn("[Chess] move effect failed: " .. tostring(result))
		end
	else
		App.refreshBars()
		App.pages.game.setCurrent(session.viewPly)
	end

	Sound.forMove(session.flags[viewPly])
	App.pages.game.refresh()

	if session.kind == "bot" then
		local status = session:status()

		if status ~= "ongoing" then
			App.endLocalGame(status)
			return
		end
	end

	if App.premove and session:isMyTurn() and not session.over then
		local shiftPremove = App.board:shiftPremove()
		task.defer(function()
			if App.session ~= session then
				return
			end

			if not session:isMyTurn() or session.viewPly ~= #session.ucis or session.over then
				App.board:clearPremove()
			elseif not session:findMove(shiftPremove.from, shiftPremove.to, shiftPremove.promo) then
				App.board:clearPremove()
			elseif not ownMove(shiftPremove.from, shiftPremove.to, shiftPremove.promo) then -- inferred equivalent call
				App.board:clearPremove()
			end
		end)
	elseif session.kind == "bot" and not (session.over or session:isMyTurn()) then
		App.botTurn()
	end
end

local function showSearching(selectedTc)
	App.selectedTc = selectedTc
	App.searching = { tc = selectedTc, since = os.clock() }
	App.joining = nil
	App.setSession(Session.new("idle", {
		white = App.myInfo(Config.TC_BY_ID[selectedTc].class),
		black = { display = "Searching..." },
		myColor = 1,
		tc = selectedTc
	}))

	App.pages.show("home")
	App.pages.home.refresh()
end

function App.startSearch(tc)
	if not Config.TC_BY_ID[tc] then
		tc = Config.TC_BY_ID[App.selectedTc] and App.selectedTc or Config.DEFAULT_TC
	end

	if
		App.session and (App.session.kind == "online" or App.session.kind == "bot") and not App.session.over
		or App.joining
	then
		return
	end

	App.send({ type = "queue", tc = tc })
	showSearching(tc)
end

local function showPairing(data)
	local v8 = Config.TC_BY_ID[data.tc]
	local myInfo = App.myInfo(v8 and v8.class)
	local opponent = data.opponent or {}
	local v9 = {
		userId = opponent.userId,
		display = opponent.display or "Opponent",
		rating = opponent.rating
	}
	local myColor = data.color == -1 and -1 or 1
	App.setSession(Session.new("idle", {
		white = myColor == 1 and myInfo or v9,
		black = myColor == 1 and v9 or myInfo,
		myColor = myColor,
		tc = v8 and data.tc or nil
	}))
end

local function buildTeleportScreen(text, value)
	local screenGui = UI.new("ScreenGui", {
		Name = "ChessTeleport",
		IgnoreGuiInset = true,
		DisplayOrder = 100
	})

	local frame = UI.new("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme.bg,
		BorderSizePixel = 0,
		Parent = screenGui
	})

	UI.new("TextLabel", {
		Text = "RoChess!",
		FontFace = Theme.fontHeavy,
		TextSize = 22,
		TextColor3 = Theme.green,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 0.5, -44),
		Size = UDim2.new(1, 0, 0, 28),
		Parent = frame
	})

	UI.new("TextLabel", {
		Text = text,
		FontFace = Theme.fontHeavy,
		TextSize = 34,
		TextColor3 = Theme.text,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, -12),
		Size = UDim2.new(1, -40, 0, 42),
		Parent = frame
	})

	UI.new("TextLabel", {
		Text = value or "",
		FontFace = Theme.fontMedium,
		TextSize = 18,
		TextColor3 = Theme.textDim,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0.5, 18),
		Size = UDim2.new(1, -40, 0, 24),
		Parent = frame
	})

	return screenGui
end

function App.setTeleportScreen(text, p)
	local success, result = pcall(function()
		TeleportService:SetTeleportGui(buildTeleportScreen(text, p))
	end)

	if not success then
		warn("[Chess] teleport screen: " .. tostring(result))
	end
end

local function opponentLine(p) -- 1 equivalent call inferred from this helper
	local opponent = p and p.opponent

	if opponent and opponent.display then
		return "vs " .. opponent.display .. (opponent.rating and string.format(" (%d)", opponent.rating) or "")
	end

	return ""
end

App.opponentLine = opponentLine

local function watchJoining(p, duration) -- 3 equivalent calls inferred from this helper
	task.delay(duration, function()
		if App.joining == p then
			App.joining = nil
			App.toast("Couldn't start the game", Theme.loss)

			if App.session and App.session.kind == "idle" then
				App.resetIdle()
			end

			App.pages.home.refresh()
		end
	end)
end

function App.cancelSearch()
	if App.searching then
		App.searching = nil
		App.send({ type = "cancelQueue" })
		App.pages.home.refresh()
		App.resetIdle()
	end
end

function App.resetIdle()
	App.setSession(Session.new("idle", {
		white = App.myInfo(Config.TC_BY_ID[App.selectedTc].class),
		black = { display = "Opponent" },
		myColor = 1
	}))
end

function App.inLiveGame(): boolean
	local session = App.session
	return session ~= nil and (session.kind == "online" or session.kind == "bot") and not session.over
end

local handlers = {}
App.handlers = handlers

function handlers.profile(profile)
	local v8 = App.profile == nil

	if v8 then
		App.send({ type = "fx", ev = "loaded" })
	end

	App.profile = profile

	if profile.settings then
		for k, setting in profile.settings do
			App.settings[k] = setting
		end

		App.applySettings()
	end

	App.pages.home.refresh()
	App.pages.refreshAll()

	if v8 then
		Music.init()
	end

	local session = App.session

	if session and session.kind == "idle" then
		local myInfo = App.myInfo(Config.TC_BY_ID[App.selectedTc].class)

		if session.myColor == 1 then
			session.white = myInfo
		else
			session.black = myInfo
		end

		App.refreshBars()
	end

	if v8 and not profile.skillSet and (profile.games or 0) == 0 then
		if Config.ONB_WELCOME then
			App.modals.welcome()
		else
			App.modals.skill()
		end
	end
end

function handlers.queue(p)
	if p.searching then
		if not Config.TC_BY_ID[p.tc] or App.searching and App.searching.tc == p.tc then
			return
		end

		local session = App.session

		if not session or session.kind == "idle" then
			showSearching(p.tc)
			return
		end

		App.joining = nil
		App.searching = { tc = p.tc, since = os.clock() }
		App.pages.home.refresh()
	elseif App.searching then
		App.searching = nil

		if App.session and App.session.kind == "idle" then
			App.resetIdle()
		end

		App.pages.home.refresh()
	end
end

function handlers.matchFound(data)
	App.searching = nil
	App.pendingChallenge = nil
	local joining = {
		phase = "found",
		opponent = data.opponent or {},
		tc = data.tc,
		color = data.color,
		since = os.clock()
	}
	App.joining = joining
	App.modals.closeAll()

	if not App.inLiveGame() then
		showPairing(joining)
		App.pages.show("home")
	end

	App.pages.home.refresh()

	if not data.stay then
		App.setTeleportScreen("Joining your game", opponentLine(joining)) -- inferred equivalent call
	end

	Sound.play("notify")
	Sound.play("transition")
	watchJoining(joining, 120) -- inferred equivalent call
end

function handlers.serverMove(_)
	App.setTeleportScreen("Moving you to an updated server", "Finding you a game...")
	App.toast("RoChess was updated! Moving you to a new server...", Theme.green, 3)
end

function handlers.rejoining()
	App.searching = nil
	local joining = { phase = "rejoin", since = os.clock() }
	App.joining = joining
	App.pages.home.refresh()
	App.setTeleportScreen("Reconnecting to your game", "")
	watchJoining(joining, 90) -- inferred equivalent call
end

function handlers.rejoinFailed()
	if App.joining and App.joining.phase == "rejoin" then
		App.joining = nil
		App.pages.home.refresh()
	end
end

function handlers.joinFailed()
	if App.joining then
		App.joining = nil

		if App.session and App.session.kind == "idle" and App.resetIdle then
			App.resetIdle()
		end

		App.pages.home.refresh()
	end
end

function handlers.gameStart(data)
	local v8 = App.session and App.session.id == data.id
	App.searching = nil
	App.joining = nil
	App.pendingChallenge = nil
	App.modals.closeAll()
	local online = Session.new("online", {
		id = data.id,
		ucis = data.moves,
		white = data.white,
		black = data.black,
		myColor = data.color,
		tc = data.tc,
		clocks = data.clocks,
		turnStart = data.turnStart,
		deadline = data.deadline,
		rated = data.rated,
		class = data.class
	})

	if type(data.ck) == "string" and type(data.cc) == "table" then
		object[online] = { k = data.ck, c = data.cc }
	end

	v5 = online
	App.disconnectDeadline = nil
	App.setSession(online)
	App.pages.show("game")
	App.pages.home.refresh()

	if data.drawOffer and data.drawOffer == -data.color then
		App.pages.game.showDrawOffer(true)
	end

	if not v8 then
		Sound.play("start")
	end
end

function handlers.move(data)
	local session = App.session

	if not session or session.kind ~= "online" or session.id ~= data.id then
		return
	end

	local function syncClocks() -- 2 equivalent calls inferred from this helper
		if session.clocks and data.clocks then
			session.clocks[1] = data.clocks.w
			session.clocks[-1] = data.clocks.b
		end

		session.turnStart = data.turnStart
		session.deadline = data.deadline
	end

	if data.drawCleared then
		App.pages.game.showDrawOffer(false)
	end

	if data.ply == #session.ucis and session.ucis[data.ply] == data.uci then
		syncClocks() -- inferred equivalent call
	else
		if data.ply ~= #session.ucis + 1 then
			App.send({ type = "sync" })
			return
		end

		local v8 = session:applyUci(data.uci)

		if not v8 then
			App.send({ type = "sync" })
			return
		end

		syncClocks() -- inferred equivalent call
		App.afterMove(v8, {})
	end
end

function handlers.gameEnd(data)
	local session = App.session

	if not session or session.kind ~= "online" or session.id ~= data.id then
		return
	end

	session.over = true
	session.result = data.result
	session.reason = data.reason

	if session.clocks and data.clocks then
		session.clocks[1] = data.clocks.w
		session.clocks[-1] = data.clocks.b
	end

	App.disconnectDeadline = nil
	App.topBar:setStatus("")
	App.bottomBar:setStatus("")
	App.render({ animate = false })
	App.pages.game.showDrawOffer(false)
	App.pages.game.refresh()
	Sound.play("finish")
	local ratings = data.ratings
	local mine = ratings and ratings[session.myColor == 1 and "w" or "b"]
	local theirs = ratings and ratings[session.myColor == 1 and "b" or "w"]

	if mine then
		(session.myColor == 1 and session.white or session.black).rating = mine.new
	end

	if theirs then
		(session.myColor == 1 and session.black or session.white).rating = theirs.new
	end

	if mine or theirs then
		App.refreshBars()
	end

	if
		data.result ~= "*"
		or data.abortedBy == nil
		or data.abortedBy ~= -session.myColor
		or not (App.newFlow() and session.tc)
	then
		App.afterMateEffect(function()
			App.modals.gameOver({
				session = session,
				result = data.result,
				reason = data.reason,
				mine = mine,
				theirs = theirs
			})
		end)
		return
	end

	App.toast("Your opponent didn't move. Finding you a new game...", nil, 4)
	App.newGame()
end

function handlers.drawOffer(p)
	local session = App.session

	if session and session.id == p.id and not session.over then
		App.pages.game.showDrawOffer(true)
		Sound.play("notify")
	end
end

function handlers.drawSent()
	App.toast("Draw offer sent")
end

function handlers.drawDeclined(p)
	local session = App.session
	App.pages.game.showDrawOffer(false)

	if session and p.by ~= session.myColor then
		App.toast("Draw declined")
	end
end

function handlers.rematchOffer(p)
	local session = App.session

	if session and session.id == p.id then
		App.modals.rematchOffered()
		App.pages.game.rematchOffered()
		Sound.play("notify")
	end
end

function handlers.rematchSent()
	App.toast("Rematch offer sent")
end

function handlers.rematchDeclined()
	App.toast("Rematch declined")
	App.pages.game.refresh()
end

function handlers.opponentStatus(data)
	local session = App.session

	if not session or session.id ~= data.id then
		return
	end

	if data.connected then
		App.disconnectDeadline = nil
		App.topBar:setStatus("")
		App.bottomBar:setStatus("")
		App.toast("Opponent reconnected")
	else
		App.disconnectDeadline = data.deadline
		App.toast("Opponent disconnected", Theme.loss)
	end
end

function handlers.notice(p)
	App.toast(p.text or "", nil, (tonumber(p.duration)))
end

function handlers.reported(p)
	App.reportedGames = App.reportedGames or {}

	if not App.reportedGames[p.id] then
		App.toast("Thanks for the report. We'll look into it.")
	end

	App.reportedGames[p.id] = true
	App.refreshBars()
end

function App.reportGame(id)
	if type(id) == "string" and not (App.reportedGames and App.reportedGames[id]) then
		App.send({ type = "report", id = id })
		App.reportedGames = App.reportedGames or {}
		App.reportedGames[id] = true
		App.toast("Thanks for the report. We'll look into it.")
		App.refreshBars()
	end
end

function handlers.challenge(p)
	App.modals.incomingChallenge(p)
	Sound.play("notify")
end

function handlers.challengeSent(pendingChallenge)
	App.pendingChallenge = pendingChallenge
	App.toast("Challenge sent to " .. (pendingChallenge.to and pendingChallenge.to.display or "player"))
	App.pages.refreshAll()
end

function handlers.challengeDeclined(p)
	App.pendingChallenge = nil
	App.toast((p.by or "Player") .. " declined your challenge")
	App.pages.refreshAll()
end

function handlers.challengeCancelled(p)
	if App.pendingChallenge and App.pendingChallenge.id == p.id then
		local pendingChallenge = App.pendingChallenge
		App.pendingChallenge = nil

		if p.reason == "expired" then
			App.toast("Challenge expired")
		elseif p.reason == "left" then
			App.toast((pendingChallenge.to and pendingChallenge.to.display or "They") .. " left RoChess")
		end
	end

	App.modals.challengeGone(p.id)
	App.pages.refreshAll()
end

function App.resign()
	local session = App.session

	if not App.inLiveGame() then
		return
	end

	local function doIt()
		if session ~= App.session or session.over then
			return
		end

		if session.kind == "online" then
			App.send({ type = "resign", id = session.id })
		else
			App.endLocalGame("resign")
		end
	end

	if App.settings.confirmResign and #session.ucis >= 2 then
		App.modals.confirm("Are you sure you want to resign?", "Resign", doIt)
	else
		doIt()
	end
end

function App.abort()
	local session = App.session

	if session and session.kind == "online" and not session.over then
		App.send({ type = "abort", id = session.id })
	end
end

function App.offerDraw()
	local session = App.session

	if session and session.kind == "online" and not session.over then
		App.send({ type = "draw", id = session.id })
	end
end

function App.respondDraw(accept)
	local session = App.session

	if session and session.kind == "online" then
		App.send({ type = "drawResponse", id = session.id, accept = accept })
	end

	App.pages.game.showDrawOffer(false)
end

function App.rematch()
	local session = App.session

	if not (session and session.over) then
		return
	end

	if session.kind == "online" then
		App.send({ type = "rematch", id = session.id })
	elseif session.kind == "bot" then
		App.startBotGame(session.bot, session.myColor == 1 and "black" or "white")
	end
end

function App.newGame()
	local session = App.session
	App.modals.closeAll()

	if session and session.kind == "online" then
		App.send({ type = "leaveGame" })
		App.startSearch(session.tc and session.tc.id or App.selectedTc)
	elseif session and session.kind == "bot" then
		App.startBotGame(session.bot, App.botColor)
	else
		App.startSearch(App.selectedTc)
	end
end

function App.goHome()
	if App.inLiveGame() then
		return
	end

	local session = App.session

	if session and session.kind == "online" then
		App.send({ type = "leaveGame" })
	end

	if session and (session.kind == "bot" or session.kind == "puzzle" or session.kind == "rush") then
		App.send({ type = "status", status = "idle" })
	end

	App.modals.closeAll()

	if App.joining then
		showPairing(App.joining)
	elseif not App.searching then
		App.resetIdle()
	end

	App.pages.show("home")
end

function App.startBotGame(p, p2)
	local bot2 = Config.BOT_BY_ID[p] or Config.BOT_BY_ID.jasper

	if App.searching then
		App.cancelSearch()
	end

	App.modals.closeAll()
	App.selectedBot = bot2.id
	local myColor

	if p2 == "white" then
		myColor = 1
	elseif p2 == "black" then
		myColor = -1
	else
		myColor = if math.random() < 0.5 then 1 else -1
	end

	local myInfo = App.myInfo()
	local v8 = { display = bot2.name, rating = bot2.rating, bot = bot2 }
	local bot = Session.new("bot", {
		white = myColor == 1 and myInfo or v8,
		black = myColor == 1 and v8 or myInfo,
		myColor = myColor,
		bot = bot2.id
	})

	Bot.clearTT()
	App.setSession(bot)
	App.send({ type = "status", status = "bot" })
	App.send({ type = "fx", ev = "botStart" })
	App.pages.show("game")
	Sound.play("start")
	App.botSay(bot2, "Hi! Good luck, have fun.")

	if myColor == -1 then
		App.botTurn()
	end
end

function App.setThinking(p)
	local session = App.session

	if not session or session.kind ~= "bot" then
		return
	end

	local v8 = -session.myColor

	for _, v9 in { App.topBar, App.bottomBar } do
		if App.barColor[v9] == v8 then
			v9:setStatus(p and "thinking..." or "")
		end
	end
end

function App.botTurn()
	local session = App.session

	if not session or session.kind ~= "bot" or session.over or session:isMyTurn() then
		return
	end

	session.token = (session.token or 0) + 1
	local token = session.token
	local v8 = Config.BOT_BY_ID[session.bot]
	App.setThinking(true)
	task.spawn(function()
		local lastTime = os.clock()
		local function cancelled() -- 1 equivalent call inferred from this helper
			return App.session ~= session or (session.over or session.token ~= token)
		end

		local think = VortexBot.think(session.startFen, table.clone(session.ucis), v8, {
			cancelled = cancelled
		})
		local v9 = 0.25 + math.random() * 0.45
		local v10 = os.clock() - lastTime

		if v10 < v9 then
			task.wait(v9 - v10)
		end

		if cancelled() then -- inferred equivalent call
			return
		end

		App.setThinking(false)

		if not think then
			return
		end

		local v11 = session:applyUci(think)

		if not v11 and type(think) == "string" and #think == 4 then
			v11 = session:applyUci(think .. "q")
		end

		if not v11 then
			warn("[Chess] Bot gave an illegal move: " .. tostring(think))
			local Bot2 = require(ReplicatedStorage.Chess.Bot)
			local success, result = pcall(Bot2.think, session.startFen, table.clone(session.ucis), v8, {
				cancelled = cancelled
			})

			if success and result and App.session == session and not session.over and session.token == token then
				v11 = session:applyUci(result)
			end
		end

		if v11 then
			App.afterMove(v11, { fromBot = true })
		end
	end)
end

function App.endLocalGame(reason)
	local session = App.session

	if not session or session.over then
		return
	end

	session.over = true
	session.token = (session.token or 0) + 1
	local v8

	if reason == "checkmate" then
		v8 = session.engine.side == 1 and "0-1" or "1-0"
		reason = "checkmate"
	elseif reason == "resign" then
		v8 = session.myColor == 1 and "0-1" or "1-0"
		reason = "resignation"
	else
		v8 = "1/2-1/2"
	end

	session.result = v8
	session.reason = reason
	App.setThinking(false)
	App.render({ animate = false })
	App.pages.game.refresh()
	Sound.play("finish")
	local v9 = v8 == "1/2-1/2" and "draw" or (v8 == "1-0") == (session.myColor == 1) and "win" or "loss"
	App.send({ type = "botResult", bot = session.bot, result = v9 })
	local v10 = Config.BOT_BY_ID[session.bot]
	VortexBot.reportGame({
		kind = "bot",
		bot = session.bot,
		botColor = -session.myColor,
		botRating = v10 and v10.rating,
		startFen = session.startFen,
		moves = session.ucis,
		result = v8,
		reason = reason
	})

	local v11 = Config.BOT_BY_ID[session.bot]

	if v9 == "win" then
		App.botSay(v11, "Well played! You got me.")
	elseif v9 == "loss" then
		App.botSay(v11, "Good game! Want a rematch?")
	else
		App.botSay(v11, "A draw! Hard-fought game.")
	end

	App.afterMateEffect(function()
		App.modals.gameOver({ session = session, result = v8, reason = reason })
	end)
end

function App.takeback()
	local session = App.session

	if not session or session.kind ~= "bot" or session.over or #session.ucis == 0 then
		return
	end

	session.token = (session.token or 0) + 1
	App.setThinking(false)

	for _ = 1, session:isMyTurn() and 2 or 1 do
		if not (#session.ucis > 0) then
			continue
		end

		session:undo()
		App.pages.game.pop()
	end

	if session:isMyTurn() then
		session.viewPly = #session.ucis
		App.board:setArrow("hint", nil)
		App.render()
	else
		session.viewPly = #session.ucis
		App.render()
		App.botTurn()
	end
end

function App.hint()
	local session = App.session

	if not session or session.kind ~= "bot" or session.over or not session:isMyTurn() or App.hinting then
		return
	end

	App.hinting = true
	task.spawn(function()
		local analyse = Bot.analyse(session.startFen, table.clone(session.ucis), 0.7, 20)
		App.hinting = false

		if App.session ~= session or not analyse.best then
			return
		end

		local algToIndex64 = Engine.algToIndex64((string.sub(analyse.best, 1, 2)))
		local algToIndex64_2 = Engine.algToIndex64((string.sub(analyse.best, 3, 4)))
		App.board:setArrow("hint", algToIndex64, algToIndex64_2, Color3.fromRGB(150, 190, 70), 0.15)
	end)
end

function App:bubbleOn(text)
	if self.bubble then
		UI.fadeOut(self.bubble, 0.08)
		self.bubble = nil
	end

	local frame = UI.new("Frame", {
		Name = "Bubble",
		AutomaticSize = Enum.AutomaticSize.XY,
		Size = UDim2.new(),
		BackgroundColor3 = Color3.new(1, 1, 1),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, self.avatar.frame.AbsoluteSize.X + 8, 0.5, 0),
		ZIndex = 5,
		Parent = self.frame
	}, { UI.corner(10), UI.pad(6, 12, 6, 12) })
	UI.text({
		Text = text,
		FontFace = Theme.fontMedium,
		TextSize = string.find(text, "%a") and 14 or 22,
		TextColor3 = Theme.bg,
		AutomaticSize = Enum.AutomaticSize.XY,
		Size = UDim2.new(),
		ZIndex = 6,
		Parent = frame
	})

	self.bubble = frame

	local popScale = Instance.new("UIScale")
	popScale.Name = "PopScale"
	popScale.Parent = frame
	UI.pop(frame, 0.5, 0.22)
	task.delay(3.5, function()
		if frame.Parent then
			UI.fadeOut(frame, 0.16)
		end

		if self.bubble == frame then
			self.bubble = nil
		end
	end)
	return frame
end

function App.say(p, p2)
	local topBar = App.barColor and App.barColor[App.topBar] == p and App.topBar or App.bottomBar
	return App.bubbleOn(topBar, p2)
end

function App.botSay(_, p)
	local session = App.session

	if not session or session.kind ~= "bot" then
		return
	end

	App.say(-session.myColor, p)
end

local v8 = {
	self = "That's your own game!",
	busy = "Finish your game first.",
	none = "That game has already finished.",
	full = "Too many people are watching this game.",
	error = "Couldn't watch that game right now."
}

App.watchTarget = nil

function App.watch(watchTarget): boolean
	if type(watchTarget) ~= "number" then
		return false
	end

	if App.inLiveGame() then
		App.toast("Finish your game first.")
		return false
	end

	if App.searching then
		App.cancelSearch()
	end

	local request = App.request({ type = "watch", userId = watchTarget })

	if type(request) == "table" and request.ok then
		App.watchTarget = watchTarget
		return true
	end

	App.toast(v8[type(request) == "table" and request.reason or "error"] or "Couldn't watch that game right now.")
	return false
end

function App.stopWatching()
	local session = App.session

	if session and session.kind == "watch" then
		App.goHome()
	end
end

function handlers.watchStart(data)
	local v9 = App.session

	if App.inLiveGame() or data.follow and (not v9 or v9.kind ~= "watch" or v9.reviewJob) then
		App.send({ type = "unwatch" })
		return
	end

	if v9 then
		if v9.kind == "watch" then
			v9 = v9.id == data.id
		else
			v9 = false
		end
	end

	local watch = Session.new("watch", {
		id = data.id,
		ucis = data.moves,
		white = data.white,
		black = data.black,
		tc = data.tc,
		clocks = data.clocks,
		turnStart = data.turnStart,
		deadline = data.deadline,
		rated = data.rated,
		class = data.class
	})

	local watchTarget = App.watchTarget

	if
		not watchTarget
		or (not data.white or data.white.userId ~= watchTarget) and (not data.black or data.black.userId ~= watchTarget)
	then
		watchTarget = data.white and data.white.userId
		App.watchTarget = watchTarget
	end

	watch.viewColor = data.black and data.black.userId == watchTarget and -1 or 1
	watch.othersGame = true
	watch.watchers = tonumber(data.watchers)

	if data.over then
		watch.over = true
		watch.result = data.result
		watch.reason = data.reason
	end

	local flipOverride = v9 and App.flipOverride
	App.modals.closeAll()
	App.setSession(watch)

	if flipOverride then
		App.flip()
	end

	App.pages.show("game")

	if not v9 then
		local display = data.white and (data.white.display or data.white.name or "White") or "White"
		local display2 = data.black and (data.black.display or data.black.name or "Black") or "Black"
		App.toast((data.follow and "New game: " or "Watching ") .. display .. " vs " .. display2)
		Sound.play("start")
	end
end

function handlers.watchMove(data)
	local session = App.session

	if not session or session.kind ~= "watch" or session.id ~= data.id then
		return
	end

	local function syncClocks() -- 2 equivalent calls inferred from this helper
		if session.clocks and data.clocks then
			session.clocks[1] = data.clocks.w
			session.clocks[-1] = data.clocks.b
		end

		session.turnStart = data.turnStart
		session.deadline = data.deadline
	end

	if data.ply == #session.ucis and session.ucis[data.ply] == data.uci then
		syncClocks() -- inferred equivalent call
	else
		local v9 = data.ply == #session.ucis + 1 and session:applyUci(data.uci)

		if not v9 then
			App.send({ type = "watchSync" })
			return
		end

		syncClocks() -- inferred equivalent call
		App.afterMove(v9, {})
	end
end

function handlers.watchEnd(data)
	local session = App.session

	if not session or session.kind ~= "watch" or session.id ~= data.id then
		return
	end

	session.over = true
	session.result = data.result
	session.reason = data.reason

	if session.clocks and data.clocks then
		session.clocks[1] = data.clocks.w
		session.clocks[-1] = data.clocks.b
	end

	local ratings = data.ratings

	if ratings and ratings.w and session.white then
		session.white.rating = ratings.w.new
	end

	if ratings and ratings.b and session.black then
		session.black.rating = ratings.b.new
	end

	App.render({ animate = false })
	App.pages.game.refresh()
	Sound.play("finish")
end

function App.openHistory(historyEntry)
	if App.inLiveGame() then
		return
	end

	local ucis = historyEntry.mv and historyEntry.mv ~= "" and string.split(historyEntry.mv, " ") or {}
	local review = Session.new("review", {
		ucis = ucis,
		white = {
			display = historyEntry.white.n,
			rating = historyEntry.white.r,
			userId = historyEntry.white.u,
			headshot = historyEntry.white.h
		},
		black = {
			display = historyEntry.black.n,
			rating = historyEntry.black.r,
			userId = historyEntry.black.u,
			headshot = historyEntry.black.h
		},
		myColor = historyEntry.color,
		tc = historyEntry.tc
	})

	review.over = true
	review.result = historyEntry.res
	review.reason = historyEntry.why
	review.historyEntry = historyEntry

	review.othersGame = historyEntry.white.u ~= LocalPlayer.UserId and historyEntry.black.u ~= LocalPlayer.UserId
	App.setSession(review)
	App.pages.show("game")
end

function App.applySettings()
	Sound.enabled = App.settings.sound ~= false
	Haptics.enabled = App.settings.vibration ~= false
	Music.setEnabled(App.settings.music ~= false)
	App.board:applySettings(App.settings)
end

function App.saveSettings()
	App.applySettings()
	App.settingsDirty = true
	task.delay(1, function()
		if App.settingsDirty then
			App.settingsDirty = false
			App.send({ type = "settings", settings = App.settings })
		end
	end)
end

function App.debug(data)
	local session = App.session

	if data.type == "gameOverPreview" then
		local white = {
			display = Players.LocalPlayer.DisplayName,
			userId = Players.LocalPlayer.UserId,
			rating = 1200
		}
		local black = {
			display = data.opp or "TestOpponent",
			userId = 1,
			rating = 1210
		}
		App.modals.gameOver({
			session = {
				kind = "online",
				id = data.id or "preview-game",
				myColor = 1,
				white = white,
				black = black
			},
			result = data.result or "0-1",
			reason = "resignation"
		})

		return true
	elseif data.type == "reportLink" then
		for _, button in App.modalLayer:GetDescendants() do
			if button.Name == "Report" and button:IsA("TextButton") then
				return {
					text = button.Text,
					active = button.Active,
					abs = {
						button.AbsolutePosition.X,
						button.AbsolutePosition.Y,
						button.AbsoluteSize.X,
						button.AbsoluteSize.Y
					}
				}
			end
		end

		return nil
	elseif data.type == "state" then
		local v9 = {
			kind = session and session.kind,
			ply = session and #session.ucis,
			viewPly = session and session.viewPly,
			over = session and session.over,
			result = session and session.result,
			reason = session and session.reason,
			side = session and session.engine.side,
			myColor = session and session.myColor,
			fen = session and session.engine:getFen(),
			sans = session and table.concat(session.sans, " "),
			page = App.pages.current,
			searching = App.searching ~= nil,
			joining = App.joining and App.joining.phase or nil,
			black = session and session.black and session.black.display,
			white = session and session.white and session.white.display,
			clocks = session and session.clocks and {
				w = session.clocks[1],
				b = session.clocks[-1]
			},
			modals = 0
		}

		local names = {}

		for _, child in App.modalLayer:GetChildren() do
			table.insert(names, child.Name)
		end

		v9.modals = table.concat(names, ",")
		return v9
	else
		if data.type == "focus" then
			App._focusEvent(data.lost == true)
			return true
		end

		if data.type == "haptics" then
			return Haptics.debug(data)
		end

		if data.type == "move" then
			local algToIndex64 = Engine.algToIndex64((string.sub(data.uci, 1, 2)))
			local algToIndex64_2 = Engine.algToIndex64((string.sub(data.uci, 3, 4)))
			local v9 = ({ q = 5, r = 4, b = 3, n = 2 })[string.sub(data.uci, 5, 5)] or 0

			if not data.noInput then
				count += 1
			end

			return ownMove(algToIndex64, algToIndex64_2, v9) -- inferred equivalent call
		elseif data.type == "trip" then
			local what = data.what

			if what == "reset" then
				v6.game = nil
				v6.e = {}
				v6.a = {}
				v6.ne = 0
				v6.na = 0
				v6.d = 0
				v6.m = 0
				return true
			end

			if what == "engine" and session then
				local analyse = Bot.analyse(session.startFen, table.clone(session.ucis), 0.05, 6)
				return analyse and analyse.best
			end

			if what == "vortex" and session then
				local analyse = VortexBot.analyse(session.startFen, table.clone(session.ucis), 0.2, 6)
				return analyse and analyse.best
			end

			if what == "premove" and session and type(data.uci) == "string" then
				local algToIndex64 = Engine.algToIndex64((string.sub(data.uci, 1, 2)))
				local algToIndex64_2 = Engine.algToIndex64((string.sub(data.uci, 3, 4)))
				return App.board:addPremove({ from = algToIndex64, to = algToIndex64_2, promo = 0 })
			end

			if what == "debug" then
				return App.debug({ type = "state" }) ~= nil
			end

			if (what == "move" or what == "arrow" or what == "board") and session then
				local legalMoves = session.engine:legalMoves()
				local v9 = legalMoves[1] and session.engine:moveToUci(legalMoves[1])

				if not v9 then
					return nil
				end

				local algToIndex64 = Engine.algToIndex64((string.sub(v9, 1, 2)))
				local algToIndex64_2 = Engine.algToIndex64((string.sub(v9, 3, 4)))

				if what == "arrow" then
					App.board:setArrow("best", algToIndex64, algToIndex64_2)
					App.board:setArrow("best", nil)
				else
					count += 1

					if what ~= "board" then
						return App.onBoardMove(
								algToIndex64,
								algToIndex64_2,
								({ q = 5, r = 4, b = 3, n = 2 })[string.sub(v9, 5, 5)] or 0,
								false
							)
							and v9
					end

					App.board:commit(
						algToIndex64,
						algToIndex64_2,
						({ q = 5, r = 4, b = 3, n = 2 })[string.sub(v9, 5, 5)] or 0,
						false
					)
				end

				return v9
			else
				local v9 = {
					d = v6.d,
					m = v6.m,
					ne = session and v6.game == session.id and v6.ne or 0,
					na = session and v6.game == session.id and v6.na or 0,
					cs = 0
				}

				if session then
					session = tripCode(session) -- inferred equivalent call
				end

				v9.cs = session
				return v9
			end
		elseif data.type == "botgame" then
			local bot2 = Config.BOT_BY_ID[data.bot or "jasper"]
			local color = data.color or 1
			local myInfo = App.myInfo()
			local v9 = { display = bot2.name, rating = bot2.rating, bot = bot2 }
			local bot = Session.new("bot", {
				white = color == 1 and myInfo or v9,
				black = color == 1 and v9 or myInfo,
				myColor = color,
				bot = bot2.id,
				ucis = data.ucis or {},
				tc = data.tc
			})

			App.modals.closeAll()
			App.setSession(bot)
			App.pages.show("game")

			if not bot:isMyTurn() then
				App.botTurn()
			end

			return true
		elseif data.type == "click" then
			local algToIndex64 = Engine.algToIndex64(data.square)
			local colRow, v9 = App.board:colRow(algToIndex64)
			local v10 = App.board.frame.AbsolutePosition + Vector2.new(
				(colRow + 0.5) * App.board.sqPx,
				(v9 + 0.5) * App.board.sqPx
			)
			return { x = v10.X, y = v10.Y }
		else
			if data.type == "page" then
				App.pages.show(data.name)
				return true
			end

			if data.type == "showReport" then
				App.topBar:setReport(function() end, data.reported == true)
				return true
			end

			if data.type == "modal" then
				App.modals[data.name](table.unpack(data.args or {}))
				return true
			end

			if data.type == "resign" then
				App.settings.confirmResign = false
				App.resign()
				return true
			end

			if data.type == "search" then
				App.startSearch(data.tc or App.selectedTc)
				return true
			end

			if data.type == "review" then
				App.startReview()
				return true
			end

			if data.type == "openHistory" then
				App.openHistory(data.entry)
				return true
			end

			if data.type == "coachText" then
				for _, label in App.gui:GetDescendants() do
					if label:IsA("TextLabel") and label.Parent and label.Parent.Name == "Strip" then
						return label.ContentText
					end
				end

				return nil
			elseif data.type == "joining" then
				if data.phase then
					App.searching = nil
					App.joining = {
						phase = data.phase,
						opponent = data.opponent or {},
						tc = data.tc,
						color = data.color,
						since = os.clock()
					}
					showPairing(App.joining)
				else
					App.joining = nil
					App.resetIdle()
				end

				App.pages.show("home")
				App.pages.home.refresh()
				return true
			elseif data.type == "teleportScreen" then
				local chessTeleport = LocalPlayer.PlayerGui:FindFirstChild("ChessTeleport")

				if chessTeleport then
					chessTeleport:Destroy()
				end

				if data.title then
					local teleportScreen = buildTeleportScreen(data.title, data.sub)
					teleportScreen.Parent = LocalPlayer.PlayerGui
				end

				return true
			else
				if data.type == "navigate" then
					App.navigate(data.ply)
					return true
				end

				if data.type == "navPress" then
					return App.nav.press(data.id)
				end

				if data.type == "tasksState" then
					return App.pages.tasks.state()
				end

				if data.type == "shopState" then
					if data.open then
						App.Shop.openCrate(data.open)
					end

					if data.daily and App.Shop.buyDaily then
						App.Shop.buyDaily(data.daily)
					end

					if data.bought and App.Shop.fakeTokensBought then
						App.Shop.fakeTokensBought(data.bought)
					end

					return App.Shop.state()
				end

				if data.type == "learnHub" then
					return App.Learn.debug(data)
				end

				if data.type == "learn" then
					if data.welcome then
						App.modals.welcome()
					end

					if data.open then
						App.openTutorial(data.fromStart)
					end

					if data.lesson then
						App.Tutorial._fwd.startLesson(data.lesson)
					end

					local state = App.Tutorial.state
					local v9 = {}

					for k in state.stars do
						table.insert(v9, Engine.index64ToAlg(k))
					end

					return {
						idx = state.idx,
						complete = state.complete,
						finished = state.finished,
						busy = state.busy,
						msg = state.msg,
						stars = table.concat(v9, ","),
						onBoard = session ~= nil and session == state.session
					}
				end

				if data.type == "vipState" then
					return App.Vip.debug(data)
				end

				if data.type == "openCrate" then
					App.Shop.openCrate(data.crate)
					return true
				end

				if data.type == "shopPolicy" then
					App.pages.shop.checkPolicy(true)
					return true
				end

				if data.type == "skipReel" then
					if App.Shop.reel then
						App.Shop.reel.finish()
					end

					return true
				elseif data.type == "equip" then
					local v9 = App.Cosmetics.Shared.BY_ID[data.id]

					if v9 then
						App.Shop.equip(v9)
					end

					return v9 ~= nil
				else
					if data.type == "effect" then
						return App.board:playEffect(data.sq or 28, data.id, data.big)
					end

					if data.type == "inventory" then
						App.pages.inventory.show(data.kind or "board")
						return true
					end

					if data.type == "claimTask" then
						App.pages.tasks.claim(data.id)
						return true
					end

					if data.type == "donateState" then
						return App.pages.donate.state()
					end

					if data.type == "historyState" then
						return App.pages.history.state(data.more)
					end

					if data.type == "pad" then
						local gamepad = App.gamepad

						if data.active ~= nil then
							gamepad.setActive(data.active)
						end

						if data.key then
							gamepad.press(Enum.KeyCode[data.key])
						end

						if data.dc or data.dr then
							gamepad.move(data.dc or 0, data.dr or 0)
						end

						return gamepad.state()
					end

					if data.type == "levelsState" then
						return App.Levels.state()
					end

					if data.type == "quickChat" then
						if data.open then
							App.QuickChat.open()
						end

						if data.p then
							App.QuickChat.pick(data.p)
						end

						return App.QuickChat.state()
					else
						if data.type == "codes" then
							return App.Codes.debug(data)
						end

						if data.type == "profile" then
							return App.Profile.debug(data)
						end

						if data.type == "gifts" then
							return App.Gifts.debug(data)
						end

						if data.type ~= "reviewState" then
							return nil
						end

						local review = session and session.review

						if not review then
							return nil
						end

						local v9 = {}

						for i = 1, #session.ucis do
							v9[i] = session.sans[i] .. ":" .. tostring(review.classes and review.classes[i])
						end

						return {
							done = review.done,
							progress = review.progress,
							accW = review.accuracy and review.accuracy[1],
							accB = review.accuracy and review.accuracy[-1],
							classes = table.concat(v9, " ")
						}
					end
				end
			end
		end
	end
end

function App.applyCarriedLook()
	if App.profile then
		return
	end

	local success, result = pcall(function()
		local TeleportService2 = game:GetService("TeleportService")
		return TeleportService2:GetLocalPlayerTeleportData()
	end)

	if success then
		success = type(result) == "table" and result.look
	end

	if type(success) ~= "table" then
		return
	end

	if type(success.set) == "table" and type(App.settings) == "table" then
		for k, v9 in success.set do
			if not (type(k) == "string" and App.settings[k] ~= nil and type(App.settings[k]) == type(v9)) then
				continue
			end

			if not (k ~= "theme" or Config.THEME_BY_ID and Config.THEME_BY_ID[v9]) then
				continue
			end

			App.settings[k] = v9
		end

		pcall(App.applySettings)
	end

	local cos = success.cos
	local Shared = App.Cosmetics and App.Cosmetics.Shared

	if type(cos) == "table" and App.setCos and Shared and Shared.BY_ID then
		local eq = {}
		local inv = {}

		if type(cos.eq) == "table" then
			for k, v9 in cos.eq do
				if not (type(k) == "string" and type(v9) == "string" and Shared.BY_ID[v9]) then
					continue
				end

				eq[k] = v9
			end
		end

		if type(cos.inv) == "table" then
			for _, v9 in cos.inv do
				if type(v9) == "string" and Shared.BY_ID[v9] then
					table.insert(inv, v9)
				end
			end
		end

		local success2, result2 = pcall(App.setCos, {
			inv = inv,
			eq = eq,
			crates = tonumber(cos.crates) or 0,
			prompted = cos.prompted == true
		})

		if not success2 then
			warn("[Chess] carried look: " .. tostring(result2))
		end
	end
end

function App.start()
	Sound.init()

	function Haptics.watching(): boolean
		return App.session ~= nil and App.session.kind == "watch"
	end

	Haptics.init()
	App.build()
	App.applyCarriedLook()
	watchArrows(App.board) -- inferred equivalent call
	Sound.attach(App.gui)

	while not Chess:GetAttribute("BuildId") do
		Chess:GetAttributeChangedSignal("BuildId"):Wait()
	end

	local v9 = string.split(Chess:GetAttribute("BuildId"), ":")
	local child = Chess:WaitForChild(v9[1])
	v = {
		Action = child:WaitForChild(v9[2]),
		Event = child:WaitForChild(v9[3]),
		Request = child:WaitForChild(v9[4])
	}

	v.Event.OnClientEvent:Connect(function(p)
		if type(p) ~= "table" then
			return
		end

		local v10 = handlers[p.type]

		if v10 then
			local success, result = pcall(v10, p)

			if not success then
				warn("[Chess] client handler " .. tostring(p.type) .. ": " .. tostring(result))
			end
		end
	end)

	task.spawn(function()
		local v10 = 8

		for _ = 1, 12 do
			task.wait(v10)

			if App.profile then
				break
			end

			App.send({ type = "needProfile" })
			v10 = math.min(v10 + 4, 20)
		end
	end)

	task.spawn(function()
		if Openings.load(120) and App.session then
			App.render({ animate = false })
		end
	end)

	RunService.RenderStepped:Connect(function()
		App.updateClocks()

		if App.pages and App.pages.onFrame then
			App.pages.onFrame()
		end
	end)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed or UserInputService:GetFocusedTextBox() then
			return
		end

		local session = App.session

		if not session then
			return
		end

		local keyCode = input.KeyCode

		if keyCode == Enum.KeyCode.Left then
			App.navigate(session.viewPly - 1)
		elseif keyCode == Enum.KeyCode.Right then
			App.navigate(session.viewPly + 1)
		elseif keyCode == Enum.KeyCode.Up or keyCode == Enum.KeyCode.Home then
			App.navigate(0)
		elseif keyCode == Enum.KeyCode.Down or keyCode == Enum.KeyCode.End then
			App.navigate(#session.ucis)
		elseif keyCode == Enum.KeyCode.F then
			App.flip()
		end
	end)

	local success, result = pcall(function()
		return TeleportService:GetLocalPlayerTeleportData()
	end)

	if
		success
		and type(result) == "table"
		and result.chessMatch
		and not App.joining
		and (not App.session or App.session.kind ~= "online")
	then
		local joining = {
			phase = "arrived",
			opponent = type(result.opp) == "table" and result.opp or {},
			tc = result.tc,
			color = result.color,
			since = os.clock()
		}

		App.joining = joining
		showPairing(joining)
		App.pages.show("home")
		App.pages.home.refresh()
		watchJoining(joining, 90) -- inferred equivalent call
	end

	local Debug = App.debug
	function App.debug(p)
		v6.d += 1
		return Debug(p)
	end

	if RunService:IsStudio() then
		local chessDebug = Instance.new("BindableFunction")
		chessDebug.Name = "ChessDebug"
		function chessDebug.OnInvoke(p)
			return Debug(p)
		end

		chessDebug.Parent = App.gui
	end

	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		currentCamera.CameraType = Enum.CameraType.Scriptable
		currentCamera.CFrame = CFrame.new(0, 500, 0) * CFrame.Angles(-1.5707963267948966, 0, 0)
	end
end

return App