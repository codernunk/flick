extends Camera2D

func shake(amount: float, duration: float) -> void:
	var amp = func():
		return randf_range(-1.0, 1.0) * amount

	var tween = get_tree().create_tween()
	tween.tween_property(self, "offset", Vector2(amp.call(), amp.call()), duration / 3.0)
	tween.tween_property(self, "offset", Vector2(amp.call(), amp.call()), duration / 3.0)
	tween.tween_property(self, "offset", Vector2(0, 0), duration / 3.0)

func woosh(amount: float, direction: Vector2, duration: float) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "offset", direction.normalized() * amount, duration / 2.0)
	tween.tween_property(self, "offset", Vector2.ZERO, duration / 2.0)
