extends Control
class_name OptionSlider

var value:float = 1.0:
	set(val):
		value = clamp(val,0,1)
		update_visual()
		value_changed.emit(value)

@export var label_name:String
@onready var slider: RichTextLabel = $HBoxContainer/Slider
@onready var label: RichTextLabel = $HBoxContainer/Label
@export var slider_string:String = "<--------------------------->"
@export var knob_string:String = "|=|"
@export var highlight_color:Color
@export var dim_color:Color

signal value_changed(new_value:float)

func _ready() -> void:
	label.text = label_name
	update_visual()

func highlight(highlighted:bool):
	modulate = highlight_color if highlighted else dim_color

func update_visual():
	var bar_chars_length:int = slider_string.length() - 2
	var knob_length:int = knob_string.length()
	@warning_ignore("narrowing_conversion")
	var knob_space:int = snappedf(((bar_chars_length - 1) * value), 0.1)
	var left = slider_string.substr(0,knob_space)
	var right = slider_string.substr(knob_space + knob_length)
	var text = left + knob_string + right
	slider.text = text
