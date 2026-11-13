local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Chess = ReplicatedStorage:WaitForChild("Chess")
local Bot = require(Chess:WaitForChild("Bot"))
local Engine = require(Chess:WaitForChild("Engine"))

local VortexBot = {}
VortexBot.THINK_TIMEOUT = 4

local function fallback(p, list, p2, p3)
	return Bot.think(p, list, p2, p3)
end

local v = nil
function VortexBot._setServerRequest(p)
	v = p
end

local function askVortex(startFen: string?, moves, data)
	local v2 = {
		startFen = startFen,
		moves = moves,
		persona = {
			rating = data.rating,
			noise = data.noise,
			blunder = data.blunder,
			time = data.time
		}
	}

	if RunService:IsServer() then
		if v then
			return v(startFen, moves, v2.persona)
		end

		return nil
	else
		local vortexThink = Chess:FindFirstChild("VortexThink")

		if not vortexThink then
			return nil
		end

		local v3 = { done = false, result = nil }
		task.spawn(function()
			local success, result = pcall(function()
				return vortexThink:InvokeServer(v2)
			end)

			v3.result = success and result or nil
			v3.done = true
		end)
		local v4 = os.clock() + math.min(tonumber(data.time) or 1, 1) + VortexBot.THINK_TIMEOUT

		while not v3.done do
			if v4 < os.clock() then
				return nil
			end

			task.wait(0.05)
		end

		return v3.result
	end
end

local random = Random.new()

function VortexBot.think(startFen: string?, moves, p, p2)
	if (p.rating or 0) < 1100 then
		return fallback(startFen, moves, p, p2)
	end

	if (startFen == nil or startFen == Engine.START_FEN) and #moves < 16 then
		local bookMove = Bot.bookMove(moves)

		if bookMove and random:NextNumber() < 0.9 then
			return bookMove, { book = true }
		end
	end

	local v2 = askVortex(startFen, moves, p)

	if p2 and p2.cancelled and p2.cancelled() then
		return nil, nil
	end

	if type(v2) ~= "table" or v2.uci == nil and v2.score == nil or v2.uci == nil then
		return fallback(startFen, moves, p, p2)
	end

	return v2.uci, {
		score = v2.score,
		depth = v2.depth,
		nodes = v2.nodes,
		time = (v2.time or 0) / 1000
	}
end

local v2 = nil
function VortexBot._setServerEval(p)
	v2 = p
end

function VortexBot.evaluate(p, p2: number?)
	if not (RunService:IsServer() and v2) then
		return nil, "off"
	end

	local success, result, v3 = pcall(v2, p, p2)

	if success then
		return result, v3
	end

	return nil, "failed"
end

function VortexBot._debugEval(p)
	v2 = p
end

local v3 = nil
function VortexBot._setServerReview(p)
	v3 = p
end

VortexBot.lastReviewError = nil
function VortexBot.reviewMoves(p, p2)
	if not (RunService:IsServer() and v3) then
		return nil, "off"
	end

	local success, result, v4 = pcall(v3, p, p2)

	if success then
		return result, v4
	end

	return nil, "failed"
end

function VortexBot._debugReview(p)
	v3 = p
end

local v4 = nil
function VortexBot._setServerReport(p)
	v4 = p
end

function VortexBot.reportGame(p)
	if type(p) ~= "table" or type(p.moves) ~= "table" or #p.moves == 0 then
		return
	end

	if RunService:IsServer() then
		if v4 then
			task.spawn(pcall, v4, p)
		end
	else
		local vortexGame = Chess:FindFirstChild("VortexGame")

		if vortexGame then
			pcall(function()
				vortexGame:FireServer(p)
			end)
		end
	end
end

local function invokeWithTimeout(object, p, p2: number)
	local v5 = { done = false, ok = false, res = nil }
	task.spawn(function()
		local success, result = pcall(function()
			return object:InvokeServer(p)
		end)

		v5.ok = success
		v5.res = result
		v5.done = true
	end)
	local lastTime = os.clock()

	while not v5.done do
		if p2 < os.clock() - lastTime then
			return false, "timeout"
		end

		task.wait(0.1)
	end

	return v5.ok, v5.res
end

function VortexBot.analyse(startFen: string?, moves, seconds: number?, p: number?, p2)
	local vortexAnalyse = Chess:FindFirstChild("VortexAnalyse")

	if vortexAnalyse and RunService:IsClient() then
		local v5, v6 = invokeWithTimeout(
			vortexAnalyse,
			{ startFen = startFen, moves = moves, seconds = seconds },
			(seconds or 1) + 4
		)

		if v5 and type(v6) == "table" and (v6.best ~= nil or v6.terminal ~= nil) then
			v6.score = tonumber(v6.score) or 0
			v6.depth = tonumber(v6.depth) or 0
			return v6
		end
	end

	return Bot.analyse(startFen, moves, seconds, p, p2)
end

function VortexBot.reviewGame(startFen: string?, moves)
	local vortexReview = Chess:FindFirstChild("VortexReview")

	if not (vortexReview and RunService:IsClient()) then
		return nil
	end

	local v5, v6 = invokeWithTimeout(
		vortexReview,
		{ startFen = startFen, moves = moves },
		math.clamp(#moves * 0.1 + 8, 12, 40)
	)

	if not v5 or type(v6) ~= "table" or #v6 ~= #moves + 1 then
		return nil
	end

	local result = {}

	for k, v7 in v6 do
		if type(v7) ~= "table" then
			return nil
		end

		v7.score = tonumber(v7.score) or 0
		v7.depth = tonumber(v7.depth) or 0
		result[k - 1] = v7
	end

	return result
end

return VortexBot