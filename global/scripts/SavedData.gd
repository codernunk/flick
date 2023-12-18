extends Node

signal beans_changed(color: Constants.Colors)

# Settings
## Controls the size of the safe zone for initiating both
var click_radius_size: float = 5  # range from 1 to 5
## How fast you drag to register a flick within the click radius
var speed_threshold: float = 10

## The player's bean total accumulated across total playtime
var beans: Dictionary = {
	Constants.Colors.GREEN: 0,
	Constants.Colors.YELLOW: 0,
	Constants.Colors.BLUE: 0,
	Constants.Colors.RED: 0,
	Constants.Colors.WHITE: 0,
	Constants.Colors.BLACK: 0
} : get = _get_beans
## Temporary powerup uses that the player can purchase in the Shop
var powerup_reserve: Dictionary = {
	Constants.Powerups.FANTASTIC: 0,
	Constants.Powerups.FIERY: 0,
	Constants.Powerups.FROSTY: 0,
	Constants.Powerups.STEELY: 0,
	Constants.Powerups.FEATHERY: 0,
	Constants.Powerups.ROCKET: 0,
}
## Not saved, but used for level unlock checks
var spuds_total: Dictionary = {
	Constants.Colors.GREEN: 0,
	Constants.Colors.YELLOW: 0,
	Constants.Colors.BLUE: 0,
	Constants.Colors.RED: 0,
	Constants.Colors.WHITE: 0,
	Constants.Colors.BLACK: 0
}
## Completion data of levels
var world_data: Dictionary = {}

func _init() -> void:
	for i in Constants.WORLDS:
		world_data[i] = {}
		for j in Constants.WORLDS[i].levels:
			world_data[i][j] = {
				"spuds_collected": {
					Constants.Colors.GREEN: false,
					Constants.Colors.YELLOW: false,
					Constants.Colors.BLUE: false,
					Constants.Colors.RED: false,
					Constants.Colors.WHITE: false,
					Constants.Colors.BLACK: false
				},
				"best_rank": null,
				"best_time": null,
				"best_beans": null,
				"best_falls": null,
			}

func set_beans(color: Constants.Colors, value: int):
	beans[color] = value
	beans_changed.emit(color)

## Sets the records from the level after it is completed. This will be called by the LevelStatusScreen
func set_level_records(rank: Constants.Ranks, time: float, beans: int, falls: int) -> void:
	world_data[Level.world][Level.level].best_rank = rank if not world_data[Level.world][Level.level].best_rank or rank < world_data[Level.world][Level.level].best_rank else world_data[Level.world][Level.level].best_rank
	world_data[Level.world][Level.level].best_time = time if not world_data[Level.world][Level.level].best_time or time < world_data[Level.world][Level.level].best_time else world_data[Level.world][Level.level].best_time
	world_data[Level.world][Level.level].best_beans = beans if not world_data[Level.world][Level.level].best_beans or beans > world_data[Level.world][Level.level].best_beans else world_data[Level.world][Level.level].best_beans
	world_data[Level.world][Level.level].best_falls = falls if not world_data[Level.world][Level.level].best_falls or falls < world_data[Level.world][Level.level].best_falls else world_data[Level.world][Level.level].best_falls
	world_data[Level.world][Level.level].spuds_collected = Level.spuds
	calc_total_spuds()

func calc_total_spuds():
	spuds_total = {
		Constants.Colors.GREEN: 0,
		Constants.Colors.YELLOW: 0,
		Constants.Colors.BLUE: 0,
		Constants.Colors.RED: 0,
		Constants.Colors.WHITE: 0,
		Constants.Colors.BLACK: 0
	}
	for w in Constants.WORLDS:
		for l in Constants.WORLDS[w].levels:
			for s in spuds_total:
				spuds_total[s] += int(world_data[w][l].spuds_collected[s])

func _get_beans():
	return beans
