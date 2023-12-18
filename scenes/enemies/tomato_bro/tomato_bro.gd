extends Enemy


func _ready():
	super()
	if move_speed < 0:
		$Direction.scale.x = -$Direction.scale.x


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity
		
	set_up_direction(Vector2.UP)
	set_floor_stop_on_slope_enabled(false)
	set_max_slides(4)
	set_floor_max_angle(deg_to_rad(80))
	move_and_slide()

	if not is_dead:
		if $Direction/RayCastWall.is_colliding() or not $Direction/RayCastFloor.is_colliding():
			velocity.x = -velocity.x
			$Direction.scale.x = -$Direction.scale.x
