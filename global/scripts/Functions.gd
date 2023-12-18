extends Node

static func format_time(millis: float) -> String:
	var msec = fmod(millis, 1) * 100
	var seconds = fmod(millis, 60)
	var minutes = fmod(millis, 3600) / 60
	return "%02d:%02d.%03d" % [minutes, seconds, msec]

func load_screen_to_scene(scene: String, parameters: Dictionary = {}) -> void:
	var loading_screen = preload("res://scenes/loading_screen/loading_screen.tscn").instantiate()
	loading_screen.next_scene_path = scene
	loading_screen.parameters = parameters
	get_tree().get_root().add_child(loading_screen)
