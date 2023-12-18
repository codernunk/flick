extends HBoxContainer
class_name MoveController

var is_left_down: bool = false
var is_right_down: bool = false

func _ready() -> void:
	$LeftButton.modulate = Color(1, 1, 1, 0)
	$RightButton.modulate = Color(1, 1, 1, 0)

func _on_LeftButton_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			is_left_down = true
			get_tree().create_tween().tween_property($LeftButton, "modulate:a", 1, 1).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		else:
			is_left_down = false
			get_tree().create_tween().tween_property($LeftButton, "modulate:a", 0, 1).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)

func _on_RightButton_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			is_right_down = true
			get_tree().create_tween().tween_property($RightButton, "modulate:a", 1, 1).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		else:
			is_right_down = false
			get_tree().create_tween().tween_property($RightButton, "modulate:a", 0, 1).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)

func _on_LeftButton_mouse_exited() -> void:
	if is_left_down:
		is_left_down = false
		get_tree().create_tween().tween_property($LeftButton, "modulate:a", 0, 1).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)

func _on_RightButton_mouse_exited() -> void:
	if is_right_down:
		is_right_down = false
		get_tree().create_tween().tween_property($RightButton, "modulate:a", 0, 1).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
