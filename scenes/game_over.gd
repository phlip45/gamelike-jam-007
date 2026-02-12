extends Control

@export var hyperbole_texts:Array[RichTextLabel]

@onready var selector: Selector = $Selector

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _ready() -> void:
	if Global.Settings.hyperbole:
		for text in hyperbole_texts:
			text.visible = false
		hyperbole_texts.pick_random().visible = true
	

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
