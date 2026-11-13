local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Chess = ReplicatedStorage:WaitForChild("Chess")
local Config = require(Chess.Config)
local parent = script.Parent
local Theme = require(parent.Theme)
local UI = require(parent.UI)
local Sound = require(parent.Sound)

local v = utf8.char(57346)

local v2 = {
	Color3.fromRGB(246, 164, 186),
	Color3.fromRGB(243, 134, 162),
	Color3.fromRGB(239, 106, 138),
	Theme.donate,
	Color3.fromRGB(214, 58, 94),
	Theme.gold
}

local color = Color3.fromRGB(200, 200, 205)
local color2 = Color3.fromRGB(205, 140, 90)

local function commas(value)
	local v3 = tostring((math.floor(value or 0)))
	local v4 = string.reverse((string.gsub(string.reverse(v3), "(%d%d%d)", "%1,")))
	return (string.gsub(v4, "^,", ""))
end

local function robux(p) -- 4 equivalent calls inferred from this helper
	return v .. commas(p)
end

return {
	["robux"] = robux,
	install = function(self)
		local pages = self.pages
		local localPlayer = Players.LocalPlayer

		local function switcher(p, parent2)
			local segmented = UI.segmented({
				{ id = "donate", label = "Donate", icon = "heart", iconColor = Theme.donate },
				{ id = "donors", label = "Top Donors", icon = "crown", iconColor = Theme.gold }
			}, p, function(p2)
				if p2 ~= p then
					pages.show(p2)
				end
			end, 40)
			segmented.frame.LayoutOrder = 0
			segmented.frame.Parent = parent2
			return segmented
		end

		local page, parent2 = pages.newPage("donate", "Donate", "heart", Theme.donate, true)
		local donate = { frame = page }
		pages.donate = donate
		local v3 = switcher("donate", parent2)

		local frame = UI.new("Frame", {
			Name = "Intro",
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Theme.panelLight,
			LayoutOrder = 1,
			Parent = parent2
		}, { UI.corner(8), UI.pad(14, 14, 14, 14) })
		local icon = UI.icon("heart", 46, Theme.donate, { Name = "Heart", Parent = frame })

		UI.text({
			Text = "Support RoChess",
			FontFace = Theme.fontHeavy,
			TextSize = 20,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, -60, 0, 24),
			Position = UDim2.fromOffset(60, 0),
			Parent = frame
		})

		UI.text({
			Text = "If you're enjoying RoChess, a donation helps keep it growing.",
			TextSize = 14,
			TextColor3 = Theme.textDim,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, -60, 0, 0),
			Position = UDim2.fromOffset(60, 26),
			Parent = frame
		})

		local frame2 = UI.new("Frame", {
			Name = "Amounts",
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = 2,
			Parent = parent2
		}, { UI.new("UIGridLayout", {
				CellSize = UDim2.new(0.5, -5, 0, 62),
				CellPadding = UDim2.fromOffset(10, 10),
				SortOrder = Enum.SortOrder.LayoutOrder
			}) })

		local lastTime = 0
		local function prompt(p)
			if os.clock() - lastTime < 1 then
				return
			end

			lastTime = os.clock()

			if not pcall(function()
				MarketplaceService:PromptProductPurchase(localPlayer, p.id)
			end) then
				self.toast("Couldn't open the purchase. Try again in a moment.", Theme.loss)
			end
		end

		local v4 = {}

		for k, product in Config.DONATE_PRODUCTS do
			v4[k] = {
				button = UI.button({
					parent = frame2,
					name = "Donate" .. tostring(product.robux),
					style = "secondary",
					icon = "heart",
					iconSize = math.min(k, 6) * 2 + 18,
					iconColor = v2[math.min(k, #v2)],
					text = robux(product.robux), -- inferred equivalent call
					textSize = 21,
					font = Theme.fontHeavy,
					textColor = Theme.text,
					layoutOrder = k,
					onClick = function()
						prompt(product)
					end
				}),
				product = product
			}
		end

		local text = UI.text({
			Name = "Total",
			Text = "",
			RichText = true,
			TextSize = 15,
			TextColor3 = Theme.textDim,
			Size = UDim2.new(1, 0, 0, 22),
			Visible = false,
			LayoutOrder = 3,
			Parent = parent2
		})

		local text2 = UI.text({
			Name = "Note",
			Text = "",
			Visible = false,
			TextSize = 12,
			TextColor3 = Theme.textMuted,
			TextWrapped = true,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = 4,
			Parent = parent2
		})

		local idSet = {}
		local flag = false
		local function checkOnSale() -- 1 equivalent call inferred from this helper
			if flag then
				return
			end

			flag = true
			task.spawn(function()
				for _, v5 in v4 do
					if idSet[v5.product.id] then
						continue
					end

					local success, result = pcall(function()
						return MarketplaceService:GetProductInfo(v5.product.id, Enum.InfoType.Product)
					end)

					if not (success and type(result) == "table") then
						continue
					end

					idSet[v5.product.id] = true
					v5.button:setVisible(result.IsForSale ~= false)
				end

				flag = false
			end)
		end
		task.delay(2, checkOnSale)

		local function setTotalText(p) -- 4 equivalent calls inferred from this helper
			text.Text = string.format("You've donated <font color=\"#FFFFFF\">%s</font>. Thank you!", robux(p)) -- inferred equivalent call
		end
		local count = 0

		function donate.refreshTotal(p)
			count += 1
			local v5 = count
			local donated = self.donated or 0
			UI.reveal(text, donated > 0, 4)

			if donated <= 0 then
				return
			end

			if not p or donated <= p then
				setTotalText(donated) -- inferred equivalent call
				return
			end

			setTotalText(p) -- inferred equivalent call
			local numberValue = Instance.new("NumberValue")
			numberValue.Value = p
			numberValue.Changed:Connect(function(p2)
				if v5 == count then
					setTotalText(math.round(p2)) -- inferred equivalent call
				end
			end)
			UI.tween(numberValue, 0.8, { Value = donated }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out).Completed:Connect(function()
				numberValue:Destroy()

				if v5 == count then
					setTotalText(donated) -- inferred equivalent call
				end
			end)
		end

		local v5 = false
		local function loadInfo() -- 1 equivalent call inferred from this helper
			task.spawn(function()
				local request = self.request({ type = "donateInfo" })

				if type(request) ~= "table" then
					return
				end

				self.donated = tonumber(request.total) or 0

				if request.studio and not v5 then
					v5 = true
					text2.Text = "Studio: test purchases are free and only count until this test ends."
					text2.Visible = true
				end

				donate.refreshTotal()
			end)
		end

		function donate.onShow()
			v3.set("donate")
			checkOnSale() -- inferred equivalent call
			loadInfo() -- inferred equivalent call
		end

		local page2, parent3 = pages.newPage("donors", "Top Donors", "crown", Theme.gold, true)
		local donors = { frame = page2, scope = "global" }
		pages.donors = donors
		local v6 = switcher("donors", parent3)
		local segmented = UI.segmented({
			{ id = "global", label = "Global", icon = "globe" },
			{ id = "server", label = "This server", icon = "group" }
		}, donors.scope, function(scope)
			donors.scope = scope
			donors.load()
		end, 38)
		segmented.frame.LayoutOrder = 1
		segmented.frame.Parent = parent3
		local text3 = UI.text({
			Name = "Note",
			Text = "",
			TextSize = 13,
			TextColor3 = Theme.textMuted,
			Size = UDim2.new(1, 0, 0, 16),
			LayoutOrder = 2,
			Parent = parent3
		})

		local frame3 = UI.new("Frame", {
			Name = "List",
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = 3,
			Parent = parent3
		}, { UI.list(Enum.FillDirection.Vertical, 2) })

		local function addRow(k, entry)
			local v7 = entry.userId == localPlayer.UserId
			local frame4 = UI.new("Frame", {
				Size = UDim2.new(1, 0, 0, 44),
				BackgroundColor3 = v7 and Theme.rowActive or k % 2 == 1 and Theme.panelLight or Theme.panel,
				LayoutOrder = k,
				Parent = frame3
			}, { UI.corner(4) })

			if k == 1 then
				UI.icon("crown", 22, Theme.gold, {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(0, 17, 0.5, 0),
					Parent = frame4
				})
			else
				UI.text({
					Text = tostring(k),
					FontFace = Theme.fontHeavy,
					TextSize = 16,
					TextColor3 = k == 2 and color or k == 3 and color2 or Theme.textDim,
					Size = UDim2.new(0, 34, 1, 0),
					Parent = frame4
				})
			end

			UI.avatar({ userId = entry.userId }, 32, {
				Position = UDim2.new(0, 38, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				Parent = frame4
			})

			UI.text({
				Text = entry.name or "Player",
				FontFace = Theme.fontBold,
				TextSize = 16,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Size = UDim2.new(1, -194, 1, 0),
				Position = UDim2.fromOffset(80, 0),
				Parent = frame4
			})

			UI.text({
				Text = robux(entry.rating), -- inferred equivalent call
				FontFace = Theme.fontHeavy,
				TextSize = 17,
				TextXAlignment = Enum.TextXAlignment.Right,
				Size = UDim2.new(0, 100, 1, 0),
				Position = UDim2.new(1, -110, 0, 0),
				Parent = frame4
			})

			if self.profileRow then
				self.profileRow(frame4, entry.userId, "donors", nil, entry.name)
			end
		end

		local count2 = 0
		function donors.load()
			count2 += 1
			local v7 = count2

			for _, frame4 in frame3:GetChildren() do
				if frame4:IsA("Frame") then
					frame4:Destroy()
				end
			end

			text3.Text = "Loading..."
			task.spawn(function()
				local request = self.request({
					type = "leaderboard",
					class = "donated",
					scope = donors.scope
				})

				if v7 ~= count2 then
					return
				end

				if type(request) ~= "table" then
					text3.Text = "Couldn't load the board."
					return
				end

				local entries = request.entries or {}
				local count3 = #entries

				if donors.scope == "server" then
					text3.Text = count3 == 0 and "Nobody in this server has donated yet."
						or count3 == 1 and "1 donor in this server"
						or tostring(count3) .. " donors in this server"
				elseif count3 == 0 then
					text3.Text = "No donations yet. Be the first!"
				elseif request.isLocal then
					text3.Text = "Donors in this server (the global board appears once published)"
				else
					text3.Text = "Top donors worldwide"
				end

				for k, entry in entries do
					addRow(k, entry)
				end
			end)
		end

		function donors.onShow()
			v6.set("donors")
			segmented.set(donors.scope)
			donors.load()
		end

		local function rosterChanged()
			if donors.scope == "server" and page2.Visible then
				task.delay(1, function()
					if donors.scope == "server" and page2.Visible then
						donors.load()
					end
				end)
			end
		end
		Players.PlayerAdded:Connect(rosterChanged)
		Players.PlayerRemoving:Connect(rosterChanged)

		function self.handlers.donated(p)
			local robux2 = tonumber(p.robux) or 0
			local donated = self.donated or 0
			self.donated = tonumber(p.total) or donated + robux2
			donate.refreshTotal(donated)
			Sound.play("currency")
			task.delay(0.25, Sound.play, "unlock")
			local toast = self.toast("Thank you for donating " .. robux(robux2) .. "!", Theme.donate, 4) -- inferred equivalent call

			if toast then
				local list = UI.list(
					Enum.FillDirection.Horizontal,
					8,
					Enum.HorizontalAlignment.Left,
					Enum.VerticalAlignment.Center
				)
				list.Parent = toast
				local textLabel = toast:FindFirstChildOfClass("TextLabel")

				if textLabel then
					textLabel.LayoutOrder = 2
				end

				UI.icon("heart", 20, Theme.donate, { LayoutOrder = 1, Parent = toast })
			end

			if page.Visible then
				UI.pop(icon, 0.6, 0.35)

				local v7 = icon.AbsolutePosition + icon.AbsoluteSize / 2 - self.gui.AbsolutePosition
				local frame4 = UI.new("Frame", {
					Name = "DonateFx",
					Size = UDim2.new(),
					BackgroundTransparency = 1,
					ZIndex = 50,
					Parent = self.gui
				})
				UI.confetti(frame4, v7, {
					count = 36,
					spread = 180,
					zindex = 50,
					colors = {
						Theme.donate,
						Theme.gold,
						Color3.fromRGB(255, 160, 190),
						Color3.new(1, 1, 1)
					}
				})

				task.delay(2.5, frame4.Destroy, frame4)
			end

			if page2.Visible then
				task.delay(1, donors.load)
			end
		end

		function donate.state()
			local v7 = {
				total = text.Visible and text.ContentText or "",
				note = text2.Text,
				tiles = {}
			}

			for k, v8 in v4 do
				v7.tiles[k] = {
					text = v8.button.label.ContentText,
					visible = v8.button.holder.Visible
				}
			end

			v7.donorsNote = text3.Text
			local count3 = 0

			for _, frame4 in frame3:GetChildren() do
				if frame4:IsA("Frame") then
					count3 += 1
				end
			end

			v7.donorRows = count3
			return v7
		end
	end
}