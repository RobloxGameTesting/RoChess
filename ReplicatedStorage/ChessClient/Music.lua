local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Chess.Config)

local Music = {}

local v = true
local flag = false
local chessMusic = nil
local v2 = {}
local count = 0
local count2 = 0

local function shuffle()
	v2 = {}

	for i = 1, #Config.MUSIC do
		v2[i] = i
	end

	for i = #v2, 2, -1 do
		local v3 = math.random(1, i)
		local v4 = v2
		local v5 = v2
		local v6 = v2[v3]
		local v7 = v2[i]
		v4[i] = v6
		v5[v3] = v7
	end

	count = 0
end

local function fade(MUSIC_VOLUME, value) -- 3 equivalent calls inferred from this helper
	if chessMusic then
		TweenService:Create(chessMusic, TweenInfo.new(value or 2), { Volume = MUSIC_VOLUME }):Play()
	end
end

local function playNext()
	count2 += 1
	local v3 = count2

	if not v or #Config.MUSIC == 0 then
		return
	end

	for _ = 1, #Config.MUSIC do
		if count >= #v2 then
			shuffle()
		end

		count += 1
		local v4 = Config.MUSIC[v2[count]]
		chessMusic.SoundId = "rbxassetid://" .. tostring(v4.id)
		chessMusic.Volume = 0
		local v5 = true
		pcall(function()
			ContentProvider:PreloadAsync({ chessMusic }, function(_, p)
				v5 = p == Enum.AssetFetchStatus.Success
			end)
		end)

		if v3 ~= count2 or not v then
			break
		end

		if v5 then
			chessMusic.TimePosition = 0
			chessMusic:Play()
			fade(Config.MUSIC_VOLUME) -- inferred equivalent call
			Music.current = v4.name
			break
		end
	end
end

function Music.init()
	if flag then
		return
	end

	flag = true
	chessMusic = Instance.new("Sound")
	chessMusic.Name = "ChessMusic"
	chessMusic.Volume = 0
	chessMusic.Parent = SoundService
	chessMusic.Ended:Connect(function()
		task.wait(1.5)
		playNext()
	end)
	shuffle()

	if v then
		task.spawn(playNext)
	end
end

function Music.setEnabled(p)
	local v3 = p ~= false

	if v3 == v then
		return
	end

	v = v3

	if not flag then
		return
	end

	if v3 then
		if not (chessMusic.IsPaused and chessMusic.TimePosition > 0) then
			task.spawn(playNext)
			return
		end

		chessMusic:Resume()
		fade(Config.MUSIC_VOLUME) -- inferred equivalent call
	else
		count2 += 1
		fade(0, 0.6) -- inferred equivalent call
		task.delay(0.6, function()
			if not v then
				chessMusic:Pause()
			end
		end)
	end
end

return Music