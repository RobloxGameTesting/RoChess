--!native
local Engine = require(script.Parent.Engine)

local band = bit32.band
local extract = bit32.extract
local abs = math.abs

local F_EP = Engine.F_EP
local squares = Engine.SQUARES

local v = table.create(1561, 0)
local v2 = table.create(1561, 0)
local v3 = { 82, 337, 365, 477, 1025, 0 }

local v4 = {
	{
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		98,
		134,
		61,
		95,
		68,
		126,
		34,
		-11,
		-6,
		7,
		26,
		31,
		65,
		56,
		25,
		-20,
		-14,
		13,
		6,
		21,
		23,
		12,
		17,
		-23,
		-27,
		-2,
		-5,
		12,
		17,
		6,
		10,
		-25,
		-26,
		-4,
		-4,
		-10,
		3,
		3,
		33,
		-12,
		-35,
		-1,
		-20,
		-23,
		-15,
		24,
		38,
		-22,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0
	},
	{
		-167,
		-89,
		-34,
		-49,
		61,
		-97,
		-15,
		-107,
		-73,
		-41,
		72,
		36,
		23,
		62,
		7,
		-17,
		-47,
		60,
		37,
		65,
		84,
		129,
		73,
		44,
		-9,
		17,
		19,
		53,
		37,
		69,
		18,
		22,
		-13,
		4,
		16,
		13,
		28,
		19,
		21,
		-8,
		-23,
		-9,
		12,
		10,
		19,
		17,
		25,
		-16,
		-29,
		-53,
		-12,
		-3,
		-1,
		18,
		-14,
		-19,
		-105,
		-21,
		-58,
		-33,
		-17,
		-28,
		-19,
		-23
	},
	{
		-29,
		4,
		-82,
		-37,
		-25,
		-42,
		7,
		-8,
		-26,
		16,
		-18,
		-13,
		30,
		59,
		18,
		-47,
		-16,
		37,
		43,
		40,
		35,
		50,
		37,
		-2,
		-4,
		5,
		19,
		50,
		37,
		37,
		7,
		-2,
		-6,
		13,
		13,
		26,
		34,
		12,
		10,
		4,
		0,
		15,
		15,
		15,
		14,
		27,
		18,
		10,
		4,
		15,
		16,
		0,
		7,
		21,
		33,
		1,
		-33,
		-3,
		-14,
		-21,
		-13,
		-12,
		-39,
		-21
	},
	{
		32,
		42,
		32,
		51,
		63,
		9,
		31,
		43,
		27,
		32,
		58,
		62,
		80,
		67,
		26,
		44,
		-5,
		19,
		26,
		36,
		17,
		45,
		61,
		16,
		-24,
		-11,
		7,
		26,
		24,
		35,
		-8,
		-20,
		-36,
		-26,
		-12,
		-1,
		9,
		-7,
		6,
		-23,
		-45,
		-25,
		-16,
		-17,
		3,
		0,
		-5,
		-33,
		-44,
		-16,
		-20,
		-9,
		-1,
		11,
		-6,
		-71,
		-19,
		-13,
		1,
		17,
		16,
		7,
		-37,
		-26
	},
	{
		-28,
		0,
		29,
		12,
		59,
		44,
		43,
		45,
		-24,
		-39,
		-5,
		1,
		-16,
		57,
		28,
		54,
		-13,
		-17,
		7,
		8,
		29,
		56,
		47,
		57,
		-27,
		-27,
		-16,
		-16,
		-1,
		17,
		-2,
		1,
		-9,
		-26,
		-9,
		-10,
		-2,
		-4,
		3,
		-3,
		-14,
		2,
		-11,
		-2,
		-5,
		2,
		14,
		5,
		-35,
		-8,
		11,
		2,
		8,
		15,
		-3,
		1,
		-1,
		-18,
		-9,
		10,
		-15,
		-25,
		-31,
		-50
	},
	{
		-65,
		23,
		16,
		-15,
		-56,
		-34,
		2,
		13,
		29,
		-1,
		-20,
		-7,
		-8,
		-4,
		-38,
		-29,
		-9,
		24,
		2,
		-16,
		-20,
		6,
		22,
		-22,
		-17,
		-20,
		-12,
		-27,
		-30,
		-25,
		-14,
		-36,
		-49,
		-1,
		-27,
		-39,
		-46,
		-44,
		-33,
		-51,
		-14,
		-14,
		-22,
		-46,
		-44,
		-30,
		-15,
		-27,
		1,
		7,
		-8,
		-64,
		-43,
		-16,
		9,
		8,
		-15,
		36,
		12,
		-54,
		8,
		-28,
		24,
		14
	}
}
local v5 = { 94, 281, 297, 512, 936, 0 }

