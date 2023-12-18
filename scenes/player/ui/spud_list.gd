extends Control

@onready var state_machine: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/StateMachine/playback"]


func _ready():
	Level.spud_get.connect(_set_spuds)
	$Timer.start(2)
	for i in Constants.Colors:
		%HBoxContainer.get_node(i.to_lower()).modulate = Color(1, 1, 1, 1.0 if Level.spuds[Constants.Colors[i]] else 0.2)


func _set_spuds(color: Constants.Colors):
	var spud_node = %HBoxContainer.get_node(Constants.Colors.keys()[color].to_lower())
	state_machine.travel("Show")
	$Timer.start(3)
	await $AnimationTree.animation_finished # Wait for the show animation to complete before doing the tween
	var tween = get_tree().create_tween()
	tween.tween_property(spud_node, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)


func _on_timer_timeout() -> void:
	state_machine.travel("Hide")
