@tool
extends Control

@export var color: Constants.Colors = Constants.Colors.GREEN
@onready var state_machine: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/StateMachine/playback"]
@onready var bean_atlas_texture: AtlasTexture = %Bean.texture
@onready var bean_label: Label = %Bean/Label

func _ready():
	if not Engine.is_editor_hint():
		_set_sprite()
	Level.bean_get.connect(_set_beans) # Whenever the global bean count updates, update the display
	show_count() # This way, the bean count is displayed when the player spawns

func _process(_delta):
	if Engine.is_editor_hint():
		_set_sprite()

## We will adjust the atlas texture's region for now
func _set_sprite():
	match color:
		Constants.Colors.GREEN:
			bean_atlas_texture.region = Rect2(Vector2(0,0), Vector2(128,128))
		Constants.Colors.YELLOW:
			bean_atlas_texture.region = Rect2(Vector2(128,0), Vector2(128,128))
		Constants.Colors.BLUE:
			bean_atlas_texture.region = Rect2(Vector2(256,0), Vector2(128,128))
		Constants.Colors.RED:
			bean_atlas_texture.region = Rect2(Vector2(384,0), Vector2(128,128))
		Constants.Colors.WHITE:
			bean_atlas_texture.region = Rect2(Vector2(512,0), Vector2(128,128))
		Constants.Colors.BLACK:
			bean_atlas_texture.region = Rect2(Vector2(640,0), Vector2(128,128))

func _set_beans(col: Constants.Colors, _value: int):
	if self.color == col:
		bean_label.text = "x%.0d" % Level.beans[col]
		show_count()

func _on_Timer_timeout():
	hide_count()

func show_count(duration: float = 3):
	state_machine.travel("Show")
	$AnimationTree.set("parameters/get/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	bean_label.text = "x%.0d" % Level.beans[color]
	if duration:
		$Timer.start(duration)

func hide_count():
	state_machine.travel("Hide")
