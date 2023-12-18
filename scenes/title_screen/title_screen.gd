extends Control

const MAIN_MENU_SCENE_PATH: String = "res://scenes/main_menu/main_menu.tscn"

func _ready() -> void:
	%Options.visible = false

func _process(delta: float) -> void:
	$Camera2D.position += Vector2(5,0)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"FadeIn":
			$AnimationPlayer.play("TouchToStart")
		"ShowOptions":
			%TouchToStart.visible = false

func _on_start_button_button_up() -> void:
	print($AnimationPlayer.current_animation)
	if not $AnimationPlayer.current_animation == "TouchToStart":
		return
	$AnimationPlayer.play("ShowOptions")
	%Options.visible = true


func _on_continue_button_button_up() -> void:
	Functions.load_screen_to_scene(MAIN_MENU_SCENE_PATH)
