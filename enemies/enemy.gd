extends Actor
class_name Enemy

@onready var feeler: Area2D = $Feeler
@export var stats:Stats
@export var _ai_script:GDScript
var ai:AI

var state:State

enum State{
	NULL, SLEEPING, PATROLING, WAITING, AGGRO, DEAD, 
	SPECIAL0, SPECIAL1, SPECIAL2
}

func _ready() -> void:
	super()
	level = Global.current_level
	ai = _ai_script.create()

## Returns how long the turn took to feed into the queue
func take_turn() -> int:
	if !level: level = Global.current_level
	return ai.take_turn(self, level)

func take_damage(amount:int) -> void:
	stats.hp -= amount
	print_rich("[color=red]I've been hit for %s damage" % amount)
	if stats.hp <= 0:
		die()
		
func die():
	died.emit()
	queue_free()
