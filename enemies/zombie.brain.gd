extends Brain

static func create(_body:Enemy,_level) -> Brain:
	var brain = new(_body,_level)
	return brain

func take_turn() -> int:
	var enemies:Array[Actor] = get_visible_enemies()
	if enemies.size() > 0:
		path = _get_path(enemies[0].coord)
	elif path.size() <= 1: 
		path = _get_path(level.player.coord)
	if path.size() > 1:
		if level.is_cell_occupied(path[-1]):
			path = []
			return 25
		body.move(path.pop_back())
		return 100
	else:
		print_rich("[color=cyan] Zombie attack player!")
		return 100
