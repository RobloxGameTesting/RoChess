local Config = require(script.Parent.Config)

local v = {}
local Sprites = {}

local v2 = { "P", "N", "B", "R", "Q", "K" }

for k, v3 in Config.SPRITE_PIECES do
	v[v3] = k - 1
end

local v3 = {}

for k, v4 in Config.SPRITE_ICONS do
	v3[v4] = k - 1
end

local source = nil

local v4 = {}

function v4.heart(parent)
	local v5 = {}
	local function piece(name, p, p2, rotation, cornerRadius)
		local frame = Instance.new("Frame")
		frame.Name = name
		frame.BorderSizePixel = 0
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Size = UDim2.fromScale(0.49, 0.49)
		frame.Position = UDim2.fromScale(p, p2)
		frame.Rotation = rotation
		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = cornerRadius
		uiCorner.Parent = frame
		frame.Parent = parent
		table.insert(v5, frame)
	end
	piece("Point", 0.5, 0.518, 45, UDim.new(0.1, 0))
	piece("Left", 0.3267588386092959, 0.3447588386092959, 0, UDim.new(0.5, 0))
	piece("Right", 0.6732411613907041, 0.3447588386092959, 0, UDim.new(0.5, 0))
	return v5
end

function v4.token(parent)
	local v5 = {}
	local function piece(name, p, rotation, cornerRadius, shade)
		local frame = Instance.new("Frame")
		frame.Name = name
		frame.BorderSizePixel = 0
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Size = UDim2.fromScale(p, p)
		frame.Position = UDim2.fromScale(0.5, 0.5)
		frame.Rotation = rotation
		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = cornerRadius
		uiCorner.Parent = frame

		if shade then
			frame:SetAttribute("Shade", shade)
		end

		frame.Parent = parent
		table.insert(v5, frame)
	end
	piece("Rim", 0.86, 0, UDim.new(0.5, 0))
	piece("Face", 0.64, 0, UDim.new(0.5, 0), 0.3)
	piece("Gem", 0.27, 45, UDim.new(0.18, 0))
	return v5
end

local function box(list, parent, name, p, p2, p3, p4, cornerRadius, shade, value)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.BorderSizePixel = 0
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.fromScale(p, p2)
	frame.Size = UDim2.fromScale(p3, p4)
	frame.Rotation = value or 0

	if cornerRadius then
		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = cornerRadius
		uiCorner.Parent = frame
	end

	if shade then
		frame:SetAttribute("Shade", shade)
	end

	frame.Parent = parent
	table.insert(list, frame)
	return frame
end

function v4.crate(p)
	local v5 = {}
	box(v5, p, "Body", 0.5, 0.6, 0.8, 0.52, UDim.new(0.12, 0), 0.28)
	box(v5, p, "Lid", 0.5, 0.3, 0.88, 0.22, UDim.new(0.25, 0))
	box(v5, p, "Strap", 0.5, 0.6, 0.16, 0.52, nil, 0.5)
	box(v5, p, "Lock", 0.5, 0.43, 0.2, 0.18, UDim.new(0.25, 0))
	return v5
end

function v4.grid(p)
	local v5 = {}

	for k, v6 in {
		{ 0.3, 0.3 },
		{ 0.7, 0.3 },
		{ 0.3, 0.7 },
		{ 0.7, 0.7 }
	} do
		box(v5, p, "Tile" .. k, v6[1], v6[2], 0.34, 0.34, UDim.new(0.25, 0), (k == 2 or k == 3) and 0.35 or nil)
	end

	return v5
end

function v4.boardicon(p)
	local v5 = {}
	box(v5, p, "Edge", 0.5, 0.5, 0.86, 0.86, UDim.new(0.14, 0), 0.55)

	for k, v6 in {
		{ 0.31, 0.31 },
		{ 0.69, 0.31 },
		{ 0.31, 0.69 },
		{ 0.69, 0.69 }
	} do
		box(v5, p, "Sq" .. k, v6[1], v6[2], 0.36, 0.36, UDim.new(0.08, 0), (k == 2 or k == 3) and 0.4 or nil)
	end

	return v5
