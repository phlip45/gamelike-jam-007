extends Actor
class_name Enemy

@export var data:EnemyData
@export var _debug_draw_path:bool
var attack_action:Action
var brain:Brain
var debug_color:Color
var debug_offset:Vector2

var state:State

enum State{
	NULL, SLEEPING, PATROLING, WAITING, AGGRO, DEAD, 
	SPECIAL0, SPECIAL1, SPECIAL2
}

func _ready() -> void:
	super()
	if !data:
		push_error("Enemy Data missing!! Aborting enemy")
		die()
		return
	data = data.duplicate()
	actor_name = data.actor_name
	base_stats = data.base_stats.duplicate()
	symbol_char = data.symbol_char
	color = data.color
	attack_action = data.attack_action
	projectile_data = data.projectile_data
	level = Global.current_level
	debug_color = Global.rand_color()
	debug_offset = Vector2(randi_range(-16,16),randi_range(-16,16))
	
func _process(_delta):
	if _debug_draw_path:
		queue_redraw()
	
func _draw() -> void:
	if !brain: return
	if !_debug_draw_path: return
	if brain.path.size() == 0: return
	var last_spot:Vector2i = brain.path[0]
	for spot:Vector2i in brain.path:
		draw_line(
			Global.coord_to_position(spot)-global_position + debug_offset, 
			Global.coord_to_position(last_spot)-global_position + debug_offset, 
			debug_color, 
			2.0)
		last_spot = spot

## Returns how long the turn took to feed into the queue
func take_turn() -> int:
	if !level: level = Global.current_level
	if !brain:
		brain = data.brain_script.create(self,level)
	return brain.take_turn()

func take_damage(amount:int) -> void:
	stats.hp -= amount
	print_rich("[color=red]I've been hit for %s damage" % amount)
	if stats.hp <= 0:
		die()

func move(_coord:Vector2i) -> bool:
	teleport(_coord)
	return true

func die():
	died.emit()
	queue_free()
