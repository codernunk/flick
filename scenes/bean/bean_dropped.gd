extends CharacterBody2D

@export var color: Constants.Colors = Constants.Colors.GREEN
@export var gravity: float = 20
@export var friction: float = 0.01
@export var homing: bool = true
@onready var target_player: Node = get_tree().get_nodes_in_group("player").front()
@onready var particles := %CollectParticles

func setup(pos: Vector2, col: Constants.Colors, vel: Vector2, inactive_time: float = 1, hom: bool = false):
	await self.ready
	self.global_position = pos
	self.velocity = vel
	self.homing = hom
	match color:
		Constants.Colors.GREEN:
			particles.color = Color.GREEN
		Constants.Colors.YELLOW:
			particles.color = Color.YELLOW
		Constants.Colors.BLUE:
			particles.color = Color.BLUE
		Constants.Colors.RED:
			particles.color = Color.RED
		Constants.Colors.WHITE:
			particles.color = Color.WHITE_SMOKE
		Constants.Colors.BLACK:
			particles.color = Color.SLATE_GRAY
	$Sprite2D.frame = col
	$AnimationTree.set("parameters/spawn/seek_position", 0)
	$Timer.start(inactive_time)


func _physics_process(_delta):
	if $PickupBox.monitoring and homing:
		self.global_position = lerp(self.global_position, target_player.global_position, 0.2)
	else:
		velocity.y += gravity
		set_velocity(velocity)
		set_up_direction(Vector2.UP)
		move_and_slide()
		velocity = velocity
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			if collision.get_collider().is_in_group("land"):
				if is_on_floor():
					velocity.x = lerp(velocity.x, 0.0, friction)


func _on_Timer_timeout():
	$PickupBox.monitoring = true
	$AnimationTree.set("parameters/inactive/add_amount", 0)


func _on_PickupBox_body_entered(_body):
	$Sprite2D.visible = false
	Level.collect_bean(color, 1)
	particles.emitting = true
	await get_tree().create_timer(particles.lifetime).timeout
	queue_free()
