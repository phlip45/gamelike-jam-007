extends LevelLayout
class_name DrunkardWalkLayout

var current_coord:Vector2i
var tile_count:int = 0
## coord -> tile has unwalked neighbors
var walkable_tiles: Dictionary[Vector2i,bool]
## Coord -> unused copy of coord
var walked_tiles: Dictionary[Vector2i,Vector2i]
var options:DrunkardWalkOptions

var directions:Array[Vector2i] = [
		Vector2i.UP,
		Vector2i.DOWN,
		Vector2i.LEFT,
		Vector2i.RIGHT,
]

var directions_eight_way:Array[Vector2i] = [
		Vector2i.UP,
		Vector2i.DOWN,
		Vector2i.LEFT,
		Vector2i.RIGHT,
		Vector2i.UP + Vector2i.LEFT,
		Vector2i.UP + Vector2i.RIGHT,
		Vector2i.DOWN + Vector2i.LEFT,
		Vector2i.DOWN + Vector2i.RIGHT
]
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
	layout.populate_tiles()
	return layout
	
func walk():
	var allowed_rect:Rect2i = rect.grow(-1)
	current_coord = Vector2i(
		rng.randi_range(allowed_rect.position.x,allowed_rect.size.x + allowed_rect.position.x),
		rng.randi_range(allowed_rect.position.y,allowed_rect.size.y + allowed_rect.position.y),
	)
	for i in options.max_tiles_walked:
		var dir_to_walk:Vector2i
		if options.walk_style == DrunkardWalkOptions.WalkStyle.EIGHT_WAY:
			dir_to_walk = pick_random_dir_eight_way()
		else:
			dir_to_walk = pick_random_dir()
		var new_coord:Vector2i
		new_coord = current_coord + dir_to_walk
		
		if !allowed_rect.has_point(new_coord): 
			if i > options.max_tiles_walked - 3:
				print("final i out of bounds: ", i)
			continue
		if !walked_tiles.has(new_coord): 
			tile_count += 1
		current_coord += dir_to_walk
		
		walked_tiles.set(new_coord,new_coord)
		
		# if not teleporting, drunkard actually walks to next square
		if tile_count >= options.num_tiles:
			print("final i", i)
			break
	print("Random Walk Tile_count: ", tile_count)

func populate_tiles():
	for coord in walked_tiles.keys():
		var tile:Tile = Tile.create(coord, Tile.Type.FLOOR)
		tiles.set(tile.coord,tile)
		floors.set(tile.coord,tile)
	# Create walls now from the tiles adjacent to floors
	for tile:Tile in tiles.values():
		for _coord in get_adjacent_voids(tile.coord):
			if !walls.has(_coord):
				var new_tile:Tile = Tile.create(_coord, Tile.Type.WALL)
				walls.set(_coord, new_tile)
				tiles.set(_coord, new_tile)

func pick_random_dir() -> Vector2i:
	return directions[rng.randi_range(0,directions.size()-1)]

func pick_random_dir_eight_way() -> Vector2i:
	return directions_eight_way[rng.randi_range(0,directions_eight_way.size()-1)]
