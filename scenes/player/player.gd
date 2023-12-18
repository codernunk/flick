class_name Player
extends CharacterBody2D

signal powerup_expired(type)

enum STATES { GROUND, AIRBORNE, JUMPING, FLICKING, ROLLING, BOUNCE, HOVERING, SLIDING, DYING, LEVEL_FINISHING, LEVEL_FINISHED }

const FLICK_TRAIL_SCENE := preload("res://scenes/player/flick_trail/flick_trail.tscn")
const LEVEL_COMPLETE_BANNER_SCENE := preload("res://scenes/level_status_screen/level_complete_banner.tscn")

@export var acceleration_walk: float = 30
@export var acceleration_air: float = 10
@export var deceleration_ground: float = 8
@export var deceleration_slide: float = 4
@export var deceleration_air: float = 1
@export var max_walk_speed: float = 500
@export var jump_strength: float = 750
@export var flick_strength: float = 1000
@export var bounce_strength: float = 1100
@export var gravity: float = 20
@export var max_fall_speed_base: float = 2000
@export var max_fall_speed_hover: float = 100
@export var max_flicks: int = 1
@export var roll_duration: float = 1
@export var min_slide_angle: float = 40
@export var max_slide_speed: float = 1400
@export var super_flick_strength: float = 2000

var state = STATES.GROUND
var num_flicks: int = 0
var slide_dir: int = 1
var start_position: Vector2
var active_powerup: int = -1
var powerup_uses: int = 0
var max_fall_speed: float = max_fall_speed_base

var _current_trail: FlickTrail
@onready var _sprite: Sprite2D = $Sprite2D
@onready var _flick_controller: FlickController = $FlickController
@onready var _move_controller: MoveController = $CanvasLayer/MoveController
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _anim_tree: AnimationTree = %AnimationTree
@onready var _state_machine: AnimationNodeStateMachinePlayback = _anim_tree["parameters/StateMachine/playback"]

## Events
## #################
func _ready() -> void:
	start_position = self.global_position
	Level.powerup_use.connect(_set_powerup)
	Level.level_complete.connect(exit)
	_flick_controller.click.connect(_on_click)
	_flick_controller.drag.connect(_on_drag)
	_flick_controller.release.connect(_on_release)

func _on_click(inside_radius: bool):
	pass

# Change the color of the flick line
func _on_drag(direction):
	if num_flicks < max_flicks and direction.length() > 0:
		if direction.y > 0 and abs(direction.x) < 0.5:
			_flick_controller.set_action_type(FlickController.ActionType.BOUNCE)
		elif direction.y > 0 and is_on_floor():
			_flick_controller.set_action_type(FlickController.ActionType.ROLL)
		else:
			_flick_controller.set_action_type(FlickController.ActionType.FLICK)
	else:
		_flick_controller.set_action_type(FlickController.ActionType.NONE)

func _on_release(direction: Vector2):
	if num_flicks < max_flicks and direction.length() > 0:
		var strength = super_flick_strength if active_powerup == 0 else flick_strength
		velocity.x = cos(direction.angle()) * strength
		velocity.y = sin(direction.angle()) * strength
		if direction.y > 0 and abs(direction.x) < 0.5:
			_set_state(STATES.BOUNCE)
		elif direction.y > 0 and is_on_floor():
			_set_state(STATES.ROLLING)
		else:
			_set_state(STATES.FLICKING)
#			$Camera2D.woosh(50, direction, 0.5)
#			$Sprite2D.rotation = direction.angle()
#			var tween = get_tree().create_tween()
#			tween.tween_property($Sprite2D, "scale", Vector2(3.0, 0.5), 0.1).set_trans(Tween.TRANS_BOUNCE)
#			tween.tween_property($Sprite2D, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BOUNCE)
#			tween.parallel().tween_property($Sprite2D, "rotation", 0.0, 0.2)
	else:
		if num_flicks >= max_flicks and direction.y > 0:
			velocity.x /= 4  #
		if is_on_floor() or state == STATES.ROLLING:
			_set_state(STATES.JUMPING)
		elif num_flicks == 0:
			_set_state(STATES.HOVERING if state != STATES.HOVERING else STATES.AIRBORNE)

