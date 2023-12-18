extends Control

signal world_selected(world: int)

const color_spud_collected := Color.WHITE
const color_spud_missed := Color(1, 1, 1, 0.2)

var player_position_tween: Tween
var details_tween: Tween
var selected_world: int = 1
var enabled := true

@onready var world_icons := [%WorldIcon1, %WorldIcon2, %WorldIcon3, %WorldIcon4, %WorldIcon5, %WorldIcon6]

func _ready() -> void:
	for i in world_icons.size():
		world_icons[i].button_up.connect(_on_world_select.bind(i+1, world_icons[i]))
	$PlayerIcon.position = $WorldIcon1.position + $WorldIcon1.pivot_offset
	_set_details(0, selected_world)

func _on_world_select(world: int, node: Node) -> void:
	if not enabled or not node.is_unlocked():
		return
	if player_position_tween and player_position_tween.is_running():
		return
	if details_tween and details_tween.is_running():
		return
	if world == selected_world:
		# Give control to the level select
		enabled = false
		world_selected.emit(world)
		return
	var root_position = $Details.position.x
	details_tween = get_tree().create_tween()
	details_tween.tween_property($Details, "position:x", root_position + $Details.size.x, 1).from(root_position).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
	details_tween.step_finished.connect(_set_details.bind(world))
	details_tween.tween_property($Details, "position:x", root_position , 1).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
	player_position_tween = get_tree().create_tween()
	player_position_tween.tween_property($PlayerIcon, "position", node.position + node.pivot_offset, 1).set_trans(Tween.TRANS_CUBIC)
	# Wait for the tweens to finish before letting the player select a different world
	await details_tween.finished
	selected_world = world

func _set_details(_idx, world: int):
	%WorldTitle.text = "World %s: %s" % [world, Constants.WORLDS[world].name]
	for l in Constants.WORLDS[world].levels:
		for c in SavedData.world_data[world][l].spuds_collected:
			var node := %VBoxContainer.get_node("Level%s" % l)
			node.get_node("Rank").text = Constants.Ranks.keys()[SavedData.world_data[world][l].best_rank] if not SavedData.world_data[world][l].best_rank == null else "-"
			node.get_node(Constants.Colors.keys()[c].to_lower()).modulate = color_spud_collected if SavedData.world_data[world][l].spuds_collected[c] else color_spud_missed
