extends Area2D
class_name ItemHusk

@export var item:Item
@onready var symbol: RichTextLabel = $Symbol

func _ready() -> void:
	symbol.text = item.symbol
