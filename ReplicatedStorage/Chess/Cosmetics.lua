local Config = require(script.Parent.Config)

local Cosmetics = {}
Cosmetics.CRATE_PRICE = 10
Cosmetics.TOKENS_FOR_SALE = next(Config.TOKEN_PACK_BY_ID) ~= nil

Cosmetics.RARITIES = {
	{
		id = "common",
		name = "Common",
		weight = 60,
		refund = 1,
		color = Color3.fromRGB(176, 176, 176)
	},
	{
		id = "rare",
		name = "Rare",
		weight = 28,
		refund = 2,
		color = Color3.fromRGB(78, 152, 244)
	},
	{
		id = "epic",
		name = "Epic",
		weight = 10,
		refund = 3,
		color = Color3.fromRGB(176, 96, 240)
	},
	{
		id = "legendary",
		name = "Legendary",
		weight = 2,
		refund = 5,
		color = Color3.fromRGB(255, 192, 48)
	}
}

Cosmetics.RARITY = {}

for k, v in Cosmetics.RARITIES do
	v.order = k
	Cosmetics.RARITY[v.id] = v
end

Cosmetics.RARITY.vip = {
	id = "vip",
	name = "VIP",
	weight = 0,
	refund = 0,
	color = Color3.fromRGB(255, 204, 64),
	order = #Cosmetics.RARITIES + 1
}

Cosmetics.TYPES = {
	{
		id = "board",
		name = "Boards",
		one = "Board",
		crate = "Board Crate",
		icon = "boardicon",
		color = Color3.fromRGB(46, 196, 182)
	},
	{
		id = "background",
		name = "Backgrounds",
		one = "Background",
		crate = "Background Crate",
		icon = "landscape",
		color = Color3.fromRGB(96, 178, 214)
	},
	{
		id = "pieces",
		name = "Piece Sets",
		one = "Piece Set",
		crate = "Piece Crate",
		icon = "pawn",
		color = Color3.fromRGB(240, 140, 60)
	},
	{
		id = "accessory",
		name = "Accessories",
		one = "Accessory",
		crate = "Accessory Crate",
		icon = "tophat",
		color = Color3.fromRGB(235, 82, 116)
	},
	{
		id = "effect",
		name = "Effects",
		one = "Effect",
		crate = "Effect Crate",
		icon = "star",
		color = Color3.fromRGB(176, 96, 240)
	}
}

Cosmetics.TYPE = {}

for _, v in Cosmetics.TYPES do
	Cosmetics.TYPE[v.id] = v
end

local function rgb(p, p2, p3) -- 167 equivalent calls inferred from this helper
	return Color3.fromRGB(p, p2, p3)
end

