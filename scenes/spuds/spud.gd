class_name Spud
extends Area2D

@export var color: Constants.Colors = Constants.Colors.GREEN


func _on_body_entered(_body: Node):
	$AnimationPlayer.play("Get")
	$CollisionShape2D.set_deferred("disabled", true)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Get":
		Level.collect_spud(color)
		$AnimationPlayer.play("Active")
