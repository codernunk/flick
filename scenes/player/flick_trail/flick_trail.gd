class_name FlickTrail
extends Line2D

enum Style { FLICK, ROLL, BOUNCE }

var gradients := [
	preload("res://scenes/player/flick_trail/trail_gradient_flick.tres"),
	preload("res://scenes/player/flick_trail/trail_gradient_roll.tres"),
	preload("res://scenes/player/flick_trail/trail_gradient_bounce.tres")
]
var line_widths := [
	48,
	24,
	96
]
## Limits the number of points that are drawn on the curve.
@export var max_points: int = 2000
## Adjusts the style of the curve based on the action
@export var style: Style = Style.FLICK:
	set(v):
		style = v
		gradient = gradients[v]
		width = line_widths[v]
@onready var curve := Curve2D.new()

func _process(delta: float) -> void:
	# Add points to the curve, and then update the trail line
	curve.add_point(get_parent().position)
	if curve.get_baked_points().size() > max_points:
		curve.remove_point(0)
	points = curve.get_baked_points()

func stop() -> void:
	set_process(false)
	var t = get_tree().create_tween()
	t.tween_property(self, "modulate:a", 0.0, 3.0)
	await t.finished
	queue_free()