local v = {
	{
		id = "bg_default",
		name = "Classic",
		free = true,
		style = "living",
		c1 = rgb(40, 43, 50), -- inferred equivalent call
		c2 = rgb(27, 29, 34), -- inferred equivalent call
		c3 = rgb(16, 17, 21) -- inferred equivalent call
	},
	{
		id = "bg_navy",
		name = "Navy",
		rarity = "common",
		style = "soft",
		c1 = rgb(30, 37, 56), -- inferred equivalent call
		c2 = rgb(70, 100, 180), -- inferred equivalent call
		ui = rgb(70, 110, 200) -- inferred equivalent call
	},
	{
		id = "bg_forest",
		name = "Forest",
		rarity = "common",
		style = "soft",
		c1 = rgb(28, 46, 36), -- inferred equivalent call
		c2 = rgb(80, 160, 100), -- inferred equivalent call
		ui = rgb(70, 170, 110) -- inferred equivalent call
	},
	{
		id = "bg_plum",
		name = "Plum",
		rarity = "common",
		style = "soft",
		c1 = rgb(48, 30, 52), -- inferred equivalent call
		c2 = rgb(170, 80, 170), -- inferred equivalent call
		ui = rgb(170, 90, 190) -- inferred equivalent call
	},
	{
		id = "bg_charcoal",
		name = "Charcoal",
		rarity = "common",
		style = "soft",
		c1 = rgb(24, 24, 27), -- inferred equivalent call
		c2 = rgb(90, 90, 100), -- inferred equivalent call
		ui = rgb(120, 120, 135), -- inferred equivalent call
		uiv = 0.78
	},
	{
		id = "bg_wine",
		name = "Garnet",
		rarity = "common",
		style = "soft",
		c1 = rgb(50, 22, 32), -- inferred equivalent call
		c2 = rgb(196, 64, 96), -- inferred equivalent call
		ui = rgb(206, 76, 110) -- inferred equivalent call
	},
	{
		id = "bg_amber",
		name = "Amber",
		rarity = "common",
		style = "soft",
		c1 = rgb(46, 32, 18), -- inferred equivalent call
		c2 = rgb(214, 140, 50), -- inferred equivalent call
		ui = rgb(214, 150, 64) -- inferred equivalent call
	},
	{
		id = "bg_sunset",
		name = "Sunset",
		rarity = "rare",
		style = "sunset",
		c1 = rgb(34, 20, 66), -- inferred equivalent call
		c2 = rgb(250, 140, 70), -- inferred equivalent call
		ui = rgb(220, 90, 110) -- inferred equivalent call
	},
	{
		id = "bg_deepsea",
		name = "Deep Sea",
		rarity = "rare",
		style = "deepsea",
		c1 = rgb(22, 92, 128), -- inferred equivalent call
		c2 = rgb(6, 16, 34), -- inferred equivalent call
		ui = rgb(40, 150, 200) -- inferred equivalent call
	},
	{
		id = "bg_dusk",
		name = "Mint Dusk",
		rarity = "rare",
		style = "fireflies",
		c1 = rgb(24, 84, 70), -- inferred equivalent call
		c2 = rgb(22, 30, 50), -- inferred equivalent call
		rot = 45,
		ui = rgb(60, 190, 150) -- inferred equivalent call
	},
	{
		id = "bg_snow",
		name = "Snowfall",
		rarity = "rare",
		style = "snow",
		c1 = rgb(22, 30, 54), -- inferred equivalent call
		c2 = rgb(64, 88, 132), -- inferred equivalent call
		ui = rgb(110, 150, 210) -- inferred equivalent call
	},
	{
		id = "bg_sakura",
		name = "Sakura",
		rarity = "rare",
		style = "sakura",
		c1 = rgb(52, 28, 60), -- inferred equivalent call
		c2 = rgb(226, 132, 168), -- inferred equivalent call
		ui = rgb(226, 120, 166) -- inferred equivalent call
	},
	{
		id = "bg_stars",
		name = "Starfield",
		rarity = "epic",
		style = "stars",
		c1 = rgb(14, 18, 36), -- inferred equivalent call
		c2 = rgb(30, 26, 60), -- inferred equivalent call
		rot = 90,
		ui = rgb(90, 100, 220) -- inferred equivalent call
	},
	{
		id = "bg_drift",
		name = "Checker Drift",
		rarity = "epic",
		style = "drift",
		c1 = rgb(36, 44, 40), -- inferred equivalent call
		c2 = rgb(58, 74, 62), -- inferred equivalent call
		ui = rgb(90, 160, 110) -- inferred equivalent call
	},
	{
		id = "bg_synth",
		name = "Synthwave",
		rarity = "epic",
		style = "synth",
		c1 = rgb(18, 8, 38), -- inferred equivalent call
		c2 = rgb(255, 64, 160), -- inferred equivalent call
		ui = rgb(214, 70, 200) -- inferred equivalent call
	},
	{
		id = "bg_aurora",
		name = "Aurora",
		rarity = "legendary",
		style = "aurora",
		c1 = rgb(6, 14, 26), -- inferred equivalent call
		c2 = rgb(12, 34, 44), -- inferred equivalent call
		ui = rgb(60, 200, 170) -- inferred equivalent call
	},
	{
		id = "bg_galaxy",
		name = "Galaxy",
		rarity = "legendary",
		style = "galaxy",
		c1 = rgb(16, 10, 30), -- inferred equivalent call
		c2 = rgb(70, 24, 90), -- inferred equivalent call
		ui = rgb(150, 70, 210) -- inferred equivalent call
	},
	{
		id = "bg_storm",
		name = "Thunderstorm",
		rarity = "legendary",
		style = "storm",
		c1 = rgb(12, 16, 26), -- inferred equivalent call
		c2 = rgb(40, 50, 72), -- inferred equivalent call
		ui = rgb(96, 128, 190) -- inferred equivalent call
	},
	{
		id = "bg_witching",
		name = "Witching Hour",
		rarity = "rare",
		event = "halloween",
		style = "witching",
		c1 = rgb(26, 14, 40), -- inferred equivalent call
		c2 = rgb(58, 30, 76), -- inferred equivalent call
		ui = rgb(230, 120, 40) -- inferred equivalent call
	},
	{
		id = "bg_bloodmoon",
		name = "Blood Moon",
		rarity = "epic",
		event = "halloween",
		style = "bloodmoon",
		c1 = rgb(20, 6, 10), -- inferred equivalent call
		c2 = rgb(70, 14, 22), -- inferred equivalent call
		ui = rgb(210, 56, 56) -- inferred equivalent call
	},
	{
		id = "bg_vip",
		name = "VIP Lounge",
		vip = true,
		style = "vip",
		c1 = rgb(14, 11, 8), -- inferred equivalent call
		c2 = rgb(52, 38, 14), -- inferred equivalent call
		ui = rgb(214, 168, 64), -- inferred equivalent call
		uiv = 0.9
	}
}