end

function v4.landscape(parent)
	local v5 = {}
	local parent2 = box(v5, parent, "Frame", 0.5, 0.5, 0.88, 0.72, UDim.new(0.14, 0), 0.5)
	parent2.ClipsDescendants = true
	local box_2 = box(v5, parent, "Sun", 0.7, 0.36, 0.16, 0.16, UDim.new(0.5, 0))
	box_2.Parent = parent
	local v6 = box(v5, parent, "Hill", 0.5, 1.15, 0.9, 0.9, UDim.new(0.5, 0))
	v6.Parent = parent2
	v6.Position = UDim2.fromScale(0.35, 1.12)
	local v7 = box(v5, parent, "Hill2", 0.5, 1.15, 0.9, 0.9, UDim.new(0.5, 0), 0.2)
	v7.Parent = parent2
	v7.Position = UDim2.fromScale(0.85, 1.25)
	v7.ZIndex = 0
	return v5
end

function v4.tophat(p)
	local v5 = {}
	box(v5, p, "Crown", 0.5, 0.44, 0.5, 0.5, UDim.new(0.08, 0))
	box(v5, p, "Band", 0.5, 0.6, 0.5, 0.12, nil, 0.45)
	box(v5, p, "Brim", 0.5, 0.74, 0.86, 0.12, UDim.new(0.5, 0))
	return v5
end

function v4.gift(parent)
	local v5 = {}
	box(v5, parent, "Box", 0.5, 0.66, 0.74, 0.5, UDim.new(0.1, 0), 0.25)
	box(v5, parent, "Lid", 0.5, 0.39, 0.86, 0.17, UDim.new(0.2, 0))
	box(v5, parent, "Ribbon", 0.5, 0.63, 0.15, 0.56, nil, 0.5)
	box(v5, parent, "BowL", 0.39, 0.22, 0.2, 0.2, UDim.new(0.35, 0), nil, 45)
	box(v5, parent, "BowR", 0.61, 0.22, 0.2, 0.2, UDim.new(0.35, 0), nil, 45)
	return v5
end

function v4.pumpkin(parent)
	local v5 = {}
	box(v5, parent, "LobeL", 0.33, 0.6, 0.46, 0.62, UDim.new(0.5, 0), 0.22)
	box(v5, parent, "LobeR", 0.67, 0.6, 0.46, 0.62, UDim.new(0.5, 0), 0.22)
	box(v5, parent, "Middle", 0.5, 0.6, 0.46, 0.68, UDim.new(0.5, 0))
	box(v5, parent, "RibL", 0.39, 0.6, 0.05, 0.5, UDim.new(0.5, 0), 0.32)
	box(v5, parent, "RibR", 0.61, 0.6, 0.05, 0.5, UDim.new(0.5, 0), 0.32)
	box(v5, parent, "Stem", 0.52, 0.2, 0.1, 0.2, UDim.new(0.3, 0), 0.6, 12)
	box(v5, parent, "Leaf", 0.64, 0.22, 0.18, 0.08, UDim.new(0.5, 0), 0.45, -24)
	return v5
end

local object = setmetatable({}, { __mode = "k" })

local function clearVector(p) -- 3 equivalent calls inferred from this helper
	local v5 = object[p]

	if not v5 then
		return
	end

	object[p] = nil

	for _, conn in v5.conns do
		conn:Disconnect()
	end

	v5.holder:Destroy()
end

