local Config = {}
Config.SPRITE_ASSET_ID = 110181402669597
Config.PLACE_NAME = "Chess"
Config.TOURNAMENTS_ENABLED = false
Config.TIME_CONTROLS = {
	{
		id = "1+0",
		base = 60,
		inc = 0,
		label = "1 min",
		class = "bullet"
	},
	{
		id = "1+1",
		base = 60,
		inc = 1,
		label = "1 | 1",
		class = "bullet"
	},
	{
		id = "2+1",
		base = 120,
		inc = 1,
		label = "2 | 1",
		class = "bullet"
	},
	{
		id = "3+0",
		base = 180,
		inc = 0,
		label = "3 min",
		class = "blitz"
	},
	{
		id = "3+2",
		base = 180,
		inc = 2,
		label = "3 | 2",
		class = "blitz"
	},
	{
		id = "5+0",
		base = 300,
		inc = 0,
		label = "5 min",
		class = "blitz"
	},
	{
		id = "10+0",
		base = 600,
		inc = 0,
		label = "10 min",
		class = "rapid"
	},
	{
		id = "15+10",
		base = 900,
		inc = 10,
		label = "15 | 10",
		class = "rapid"
	},
	{
		id = "30+0",
		base = 1800,
		inc = 0,
		label = "30 min",
		class = "rapid"
	}
}

Config.TC_BY_ID = {}

for _, v in Config.TIME_CONTROLS do
	Config.TC_BY_ID[v.id] = v
end

Config.DEFAULT_TC = "3+2"

Config.CLASSES = { "bullet", "blitz", "rapid" }
Config.CLASS_LABEL = { bullet = "Bullet", blitz = "Blitz", rapid = "Rapid" }
Config.CLASS_ICON = { bullet = "bullet", blitz = "bolt", rapid = "timer" }
Config.CLASS_COLOR = {
	bullet = Color3.fromRGB(227, 170, 36),
	blitz = Color3.fromRGB(250, 214, 72),
	rapid = Color3.fromRGB(46, 196, 182)
}

Config.RATING_BOOST = 200

Config.DEFAULT_RATING = 400
Config.PUZZLE_DEFAULT_RATING = 400
Config.DEFAULT_RD = 350
Config.DEFAULT_VOL = 0.06
Config.MIN_RD = 45
Config.PROVISIONAL_RD = 110

Config.SKILL_LEVELS = {
	{ id = "new", label = "New to chess", sub = "I'm learning how the pieces move", rating = 200 },
	{
		id = "beginner",
		label = "Beginner",
		sub = "I know the rules and basic tactics",
		rating = 400
	},
	{
		id = "intermediate",
		label = "Intermediate",
		sub = "I play regularly and know some openings",
		rating = 600
	},
	{ id = "advanced", label = "Advanced", sub = "I'm a strong club player", rating = 800 }
}

Config.FIRST_MOVE_SECONDS = 25

Config.QUEUE_FALLBACK_OPPONENTS = true

Config.MERGE_SERVERS = true

Config.MERGE_HEADROOM = 2

Config.BOT_FALLBACK_MIN = 25
Config.BOT_FALLBACK_MAX = 40

Config.MATCH_WINDOW_MAX = 200

Config.MATCH_HIGH_RATING = 1800
Config.MATCH_WINDOW_MAX_HIGH = 400

function Config.matchWindowCap(value)
	if (value or 0) >= Config.MATCH_HIGH_RATING then
		return Config.MATCH_WINDOW_MAX_HIGH
	end

	return Config.MATCH_WINDOW_MAX
end

Config.ONB_FLOW_B_SHARE = 0.5

Config.ONB_WELCOME = true
Config.FIRST_GAME_WAIT_B = { 2, 4 }
Config.NEW_PLAYER_GAMES = 5
Config.NEW_PLAYER_FALLBACK_MIN = 6
Config.NEW_PLAYER_FALLBACK_MAX = 9
Config.DISCONNECT_GRACE = 15
Config.DRAW_OFFER_COOLDOWN_PLIES = 10
Config.MAX_HISTORY = 100
Config.HISTORY_PAGE = 25

