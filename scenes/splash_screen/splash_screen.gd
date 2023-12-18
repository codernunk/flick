extends Control

const TITLE_SCREEN_SCENE_PATH = "res://scenes/title_screen/title_screen.tscn"

@onready var logos_to_cycle := [$NunkwareDigitalLogo, $GodotLogo]

func _ready() -> void:
	for l in logos_to_cycle:
		l.visible = false
	logos_to_cycle[0].visible = true

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	var last_logo = logos_to_cycle.pop_front()
	if not logos_to_cycle.size():
		# Open the title screen
		get_tree().change_scene_to_file(TITLE_SCREEN_SCENE_PATH)
		return
	# Otherwise, keep showing logos
	last_logo.visible = false
	logos_to_cycle[0].visible = true
	$AnimationPlayer.play("Fade")

## Adds the ability to skip through the sequence by tapping/clicking the screen
func _on_dark_layer_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
		var last_logo = logos_to_cycle.pop_front()
		if not logos_to_cycle.size():
			$AnimationPlayer.play("FadeOut")
			return
		# Otherwise, keep showing logos
		last_logo.visible = false
		logos_to_cycle[0].visible = true
		$AnimationPlayer.stop()
		$AnimationPlayer.play("Fade")