func _physics_process(_delta: float) -> void:
	if state == STATES.LEVEL_FINISHED:
		_accelerate(1)

	if not state in [STATES.SLIDING, STATES.ROLLING, STATES.BOUNCE, STATES.LEVEL_FINISHING, STATES.LEVEL_FINISHED]:
		if Input.is_action_pressed("left") or _move_controller.is_left_down:
			_accelerate(-1)
		elif Input.is_action_pressed("right") or _move_controller.is_right_down:
			_accelerate(1)
	_decelerate()

	if Input.is_action_just_pressed("jump") and (is_on_floor() or state == STATES.ROLLING):
		_set_state(STATES.JUMPING)

	if not is_on_floor():
		velocity.y = min(velocity.y  + gravity, max_fall_speed)

	set_velocity(velocity)
	move_and_slide()
	for i in get_slide_collision_count(): collide(get_slide_collision(i))

	# For some reason, the CharacterBody2D does not trigger the slide collision if going down a steep slope
	# (probably because you're not actually colliding with it before you have the floor_snap_length accounted for).
	# To better detect steep slopes, I have a specific RayCast2d that'll detect the slope, calculate the angle of the slope,
	# and trigger the sliding state if it's steep enough.
	if not is_on_wall() and is_on_floor() and _is_on_steep_slope() and not state in [STATES.BOUNCE]:
		_set_state(STATES.SLIDING)

	if state == STATES.SLIDING:
		if %SlopeRaycast.is_colliding():
#			if sign(%SlopeRaycast.get_collision_normal().x) == sign(velocity.x):
			_accelerate(%SlopeRaycast.get_collision_normal().x)
		elif is_on_floor():
			# The CharacterBody2D controller doesn't seem to support flying off slopes the way I would like, so I'll force the Y velocity to launch the player off an upward slope
			# This works because the raycast keeps the last ground normal it checked before it stopped colliding
			# Recalculating the floor angle because the one the CharacterBody2D gives is not based on the RayCast2D
			var floor_angle = %SlopeRaycast.get_collision_normal().angle() + PI/2
			velocity.y = velocity.length() * sin(floor_angle)
			velocity.x = velocity.length() * cos(floor_angle)
			_set_state(STATES.ROLLING)

	if global_transform.origin.y > 10:
		_set_state(STATES.DYING)

	%DashParticles.emitting = abs(velocity.x) > _get_max_x_speed() * 0.9 and is_on_floor()
	_sprite.flip_h = velocity.x < 0 if sign(velocity.x) != 0 else _sprite.flip_h
	$Flip.scale.x = _sprite.scale.x
	_anim_tree["parameters/StateMachine/IdleWalk/blend_position"] = abs(velocity.x) > 0

## Private functions
## #################
func _get_max_x_speed():
	return max_slide_speed if state == STATES.SLIDING else max_walk_speed

func _accelerate(factor: float) -> void:
	var accel_x = acceleration_walk if is_on_floor() else acceleration_air
	velocity.x = move_toward(velocity.x, _get_max_x_speed() * sign(factor), accel_x * abs(factor))

func _decelerate() -> void:
	var decel = deceleration_slide if state in [STATES.ROLLING, STATES.SLIDING] else deceleration_ground if is_on_floor() else deceleration_air
	velocity.x = move_toward(velocity.x, 0, decel)

func _set_state(new_state):
	# Prevent state from changing if finished level
	if state == STATES.LEVEL_FINISHED:
		return
	if new_state == state and not state in [STATES.ROLLING]:
		return
	# On end of old state
	match state:
		STATES.GROUND:
			pass
		STATES.AIRBORNE:
			pass
		STATES.FLICKING:
			if _current_trail: _current_trail.stop()
			if active_powerup in [0]:
				powerup_uses -= 1
				if powerup_uses <= 0:
					_reset_powerup()
		STATES.HOVERING:
			max_fall_speed = max_fall_speed_base
			$HoverParticles.emitting = false
		STATES.ROLLING:
			if _current_trail: _current_trail.stop()
			$RollTimer.stop()
		STATES.SLIDING:
			if _current_trail: _current_trail.stop()
			floor_snap_length = 32
		STATES.BOUNCE:
			pass
		STATES.DYING:
			pass
	state = new_state
	print("Changed state to %.0d" % state)
	# On start of new state
	match new_state:
		STATES.GROUND:
			reset_flick()
			_state_machine.travel("IdleWalk")
		STATES.AIRBORNE:
			pass
		STATES.JUMPING:
			_state_machine.travel("Jump")
			$JumpSound.play()
			velocity.y = -jump_strength
			_set_state(STATES.AIRBORNE)
		STATES.FLICKING:
			_current_trail = FLICK_TRAIL_SCENE.instantiate()
			_current_trail.style = FlickTrail.Style.FLICK
			add_child(_current_trail)
			_state_machine.travel("Flick")
			$FlickSound.play()
			num_flicks += 1
			%FlickParticles.emitting = true
		STATES.HOVERING:
			max_fall_speed = max_fall_speed_hover
			$HoverParticles.emitting = true
		STATES.ROLLING:
			_current_trail = FLICK_TRAIL_SCENE.instantiate()
			_current_trail.style = FlickTrail.Style.ROLL
			add_child(_current_trail)
			_state_machine.travel("Flick")
			$RollTimer.wait_time = roll_duration
			$RollTimer.start()
		STATES.SLIDING:
			_current_trail = FLICK_TRAIL_SCENE.instantiate()
			_current_trail.style = FlickTrail.Style.ROLL
			add_child(_current_trail)
			_state_machine.travel("Flick")
			slide_dir = int(sign(get_floor_normal().x))
		STATES.BOUNCE:
			_state_machine.travel("BounceStart")
