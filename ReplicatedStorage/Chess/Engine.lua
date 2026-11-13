--!native
local band = bit32.band
local bxor = bit32.bxor
local extract = bit32.extract
local abs = math.abs

local Engine = {}
Engine.__index = Engine

local function toSq(p, p2) -- 4 equivalent calls inferred from this helper
	return 22 + p + p2 * 10
end

local function fileOf(p) -- 10 equivalent calls inferred from this helper
	return (p - 2) % 10
end

local function rankOf(p) -- 8 equivalent calls inferred from this helper
	return (p - 22) // 10
end

local squares = table.create(64, 0)
local sq = table.create(120, 0)
local v = { -21, -19, -12, -8, 8, 12, 19, 21 }
local v2 = { -11, -9, 9, 11 }
local v3 = { -10, -1, 1, 10 }
local v4 = { -11, -10, -9, -1, 1, 9, 10, 11 }

local v5 = { "p", "n", "b", "r", "q", "k" }

local v6 = { "", "N", "B", "R", "Q", "K" }
local v7 = { "a", "b", "c", "d", "e", "f", "g", "h" }

local v8 = {
	p = 1,
	n = 2,
	b = 3,
	r = 4,
	q = 5,
	k = 6
}

for i = 0, 7 do
	for j = 0, 7 do
		local v9 = i * 8 + j + 1
		local sq2 = toSq(j, i) -- inferred equivalent call
		squares[v9] = sq2
		sq[sq2] = v9
	end
end

local v9 = table.create(120, 15)
v9[22] = 13
v9[29] = 14
v9[26] = 12
v9[92] = 7
v9[99] = 11
v9[96] = 3

local random = Random.new(20261001)
local function r31() -- 8 equivalent calls inferred from this helper
	return random:NextInteger(0, 2147483647)
end

local v10 = {}
local v11 = {}

for i = -6, 6 do
	for j = 1, 120 do
		local v12 = (i + 6) * 120 + j
		v10[v12] = r31() -- inferred equivalent call
		v11[v12] = r31() -- inferred equivalent call
	end
end

local v12 = r31() -- inferred equivalent call
local v13 = r31() -- inferred equivalent call
local v14 = {}
local v15 = {}

for i = 0, 15 do
	v14[i] = r31() -- inferred equivalent call
	v15[i] = r31() -- inferred equivalent call
end

local v16 = {}
local v17 = {}

for i = 0, 7 do
	v16[i] = r31() -- inferred equivalent call
	v17[i] = r31() -- inferred equivalent call
end

Engine.EMPTY = 0
Engine.PAWN = 1
Engine.KNIGHT = 2
Engine.BISHOP = 3
Engine.ROOK = 4
Engine.QUEEN = 5
Engine.KING = 6
Engine.OFF = 7
Engine.WHITE = 1
Engine.BLACK = -1
Engine.F_NONE = 0
Engine.F_DOUBLE = 1
Engine.F_EP = 2
Engine.F_OO = 3
Engine.F_OOO = 4
Engine.KNIGHT_DIRS = v
Engine.BISHOP_DIRS = v2
Engine.ROOK_DIRS = v3
Engine.KING_DIRS = v4
Engine.SQUARES = squares
Engine.SQ64 = sq
Engine.toSq = toSq
Engine.fileOf = fileOf
Engine.rankOf = rankOf

function Engine.encode(p, p2, p3, p4)
	return p + p2 * 128 + p3 * 16384 + p4 * 131072
end
Engine.PIECE_CHARS = v5
Engine.SAN_LETTERS = v6
Engine.START_FEN = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

function Engine.moveFrom(p)
	return (band(p, 127))
end

function Engine.moveTo(p)
	return (extract(p, 7, 7))
end

function Engine.movePromo(p)
	return (extract(p, 14, 3))
end

function Engine.moveFlag(p)
	return (extract(p, 17, 3))
end

function Engine.moveSquares64(p)
	return sq[band(p, 127)], sq[extract(p, 7, 7)]
end

function Engine.sqToAlg(p)
	return v7[fileOf(p) + 1] .. tostring(rankOf(p) + 1) -- inferred equivalent call
end

