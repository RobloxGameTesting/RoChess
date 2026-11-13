local CoachLines = {
	intro = {
		{
			id = "intro_1",
			voice = 0,
			text = "Let's go through your game together and see where it was won and lost."
		},
		{
			id = "intro_2",
			voice = 0,
			text = "Alright, let's take a look at how this one played out."
		},
		{ id = "intro_3", voice = 0, text = "Every game has something to teach us. Let's find it." }
	},
	book = {
		{ id = "book_1", voice = 0, text = "Straight out of the opening book. Good start." },
		{
			id = "book_2",
			voice = 0,
			text = "A well-known opening move. Players have trusted this for a long time."
		},
		{ id = "book_3", voice = 0, text = "Still following theory here. Nice and solid." }
	},
	brilliant = {
		{
			id = "brilliant_1",
			voice = 0,
			text = "Wow! Giving up material like that takes real vision. Excellent!"
		},
		{
			id = "brilliant_2",
			voice = 0,
			text = "A sacrifice that actually works. That's the kind of move people remember."
		},
		{ id = "brilliant_3", voice = 0, text = "Bold and correct. I love it." }
	},
	great = {
		{
			id = "great_1",
			voice = 0,
			text = "Every other move lets it slip. You found the only one that works."
		},
		{
			id = "great_2",
			voice = 0,
			text = "Under pressure and you still found it. That's a sharp move."
		},
		{
			id = "great_3",
			voice = 0,
			text = "The one move that holds everything together. Well spotted."
		}
	},
	best = {
		{ id = "best_1", voice = 0, text = "That's exactly what I would have played." },
		{ id = "best_2", voice = 0, text = "The strongest move in the position. Well found." },
		{ id = "best_3", voice = 0, text = "Perfect. You didn't give anything away there." },
		{ id = "best_4", voice = 0, text = "Spot on. Keep playing like this." }
	},
	excellent = {
		{ id = "excellent_1", voice = 0, text = "Very close to the top choice. Strong move." },
		{ id = "excellent_2", voice = 0, text = "A strong move. You kept things under control." },
		{
			id = "excellent_3",
			voice = 0,
			text = "Nicely done. Hardly any difference from the best move."
		}
	},
	good = {
		{
			id = "good_1",
			voice = 0,
			text = "A reasonable move, though there was something a bit sharper."
		},
		{
			id = "good_2",
			voice = 0,
			text = "That works fine. Not the most precise, but nothing wrong with it."
		},
		{
			id = "good_3",
			voice = 0,
			text = "Decent. You gave away a little, but the position is still okay."
		}
	},
	inaccuracy = {
		{
			id = "inaccuracy_1",
			voice = 0,
			text = "Hmm, not quite. There was a better plan available."
		},
		{
			id = "inaccuracy_2",
			voice = 0,
			text = "A small slip. It won't lose the game, but it makes things harder."
		},
		{ id = "inaccuracy_3", voice = 0, text = "This lets some of your advantage slip away." }
	},
	mistake = {
		{
			id = "mistake_1",
			voice = 0,
			text = "Ouch, that's a mistake. Your opponent can take over from here."
		},
		{
			id = "mistake_2",
			voice = 0,
			text = "This one hurts your position. Take a moment to see why."
		},
		{ id = "mistake_3", voice = 0, text = "Not the right idea here. Check what was better." }
	},
	miss = {
		{
			id = "miss_1",
			voice = 0,
			text = "Your opponent just slipped up, and you didn't punish it."
		},
		{
			id = "miss_2",
			voice = 0,
			text = "There was a chance to win material here. Don't let those go!"
		},
		{ id = "miss_3", voice = 0, text = "So close! The winning idea was right there." }
	},
	blunder = {
		{
			id = "blunder_1",
			voice = 0,
			text = "Oh no. That's a blunder, and it changes the whole game."
		},
		{
			id = "blunder_2",
			voice = 0,
			text = "Yikes! Always check what your opponent is threatening first."
		},
		{
			id = "blunder_3",
			voice = 0,
			text = "That gives a lot away. It happens to everyone, but let's learn from it."
		},
		{
			id = "blunder_4",
			voice = 0,
			text = "Big mistake. Before you move, ask: what can they do next?"
		}
	},
	checkmate = {
		{ id = "checkmate_1", voice = 0, text = "Checkmate! That's how you finish a game." },
		{ id = "checkmate_2", voice = 0, text = "And that's checkmate. Game over!" }
	},
	win = {
		{ id = "win_1", voice = 0, text = "Well played! You earned this win." },
		{
			id = "win_2",
			voice = 0,
			text = "A great result. Now let's make the next one even cleaner."
		}
	},
	loss = {
		{
			id = "loss_1",
			voice = 0,
			text = "Tough game. Look at the turning points and you'll come back stronger."
		},
		{ id = "loss_2", voice = 0, text = "Losses teach the most. You've got this next time." }
	},
	draw = {
		{ id = "draw_1", voice = 0, text = "A hard-fought draw. Neither side gave an inch." },
		{
			id = "draw_2",
			voice = 0,
			text = "Honours even. Let's see where either of you could have pushed for more."
		}
	}
}

function CoachLines.pick(p, value)
	local v = CoachLines[p]

	if type(v) == "table" and #v ~= 0 then
		return v[(value or 0) % #v + 1]
	end

	return nil
end

return CoachLines