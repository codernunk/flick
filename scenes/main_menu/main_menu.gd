extends Control

@onready var all_submenus := [$Campaign, $ChallengeLevels, $Shop]
@onready var current_submenu: Control = $Campaign

var screen_tween: Tween
var parameters: Dictionary

func _ready() -> void:
	for m in all_submenus:
		m.visible = false
	current_submenu.visible = true
	print(parameters)

func _on_campaign_button_toggled(button_pressed: bool) -> void:
	change_submenu($Campaign)

func _on_challenge_level_button_toggled(button_pressed: bool) -> void:
	change_submenu($ChallengeLevels)

func _on_shop_button_toggled(button_pressed: bool) -> void:
	change_submenu($Shop)

func change_submenu(new_submenu: Control) -> void:
	if not current_submenu == new_submenu:
		var screen_width = DisplayServer.window_get_size().x
		var is_new_menu_to_left := all_submenus.find(current_submenu) < all_submenus.find(new_submenu)
		screen_tween = get_tree().create_tween()
		screen_tween.tween_property(current_submenu, "position:x", -screen_width * 2.0 if is_new_menu_to_left else screen_width * 2.0, 0.5).from(0.0).set_trans(Tween.TRANS_EXPO)
		screen_tween.parallel().tween_property(new_submenu, "position:x", 0, 0.5).from(screen_width * 2.0 if is_new_menu_to_left else -screen_width * 2.0).set_trans(Tween.TRANS_EXPO)
		new_submenu.visible = true
		await screen_tween.finished
		current_submenu.visible = false
		current_submenu = new_submenu