local v6 = {
	{
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		178,
		173,
		158,
		134,
		147,
		132,
		165,
		187,
		94,
		100,
		85,
		67,
		56,
		53,
		82,
		84,
		32,
		24,
		13,
		5,
		-2,
		4,
		17,
		17,
		13,
		9,
		-3,
		-7,
		-7,
		-8,
		3,
		-1,
		4,
		7,
		-6,
		1,
		0,
		-5,
		-1,
		-8,
		13,
		8,
		8,
		10,
		13,
		0,
		2,
		-7,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0
	},
	{
		-58,
		-38,
		-13,
		-28,
		-31,
		-27,
		-63,
		-99,
		-25,
		-8,
		-25,
		-2,
		-9,
		-25,
		-24,
		-52,
		-24,
		-20,
		10,
		9,
		-1,
		-9,
		-19,
		-41,
		-17,
		3,
		22,
		22,
		22,
		11,
		8,
		-18,
		-18,
		-6,
		16,
		25,
		16,
		17,
		4,
		-18,
		-23,
		-3,
		-1,
		15,
		10,
		-3,
		-20,
		-22,
		-42,
		-20,
		-10,
		-5,
		-2,
		-20,
		-23,
		-44,
		-29,
		-51,
		-23,
		-15,
		-22,
		-18,
		-50,
		-64
	},
	{
		-14,
		-21,
		-11,
		-8,
		-7,
		-9,
		-17,
		-24,
		-8,
		-4,
		7,
		-12,
		-3,
		-13,
		-4,
		-14,
		2,
		-8,
		0,
		-1,
		-2,
		6,
		0,
		4,
		-3,
		9,
		12,
		9,
		14,
		10,
		3,
		2,
		-6,
		3,
		13,
		19,
		7,
		10,
		-3,
		-9,
		-12,
		-3,
		8,
		10,
		13,
		3,
		-7,
		-15,
		-14,
		-18,
		-7,
		-1,
		4,
		-9,
		-15,
		-27,
		-23,
		-9,
		-23,
		-5,
		-9,
		-16,
		-5,
		-17
	},
	{
		13,
		10,
		18,
		15,
		12,
		12,
		8,
		5,
		11,
		13,
		13,
		11,
		-3,
		3,
		8,
		3,
		7,
		7,
		7,
		5,
		4,
		-3,
		-5,
		-3,
		4,
		3,
		13,
		1,
		2,
		1,
		-1,
		2,
		3,
		5,
		8,
		4,
		-5,
		-6,
		-8,
		-11,
		-4,
		0,
		-5,
		-1,
		-7,
		-12,
		-8,
		-16,
		-6,
		-6,
		0,
		2,
		-9,
		-9,
		-11,
		-3,
		-9,
		2,
		3,
		-1,
		-5,
		-13,
		4,
		-20
	},
	{
		-9,
		22,
		22,
		27,
		27,
		19,
		10,
		20,
		-17,
		20,
		32,
		41,
		58,
		25,
		30,
		0,
		-20,
		6,
		9,
		49,
		47,
		35,
		19,
		9,
		3,
		22,
		24,
		45,
		57,
		40,
		57,
		36,
		-18,
		28,
		19,
		47,
		31,
		34,
		39,
		23,
		-16,
		-27,
		15,
		6,
		9,
		17,
		10,
		5,
		-22,
		-23,
		-30,
		-16,
		-16,
		-23,
		-36,
		-32,
		-33,
		-28,
		-22,
		-43,
		-5,
		-32,
		-20,
		-41
	},
	{
		-74,
		-35,
		-18,
		-18,
		-11,
		15,
		4,
		-17,
		-12,
		17,
		14,
		17,
		17,
		38,
		23,
		11,
		10,
		17,
		23,
		15,
		20,
		45,
		44,
		13,
		-8,
		22,
		24,
		27,
		26,
		33,
		26,
		3,
		-18,
		-4,
		21,
		24,
		27,
		23,
		9,
		-11,
		-19,
		-3,
		11,
		21,
		23,
		16,
		7,
		-9,
		-27,
		-11,
		4,
		13,
		14,
		4,
		-5,
		-17,
		-53,
		-34,
		-21,
		-11,
		-28,
		-14,
		-24,
		-43
	}
}
local Bot = {}

for i = 1, 6 do
	for j = 0, 7 do
		for k = 0, 7 do
			local sq = Engine.toSq(k, j)
			local v7 = (7 - j) * 8 + k + 1
			local v8 = j * 8 + k + 1
			v[(i + 6) * 120 + sq] = v3[i] + v4[i][v7]
			v2[(i + 6) * 120 + sq] = v5[i] + v6[i][v7]
			v[(6 - i) * 120 + sq] = -(v3[i] + v4[i][v8])
			v2[(6 - i) * 120 + sq] = -(v5[i] + v6[i][v8])
		end
	end
end

local v7 = {
	0,
	4,
	2,
	1,
	1,
	0,
	0,
	0,
	1,
	1,
	2,
	4,
	0
}

local v8 = { 100, 320, 330, 500, 900, 2000 }

local function evaluate(e)
	local board = e.board
	local v9 = 0
	local v10 = 0
	local total = 0
	local count = 0
	local count2 = 0

	for i = 1, 64 do
		local square = squares[i]
		local v11 = board[square]

		if v11 == 0 then
			continue
		end

		local v12 = (v11 + 6) * 120 + square
		v9 += v[v12]
		v10 += v2[v12]
		total += v7[v11 + 7]

		if v11 == 3 then
			count2 += 1
		elseif v11 == -3 then
			count += 1
		end
	end

	if count2 >= 2 then
		v9 += 30
		v10 += 50
	end

	if count >= 2 then
		v9 -= 30
		v10 -= 50
	end

	local v11 = total > 24 and 24 or total
	return (v9 * v11 + v10 * (24 - v11)) // 24 * e.side + 10