local v2 = {
	{ id = "pc_classic", name = "Classic", free = true },
	{
		id = "pc_mint",
		name = "Mint",
		rarity = "common",
		light = rgb(206, 246, 220), -- inferred equivalent call
		dark = rgb(46, 120, 88) -- inferred equivalent call
	},
	{
		id = "pc_sand",
		name = "Sandcastle",
		rarity = "common",
		light = rgb(248, 230, 188), -- inferred equivalent call
		dark = rgb(126, 84, 48) -- inferred equivalent call
	},
	{
		id = "pc_sky",
		name = "Sky",
		rarity = "common",
		light = rgb(214, 236, 255), -- inferred equivalent call
		dark = rgb(40, 76, 140) -- inferred equivalent call
	},
	{
		id = "pc_coral",
		name = "Coral",
		rarity = "common",
		light = rgb(255, 218, 204), -- inferred equivalent call
		dark = rgb(164, 64, 64) -- inferred equivalent call
	},
	{
		id = "pc_lemon",
		name = "Lemon",
		rarity = "common",
		light = rgb(255, 246, 186), -- inferred equivalent call
		dark = rgb(176, 134, 26) -- inferred equivalent call
	},
	{
		id = "pc_lilac",
		name = "Lilac",
		rarity = "common",
		light = rgb(236, 224, 255), -- inferred equivalent call
		dark = rgb(112, 80, 172) -- inferred equivalent call
	},
	{
		id = "pc_gem",
		name = "Ruby & Sapphire",
		rarity = "rare",
		light = rgb(255, 136, 146), -- inferred equivalent call
		light2 = rgb(220, 50, 70), -- inferred equivalent call
		dark = rgb(70, 110, 230), -- inferred equivalent call
		dark2 = rgb(30, 50, 140) -- inferred equivalent call
	},
	{
		id = "pc_candy",
		name = "Candy",
		rarity = "rare",
		light = rgb(255, 210, 238), -- inferred equivalent call
		light2 = rgb(255, 160, 210), -- inferred equivalent call
		dark = rgb(150, 80, 200), -- inferred equivalent call
		dark2 = rgb(100, 40, 150) -- inferred equivalent call
	},
	{
		id = "pc_frost",
		name = "Frost",
		rarity = "rare",
		light = rgb(240, 250, 255), -- inferred equivalent call
		light2 = rgb(170, 216, 246), -- inferred equivalent call
		dark = rgb(90, 150, 210), -- inferred equivalent call
		dark2 = rgb(40, 80, 150) -- inferred equivalent call
	},
	{
		id = "pc_peach",
		name = "Peach & Plum",
		rarity = "rare",
		light = rgb(255, 232, 196), -- inferred equivalent call
		light2 = rgb(255, 150, 130), -- inferred equivalent call
		dark = rgb(160, 80, 160), -- inferred equivalent call
		dark2 = rgb(70, 30, 100) -- inferred equivalent call
	},
	{
		id = "pc_jade",
		name = "Jade & Onyx",
		rarity = "rare",
		light = rgb(200, 250, 216), -- inferred equivalent call
		light2 = rgb(80, 190, 130), -- inferred equivalent call
		dark = rgb(112, 118, 132), -- inferred equivalent call
		dark2 = rgb(36, 38, 48) -- inferred equivalent call
	},
	{
		id = "pc_royal",
		name = "Gold & Silver",
		rarity = "epic",
		light = rgb(255, 232, 140), -- inferred equivalent call
		light2 = rgb(214, 156, 36), -- inferred equivalent call
		dark = rgb(196, 200, 210), -- inferred equivalent call
		dark2 = rgb(96, 102, 116), -- inferred equivalent call
		shine = true
	},
	{
		id = "pc_toxic",
		name = "Toxic",
		rarity = "epic",
		light = rgb(200, 255, 130), -- inferred equivalent call
		light2 = rgb(110, 220, 60), -- inferred equivalent call
		dark = rgb(150, 80, 210), -- inferred equivalent call
		dark2 = rgb(80, 30, 130), -- inferred equivalent call
		glow = true
	},
	{
		id = "pc_crystal",
		name = "Crystal",
		rarity = "epic",
		light = rgb(236, 250, 255), -- inferred equivalent call
		light2 = rgb(150, 214, 255), -- inferred equivalent call
		dark = rgb(196, 140, 255), -- inferred equivalent call
		dark2 = rgb(84, 44, 170), -- inferred equivalent call
		glint = true
	},
	{
		id = "pc_neon",
		name = "Neon",
		rarity = "legendary",
		light = rgb(150, 245, 255), -- inferred equivalent call
		dark = rgb(255, 110, 210), -- inferred equivalent call
		glow = true,
		anim = "pulse"
	},
	{
		id = "pc_inferno",
		name = "Inferno",
		rarity = "legendary",
		light = rgb(255, 236, 130), -- inferred equivalent call
		light2 = rgb(255, 110, 40), -- inferred equivalent call
		dark = rgb(150, 40, 30), -- inferred equivalent call
		dark2 = rgb(60, 14, 14), -- inferred equivalent call
		glow = true,
		anim = "flow"
	},
	{
		id = "pc_holo",
		name = "Holographic",
		rarity = "legendary",
		light = rgb(236, 236, 255), -- inferred equivalent call
		dark = rgb(120, 90, 170), -- inferred equivalent call
		glow = true,
		anim = "rainbow"
	},
	{
		id = "pc_pumpkin",
		name = "Pumpkin & Shadow",
		rarity = "rare",
		event = "halloween",
		light = rgb(255, 200, 112), -- inferred equivalent call
		light2 = rgb(236, 110, 24), -- inferred equivalent call
		dark = rgb(88, 68, 108), -- inferred equivalent call
		dark2 = rgb(20, 14, 28) -- inferred equivalent call
	},
	{
		id = "pc_ghostly",
		name = "Ghostly",
		rarity = "epic",
		event = "halloween",
		light = rgb(236, 255, 246), -- inferred equivalent call
		light2 = rgb(170, 240, 210), -- inferred equivalent call
		dark = rgb(150, 110, 210), -- inferred equivalent call
		dark2 = rgb(56, 28, 96), -- inferred equivalent call
		glow = true,
		anim = "pulse"
	},
	{
		id = "pc_vip",
		name = "VIP Gold & Onyx",
		vip = true,
		light = rgb(255, 234, 150), -- inferred equivalent call
		light2 = rgb(218, 158, 34), -- inferred equivalent call
		dark = rgb(92, 86, 96), -- inferred equivalent call
		dark2 = rgb(22, 20, 26), -- inferred equivalent call
		shine = true,
		glow = true,
		anim = "pulse"
	}
}