function Engine.algToSq(value)
	if type(value) ~= "string" or #value ~= 2 then
		return nil
	end

	local v18 = string.byte(value, 1) - 96
	local v19 = string.byte(value, 2) - 48

	if v18 < 1 or v18 > 8 or v19 < 1 or v19 > 8 then
		return nil
	end

	return toSq(v18 - 1, v19 - 1) -- inferred equivalent call
end

function Engine.index64ToAlg(p)
	return Engine.sqToAlg(squares[p])
end

function Engine.algToIndex64(p)
	local algToSq = Engine.algToSq(p)
	return algToSq and sq[algToSq] or nil
end

function Engine.new(p)
	local self = setmetatable({}, Engine)
	self.board = table.create(120, 7)
	self.kingSq = { [1] = 0, [-1] = 0 }
	self.side = 1
	self.castling = 0
	self.ep = 0
	self.halfmove = 0
	self.fullmove = 1
	self.ply = 0
	self.h1 = 0
	self.h2 = 0
	self.uMove = {}
	self.uCap = {}
	self.uCastle = {}
	self.uEp = {}
	self.uHalf = {}
	self.uH1 = {}
	self.uH2 = {}
	self.history = {}
	self:loadFen(p or Engine.START_FEN)
	return self
end

function Engine:computeHash()
	local board = self.board
	local v18 = 0
	local v19 = 0

	for i = 1, 64 do
		local v20 = squares[i]
		local v21 = board[v20]

		if v21 == 0 then
			continue
		end

		local v22 = (v21 + 6) * 120 + v20
		v18 = bxor(v18, v10[v22])
		v19 = bxor(v19, v11[v22])
	end

	if self.side == -1 then
		v18 = bxor(v18, v12)
		v19 = bxor(v19, v13)
	end

	local h1 = bxor(v18, v14[self.castling])
	local h2 = bxor(v19, v15[self.castling])

	if self.ep ~= 0 then
		local v20 = fileOf(self.ep) -- inferred equivalent call
		h1 = bxor(h1, v16[v20])
		h2 = bxor(h2, v17[v20])
	end

	self.h1 = h1
	self.h2 = h2
end

function Engine:_epCapturable(p): boolean
	local side = self.side

	if rankOf(p) ~= (side == 1 and 5 or 2) then -- inferred equivalent call
		return false
	end

	local v18 = p - 10 * side
	local v19 = 1 * side
	local board = self.board

	if board[p] ~= 0 or board[p + 10 * side] ~= 0 then
		return false
	end

	return board[v18] == -v19 and (board[v18 - 1] == v19 or board[v18 + 1] == v19)
end

function Engine:loadFen(startFen)
	local v18 = {}

	for _, v19 in string.split(startFen, " ") do
		if v19 ~= "" then
			table.insert(v18, v19)
		end
	end

	local board = self.board

	for i = 1, 120 do
		board[i] = 7
	end

	for i = 1, 64 do
		board[squares[i]] = 0
	end

	self.kingSq[1] = 0
	self.kingSq[-1] = 0

	local v19 = v18[1] or ""
	local total = 0
	local v20 = 7

	for i = 1, #v19 do
		local v21 = string.sub(v19, i, i)

		if v21 == "/" then
			v20 -= 1
			total = 0
		elseif tonumber(v21) then
			total += tonumber(v21)
		else
			local v22 = string.lower(v21)
			local v23 = v8[v22]

			if v23 and total <= 7 and v20 >= 0 then
				local v24 = v21 == v22 and -1 or 1
				local sq2 = toSq(total, v20) -- inferred equivalent call
				board[sq2] = v23 * v24

				if v23 == 6 then
					self.kingSq[v24] = sq2
				end
			end

			total += 1
		end
	end

	self.side = v18[2] == "b" and -1 or 1
	local v21 = v18[3] or "-"
	local total2 = 0

	if string.find(v21, "K", 1, true) and board[26] == 6 and board[29] == 4 then
		total2 += 1
	end

	if string.find(v21, "Q", 1, true) and board[26] == 6 and board[22] == 4 then
		total2 += 2
	end

	if string.find(v21, "k", 1, true) and board[96] == -6 and board[99] == -4 then
		total2 += 4
	end

	if string.find(v21, "q", 1, true) and board[96] == -6 and board[92] == -4 then
		total2 += 8
	end

	self.castling = total2
	self.ep = 0
	local v22 = v18[4]

	if v22 and v22 ~= "-" then
		local algToSq = Engine.algToSq(v22)

		if algToSq and self:_epCapturable(algToSq) then
			self.ep = algToSq
		end
	end

	self.halfmove = tonumber(v18[5]) or 0
	self.fullmove = tonumber(v18[6]) or 1
	self.ply = 0
	self.history = {}
	self.startFen = startFen
	self:computeHash()
