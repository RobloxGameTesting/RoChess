local Levels = {
	XP_WIN = 30,
	XP_DRAW = 20,
	XP_LOSS = 12,
	XP_PUZZLE = 1,
	XP_PUZZLE_MISS = 0,
	XP_RUSH_PER = 1,
	XP_RUSH_MAX = 30,
	LEVEL_TOKENS = 1,
	LEVEL_BONUS_EVERY = 5,
	LEVEL_BONUS_TOKENS = 3,
	need = function(p)
		return 25 * (p + 1)
	end,
	total = function(p)
		local v = p - 1
		return 25 * (v * (v + 1) // 2 + v)
	end
}

function Levels.of(p)
	local v = math.max(0, (math.floor(tonumber(p) or 0)))

	local v2 = math.max(1, (math.floor((math.sqrt(9 + 8 * v / 25) + -1) / 2)))

	while v2 > 1 and v < Levels.total(v2) do
		v2 -= 1
	end

	while Levels.total(v2 + 1) <= v do
		v2 += 1
	end

	return v2, v - Levels.total(v2), Levels.need(v2)
end

function Levels.reward(p)
	if p <= 1 then
		return 0
	end

	if Levels.LEVEL_BONUS_EVERY > 0 and p % Levels.LEVEL_BONUS_EVERY == 0 then
		return Levels.LEVEL_BONUS_TOKENS
	end

	return Levels.LEVEL_TOKENS
end

function Levels.rewardBetween(p, p2)
	local total = 0

	for i = p + 1, p2 do
		total += Levels.reward(i)
	end

	return total
end

return Levels