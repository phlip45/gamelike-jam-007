extends Control

@onready var selector: Selector = $Selector
@export var cooldown:Vector2 = Vector2(.4,.4)
@onready var you_win: RichTextLabel = $MarginContainer/VBoxContainer/YouWin
@onready var you_win_1: RichTextLabel = $MarginContainer/VBoxContainer/YouWin1
@onready var you_win_2: RichTextLabel = $MarginContainer/VBoxContainer/YouWin2
@onready var you_win_3: RichTextLabel = $MarginContainer/VBoxContainer/YouWin3
@onready var you_wins:Array[RichTextLabel] = [you_win,you_win_1,you_win_3,you_win_2]
@export var sounds:Dictionary[String, AudioStream]
var you_win_index:int = 0

func _ready() -> void:
	Maestro.voice_player.stream = sounds["congrats"]
	Maestro.voice_player.play()

func _process(delta: float) -> void:
	cooldown.x -= delta
	if cooldown.x < 0:
		you_wins[you_win_index].visible = false
		you_win_index = posmod(you_win_index + 1, you_wins.size())
		you_wins[you_win_index].visible = true
		cooldown.x = cooldown.y

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