end

function Engine.getFen(data)
	local board = data.board
	local v18 = {}

	for i = 7, 0, -1 do
		local count = 0
		local v19 = ""

		for j = 0, 7 do
			local v20 = board[toSq(j, i)] -- inferred equivalent call

			if v20 == 0 then
				count += 1
			else
				if count > 0 then
					v19 ..= tostring(count)
					count = 0
				end

				local v21 = v5[abs(v20)]
				v21 = v20 > 0 and string.upper(v21) or v21
				v19 ..= v21
			end
		end

		if count > 0 then
			v19 ..= tostring(count)
		end

		table.insert(v18, v19)
	end

	local v19 = ""

	if band(data.castling, 1) ~= 0 then
		v19 ..= "K"
	end

	if band(data.castling, 2) ~= 0 then
		v19 ..= "Q"
	end

	if band(data.castling, 4) ~= 0 then
		v19 ..= "k"
	end

	if band(data.castling, 8) ~= 0 then
		v19 ..= "q"
	end

	local v20 = v19 == "" and "-" or v19

	local v21 = data.ep == 0 and "-" or Engine.sqToAlg(data.ep) or "-"
	return table.concat(v18, "/") .. " " .. (data.side == 1 and "w" or "b") .. " " .. v20 .. " " .. v21 .. " " .. tostring(data.halfmove) .. " " .. tostring(data.fullmove)
end

function Engine.pieceAt(p, p2)
	return p.board[squares[p2]]
end

function Engine.boardArray(p)
	local result = table.create(64, 0)
	local board = p.board

	for i = 1, 64 do
		result[i] = board[squares[i]]
	end

	return result
end

function Engine.kingIndex64(p, p2)
	return sq[p.kingSq[p2]]
end

function Engine:isAttacked(p, p2): boolean
	local board = self.board

	if p2 == 1 then
		if board[p - 9] == 1 or board[p - 11] == 1 then
			return true
		end
	elseif board[p + 9] == -1 or board[p + 11] == -1 then
		return true
	end

	local v18 = 2 * p2

	for i = 1, 8 do
		if board[p + v[i]] == v18 then
			return true
		end
	end

	local v19 = 6 * p2

	for i = 1, 8 do
		if board[p + v4[i]] == v19 then
			return true
		end
	end

	local v20 = 3 * p2
	local v21 = 4 * p2
	local v22 = 5 * p2

	for i = 1, 4 do
		local v23 = v2[i]
		local v24 = p + v23
		local v25 = board[v24]

		while v25 == 0 do
			v24 += v23
			v25 = board[v24]
		end

		if v25 == v20 or v25 == v22 then
			return true
		end
	end

	for i = 1, 4 do
		local v23 = v3[i]
		local v24 = p + v23
		local v25 = board[v24]

		while v25 == 0 do
			v24 += v23
			v25 = board[v24]
		end

		if v25 == v21 or v25 == v22 then
			return true
		end
	end

	return false
end

function Engine:inCheck()
	return self:isAttacked(self.kingSq[self.side], -self.side)
end