local v3 = {
	{ id = "fx_none", name = "None", free = true },
	{
		id = "fx_sparks",
		name = "Sparks",
		rarity = "common",
		kind = "burst",
		colors = { rgb(255, 230, 120), rgb(255, 255, 255), rgb(255, 180, 60) } -- inferred equivalent call
	},
	{
		id = "fx_puff",
		name = "Dust Puff",
		rarity = "common",
		kind = "puff",
		colors = { rgb(210, 205, 196), rgb(170, 164, 156) } -- inferred equivalent call
	},
	{
		id = "fx_confetti",
		name = "Confetti",
		rarity = "common",
		kind = "confetti",
		colors = { rgb(61, 139, 255), rgb(255, 200, 60), rgb(240, 110, 120), rgb(110, 170, 240) } -- inferred equivalent call
	},
	{
		id = "fx_bubbles",
		name = "Bubbles",
		rarity = "common",
		kind = "bubbles",
		colors = { rgb(140, 214, 255), rgb(190, 236, 255), rgb(255, 190, 240) } -- inferred equivalent call
	},
	{
		id = "fx_pixels",
		name = "Pixel Burst",
		rarity = "common",
		kind = "pixels",
		colors = {
			rgb(255, 84, 84), -- inferred equivalent call
			rgb(255, 206, 60), -- inferred equivalent call
			rgb(80, 220, 120), -- inferred equivalent call
			rgb(70, 160, 255), -- inferred equivalent call
			rgb(200, 110, 255)
		}
	},
	{
		id = "fx_hearts",
		name = "Hearts",
		rarity = "rare",
		kind = "icons",
		icon = "heart",
		colors = { rgb(255, 110, 150), rgb(255, 160, 190), rgb(235, 60, 100) } -- inferred equivalent call
	},
	{
		id = "fx_stars",
		name = "Stars",
		rarity = "rare",
		kind = "icons",
		icon = "star",
		colors = { rgb(255, 214, 70), rgb(255, 245, 180) } -- inferred equivalent call
	},
	{
		id = "fx_shockwave",
		name = "Shockwave",
		rarity = "rare",
		kind = "ring",
		colors = { rgb(120, 230, 255), rgb(255, 255, 255) } -- inferred equivalent call
	},
	{
		id = "fx_coins",
		name = "Coin Shower",
		rarity = "rare",
		kind = "coins",
		colors = { rgb(255, 206, 64), rgb(255, 238, 150), rgb(214, 150, 30) } -- inferred equivalent call
	},
	{
		id = "fx_lightning",
		name = "Lightning",
		rarity = "epic",
		kind = "lightning",
		colors = { rgb(255, 240, 120), rgb(180, 220, 255) } -- inferred equivalent call
	},
	{
		id = "fx_shatter",
		name = "Shatter",
		rarity = "epic",
		kind = "shatter",
		colors = { rgb(255, 255, 255), rgb(200, 220, 240) } -- inferred equivalent call
	},
	{
		id = "fx_fireworks",
		name = "Fireworks",
		rarity = "epic",
		kind = "fireworks",
		colors = {
			rgb(255, 90, 120), -- inferred equivalent call
			rgb(255, 210, 80), -- inferred equivalent call
			rgb(110, 220, 255), -- inferred equivalent call
			rgb(180, 120, 255), -- inferred equivalent call
			rgb(120, 255, 160)
		}
	},
	{
		id = "fx_slash",
		name = "Blade Slash",
		rarity = "epic",
		kind = "slash",
		colors = { rgb(150, 220, 255), rgb(255, 255, 255), rgb(80, 130, 255) } -- inferred equivalent call
	},
	{
		id = "fx_supernova",
		name = "Supernova",
		rarity = "legendary",
		kind = "supernova",
		colors = { rgb(255, 250, 220), rgb(255, 190, 60), rgb(255, 90, 60), rgb(170, 110, 255) } -- inferred equivalent call
	},
	{
		id = "fx_blackhole",
		name = "Black Hole",
		rarity = "legendary",
		kind = "blackhole",
		colors = { rgb(176, 96, 240), rgb(90, 200, 255), rgb(255, 255, 255) } -- inferred equivalent call
	},
	{
		id = "fx_meteor",
		name = "Meteor",
		rarity = "legendary",
		kind = "meteor",
		colors = { rgb(255, 236, 190), rgb(255, 160, 50), rgb(255, 80, 36), rgb(96, 84, 92) } -- inferred equivalent call
	},
	{
		id = "fx_ghosts",
		name = "Ghost Rise",
		rarity = "epic",
		event = "halloween",
		kind = "ghosts",
		colors = { rgb(240, 248, 255), rgb(140, 255, 180), rgb(190, 140, 255) } -- inferred equivalent call
	},
	{
		id = "fx_bats",
		name = "Bat Swarm",
		rarity = "legendary",
		event = "halloween",
		kind = "bats",
		colors = { rgb(36, 24, 46), rgb(255, 140, 40), rgb(96, 56, 128) } -- inferred equivalent call
	},
	{
		id = "fx_vip",
		name = "VIP Crown Drop",
		vip = true,
		kind = "vipcrown",
		icon = "crown",
		colors = { rgb(255, 206, 64), rgb(255, 244, 196), rgb(214, 150, 30) } -- inferred equivalent call
	}
}

