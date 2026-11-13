local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Engine = require(ReplicatedStorage.Chess.Engine)
local Config = require(ReplicatedStorage.Chess.Config)

local Session = {}
Session.__index = Session

local v = { 8, 2, 2, 2, 1 }
local v2 = { 1, 3, 3, 5, 9, 0 }

function Session.new(kind, options)
	local v3 = options or {}
	local self = setmetatable({}, Session)
	self.kind = kind
	self.id = v3.id
	self.startFen = v3.startFen
	self.engine = Engine.new(v3.startFen)
	self.ucis = {}
	self.sans = {}
	self.positions = { [0] = self.engine:boardArray() }
	self.lastMoves = {}
	self.flags = {}
	self.checks = { [0] = self:checkSquare() }
	self.myColor = v3.myColor
	self.white = v3.white or { display = "White" }
	self.black = v3.black or { display = "Black" }
	self.bot = v3.bot
	self.rated = v3.rated
	self.class = v3.class
	local tc

	if v3.tc then
		tc = Config.TC_BY_ID[v3.tc] or nil
	end

	self.tc = tc

	if self.tc then
		local v4 = self.tc.base * 1000
		self.clocks = { [1] = v4, [-1] = v4 }

		if v3.clocks then
			self.clocks[1] = v3.clocks.w
			self.clocks[-1] = v3.clocks.b
		end
	end

	self.turnStart = v3.turnStart or 0
	self.deadline = v3.deadline
	self.over = false
	self.version = 0

	for _, v4 in v3.ucis or {} do
		if not self:applyUci(v4) then
			break
		end
	end

	self.viewPly = #self.ucis
	return self
end

function Session.ply(p)
	return #p.ucis
end

function Session:checkSquare()
	local engine = self.engine

	if engine:inCheck() then
		return engine:kingIndex64(engine.side)
	end

	return nil
end

function Session:applyMove(p)
	local engine = self.engine
	local from, to = Engine.moveSquares64(p)
	local v3 = Engine.moveFlag(p)
	local capture = engine.board[Engine.moveTo(p)] ~= 0 or v3 == Engine.F_EP
	local v4 = engine:moveToUci(p)
	local san = engine:play(p)
	local v5 = #self.ucis + 1
	self.ucis[v5] = v4
	self.sans[v5] = san
	self.positions[v5] = engine:boardArray()
	self.lastMoves[v5] = { from = from, to = to }
	self.checks[v5] = self:checkSquare()
	self.flags[v5] = {
		capture = capture,
		castle = v3 == Engine.F_OO or v3 == Engine.F_OOO,
		promo = Engine.movePromo(p) ~= 0,
		san = san
	}

	self.version += 1
	return v5, san
end

function Session:applyUci(p)
	local v3 = self.engine:moveFromUci(p)

	if v3 then
		return self:applyMove(v3)
	end

	return nil
end

local function findIn(object, p, p2, value)
	local v3 = Engine.SQUARES[p]
	local v4 = Engine.SQUARES[p2]
	local v5 = value or 0

	for _, v6 in object:legalMoves() do
		if Engine.moveFrom(v6) == v3 and Engine.moveTo(v6) == v4 and Engine.movePromo(v6) == v5 then
			return v6
		end
	end

	return nil
end

local function targetsIn(object, p)
	local v3 = Engine.SQUARES[p]
	local result = {}

	for _, v4 in object:legalMoves() do
		if Engine.moveFrom(v4) ~= v3 then
			continue
		end

		local _, v5 = Engine.moveSquares64(v4)

		if Engine.movePromo(v4) == 0 then
			if result[v5] == nil then
				result[v5] = false
			end
		else
			result[v5] = true
		end
	end

	return result
end

function Session.findMove(p, p2, p3, p4)
	return findIn(p.engine, p2, p3, p4)
end

function Session.targets(p, p2)
	return targetsIn(p.engine, p2)
end

function Session:engineAt(ply)
	if #self.ucis <= ply then
		return self.engine
	end

	local atCache = self.atCache

	if atCache and atCache.ply == ply and atCache.version == self.version then
		return atCache.engine
	end

	local engine = Engine.new(self.startFen)

	for i = 1, ply do
		local v3 = engine:moveFromUci(self.ucis[i])

		if not v3 then
			break
		end

		engine:play(v3)
	end

	self.atCache = { ply = ply, version = self.version, engine = engine }
	return engine
end

function Session:findMoveAt(p, p2, p3, p4)
	return findIn(self:engineAt(p), p2, p3, p4)
end

function Session:targetsAt(p, p2)
	return targetsIn(self:engineAt(p), p2)
end

function Session.sideAt(data, p)
	return (#data.ucis - (p or data.viewPly)) % 2 == 0 and data.engine.side or -data.engine.side
end

function Session:truncate(p)
	while p < #self.ucis do
		self:undo()
	end
end

function Session:undo(): boolean
	local count = #self.ucis

	if count == 0 then
		return false
	end

	self.engine:takeback()
	self.ucis[count] = nil
	self.sans[count] = nil
	self.positions[count] = nil
	self.lastMoves[count] = nil
	self.checks[count] = nil
	self.flags[count] = nil
	self.version += 1

	if self.viewPly > #self.ucis then
		self.viewPly = #self.ucis
	end

	return true
end

function Session.sideToMove(p)
	return p.engine.side
end

function Session.isMyTurn(p): boolean
	return p.myColor ~= nil and p.engine.side == p.myColor
end

function Session.clockFor(data, p, p2)
	if not data.clocks then
		return 0
	end

	local clock = data.clocks[p]

	if not data.over and data.engine.side == p and #data.ucis >= 2 then
		clock -= (p2 - data.turnStart) * 1000
	end

	return (math.max(0, clock))
end

function Session.material(p, p2)
	local position = p.positions[p2 or p.viewPly]
	local v3 = {}

	for i = 1, 64 do
		local v4 = position[i]

		if v4 ~= 0 then
			v3[v4] = (v3[v4] or 0) + 1
		end
	end

	local total = 0
	local total2 = 0
	local result = {}
	local result2 = {}

	for i = 1, 5 do
		local v4 = v3[i] or 0
		local v5 = v3[-i] or 0
		total += v4 * v2[i]
		total2 += v5 * v2[i]

		for _ = 1, math.max(0, v[i] - v5) do
			table.insert(result, -i)
		end

		for _ = 1, math.max(0, v[i] - v4) do
			table.insert(result2, i)
		end
	end

	return result, result2, total - total2
end

function Session:status()
	return self.engine:status()
end

function Session.pgn(p, value)
	local v3 = {}

	for k, san in p.sans do
		if k % 2 == 1 then
			table.insert(v3, tostring((k + 1) // 2) .. ".")
		end

		table.insert(v3, san)
	end

	table.insert(v3, value or "*")
	return table.concat(v3, " ")
end

return Session