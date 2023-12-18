extends CanvasLayer

## The scene file to open upon transition
@export_file("*.tscn") var next_scene_path: String
## Arguments to pass to the loaded scene
@export var scene_args: Array
@export var tips: Array[Dictionary] = [
	{ "title": "Bouncing", "text": "Bouncing gives more height than a standard jump or flick."},
	{ "title": "Rolling", "text": "Rolling gives the player more speed on the ground and can defeat grounded enemies."},
	{ "title": "Gaining More Height", "text": "Jumping and then flicking upwards can be done to reach higher areas than with either one alone."},
	{ "title": "Tomato Bro", "text": "These pesky guys like to partrol the area in search of beans to bully, but they aren't very smart."},
	{ "title": "Flying Tomato Bro", "text": "Like their walking counterpart, they don't do much other than move around, but they are inconveiently placed in the way." },
]

var parameters: Dictionary
var loaded := false
var target_scene: PackedScene

func _ready() -> void:
	var selected_tip := tips[randi() % tips.size()]
	%TipLabel.text = "Tip: %s" % selected_tip.title
	%TipText.text = selected_tip.text
	ResourceLoader.load_threaded_request(next_scene_path)

func _process(delta: float) -> void:
	if ResourceLoader.load_threaded_get_status(next_scene_path) == ResourceLoader.THREAD_LOAD_LOADED:
		set_process(false)
		await get_tree().create_timer(1).timeout # Add a small delay for transitions
		loaded = true
		%LoadingLabel.text = "Touch screen to continue..."
		%AnimationPlayerLoading.play("Complete")

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and loaded:
		$AnimationPlayer.play_backwards("Init")
		await $AnimationPlayer.animation_finished
		queue_free()

func open_new_scene():
	# This function gets called twice because the animation plays in reverse, 
	# and this function call is a keyframe on the loading screen's animation.
	# Therefore, we only need this to be called once, so we will
	# store the loaded scene into a variable.
	if loaded and not target_scene:
		target_scene = ResourceLoader.load_threaded_get(next_scene_path)
		var new_node = target_scene.instantiate()
		if "parameters" in new_node: new_node.parameters = parameters
		var last_scene = get_tree().current_scene
		get_tree().get_root().add_child(new_node)
		get_tree().current_scene = new_node
		last_scene.queue_free()