Cosmetics.ITEMS = {}
Cosmetics.BY_ID = {}
Cosmetics.BY_TYPE = {}
Cosmetics.DEFAULT = {}

local function add(p, state)
	state.type = p
	state.rarity = state.vip and "vip" or state.rarity or "common"
	table.insert(Cosmetics.ITEMS, state)
	Cosmetics.BY_ID[state.id] = state
	Cosmetics.BY_TYPE[p] = Cosmetics.BY_TYPE[p] or {}
	table.insert(Cosmetics.BY_TYPE[p], state)

	if state.free and not Cosmetics.DEFAULT[p] then
		Cosmetics.DEFAULT[p] = state.id
	end
end

for _, v4 in Config.BOARD_THEMES do
	v4.free = v4.crate == nil
	v4.rarity = v4.crate or "common"
	add("board", v4)
end

Cosmetics.DEFAULT.board = Config.DEFAULT_SETTINGS.theme

for _, v4 in v do
	add("background", v4)
end

for _, v4 in v2 do
	add("pieces", v4)
end

for _, v4 in {
	{ id = "acc_none", name = "None", free = true },
	{ id = "acc_party", name = "Party Hat", rarity = "common", image = 70633967490956 },
	{ id = "acc_beanie", name = "Beanie", rarity = "common", image = 119781418929050 },
	{ id = "acc_cap", name = "Baseball Cap", rarity = "common", image = 71161545028188 },
	{ id = "acc_bow", name = "Bow", rarity = "common", image = 77321709483450 },
	{ id = "acc_chef", name = "Chef Hat", rarity = "common", image = 101294843493000 },
	{ id = "acc_beret", name = "Beret", rarity = "common", image = 99734964438534 },
	{ id = "acc_tophat", name = "Top Hat", rarity = "rare", image = 111439664299307 },
	{ id = "acc_cowboy", name = "Cowboy Hat", rarity = "rare", image = 129430268235769 },
	{ id = "acc_santa", name = "Santa Hat", rarity = "rare", image = 121251776192948 },
	{ id = "acc_headphones", name = "Headphones", rarity = "rare", image = 74437954198692 },
	{ id = "acc_pirate", name = "Pirate Hat", rarity = "rare", image = 114840192361900 },
	{ id = "acc_grad", name = "Graduation Cap", rarity = "rare", image = 82569410001078 },
	{ id = "acc_wizard", name = "Wizard Hat", rarity = "epic", image = 103040001650440 },
	{ id = "acc_viking", name = "Viking Helmet", rarity = "epic", image = 127837430463652 },
	{ id = "acc_propeller", name = "Propeller Cap", rarity = "epic", image = 78160338102730 },
	{ id = "acc_jester", name = "Jester Hat", rarity = "epic", image = 138832218803298 },
	{ id = "acc_crown", name = "Royal Crown", rarity = "legendary", image = 73214188142863 },
	{ id = "acc_halo", name = "Halo", rarity = "legendary", image = 78481874518198 },
	{
		id = "acc_flamecrown",
		name = "Flame Crown",
		rarity = "legendary",
		image = 84440540739720,
		fx = 97871238946052
	},
	{
		id = "acc_witch",
		name = "Witch Hat",
		rarity = "epic",
		event = "halloween",
		image = 71153577472960
	},
	{
		id = "acc_pumpkin",
		name = "Jack-o'-Lantern",
		rarity = "legendary",
		event = "halloween",
		image = 70668673590025,
		fx = 103636357095419
	},
	{ id = "acc_vip", name = "VIP Top Hat", vip = true, image = 133734165442835 }
} do
	add("accessory", v4)
