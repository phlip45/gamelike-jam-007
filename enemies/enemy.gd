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

static func create(_data:EnemyData) -> Enemy:
	var enemy:Enemy = load("res://enemies/enemy.tscn").instantiate()
	if !_data:
		push_error("Enemy Data missing!! Aborting enemy")
		enemy.die()
		return
	enemy.data = _data.duplicate()
	enemy.actor_name = _data.actor_name
	enemy.base_stats = _data.base_stats.duplicate()
	enemy.symbol_char = _data.symbol_char
	enemy.color = _data.color
	enemy.modulate = _data.color
	enemy.attack_action = _data.attack_action
	enemy.projectile_data = _data.projectile_data
	enemy.level = Global.current_level
	enemy.debug_color = Global.rand_color()
	enemy.debug_offset = Vector2(randi_range(-16,16),randi_range(-16,16))
	return enemy

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

func move(_coord:Vector2i) -> bool:
	teleport(_coord)
	return true

func drop_items():
	var drops:Array[Item] = data.death_drops.get_death_drops(level.item_rng)
	for item:Item in drops:
		drop_item(item)
		
func drop_item(item:Item):
	var item_husk:ItemHusk = ItemHusk.create(item)
	level.item_manager.add_item_husk(item_husk,coord)
	
func die():
	died.emit()
	if !data.death_drops:
		push_warning("Enemy %s had no death drops equipped" % actor_name)
	else:
		drop_items()
	death_start = Vector2(randf_range(-4,4), randf_range(-18,-9))
	death_rotation = .016 * randf_range(-25,25)
	var sound = death_sound.pick_random()
	actor_sound_player.stop()
	actor_sound_player.play_sound.call_deferred(sound)

	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_method(func(_progress:float):
		death_start += Vector2.DOWN * .016 * 20
		global_position += death_start 
		rotation += death_rotation
		,0.0,1.0,3)
	tween.tween_callback(queue_free)
	#queue_free()