Config.BOARD_THEMES = {
	{
		id = "green",
		name = "Harbor",
		light = Color3.fromRGB(227, 234, 242),
		dark = Color3.fromRGB(95, 127, 160)
	},
	{
		id = "brown",
		name = "Brown",
		crate = "common",
		light = Color3.fromRGB(240, 217, 181),
		dark = Color3.fromRGB(181, 136, 99)
	},
	{
		id = "blue",
		name = "Blue",
		crate = "common",
		light = Color3.fromRGB(234, 233, 210),
		dark = Color3.fromRGB(75, 115, 153)
	},
	{
		id = "icy",
		name = "Frost",
		crate = "common",
		light = Color3.fromRGB(197, 213, 220),
		dark = Color3.fromRGB(122, 157, 178)
	},
	{
		id = "purple",
		name = "Purple",
		crate = "common",
		light = Color3.fromRGB(239, 239, 239),
		dark = Color3.fromRGB(136, 119, 183)
	},
	{
		id = "walnut",
		name = "Hazel",
		crate = "common",
		light = Color3.fromRGB(234, 211, 173),
		dark = Color3.fromRGB(160, 113, 75)
	},
	{
		id = "tournament",
		name = "Club",
		crate = "common",
		light = Color3.fromRGB(235, 236, 230),
		dark = Color3.fromRGB(49, 104, 74)
	},
	{
		id = "dash",
		name = "Caramel",
		crate = "common",
		light = Color3.fromRGB(189, 146, 85),
		dark = Color3.fromRGB(107, 64, 33)
	},
	{
		id = "sand",
		name = "Sandstone",
		crate = "common",
		light = Color3.fromRGB(238, 222, 190),
		dark = Color3.fromRGB(196, 158, 108)
	},
	{
		id = "mint",
		name = "Mint",
		crate = "common",
		light = Color3.fromRGB(226, 242, 228),
		dark = Color3.fromRGB(112, 178, 146)
	},
	{
		id = "slate",
		name = "Slate",
		crate = "common",
		light = Color3.fromRGB(206, 211, 218),
		dark = Color3.fromRGB(112, 122, 138)
	},
	{
		id = "rose",
		name = "Rose",
		crate = "common",
		light = Color3.fromRGB(246, 228, 230),
		dark = Color3.fromRGB(204, 124, 140)
	},
	{
		id = "ocean",
		name = "Ocean",
		crate = "rare",
		style = "gradient",
		light = Color3.fromRGB(205, 236, 244),
		dark = Color3.fromRGB(52, 132, 180)
	},
	{
		id = "autumn",
		name = "Autumn",
		crate = "rare",
		style = "gradient",
		light = Color3.fromRGB(246, 226, 188),
		dark = Color3.fromRGB(206, 108, 56)
	},
	{
		id = "lavender",
		name = "Lavender Haze",
		crate = "rare",
		style = "gradient",
		light = Color3.fromRGB(238, 230, 250),
		dark = Color3.fromRGB(146, 116, 204)
	},
	{
		id = "oak",
		name = "Oak",
		crate = "rare",
		style = "wood",
		light = Color3.fromRGB(236, 206, 158),
		dark = Color3.fromRGB(164, 104, 60)
	},
	{
		id = "crimson",
		name = "Crimson",
		crate = "rare",
		style = "gradient",
		light = Color3.fromRGB(246, 226, 220),
		dark = Color3.fromRGB(186, 66, 76)
	},
	{
		id = "candy",
		name = "Candy",
		crate = "epic",
		style = "gloss",
		light = Color3.fromRGB(255, 220, 236),
		dark = Color3.fromRGB(104, 196, 228)
	},
	{
		id = "midnight",
		name = "Midnight",
		crate = "epic",
		style = "gloss",
		hint = Color3.new(1, 1, 1),
		light = Color3.fromRGB(160, 170, 208),
		dark = Color3.fromRGB(86, 98, 150)
	},
	{
		id = "marble",
		name = "Marble",
		crate = "epic",
		style = "marble",
		light = Color3.fromRGB(238, 236, 232),
		dark = Color3.fromRGB(96, 128, 120)
	},
	{
		id = "lagoon",
		name = "Lagoon",
		crate = "epic",
		style = "waves",
		light = Color3.fromRGB(240, 230, 200),
		dark = Color3.fromRGB(56, 166, 184)
	},
	{
		id = "goldleaf",
		name = "Gold Leaf",
		crate = "legendary",
		style = "shimmer",
		light = Color3.fromRGB(255, 242, 206),
		dark = Color3.fromRGB(208, 162, 62)
	},
	{
		id = "prism",
		name = "Prism",
		crate = "legendary",
		style = "prism",
		light = Color3.fromRGB(246, 244, 238),
		dark = Color3.fromRGB(150, 120, 220)
	},
	{
		id = "nightsky",
		name = "Night Sky",
		crate = "legendary",
		style = "starry",
		hint = Color3.fromRGB(24, 22, 60),
		light = Color3.fromRGB(208, 206, 236),
		dark = Color3.fromRGB(70, 74, 144)
	},
	{
		id = "hw_pumpkin",
		name = "Pumpkin Patch",
		crate = "rare",
		event = "halloween",
		style = "gradient",
		light = Color3.fromRGB(255, 228, 188),
		dark = Color3.fromRGB(226, 112, 32)
	},
	{
		id = "hw_haunted",
		name = "Haunted Night",
		crate = "legendary",
		event = "halloween",
		style = "haunted",
		hint = Color3.fromRGB(255, 190, 90),
		light = Color3.fromRGB(206, 192, 224),
		dark = Color3.fromRGB(62, 40, 92)
	},
	{
		id = "vip_royal",
		name = "VIP Royal",
		crate = "vip",
		vip = true,
		style = "royal",
		hint = Color3.fromRGB(120, 72, 10),
		light = Color3.fromRGB(246, 230, 184),
		dark = Color3.fromRGB(104, 62, 132),
		veinLight = Color3.fromRGB(200, 146, 40),
		veinDark = Color3.fromRGB(255, 206, 92),
		joint = Color3.fromRGB(70, 46, 18)
	}
}