#			_current_trail = FLICK_TRAIL_SCENE.instantiate()
#			_current_trail.style = FlickTrail.Style.BOUNCE
#			add_child(_current_trail)
			velocity.x = 0
			velocity.y = 0
		STATES.DYING:
			Level.falls += 1
			self.global_position = start_position
			velocity = Vector2.ZERO
			state = STATES.GROUND
			num_flicks = 0
			slide_dir = 1
		STATES.LEVEL_FINISHING:
			# The idea here is that the player can reach the exit while being above it.
			# In that case, the player's X velocity should be set to zero until he lands on the ground,
			# in which the exit sequence would then play.
			# The exit sequence is a small dance followed by the player walking off the screen,
			# and then the results screen showing.
			# Of course, the player should not be controllable at this point.
			velocity.x = 0
			_flick_controller.queue_free()
			_move_controller.queue_free()
			# Stop collisions with everything but the ground
			set_collision_layer_value(1, false)
			# TODO: Fade away UI elements
		STATES.LEVEL_FINISHED:
			gravity = 0
			_state_machine.travel("IdleWalk")
			# Detach the camera to stop it from following the player
			var camera = $Camera2D
			remove_child(camera)
			camera.position = position
			get_parent().add_child(camera)
			await get_tree().create_timer(1).timeout
			# Create status window
			var level_complete_banner = LEVEL_COMPLETE_BANNER_SCENE.instantiate()
			get_parent().add_child(level_complete_banner)

func _set_powerup(type: int):
	print("Got powerup: %s" % Constants.POWERUPS[type])
	active_powerup = type
	powerup_uses = 3

func _reset_powerup():
	powerup_expired.emit()
	active_powerup = -1
	powerup_uses = 0


func _is_on_steep_slope():
	return abs( rad_to_deg((Vector2.UP).angle_to(%SlopeRaycast.get_collision_normal())) ) > min_slide_angle

func _set_bounce_velocity(is_going_down: bool):
	if !is_going_down:
		velocity = get_floor_normal() * bounce_strength
		reset_flick()
		_set_state(STATES.AIRBORNE)
	else:
		velocity = Vector2(0, max_fall_speed)

## Public functions
## #################
func reset_flick():
	num_flicks = 0

func exit():
	velocity.x = 0
	_set_state(STATES.LEVEL_FINISHING)

func spring(power: float, angle: float) -> void:
	velocity.x = velocity.x + cos(angle) * power
	velocity.y = -sin(angle) * power
	reset_flick()
	_state_machine.travel("Jump")
	_set_state(STATES.AIRBORNE)

func collide(collision: KinematicCollision2D) -> void:
	if collision.get_collider().is_in_group("land"):
		if state == STATES.LEVEL_FINISHING:
			_set_state(STATES.LEVEL_FINISHED)
		if is_on_wall() and state in [STATES.ROLLING, STATES.SLIDING]:
			_set_state(STATES.GROUND)
		elif is_on_floor():
			if state == STATES.BOUNCE:
				# When hitting the ground, the player will incur some hitstun before bouncing upwards. Hitting a spring or an enemy will cancel this.
				_state_machine.travel("BounceLand")
				# screen shake
				$Camera2D.shake(10, 0.1)
			elif (state == STATES.SLIDING and not _is_on_steep_slope() and abs(velocity.x) < 10.0) or not state in [STATES.ROLLING, STATES.SLIDING]:
				_set_state(STATES.GROUND)

func _on_Hurtbox_body_entered(body: Node) -> void:
	if body.is_in_group("enemy"):
		if num_flicks > 0 or (not is_on_floor() and Vector2.UP.dot(self.global_position - body.global_position) > 0.1):
			body.die()
			velocity.x *= 0.5
			velocity.y = -jump_strength
			reset_flick()
			_state_machine.travel("Jump")
			_set_state(STATES.AIRBORNE)
		elif state in [STATES.ROLLING, STATES.SLIDING]:
			body.die()
		else:
			_set_state(STATES.DYING)

func _on_RollTimer_timeout():
	_set_state(STATES.GROUND)
