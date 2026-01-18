extends Actor
class_name Player

@onready var feeler: Area2D = $Feeler
@onready var feet_feeler: Area2D = $FeetFeeler

@export var stats:Stats
@export var walk_cooldown:Vector2 = Vector2(0,.5)
var inventory:Inventory
var running:bool = false
var state:State
var ground_item_husks:Array[ItemHusk]

enum State{
	NULL, AWAITING_INPUT,AWAITING_TURN,AWAITING_BUMPABLES,ANIMATING,INVENTORY,
}

signal finished_turn(time_taken:int)

func _ready() -> void:
	coord = Global.position_to_coord(position)
	inventory = Inventory.new()
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
	var desired_move:Vector2i = coord
	if Input.is_action_pressed("left"):
		desired_move.x = coord.x - 1
	elif Input.is_action_pressed("right"):
		desired_move.x = coord.x + 1
	elif Input.is_action_pressed("up"):
		desired_move.y = coord.y - 1
	elif Input.is_action_pressed("down"):
		desired_move.y = coord.y + 1
	elif Input.is_action_pressed("ul"):
		desired_move.x = coord.x - 1
		desired_move.y = coord.y - 1
	elif Input.is_action_pressed("ur"):
		desired_move.x = coord.x + 1
		desired_move.y = coord.y - 1
	elif Input.is_action_pressed("dl"):
		desired_move.x = coord.x - 1
		desired_move.y = coord.y + 1
	elif Input.is_action_pressed("dr"):
		desired_move.x = coord.x + 1
		desired_move.y = coord.y + 1
	elif Input.is_action_pressed("wait"):
		pass
	elif Input.is_action_just_pressed("cancel"):
		open_inventory()
		return
	elif Input.is_action_just_pressed("pickup"):
		pickup_items()
		return
	else:  # for example if a mouse is clicked or something.
		walk_cooldown.x = 0
		running = false
		return
	var desired_pos:Vector2 = Global.coord_to_position(desired_move)
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

func move(desired_pos:Vector2, desired_coord:Vector2i, _delta:float):
	position = desired_pos
	coord = desired_coord
	## TODO: Add micro animations here to move the @ inbetween spaces instead
	## of instantly
	state = State.AWAITING_TURN
	Global.actor_moved(self,coord)
	Global.set_ground_items(await get_ground_items())
	finished_turn.emit( max(100 - stats.whoosh,0) )

func get_bumpables_at_location(target:Vector2) -> Array:
	feeler.position = target - position
	state = State.AWAITING_BUMPABLES
	## Takes two frames for feeler to move and for it to correctly
	## register overlapping areas it seems.
	await get_tree().process_frame
	await get_tree().process_frame
	var areas:Array[Area2D] = feeler.get_overlapping_areas()
	areas = areas.filter(is_bumpable)
	var physics_stuffs:Array[Node2D] = feeler.get_overlapping_bodies()
	if physics_stuffs.size() > 0:
		areas.append(Wall.new())
	return areas

func get_items_at_location(target:Vector2) -> Array[Item]:
	feeler.position = target - position
	await get_tree().process_frame
	await get_tree().process_frame
	ground_item_husks.clear()
	var areas:Array = feeler.get_overlapping_areas()
	var items:Array[Item]
	for a:Area2D in areas:
		if a is ItemHusk:
			ground_item_husks.append(a)
			items.append(a.item as Item)
	return items
	
func bump_into(bumpables:Array):
	var enemy:Enemy = null
	var interactable:Interactable = null
	var wall:Wall = null
	var player:Player = null
	for bumpable:Area2D in bumpables:
		if bumpable is Enemy:
			enemy = bumpable as Enemy
		elif bumpable is Interactable:
			interactable = bumpable as Interactable
		elif bumpable is Wall:
			wall = bumpable as Wall
		elif bumpable is Player:
			player = bumpable as Player
	state = State.AWAITING_TURN
	if enemy:
		#whack!
		attack(enemy)
	elif interactable:
		#interact with this thing/Prompt to interact
		#Maybe interact prompt is part of the interact portion?
		finished_turn.emit( max(100 - stats.whoosh,0) )
	elif wall:
		#bonk sound effect
		wall.queue_free()
		finished_turn.emit(0)
	elif player:
		#Skip Turn
		finished_turn.emit(50)
	else:
		finished_turn.emit(0)

func is_bumpable(area:Area2D) -> bool:
	return area is Enemy or\
		 area is Player or\
		 area is Wall or\
		 area is Interactable

func get_ground_items() -> Array[Item]:
	return await get_items_at_location(global_position)

func attack(enemy:Enemy):
	enemy.take_damage(5)
	Global.push_message("[color=red]%s[color=white] took 5 damage" % enemy.actor_name)
	finished_turn.emit(50)

func open_inventory():
	state = State.INVENTORY
	Global.ui.open_inventory(inventory)
	await Global.ui.inventory_closed
	state = State.AWAITING_INPUT

func pickup_items():
	for item_husk:ItemHusk in ground_item_husks:
		inventory.add(item_husk.item)
		item_husk.queue_free()
	Global.set_ground_items(await get_ground_items())
	
