extends Control

var world_select_tween: Tween
var level_select_tween: Tween

func _on_world_select_world_selected(world) -> void:
	$LevelSelect.position.y = -$LevelSelect.size.y
	$LevelSelect.set_world($WorldSelect.selected_world)
	$LevelSelect.visible = true
	world_select_tween = get_tree().create_tween()
	world_select_tween.tween_property($WorldSelect, "position:y", $WorldSelect.size.y, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	level_select_tween = get_tree().create_tween()
	level_select_tween.tween_property($LevelSelect, "position:y", 0, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC).set_delay(0.25)
	await world_select_tween.finished
	$WorldSelect.visible = false
	await level_select_tween.finished
	$LevelSelect.enabled = true

func _on_level_select_cancelled() -> void:
	$WorldSelect.position.y = $WorldSelect.size.y
	$WorldSelect.visible = true
	level_select_tween = get_tree().create_tween()
	level_select_tween.tween_property($LevelSelect, "position:y", -$LevelSelect.size.y, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	world_select_tween = get_tree().create_tween()
	world_select_tween.tween_property($WorldSelect, "position:y", 0, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC).set_delay(.25)
	await level_select_tween.finished
	$LevelSelect.visible = false
	await world_select_tween.finished
	$WorldSelect.enabled = true

func _on_level_select_level_selected(level) -> void:
	$ModalWindow.show_modal()

func _on_modal_window_cancelled() -> void:
	$LevelSelect.enabled = true

func _on_modal_window_confirmed() -> void:
	$ModalWindow.confirmed.disconnect(_on_modal_window_confirmed) # To prevent bugs with clicking the modal more than once
	# Load the selected level
	Level.set_level($WorldSelect.selected_world, $LevelSelect.selected_level)
	Functions.load_screen_to_scene("res://scenes/worlds/%s/%s_%s.tscn" % [$WorldSelect.selected_world, $WorldSelect.selected_world, $LevelSelect.selected_level])