local function applyVector(parent, name)
	local v5 = object[parent]

	if v5 and v5.name == name and v5.holder.Parent == parent then
		return
	end

	clearVector(parent) -- inferred equivalent call
	parent.Image = ""
	parent.ImageRectOffset = Vector2.zero
	parent.ImageRectSize = Vector2.zero
	local vectorIcon = Instance.new("Frame")
	vectorIcon.Name = "VectorIcon"
	vectorIcon.BackgroundTransparency = 1
	vectorIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	vectorIcon.Position = UDim2.fromScale(0.5, 0.5)
	vectorIcon.Size = UDim2.fromScale(1, 1)
	local uiAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uiAspectRatioConstraint.Parent = vectorIcon
	local v6 = v4[name](vectorIcon)
	local function sync()
		for _, v7 in v6 do
			local shade = v7:GetAttribute("Shade")
			v7.BackgroundColor3 = shade and parent.ImageColor3:Lerp(Color3.new(0, 0, 0), shade) or parent.ImageColor3
			v7.BackgroundTransparency = parent.ImageTransparency
		end
	end
	sync()
	vectorIcon.Parent = parent
	object[parent] = {
		name = name,
		holder = vectorIcon,
		conns = {
			parent:GetPropertyChangedSignal("ImageColor3"):Connect(sync),
			parent:GetPropertyChangedSignal("ImageTransparency"):Connect(sync)
		}
	}
end

local function buildFallback()
	local success, result = pcall(function()
		local AssetService = game:GetService("AssetService")
		local EncodingService = game:GetService("EncodingService")
		local SpriteFallback = require(script.Parent.SpriteFallback)
		local decompressBuffer = EncodingService:DecompressBuffer(
			EncodingService:Base64Decode(buffer.fromstring(SpriteFallback)),
			Enum.CompressionAlgorithm.Zstd
		)

		local v5 = buffer.len(decompressBuffer)
		local buf = buffer.create(v5 * 4)

		for i = 0, v5 - 1 do
			local v6 = buffer.readu8(decompressBuffer, i)
			local v7 = bit32.rshift(v6, 4) * 17
			local v8 = bit32.band(v6, 15) * 17
			buffer.writeu32(buf, i * 4, v7 + v7 * 256 + v7 * 65536 + v8 * 16777216)
		end

		local editableImage = AssetService:CreateEditableImage({ Size = Vector2.new(512, 512) })
		editableImage:WritePixelsBuffer(Vector2.zero, Vector2.new(512, 512), buf)
		return {
			content = Content.fromObject(editableImage),
			scale = 0.5,
			editable = editableImage
		}
	end)

	if success then
		return result
	end

	warn("[Chess] Sprite fallback failed (set Config.SPRITE_ASSET_ID): " .. tostring(result))
	return { image = "", scale = 1 }
end

local function getSource() -- 1 equivalent call inferred from this helper
	if source then
		return source
	end

	if Config.SPRITE_ASSET_ID and Config.SPRITE_ASSET_ID ~= 0 then
		source = {
			image = "rbxassetid://" .. tostring(Config.SPRITE_ASSET_ID),
			scale = 1
		}
	else
		source = buildFallback()
	end

	return source
end

