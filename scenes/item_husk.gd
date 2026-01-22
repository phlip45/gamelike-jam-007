extends Area2D
class_name ItemHusk

var coord:Vector2i
@export var item:Item
@onready var symbol: RichTextLabel = $Symbol
const ITEM_HUSK = preload("uid://k3vwahreh1xd")

signal destroyed

static func create(_item:Item) -> ItemHusk:
	var husk:ItemHusk = ITEM_HUSK.instantiate()
	husk.item = _item
	return husk

func _ready() -> void:
	symbol.text = item.symbol
	symbol.modulate = item.color
	teleport(coord)

func teleport(_coord:Vector2i) -> void:
	position = Global.coord_to_position(_coord)
	coord = _coord

func die():
	queue_free()
	destroyed.emit()

func check_visibility():
	if !Global.current_level.layout.tiles.has(coord): return
	symbol.visible = Global.current_level.layout.tiles[coord].visible
