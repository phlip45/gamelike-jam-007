extends RichTextLabel
class_name TextButton

@export var highlight_color:Color
@export var dim_color:Color
signal pressed

func _ready() -> void:
	modulate = dim_color

func press():
	pressed.emit()

func highlight(highlighted:bool):
	modulate = highlight_color if highlighted else dim_color