function Sprites.rect(p)
	local v5 = v[p]

	if v5 then
		return Vector2.new(v5 % 4 * 256, v5 // 4 * 256), Vector2.new(256, 256)
	end

	local v6 = v3[p]

	if v6 then
		return Vector2.new(v6 % 16 * 64, 768 + v6 // 16 * 64), Vector2.new(64, 64)
	end

	return nil
end

function v4.puzzle(p)
	local v5 = {}
	box(v5, p, "Body", 0.44, 0.58, 0.6, 0.6, UDim.new(0.14, 0))
	box(v5, p, "KnobTop", 0.44, 0.22, 0.27, 0.27, UDim.new(0.5, 0))
	box(v5, p, "KnobRight", 0.8, 0.58, 0.27, 0.27, UDim.new(0.5, 0))
	return v5
end

function v4.school(parent)
	local v5 = {}
	local udim = UDim.new(0.5, 0)
	box(v5, parent, "Body", 0.48, 0.48, 0.72, 0.44, udim)
	box(v5, parent, "Front", 0.21, 0.5, 0.28, 0.3, udim)
	box(v5, parent, "Bump1", 0.27, 0.36, 0.3, 0.3, udim)
	box(v5, parent, "Bump2", 0.4, 0.28, 0.32, 0.3, udim)
	box(v5, parent, "Bump3", 0.56, 0.26, 0.32, 0.3, udim)
	box(v5, parent, "Bump4", 0.7, 0.33, 0.3, 0.3, udim)
	box(v5, parent, "Back", 0.79, 0.47, 0.24, 0.26, udim)
	box(v5, parent, "Temporal", 0.43, 0.6, 0.4, 0.24, udim)
	box(v5, parent, "Cerebellum", 0.72, 0.63, 0.22, 0.16, udim, 0.28)
	box(v5, parent, "Stem", 0.6, 0.75, 0.08, 0.2, UDim.new(0.45, 0), 0.32, -18)
	box(v5, parent, "Lateral", 0.42, 0.53, 0.34, 0.045, udim, 0.45, -8)
	box(v5, parent, "Fold1", 0.33, 0.36, 0.12, 0.04, udim, 0.45, 20)
	box(v5, parent, "Fold2", 0.5, 0.32, 0.12, 0.04, udim, 0.45, -15)
	box(v5, parent, "Fold3", 0.66, 0.38, 0.12, 0.04, udim, 0.45, 25)
	return v5
end

function v4.rook(p)
	local v5 = {}
	box(v5, p, "Base", 0.5, 0.84, 0.64, 0.12, UDim.new(0.4, 0))
	box(v5, p, "Foot", 0.5, 0.74, 0.5, 0.08, UDim.new(0.3, 0))
	box(v5, p, "Body", 0.5, 0.54, 0.36, 0.36, UDim.new(0.08, 0))
	box(v5, p, "Cap", 0.5, 0.33, 0.52, 0.1, UDim.new(0.3, 0))

	for k, v6 in { 0.3, 0.5, 0.7 } do
		box(v5, p, "Crenel" .. k, v6, 0.22, 0.13, 0.14, UDim.new(0.2, 0))
	end

	return v5
end

local v5 = {}

for k, v6 in Config.ICON_ATLAS and Config.ICON_ATLAS.names or {} do
	v5[v6] = k - 1
end

local v6 = {}
local function getAtlas(value)
	local v7 = value or "big"
	local v8 = v6[v7]

	if v8 ~= nil then
		return v8 or nil
	end

	v6[v7] = false
	local RunService = game:GetService("RunService")

	if not RunService:IsClient() then
		return nil
	end

	local success, result = pcall(function()
		local module = require(script.Parent[v7 == "small" and "IconDataSmall" or "IconData"])
		local w = module.w
		local h = module.h
		local data = module.data
		local v9 = {}

		for i = 1, 64 do
			v9[string.byte("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/", i)] = i - 1
		end

		local buf = buffer.create(#data)
		local count = 0

		for i = 1, #data, 4 do
			local v10, v11, v12, v13 = string.byte(data, i, i + 3)
			local v14 = v9[v10] * 262144 + v9[v11] * 4096 + (v9[v12] or 0) * 64 + (v9[v13] or 0)
			buffer.writeu8(buf, count, v14 // 65536)
			count += 1

			if v12 ~= 61 then
				buffer.writeu8(buf, count, v14 // 256 % 256)
				count += 1
			end

			if v13 == 61 then
				continue
			end

			buffer.writeu8(buf, count, v14 % 256)
			count += 1
		end

		local buf2 = buffer.create(w * h * 4)
		local count2 = 0
		local total = 0

		while count2 < count do
			local v10 = buffer.readu8(buf, count2)
			count2 += 1
			local v11 = v10 // 16
			local v12 = v10 % 16

			if v12 == 15 then
				repeat
					local v13 = buffer.readu8(buf, count2)
					count2 += 1
					v12 += v13
				until v13 ~= 255
			end

			local v13 = v11 * 17 * 16777216 + 16777215

			for _ = 1, v12 do
				buffer.writeu32(buf2, total, v13)
				total += 4
			end
		end

		local AssetService = game:GetService("AssetService")
		local editableImage = AssetService:CreateEditableImage({ Size = Vector2.new(w, h) })
		editableImage:WritePixelsBuffer(Vector2.zero, Vector2.new(w, h), buf2)
		return {
			content = Content.fromObject(editableImage),
			cell = module.cell or Config.ICON_ATLAS.cell
		}
	end)

	if success then
		v6[v7] = result
		return result
	end

	warn("[Sprites] icon atlas (" .. v7 .. ") unavailable, using the old icons:", result)
	return nil
end

Sprites.getAtlas = getAtlas

local object2 = setmetatable({}, { __mode = "k" })

local object3 = setmetatable({}, { __mode = "k" })
local function paintAtlas(instance): boolean
	local v7 = object2[instance]
	local v8 = v7 and v5[v7]

	if not v8 then
		return false
	end

	local x = instance.AbsoluteSize.X
	object3[instance] = x <= 40
	local v9 = x <= 40 and getAtlas("small") or getAtlas("big") or getAtlas("small")

	if not v9 then
		return false
	end

	local perRow = Config.ICON_ATLAS.perRow
	instance.ImageContent = v9.content
	instance.ImageRectOffset = Vector2.new(v8 % perRow * v9.cell, v8 // perRow * v9.cell)
	instance.ImageRectSize = Vector2.new(v9.cell, v9.cell)
	return true
end

local v7 = { arrowhead = true }

function Sprites:apply(name)
	if v5[name] and not v7[name] then
		object2[self] = name

		if paintAtlas(self) then
			clearVector(self) -- inferred equivalent call

			if not self:GetAttribute("AtlasSized") then
				self:SetAttribute("AtlasSized", true)
				self:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
					if object2[self] and object3[self] ~= (self.AbsoluteSize.X <= 40) then
						paintAtlas(self)
					end
				end)
			end

			return
		end
	end

	object2[self] = nil

	if v4[name] then
		applyVector(self, name)
		return
	end

	clearVector(self) -- inferred equivalent call
	local v8 = Config.PIECE_IMAGES and Config.PIECE_IMAGES[name]

	if v8 then
		self.Image = "rbxassetid://" .. tostring(v8)

		local v9 = string.sub(name, 2)

		if v9 == "K" or v9 == "Q" then
			self.ImageRectOffset = Vector2.zero
			self.ImageRectSize = Vector2.zero
		elseif v9 == "P" then
			self.ImageRectOffset = Vector2.new(19, 19)
			self.ImageRectSize = Vector2.new(218, 218)
		else
			self.ImageRectOffset = Vector2.new(10, 10)
			self.ImageRectSize = Vector2.new(236, 236)
		end
	else
		local source2 = getSource() -- inferred equivalent call

		local rect, v9 = Sprites.rect(name)

		if not rect then
			self.ImageTransparency = 1
			return
		end

		if source2.content then
			self.ImageContent = source2.content
		else
			self.Image = source2.image
		end

		self.ImageRectOffset = rect * source2.scale
		self.ImageRectSize = v9 * source2.scale
	end
end

function Sprites.pieceName(p)
	if p == 0 then
		return nil
	end

	return (p > 0 and "w" or "b") .. v2[math.abs(p)]
end

function Sprites:applyPiece(p)
	local pieceName = Sprites.pieceName(p)

	if not pieceName then
		self.Visible = false

		return
	end

	Sprites.apply(self, pieceName)
	self.Visible = true
end

function Sprites.icon(p, items)
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.BackgroundTransparency = 1
	imageLabel.ScaleType = Enum.ScaleType.Fit
	Sprites.apply(imageLabel, p)

	if items then
		for k, item in items do
			imageLabel[k] = item
		end
	end

	return imageLabel
end

return Sprites