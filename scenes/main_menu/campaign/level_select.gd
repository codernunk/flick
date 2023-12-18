extends Control

signal level_selected(level: int)
signal cancelled

const color_spud_collected := Color.WHITE
const color_spud_missed := Color(1, 1, 1, 0.2)

var enabled := true
var player_position_tween: Tween
var details_tween: Tween
var current_world: int = 1 # Passed from the Campaign menu controller
var selected_level: int = 1 # Selected by this controller

@onready var level_icons := [$LevelIcon1, $LevelIcon2, $LevelIcon3, $LevelIcon4, $LevelIcon5]

func _ready() -> void:
	for i in level_icons.size():
		level_icons[i].button_up.connect(_on_level_select.bind(i+1, level_icons[i]))
	set_world(current_world)
	_set_details(0, selected_level)

func _on_level_select(level: int, node: Button) -> void:
	if not enabled or not node.is_unlocked():
		return
	if player_position_tween and player_position_tween.is_running():
		return
	if details_tween and details_tween.is_running():
		return
	if level == selected_level:
		enabled = false
		level_selected.emit(level)
		return

	var root_position = $Details.position.x
	var distance: int = abs(level-selected_level)
	var step: int = sign(level - selected_level)

	$PlayerIcon/AnimationPlayer.play("Walk")
	$PlayerIcon.flip_h = step < 0

	# Animate the details panel with an out-to-in animation, adding some squash and stretch
	details_tween = get_tree().create_tween()
	details_tween.tween_property($Details, "scale:x", 0.5, 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	details_tween.tween_property($Details, "scale:x", 1.5, 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	details_tween.parallel().tween_property($Details, "position:x", root_position + $Details.size.x, 0.5).from(root_position).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO).set_delay(0.25)

	details_tween.tween_property($Details, "position:x", root_position , 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
	details_tween.parallel().tween_property($Details, "scale:x", 0.5, 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_delay(0.25)
	details_tween.tween_property($Details, "scale:x", 1, 0.25).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	details_tween.step_finished.connect(_set_details.bind(level))

	# We will have the player icon traverse the levels in order, so if you click a level more than 1 further away, the player will walk to each tile in between
	player_position_tween = get_tree().create_tween()
	for i in range(selected_level+step-1, level+step-1, step):
		player_position_tween.tween_property($PlayerIcon, "position", level_icons[i].position + level_icons[i].pivot_offset, 2.0/distance).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

	# Wait for both tweens to finish just in case one finishes before the other
	await player_position_tween.finished
	selected_level = level
	$PlayerIcon/AnimationPlayer.play("Idle")

func set_world(world: int):
	current_world = world
	$PlayerIcon.position = $LevelIcon1.position + $LevelIcon1.pivot_offset
	$PlayerIcon/AnimationPlayer.play("Idle")
	$PlayerIcon.flip_h = false
	for i in level_icons.size():
		level_icons[i].set_details()

func _set_details(_idx, level: int):
	var name = Constants.WORLDS[1].levels[level].name
	%LevelTitle.text = "Level %s: %s" % [level, name]
	%BestRank.text = "Rank: %s" % Constants.Ranks.keys()[SavedData.world_data[current_world][level].best_rank] if not SavedData.world_data[current_world][level].best_rank == null else "-"
	%BestTime.text = "Best Time: %s" % Functions.format_time(SavedData.world_data[current_world][level].best_time) if SavedData.world_data[current_world][level].best_time else "-"
	%MostBeans.text = "Most Beans: %s" % SavedData.world_data[current_world][level].best_beans if SavedData.world_data[current_world][level].best_beans else "-"
	for c in SavedData.world_data[current_world][level].spuds_collected:
		%Spuds.get_node(Constants.Colors.keys()[c].to_lower()).modulate = color_spud_collected if SavedData.world_data[current_world][level].spuds_collected[c] else color_spud_missed

func _on_back_button_button_up() -> void:
	cancelled.emit()
	enabled = false
