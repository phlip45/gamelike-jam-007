extends Brain

var target:Actor:
	set(value):
		target = value
		print_rich("[color=pink] Set target to %s"%value)
var goal_tile_coord:Vector2i:
	set(value):
		goal_tile_coord = value
		print_rich("[color=pink] Set goal_tile_coord to %s"%value)
var path:Array[Vector2i]
var path_index:int
var path_age:int
var state_cooldown:int

static func create(_body:Enemy,_level) -> Brain:
	var brain = new(_body,_level)
	brain.goal_tile_coord = brain.body.coord
	return brain

func take_turn() -> int:
	return 100




func check_for_enemies():
	#Right now just player but layer maybe something else.
	pass

static func hello():
	print_rich("[color=green]enemy be saying hi")



func look() -> bool:
	if !target:
		if level.can_see_player(body.coord, body.stats.vision_radius):
			target = level.player
			return true
		else:
			return false
	return level.can_see_actor(body.coord, body.stats.vision_radius,target)

func move_along_path():
	if path_index >= path.size(): return
	if level.is_cell_occupied(path[path_index]):
		return
	body.move(path[path_index])
	path_index += 1
