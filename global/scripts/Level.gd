extends Node

signal bean_get(color: Constants.Colors, value: int)
signal spud_get(color: Constants.Colors)
signal powerup_get(type)
signal powerup_use(type)
signal level_complete()

var world: int = 1
var level: int = 1
var beans: Dictionary = {} : get = _get_beans
var spuds: Dictionary = {}
var powerups_start: Dictionary = {"super": 0, "sticky": 0, "fire": 0, "frosty": 0, "rocket": 0, "invincibility": 0}
var powerups_current: Dictionary = {"super": 0, "sticky": 0, "fire": 0, "frosty": 0, "rocket": 0, "invincibility": 0}
var time: float = 0
var falls: int = 0

func _init() -> void:
	for c in Constants.Colors.values():
		beans[c] = 100 # This gets reset when a level is selected anyway, so useful for debugging
		spuds[c] = false

func _process(delta):
	time += delta

func collect_bean(color: Constants.Colors, delta: int):
	beans[color] += delta
	bean_get.emit(color, beans[color])

func collect_spud(color: Constants.Colors):
	spuds[color] = true
	spud_get.emit(color)

func collect_powerup(type: int):
	powerups_current[Constants.POWERUPS[type]] += 1
	powerup_get.emit(type)

func use_powerup(type: int) -> bool:
	# Deduct from current first, then deduct from starting
	if powerups_current[Constants.POWERUPS[type]] > 0:
		powerups_current[Constants.POWERUPS[type]] -= 1
		powerup_use.emit(type)
		return true
	elif powerups_start[Constants.POWERUPS[type]] > 0:
		powerups_start[Constants.POWERUPS[type]] -= 1
		powerup_use.emit(type)
		return true
	return false

func get_powerup_uses(name: String):
	return powerups_start[name] + powerups_current[name]

func _get_beans():
	return beans

func get_total_beans() -> int:
	var total: int = 0
	for c in beans:
		total += beans[c]
	return total

## Reset the beans and spud parameters to the level selected
## TODO: Only start timer when level is loaded completely
func set_level(world: int, level: int):
	self.world = world
	self.level = level
	for c in Constants.Colors.values():
		beans[c] = 0
		spuds[c] = SavedData.world_data[world][level].spuds_collected[c]
	time = 0
	falls = 0
	set_process(true) # This may cause an issue with the timer starting before the level does

## Transfer the params to SavedData
func complete_level():
	set_process(false) # Stop the timer
	level_complete.emit()
	#SavedData.world_data[world][level].best_rank
