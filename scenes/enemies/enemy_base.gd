class_name Enemy
extends CharacterBody2D

@export var move_speed: float = -100
@export var gravity: float = 20

@onready var _animation_tree: AnimationTree = $AnimationTree
var is_dead: bool = false


func _ready() -> void:
	velocity = Vector2(move_speed, 0)


func die() -> void:
	is_dead = true
	$CollisionPolygon2D.set_deferred("disabled", true)
	set_process(false)
	set_physics_process(false)
	%HitParticles.emitting = true
	$BeanDropper.drop()
	_animation_tree["parameters/state/transition_request"] = "die"