Config.THEME_BY_ID = {}

for _, v in Config.BOARD_THEMES do
	Config.THEME_BY_ID[v.id] = v
end

Config.DEFAULT_SETTINGS = {
	theme = "green",
	sound = true,
	showLegal = true,
	coords = true,
	premove = true,
	autoQueen = false,
	highlightLast = true,
	animate = true,
	confirmResign = true,
	music = true,
	quickChat = true,
	vibration = true,
	allowChallenges = true
}

Config.MUSIC_VOLUME = 0.22
Config.MUSIC = {
	{ id = 9047104336, name = "Sunday In Bed" },
	{ id = 9046863253, name = "Poolside" },
	{ id = 73303361159954, name = "Sunday Morning Keys with Jazz Piano" },
	{ id = 82388278389517, name = "Corner Café Crush" },
	{ id = 84638374437335, name = "Desk Lamp Glow" },
	{ id = 70514921085587, name = "Silent Library Vibes" },
	{ id = 138276578183464, name = "Moonlit Notes and Coffee Pots" },
	{ id = 80392798485193, name = "Rooftop Rent Day" }
}

Config.BOT_CATEGORIES = {
	{ id = "beginner", name = "Beginner", color = Color3.fromRGB(46, 196, 182) },
	{ id = "intermediate", name = "Intermediate", color = Color3.fromRGB(96, 178, 214) },
	{ id = "advanced", name = "Advanced", color = Color3.fromRGB(240, 140, 60) },
	{ id = "master", name = "Master", color = Color3.fromRGB(202, 52, 49) },
	{ id = "boss", name = "Boss", color = Color3.fromRGB(150, 70, 230) }
}

local v = {
	{ 250, 1, 0.15, 260, 0.35 },
	{ 400, 1, 0.2, 180, 0.22 },
	{ 600, 2, 0.25, 120, 0.14 },
	{ 800, 2, 0.3, 80, 0.08 },
	{ 1000, 3, 0.4, 55, 0.05 },
	{ 1200, 3, 0.5, 35, 0.03 },
	{ 1400, 4, 0.6, 22, 0.015 },
	{ 1600, 5, 0.8, 12, 0.006 },
	{ 1800, 6, 1.2, 6, 0 },
	{ 2000, 20, 2, 0, 0 },
	{ 2200, 20, 3, 0, 0 }
}

