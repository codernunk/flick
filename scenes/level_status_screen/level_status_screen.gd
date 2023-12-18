extends CanvasLayer

const MAIN_MENU_SCENE_PATH: String = "res://scenes/main_menu/main_menu.tscn"

var time_target: float = Constants.WORLDS[Level.world].levels[Level.level].time_target
var bean_total_target: int = Constants.WORLDS[Level.world].levels[Level.level].bean_target
var falls_target: int = Constants.WORLDS[Level.world].levels[Level.level].falls_target
var time_actual: float = Level.time
var bean_total_actual: int = Level.get_total_beans()
var falls_actual: int = Level.falls
var bean_bonus: float = 1
var rank: Constants.Ranks

@onready var elements := [%CompletedTimeValue, %BeansCollectedValue, %FallsValue]
@onready var bean_counts := [$BeanCountGreen, $BeanCountYellow, $BeanCountBlue, $BeanCountRed, $BeanCountWhite, $BeanCountBlack]
@onready var bean_pluses := [%BeanPlusGreen, %BeanPlusYellow, %BeanPlusBlue, %BeanPlusRed, %BeanPlusWhite, %BeanPlusBlack]

func _ready() -> void:
	%CompletedTimeTarget.text = "[right]%s[/right]" % Functions.format_time(time_target)
	%BeansCollectedTarget.text = "[right]%s[/right]" % bean_total_target
	%FallsTarget.text = "[right]%s[/right]" % falls_target
	%CompletedTimeValue.text = "[right]%s[/right]" % Functions.format_time(time_actual)
	%BeansCollectedValue.text = "[right]%s[/right]" % bean_total_actual
	%FallsValue.text = "[right]%s[/right]" % falls_actual
	%RankLetter.modulate = Color(1,1,1,0)
	%BeanBonus.modulate = Color(1,1,1,0)
	%StatusPanel.position.y = -%StatusPanel.size.y
	for e in elements: e.visible_ratio = 0
	for c in bean_pluses: c.modulate.a = 0.0

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "FadeIn":
		# Determine rank
		# S rank = bean count is met, no falls, and target time is beaten; 1.5x bean bonus
		# A rank = bean count is met, fall target met, and target time is met; 1.25x bean bonus
		# B rank = one of three targets aren't met; 1x bean bonus
		# C rank = two of three targets aren't met; 1x bean bonus
		# D rank  = all targets aren't met; 0.5x bean bonus
		var rank_points = 0
		var points = [0, 0, 0]
		if time_actual <= time_target:
			points[0] = 1
			rank_points += points[0]
		if bean_total_actual >= bean_total_target:
			points[1] = 1
			rank_points += points[1]
		if falls_actual == 0:
			points[2] = 2
			rank_points += points[2]
		elif falls_actual <= falls_target:
			points[2] = 1
			rank_points += points[2]
		match rank_points:
			4:
				rank = Constants.Ranks.S
				%RankLetter.text = "[center][wave amp=50 freq=5][color=yellow]S[/color][/wave][/center]"
				bean_bonus = 1.5
			3:
				rank = Constants.Ranks.A
				%RankLetter.text = "[center][wave amp=50 freq=5][color=red]A[/color][/wave][/center]"
				bean_bonus = 1.25
			2:
				rank = Constants.Ranks.B
				%RankLetter.text = "[center][wave amp=50 freq=5][color=green]B[/color][/wave][/center]"
			1:
				rank = Constants.Ranks.C
				%RankLetter.text = "[center][wave amp=50 freq=5][color=blue]C[/color][/wave][/center]"
			0:
				rank = Constants.Ranks.D
				%RankLetter.text = "[center][wave amp=50 freq=5][color=gray]D[/color][/wave][/center]"
				bean_bonus = 0.5
		%BeanBonus.text = "[center][wave amp=50 freq=5]Bean Bonus: [color=green]%sx[/color][/wave][/center]" % bean_bonus
		var tween = get_tree().create_tween()
		for e in elements.size():
			tween.tween_property(elements[e], "visible_ratio", 1.0, 0.5)
			tween.tween_property(elements[e], "modulate", Color.GOLD if points[e] == 2 else Color.FOREST_GREEN if points[e] == 1 else Color.DARK_RED, 0.25)
		tween.tween_property(%RankLetter, "modulate:a", 1, 0.5)
		tween.parallel().tween_property(%RankLetter, "theme_override_font_sizes/normal_font_size", 160, 0.5).from(0)
		tween.tween_property(%BeanBonus, "modulate:a", 1, 0.5)
		# Show status panel
		tween.tween_property($StatusPanel, "position:y", 0.0, 0.2)
		# Show bonuses
		for b in bean_pluses.size():
			var bean_plus = bean_pluses[b]
			var bean_delta = int(Level.beans[b] * bean_bonus)
			var set_plus_text = func(delta): bean_plus.text = "%s%s" % ["-" if delta < 0 else "+", delta]
			var set_beans_func = func(value): SavedData.set_beans(b, value)
			set_plus_text.call(bean_delta)
			tween.parallel().tween_property(bean_plus, "modulate:a", 1.0, 0.2).set_delay(0.5)
			# Set total beans to bonus
			tween.parallel().tween_method(set_plus_text, bean_delta, 0, 1).set_delay(2.0)
			tween.parallel().tween_method(set_beans_func, SavedData.beans[b], SavedData.beans[b] + bean_delta, 1).set_delay(2.0)
			tween.parallel().tween_property(bean_plus, "modulate:a", 0.0, 0.5).set_delay(3.5)

		await tween.finished
		%LevelSelectButton.disabled = false

func _on_level_select_button_button_up() -> void:
	# Set these as the best ranks if so to the saved data
	SavedData.set_level_records(rank, time_actual, bean_total_actual, falls_actual)
	Functions.load_screen_to_scene(MAIN_MENU_SCENE_PATH, {"rank": rank, "bean_total_actual": bean_total_actual})
