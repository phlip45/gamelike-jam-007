extends Control

@onready var selector: Selector = $Selector


func _on_retry_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/dungeon.tscn")


func _on_exit_2_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/title_scene.tscn")


func _on_selector_option_highlighted(integer: int) -> void:
	for value in selector.options.values():
		value.highlight(false)
	selector.options.values()[integer].highlight(true)

func _on_selector_option_selected(integer: int) -> void:
	selector.options.values()[integer].pressed.emit()
