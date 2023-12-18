extends Node2D

const BEAN_DROP_SCENE := preload("res://scenes/bean/bean_dropped.tscn")

# Item Drop Params
@export var drop_color: Constants.Colors = Constants.Colors.GREEN
@export var drop_count: int = 3
@export var drop_velocity: float = 500
@export var drop_direction: float = 80
@export var drop_delta: float = 5
@export var drop_time: float = 1
@export var drop_homing: bool = true

func drop() -> void:
	for i in drop_count:
		var bean = BEAN_DROP_SCENE.instantiate()
		var dd = deg_to_rad(drop_direction - drop_delta + (drop_delta * 2 / drop_count) * i)
		var drop_dir = Vector2(cos(dd), -sin(dd)) * drop_velocity
		bean.setup(self.global_position, drop_color, drop_dir, drop_time, drop_homing)
		get_parent().get_parent().call_deferred("add_child", bean)
