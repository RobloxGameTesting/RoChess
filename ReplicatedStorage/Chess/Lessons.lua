return {
	{
		id = "rook",
		title = "The Rook",
		piece = "wR",
		text = "Moves in straight lines.",
		fen = "8/8/8/8/3R4/8/8/8 w - - 0 1",
		goal = "stars",
		stars = { "d7", "g7", "g2" }
	},
	{
		id = "bishop",
		title = "The Bishop",
		piece = "wB",
		text = "Moves diagonally.",
		fen = "8/8/8/8/8/8/8/2B5 w - - 0 1",
		goal = "stars",
		stars = { "f4", "d6", "b8" }
	},
	{
		id = "queen",
		title = "The Queen",
		piece = "wQ",
		text = "Moves straight or diagonally.",
		fen = "8/8/8/8/8/8/8/3Q4 w - - 0 1",
		goal = "stars",
		stars = { "d5", "g8", "a2" }
	},
	{
		id = "king",
		title = "The King",
		piece = "wK",
		text = "Moves one square in any direction.",
		fen = "8/8/8/8/8/8/8/4K3 w - - 0 1",
		goal = "stars",
		stars = { "d2", "d3", "e4" }
	},
	{
		id = "knight",
		title = "The Knight",
		piece = "wN",
		text = "Moves in an L shape. It can jump over pieces.",
		fen = "8/8/8/8/8/8/PPP5/1N6 w - - 0 1",
		goal = "stars",
		stars = { "c3", "d5", "f6" }
	},
	{
		id = "pawn",
		title = "The Pawn",
		piece = "wP",
		text = "Moves forward one square. Two on its first move.",
		fen = "8/8/8/8/8/8/4P3/8 w - - 0 1",
		goal = "stars",
		stars = { "e4", "e6" }
	},
	{
		id = "capture",
		title = "Capturing",
		piece = "wP",
		text = "Move onto a piece to take it. Pawns take diagonally.",
		fen = "8/8/8/8/4n3/3n4/2P5/8 w - - 0 1",
		goal = "capture",
		hint = "c2d3"
	},
	{
		id = "check",
		title = "Check",
		piece = "wR",
		text = "Attack the king. That's check.",
		fen = "4k3/8/8/8/8/8/8/R3K3 w - - 0 1",
		goal = "check",
		hint = "a1a8"
	},
	{
		id = "mate",
		title = "Checkmate",
		piece = "wR",
		text = "Attack the king so it can't escape. That's checkmate. You win!",
		fen = "6k1/5ppp/8/8/8/8/5PPP/R5K1 w - - 0 1",
		goal = "mate",
		hint = "a1a8"
	}
}