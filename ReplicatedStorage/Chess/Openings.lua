local EncodingService = game:GetService("EncodingService")

local Engine = require(script.Parent.Engine)

local Openings = {}

local v = nil
local flag = false
local threads = {}

local function keyOf(object) -- 3 equivalent calls inferred from this helper
	local v2, v3, v4 = string.match(object:getFen(), "^(%S+) (%S+) (%S+)")
	return v2 .. " " .. v3 .. " " .. v4
end

Openings.keyOf = keyOf

local function splitName(value)
	local v2 = 1
	local result = {}

	while true do
		local v3 = string.find(value, ": ", v2, true)
		local v4 = string.find(value, ", ", v2, true)
		local v5 = v3 and v4 and math.min(v3, v4) or v3 or v4

		if not v5 then
			break
		end

		table.insert(result, (string.sub(value, v2, v5 - 1)))
		table.insert(result, (string.sub(value, v5, v5 + 1)))
		v2 = v5 + 2
	end

	table.insert(result, (string.sub(value, v2)))
	return result
end

function Openings.isLoaded(): boolean
	return v ~= nil
end

function Openings.load(p): boolean
	if v then
		return true
	end

	if flag then
		table.insert(threads, coroutine.running())
		coroutine.yield()
		return v ~= nil
	else
		flag = true
		local success, result = pcall(function()
			local OpeningData = require(script.Parent.OpeningData)
			local base64Decode = EncodingService:Base64Decode(buffer.fromstring((string.gsub(OpeningData, "%s", ""))))
			local v2 = buffer.tostring(EncodingService:DecompressBuffer(base64Decode, Enum.CompressionAlgorithm.Zstd))

			local v3 = Engine.new(Engine.START_FEN)
			local v4 = 0
			local count = 0
			local v5 = {}
			local v6 = {}

			for k in string.gmatch(v2, "[^\n]+") do
				local v7, v8, v9, v10 = string.match(k, "^(%d+)|([^|]*)|(%d+)|(.*)$")
				local v11 = tonumber(v7)
				local v12 = tonumber(v9)

				if not (v11 and v12) then
					continue
				end

				while v11 < v4 do
					v3:takeback()
					v4 -= 1
				end

				for k2 in string.gmatch(v8, "%S+") do
					local v13 = v3:moveFromUci(k2)

					if not v13 then
						error("bad opening move " .. k2 .. " in line " .. tostring(count + 1))
					end

					v3:play(v13)
					v4 += 1
				end

				local v13 = table.concat(v5, "", 1, v12) .. v10
				v5 = splitName(v13)
				v6[keyOf(v3)] = v13 -- inferred equivalent call
				count += 1

				if p and count % p == 0 then
					task.wait()
				end
			end

			v = v6
			Openings.count = count
		end)

		if not success then
			warn("[Chess] Couldn't load opening names: " .. tostring(result))
		end

		flag = false
		local v2 = threads
		threads = {}

		for _, callback in v2 do
			task.spawn(callback)
		end

		return v ~= nil
	end
end

function Openings.nameOf(object)
	local v2

	if v then
		return v[keyOf(object)] or nil -- inferred equivalent call
	end

	return v2
end

local function cacheFor(state)
	if not v or state.startFen ~= nil and state.startFen ~= Engine.START_FEN then
		return nil
	end

	local openingCache = state.openingCache

	if openingCache and openingCache.version == state.version then
		return openingCache
	end

	local v2 = math.min(#state.ucis, 40)
	local joined = table.concat(state.ucis, " ", 1, v2)

	if openingCache and openingCache.key == joined then
		openingCache.version = state.version
		return openingCache
	end

	local names = {}
	local book = {}
	local v3 = nil
	local v4 = 1
	local v5

	if
		openingCache
		and openingCache.e
		and openingCache.ok
		and #joined > #openingCache.key
		and string.sub(joined, 1, #openingCache.key + 1) == openingCache.key .. " "
	then
		names = openingCache.names
		book = openingCache.book
		v5 = openingCache.e
		v3 = openingCache.names[openingCache.n]
		v4 = openingCache.n + 1
	else
		v5 = Engine.new(Engine.START_FEN)
	end

	local v6 = true

	for i = v4, v2 do
		local v7 = v5:moveFromUci(state.ucis[i])

		if v7 then
			v5:play(v7)
			local v8 = v[keyOf(v5)] -- inferred equivalent call

			if v8 then
				book[i] = true
				v3 = v8
			end

			names[i] = v3
		else
			v2 = i - 1
			v6 = false
			break
		end
	end

	local openingCache2 = {
		version = state.version,
		names = names,
		book = book,
		n = v2,
		key = joined,
		e = v5,
		ok = v6 and v2 > 0
	}
	state.openingCache = openingCache2
	return openingCache2
end

function Openings.forSession(p, p2)
	local v2 = cacheFor(p)

	if v2 and v2.n ~= 0 then
		return v2.names[math.min(p2 or #p.ucis, v2.n)]
	end

	return nil
end

function Openings.isBook(p, p2): boolean
	local v2 = cacheFor(p)
	return v2 ~= nil and v2.book[p2] == true
end

return Openings