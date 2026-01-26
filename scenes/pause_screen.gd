extends Control
class_name PauseMenu

@onready var selector: Selector = $Selector
@onready var options_holder: Control = $OptionsHolder
const PAUSE_SCREEN = preload("uid://7ut36fav15fa")
var chosen:int = 0
signal pause_closed

static func create() -> PauseMenu:
	var menu = PAUSE_SCREEN.instantiate()
	return menu

func _on_resume_pressed() -> void:
	queue_free()
	pause_closed.emit()

func _on_options_pressed() -> void:
	selector.enabled = false
	var option_menu_scene:PackedScene = load("res://scenes/options.tscn")
	var option_menu:OptionsMenu = option_menu_scene.instantiate()
	options_holder.add_child(option_menu)
	await option_menu.menu_exited
	selector.enabled = true

func _on_exit_pressed() -> void:
	Global.exit_game()
	get_tree().change_scene_to_file("res://scenes/title_scene.tscn")

func _on_selector_option_selected(integer: int) -> void:
	chosen = integer
	if selector.options[chosen] is TextButton:
		selector.options[chosen].press()
		return

func _on_selector_option_highlighted(integer: int) -> void:
	var highlighted = selector.options[integer]
	highlighted.highlight(true)
	selector.option_highlighted.connect(func(_useless:int):highlighted.highlight(false), CONNECT_ONE_SHOT)
	