end

for _, v4 in v3 do
	add("effect", v4)
end

Cosmetics.EVENT_CRATES = {
	{
		id = "halloween",
		event = "halloween",
		active = true,
		ends = 1793836800,
		name = "Halloween",
		one = "Halloween item",
		crate = "Halloween Crate",
		icon = "pumpkin",
		color = Color3.fromRGB(255, 128, 32)
	}
}

function Cosmetics.now()
	local success, result = pcall(function()
		return workspace:GetServerTimeNow()
	end)

	return success and result or os.time()
end

function Cosmetics.crateLive(data, p): boolean
	if not data then
		return false
	end

	if not data.event then
		return true
	end

	return data.active == true and (data.ends == nil or (p or Cosmetics.now()) < data.ends)
end

function Cosmetics.crateLeft(p, p2)
	if p and p.ends then
		return (math.max(0, p.ends - (p2 or Cosmetics.now())))
	end

	return nil
end

function Cosmetics.formatLeft(value)
	local v4 = math.floor(value or 0)
	local v5 = v4 // 86400
	local v6 = v4 % 86400 // 3600
	local v7 = v4 % 3600 // 60

	if v5 > 0 then
		return string.format("%dd %dh", v5, v6)
	end

	if v6 > 0 then
		return string.format("%dh %dm", v6, v7)
	end

	if v7 > 0 then
		return string.format("%dm", v7)
	end

	return "<1m"