function Engine:genPseudo(p, p2)
	local board = self.board
	local side = self.side
	local ep = self.ep
	local v18 = 0

	for i = 1, 64 do
		local v19 = squares[i]
		local v20 = board[v19]

		if not (v20 ~= 0 and (v20 > 0) == (side > 0)) then
			continue
		end

		local v21 = v20 * side

		if v21 == 1 then
			local v22 = 10 * side
			local v23 = v19 + v22
			local v24 = rankOf(v23) -- inferred equivalent call
			local v25 = v24 == 7 or v24 == 0

			if board[v23] == 0 then
				if v25 then
					v18 += 1
					p[v18] = v19 + v23 * 128 + 81920 + 0

					if not p2 then
						local v26 = v18 + 1
						p[v26] = v19 + v23 * 128 + 32768 + 0
						local v27 = v26 + 1
						p[v27] = v19 + v23 * 128 + 65536 + 0
						v18 = v27 + 1
						p[v18] = v19 + v23 * 128 + 49152 + 0
					end
				elseif not p2 then
					v18 += 1
					p[v18] = v19 + v23 * 128 + 0 + 0
					local v26 = side == 1 and 1 or 6

					if rankOf(v19) == v26 and board[v23 + v22] == 0 then -- inferred equivalent call
						v18 += 1
						p[v18] = v19 + (v23 + v22) * 128 + 0 + 131072
					end
				end
			end

			for j = -1, 1, 2 do
				local v26 = v23 + j
				local v27 = board[v26]

				if v27 == 0 or v27 == 7 or not (v27 * side < 0) then
					if ep ~= 0 and v26 == ep then
						v18 += 1
						p[v18] = v19 + v26 * 128 + 0 + 262144
					end
				elseif v25 then
					v18 += 1
					p[v18] = v19 + v26 * 128 + 81920 + 0

					if not p2 then
						local v28 = v18 + 1
						p[v28] = v19 + v26 * 128 + 32768 + 0
						local v29 = v28 + 1
						p[v29] = v19 + v26 * 128 + 65536 + 0
						v18 = v29 + 1
						p[v18] = v19 + v26 * 128 + 49152 + 0
					end
				else
					v18 += 1
					p[v18] = v19 + v26 * 128 + 0 + 0
				end
			end
		elseif v21 == 2 or v21 == 6 then
			local v22 = v21 == 2 and v or v4

			for j = 1, 8 do
				local v23 = v19 + v22[j]
				local v24 = board[v23]

				if v24 == 0 then
					if not p2 then
						v18 += 1
						p[v18] = v19 + v23 * 128 + 0 + 0
					end
				elseif v24 ~= 7 and v24 * side < 0 then
					v18 += 1
					p[v18] = v19 + v23 * 128 + 0 + 0
				end
			end

			if v21 == 6 and not p2 and self.castling ~= 0 then
				local castling = self.castling

				if side == 1 and v19 == 26 then
					if
						band(castling, 1) ~= 0
						and board[27] == 0
						and board[28] == 0
						and board[29] == 4
						and not (self:isAttacked(26, -1) or self:isAttacked(27, -1))
					then
						v18 += 1
						p[v18] = 396826
					end

					if
						band(castling, 2) ~= 0
						and board[25] == 0
						and board[24] == 0
						and board[23] == 0
						and board[22] == 4
						and not (self:isAttacked(26, -1) or self:isAttacked(25, -1))
					then
						v18 += 1
						p[v18] = 527386
					end
				elseif side == -1 and v19 == 96 then
					if
						band(castling, 4) ~= 0
						and board[97] == 0
						and board[98] == 0
						and board[99] == -4
						and not (self:isAttacked(96, 1) or self:isAttacked(97, 1))
					then
						v18 += 1
						p[v18] = 405856
					end

					if
						band(castling, 8) ~= 0
						and board[95] == 0
						and board[94] == 0
						and board[93] == 0
						and board[92] == -4
						and not (self:isAttacked(96, 1) or self:isAttacked(95, 1))
					then
						v18 += 1
						p[v18] = 536416
					end
				end
			end
		else
			local v22 = v21 == 3 and v2 or v21 == 4 and v3 or v4

			for j = 1, #v22 do
				local v23 = v22[j]
				local v24 = v19 + v23
				local v25 = board[v24]

				while v25 == 0 do
					if not p2 then
						v18 += 1
						p[v18] = v19 + v24 * 128 + 0 + 0
					end

					v24 += v23
					v25 = board[v24]
				end

				if not (v25 ~= 7 and v25 * side < 0) then
					continue
				end

				v18 += 1
				p[v18] = v19 + v24 * 128 + 0 + 0
			end
		end
	end

	return v18
end

