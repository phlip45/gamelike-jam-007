extends Actor
class_name Enemy

@export var stats:Stats
@export var _ai_script:GDScript
var ai:AI
@warning_ignore("unused_signal")
signal turn_over(time_spent)

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
