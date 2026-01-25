@abstract
extends Area2D
class_name Actor

const SYMBOL = preload("uid://tmy3jabrxygd")

@export var actor_name:String
@export var base_stats:Stats
var stats:Stats
@export var symbol_char:String = "🐛"
@export var innate_hand_slot:Item
var inventory:Inventory
var cooldown:int = 100
var coord:Vector2i
var level:Level
var symbol:RichTextLabel
var target:Actor
var tween:Tween

@warning_ignore("unused_signal")
signal died()

func _ready() -> void:
	symbol = SYMBOL.instantiate()
	symbol.text = symbol_char
	add_child(symbol)
	if !inventory:
		inventory = Inventory.new()
	inventory.equipment_changed.connect(calc_stats)
	base_stats.stat_changed.connect(calc_stats)
	
	stats = base_stats.duplicate()
	level = Global.current_level
	
func teleport(_coord:Vector2i, animate:bool = true):
	var prior_symbol_pos:Vector2
	if animate:
		prior_symbol_pos = symbol.global_position
	position = Global.coord_to_position(_coord)
	coord = _coord
	Global.actor_moved(self,coord)
	if !animate: return
	if tween:
		tween.kill()
	symbol.global_position = prior_symbol_pos 
	tween = create_tween()
	tween.tween_property(symbol,"global_position", global_position + symbol.offset, .2)
	

func check_visibility():
	if !level.layout.tiles.has(coord): return
	symbol.visible = level.layout.tiles[coord].visible

func take_damage(amount:int) -> void:
	stats.hp -= amount
	print_rich("[color=red]I've been hit for %s damage" % amount)
	print("effective stats hp: ",stats.hp)
	print("base stats hp: ",base_stats.hp)
	if stats.hp <= 0:
		die()

func heal(amount:int) -> void:
	stats.hp = min(amount + stats.hp, stats.hp_max)
	print_rich("[color=green]I've been healed for %s" % amount)

func calc_stats(_stat_name:String = "", _new_val:int = 0):
	stats.overwrite(base_stats)
	for item in inventory.equipped_items:
		if item.stats:
			stats.add(item.stats) 

@abstract func die()
@abstract func take_turn() -> int
	
