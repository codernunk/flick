extends Area2D

@export var spring_power:float = 1200
@export var spring_power_strong: float = 1500

func _on_Spring_body_entered(body: Node) -> void:
	if body is Player:
		body.spring(spring_power_strong if body.state == Player.STATES.BOUNCE else spring_power, PI/2.0)
		$AnimationPlayer.play("Spring")
		$SpringSound.play()
