@tool
class_name Bean
extends Area2D

@export var color: Constants.Colors = Constants.Colors.GREEN
@onready var particles := %CollectParticles

func _ready():
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
	if not Engine.is_editor_hint():
		$Sprite2D.frame = color


func _process(_delta):
	if Engine.is_editor_hint():
		$Sprite2D.frame = color


func _on_body_entered(_body: Player):
#	var camera_pos: Vector2 = Vector2i(body.get_node("Camera2D").get_screen_center_position()) - get_viewport().size / 2
	set_deferred("monitoring", false)
	particles.emitting = true
	$Sprite2D.visible = false
	Level.collect_bean(color, 1)
#	var anima := Anima.begin(self)
#	anima.then({node = $Sprite2D, property = "position", to = camera_pos, easing = AnimaEasing.EASING.EASE_IN, duration = 0.5})
##	anima.with({node = $Sprite2D, property = "scale", to = Vector2.ZERO, duration = 0.5})
#	anima.play()
#	await anima.animation_completed
	await get_tree().create_timer(particles.lifetime).timeout
	queue_free()
