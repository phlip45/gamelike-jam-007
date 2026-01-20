@abstract
extends Area2D
class_name Actor

const SYMBOL = preload("uid://tmy3jabrxygd")

@export var actor_name:String
var cooldown:int = 100
var coord:Vector2i
var level:Level
@export var symbol_char:String = "🐛"
var symbol:RichTextLabel

func _ready() -> void:
	symbol = SYMBOL.instantiate()
	symbol.text = symbol_char
	add_child(symbol)
	level = Global.current_level
	
func teleport(_coord:Vector2i):
	position = Global.coord_to_position(_coord)
	coord = _coord
	Global.actor_moved(self,coord)

func check_visibility():
	if !level.layout.tiles.has(coord): return
	symbol.visible = level.layout.tiles[coord].visible

@warning_ignore("unused_signal")
signal died()

@abstract func take_turn() -> int
