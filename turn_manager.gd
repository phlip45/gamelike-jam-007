extends Node
class_name TurnManager

var player:Player
var actors:Array[Actor]

func _ready() -> void:
	#begin running the manager which is like the main game loop essentially.
	#it kinda acts as the engine which lets things happen
	for actor in actors:
		if actor is Player: player = actor
		actor.died.connect(remove_actor.bind(actor))

	take_next_turn()
	
func take_next_turn():
	## front of queue takes turn
	if actors.size() == 0:
		printerr("Actors Array entry when trying to take next turn.")
		return
	var actor = actors.pop_front()
	var time_taken:int = await actor.take_turn()
	if actor is Player:
		check_visibility()
	if time_taken == 0:
		actors.push_front(actor) # put current actor back in front
		take_next_turn()
		return
	actor.cooldown = time_taken
	var new_index = actors.find_custom(func(a:Actor):
		return time_taken <= a.cooldown
	)
	if new_index == -1:
		actors.append(actor)
	else:
		actors.insert(new_index, actor)
	
	# get next actor's cooldown and subtract it from everyone's cooldown
	var next_turn_cooldown = actors[0].cooldown
	for actr:Actor in actors:
		actr.cooldown -= next_turn_cooldown
	take_next_turn()

func add_actor(actor:Actor):
	actors.append(actor)
	add_child(actor)

func remove_actor(actor:Actor):
	actors.erase(actor)

func check_visibility():
	for actor:Actor in actors:
		if actor is not Player:
			actor.check_visibility()
