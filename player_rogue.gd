extends Actor
class_name Player

@onready var feeler: Area2D = $Feeler

@export var stats:Stats
@export var walk_cooldown:Vector2 = Vector2(0,.5)
var running:bool = false
var coords:Vector2i
var state:State

var hunger_words:Dictionary[float,String] = {
	.9: "[color=green]Sated",
	.5: "[color=white]Content",
	.25: "[color=orange]Peckish",
	0.0001: "[color=red]Starving",
	0: "[color=#222]Dead",
}

enum State{
	NULL, AWAITING_INPUT,AWAITING_TURN,AWAITING_BUMPABLES,ANIMATING
}

signal finished_turn(time_taken:int)

func _ready() -> void:
	coords = position_to_coord(position)
	if Global.ui:
		Global.ui.connect_to_player(self)
	else:
		Global.signals.ui_loaded.connect(func():
			Global.ui.connect_to_player(self)
		)

func _process(delta: float) -> void:
	if Input.is_action_pressed("debug_bottom"):
		stats.hp -= 1
	if Input.is_action_pressed("debug_top"):
		stats.hp += 1
	if Input.is_action_pressed("debug_left"):
		stats.whoosh += 1
	if state != State.AWAITING_INPUT:
		return
	
	premove(delta)

func take_turn() -> int:
	state = State.AWAITING_INPUT
	var time_taken:int = await finished_turn
	return time_taken

func premove(delta:float):
	if !Input.is_anything_pressed():
		walk_cooldown.x = 0
		running = false
		return
	if walk_cooldown.x > 0:
		walk_cooldown.x -= delta
		return
	var desired_move:Vector2i = coords
	if Input.is_action_pressed("left"):
		desired_move.x = coords.x - 1
	elif Input.is_action_pressed("right"):
		desired_move.x = coords.x + 1
	elif Input.is_action_pressed("up"):
		desired_move.y = coords.y - 1
	elif Input.is_action_pressed("down"):
		desired_move.y = coords.y + 1
	elif Input.is_action_pressed("ul"):
		desired_move.x = coords.x - 1
		desired_move.y = coords.y - 1
	elif Input.is_action_pressed("ur"):
		desired_move.x = coords.x + 1
		desired_move.y = coords.y - 1
	elif Input.is_action_pressed("dl"):
		desired_move.x = coords.x - 1
		desired_move.y = coords.y + 1
	elif Input.is_action_pressed("dr"):
		desired_move.x = coords.x + 1
		desired_move.y = coords.y + 1
	elif Input.is_action_pressed("wait"):
		pass
	else:  # for example if a mouse is clicked or something.
		walk_cooldown.x = 0
		running = false
		return
	var desired_pos:Vector2 = coord_to_position(desired_move)
	if walk_cooldown.x <= 0:
		var bumpables:Array = await get_bumpables_at_location(desired_pos)
		if bumpables.size() > 0:
			walk_cooldown.x = walk_cooldown.y/10 if running else walk_cooldown.y
			running = true
			bump_into(bumpables)
		else:
			walk_cooldown.x = walk_cooldown.y/10 if running else walk_cooldown.y
			running = true
			move(desired_pos, desired_move,delta)

func move(desired_pos:Vector2, desired_coords:Vector2i, _delta:float):
	position = desired_pos
	coords = desired_coords
	## TODO: Add micro animations here to move the @ inbetween spaces instead
	## of instantly
	state = State.AWAITING_TURN
	Global.actor_moved(self,coords)
	finished_turn.emit( max(100 - stats.whoosh,0) )

func get_bumpables_at_location(target:Vector2) -> Array:
	feeler.position = target - position
	state = State.AWAITING_BUMPABLES
	## Takes two frames for feeler to move and for it to correctly
	## register overlapping areas it seems.
	await get_tree().process_frame
	await get_tree().process_frame
	var areas:Array[Area2D] = feeler.get_overlapping_areas()
	var physics_stuffs:Array = feeler.get_overlapping_bodies()
	if physics_stuffs.size() > 0:
		areas.append(Wall.new())
	return areas

func bump_into(bumpables:Array):
	var enemy:Enemy = null
	var interactable:Interactable = null
	var wall:Wall = null
	var player:Player = null
	var eldritch_being:Area2D = null
	for bumpable:Area2D in bumpables:
		if bumpable is Enemy:
			enemy = bumpable as Enemy
		elif bumpable is Interactable:
			interactable = bumpable as Interactable
		elif bumpable is Wall:
			wall = bumpable as Wall
		elif bumpable is Player:
			player = bumpable as Player
		else:
			eldritch_being = bumpable
	state = State.AWAITING_TURN
	if enemy:
		attack(enemy)
	elif interactable:
		#interact with this thing
		finished_turn.emit( max(100 - stats.whoosh,0) )
	elif wall:
		#stop moving
		finished_turn.emit(0)
	elif player:
		#skip turn
		finished_turn.emit(0)
	else:
		printerr("I've bumped into a terrible eldritch thing I don't know what it is.", eldritch_being)

func position_to_coord(pos:Vector2) -> Vector2i:
	var coord:Vector2i
	@warning_ignore("narrowing_conversion")
	coord.x = pos.x / Global.tile_size.x
	@warning_ignore("narrowing_conversion")
	coord.y = pos.y / Global.tile_size.y
	return Vector2i(coord)

func coord_to_position(coord:Vector2i) -> Vector2:
	var pos:Vector2
	pos.x = coord.x * Global.tile_size.x
	pos.y = coord.y * Global.tile_size.y
	return pos

func attack(enemy:Enemy):
	enemy.take_damage(5)
	Global.push_message("[color=red]%s[color=white] took 5 damage" % enemy.actor_name)
	finished_turn.emit()

func get_hunger_text() -> String:
	var hungriness:float = float(stats.hunger) / float(stats.hunger_max)
	
	for key in hunger_words.keys():
		if hungriness >= key:
			return hunger_words[key]
	return "[color=#222]Dead"
