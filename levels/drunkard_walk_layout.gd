extends LevelLayout
class_name DrunkardWalkLayout

var current_coord:Vector2i
var tile_count:int = 0
var walk_tries:int = 1000
var options:DrunkardWalkOptions

static func generate(opts:DrunkardWalkOptions = null) -> LevelLayout:
	var layout:DrunkardWalkLayout = DrunkardWalkLayout.new()
	if !opts:
		layout.options = DrunkardWalkOptions.new()
	else:
		layout.options = opts
	layout.rng = RandomNumberGenerator.new()
	layout.rect = Rect2i(opts.offset, opts.size)
	layout.rng.seed = opts.rng_seed
	
	layout.walk()
	layout.populate_walls()
	return layout
	
func walk():
	var allowed_rect:Rect2i = rect
	allowed_rect.size -= Vector2i.ONE * 2
	allowed_rect.position += Vector2i.ONE
	current_coord = Vector2i(
		rng.randi_range(allowed_rect.position.x,allowed_rect.size.x + allowed_rect.position.x),
		rng.randi_range(allowed_rect.position.y,allowed_rect.size.y + allowed_rect.position.y),
	)
	for i in walk_tries:
		var dir_to_walk:Vector2i
		if options.walk_style == DrunkardWalkOptions.WalkStyle.EIGHT_WAY:
			dir_to_walk = pick_random_dir_eight_way()
		else:
			dir_to_walk = pick_random_dir()
		if !allowed_rect.has_point(current_coord + dir_to_walk): continue
		current_coord += dir_to_walk
		if floors.has(current_coord): continue
		var new_tile:Tile = Tile.create(current_coord,Tile.Type.FLOOR)
		floors.set(current_coord,new_tile)
		tiles.set(current_coord,new_tile)
		tile_count += 1
		if tile_count >= options.num_tiles:
			break

func populate_walls():
	# Create walls now from the tiles adjacent to floors
	for tile:Tile in tiles.values():
		for _coord in get_adjacent_voids(tile.coord):
			if !walls.has(_coord):
				var new_tile:Tile = Tile.create(_coord, Tile.Type.WALL)
				walls.set(_coord, new_tile)
				tiles.set(_coord, new_tile)

func pick_random_dir() -> Vector2i:
	var directions:Array[Vector2i] = [
		Vector2i.UP,
		Vector2i.DOWN,
		Vector2i.LEFT,
		Vector2i.RIGHT,
	]
	return directions[rng.randi_range(0,directions.size()-1)]

func pick_random_dir_eight_way() -> Vector2i:
	var directions:Array[Vector2i] = [
		Vector2i.UP,
		Vector2i.DOWN,
		Vector2i.LEFT,
		Vector2i.RIGHT,
		Vector2i.UP + Vector2i.LEFT,
		Vector2i.UP + Vector2i.RIGHT,
		Vector2i.DOWN + Vector2i.LEFT,
		Vector2i.DOWN + Vector2i.RIGHT,
	]
	return directions[rng.randi_range(0,directions.size()-1)]
