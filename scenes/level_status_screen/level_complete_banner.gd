extends CanvasLayer

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	# show status banner
	var level_status_screen = preload("res://scenes/level_status_screen/level_status_screen.tscn").instantiate()
	add_sibling(level_status_screen)
	queue_free()
