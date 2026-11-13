local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Chess"):WaitForChild("Config"))

local Haptics = {}
Haptics.enabled = true
Haptics.force = false

function Haptics.watching(): boolean
	return false
end

local haptics = Config.HAPTICS or {}
local v = {}
local nowsByName = {}
local v2 = -1e999
local v3 = 0
local chessHaptics = nil
local v4 = {}

local set = {
	[Enum.UserInputType.MouseButton1] = true,
	[Enum.UserInputType.MouseButton2] = true,
	[Enum.UserInputType.MouseButton3] = true,
	[Enum.UserInputType.MouseMovement] = true,
	[Enum.UserInputType.MouseWheel] = true,
	[Enum.UserInputType.Keyboard] = true
}

local function note(name, p) -- 7 equivalent calls inferred from this helper
	table.insert(v4, { name = name, result = p })

	if #v4 > 40 then
		table.remove(v4, 1)
	end
end

local function make(name, haptic) -- 1 equivalent call inferred from this helper
	local success, result = pcall(function()
		if not chessHaptics then
			chessHaptics = Instance.new("Folder")
			chessHaptics.Name = "ChessHaptics"
			chessHaptics.Parent = workspace
		end

		local hapticEffect = Instance.new("HapticEffect")
		hapticEffect.Name = name
		hapticEffect.Type = haptic.keys and Enum.HapticEffectType.Custom or Enum.HapticEffectType[haptic.type]
		hapticEffect.Parent = chessHaptics

		if not haptic.keys then
			return hapticEffect
		end

		local floatCurveKeys = {}

		for k, key in haptic.keys do
			floatCurveKeys[k] = FloatCurveKey.new(key[1], key[2], Enum.KeyInterpolationMode.Linear)
		end

		hapticEffect:SetWaveformKeys(floatCurveKeys)

		return hapticEffect
	end)

	if success then
		return result
	end

	warn("[Chess] haptic " .. name .. ": " .. tostring(result))
	return false
end

function Haptics.init()
	for k, haptic in haptics do
		if v[k] == nil then
			v[k] = make(k, haptic) -- inferred equivalent call
		end
	end
end

local function canFeel() -- 1 equivalent call inferred from this helper
	return Haptics.force or not set[UserInputService:GetLastInputType()]
end

function Haptics.play(name)
	local haptic = haptics[name]

	if not haptic then
		return false
	end

	if Haptics.enabled then
		if haptic.game and Haptics.watching() then
			note(name, "spectating") -- inferred equivalent call
			return false
		elseif canFeel() then -- inferred equivalent call
			local now = os.clock()
			local weight = haptic.weight or 1

			if now - v2 < (Config.HAPTIC_MERGE or 0.06) and weight <= v3 then
				note(name, "merged") -- inferred equivalent call
				return false
			elseif haptic.cooldown and now - (nowsByName[name] or -1e999) < haptic.cooldown then
				note(name, "cooldown") -- inferred equivalent call
				return false
			else
				local result = v[name]

				if result == nil then
					local success
					success, result = pcall(function()
						if not chessHaptics then
							chessHaptics = Instance.new("Folder")
							chessHaptics.Name = "ChessHaptics"
							chessHaptics.Parent = workspace
						end

						local hapticEffect = Instance.new("HapticEffect")
						hapticEffect.Name = name
						hapticEffect.Type = haptic.keys and Enum.HapticEffectType.Custom
							or Enum.HapticEffectType[haptic.type]
						hapticEffect.Parent = chessHaptics

						if not haptic.keys then
							return hapticEffect
						end

						local floatCurveKeys = {}

						for k, key in haptic.keys do
							floatCurveKeys[k] = FloatCurveKey.new(key[1], key[2], Enum.KeyInterpolationMode.Linear)
						end

						hapticEffect:SetWaveformKeys(floatCurveKeys)

						return hapticEffect
					end)

					if not success then
						warn("[Chess] haptic " .. name .. ": " .. tostring(result))
						result = false
					end

					v[name] = result
				end

				if result then
					v2 = now
					v3 = weight
					nowsByName[name] = now
					local v5 = pcall(result.Play, result)
					note(name, v5 and "played" or "failed") -- inferred equivalent call
					return v5
				end

				note(name, "unsupported") -- inferred equivalent call
				return false
			end
		else
			note(name, "pointer") -- inferred equivalent call
			return false
		end
	else
		note(name, "off") -- inferred equivalent call
		return false
	end
end

function Haptics.debug(data)
	if data.force ~= nil then
		Haptics.force = data.force == true
	end

	if data.clear then
		table.clear(v4)
		v2 = -1e999
		v3 = 0
		table.clear(nowsByName)
	end

	local played

	if type(data.play) == "string" then
		played = Haptics.play(data.play)
	end

	local count = 0
	local count2 = 0

	for _, v5 in v do
		if v5 then
			count += 1
		else
			count2 += 1
		end
	end

	local log = {}

	for _, v5 in v4 do
		table.insert(log, v5.name .. ":" .. v5.result)
	end

	return {
		enabled = Haptics.enabled,
		force = Haptics.force,
		made = count,
		failed = count2,
		played = played,
		lastInput = UserInputService:GetLastInputType().Name,
		log = log
	}
end

return Haptics