end

Bot.evaluate = evaluate

local function hasNonPawn(e, side): boolean
	local board = e.board

	for i = 1, 64 do
		local v9 = board[squares[i]] * side

		if v9 >= 2 and v9 <= 5 then
			return true
		end
	end

	return false
end

local v9 = table.create(65536, -1)
local v10 = table.create(65536, 0)
local v11 = table.create(65536, 0)

function Bot.clearTT()
	for i = 1, 65536 do
		v9[i] = -1
		v10[i] = 0
		v11[i] = 0
	end
end

local function ttStore(p, h2, count, p2, p3, p4) -- 1 equivalent call inferred from this helper
	local v12 = count < 0 and 0 or count
	local v13 = v12 > 127 and 127 or v12
	v9[p] = h2
	v10[p] = (p2 + 40000) * 512 + v13 * 4 + p3
	v11[p] = p4
end

local class = {}
class.__index = class

function class.new(p)
	local object = setmetatable({}, class)
	object.e = p
	object.nodes = 0
	object.stop = false
	object.k1 = table.create(98, 0)
	object.k2 = table.create(98, 0)
	object.hist = {}
	object.lists = {}
	object.scores = {}

	for i = 1, 98 do
		object.lists[i] = table.create(128, 0)
		object.scores[i] = table.create(128, 0)
	end

	object.useQs = true
	object.rootPly = p.ply
	object.deadline = 1e999
	object.slice = 0.006
	object.sliceStart = os.clock()
	return object
end

function class:checkTime()
	local now = os.clock()

	if self.deadline <= now then
		self.stop = true
	elseif self.slice and now - self.sliceStart > self.slice then
		task.wait()
		local now2 = os.clock()

		if self.cpuTime then
			local v12 = now2 - now
			self.deadline += v12

			if self.soft then
				self.soft += v12
			end
		end

		self.sliceStart = now2

		if self.cancelled and self.cancelled() then
			self.stop = true
		end
	end
end

function class:repDraw(): boolean
	local e = self.e
	local h1 = e.h1
	local h2 = e.h2
	local ply = e.ply
	local v12 = math.max(1, ply - e.halfmove + 1)
	local uH1 = e.uH1
	local uH2 = e.uH2
	local rootPly = self.rootPly

	local v13 = ply - 1
	local v14 = 1

	while v12 <= v13 do
		if uH1[v13] == h1 and uH2[v13] == h2 then
			if rootPly <= v13 - 1 then
				return true
			end

			v14 += 1

			if v14 >= 3 then
				return true
			end
		end

		v13 -= 2
	end

	return false
end

function class:scoreMoves(list, list2, p, p2, p3)
	local board = self.e.board
	local v12 = self.k1[p3 + 1]
	local v13 = self.k2[p3 + 1]
	local hist = self.hist

	for i = 1, p do
		local item = list[i]

		if item == p2 then
			list2[i] = 10000000
		else
			local v14 = board[extract(item, 7, 7)]
			local v15 = extract(item, 14, 3)

			if v14 == 0 and extract(item, 17, 3) ~= F_EP then
				if v15 == 0 then
					if item == v12 then
						list2[i] = 800000
					elseif item == v13 then
						list2[i] = 790000
					else
						list2[i] = hist[band(item, 16383)] or 0
					end
				else
					list2[i] = v15 == 5 and 900000 or -1000
				end
			else
				list2[i] = 1000000 + v8[v14 == 0 and 1 or abs(v14) or 1] * 10 - v8[abs(board[band(item, 127)])] // 10 + (v15 == 5 and 9000 or 0)
			end
		end
	end
end