function Engine:makeMove(p)
	local board = self.board
	local v18 = band(p, 127)
	local v19 = extract(p, 7, 7)
	local v20 = extract(p, 14, 3)
	local v21 = extract(p, 17, 3)
	local side = self.side
	local v22 = board[v18]
	local v23 = board[v19]
	local ply = self.ply + 1
	self.ply = ply
	self.uMove[ply] = p
	self.uCap[ply] = v23
	self.uCastle[ply] = self.castling
	self.uEp[ply] = self.ep
	self.uHalf[ply] = self.halfmove
	local h1 = self.h1
	local h2 = self.h2
	self.uH1[ply] = h1
	self.uH2[ply] = h2

	if self.ep ~= 0 then
		local v24 = fileOf(self.ep) -- inferred equivalent call
		h1 = bxor(h1, v16[v24])
		h2 = bxor(h2, v17[v24])
	end

	local v24 = bxor(h1, v14[self.castling])
	local v25 = bxor(h2, v15[self.castling])

	local v26 = (v22 + 6) * 120
	local v27 = bxor(v24, v10[v26 + v18])
	local v28 = bxor(v25, v11[v26 + v18])
	board[v18] = 0

	if v23 ~= 0 then
		local v29 = (v23 + 6) * 120 + v19
		v27 = bxor(v27, v10[v29])
		v28 = bxor(v28, v11[v29])
	end

	local v29

	if v20 == 0 then
		v29 = v22
	else
		v29 = v20 * side
	end

	board[v19] = v29
	local v30 = (v29 + 6) * 120 + v19
	local v31 = bxor(v27, v10[v30])
	local v32 = bxor(v28, v11[v30])

	local ep = 0

	if v21 == 2 then
		local v43 = v19 - 10 * side
		local v44 = board[v43]
		board[v43] = 0
		local v45 = (v44 + 6) * 120 + v43
		v31 = bxor(v31, v10[v45])
		v32 = bxor(v32, v11[v45])
	elseif v21 == 1 then
		local v43 = -1 * side

		if board[v19 - 1] == v43 or board[v19 + 1] == v43 then
			ep = v18 + 10 * side
		end
	elseif v21 == 3 then
		local v43 = v19 + 1
		local v44 = v19 - 1
		local v45 = board[v43]
		board[v43] = 0
		board[v44] = v45
		local v46 = (v45 + 6) * 120
		v31 = bxor(v31, v10[v46 + v43], v10[v46 + v44])
		v32 = bxor(v32, v11[v46 + v43], v11[v46 + v44])
	elseif v21 == 4 then
		local v43 = v19 - 2
		local v44 = v19 + 1
		local v45 = board[v43]
		board[v43] = 0
		board[v44] = v45
		local v46 = (v45 + 6) * 120
		v31 = bxor(v31, v10[v46 + v43], v10[v46 + v44])
		v32 = bxor(v32, v11[v46 + v43], v11[v46 + v44])
	end

	if v22 == 6 * side then
		self.kingSq[side] = v19
	end

	local castling = band(self.castling, v9[v18], v9[v19])
	self.castling = castling
	local v47 = bxor(v31, v14[castling])
	local v49 = bxor(v32, v15[castling])
	self.ep = ep

	if ep ~= 0 then
		local v50 = fileOf(ep) -- inferred equivalent call
		v47 = bxor(v47, v16[v50])
		v49 = bxor(v49, v17[v50])
	end

	if v22 == 1 * side or v23 ~= 0 then
		self.halfmove = 0
	else
		self.halfmove += 1
	end

	if side == -1 then
		self.fullmove += 1
	end

	self.side = -side
	self.h1 = bxor(v47, v12)
	self.h2 = bxor(v49, v13)
end

function Engine:undoMove()
	local ply = self.ply

	if ply <= 0 then
		return
	end

	local v18 = self.uMove[ply]
	local v19 = band(v18, 127)
	local v20 = extract(v18, 7, 7)
	local v21 = extract(v18, 14, 3)
	local v22 = extract(v18, 17, 3)
	local side = -self.side
	self.side = side
	local board = self.board
	local v23 = board[v20]

	if v21 ~= 0 then
		v23 = 1 * side
	end

	board[v19] = v23
	board[v20] = self.uCap[ply]

	if v22 == 2 then
		board[v20 - 10 * side] = -1 * side
	elseif v22 == 3 then
		board[v20 + 1] = board[v20 - 1]
		board[v20 - 1] = 0
	elseif v22 == 4 then
		board[v20 - 2] = board[v20 + 1]
		board[v20 + 1] = 0
	end

	if v23 == 6 * side then
		self.kingSq[side] = v19
	end

	self.castling = self.uCastle[ply]
	self.ep = self.uEp[ply]
	self.halfmove = self.uHalf[ply]
	self.h1 = self.uH1[ply]
	self.h2 = self.uH2[ply]

	if side == -1 then
		self.fullmove -= 1
	end

	self.ply = ply - 1
