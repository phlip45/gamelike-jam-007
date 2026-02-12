extends RichTextLabel
class_name Symbol

static var offset = Vector2(-10,-22)
@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	visibility_changed.connect(line_of_sight_change)
func line_of_sight_change():
	color_rect.visible = visible
