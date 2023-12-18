extends Node

enum Colors { GREEN, YELLOW, BLUE, RED, WHITE, BLACK }
enum Powerups { FANTASTIC, FIERY, FROSTY, STEELY, FEATHERY, ROCKET }
enum Ranks { S, A, B, C, D }
const POWERUPS = ["super", "sticky", "fire", "frosty", "rocket", "invincibility"]

const WORLDS := {
	1: {
		"name": "Flick Fields",
		"levels": {
			1: {
				"name": "First Flicks",
				"required_spuds": 0,
				"required_spud_color": Colors.GREEN,
				"time_target": 90,
				"bean_target": 50,
				"falls_target": 3
			},
			2: {
				"name": "A Fantastic Flick",
				"required_spuds": 1,
				"required_spud_color": Colors.GREEN
			},
			3: {
				"name": "Tomato Bashing",
				"required_spuds": 2,
				"required_spud_color": Colors.GREEN
			},
			4: {
				"name": "Rolling Hills",
				"required_spuds": 3,
				"required_spud_color": Colors.GREEN
			},
			5: {
				"name": "Nightime Run",
				"required_spuds": 8,
				"required_spud_color": Colors.GREEN
			},
		}
	},
	2: {
		"name": "Drag Desert",
		"levels": {
			1: {
				"name": "A Spike in Temperature",
				"required_spuds": 2,
				"required_spud_color": Colors.YELLOW
			},
			2: {
				"name": "Quick Flick in Quicksand",
				"required_spuds": 3,
				"required_spud_color": Colors.YELLOW
			},
			3: {
				"name": "Flicking Through the Ruins",
				"required_spuds": 5,
				"required_spud_color": Colors.YELLOW
			},
			4: {
				"name": "Through Darkness",
				"required_spuds": 7,
				"required_spud_color": Colors.YELLOW
			},
			5: {
				"name": "Exiting the Desert",
				"required_spuds": 9,
				"required_spud_color": Colors.YELLOW
			},
		}
	},
	3: {
		"name": "Double-Tap Tropics",
		"levels": {
			1: {
				"name": "Flicking Swimmingly",
				"required_spuds": 2,
				"required_spud_color": Colors.BLUE
			},
			2: {
				"name": "Ropeswings and Flings",
				"required_spuds": 3,
				"required_spud_color": Colors.BLUE
			},
			3: {
				"name": "Melons and a Good Time",
				"required_spuds": 5,
				"required_spud_color": Colors.BLUE
			},
			4: {
				"name": "A Chilly Refreshment",
				"required_spuds": 7,
				"required_spud_color": Colors.BLUE
			},
			5: {
				"name": "End of the Beach Day",
				"required_spuds": 9,
				"required_spud_color": Colors.BLUE
			},
		}
	},
	4: {
		"name": "Floor-It Flows",
		"levels": {
			1: {
				"name": "First Flicks",
				"required_spuds": 10,
				"required_spud_color": Colors.RED
			},
			2: {
				"name": "First Flicks",
				"required_spuds": 11,
				"required_spud_color": Colors.RED
			},
			3: {
				"name": "First Flicks",
				"required_spuds": 12,
				"required_spud_color": Colors.RED
			},
			4: {
				"name": "First Flicks",
				"required_spuds": 13,
				"required_spud_color": Colors.RED
			},
			5: {
				"name": "First Flicks",
				"required_spuds": 15,
				"required_spud_color": Colors.RED
			},
		}
	},
	5: {
		"name": "Slippery Snowlands",
		"levels": {
			1: {
				"name": "First Flicks",
				"required_spuds": 10,
				"required_spud_color": Colors.WHITE
			},
			2: {
				"name": "First Flicks",
				"required_spuds": 11,
				"required_spud_color": Colors.WHITE
			},
			3: {
				"name": "First Flicks",
				"required_spuds": 12,
				"required_spud_color": Colors.WHITE
			},
			4: {
				"name": "First Flicks",
				"required_spuds": 13,
				"required_spud_color": Colors.WHITE
			},
			5: {
				"name": "First Flicks",
				"required_spuds": 15,
				"required_spud_color": Colors.WHITE
			},
		}
	},
	6: {
		"name": "Cracked Castle",
		"levels": {
			1: {
				"name": "First Flicks",
				"required_spuds": 25,
				"required_spud_color": Colors.BLACK
			},
			2: {
				"name": "First Flicks",
				"required_spuds": 26,
				"required_spud_color": Colors.BLACK
			},
			3: {
				"name": "First Flicks",
				"required_spuds": 27,
				"required_spud_color": Colors.BLACK
			},
			4: {
				"name": "First Flicks",
				"required_spuds": 28,
				"required_spud_color": Colors.BLACK
			},
			5: {
				"name": "First Flicks",
				"required_spuds": 29,
				"required_spud_color": Colors.BLACK
			},
		}
	},
}
