extends Brain

var bloodlust:Vector2i
var last_enemy:Actor

static func create(_body:Enemy,_level) -> Brain:
	var brain = new(_body,_level)
	brain.bloodlust = Vector2i(0,_body.stats.hunger_max)
	return brain

func take_turn() -> int:
	var enemies:Array[Actor] = get_visible_enemies()
	if enemies.size() > 0:
		bloodlust.x = bloodlust.y
		last_enemy = enemies[0]
		path = _get_path(last_enemy.coord)
	else:
		bloodlust.x -= 1
	if path.size() > 1:
		if level.is_cell_occupied(path[-1]):
			body.move(get_alternate_step(body.coord,level.player.coord))
			path = []
			return calc_turn_cost(3.0)
		body.move(path.pop_back())
		return calc_turn_cost(3.0)
	else:
		if !last_enemy:
			return calc_turn_cost(5.0)
		elif last_enemy and level.is_adjacent_to_player(body.coord):
			#attack
			body.target = last_enemy
			body.attack_action.activate(body)
			return calc_turn_cost(1.0)
		if last_enemy and bloodlust.x > 0:
			path = _get_path(last_enemy.coord)
			return calc_turn_cost(4.0)
		else:
			last_enemy = null
			return calc_turn_cost(1.0)
			

func get_alternate_step(current: Vector2i, desired: Vector2i) -> Vector2i:
	var best_tile:Vector2i = current
	var best_dist:float = current.distance_squared_to(desired)

	for dir:Vector2i in [
		Vector2i.LEFT,
		Vector2i.UP,
		Vector2i.RIGHT,
		Vector2i.DOWN ,
		Vector2i.LEFT + Vector2i.DOWN ,
		Vector2i.UP + Vector2i.LEFT,
		Vector2i.RIGHT + Vector2i.UP,
		Vector2i.DOWN + Vector2i.RIGHT,
	]:
		var candidate:Vector2i = current + dir

		if not level.is_cell_walkable(candidate):
			continue
		if level.is_cell_occupied(candidate):
			continue

		var d:float = candidate.distance_squared_to(desired)
		if d < best_dist:
			best_dist = d
			best_tile = candidate
	print("I'm at %s" % body.coord)
	print("Wanted to go from %s to %s. Went to %s instead" % [current,desired,best_tile])
	return best_tile
