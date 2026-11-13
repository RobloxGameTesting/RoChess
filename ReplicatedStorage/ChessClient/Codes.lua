local GroupService = game:GetService("GroupService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Chess = ReplicatedStorage:WaitForChild("Chess")
local Cosmetics = require(Chess.Cosmetics)
local parent = script.Parent
local Theme = require(parent.Theme)
local UI = require(parent.UI)
local Sound = require(parent.Sound)

local Codes = {}
Codes.fakeJoin = nil
local blueSoft = Theme.blueSoft

local function plural(tokens, p) -- 1 equivalent call inferred from this helper
	return tostring(tokens) .. " " .. p .. (tokens == 1 and "" or "s")
end

local function rewardText(data)
	local v = {}
	local tokens = tonumber(data.tokens) or 0
	local xp = tonumber(data.xp) or 0

	if tokens > 0 then
		table.insert(v, "+" .. plural(tokens, "token")) -- inferred equivalent call
	end

	if xp > 0 then
		table.insert(v, "+" .. xp .. " XP")
	end

	for _, v2 in type(data.items) == "table" and data.items or {} do
		local v3 = Cosmetics.BY_ID[v2]

		if v3 then
			table.insert(v, v3.name)
		end
	end

	if #v == 0 then
		return "nothing new (you already had it)"
	end

	if #v == 1 then
		return v[1]
	end

	return table.concat(v, ", ", 1, #v - 1) .. " and " .. v[#v]
end

local function escape(value) -- 2 equivalent calls inferred from this helper
	return (string.gsub(string.gsub(string.gsub(value, "&", "&amp;"), "<", "&lt;"), ">", "&gt;"))
end

local function groupId() -- 2 equivalent calls inferred from this helper
	local codesGroupId = Chess:GetAttribute("CodesGroupId")

	if type(codesGroupId) == "number" and codesGroupId > 0 then
		return codesGroupId
	end

	if game.CreatorType == Enum.CreatorType.Group then
		return game.CreatorId
	end

	return nil
end

local function groupPhrase(p)
	local v = Chess:GetAttribute("CodesGroupName")

	if type(v) ~= "string" or v == "" then
		return "our Roblox group"
	end

	v = p and "<b>" .. escape(v) .. "</b>" or v -- inferred equivalent call
	return "the " .. v .. " group"
end

local function isMember()
	local v = groupId() -- inferred equivalent call

	if not v then
		return true
	end

	local localPlayer = Players.LocalPlayer
	local success, result = pcall(function()
		return localPlayer:IsInGroupAsync(v)
	end)

	if success and type(result) == "boolean" then
		return result
	end

	local success2, result2 = pcall(function()
		return localPlayer:IsInGroup(v)
	end)

	if success2 and type(result2) == "boolean" then
		return result2
	end

	return nil
end

local function promptJoin()
	if Codes.fakeJoin and RunService:IsStudio() then
		task.wait(0.4)
		return Codes.fakeJoin
	end

	local v = groupId() -- inferred equivalent call

	if not v then
		return "member"
	end

	local success, result = pcall(function()
		return GroupService:PromptJoinAsync(v)
	end)

	if not success then
		return "error"
	end

	local name = typeof(result) == "EnumItem" and result.Name or ""

	if name == "Joined" or name == "AlreadyMember" then
		return "member"
	end

	return if name == "JoinRequestPending" then "pending" else "none"
end

function Codes.install(data)
	local pages = data.pages
	local page, parent2 = pages.newPage("codes", "Codes", "gift", Theme.token, true)
	local codes = { frame = page }
	pages.codes = codes

	if pages.backTo then
		pages.backTo.codes = "shop"
	end

	local frame = UI.new("Frame", {
		Name = "Hero",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 1,
		Parent = parent2
	}, { UI.list(Enum.FillDirection.Vertical, 2, Enum.HorizontalAlignment.Center), UI.pad(4, 0, 2, 0) })
	local icon = UI.icon("gift", 58, Theme.token, { Name = "Gift", LayoutOrder = 1, Parent = frame })
	UI.text({
		Name = "Title",
		Text = "Got a code?",
		FontFace = Theme.fontHeavy,
		TextSize = 24,
		Size = UDim2.new(1, 0, 0, 30),
		LayoutOrder = 2,
		Parent = frame
	})

	UI.text({
		Name = "Sub",
		Text = "Type it below for free tokens, XP and items.",
		TextSize = 15,
		TextColor3 = Theme.textDim,
		TextWrapped = true,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 3,
		Parent = frame
	})

	local textBox = UI.new("TextBox", {
		Name = "Code",
		Size = UDim2.new(1, 0, 0, 76),
		BackgroundTransparency = 0,
		BackgroundColor3 = Theme.panelHeader,
		Text = "",
		PlaceholderText = "ENTER CODE",
		PlaceholderColor3 = Theme.textMuted,
		FontFace = Theme.fontHeavy,
		TextSize = 30,
		TextColor3 = Theme.text,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ClearTextOnFocus = false,
		LayoutOrder = 2,
		Parent = parent2
	}, { UI.corner(10), UI.pad(0, 14, 0, 14) })
	local stroke = UI.stroke(Theme.divider, 2, 0)
	stroke.Parent = textBox

	local text = UI.text({
		Name = "Status",
		Text = "",
		FontFace = Theme.fontBold,
		TextSize = 15,
		TextWrapped = true,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Visible = false,
		LayoutOrder = 4,
		Parent = parent2
	})

	local function card(name, layoutOrder)
		return UI.new("Frame", {
			Name = name,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Theme.panelLight,
			LayoutOrder = layoutOrder,
			Parent = parent2
		}, { UI.corner(8), UI.pad(14, 14, 14, 14), UI.list(Enum.FillDirection.Vertical, 10) })
	end

	local function heading(parent3, p, p2, text2)
		local frame2 = UI.new("Frame", {
			Name = "Head",
			Size = UDim2.new(1, 0, 0, 24),
			BackgroundTransparency = 1,
			LayoutOrder = 1,
			Parent = parent3
		}, { UI.list(Enum.FillDirection.Horizontal, 8, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center) })
		UI.icon(p, 22, p2, { Name = "Icon", LayoutOrder = 1, Parent = frame2 })
		UI.text({
			Name = "Title",
			Text = text2,
			FontFace = Theme.fontBold,
			TextSize = 17,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.new(0, 0, 1, 0),
			LayoutOrder = 2,
			Parent = frame2
		})

		return frame2
	end

	local function body(parent3, layoutOrder, text2)
		return UI.text({
			Name = "Body",
			Text = text2,
			RichText = true,
			TextSize = 15,
			TextColor3 = Theme.textSoft,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = layoutOrder,
			Parent = parent3
		})
	end

	local parent3 = card("Group", 5)
	heading(parent3, "group", blueSoft, "Group members only")
	local v = body(parent3, 2, "")
	local join
	local button = UI.button({
		parent = parent3,
		name = "Join",
		size = UDim2.new(1, 0, 0, 46),
		style = "secondary",
		icon = "group",
		iconColor = blueSoft,
		iconSize = 20,
		text = "Join the group",
		textSize = 17,
		layoutOrder = 3,
		onClick = function()
			join(nil)
		end
	})

	local frame2 = UI.new("Frame", {
		Name = "Member",
		Size = UDim2.new(1, 0, 0, 22),
		BackgroundTransparency = 1,
		Visible = false,
		LayoutOrder = 4,
		Parent = parent3
	}, { UI.list(Enum.FillDirection.Horizontal, 6, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center) })
	UI.icon("check", 20, Theme.green, { LayoutOrder = 1, Parent = frame2 })
	UI.text({
		Text = "You're in the group",
		FontFace = Theme.fontBold,
		TextSize = 15,
		TextColor3 = Theme.green,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 1, 0),
		LayoutOrder = 2,
		Parent = frame2
	})

	local parent4 = card("Where", 6)
	heading(parent4, "bell", Theme.tasks, "New codes")
	body(parent4, 2, "Codes are posted in the server and the group.")
	local frame3 = UI.new("Frame", {
		Name = "Note",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.panelHeader,
		LayoutOrder = 3,
		Parent = parent4
	}, { UI.corner(6), UI.pad(10, 12, 10, 12), UI.stroke(Theme.gold, 1, 0.55) })
	UI.icon("thumbup", 22, Theme.gold, {
		Name = "Icon",
		Position = UDim2.fromOffset(0, 0),
		Parent = frame3
	})
	local text2 = UI.text({
		Name = "Text",
		Text = "",
		FontFace = Theme.fontBold,
		TextSize = 15,
		TextColor3 = Theme.gold,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(32, 2),
		Size = UDim2.new(1, -32, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = frame3
	})

	local function showNote() -- 1 equivalent call inferred from this helper
		local codesNote = Chess:GetAttribute("CodesNote")
		local text3 = type(codesNote) == "string" and string.match(codesNote, "^%s*(.-)%s*$") or ""
		text2.Text = text3
		frame3.Visible = text3 ~= ""
	end
	Chess:GetAttributeChangedSignal("CodesNote"):Connect(showNote)
	showNote() -- inferred equivalent call

	local function showGroup() -- 1 equivalent call inferred from this helper
		local codesGroupName = Chess:GetAttribute("CodesGroupName")
		v.Text = "You must be in " .. ((type(codesGroupName) ~= "string" or codesGroupName == "") and "our Roblox group" or "the " .. ("<b>" .. escape(codesGroupName) .. "</b>" or codesGroupName) .. " group") .. " to redeem codes." -- inferred equivalent call
	end
	Chess:GetAttributeChangedSignal("CodesGroupName"):Connect(showGroup)
	showGroup() -- inferred equivalent call
	local member2 = nil
	local function setMember(member) -- 2 equivalent calls inferred from this helper
		member2 = member
		button.holder.Visible = member ~= true
		frame2.Visible = member == true
	end

	member2 = nil
	button.holder.Visible = true
	frame2.Visible = false

	local v2 = false
	local lastTime = -1e999
	local function checkMember(p)
		if v2 or not p and os.clock() - lastTime < 30 then
			return
		end

		v2 = true
		task.spawn(function()
			local member = isMember()
			v2 = false
			lastTime = os.clock()

			if member ~= nil then
				setMember(member) -- inferred equivalent call
			end
		end)
	end

	local flag = false
	local flag2 = false
	local v3 = nil
	local submit

	local function say(text3, textColor) -- 11 equivalent calls inferred from this helper
		text.Text = text3
		text.TextColor3 = textColor
		UI.reveal(text, true, 4)
		UI.textIn(text, 0.15)
	end

	local function celebrate(request)
		Sound.play("currency")
		task.delay(0.2, Sound.play, "unlock")
		UI.pop(icon, 0.5, 0.35)
		local v4 = v3.holder.AbsolutePosition + v3.holder.AbsoluteSize / 2 - data.gui.AbsolutePosition
		local frame4 = UI.new("Frame", {
			Name = "CodeFx",
			Size = UDim2.new(),
			BackgroundTransparency = 1,
			ZIndex = 50,
			Parent = data.gui
		})
		UI.confetti(frame4, v4, {
			count = 30,
			spread = 140,
			zindex = 50,
			colors = { Theme.token, Theme.gold, Theme.green, Color3.new(1, 1, 1) }
		})

		task.delay(2.5, frame4.Destroy, frame4)
		local toast = data.toast("Code redeemed!", Theme.green, 3)
		local tokens = tonumber(request.tokens) or 0

		if toast and tokens > 0 and data.Levels then
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

			data.Levels.tokenChip(toast, tokens, 20, 2)
		end
	end

	join = function(p)
		if flag2 then
			return
		end

		flag2 = true
		button:setEnabled(false)
		task.spawn(function()
			local v4 = promptJoin()
			flag2 = false
			button:setEnabled(true)

			if v4 == "member" then
				member2 = true
				button.holder.Visible = false
				frame2.Visible = true

				Sound.play("unlock")

				if p then
					say("You're in! Redeeming your code...", Theme.green) -- inferred equivalent call
					task.wait(0.6)
					submit(p, true)
				else
					say("You're in the group. You can redeem codes now!", Theme.green) -- inferred equivalent call
				end
			elseif v4 == "pending" then
				say("Your request to join is waiting for approval. You can redeem codes once you're in.", Theme.gold) -- inferred equivalent call
			elseif v4 == "error" then
				local codesGroupName = Chess:GetAttribute("CodesGroupName")
				say( -- inferred equivalent call
					"Couldn't open the join prompt. Join " .. ((type(codesGroupName) ~= "string" or codesGroupName == "") and "our Roblox group" or "the " .. codesGroupName .. " group") .. " on Roblox, then try again.",
					Theme.loss
				)
			elseif p then
				local codesGroupName = Chess:GetAttribute("CodesGroupName")
				say( -- inferred equivalent call
					"You need to be in " .. ((type(codesGroupName) ~= "string" or codesGroupName == "") and "our Roblox group" or "the " .. codesGroupName .. " group") .. " to redeem codes.",
					Theme.loss
				)
			end
		end)
	end

	submit = function(p, p2)
		if flag then
			return
		end

		local code = p or string.gsub(textBox.Text, "%s+", "")

		if code == "" then
			Sound.play("locked")
			UI.shake(textBox, 5)
			say("Type a code first.", Theme.textDim) -- inferred equivalent call
		else
			flag = true
			v3:setEnabled(false)
			v3:setText("...")
			task.spawn(function()
				local request = data.request({ type = "redeemCode", code = code })
				flag = false
				v3:setEnabled(true)
				v3:setText("Redeem")

				if type(request) == "table" then
					if request.ok then
						member2 = true
						button.holder.Visible = false
						frame2.Visible = true

						if type(request.tasks) == "table" and pages.tasks then
							pages.tasks.apply(request.tasks, false)
						end

						if type(request.cos) == "table" and data.setCos then
							data.setCos(request.cos)
						end

						if pages.shop and pages.shop.refresh then
							pages.shop.refresh()
						end

						textBox.Text = ""
						say("Redeemed " .. tostring(request.code) .. ": " .. rewardText(request) .. "!", Theme.green) -- inferred equivalent call
						celebrate(request)
					elseif request.needGroup then
						member2 = false
						button.holder.Visible = true
						frame2.Visible = false

						if p2 then
							say("Roblox hasn't caught up with your join yet. Try again in a minute.", Theme.gold) -- inferred equivalent call
						else
							Sound.play("error")
							local codesGroupName = Chess:GetAttribute("CodesGroupName")
							say( -- inferred equivalent call
								"You need to be in " .. ((type(codesGroupName) ~= "string" or codesGroupName == "") and "our Roblox group" or "the " .. codesGroupName .. " group") .. " to redeem codes. Join it to get your reward!",
								Theme.gold
							)
							task.delay(0.35, join, code)
						end
					else
						Sound.play("error")
						UI.shake(textBox, 5)
						say(tostring(request.reason or "That code didn't work."), Theme.loss) -- inferred equivalent call
					end
				else
					Sound.play("error")
					say("Couldn't check that code. Try again in a moment.", Theme.loss) -- inferred equivalent call
				end
			end)
		end
	end

	v3 = UI.button({
		parent = parent2,
		name = "Redeem",
		size = UDim2.new(1, 0, 0, 56),
		style = "primary",
		text = "Redeem",
		textSize = 21,
		layoutOrder = 3,
		onClick = function()
			submit()
		end
	})

	textBox.Focused:Connect(function()
		UI.tween(stroke, UI.FAST, { Color = Theme.green })
	end)
	textBox.FocusLost:Connect(function(p)
		UI.tween(stroke, UI.SNAP, { Color = Theme.divider })

		if p then
			submit()
		end
	end)
	textBox:GetPropertyChangedSignal("Text"):Connect(function()
		if #textBox.Text > 32 then
			textBox.Text = string.sub(textBox.Text, 1, 32)
		end
	end)

	function codes.onShow()
		UI.pop(icon, 0.7, 0.3)

		if not v2 then
			if os.clock() - lastTime < 30 then
				return
			end

			v2 = true
			task.spawn(function()
				local member = isMember()
				v2 = false
				lastTime = os.clock()

				if member ~= nil then
					setMember(member) -- inferred equivalent call
				end
			end)
		end
	end

	local shop = pages.shop
	local scrollingFrame = shop and shop.frame:FindFirstChildOfClass("ScrollingFrame")

	if scrollingFrame then
		local button2 = UI.button({
			parent = scrollingFrame,
			name = "Codes",
			size = UDim2.new(1, 0, 0, 58),
			style = "secondary",
			icon = "gift",
			iconColor = Theme.textSoft,
			iconSize = 28,
			text = "Codes",
			textSize = 17,
			subtext = "Redeem a code for free rewards",
			align = Enum.HorizontalAlignment.Left,
			padX = 14,
			gap = 12,
			layoutOrder = 1,
			onClick = function()
				pages.show("codes")
			end
		})

		UI.icon("next", 20, Theme.textDim, {
			Name = "Chevron",
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -12, 0.5, 0),
			Parent = button2.face
		})
	end

	function Codes.try(text3)
		pages.show("codes")
		textBox.Text = text3
		submit()
	end
	function Codes.debug(data2)
		if data2.fakeJoin ~= nil then
			local fakeJoin

			if data2.fakeJoin ~= false then
				fakeJoin = data2.fakeJoin or nil
			end

			Codes.fakeJoin = fakeJoin
		end

		if data2.join then
			join(nil)
		end

		if data2.code then
			Codes.try(data2.code)
		end

		return Codes.state()
	end

	function Codes.state()
		return {
			page = pages.current,
			text = textBox.Text,
			status = text.Visible and text.Text or nil,
			busy = flag,
			joining = flag2,
			member = member2,
			group = v.Text,
			note = frame3.Visible and text2.Text or nil
		}
	end
end

return Codes