function class:quiesce(p, p2, p3)
	local e = self.e
	self.nodes += 1

	if band(self.nodes, 255) == 0 then
		self:checkTime()

		if self.stop then
			return 0
		end
	end

	local side = e.side
	local attacked = e:isAttacked(e.kingSq[side], -side)
	local board = e.board
	local v12

	if attacked then
		v12 = -32000
	else
		v12 = evaluate(e)

		if p2 <= v12 then
			return v12
		end

		if p < v12 then
			p = v12
		end
	end

	if p3 >= 96 then
		return v12 > -32000 and v12 or evaluate(e)
	end

	local list = self.lists[p3 + 1]
	local score = self.scores[p3 + 1]
	local genPseudo = e:genPseudo(list, not attacked)

	for i = 1, genPseudo do
		local item = list[i]
		local v13 = board[extract(item, 7, 7)]
		local v14 = v13 ~= 0 and abs(v13) or extract(item, 17, 3) == F_EP and 1 or 0
		local v15

		if v14 > 0 then
			v15 = v8[v14] * 10 - v8[abs(board[band(item, 127)])] // 10 or 0
		else
			v15 = 0
		end

		if extract(item, 14, 3) == 5 then
			v15 += 9000
		end

		score[i] = v15
	end

	local v13 = v12
	local count = 0

	for i = 1, genPseudo do
		local v14 = score[i]
		local v15 = i

		for j = i + 1, genPseudo do
			if not (v14 < score[j]) then
				continue
			end

			v14 = score[j]
			v15 = j
		end

		if v15 ~= i then
			local item = list[v15]
			local item2 = list[i]
			list[i] = item
			list[v15] = item2
			local v16 = score[v15]
			local v17 = score[i]
			score[i] = v16
			score[v15] = v17
		end

		local item = list[i]

		if not attacked then
			local v16 = board[extract(item, 7, 7)]
			local v17 = v16 == 0 and 100 or v8[abs(v16)] or 100

			if extract(item, 14, 3) == 0 and v12 + v17 + 200 < p then
				continue
			end
		end

		e:makeMove(item)

		if e:isAttacked(e.kingSq[side], -side) then
			e:undoMove()
		else
			count += 1
			local v16 = -self:quiesce(-p2, -p, p3 + 1)
			e:undoMove()

			if self.stop then
				return 0
			end

			if v13 < v16 then
				if p < v16 then
					if p2 <= v16 then
						return v16
					end

					v13 = v16
					p = v13
				else
					v13 = v16
				end
			end
		end
	end

	if attacked and count == 0 then
		return -30000 + p3
	end

	return v13
end

function class:negamax(count, p, p2, p3, p4)
	local e = self.e
	local side = e.side

	if p3 > 0 then
		if self:repDraw() then
			return 0
		end

		if e.halfmove >= 100 then
			if e:isAttacked(e.kingSq[side], -side) and #e:legalMoves() == 0 then
				return -30000 + p3
			end

			return 0
		else
			local v12 = -30000 + p3

			if p < v12 then
				p = v12
			end

			local v13 = 30000 - p3 - 1

			if v13 < p2 then
				p2 = v13
			end

			if p2 <= p then
				return p
			end
		end
	end

	local attacked = e:isAttacked(e.kingSq[side], -side)

	if attacked and p3 < 88 then
		count += 1
	end

	if count <= 0 or p3 >= 92 then
		if self.useQs then
			return self:quiesce(p, p2, p3)
		end

		self.nodes += 1
		return evaluate(e)
	else
		self.nodes += 1

		if band(self.nodes, 255) == 0 then
			self:checkTime()

			if self.stop then
				return 0
			end
		end

		local v12 = p2 - p > 1
		local h2 = e.h2
		local v13 = e.h1 % 65536 + 1
		local v14

		if v9[v13] == h2 then
			v14 = v11[v13]
			local v15 = v10[v13]
			local v16 = v15 % 4
			local v17 = v15 // 4 % 128
			local v18 = v15 // 512 - 40000

			if v18 > 29500 then
				v18 -= p3
			elseif v18 < -29500 then
				v18 += p3
			end

			if
				p3 > 0
				and not v12
				and count <= v17
				and (v16 == 1 or v16 == 2 and p2 <= v18 or v16 == 3 and v18 <= p)
			then
				return v18
			end
		else
			v14 = 0
		end

		if not attacked and not v12 and p3 > 0 then
			local v15 = evaluate(e)

			if count <= 3 and p2 <= v15 - 120 * count and p2 < 29500 then
				return v15
			end

			if p4 and count >= 3 and p2 <= v15 and hasNonPawn(e, side) then
				e:makeNull()
				local v16 = count >= 6 and 3 or 2
				local v17 = -self:negamax(count - 1 - v16, -p2, -p2 + 1, p3 + 1, false)
				e:undoNull()

				if self.stop then
					return 0
				end

				if p2 <= v17 then
					return if v17 >= 29500 then p2 else v17
				end
			end
		end

		local list = self.lists[p3 + 1]
		local score = self.scores[p3 + 1]
		local genPseudo = e:genPseudo(list, false)
		self:scoreMoves(list, score, genPseudo, v14, p3)
		local board = e.board
		local v15 = p
		local count2 = 0
		local v16 = -32000
		local v17 = 0

		for i = 1, genPseudo do
			local v18 = score[i]
			local v19 = i

			for j = i + 1, genPseudo do
				if not (v18 < score[j]) then
					continue
				end

				v18 = score[j]
				v19 = j
			end

			if v19 ~= i then
				local item = list[v19]
				local item2 = list[i]
				list[i] = item
				list[v19] = item2
				local v20 = score[v19]
				local v21 = score[i]
				score[i] = v20
				score[v19] = v21
			end

			local item = list[i]
			local v20 = board[extract(item, 7, 7)] ~= 0 or extract(item, 17, 3) == F_EP
			local v21 = extract(item, 14, 3) ~= 0
			e:makeMove(item)

			if e:isAttacked(e.kingSq[side], -side) then
				e:undoMove()
			else
				count2 += 1
				local rootScore

				if count2 == 1 then
					rootScore = -self:negamax(count - 1, -p2, -p, p3 + 1, true)
				else
					local v22

					if
						count >= 3
						and count2 > 3
						and not (attacked or v20 or v21 or e:isAttacked(e.kingSq[-side], side))
					then
						local v23 = count2 > 10 and count >= 5 and 2 or 1
						v22 = v12 and v23 > 1 and 1 or v23
					else
						v22 = 0
					end

					rootScore = -self:negamax(count - 1 - v22, -p - 1, -p, p3 + 1, true)

					if p < rootScore and v22 > 0 and not self.stop then
						rootScore = -self:negamax(count - 1, -p - 1, -p, p3 + 1, true)
					end

					if p < rootScore and rootScore < p2 and not self.stop then
						rootScore = -self:negamax(count - 1, -p2, -p, p3 + 1, true)
					end
				end

				e:undoMove()

				if self.stop then
					return 0
				end

				if v16 < rootScore then
					if p < rootScore then
						if p3 == 0 then
							self.rootBest = item
							self.rootScore = rootScore
						end

						if p2 <= rootScore then
							if not (v20 or v21) then
								local v22 = p3 + 1

								if self.k1[v22] ~= item then
									self.k2[v22] = self.k1[v22]
									self.k1[v22] = item
								end

								local v23 = band(item, 16383)
								local v24 = (self.hist[v23] or 0) + count * count
								local v25 = v24 > 700000 and 700000 or v24
								self.hist[v23] = v25
							end

							v17 = item
							v16 = rootScore
							break
						end

						p = rootScore
						v17 = item
						v16 = p
					else
						v17 = item
						v16 = rootScore
					end
				end
			end
		end

		if count2 == 0 then
			return attacked and -30000 + p3 or 0
		end

		local v18 = p2 <= v16 and 2 or v15 < v16 and 1 or 3
		local v19

		if v16 > 29500 then
			v19 = v16 + p3
		elseif v16 < -29500 then
			v19 = v16 - p3
		else
			v19 = v16
		end

		ttStore(v13, h2, count, v19, v18, v17) -- inferred equivalent call
		return v16
	end