function Config.botStrength(p)
	local v2 = v[1]
	local v3 = v[#v]

	for i = 1, #v - 1 do
		if v[i][1] <= p and p <= v[i + 1][1] then
			v2 = v[i]
			v3 = v[i + 1]
			break
		end
	end

	local v4 = v3[1] == v2[1] and 0 or math.clamp((p - v2[1]) / (v3[1] - v2[1]), 0, 1)
	local function mix(p2) -- 3 equivalent calls inferred from this helper
		return v2[p2] + (v3[p2] - v2[p2]) * v4
	end

	return {
		depth = v4 < 0.5 and v2[2] or v3[2],
		time = mix(3), -- inferred equivalent call
		noise = mix(4), -- inferred equivalent call
		blunder = mix(5) -- inferred equivalent call
	}
end

local function bot(id, name, rating, category, p, p2, p3, bio)
	local botStrength = Config.botStrength(rating)
	return {
		id = id,
		name = name,
		rating = rating,
		category = category,
		color = Color3.fromRGB(p, p2, p3),
		bio = bio,
		depth = botStrength.depth,
		time = botStrength.time,
		noise = botStrength.noise,
		blunder = botStrength.blunder
	}
end

Config.BOTS = {
	bot("pebble", "Pebble", 250, "beginner", 141, 198, 63, "Just learned how the horsey moves. Be nice!"),
	bot("milo", "Milo", 400, "beginner", 90, 190, 140, "Loves attacking, forgets to defend."),
	bot("poppy", "Poppy", 500, "beginner", 245, 150, 190, "Moves fast and hopes for the best."),
	bot("clara", "Clara", 600, "beginner", 80, 170, 220, "Plays it safe and waits for your mistakes."),
	bot("benny", "Benny", 700, "beginner", 200, 160, 90, "Never met a pawn he didn't want to push."),
	bot("jasper", "Jasper", 800, "intermediate", 110, 120, 230, "A solid club regular. Watch your queen."),
	bot("ivy", "Ivy", 900, "intermediate", 70, 160, 110, "Quiet moves, sneaky traps."),
	bot("nova", "Nova", 1000, "intermediate", 170, 100, 230, "Sharp tactics, shaky endgames."),
	bot("felix", "Felix", 1100, "intermediate", 230, 130, 60, "Will trade everything and grind you down."),
	bot("atlas", "Atlas", 1200, "intermediate", 230, 90, 160, "Knows his openings cold."),
	bot("vega", "Vega", 1400, "advanced", 240, 110, 80, "Patient positional player."),
	bot("marco", "Marco", 1500, "advanced", 60, 140, 200, "Gambits first, questions later."),
	bot("orion", "Orion", 1600, "advanced", 240, 160, 50, "Calculates deep and punishes loose pieces."),
	bot("sable", "Sable", 1700, "advanced", 90, 90, 110, "Cold, precise, and very hard to surprise."),
	bot("titan", "Titan", 1800, "advanced", 200, 70, 60, "Tournament-hardened. Rarely blunders."),
	bot("hector", "Hector", 1900, "master", 150, 110, 70, "A veteran who has seen every trick."),
	bot("maximus", "Maximus", 2000, "master", 60, 60, 70, "Full strength. Good luck."),
	bot("zenith", "Zenith", 2100, "master", 120, 80, 200, "Thinks longer than anyone else here."),
	bot("apex", "Apex", 2200, "master", 30, 30, 35, "The strongest bot in RoChess. Can you beat it?"),
	bot(
		"vortex",
		"Vortex",
		2800,
		"boss",
		150,
		70,
		230,
		"The Vortex engine at full strength: it powers every RoChess bot from 1600 up. Nobody has beaten it yet."
	)
}

Config.BOT_BY_ID = {}

for _, v2 in Config.BOTS do
	Config.BOT_BY_ID[v2.id] = v2
end

Config.DONATE_PRODUCTS = {
	{ id = 3724455508, robux = 10 },
	{ id = 3724455520, robux = 50 },
	{ id = 3724455530, robux = 100 },
	{ id = 3724455552, robux = 500 },
	{ id = 3724455570, robux = 1000 },
	{ id = 3724455579, robux = 5000 },
	{ id = 3729113257, robux = 10000 },
	{ id = 3729113354, robux = 50000 }
}

Config.TOKEN_PACKS = {
	{ id = 3724455385, tokens = 10, robux = 20, name = "Handful" },
	{ id = 3724455390, tokens = 30, robux = 50, name = "Pouch" },
	{ id = 3724455397, tokens = 75, robux = 110, name = "Sack" },
	{ id = 3724455410, tokens = 200, robux = 250, name = "Chest" },
	{ id = 3724455422, tokens = 500, robux = 500, name = "Vault" }
}

Config.TOKEN_PACK_BY_ID = {}

for _, v2 in Config.TOKEN_PACKS do
	if v2.id ~= 0 then
		Config.TOKEN_PACK_BY_ID[v2.id] = v2
	end
end

Config.FREE_REVIEWS_PER_DAY = 1

Config.REVIEW_PASS = 2058055743
Config.LEGACY_REVIEW_PASS = 2002688905
Config.REVIEW_PASS_ROBUX = 79
Config.REVIEW_AD_PRODUCT = 3724455596

Config.REVIEW_CARD = "preview"
Config.REVIEW_CARD_KEY = "review_card"

Config.REVIEW_PREVIEWS_PER_SESSION = 6

Config.VIP_PASS = 2061822289
Config.LEGACY_VIP_PASS = 2034392332
Config.VIP_ROBUX = 199
Config.VIP_XP_MULT = 1.5
Config.VIP_TOKEN_MULT = 2

function Config.vipXp(p, p2)
	return p2 and math.floor(p * Config.VIP_XP_MULT + 0.5) or p
end

function Config.vipTokens(p, p2)
	return p2 and p * Config.VIP_TOKEN_MULT or p
end

Config.DONATE_BY_ID = {}

for _, v2 in Config.DONATE_PRODUCTS do
	Config.DONATE_BY_ID[v2.id] = v2
end

Config.GIFTS = {
	{
		key = "vip",
		kind = "vip",
		id = 3724455433,
		robux = 199,
		name = "VIP"
	},
	{
		key = "review",
		kind = "review",
		id = 3724455446,
		robux = 79,
		name = "Infinite Game Breakdown"
	},
	{
		key = "t30",
		kind = "tokens",
		tokens = 30,
		id = 3724455458,
		robux = 50,
		name = "30 Tokens"
	},
	{
		key = "t75",
		kind = "tokens",
		tokens = 75,
		id = 3724455469,
		robux = 110,
		name = "75 Tokens"
	},
	{
		key = "t200",
		kind = "tokens",
		tokens = 200,
		id = 3724455482,
		robux = 250,
		name = "200 Tokens"
	},
	{
		key = "t500",
		kind = "tokens",
		tokens = 500,
		id = 3724455499,
		robux = 500,
		name = "500 Tokens"
	}
}

Config.GIFT_PRICE_CHECK = false
function Config.rebuildGifts()
	Config.GIFT_BY_ID = {}
	Config.GIFT_BY_KEY = {}

	for _, v2 in Config.GIFTS do
		Config.GIFT_BY_KEY[v2.key] = v2

		if v2.id ~= 0 then
			Config.GIFT_BY_ID[v2.id] = v2
		end
	end
end
Config.rebuildGifts()

Config.DAILY_TASKS = {
	{
		id = "play",
		label = "Play 5 games",
		goal = 5,
		reward = 1,
		icon = "pawn",
		color = Color3.fromRGB(46, 196, 182)
	},
	{
		id = "win",
		label = "Win 2 games",
		goal = 2,
		reward = 3,
		icon = "trophy",
		color = Color3.fromRGB(242, 190, 66)
	},
	{
		id = "capture",
		label = "Capture 50 pieces",
		goal = 50,
		reward = 2,
		icon = "swords",
		color = Color3.fromRGB(245, 166, 35)
	}
}

Config.TASK_BY_ID = {}

for _, v2 in Config.DAILY_TASKS do
	Config.TASK_BY_ID[v2.id] = v2
end

Config.TASK_MIN_PLIES = 10
Config.TASK_RESET_HOUR_UTC = 0

Config.QUICK_CHAT = {
	"Good luck!",
	"Have fun!",
	"Nice move!",
	"Oops!",
	"Thanks!",
	"Good game!",
	"Well played!",
	"Rematch?",
	utf8.char(128077),
	utf8.char(128558),
	utf8.char(128517),
	utf8.char(128293)
}

Config.SOUNDS = {
	move = { id = 140328930064176, volume = 1.1, speed = 1 },
	capture = { id = 109239080496907, volume = 1.1, speed = 1 },
	check = { id = 115636363867751, volume = 1.1, speed = 1 },
	castle = { id = 72791776642892, volume = 1.1, speed = 1 },
	promote = { id = 113931580693212, volume = 1.1, speed = 1 },
	start = { id = 139144475868476, volume = 1, speed = 1 },
	finish = { id = 96662713837315, volume = 2.8, speed = 1 },
	notify = { id = 119064983572776, volume = 1, speed = 1 },
	lowtime = { id = 78209441695712, volume = 1.1, speed = 1 },
	illegal = { id = 76897410814925, volume = 0.85, speed = 1 }
}

Config.UI_SOUNDS = {
	press = {
		ids = { 80217974944172, 104090062488535, 129770605537421 },
		volume = 0.45,
		jitter = 0.04,
		cooldown = 0.04
	},
	confirm = {
		ids = { 77999342895552 },
		volume = 0.5,
		jitter = 0.03,
		cooldown = 0.08
	},
	cancel = {
		ids = { 88431307422684 },
		volume = 0.45,
		jitter = 0.03,
		cooldown = 0.08
	},
	hover = {
		ids = { 82664691035175, 120122901726450 },
		volume = 0.12,
		jitter = 0.06,
		cooldown = 0.07
	},
	tab = {
		ids = { 123266924845685 },
		volume = 0.4,
		jitter = 0.04,
		cooldown = 0.05
	},
	toggleOn = {
		ids = { 128889600377247 },
		volume = 0.5,
		cooldown = 0.05
	},
	toggleOff = {
		ids = { 133752947030051 },
		volume = 0.5,
		cooldown = 0.05
	},
	locked = {
		ids = { 119278169084385 },
		volume = 0.45,
		cooldown = 0.15
	},
	open = {
		ids = { 112914786697730 },
		volume = 0.4,
		jitter = 0.02,
		cooldown = 0.1
	},
	close = {
		ids = { 123463854968649 },
		volume = 0.35,
		jitter = 0.02,
		cooldown = 0.1
	},
	toast = {
		ids = { 130282937589000, 102127302066583 },
		volume = 0.4,
		jitter = 0.05,
		cooldown = 0.12
	},
	tick = {
		ids = { 98969213997646 },
		volume = 0.25,
		cooldown = 0.045
	},
	step = {
		ids = { 105663192287415 },
		volume = 0.45,
		cooldown = 0.1
	},
	success = {
		ids = { 138689840207150 },
		volume = 0.55,
		cooldown = 0.2
	},
	error = {
		ids = { 136171931059880 },
		volume = 0.45,
		cooldown = 0.15
	},
	win = {
		ids = { 99119807713848 },
		volume = 0.6,
		cooldown = 0.5
	},
	lose = {
		ids = { 75883288994292 },
		volume = 0.5,
		cooldown = 0.5
	},
	draw = {
		ids = { 107797134927608 },
		volume = 0.5,
		cooldown = 0.5
	},
	unlock = {
		ids = { 84197296384081 },
		volume = 0.55,
		cooldown = 0.3
	},
	currency = {
		ids = { 121888120571732, 73510856404491 },
		volume = 0.6,
		cooldown = 0.1
	},
	transition = {
		ids = { 117323436231794 },
		volume = 0.5,
		cooldown = 0.3
	}
}

Config.HAPTIC_MERGE = 0.06
Config.HAPTICS = {
	press = { type = "UIClick", weight = 1 },
	tab = { type = "UIClick", weight = 1 },
	cancel = { type = "UIClick", weight = 1 },
	confirm = { type = "UIClick", weight = 1 },
	toggleOn = {
		keys = {
			{ 0, 0.45 },
			{ 25, 0.45 },
			{ 26, 0 }
		},
		weight = 1
	},
	toggleOff = {
		keys = {
			{ 0, 0.3 },
			{ 20, 0.3 },
			{ 21, 0 }
		},
		weight = 1
	},
	step = {
		keys = {
			{ 0, 0.35 },
			{ 30, 0.35 },
			{ 31, 0 }
		},
		weight = 1
	},
	reel = {
		keys = {
			{ 0, 0.35 },
			{ 22, 0.35 },
			{ 23, 0 }
		},
		weight = 1,
		cooldown = 0.05
	},
	locked = {
		keys = {
			{ 0, 0.4 },
			{ 35, 0.4 },
			{ 36, 0 },
			{ 80, 0 },
			{ 81, 0.4 },
			{ 116, 0.4 },
			{ 117, 0 }
		},
		weight = 2,
		cooldown = 0.15
	},
	currency = {
		keys = {
			{ 0, 0.45 },
			{ 25, 0.45 },
			{ 26, 0 },
			{ 75, 0 },
			{ 76, 0.55 },
			{ 101, 0.55 },
			{ 102, 0 }
		},
		weight = 2,
		cooldown = 0.1
	},
	error = {
		keys = {
			{ 0, 0.75 },
			{ 130, 0.75 },
			{ 170, 0 }
		},
		weight = 3,
		cooldown = 0.15
	},
	success = {
		keys = {
			{ 0, 0.45 },
			{ 30, 0.45 },
			{ 31, 0 },
			{ 80, 0 },
			{ 81, 0.85 },
			{ 121, 0.85 },
			{ 170, 0 }
		},
		weight = 3,
		cooldown = 0.2
	},
	notify = { type = "UINotification", weight = 3, cooldown = 0.3 },
	unlock = {
		keys = {
			{ 0, 0.35 },
			{ 90, 1 },
			{ 120, 1 },
			{ 220, 0 }
		},
		weight = 4,
		cooldown = 0.3
	},
	win = {
		keys = {
			{ 0, 0.5 },
			{ 45, 0.5 },
			{ 46, 0 },
			{ 100, 0 },
			{ 101, 0.75 },
			{ 146, 0.75 },
			{ 147, 0 },
			{ 200, 0 },
			{ 201, 1 },
			{ 300, 1 },
			{ 450, 0 }
		},
		weight = 5,
		cooldown = 0.5
	},
	lose = {
		keys = {
			{ 0, 0.6 },
			{ 350, 0 }
		},
		weight = 5,
		cooldown = 0.5
	},
	draw = {
		keys = {
			{ 0, 0.6 },
			{ 70, 0.6 },
			{ 71, 0 },
			{ 150, 0 },
			{ 151, 0.6 },
			{ 221, 0.6 },
			{ 222, 0 }
		},
		weight = 5,
		cooldown = 0.5
	},
	legendary = { type = "GameplayExplosion", weight = 6, cooldown = 1 },
	move = {
		keys = {
			{ 0, 0.55 },
			{ 25, 0.55 },
			{ 45, 0 }
		},
		weight = 2,
		game = true
	},
	capture = {
		keys = {
			{ 0, 0.9 },
			{ 30, 0.9 },
			{ 80, 0 }
		},
		weight = 3,
		game = true
	},
	castle = {
		keys = {
			{ 0, 0.55 },
			{ 25, 0.55 },
			{ 26, 0 },
			{ 85, 0 },
			{ 86, 0.7 },
			{ 111, 0.7 },
			{ 131, 0 }
		},
		weight = 3,
		game = true
	},
	promote = {
		keys = {
			{ 0, 0.25 },
			{ 140, 0.9 },
			{ 170, 0.9 },
			{ 200, 0 }
		},
		weight = 3,
		game = true
	},
	illegal = {
		keys = {
			{ 0, 0.5 },
			{ 30, 0.5 },
			{ 31, 0 },
			{ 70, 0 },
			{ 71, 0.5 },
			{ 101, 0.5 },
			{ 102, 0 },
			{ 140, 0 },
			{ 141, 0.5 },
			{ 171, 0.5 },
			{ 172, 0 }
		},
		weight = 3,
		cooldown = 0.2
	},
	check = {
		keys = {
			{ 0, 0.85 },
			{ 40, 0.85 },
			{ 41, 0 },
			{ 100, 0 },
			{ 101, 0.85 },
			{ 141, 0.85 },
			{ 160, 0 }
		},
		weight = 4,
		game = true
	},
	start = {
		keys = {
			{ 0, 0.3 },
			{ 120, 0.8 },
			{ 150, 0.8 },
			{ 200, 0 }
		},
		weight = 4,
		game = true
	},
	lowtime = {
		keys = {
			{ 0, 0.8 },
			{ 70, 0.8 },
			{ 71, 0 },
			{ 150, 0 },
			{ 151, 0.8 },
			{ 221, 0.8 },
			{ 222, 0 },
			{ 300, 0 },
			{ 301, 0.8 },
			{ 371, 0.8 },
			{ 372, 0 }
		},
		weight = 4,
		game = true
	},
	finish = {
		keys = {
			{ 0, 1 },
			{ 50, 1 },
			{ 250, 0 }
		},
		weight = 5,
		game = true
	}
}

Config.PIECE_IMAGES = {
	wK = 108253639129512,
	wQ = 128494764910602,
	wR = 133288029788689,
	wB = 85269847273836,
	wN = 111025513068016,
	wP = 130108347060797,
	bK = 99364349373891,
	bQ = 87797543393819,
	bR = 92908975354335,
	bB = 72796651173850,
	bN = 104573159846789,
	bP = 71167246324478
}

Config.ICON_ATLAS_ID = 0
Config.ICON_ATLAS = {
	cell = 112,
	perRow = 9,
	names = {
		"bolt",
		"bullet",
		"timer",
		"flip",
		"first",
		"prev",
		"next",
		"last",
		"flag",
		"close",
		"settings",
		"bot",
		"trophy",
		"person",
		"group",
		"history",
		"puzzle",
		"play",
		"search",
		"check",
		"chat",
		"analysis",
		"star",
		"thumbup",
		"up",
		"down",
		"volume",
		"mute",
		"home",
		"swords",
		"info",
		"crown",
		"hourglass",
		"replay",
		"add",
		"back",
		"menu",
		"eye",
		"bulb",
		"undo",
		"handshake",
		"arrowhead",
		"calendar",
		"leaderboard",
		"mail",
		"bell",
		"edit",
		"globe",
		"shuffle",
		"lock",
		"help",
		"trend",
		"school",
		"chart",
		"pause",
		"download",
		"more",
		"heart",
		"crate",
		"grid",
		"boardicon",
		"landscape",
		"gift",
		"token",
		"pawn",
		"rook",
		"tophat"
	}
}

Config.SPRITE_PIECES = {
	"wK",
	"wQ",
	"wR",
	"wB",
	"wN",
	"wP",
	"bK",
	"bQ",
	"bR",
	"bB",
	"bN",
	"bP"
}
Config.SPRITE_ICONS = {
	"bolt",
	"bullet",
	"timer",
	"flip",
	"first",
	"prev",
	"next",
	"last",
	"flag",
	"close",
	"settings",
	"bot",
	"trophy",
	"person",
	"group",
	"history",
	"puzzle",
	"play",
	"search",
	"check",
	"chat",
	"analysis",
	"star",
	"thumbup",
	"up",
	"down",
	"volume",
	"mute",
	"home",
	"swords",
	"info",
	"crown",
	"hourglass",
	"replay",
	"add",
	"back",
	"menu",
	"eye",
	"bulb",
	"undo",
	"handshake",
	"arrowhead",
	"pawn",
	"calendar",
	"leaderboard",
	"mail",
	"bell",
	"edit",
	"globe",
	"shuffle",
	"lock",
	"help",
	"trend",
	"school",
	"chart",
	"pause",
	"download",
	"more"
}

function Config.timeClass(p, p2): string
	local v2 = p + 40 * p2

	if v2 < 180 then
		return "bullet"
	end

	return if v2 < 600 then "blitz" else "rapid"
end

function Config.formatClock(p)
	local v2 = (p < 0 and 0 or p) / 1000

	if v2 < 20 then
		local v3 = math.floor(v2 * 10) / 10
		return string.format("0:%04.1f", v3)
	end

	local v3 = math.ceil(v2 - 0.0001)
	local v4 = v3 // 3600
	local v5 = v3 % 3600 // 60
	local v6 = v3 % 60

	if v4 > 0 then
		return string.format("%d:%02d:%02d", v4, v5, v6)
	end

	return string.format("%d:%02d", v5, v6)
end

return Config