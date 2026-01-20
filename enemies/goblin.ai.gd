extends AI

var target:Actor
var goal_tile_coord:Vector2i
var path:Array[Vector2i]

static func create() -> AI:
	var ai = new()
	return ai

func take_turn(goblin:Enemy, level:Level) -> int:
	## decide what to do
	match goblin.state:
		Enemy.State.NULL:
			goblin.state = Enemy.State.SLEEPING
		Enemy.State.SLEEPING:
			return 200
		Enemy.State.PATROLING:
			if goal_tile_coord and goal_tile_coord == goblin.coord:
				goblin.state = Enemy.State.WAITING
				return 100
			if !goal_tile_coord:
				goal_tile_coord = level.layout.get_random_floor().coord
			#go towards patrol point
			
			return 100
		Enemy.State.WAITING:
			pass
		Enemy.State.AGGRO:
			pass
		Enemy.State.DEAD:
			pass
		Enemy.State.SPECIAL0:
			pass
		Enemy.State.SPECIAL1:
			pass
		Enemy.State.SPECIAL2:
			pass
		
	if level.can_see_player(goblin.coord, 15):
		if !target:
			target = level.turn_manager.player
	else:
		print_rich("[color=red] I am lonely")
	return 100

func move():
	pass

func check_for_enemies():
	#Right now just player but layer maybe something else.
	pass

static func hello():
	print_rich("[color=green]goblin be saying hi")
