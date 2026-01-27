extends Area2D
class_name Feature

const FEATURE = preload("uid://irvyekssfi8g")

var coord:Vector2i
const SYMBOL = preload("uid://tmy3jabrxygd")
@export var symbol_char:String = "🐛"
@export var func_name:Effect.Func
@export var trigger:Trigger
@export var blocks_movement:bool = false
var symbol:RichTextLabel
var level:Level
var tween:Tween

@warning_ignore("unused_signal")
signal destroyed

enum Trigger{
	NULL, ENTER, USE
}

@warning_ignore("int_as_enum_without_cast")
static func create(_symbol:String = "🐛", _trigger:Trigger = 0, _func:Effect.Func = 0) -> Feature:
	var feature = FEATURE.instantiate()
	feature.symbol_char = _symbol
	feature.trigger = _trigger
	feature.func_name = _func
	return feature
	
func _ready() -> void:
	symbol = SYMBOL.instantiate()
	symbol.text = symbol_char
	add_child(symbol)
	level = Global.current_level
	match trigger:
		Trigger.ENTER:
			area_entered.connect(_on_area_entered)
		Trigger.USE:
			pass

func teleport(_coord:Vector2i, animate:bool = true):
	var prior_symbol_pos:Vector2
	if animate:
		prior_symbol_pos = symbol.global_position
	position = Global.coord_to_position(_coord)
	coord = _coord
	if !animate: return
	if tween:
		tween.kill()
	symbol.global_position = prior_symbol_pos 
	tween = create_tween()
	tween.tween_property(symbol,"global_position", global_position + symbol.offset, .2)

func check_visibility():
	if !Global.current_level.layout.tiles.has(coord): return
	symbol.visible = Global.current_level.layout.tiles[coord].visible
	
func use(source:Actor, targets:Array[Variant] = []) -> void:
	if trigger != Trigger.USE: return
	var effect:Effect = Effect.func_to_callable[func_name]
	effect.activate.call(source,targets)
	
func _on_area_entered(_area: Area2D) -> void:
	pass # Replace with function body.


func _on_area_exited(_area: Area2D) -> void:
	pass # Replace with function body.
