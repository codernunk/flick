extends Node2D
class_name FlickController

enum ActionType { NONE, JUMP, FLICK, ROLL, BOUNCE }

signal click(inside_radius)
signal drag(direction)
signal release(direction)

var click_radius: float
var last_click_pos: Vector2 = Vector2(-INF, -INF)
var action_type = ActionType.NONE
var alpha_tween: Tween

@onready var _flick_line: Line2D = $FlickLine
@onready var _click_radius_spr: Sprite2D = $ClickRadius
@onready var _player: Node = get_parent()
@onready var _flick_time: Timer = $Timer


func _ready():
	_flick_line.set_as_top_level(true)
	_click_radius_spr.scale = Vector2(1, 1) * SavedData.click_radius_size
	click_radius = _click_radius_spr.texture.get_width() / 2.0 * _click_radius_spr.scale.x


func _input(event: InputEvent) -> void:
	var mouse_offset = self.get_global_mouse_position() - self.global_position
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_click_radius_spr.visible = event.pressed
		if event.pressed:
			if mouse_offset.length() < click_radius:
				_tween_alpha(1, 0.05)
				_flick_time.start()
				last_click_pos = self.get_global_mouse_position()
				_flick_line.set_point_position(0, self.global_position)
				_flick_line.set_point_position(1, self.global_position)
				click.emit(true)
			else:
				last_click_pos = Vector2(-INF, -INF)
				click.emit(false)
		elif not event.pressed and not last_click_pos == Vector2(-INF, -INF):
			_release(mouse_offset)


func _physics_process(_delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and last_click_pos != Vector2(-INF, -INF):
		var mouse_offset = self.get_global_mouse_position() - self.global_position
		_flick_line.set_point_position(0, self.global_position)
		_flick_line.set_point_position(1, self.get_global_mouse_position())
		drag.emit(mouse_offset.normalized() if mouse_offset.length() >= click_radius else Vector2.ZERO)


func _release(direction: Vector2):
	_tween_alpha(0, 0.25)
	release.emit(direction.normalized() if direction.length() >= click_radius else Vector2.ZERO)


func _cancel_flick():
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and last_click_pos != Vector2(-INF, -INF):
		_tween_alpha(0, 1)
		last_click_pos = Vector2(-INF, -INF)


func _tween_alpha(value, duration):
	if alpha_tween:
		alpha_tween.kill()
	alpha_tween = get_tree().create_tween()
	alpha_tween.tween_property(_flick_line, "modulate:a", value, duration)


func set_action_type(type: int):
	if action_type == type:
		return
	action_type = type
	var col: Color = Color.WHITE
	var to_width = 40
	match type:
		ActionType.NONE:
			to_width = 10
		ActionType.JUMP:
			to_width = 40
		ActionType.FLICK:
			to_width = 40
			col = Color.YELLOW
		ActionType.ROLL:
			to_width = 40
			col = Color.GREEN
		ActionType.BOUNCE:
			to_width = 40
			col = Color.RED
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property(_flick_line, "modulate:r", col.r, 0.1)
	tween.tween_property(_flick_line, "modulate:g", col.g, 0.1)
	tween.tween_property(_flick_line, "modulate:b", col.b, 0.1)
	tween.tween_property(_flick_line, "width", to_width, 0.1)
