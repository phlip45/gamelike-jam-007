extends Actor
class_name Player

@export var walk_cooldown:Vector2 = Vector2(0,.5)
@export var unarmed_weapon:Weapon
var running:bool = false
var state:State
var ground_features:Array[Feature]
var equipped_weapon:Weapon
@export var time_til_heal:Vector2i = Vector2i(500,500)
@export var sounds:Dictionary[String,AudioStream]

enum State{
	NULL,AWAITING_INPUT,AWAITING_TURN,AWAITING_BUMPABLES,ANIMATING,INVENTORY,DEAD
}

signal started_turn
signal finished_turn(time_taken:int)

func _ready() -> void:
	super()
	coord = Global.position_to_coord(position)
	
	if Global.ui != null:
		Global.ui.connect_to_player.call_deferred(self)
	else:
		Global.signals.ui_loaded.connect(func():
			Global.ui.connect_to_player(self)
		)
	inventory.item_dropped.connect(drop_item)

func _process(delta: float) -> void:
	if Input.is_action_pressed("debug_bottom"):
		stats.hp = randi_range( 2,2444)
	if Input.is_action_pressed("debug_top"):
		stats.hp += 1
	if Input.is_action_pressed("debug_left"):
		stats.whoosh += 1
	if state != State.AWAITING_INPUT:
		return
	premove(delta)

func take_turn() -> int:
	if state == State.DEAD:
		await finished_turn
	if time_til_heal.x <= 0:
		regenerate()
		time_til_heal.x = time_til_heal.y
	started_turn.emit()
	state = State.AWAITING_INPUT
	var time_taken:int = await finished_turn
	time_til_heal.x -= time_taken
	time_taken -= stats.whoosh
	time_taken = max(0, time_taken)
	hunger(2)
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
		walk_cooldown.x = walk_cooldown.y
		return
	elif Input.is_action_just_pressed("action"):
		if ground_features.size() > 0:
			for feature in ground_features:
				if feature.trigger == Feature.Trigger.USE:
					state = State.ANIMATING
					if tween:
						tween.kill()
					feature.use(self)
					ground_features.clear()
					return
					
	elif Input.is_action_just_pressed("pause"):
		pause()
		walk_cooldown.x = walk_cooldown.y
		return
	elif Input.is_action_just_pressed("pickup"):
		pickup_items()
		walk_cooldown.x = walk_cooldown.y
		return
	else:  # for example if a mouse is clicked or something.
		walk_cooldown.x = 0
		running = false
		return
	if walk_cooldown.x <= 0:
		var bumpables:Array = get_bumpables_at_location(desired_move)
		if bumpables.size() > 0:
			walk_cooldown.x = walk_cooldown.y/10 if running else walk_cooldown.y
			running = true
			bump_into(bumpables)
		else:
			walk_cooldown.x = walk_cooldown.y/10 if running else walk_cooldown.y
			running = true
			move(desired_move,delta)

func move(desired_coord:Vector2i, _delta:float = 0):
	teleport(desired_coord)
	## TODO: Add micro animations here to move the @ inbetween spaces instead
	## of instantly
	state = State.AWAITING_TURN
	Global.set_ground_items(get_ground_items())
	ground_features = get_features_at_coord(coord)
	finished_turn.emit(100)
	
func take_damage(amount:int) -> void:
	stats.hp -= amount
	DamageNumber.create(amount,coord)
	if stats.hp <= 0:
		die()
		return
	if amount > 0:
		actor_sound_player.play_sound(hurt_sound.pick_random())
func get_bumpables_at_location(target_coord:Vector2i) -> Array[Area2D]:
	return level.get_bumpables_at_location(target_coord)

func get_items_at_coord(_target:Vector2i) -> Array[Item]:
	return level.get_items_at_coord(_target)

func get_features_at_coord(_target:Vector2i) -> Array[Feature]:
	return level.get_features_at_coord(_target)
	
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
	return get_items_at_coord(coord)

func attack(enemy:Enemy):
	target = enemy
	if inventory.weapon_slot:
		inventory.weapon_slot.attack(self)
	else:
		unarmed_weapon.attack(self)
	finished_turn.emit(80)

func open_inventory():
	state = State.INVENTORY
	Global.ui.open_inventory(inventory)
	await Global.ui.inventory_closed
	state = State.AWAITING_INPUT

func pause():
	state = State.INVENTORY
	var menu = PauseMenu.create()
	Global.ui.pause_holder.add_child(menu)
	await menu.pause_closed
	state = State.AWAITING_INPUT

func pickup_items():
	var husks:Array[ItemHusk] = level.get_item_husks_at_coord(coord)
	for item_husk:ItemHusk in husks:
		if(inventory.add(item_husk.item)):
			item_husk.die()
	Global.set_ground_items(get_ground_items())

func drop_item(item:Item):
	var item_husk:ItemHusk = ItemHusk.create(item)
	level.item_manager.add_item_husk(item_husk,coord)
	Global.set_ground_items(get_ground_items())

func regenerate():
	heal(ceil(stats.hp_max/10.0))

func hunger(amount:int = 1):
	stats.hunger -= amount
	if stats.hunger == 0:
		die.call_deferred()

func eat(amount:int = 0):
	stats.hunger += amount

func die():
	state = State.DEAD
	death_start = Vector2(randf_range(-4,4), randf_range(-18,-9))
	death_rotation = .016 * randf_range(-25,25)
	actor_sound_player.play_sound(death_sound.pick_random())
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_method(func(_progress:float):
		death_start += Vector2.DOWN * .016 * 20
		global_position += death_start 
		rotation += death_rotation
		,0.0,1.0,3)
	tween.tween_callback(get_tree().change_scene_to_file.call_deferred.bind("res://scenes/game_over.tscn"))
