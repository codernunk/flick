extends Control

signal confirmed
signal cancelled

var details_tween: Tween

func show_modal() -> void:
	visible = true
	details_tween = get_tree().create_tween()
	details_tween.tween_property($Background, "modulate", $Background.modulate, 1).from(Color(0,0,0,0)).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	details_tween.parallel().tween_property(%Contents, "position:y", 0, 1).from(size.y).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	details_tween.parallel().tween_property(%Contents, "scale:y", 1, 1).from(2.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func _on_back_button_button_up() -> void:
	cancelled.emit()
	visible = false


func _on_flick_zone_gui_input(event: InputEvent) -> void:
	# TODO: Add a flick like input here. For now, just clicking it will work
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
		confirmed.emit()
