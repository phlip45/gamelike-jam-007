extends AI

static func create() -> AI:
	var ai = new()
	return ai

func take_turn(goblin:Enemy) -> int:
	goblin.move()
	return 100

static func hello():
	print_rich("[color=green]goblin be saying hi")
