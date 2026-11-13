local list = {
	{
		id = "basics",
		title = "The Basics",
		sub = "How the pieces move, check and checkmate",
		icon = "school",
		color = Color3.fromRGB(129, 182, 76),
		tutorial = true
	},
	{
		id = "rules",
		title = "Special Moves & Rules",
		sub = "Castling, en passant, promotion, draws",
		icon = "info",
		color = Color3.fromRGB(96, 165, 230),
		lessons = {
			{
				id = "castling",
				title = "Castling",
				sub = "Tuck your king away safely",
				piece = "wK",
				steps = {
					{
						info = true,
						fen = "4k3/8/8/8/8/8/PPPPPPPP/R3K2R w KQ - 0 1",
						text = "Castling moves your king two squares toward a rook, and the rook jumps over it. It's the only move where two pieces move.",
						arrows = { "e1g1", "h1f1" }
					},
					{
						fen = "4k3/8/8/8/8/8/PPPPPPPP/R3K2R w KQ - 0 1",
						text = "Castle on the short side. Move your king two squares to the right.",
						line = { "e1g1" },
						goal = "Castle kingside."
					},
					{
						fen = "4k3/8/8/8/8/8/PPPPPPPP/R3K2R w KQ - 0 1",
						text = "Now the long side. The king still moves two squares, this time to the left.",
						line = { "e1c1" },
						goal = "Castle queenside."
					},
					{
						fen = "5r1k/8/8/8/8/8/PPP3PP/R3K2R w KQ - 0 1",
						text = "You can't castle out of check, through check or into check, or once the king or that rook has moved.",
						line = { "e1c1" },
						goal = "The black rook covers f1. Castle the other way."
					}
				}
			},
			{
				id = "enpassant",
				title = "En Passant",
				sub = "The strangest pawn capture",
				piece = "wP",
				steps = {
					{
						fen = "4k3/3p4/8/4P3/8/8/8/4K3 b - - 0 1",
						text = "When an enemy pawn jumps two squares and lands right beside your pawn, you can take it as if it had moved one.",
						line = { "d7d5", "e5d6" },
						goal = "Take the pawn en passant."
					},
					{
						fen = "4k3/5p2/8/6P1/8/8/8/4K3 b - - 0 1",
						text = "You only get one chance: en passant has to be played straight away, or it's gone.",
						line = { "f7f5", "g5f6" },
						goal = "Take it en passant again."
					}
				}
			},
			{
				id = "promotion",
				title = "Promotion",
				sub = "Turn a pawn into a queen",
				piece = "wQ",
				steps = {
					{
						fen = "8/4P1k1/8/8/8/8/8/4K3 w - - 0 1",
						text = "A pawn that reaches the far side becomes a queen, rook, bishop or knight. Almost always pick the queen.",
						line = { "e7e8q" },
						goal = "Promote to a queen."
					},
					{
						fen = "8/2q1P3/5k2/8/8/8/8/4K3 w - - 0 1",
						text = "Sometimes a knight is better. Here a new knight attacks the king and the queen at once.",
						line = { "e7e8n", "f6e6", "e8c7" },
						goals = {
							[1] = "Promote to a knight, with check.",
							[3] = "Now take the queen."
						},
						wrong = { e7e8q = "A queen there gets taken. Try a knight!" }
					}
				},
				practice = {
					themes = { "promotion" },
					count = 3
				}
			},
			{
				id = "escape",
				title = "Getting Out of Check",
				sub = "Move, block or capture",
				piece = "wK",
				steps = {
					{
						fen = "4k3/8/8/8/8/8/8/4K2r w - - 0 1",
						text = "In check you must get out straight away. There are three ways: move the king, block, or capture the attacker.",
						line = { "e1e2" },
						any = true,
						goal = "Move your king out of check."
					},
					{
						fen = "4k3/8/8/8/8/8/4B3/r3K3 w - - 0 1",
						text = "Put a piece between your king and the attacker.",
						line = { "e2d1" },
						goal = "Block the check with your bishop."
					},
					{
						fen = "4k3/8/8/8/8/1N6/8/r3K3 w - - 0 1",
						text = "Best of all: take the piece that's giving check.",
						line = { "b3a1" },
						goal = "Capture the attacker."
					}
				}
			},
			{
				id = "draws",
				title = "Stalemate & Draws",
				sub = "Don't throw away a won game",
				piece = "bK",
				steps = {
					{
						info = true,
						fen = "k7/2Q5/8/8/8/8/8/7K b - - 0 1",
						text = "Black to move has no legal moves and isn't in check. That's stalemate: a draw, even though White is a queen up.",
						tints = {
							"a7",
							"b7",
							"b8",
							color = "red"
						}
					},
					{
						fen = "k7/8/1K6/8/8/8/8/2Q5 w - - 0 1",
						text = "When you're winning, leave the king a square to move to until you can checkmate.",
						line = { "c1c8" },
						mate = true,
						goal = "Checkmate, don't stalemate!",
						wrong = { c1c7 = "Stalemate! Black can't move. Find the checkmate." }
					},
					{
						info = true,
						fen = "8/8/3k4/8/8/4K3/8/8 w - - 0 1",
						text = "Other draws: the same position three times, 50 moves each with no capture or pawn move, or too little left to checkmate, like king against king."
					}
				}
			},
			{
				id = "values",
				title = "Piece Values",
				sub = "Which pieces are worth the most",
				piece = "wR",
				steps = {
					{
						info = true,
						fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
						text = "Pieces are worth points: pawn 1, knight 3, bishop 3, rook 5, queen 9. Trade when you get more than you give."
					},
					{
						fen = "4k3/8/1r3n2/8/3B4/8/8/4K3 w - - 0 1",
						text = "Your bishop can take a rook or a knight.",
						line = { "d4b6" },
						goal = "Take the more valuable piece.",
						wrong = { d4f6 = "A knight is worth 3, a rook 5. Take the rook." }
					}
				}
			}
		}
	},
	{
		id = "tactics",
		title = "Tactics",
		sub = "Forks, pins, skewers and more",
		icon = "swords",
		color = Color3.fromRGB(236, 120, 70),
		lessons = {
			{
				id = "fork",
				title = "Forks",
				sub = "Attack two pieces at once",
				piece = "wN",
				steps = {
					{
						fen = "r3k3/8/8/3N4/8/8/8/4K3 w - - 0 1",
						text = "A fork attacks two things at once. They can only save one. Knights are the best at it.",
						line = { "d5c7", "e8d7", "c7a8" },
						goals = { [1] = "Fork the king and the rook.", [3] = "Take the rook." }
					},
					{
						fen = "4k3/8/8/2n1b3/8/3P4/8/4K3 w - - 0 1",
						text = "Any piece can fork. Even a pawn.",
						line = { "d3d4", "e5f6", "d4c5" },
						goals = {
							[1] = "Fork both pieces with your pawn.",
							[3] = "Take the knight."
						}
					}
				},
				practice = {
					themes = { "fork" },
					count = 4
				}
			},
			{
				id = "pin",
				title = "Pins",
				sub = "Freeze a piece in place",
				piece = "wB",
				steps = {
					{
						fen = "7k/8/5q2/8/1B6/8/1P6/6K1 w - - 0 1",
						text = "A pin attacks a piece that can't move without exposing something bigger behind it. Behind this queen is the king.",
						line = { "b4c3", "f6c3", "b2c3" },
						goals = {
							[1] = "Pin the queen to the king.",
							[3] = "Take back. Queen for a bishop!"
						}
					},
					{
						fen = "4k3/8/2n5/1B6/3P4/8/8/4K3 w - - 0 1",
						text = "The knight is pinned to the king, so it can't run. Attack it again.",
						line = { "d4d5", "e8e7", "d5c6" },
						goals = {
							[1] = "Attack the pinned knight with your pawn.",
							[3] = "Take the knight."
						}
					}
				},
				practice = {
					themes = { "pin" },
					count = 4
				}
			},
			{
				id = "skewer",
				title = "Skewers",
				sub = "Attack through a piece",
				piece = "wR",
				steps = {
					{
						fen = "3q4/8/8/3k4/8/8/7K/R7 w - - 0 1",
						text = "A skewer is a pin in reverse: attack the big piece, and when it moves, take what's behind it.",
						line = { "a1d1", "d5e4", "d1d8" },
						goals = {
							[1] = "Check the king along the file.",
							[3] = "Take the queen behind it."
						}
					},
					{
						fen = "8/8/5r2/8/3k4/8/8/2B3K1 w - - 0 1",
						text = "Bishops skewer along diagonals. The king and rook are lined up.",
						line = { "c1b2", "d4d3", "b2f6" },
						goals = {
							[1] = "Check the king with your bishop.",
							[3] = "Take the rook behind it."
						}
					}
				},
				practice = {
					themes = { "skewer" },
					count = 4
				}
			},
			{
				id = "discovered",
				title = "Discovered Attacks",
				sub = "Move one piece, attack with another",
				piece = "wB",
				steps = {
					{
						fen = "4k3/8/8/8/q3B3/8/8/4R1K1 w - - 0 1",
						text = "Moving the bishop uncovers check from your rook. The bishop is free to attack something else at the same time.",
						lines = {
							{ "e4c2", "e8d7", "c2a4" },
							{ "e4c6", "e8d8", "c6a4" }
						},
						goals = {
							[1] = "Move the bishop to attack the queen.",
							[3] = "Take the queen."
						}
					}
				},
				practice = {
					themes = { "discoveredAttack" },
					count = 4
				}
			},
			{
				id = "hanging",
				title = "Free Pieces",
				sub = "Spot pieces nobody defends",
				piece = "wQ",
				steps = {
					{
						fen = "4k3/8/5p2/2n1n3/3Q4/8/8/4K3 w - - 0 1",
						text = "A piece nobody defends is 'hanging'. Before you capture, check what could take back.",
						line = { "d4c5" },
						goal = "Take the knight that isn't defended.",
						wrong = { d4e5 = "The pawn would take your queen!" }
					}
				},
				practice = {
					themes = { "hangingPiece" },
					count = 4
				}
			},
			{
				id = "deflection",
				title = "Deflection",
				sub = "Chase a defender away",
				piece = "wP",
				steps = {
					{
						fen = "5rk1/5ppp/5n2/8/4P3/3B3Q/5PPP/6K1 w - - 0 1",
						text = "The knight on f6 is the only piece guarding h7. Chase it away and h7 falls.",
						line = { "e4e5", "f6d5", "h3h7" },
						mate = true,
						goals = {
							[1] = "Attack the knight with your pawn.",
							[3] = "The knight left. Checkmate on h7!"
						},
						wrong = { h3h7 = "The knight still guards h7. Chase it away first." }
					}
				},
				practice = {
					themes = { "deflection" },
					count = 3
				}
			},
			{
				id = "doublecheck",
				title = "Double Check",
				sub = "Two checks at once",
				piece = "wN",
				steps = {
					{
						fen = "3qkb2/3p1p2/8/8/4N3/8/8/4R1K1 w - - 0 1",
						text = "Double check: two pieces check at once. Nothing can block or capture both, so the king must move.",
						line = { "e4d6" },
						mate = true,
						goal = "Move the knight to give double check. It's mate!"
					}
				},
				practice = {
					themes = { "doubleCheck" },
					count = 3
				}
			},
			{
				id = "tactics_test",
				title = "Tactics Test",
				sub = "Mixed puzzles: find the tactic",
				piece = "wN",
				steps = {
					{
						info = true,
						fen = "r3k3/8/8/3N4/8/8/8/4K3 w - - 0 1",
						text = "Time to put it together. Each puzzle has one of the tactics from this course. You won't be told which."
					}
				},
				practice = {
					themes = {
						"fork",
						"pin",
						"skewer",
						"discoveredAttack",
						"hangingPiece",
						"deflection"
					},
					count = 6
				}
			}
		}
	},
	{
		id = "mates",
		title = "Checkmate Patterns",
		sub = "The mates every player should know",
		icon = "crown",
		color = Color3.fromRGB(240, 190, 60),
		lessons = {
			{
				id = "backrank",
				title = "Back Rank Mate",
				sub = "Trapped behind its own pawns",
				piece = "wQ",
				steps = {
					{
						fen = "6k1/5ppp/8/8/8/8/8/1Q4K1 w - - 0 1",
						text = "A king stuck behind its own pawns can be mated on the back rank.",
						line = { "b1b8" },
						mate = true,
						goal = "Checkmate on the back rank."
					},
					{
						fen = "4r1k1/5ppp/8/8/8/8/4R3/4R1K1 w - - 0 1",
						text = "Here a black rook guards the back rank. But you have two rooks and Black has one.",
						line = { "e2e8" },
						mate = true,
						goal = "Take the rook. It's checkmate."
					}
				},
				practice = {
					themes = { "backRankMate" },
					count = 3
				}
			},
			{
				id = "smothered",
				title = "Smothered Mate",
				sub = "A knight against a boxed-in king",
				piece = "wN",
				steps = {
					{
						fen = "6rk/6pp/8/6N1/8/8/8/6K1 w - - 0 1",
						text = "When the king is boxed in by its own pieces, a single knight can checkmate it.",
						line = { "g5f7" },
						mate = true,
						goal = "Smother the king with your knight."
					},
					{
						fen = "r6k/6pp/8/3Q2N1/8/8/5PPP/6K1 w - - 0 1",
						text = "Philidor's Legacy, a famous combination: knight checks, a double check, then a queen sacrifice that boxes the king in.",
						line = { "g5f7", "h8g8", "f7h6", "g8h8", "d5g8", "a8g8", "h6f7" },
						mate = true,
						goals = {
							[1] = "Check with the knight.",
							[3] = "Double check from knight and queen!",
							[5] = "Sacrifice your queen on g8.",
							[7] = "Smothered mate!"
						}
					}
				},
				practice = {
					themes = { "smotheredMate" },
					count = 3
				}
			},
			{
				id = "ladder",
				title = "Ladder Mate",
				sub = "Two rooks take turns",
				piece = "wR",
				steps = {
					{
						fen = "4k3/8/8/8/8/8/R7/1R4K1 w - - 0 1",
						text = "Two rooks can mate on their own: one cuts the king off from a row, the other gives check.",
						lines = {
							{ "a2a7", "e8f8", "b1b8" },
							{ "b1b7", "e8f8", "a2a8" }
						},
						mate = true,
						goals = {
							[1] = "Cut the king off: put a rook on the 7th row.",
							[3] = "Checkmate with the other rook."
						}
					}
				},
				practice = {
					themes = { "mateIn1" },
					count = 3
				}
			},
			{
				id = "queenmate",
				title = "Queen Checkmate",
				sub = "King and queen vs king",
				piece = "wQ",
				steps = {
					{
						fen = "k7/8/1K6/8/8/8/8/7Q w - - 0 1",
						text = "With king and queen against a lone king: push it to the edge, bring your king close, then mate.",
						line = { "h1h8" },
						mate = true,
						goal = "Checkmate in one."
					},
					{
						fen = "7k/8/6K1/8/8/8/8/Q7 w - - 0 1",
						text = "Your king guards the squares in front of theirs. The queen does the rest.",
						line = { "a1a8" },
						mate = true,
						goal = "Checkmate in one."
					}
				}
			},
			{
				id = "rookmate",
				title = "Rook Checkmate",
				sub = "King and rook vs king",
				piece = "wR",
				steps = {
					{
						fen = "1k6/8/1K6/8/8/8/8/7R w - - 0 1",
						text = "A rook can mate too. Put the kings face to face, then check along the edge.",
						line = { "h1h8" },
						mate = true,
						goal = "Checkmate in one."
					}
				}
			},
			{
				id = "scholars",
				title = "Attacking f7",
				sub = "Scholar's Mate and friends",
				piece = "wB",
				steps = {
					{
						fen = "r1bqkb1r/pppp1ppp/2n2n2/4p2Q/2B1P3/8/PPPP1PPP/RNB1K1NR w KQkq - 4 4",
						text = "At the start only the king guards f7. Queen and bishop together can mate there. That's Scholar's Mate.",
						line = { "h5f7" },
						mate = true,
						goal = "Checkmate on f7."
					}
				},
				practice = {
					themes = { "mateIn1" },
					count = 3
				}
			},
			{
				id = "anastasia",
				title = "Anastasia's Mate",
				sub = "Knight and rook on the edge",
				piece = "wN",
				steps = {
					{
						fen = "7k/4N1pp/8/7Q/8/3R4/5PPP/6K1 w - - 0 1",
						text = "Anastasia's Mate: the knight on e7 covers the king's escape squares, and a rook mates on the edge.",
						line = { "h5h7", "h8h7", "d3h3" },
						mate = true,
						goals = {
							[1] = "Sacrifice your queen on h7!",
							[3] = "Checkmate with the rook."
						}
					}
				},
				practice = {
					themes = { "anastasiaMate" },
					count = 3
				}
			},
			{
				id = "arabian",
				title = "Arabian Mate",
				sub = "Rook and knight in the corner",
				piece = "wR",
				steps = {
					{
						fen = "7k/1R6/5N2/8/8/8/5PPP/6K1 w - - 0 1",
						text = "One of the oldest mates there is: the knight guards the rook and the last escape square.",
						line = { "b7h7" },
						mate = true,
						goal = "Checkmate with your rook.",
						wrong = { b7b8 = "The king escapes to g7. Try another square." }
					}
				},
				practice = {
					themes = { "arabianMate" },
					count = 3
				}
			},
			{
				id = "matein2",
				title = "Mate in 2",
				sub = "Look one move further",
				piece = "wK",
				steps = {
					{
						info = true,
						fen = "6rk/6pp/8/6N1/8/8/8/6K1 w - - 0 1",
						text = "Every puzzle here is a mate in 2. Look for checks first: they leave your opponent the fewest choices."
					}
				},
				practice = {
					themes = { "mateIn2" },
					count = 4
				}
			}
		}
	},
	{
		id = "openings",
		title = "Openings",
		sub = "Start every game well",
		icon = "bulb",
		color = Color3.fromRGB(176, 120, 230),
		lessons = {
			{
				id = "principles",
				title = "Opening Rules",
				sub = "Centre, develop, castle",
				piece = "wP",
				steps = {
					{
						fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
						text = "Rule 1: take the centre. Pawns on e4 and d4 grab space and let your pieces out.",
						lines = {
							{ "e2e4" },
							{ "d2d4" }
						},
						goal = "Push a centre pawn two squares."
					},
					{
						fen = "rnbqkbnr/pppp1ppp/8/4p3/4P3/8/PPPP1PPP/RNBQKBNR w KQkq - 0 2",
						text = "Rule 2: get your knights and bishops out early. Knights belong on f3 and c3.",
						lines = {
							{ "g1f3" },
							{ "b1c3" }
						},
						goal = "Develop a knight."
					},
					{
						fen = "r1bqk1nr/pppp1ppp/2n5/2b1p3/2B1P3/5N2/PPPP1PPP/RNBQK2R w KQkq - 4 4",
						text = "Rule 3: castle early to keep your king safe.",
						line = { "e1g1" },
						goal = "Castle."
					},
					{
						info = true,
						fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
						text = "Also: don't bring your queen out too early, and don't move the same piece twice without a reason."
					}
				}
			},
			{
				id = "italian",
				title = "Italian Game",
				sub = "A classic for White",
				piece = "wB",
				steps = {
					{
						fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
						text = "The Italian Game: quick development and a bishop aimed at f7.",
						line = { "e2e4", "e7e5", "g1f3", "b8c6", "f1c4", "f8c5" },
						goals = {
							[1] = "1. e4: take the centre.",
							[3] = "2. Nf3: attack the e5 pawn.",
							[5] = "3. Bc4: aim the bishop at f7."
						}
					},
					{
						fen = "r1bqk1nr/pppp1ppp/2n5/2b1p3/2B1P3/5N2/PPPP1PPP/RNBQK2R w KQkq - 4 4",
						text = "A common plan: prepare d4 with c3, then hit the centre.",
						line = { "c2c3", "g8f6", "d2d4" },
						goals = {
							[1] = "4. c3: get ready for d4.",
							[3] = "5. d4: strike in the centre."
						}
					}
				}
			},
			{
				id = "queensgambit",
				title = "Queen's Gambit",
				sub = "White's oldest weapon",
				piece = "wQ",
				steps = {
					{
						fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
						text = "The Queen's Gambit offers a side pawn to pull Black's d-pawn out of the centre.",
						line = { "d2d4", "d7d5", "c2c4", "e7e6", "b1c3", "g8f6" },
						goals = {
							[1] = "1. d4: take the centre.",
							[3] = "2. c4: offer the pawn.",
							[5] = "3. Nc3: develop and add pressure on d5."
						}
					},
					{
						info = true,
						fen = "rnbqkbnr/ppp1pppp/8/8/2pP4/8/PP2PPPP/RNBQKBNR w KQkq - 0 3",
						text = "If Black takes on c4 (the Queen's Gambit Accepted), you usually win the pawn back. It's not really a sacrifice."
					}
				}
			},
			{
				id = "london",
				title = "London System",
				sub = "One simple setup for White",
				piece = "wB",
				steps = {
					{
						fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
						text = "The London System: the same solid setup almost every game, so there's little to memorise.",
						line = {
							"d2d4",
							"d7d5",
							"c1f4",
							"g8f6",
							"e2e3",
							"e7e6",
							"g1f3",
							"c7c5",
							"c2c3",
							"b8c6"
						},
						goals = {
							[1] = "1. d4: take the centre.",
							[3] = "2. Bf4: the London bishop, out before e3 shuts it in.",
							[5] = "3. e3: back up d4 and free the other bishop.",
							[7] = "4. Nf3: develop.",
							[9] = "5. c3: a solid wall of pawns."
						}
					}
				}
			},
			{
				id = "sicilian",
				title = "Sicilian Defence",
				sub = "Black's fighting answer to e4",
				piece = "bP",
				steps = {
					{
						fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
						color = -1,
						text = "You're Black. The Sicilian is the most popular answer to 1. e4: fight for the centre from the side.",
						line = {
							"e2e4",
							"c7c5",
							"g1f3",
							"d7d6",
							"d2d4",
							"c5d4",
							"f3d4",
							"g8f6",
							"b1c3",
							"a7a6"
						},
						goals = {
							[2] = "1... c5: the Sicilian.",
							[4] = "2... d6: free your bishop.",
							[6] = "3... cxd4: trade a side pawn for a centre pawn.",
							[8] = "4... Nf6: develop and attack e4.",
							[10] = "5... a6: the Najdorf, a world champions' favourite."
						}
					}
				}
			},
			{
				id = "carokann",
				title = "Caro-Kann Defence",
				sub = "A rock-solid answer to e4",
				piece = "bP",
				steps = {
					{
						fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
						color = -1,
						text = "You're Black. The Caro-Kann prepares d5 with c6, so you fight for the centre without blocking in your bishop.",
						line = { "e2e4", "c7c6", "d2d4", "d7d5", "b1c3", "d5e4", "c3e4", "c8f5" },
						goals = {
							[2] = "1... c6: get ready for d5.",
							[4] = "2... d5: challenge the centre.",
							[6] = "3... dxe4: take the centre pawn.",
							[8] = "4... Bf5: develop the bishop with a hit on the knight."
						}
					}
				}
			},
			{
				id = "stopscholar",
				title = "Stopping Scholar's Mate",
				sub = "Don't fall for the 4-move mate",
				piece = "bN",
				steps = {
					{
						fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
						color = -1,
						text = "You're Black, and White is going for Scholar's Mate on f7. Here's how to shut it down.",
						line = { "e2e4", "e7e5", "d1h5", "b8c6", "f1c4", "g7g6", "h5f3", "g8f6" },
						goals = {
							[2] = "1... e5: meet the centre.",
							[4] = "2... Nc6: guard the e5 pawn.",
							[6] = "3... g6: kick the queen away from f7.",
							[8] = "4... Nf6: block the queen and develop."
						}
					}
				},
				practice = {
					themes = { "opening" },
					count = 3
				}
			}
		}
	},
	{
		id = "endgames",
		title = "Endgames",
		sub = "Turn an advantage into a win",
		icon = "flag",
		color = Color3.fromRGB(80, 190, 180),
		lessons = {
			{
				id = "passedpawn",
				title = "Passed Pawns",
				sub = "Race to the other side",
				piece = "wP",
				steps = {
					{
						info = true,
						fen = "8/8/8/P6k/8/8/8/K7 w - - 0 1",
						text = "The rule of the square: picture a square from the pawn to the far side. If their king can't get inside it, the pawn can't be caught.",
						tints = {
							"a5",
							"b5",
							"c5",
							"d5",
							"a6",
							"b6",
							"c6",
							"d6",
							"a7",
							"b7",
							"c7",
							"d7",
							"a8",
							"b8",
							"c8",
							"d8",
							color = "green"
						}
					},
					{
						fen = "8/8/8/P6k/8/8/8/K7 w - - 0 1",
						text = "A passed pawn has no enemy pawns in its way. Their king is outside the square, so just run.",
						line = { "a5a6", "h5g6", "a6a7", "g6f7", "a7a8q" },
						goals = {
							[1] = "Push your pawn.",
							[3] = "Keep going.",
							[5] = "Promote to a queen."
						}
					}
				},
				practice = {
					themes = { "advancedPawn" },
					count = 3
				}
			},
			{
				id = "kingpawn",
				title = "King and Pawn",
				sub = "Your king leads the way",
				piece = "wK",
				steps = {
					{
						fen = "4k3/8/4K3/4P3/8/8/8/8 w - - 0 1",
						text = "In the endgame the king is a fighter. Walk it beside your pawn so it can guard every square on the way.",
						line = {
							"e6d6",
							"e8d8",
							"e5e6",
							"d8e8",
							"e6e7",
							"e8f7",
							"d6d7",
							"f7f6",
							"e7e8q"
						},
						goals = {
							[1] = "Step your king to d6.",
							[3] = "Push the pawn.",
							[5] = "Push again. Your king guards it.",
							[7] = "Move your king off d6, guarding e8.",
							[9] = "Promote!"
						}
					}
				},
				practice = {
					themes = { "pawnEndgame" },
					count = 3
				}
			},
			{
				id = "opposition",
				title = "The Opposition",
				sub = "Make the other king give way",
				piece = "bK",
				steps = {
					{
						fen = "8/4k3/8/4K3/4P3/8/8/8 b - - 0 1",
						text = "Kings face to face with one square between: the side that has to move must give way. That's the opposition. Black has to move here.",
						line = {
							"e7d7",
							"e5f6",
							"d7d6",
							"e4e5",
							"d6d7",
							"f6f7",
							"d7d8",
							"e5e6",
							"d8c7",
							"e6e7",
							"c7d6",
							"e7e8q"
						},
						goals = {
							[2] = "Black gave way. Walk past to f6!",
							[4] = "Push with check.",
							[6] = "Step to f7 to guard e7 and e8.",
							[8] = "Push.",
							[10] = "Push.",
							[12] = "Promote!"
						}
					},
					{
						info = true,
						fen = "8/4k3/8/4K3/4P3/8/8/8 w - - 0 1",
						text = "Same position, but White to move: now Black has the opposition and it's a draw. One move can decide a king and pawn ending.",
						tints = {
							"e6",
							color = "blue"
						}
					}
				},
				practice = {
					themes = { "pawnEndgame" },
					count = 2
				}
			},
			{
				id = "rookending",
				title = "Rook Endings",
				sub = "The most common endgame",
				piece = "wR",
				steps = {
					{
						fen = "8/6k1/8/8/8/p7/6K1/7R w - - 0 1",
						text = "Rooks belong behind passed pawns, yours or theirs. From behind, the rook gets stronger as the pawn moves.",
						line = { "h1a1" },
						goal = "Put your rook behind the passed pawn."
					},
					{
						info = true,
						fen = "8/6k1/8/8/8/p7/6K1/R7 b - - 0 1",
						text = "And keep your rook active: a rook that attacks is worth far more than one stuck defending."
					}
				},
				practice = {
					themes = { "rookEndgame" },
					count = 3
				}
			}
		}
	}
}

local lesson2 = {}
local courseOf = {}

for _, v in list do
	if v.tutorial then
		lesson2[v.id] = { id = v.id, title = v.title }
		courseOf[v.id] = v
	else
		for _, lesson in v.lessons do
			assert(lesson2[lesson.id] == nil, "duplicate lesson id " .. lesson.id)
			lesson2[lesson.id] = lesson
			courseOf[lesson.id] = v
		end
	end
end

return {
	START = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
	list = list,
	lesson = lesson2,
	courseOf = courseOf
}