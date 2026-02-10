@abstract
extends Area2D
class_name Actor

const SYMBOL = preload("uid://tmy3jabrxygd")

@export var actor_name:String
@export var base_stats:Stats
@export var blocks_movement:bool = true
@export var symbol_char:String = "🐛"
@export var color:Color = Color.WHITE
@export var projectile_data:ProjectileData
@export var ranged_attack_sound:Array[AudioStream]
@export var hurt_sound:Array[AudioStream]
@export var death_sound:Array[AudioStream]
@export var actor_sound_player: ActorSoundPlayer

var stats:Stats
var inventory:Inventory
var cooldown:int = 100
var coord:Vector2i
var level:Level
var symbol:RichTextLabel
var target:Actor
var tween:Tween
var death_start:Vector2
var death_rotation:float

@warning_ignore("unused_signal")
signal died()

func _ready() -> void:
	symbol = SYMBOL.instantiate()
	symbol.text = symbol_char
	add_child(symbol)
	if !inventory:
		inventory = Inventory.new()
		inventory.owner = self
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
	tween.tween_property(symbol,"position", Vector2.ZERO + symbol.offset,0)

func check_visibility():
	if !level.layout.tiles.has(coord): return
	visible = level.layout.tiles[coord].visible

func take_damage(amount:int) -> void:
	stats.hp -= amount
	DamageNumber.create(amount,coord,color)
	if stats.hp <= 0:
		die()
	if amount > 0:
		actor_sound_player.play_sound(hurt_sound.pick_random())

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
	