end

Cosmetics.CRATES = {}
Cosmetics.CRATE_BY_ID = {}

for _, v4 in Cosmetics.EVENT_CRATES do
	Cosmetics.CRATE_BY_ID[v4.id] = v4

	if Cosmetics.crateLive(v4) then
		table.insert(Cosmetics.CRATES, v4)
	end
end

for _, v4 in Cosmetics.TYPES do
	Cosmetics.CRATE_BY_ID[v4.id] = v4
	table.insert(Cosmetics.CRATES, v4)
end

function Cosmetics.crateOf(p)
	return p.event and Cosmetics.CRATE_BY_ID[p.event] or Cosmetics.TYPE[p.type]
end

Cosmetics.CRATE_POOL = {}

for _, v4 in Cosmetics.CRATE_BY_ID do
	local v5 = {}

	for _, v6 in Cosmetics.RARITIES do
		v5[v6.id] = {}
	end

	for _, v6 in Cosmetics.ITEMS do
		local v7

		if v4.event then
			v7 = v6.event == v4.event
		elseif v6.type == v4.id then
			v7 = v6.event == nil
		else
			v7 = false
		end

		if not v7 or (v6.free or v6.vip) or not v5[v6.rarity] then
			continue
		end

		table.insert(v5[v6.rarity], v6)
	end

	Cosmetics.CRATE_POOL[v4.id] = v5
end

function Cosmetics.odds(p)
	local v4 = Cosmetics.CRATE_POOL[p]
	local total = 0

	for _, v5 in Cosmetics.RARITIES do
		if #v4[v5.id] > 0 then
			total += v5.weight
		end
	end

	local result = {}

	for _, v5 in Cosmetics.RARITIES do
		result[v5.id] = #v4[v5.id] > 0 and total > 0 and v5.weight / total or 0
	end

	return result
end

Cosmetics.DAILY_PRICES = { common = 10, rare = 20, epic = 40, legendary = 80 }
Cosmetics.DAILY_SLOTS = { "common", "common", "rare", "rare", "epic", "legendary" }

function Cosmetics.dayOf(p)
	return (p - (Config.TASK_RESET_HOUR_UTC or 0) * 3600) // 86400
end

function Cosmetics.resetAt(p)
	return (p + 1) * 86400 + (Config.TASK_RESET_HOUR_UTC or 0) * 3600
end

local v4 = {}

function Cosmetics.dailyShop(p)
	if v4[p] then
		return v4[p]
	end

	local random = Random.new(p * 7919 + 1013)
	local idSet = {}
	local typeSet = {}
	local result = {}

	for _, v5 in Cosmetics.DAILY_SLOTS do
		local v6 = {}
		local v7 = {}

		for _, v8 in Cosmetics.ITEMS do
			if v8.free or v8.vip or v8.event or v8.rarity ~= v5 then
				continue
			end

			if idSet[v8.id] then
				continue
			end

			table.insert(v6, v8)

			if not typeSet[v8.type] then
				table.insert(v7, v8)
			end
		end

		v6 = #v7 > 0 and v7 or v6

		if not (#v6 > 0) then
			continue
		end

		local v8 = v6[random:NextInteger(1, #v6)]
		idSet[v8.id] = true
		typeSet[v8.type] = true
		table.insert(result, { id = v8.id, price = Cosmetics.DAILY_PRICES[v5] })
	end

	v4[p] = result
	return result
end

function Cosmetics.dailyPrice(p, p2)
	for _, v5 in Cosmetics.dailyShop(p) do
		if v5.id == p2 then
			return v5.price
		end
	end

	return nil
end

function Cosmetics.isFree(p): boolean
	local v5 = Cosmetics.BY_ID[p]
	return v5 ~= nil and v5.free == true
end

function Cosmetics.isVip(p): boolean
	local v5 = Cosmetics.BY_ID[p]
	return v5 ~= nil and v5.vip == true
end

return Cosmetics