end

function Engine:makeNull()
	local ply = self.ply + 1
	self.ply = ply
	self.uMove[ply] = 0
	self.uCap[ply] = 0
	self.uCastle[ply] = self.castling
	self.uEp[ply] = self.ep
	self.uHalf[ply] = self.halfmove
	local h1 = self.h1
	local h2 = self.h2
	self.uH1[ply] = h1
	self.uH2[ply] = h2

	if self.ep ~= 0 then
		local v18 = fileOf(self.ep) -- inferred equivalent call
		h1 = bxor(h1, v16[v18])
		h2 = bxor(h2, v17[v18])
		self.ep = 0
	end

	self.halfmove += 1
	self.side = -self.side
	self.h1 = bxor(h1, v12)
	self.h2 = bxor(h2, v13)
end

function Engine:undoNull()
	local ply = self.ply
	self.side = -self.side
	self.ep = self.uEp[ply]
	self.halfmove = self.uHalf[ply]
	self.h1 = self.uH1[ply]
	self.h2 = self.uH2[ply]
	self.ply = ply - 1
end

function Engine:legalMoves()
	local v18 = {}
	local genPseudo = self:genPseudo(v18, false)

	local side = self.side
	local result = {}

	for i = 1, genPseudo do
		local v19 = v18[i]
		self:makeMove(v19)

		if not self:isAttacked(self.kingSq[side], -side) then
			result[#result + 1] = v19
		end

		self:undoMove()
	end

	return result
end

function Engine:legalMovesFrom64(p)
	local v18 = squares[p]
	local result = {}

	for _, v19 in self:legalMoves() do
		if band(v19, 127) == v18 then
			result[#result + 1] = v19
		end
	end

	return result
end

function Engine:repetitionCount()
	local h1 = self.h1
	local h2 = self.h2
	local ply = self.ply
	local v18 = math.max(1, ply - self.halfmove + 1)
	local uH1 = self.uH1
	local uH2 = self.uH2
	local v19 = ply - 1
	local v20 = 1

	while v18 <= v19 do
		if uH1[v19] == h1 and uH2[v19] == h2 then
			v20 += 1
		end

		v19 -= 2
	end

	return v20
end

function Engine:insufficientMaterial(): boolean
	local board = self.board
	local count = 0
	local count2 = 0
	local v18 = false
	local v19 = false

	for i = 1, 64 do
		local v20 = squares[i]
		local v21 = board[v20]

		if v21 == 0 then
			continue
		end

		local v22 = abs(v21)

		if v22 == 1 or v22 == 4 or v22 == 5 then
			return false
		end

		if v22 == 2 then
			count2 += 1
		elseif v22 == 3 then
			count += 1

			if (fileOf(v20) + rankOf(v20)) % 2 == 0 then -- inferred equivalent call
				v19 = true
			else
				v18 = true
			end
		end
	end

	return count2 + count <= 1 or count2 == 0 and not (v18 and v19)
end

function Engine.hasMatingMaterial(p, p2): boolean
	local board = p.board
	local count = 0

	for i = 1, 64 do
		local v18 = board[squares[i]]

		if not (v18 ~= 0 and (v18 > 0) == (p2 > 0)) then
			continue
		end

		local v19 = abs(v18)

		if v19 == 1 or v19 == 4 or v19 == 5 then
			return true
		end

		if v19 == 2 or v19 == 3 then
			count += 1
		end
	end

	return count >= 2
end

function Engine:status(): string
	if #self:legalMoves() == 0 then
		return if self:inCheck() then "checkmate" else "stalemate"
	end

	if self:insufficientMaterial() then
		return "insufficient"
	end

	if self.halfmove >= 100 then
		return "fifty"
	end

	if self:repetitionCount() >= 3 then
		return "repetition"
	end

	return "ongoing"
end

function Engine:moveToUci(p)
	local v18 = Engine.sqToAlg((band(p, 127))) .. Engine.sqToAlg((extract(p, 7, 7)))
	local v19 = extract(p, 14, 3)

	if v19 ~= 0 then
		return v18 .. v5[v19]
	end

	return v18
end

function Engine:moveFromUci(value)
	if type(value) ~= "string" then
		return nil
	end

	local v18 = string.gsub(string.lower(value), "[=%s]", "")

	if #v18 < 4 or #v18 > 5 then
		return nil
	end

	local algToSq = Engine.algToSq((string.sub(v18, 1, 2)))
	local algToSq2 = Engine.algToSq((string.sub(v18, 3, 4)))

	if not (algToSq and algToSq2) then
		return nil
	end

	local v19 = string.sub(v18, 5, 5)
	local v20

	if v19 == "" then
		v20 = 0
	else
		v20 = v8[v19]

		if not v20 or v20 == 1 or v20 == 6 then
			return nil
		end
	end

	for _, v21 in self:legalMoves() do
		if band(v21, 127) == algToSq and extract(v21, 7, 7) == algToSq2 and extract(v21, 14, 3) == v20 then
			return v21
		end
	end

	return nil
end

function Engine:moveToSan(p)
	local board = self.board
	local v18 = band(p, 127)
	local v19 = extract(p, 7, 7)
	local v20 = extract(p, 14, 3)
	local v21 = extract(p, 17, 3)
	local v22 = board[v18]
	local v23 = abs(v22)
	local v24

	if v21 == 3 then
		v24 = "O-O"
	elseif v21 == 4 then
		v24 = "O-O-O"
	else
		local v25 = board[v19] ~= 0 or v21 == 2

		if v23 == 1 then
			if v25 then
				v24 = v7[fileOf(v18) + 1] .. "x" .. Engine.sqToAlg(v19) -- inferred equivalent call
			else
				v24 = Engine.sqToAlg(v19)
			end

			if v20 ~= 0 then
				v24 ..= "=" .. v6[v20]
			end
		else
			local flag = false
			local v26 = false
			local flag2 = false

			for _, v27 in self:legalMoves() do
				local v28 = band(v27, 127)

				if not (v28 ~= v18 and extract(v27, 7, 7) == v19 and board[v28] == v22) then
					continue
				end

				flag = true
				v26 = fileOf(v28) == fileOf(v18) or v26 -- inferred equivalent call

				if rankOf(v28) == rankOf(v18) then -- inferred equivalent call
					flag2 = true
				end
			end

			local v27

			if flag then
				if v26 then
					if flag2 then
						v27 = Engine.sqToAlg(v18)
					else
						v27 = tostring(rankOf(v18) + 1) -- inferred equivalent call
					end
				else
					v27 = v7[fileOf(v18) + 1] -- inferred equivalent call
				end
			else
				v27 = ""
			end

			v24 = v6[v23] .. v27 .. (v25 and "x" or "") .. Engine.sqToAlg(v19)
		end
	end

	self:makeMove(p)

	if self:inCheck() then
		v24 ..= #self:legalMoves() == 0 and "#" or "+"
	end

	self:undoMove()
	return v24
end

function Engine:play(move)
	local san = self:moveToSan(move)
	local uci = self:moveToUci(move)
	local captured = self.board[extract(move, 7, 7)]

	if extract(move, 17, 3) == 2 then
		captured = -1 * self.side
	end

	self:makeMove(move)
	local history = self.history
	history[#history + 1] = { uci = uci, san = san, move = move, captured = captured }
	return san
end

function Engine:playUci(p)
	local v18 = self:moveFromUci(p)

	if v18 then
		return self:play(v18), v18
	end

	return nil
end

function Engine:takeback(): boolean
	local history = self.history

	if #history == 0 then
		return false
	end

	table.remove(history)
	self:undoMove()
	return true
end

function Engine.lastMove(p)
	local history = p.history
	return history[#history]
end

function Engine:perft(p)
	if p == 0 then
		return 1
	end

	local v18 = {}
	local genPseudo = self:genPseudo(v18, false)

	local side = self.side
	local total = 0

	for i = 1, genPseudo do
		self:makeMove(v18[i])

		if not self:isAttacked(self.kingSq[side], -side) then
			total += p == 1 and 1 or self:perft(p - 1)
		end

		self:undoMove()
	end

	return total
end

return Engine