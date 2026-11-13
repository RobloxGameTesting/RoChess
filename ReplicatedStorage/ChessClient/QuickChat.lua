local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Chess = ReplicatedStorage:WaitForChild("Chess")
local Config = require(Chess.Config)
local parent = script.Parent
local Theme = require(parent.Theme)
local UI = require(parent.UI)
local Sound = require(parent.Sound)

local QuickChat = {}

local function isReaction(value): boolean -- 2 equivalent calls inferred from this helper
	return string.find(value, "%a") == nil
end

function QuickChat:install()
	local Game = self.pages.game

	if not Game then
		return
	end

	local frame = Game.frame
	local flag = false
	local v = 0
	local v2 = 3
	local v3 = os.clock()

	function self.quickChatOn(): boolean
		local session = self.session

		if not session or session.kind ~= "online" or self.settings.quickChat == false then
			return false
		end

		return not session.over or session.endedClock ~= nil and os.clock() - session.endedClock < 115
	end

	local textButton = UI.new("TextButton", {
		Name = "QuickChatCatcher",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		Visible = false,
		ZIndex = 8,
		Parent = frame
	})

	textButton:SetAttribute("Sfx", "none")
	local frame2 = UI.new("Frame", {
		Name = "QuickChat",
		Size = UDim2.new(1, -16, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -((Game.navOffset or 104) + 2)),
		BackgroundColor3 = Theme.panelHeader,
		Visible = false,
		ZIndex = 9,
		Parent = frame
	}, {
		UI.corner(10),
		UI.pad(10, 10, 10, 10),
		UI.list(Enum.FillDirection.Vertical, 8),
		UI.stroke(Theme.divider, 1, 0)
	})
	local frame3 = UI.new("Frame", {
		Name = "Phrases",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 1,
		Parent = frame2
	})

	local uiGridLayout = Instance.new("UIGridLayout")
	uiGridLayout.CellSize = UDim2.new(0.5, -4, 0, 40)
	uiGridLayout.CellPadding = UDim2.fromOffset(8, 8)
	uiGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiGridLayout.Parent = frame3
	local frame4 = UI.new("Frame", {
		Name = "Reactions",
		Size = UDim2.new(1, 0, 0, 42),
		BackgroundTransparency = 1,
		LayoutOrder = 2,
		Parent = frame2
	}, { UI.list(Enum.FillDirection.Horizontal, 8, Enum.HorizontalAlignment.Center) })

	local function close() -- 5 equivalent calls inferred from this helper
		if not flag then
			return
		end

		flag = false
		textButton.Visible = false
		UI.reveal(frame2, false)
	end

	local function open()
		if flag or not self.quickChatOn() then
			return
		end

		flag = true
		textButton.Visible = true
		UI.reveal(frame2, true, 8)
		Sound.play("open")
	end

	local function send(k)
		local session = self.session

		if session and session.kind == "online" and session.id and self.quickChatOn() then
			local now = os.clock()
			v2 = math.min(3, v2 + (now - v3) * 0.3125)
			v3 = now

			if now - v < 1.5 or v2 < 1 then
				Sound.play("locked")
				return
			end

			v2 -= 1
			v = now
			self.send({ type = "chat", id = session.id, p = k })
			close() -- inferred equivalent call
		else
			close() -- inferred equivalent call
		end
	end

	local count = 0

	for _, v4 in Config.QUICK_CHAT do
		if isReaction(v4) then -- inferred equivalent call
			count += 1
		end
	end

	for k, text in Config.QUICK_CHAT do
		local reaction = isReaction(text) -- inferred equivalent call
		UI.button({
			parent = reaction and frame4 or frame3,
			name = "Phrase" .. k,
			size = reaction and UDim2.new(1 / count, (count - 1) * -8 / count, 1, 0) or UDim2.fromScale(1, 1),
			style = reaction and "flat" or "secondary",
			text = text,
			textSize = reaction and 22 or 16,
			layoutOrder = k,
			onClick = function()
				send(k)
			end
		})
	end

	textButton.Activated:Connect(close)

	self.closeQuickChat = close
	function self.toggleQuickChat()
		if flag then
			close() -- inferred equivalent call
		elseif not flag then
			if not self.quickChatOn() then
				return
			end

			flag = true
			textButton.Visible = true
			UI.reveal(frame2, true, 8)
			Sound.play("open")
		end
	end

	function self.handlers.chat(data)
		local session = self.session

		if not session or session.kind ~= "online" or session.id ~= data.id then
			return
		end

		local v4 = Config.QUICK_CHAT[tonumber(data.p) or 0]
		local from = tonumber(data.from)

		if not v4 or from ~= 1 and from ~= -1 then
			return
		end

		local v5 = from == session.myColor

		if not v5 and self.settings.quickChat == false then
			return
		end

		self.say(from, v4)

		if not v5 then
			Sound.play("toast")
		end
	end

	local gameEnd = self.handlers.gameEnd
	function self.handlers.gameEnd(p)
		local session = self.session

		if session and session.kind == "online" and session.id == p.id then
			session.endedClock = os.clock()

			task.delay(115.1, function()
				if self.session == session and not self.quickChatOn() then
					close() -- inferred equivalent call

					if Game.showChat then
						Game.showChat(false)
					end
				end
			end)
		end

		gameEnd(p)
	end

	local load = Game.load
	function Game.load(...)
		close() -- inferred equivalent call
		return load(...)
	end

	local applySettings = self.applySettings
	function self.applySettings(...)
		applySettings(...)

		if Game.showChat then
			Game.showChat(self.quickChatOn())
		end
	end

	QuickChat.open = open
	QuickChat.pick = send
	function QuickChat.state()
		local texts = {}

		for k, v4 in { top = self.topBar, bottom = self.bottomBar } do
			local bubble = v4.bubble
			local textLabel = bubble and bubble.Parent and bubble:FindFirstChildWhichIsA("TextLabel", true)
			texts[k] = textLabel and textLabel.Text or nil
		end

		return {
			available = self.quickChatOn(),
			open = flag,
			button = Game.chatButton ~= nil and Game.chatButton.holder.Visible,
			bubbles = texts
		}
	end
end

return QuickChat