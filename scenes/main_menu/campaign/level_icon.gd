extends Control

@export var level_idx: int = 1
var current_world: int = 1
var unlocked := false

func _ready():
	set_details()

func set_details():
	if not is_unlocked():
		%Name.text = "???"
		modulate = Color.BLACK
	else:
		%Name.text = "%s-%s" % [current_world, level_idx]

func is_unlocked():
	var level_data = Constants.WORLDS[current_world].levels[level_idx]
	return SavedData.spuds_total[level_data.required_spud_color] >= level_data.required_spuds


func _on_button_down() -> void:
	if is_unlocked():
		var tw = get_tree().create_tween()
		tw.tween_property($Sprite, "scale:x", 1.2, 0.1).set_trans(Tween.TRANS_QUART)
		tw.parallel().tween_property($Sprite, "scale:y", 0.8, 0.1).set_trans(Tween.TRANS_QUART)


func _on_button_up() -> void:
	if is_unlocked():
		var tw = get_tree().create_tween()
		tw.tween_property($Sprite, "scale:x", 1, 0.1).set_trans(Tween.TRANS_QUART)
		tw.parallel().tween_property($Sprite, "scale:y", 1, 0.1).set_trans(Tween.TRANS_QUART)