end

function class:run(p, p2)
	local now = os.clock()
	self.deadline = now + p2
	self.soft = now + p2 * 0.55
	self.sliceStart = now
	local v12 = 0
	local v13 = 0
	local v14 = 0

	for i = 1, p do
		self.rootBest = 0
		local negamax = self:negamax(i, -32000, 32000, 0, false)

		if self.stop then
			if self.rootBest == 0 or i <= 1 then
				break
			end

			v12 = self.rootBest
			v13 = self.rootScore
			v14 = i
			break
		end

		v12 = self.rootBest

		if abs(negamax) >= 29800 or os.clock() > self.soft then
			v14 = i
			v13 = negamax
			break
		end

		v14 = i
		v13 = negamax
	end

	return v12 == 0 and (self.e:legalMoves()[1] or 0) or v12, v13, v14
end

function class:rootScores(p)
	local e = self.e
	local result = {}

	for _, move in e:legalMoves() do
		e:makeMove(move)
		local score = -self:negamax(p - 1, -32000, 32000, 1, true)
		e:undoMove()

		if self.stop then
			return nil
		end

		table.insert(result, { move = move, score = score })
	end

	return result
end

local v12 = {}

for _, v13 in {
	"e2e4 e7e5 g1f3 b8c6 f1b5 a7a6 b5a4 g8f6 e1g1 f8e7 f1e1 b7b5 a4b3 d7d6",
	"e2e4 e7e5 g1f3 b8c6 f1b5 g8f6 e1g1 f6e4 d2d4 e4d6",
	"e2e4 e7e5 g1f3 b8c6 f1c4 f8c5 c2c3 g8f6 d2d3 d7d6 e1g1 e8g8",
	"e2e4 e7e5 g1f3 b8c6 f1c4 g8f6 d2d3 f8e7 e1g1 e8g8",
	"e2e4 e7e5 g1f3 b8c6 d2d4 e5d4 f3d4 g8f6 d4c6 b7c6 e4e5 d8e7",
	"e2e4 e7e5 g1f3 g8f6 f3e5 d7d6 e5f3 f6e4 d2d4 d6d5",
	"e2e4 e7e5 g1f3 d7d6 d2d4 g8f6 b1c3 b8d7",
	"e2e4 e7e5 b1c3 g8f6 f2f4 d7d5 f4e5 f6e4",
	"e2e4 c7c5 g1f3 d7d6 d2d4 c5d4 f3d4 g8f6 b1c3 a7a6 c1e3 e7e5",
	"e2e4 c7c5 g1f3 b8c6 d2d4 c5d4 f3d4 g8f6 b1c3 e7e5 d4b5 d7d6",
	"e2e4 c7c5 g1f3 e7e6 d2d4 c5d4 f3d4 a7a6 f1d3",
	"e2e4 c7c5 b1c3 b8c6 g2g3 g7g6 f1g2 f8g7 d2d3 d7d6",
	"e2e4 c7c5 c2c3 g8f6 e4e5 f6d5 d2d4 c5d4 g1f3",
	"e2e4 e7e6 d2d4 d7d5 b1c3 g8f6 c1g5 f8e7 e4e5 f6d7",
	"e2e4 e7e6 d2d4 d7d5 e4e5 c7c5 c2c3 b8c6 g1f3 d8b6",
	"e2e4 c7c6 d2d4 d7d5 b1c3 d5e4 c3e4 c8f5 e4g3 f5g6",
	"e2e4 c7c6 d2d4 d7d5 e4e5 c8f5 g1f3 e7e6 f1e2",
	"e2e4 d7d5 e4d5 d8d5 b1c3 d5a5 d2d4 g8f6 g1f3 c8f5",
	"e2e4 g7g6 d2d4 f8g7 b1c3 d7d6 g1f3 g8f6 f1e2 e8g8",
	"d2d4 d7d5 c2c4 e7e6 b1c3 g8f6 c1g5 f8e7 e2e3 e8g8 g1f3 h7h6",
	"d2d4 d7d5 c2c4 d5c4 g1f3 g8f6 e2e3 e7e6 f1c4 c7c5",
	"d2d4 d7d5 c2c4 c7c6 g1f3 g8f6 b1c3 d5c4 a2a4 c8f5",
	"d2d4 g8f6 c2c4 g7g6 b1c3 f8g7 e2e4 d7d6 g1f3 e8g8 f1e2 e7e5",
	"d2d4 g8f6 c2c4 e7e6 b1c3 f8b4 e2e3 e8g8 f1d3 d7d5",
	"d2d4 g8f6 c2c4 e7e6 g1f3 b7b6 g2g3 c8b7 f1g2 f8e7",
	"d2d4 g8f6 c2c4 g7g6 b1c3 d7d5 c4d5 f6d5 e2e4 d5c3 b2c3 f8g7",
	"d2d4 d7d5 c1f4 g8f6 e2e3 e7e6 g1f3 c7c5 c2c3 b8c6",
	"d2d4 g8f6 g1f3 g7g6 c1f4 f8g7 e2e3 e8g8 f1e2 d7d6",
	"d2d4 f7f5 g2g3 g8f6 f1g2 g7g6 g1f3 f8g7 e1g1 e8g8",
	"c2c4 e7e5 b1c3 g8f6 g1f3 b8c6 g2g3 d7d5 c4d5 f6d5",
	"c2c4 g8f6 b1c3 e7e6 g1f3 d7d5 d2d4 f8e7",
	"c2c4 c7c5 g1f3 b8c6 b1c3 g7g6 g2g3 f8g7",
	"g1f3 d7d5 g2g3 g8f6 f1g2 e7e6 e1g1 f8e7 d2d3 e8g8",
	"g1f3 g8f6 c2c4 g7g6 b1c3 f8g7 e2e4 d7d6 d2d4 e8g8"
} do
	table.insert(v12, string.split(v13, " "))
