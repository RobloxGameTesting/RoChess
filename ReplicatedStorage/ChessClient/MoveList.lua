local Theme = require(script.Parent.Theme)
local UI = require(script.Parent.UI)

local MoveList = {}
MoveList.__index = MoveList

function MoveList.new(parent)
	local self = setmetatable({}, MoveList)
	self.sans = {}
	self.current = 0
	self.rows = {}
	self.cells = {}
	self.badges = {}
	self.scroll = UI.scroll({ Name = "MoveList", Size = UDim2.fromScale(1, 1), Parent = parent })

	local list = UI.list(Enum.FillDirection.Vertical, 0)
	list.Parent = self.scroll
	self.empty = UI.text({
		Name = "Empty",
		Text = "",
		TextColor3 = Theme.textMuted,
		TextSize = 15,
		Size = UDim2.new(1, 0, 0, 40),
		LayoutOrder = 0,
		Parent = self.scroll
	})

	return self
end

function MoveList.setEmptyText(p, value)
	p.empty.Text = value or ""
	local empty = p.empty
	empty.Visible = #p.sans == 0 and (value or "") ~= ""
end

function MoveList:makeRow(layoutOrder)
	local frame = UI.new("Frame", {
		Name = "Row" .. layoutOrder,
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundColor3 = layoutOrder % 2 == 1 and Theme.rowAlt or Theme.row,
		LayoutOrder = layoutOrder,
		Parent = self.scroll
	})

	UI.text({
		Name = "Num",
		Text = tostring(layoutOrder) .. ".",
		FontFace = Theme.fontMedium,
		TextColor3 = Theme.textMuted,
		TextSize = 17,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(0, 44, 1, 0),
		Position = UDim2.fromOffset(12, 0),
		Parent = frame
	})

	self.rows[layoutOrder] = frame
	return frame
end

function MoveList:makeCell(p, text)
	local v = (p + 1) // 2
	local parent = self.rows[v] or self:makeRow(v)
	local v2 = p % 2 == 1
	local textButton = UI.new("TextButton", {
		Name = "Ply" .. p,
		Text = text,
		FontFace = Theme.fontBold,
		TextSize = 17,
		TextColor3 = Theme.textSoft,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundColor3 = Theme.rowActive,
		BackgroundTransparency = 1,
		Size = UDim2.new(0.5, -40, 1, -6),
		Position = v2 and UDim2.new(0, 56, 0, 3) or UDim2.new(0.5, 28, 0, 3),
		Parent = parent
	}, { UI.corner(3), UI.pad(0, 6, 0, 6) })
	textButton.Activated:Connect(function()
		if self.onSelect then
			self.onSelect(p)
		end
	end)
	self.cells[p] = textButton
	return textButton
end

function MoveList:setMoves(list)
	for _, row in self.rows do
		row:Destroy()
	end

	self.rows = {}
	self.cells = {}
	self.sans = {}

	for k, item in list do
		self.sans[k] = item
		self:makeCell(k, item)
	end

	local empty = self.empty
	empty.Visible = #list == 0 and self.empty.Text ~= ""
	self:setCurrent(math.min(self.current, #list), true)
end

function MoveList:push(p)
	table.insert(self.sans, p)
	local cell = self:makeCell(#self.sans, p)
	self.empty.Visible = false

	local position = cell.Position
	cell.Position = position - UDim2.fromOffset(10, 0)
	cell.TextTransparency = 1
	UI.tween(cell, UI.SNAP, { Position = position, TextTransparency = 0 })
end

function MoveList:pop()
	local count = #self.sans

	if count == 0 then
		return
	end

	local cell = self.cells[count]

	if cell then
		cell:Destroy()
	end

	self.cells[count] = nil
	table.remove(self.sans)

	if count % 2 == 1 then
		local v = (count + 1) // 2

		if self.rows[v] then
			self.rows[v]:Destroy()
			self.rows[v] = nil
		end
	end

	if self.current > #self.sans then
		self:setCurrent(#self.sans)
	end
end

function MoveList.setBadge(p, p2, backgroundColor, value, p3)
	local cell = p.cells[p2]

	if not cell then
		return
	end

	local badge = cell:FindFirstChild("Badge")

	if badge then
		badge:Destroy()
	end

	if not backgroundColor then
		return
	end

	local frame = UI.new("Frame", {
		Name = "Badge",
		Size = UDim2.fromOffset(18, 18),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		BackgroundColor3 = backgroundColor,
		Parent = cell
	}, { UI.corner(UDim.new(0.3, 0)) })
	local popScale = Instance.new("UIScale")
	popScale.Name = "PopScale"
	popScale.Scale = 0
	popScale.Parent = frame
	task.delay(math.min(p2, 80) * 0.006, UI.pop, frame, 0.2, 0.2)

	if p3 then
		UI.icon(p3, 13, Color3.new(1, 1, 1), {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Parent = frame
		})
	else
		UI.text({
			Text = value or "",
			FontFace = Theme.fontHeavy,
			TextSize = 11,
			Size = UDim2.fromScale(1, 1),
			Parent = frame
		})
	end
end

function MoveList.clearBadges(p)
	for _, cell in p.cells do
		local badge = cell:FindFirstChild("Badge")

		if badge then
			badge:Destroy()
		end
	end
end

function MoveList:setCurrent(current, p)
	local cell = self.cells[self.current]

	if cell and self.current ~= current then
		UI.tween(cell, UI.FAST, { BackgroundTransparency = 1, TextColor3 = Theme.textSoft })
	end

	self.current = current
	local cell2 = self.cells[current]

	if cell2 then
		UI.tween(cell2, UI.FAST, { BackgroundTransparency = 0, TextColor3 = Theme.text })

		task.defer(function()
			if not cell2.Parent then
				return
			end

			local v = cell2.Parent.AbsolutePosition.Y - self.scroll.AbsolutePosition.Y + self.scroll.CanvasPosition.Y
			local y = self.scroll.AbsoluteSize.Y
			local y2 = self.scroll.CanvasPosition.Y
			local vector2 = nil

			if v < y2 then
				vector2 = Vector2.new(0, v)
			else
				local v2 = v + 34

				if y2 + y < v2 then
					vector2 = Vector2.new(0, v + 34 - y)
				end
			end

			if vector2 then
				if p then
					self.scroll.CanvasPosition = vector2
				else
					UI.tween(self.scroll, UI.SNAP, { CanvasPosition = vector2 })
				end
			end
		end)
	elseif current == 0 then
		UI.tween(self.scroll, UI.SNAP, { CanvasPosition = Vector2.zero })
	end
end

return MoveList