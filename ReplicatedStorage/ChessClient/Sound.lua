local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local ContentProvider = game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Chess.Config)
local Haptics = require(script.Parent.Haptics)

local Sound = {}
Sound.enabled = true
local v = {}
local v2 = {}
local chessSounds = nil

local function make(name, id, volume, speed) -- 2 equivalent calls inferred from this helper
	local sound = Instance.new("Sound")
	sound.Name = name
	sound.SoundId = "rbxassetid://" .. tostring(id)
	sound.Volume = volume or 0.6
	sound.PlaybackSpeed = speed or 1
	sound.Parent = chessSounds
	return sound
end

function Sound.init()
	if chessSounds then
		return
	end

	chessSounds = Instance.new("Folder")
	chessSounds.Name = "ChessSounds"
	chessSounds.Parent = SoundService
	local v3 = {}

	for k, v4 in Config.SOUNDS do
		v[k] = make(k, v4.id, v4.volume, v4.speed) -- inferred equivalent call
		table.insert(v3, v[k])
	end

	for k, def in Config.UI_SOUNDS or {} do
		local v4 = { def = def, list = {}, last = -1e999, idx = 0 }

		for k2, id in def.ids do
			local list = v4.list
			list[k2] = make(k .. k2, id, def.volume, def.speed) -- inferred equivalent call
			table.insert(v3, v4.list[k2])
		end

		v2[k] = v4
	end

	task.spawn(function()
		pcall(ContentProvider.PreloadAsync, ContentProvider, v3)
	end)
end

function Sound.play(p, value)
	Haptics.play(p)

	if not Sound.enabled then
		return
	end

	local v3 = v[p]

	if v3 then
		v3.PlaybackSpeed = (Config.SOUNDS[p].speed or 1) * (value or 1)
		SoundService:PlayLocalSound(v3)
	else
		local v4 = v2[p]

		if not v4 or #v4.list == 0 then
			return
		end

		local now = os.clock()

		if now - v4.last < (v4.def.cooldown or 0.03) then
			return
		end

		v4.last = now
		local count = #v4.list
		local idx = math.random(1, count)

		if count > 1 and idx == v4.idx then
			idx = idx % count + 1
		end

		v4.idx = idx
		local item = v4.list[idx]
		local jitter = v4.def.jitter or 0
		item.PlaybackSpeed = (v4.def.speed or 1) * (value or 1) * (1 + (math.random() * 2 - 1) * jitter)
		SoundService:PlayLocalSound(item)
	end
end

function Sound.forMove(data)
	local san = data.san or ""

	if string.find(san, "[+#]") then
		Sound.play("check")
	elseif data.castle or string.sub(san, 1, 1) == "O" then
		Sound.play("castle")
	elseif data.promo or string.find(san, "=", 1, true) then
		Sound.play("promote")
	elseif data.captured or string.find(san, "x", 1, true) then
		Sound.play("capture")
	else
		Sound.play("move")
	end
end

local object = setmetatable({}, { __mode = "k" })

local function kind(button)
	local sfx = button:GetAttribute("Sfx")

	if sfx ~= nil then
		return sfx
	end

	local name = button.Name

	if name == "Back" or name == "Close" or name == "Cancel" then
		return "cancel"
	end

	local parent = button.Parent

	if parent and parent.Name == "Tabs" then
		return "tab"
	end

	if parent and parent.Name == "PromoColumn" or string.match(name, "^Ply%d+$") then
		return "none"
	end

	return "press"
end

Sound.kind = kind

local function usingMouse(): boolean
	local lastInputType = UserInputService:GetLastInputType()
	return lastInputType == Enum.UserInputType.MouseMovement
		or lastInputType == Enum.UserInputType.MouseButton1
		or lastInputType == Enum.UserInputType.MouseButton2
		or lastInputType == Enum.UserInputType.MouseWheel
		or lastInputType == Enum.UserInputType.Keyboard
end

local tweenInfo = TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.24, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local function squishScale(parent)
	local popScale = parent:FindFirstChild("PopScale")

	if popScale then
		return popScale
	end

	if parent:FindFirstChildOfClass("UIScale") then
		return nil
	end

	local popScale2 = Instance.new("UIScale")
	popScale2.Name = "PopScale"
	popScale2.Parent = parent
	return popScale2
end

local function canSquish(parent): boolean -- 1 equivalent call inferred from this helper
	if parent:GetAttribute("NoSquish") or parent.AnchorPoint ~= Vector2.new(0.5, 0.5) then
		return false
	end

	local parent2 = parent.Parent
	return not (parent2 and parent2:FindFirstChildWhichIsA("UIGridStyleLayout"))
end

local function squish(button, p) -- 3 equivalent calls inferred from this helper
	if not canSquish(button) then -- inferred equivalent call
		return
	end

	if p then
		local popScale = button:FindFirstChild("PopScale")

		if not popScale then
			if button:FindFirstChildOfClass("UIScale") then
				popScale = nil
			else
				popScale = Instance.new("UIScale")
				popScale.Name = "PopScale"
				popScale.Parent = button
			end
		end

		if not popScale then
			return
		end

		local v3 = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y, 1)
		TweenService:Create(popScale, tweenInfo, {
			Scale = math.clamp(1 - 8 / v3, 0.88, 0.985)
		}):Play()
	else
		local popScale = button:FindFirstChild("PopScale")

		if popScale and popScale.Scale < 1 then
			TweenService:Create(popScale, tweenInfo2, { Scale = 1 }):Play()
		end
	end
end
Sound.squish = squish

local function hook(button)
	if
		object[button]
		or not button:IsA("GuiButton")
		or (button.Name == "Input" or string.match(button.Name, "Dim$"))
	then
		return
	end

	object[button] = true
	button.Activated:Connect(function()
		local v3 = kind(button)

		if v3 ~= "none" then
			Sound.play(v3)
		end
	end)
	button.MouseEnter:Connect(function()
		if button.Active and usingMouse() and kind(button) ~= "none" then
			Sound.play("hover")
		end
	end)
	button.SelectionGained:Connect(function()
		Sound.play("hover")
	end)
	button.MouseButton1Down:Connect(function()
		if button.Active then
			squish(button, true) -- inferred equivalent call
		end
	end)
	button.MouseButton1Up:Connect(function()
		squish(button, false) -- inferred equivalent call
	end)
	button.MouseLeave:Connect(function()
		squish(button, false) -- inferred equivalent call
	end)
end

function Sound.attach(folder)
	for _, descendant in folder:GetDescendants() do
		hook(descendant)
	end

	folder.DescendantAdded:Connect(hook)
end

return Sound