extends AI

var target:Actor
var goal_tile_coord:Vector2i
var path:Array[Vector2i]

static func create() -> AI:
	var ai = new()
	return ai

func take_turn(goblin:Enemy, level:Level) -> int:
	if level.can_see_player(goblin.coord, 15):
		print_rich("[color=green] I see player")
	else:
		print_rich("[color=red] I am lonely")
	return 100

func move():
	pass

static func hello():
	print_rich("[color=green]goblin be saying hi")