end

function Bot.bookMove(list)
	local v13 = {}

	for _, v14 in v12 do
		if not (#v14 > #list) then
			continue
		end

		local flag = true

		for i = 1, #list do
			if v14[i] ~= list[i] then
				flag = false
				break
			end
		end

		if flag then
			table.insert(v13, v14[#list + 1])
		end
	end

	if #v13 == 0 then
		return nil
	end

	return v13[math.random(1, #v13)]
end

function Bot.isBook(list, p): boolean
	for _, v13 in v12 do
		if not (p <= #v13) then
			continue
		end

		local flag = true

		for i = 1, p do
			if v13[i] ~= list[i] then
				flag = false
				break
			end
		end

		if flag then
			return true
		end
	end

	return false
end

local random = Random.new()

local function gaussian() -- 1 equivalent call inferred from this helper
	local v13 = math.max(1e-9, random:NextNumber())
	local number = random:NextNumber()
	return math.sqrt(math.log(v13) * -2) * math.cos(6.283185307179586 * number)
end

local function buildEngine(p, items)
	local engine = Engine.new(p)

	for _, item in items do
		local v13 = engine:moveFromUci(item)

		if not v13 then
			break
		end

		engine:makeMove(v13)
	end

	return engine
end

Bot.buildEngine = buildEngine

Bot.onSearch = nil
local function searched(engine) -- 3 equivalent calls inferred from this helper
	local onSearch = Bot.onSearch

	if onSearch then
		pcall(onSearch, engine)
	end
end

function Bot.think(p, list, data, options)
	local v13 = options or {}
	local engine = buildEngine(p, list)
	searched(engine) -- inferred equivalent call

	if (data.rating or 0) >= 800 and (p == nil or p == Engine.START_FEN) and #list < 16 then
		local bookMove = Bot.bookMove(list)

		if bookMove and engine:moveFromUci(bookMove) and random:NextNumber() < 0.9 then
			return bookMove, { book = true }
		end
	end

	local v14 = class.new(engine)
	v14.cancelled = v13.cancelled

	if v13.slice ~= nil then
		v14.slice = v13.slice
	end

	v14.useQs = (data.rating or 2000) >= 500
	local noise = data.noise or 0
	local lastTime = os.clock()

	if noise <= 0 and (data.blunder or 0) <= 0 then
		local v15, score, depth = v14:run(data.depth or 20, data.time or 1)

		if v15 == 0 then
			return nil
		end

		return engine:moveToUci(v15), {
			score = score,
			depth = depth,
			nodes = v14.nodes,
			time = os.clock() - lastTime
		}
	else
		v14.deadline = lastTime + (data.time or 0.5)
		local v15 = nil

		for i = 1, data.depth or 2 do
			local rootScores = v14:rootScores(i)

			if not rootScores then
				break
			end

			v15 = rootScores
		end

		if v15 and #v15 ~= 0 then
			table.sort(v15, function(a, b): boolean
				return a.score > b.score
			end)

			local v16 = v15[1]
			local v17 = nil

			if v16.score < 29800 and random:NextNumber() < (data.blunder or 0) then
				local v18 = {}

				for _, v19 in v15 do
					if v19.score <= v16.score - 80 and v19.score >= v16.score - 600 then
						table.insert(v18, v19)
					end
				end

				if #v18 > 0 then
					v17 = v18[random:NextInteger(1, #v18)]
				end
			end

			if not v17 then
				local v18 = -1e999

				for _, v19 in v15 do
					local score = v19.score

					if abs(score) < 29800 then
						score += gaussian() * noise -- inferred equivalent call
					end

					if not (v18 < score) then
						continue
					end

					v17 = v19
					v18 = score
				end
			end

			return engine:moveToUci(v17.move), {
				score = v17.score,
				time = os.clock() - lastTime,
				nodes = v14.nodes
			}
		else
			local legalMoves = engine:legalMoves()

			if #legalMoves == 0 then
				return nil
			end

			return engine:moveToUci(legalMoves[random:NextInteger(1, #legalMoves)]), {}
		end
	end
end

function Bot.analyse(p, p2, value, value2, options)
	local v13 = options or {}
	local engine = buildEngine(p, p2)
	searched(engine) -- inferred equivalent call
	local status = engine:status()

	if status == "checkmate" then
		return {
			best = nil,
			score = engine.side == 1 and -30000 or 30000,
			mate = 0,
			depth = 0,
			terminal = "checkmate"
		}
	end

	if status ~= "ongoing" then
		return { best = nil, score = 0, depth = 0, terminal = status }
	end

	local v14 = class.new(engine)
	v14.cancelled = v13.cancelled

	if v13.slice ~= nil then
		v14.slice = v13.slice
	end

	local v15, v16, depth = v14:run(value2 or 30, value or 1)
	local score = v16 * engine.side
	local mate

	if abs(v16) >= 29800 then
		mate = math.ceil((30000 - abs(v16)) / 2) * (score > 0 and 1 or -1)
	end

	local best

	if v15 ~= 0 then
		best = engine:moveToUci(v15) or nil
	end

	return {
		best = best,
		score = score,
		mate = mate,
		depth = depth,
		nodes = v14.nodes
	}
end

local function cpToWin(value) -- 1 equivalent call inferred from this helper
	return 100 / (math.exp(-0.00368208 * math.clamp(value, -1200, 1200)) + 1)
end

local function winToCp(value) -- 1 equivalent call inferred from this helper
	local v13 = math.clamp(value, 0.5, 99.5)
	return math.log(v13 / (100 - v13)) / 0.00368208
end

local function toWhite(engine, p) -- 3 equivalent calls inferred from this helper
	local v13 = p * engine.side
	local v14

	if abs(p) >= 29800 then
		v14 = math.ceil((30000 - abs(p)) / 2) * (v13 > 0 and 1 or -1)
	end

	return v13, v14
end

function Bot.review(p, p2, p3, p4, value, options)
	local v13 = options or {}
	local engine = buildEngine(p, p2)
	searched(engine) -- inferred equivalent call
	local status = engine:status()

	if status == "checkmate" then
		return {
			best = nil,
			score = engine.side == 1 and -30000 or 30000,
			mate = 0,
			depth = 0,
			terminal = "checkmate"
		}
	end

	if status ~= "ongoing" then
		return { best = nil, score = 0, depth = 0, terminal = status }
	end

	local legalMoves = engine:legalMoves()
	local v14 = class.new(engine)
	v14.cancelled = v13.cancelled

	if v13.slice ~= nil then
		v14.slice = v13.slice
	end

	v14.cpuTime = v13.cpuTime
	local v15 = p3 and engine:moveFromUci(p3)

	local v16, v17, depth = v14:run(value or 30, p4 * (v15 and 0.7 or 1))
	local score, mate = toWhite(engine, v17) -- inferred equivalent call
	local best

	if v16 ~= 0 then
		best = engine:moveToUci(v16) or nil
	end

	local v18 = {
		best = best,
		score = score,
		mate = mate,
		depth = depth,
		nodes = v14.nodes,
		legal = #legalMoves
	}

	if not v15 or v16 == 0 or v14.cancelled and v14.cancelled() then
		return v18
	end

	local function budget(p5) -- 5 equivalent calls inferred from this helper
		local now = os.clock()
		v14.stop = false
		v14.deadline = now + p5
		v14.soft = v14.deadline
		v14.sliceStart = now
	end
	local v19 = math.max(1, depth)

	local v20 = engine:isAttacked(engine.kingSq[engine.side], -engine.side) and 1 or 0

	local function scoreMove(p5, p6) -- 2 equivalent calls inferred from this helper
		engine:makeMove(p5)
		local v21 = -v14:negamax(p6 - 1 + v20, -32000, 32000, 1, true)
		engine:undoMove()
		return if not v14.stop then v21 else nil
	end

	local v21 = engine:moveToUci(v15) == v18.best

	if v21 then
		v18.played = { score = score, mate = mate }
	else
		budget(p4 * (v13.playedShare or 0.4) + 0.02) -- inferred equivalent call
		engine:makeMove(v15)
		local v22 = -v14:negamax(v19 - 1 + v20, -32000, 32000, 1, true)
		engine:undoMove()
		local playedDepth

		if v14.stop then
			playedDepth = v19
			v22 = nil
		else
			playedDepth = v19
		end

		while v22 == nil and playedDepth > 2 do
			playedDepth -= 1
			budget(p4 * 0.2 + 0.02) -- inferred equivalent call
			engine:makeMove(v15)
			v22 = -v14:negamax(playedDepth - 1 + v20, -32000, 32000, 1, true)
			engine:undoMove()

			if v14.stop then
				v22 = nil
			end
		end

		if v22 and v17 >= 29500 and v22 < 29500 then
			for i = playedDepth + 1, playedDepth + 8 do
				budget(p4 * 0.15 + 0.02) -- inferred equivalent call
				local v23 = scoreMove(v15, i) -- inferred equivalent call

				if not v23 then
					break
				end

				if v23 >= 29500 then
					v22 = v23
					break
				end

				v22 = v23
			end
		end

		if v22 then
			local score2, mate2 = toWhite(engine, v22) -- inferred equivalent call
			v18.played = { score = score2, mate = mate2 }
			v18.playedDepth = playedDepth

			if playedDepth < v19 then
				budget(p4 * 0.2 + 0.02) -- inferred equivalent call
				local v23 = scoreMove(v16, playedDepth) -- inferred equivalent call

				if v23 then
					local score3, mate3 = toWhite(engine, v23) -- inferred equivalent call
					v18.cmpBest = { score = score3, mate = mate3 }
				else
					v18.played = nil
				end
			end
		end
	end

	if v21 and #legalMoves >= 2 then
		local v22

		if v17 >= 29500 then
			v22 = 29500
		else
			v22 = math.floor(winToCp(cpToWin(v17) - (v13.onlyMargin or 15))) -- inferred equivalent call
		end

		budget(p4 * 0.3 + 0.03) -- inferred equivalent call
		local onlyMove = true

		for _, legalMove in legalMoves do
			if legalMove == v16 then
				continue
			end

			engine:makeMove(legalMove)
			local negamax = v14:negamax(v19 - 1 + v20, -v22, -v22 + 1, 1, true)
			engine:undoMove()

			if v14.stop then
				onlyMove = nil
				break
			elseif v22 <= -negamax then
				onlyMove = false
				break
			end
		end

		v18.onlyMove = onlyMove
	end

	v18.nodes = v14.nodes
	return v18
end

local v13 = { 100, 300, 300, 500, 900, 0 }
local function material(p)
	local board = p.board
	local v14 = 0

	for i = 1, 64 do
		local v15 = board[squares[i]]

		if v15 > 0 then
			v14 += v13[v15]
		elseif v15 < 0 then
			v14 -= v13[-v15]
		end
	end

	return v14 * p.side
end

local function matQS(engine, p, p2, p3)
	local side = engine.side
	local attacked = engine:isAttacked(engine.kingSq[side], -side)
	local v14 = -50000

	if attacked then
		if p3 <= -4 then
			return material(engine)
		end
	else
		v14 = material(engine)

		if p2 <= v14 or p3 <= 0 then
			return v14
		end

		if p < v14 then
			p = v14
		end
	end

	local v15 = table.create(128, 0)
	local genPseudo = engine:genPseudo(v15, not attacked)
	local board = engine.board
	local v16 = table.create(genPseudo)

	for i = 1, genPseudo do
		local v17 = board[extract(v15[i], 7, 7)]
		v16[i] = { v15[i], v17 == 0 and 0 or v13[abs(v17)] or 0 }
	end

	table.sort(v16, function(a, b): boolean
		return a[2] > b[2]
	end)
	local count = 0

	for _, v17 in v16 do
		engine:makeMove(v17[1])

		if engine:isAttacked(engine.kingSq[side], -side) then
			engine:undoMove()
		else
			count += 1
			local v18 = -matQS(engine, -p2, -p, p3 - 1)
			engine:undoMove()

			if v14 < v18 then
				if p < v18 then
					if p2 <= v18 then
						return v18
					end

					v14 = v18
					p = v14
				else
					v14 = v18
				end
			end
		end
	end

	return if attacked and count == 0 then -50000 else v14
end

function Bot.materialLoss(p, p2, p3)
	local engine = buildEngine(p, p2)
	local v14 = engine:moveFromUci(p3)

	if not v14 then
		return 0
	end

	local v15 = material(engine)
	engine:makeMove(v14)

	if engine:status() ~= "ongoing" then
		return 0
	end

	local v16 = -matQS(engine, -60000, 60000, 8)

	if v16 <= -40000 then
		return 0
	end

	return v15 - v16
end

Bot.cpToWin = cpToWin
Bot.MATE = 30000
Bot.Search = class

return Bot