@abstract 
extends RefCounted
class_name Brain

var body:Enemy
var level:Level
var path:Array[Vector2i]

func _init(_body:Enemy,_level:Level) -> void:
	body = _body
	level = _level
	
func take_turn() -> int:
	match body.state:
		Enemy.State.NULL:
			change_state(Enemy.State.SLEEPING)
		Enemy.State.SLEEPING:
			return sleep()
		Enemy.State.PATROLING:
			return patrol()
		Enemy.State.WAITING:
			return waiting()
		Enemy.State.AGGRO:
			return aggro()
		Enemy.State.DEAD:
			return dead()
		Enemy.State.SPECIAL0:
			return special0()
		Enemy.State.SPECIAL1:
			return special1()
		Enemy.State.SPECIAL2:
			return special2()
		
	return 999999
	
func patrol() -> int:
	#if goal_tile_coord == body.coord:
		#goal_tile_coord = level.layout.get_random_floor().coord
		#change_state(Enemy.State.WAITING)
		#return 100
	##go towards patrol point
	#if path.size() <= 1 or path_age > 5:
		#path = _get_path()
		#if path.size() <= 0:
			#change_state(Enemy.State.WAITING)
			#return 1
	#move_along_path()
	#if path_index>= path.size():
		#change_state(Enemy.State.SLEEPING)
		#return 200
	return 100
	
func sleep() -> int:
	#if level.can_see_player(body.coord, body.stats.vision_radius - 3):
		#change_state(Enemy.State.AGGRO)
		#target = level.player
	return 200

func waiting() -> int:
	change_state(Enemy.State.PATROLING)
	return 100

func aggro() -> int:
	#look()
	#if path.size() <= 1:
		#_get_path(target.coord)
	#move_along_path()
	
	return 100

func dead() -> int:
	body.die()
	return 1

func special0() -> int:
	change_state(Enemy.State.PATROLING)
	return 100
	
func special1() -> int:
	change_state(Enemy.State.PATROLING)
	return 100
	
func special2() -> int:
	change_state(Enemy.State.PATROLING)
	return 100

func change_state(new_state:Enemy.State):
	body.state = new_state
	print_rich("[color=orange]Changing to State: %s" % Enemy.State.keys()[new_state])

func _get_path(to:Vector2i) -> Array[Vector2i]:
	#This path starts at the target and ends where brain is because
	#then we pop the path as we move along
	var _path:Array[Vector2i] = level.pathfinder.get_path(to, body.coord)
	_path.pop_back()
	return _path

func can_see_actor(actor:Actor) -> bool:
	return level.can_see_actor(body.coord, body.stats.vision_radius, actor)

func get_visible_enemies() -> Array[Actor]:
	var actors:Array[Actor] = level.get_actors_in_range(body.coord,body.stats.vision_radius)
	#determine whether something is an enemy or not
	#right now it is just the player
	var result:Array[Actor]
	for actor in actors:
		if actor is not Player: continue
		if can_see_actor(actor):
			result.append(actor)
	return result
