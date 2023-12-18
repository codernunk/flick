extends Enemy

var last_pos: Vector2
var dir := 1


func _ready():
	super()
	last_pos = self.global_position


func _physics_process(delta: float) -> void:
	if not is_dead:
		if get_parent() is PathFollow2D:
			get_parent().progress += delta * move_speed
		if sign((self.global_position - last_pos).x) != dir:
			_flip()
			dir = -dir
		last_pos = self.global_position


func _flip():
	$Direction.scale.x = -$Direction.scale.x
