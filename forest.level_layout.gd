extends LevelLayout
class_name Forest

var trees:Dictionary[Vector2i, Arbol]
var options:ForestOptions

static func generate(opts:ForestOptions = null) -> LevelLayout:
	var layout:Forest = Forest.new()
	if !opts:
		layout.options = ForestOptions.new()
	else:
		layout.options = opts
	layout.rect = Rect2i(opts.offset, opts.size)
	layout.rng = RandomNumberGenerator.new()
	layout.rng.seed = opts.rng_seed
	
	layout.place_trees()
	layout.populate_tiles()
	
	return layout

func place_trees():
	var total_tiles:int = rect.size.x * rect.size.y
	var num_trees:int = floor(total_tiles * options.density)
	
	for i in num_trees:
		var tree = make_tree()
		# there might be collisions but it is fine, density will
		# always be slightly lower than set
		trees.set(tree.coord, tree)
	
func make_tree() -> Arbol:	
	var tree:Arbol = Arbol.new()
	tree.coord.x = rng.randi_range(rect.position.x+1, rect.position.x + rect.size.x - 2)
	tree.coord.y = rng.randi_range(rect.position.y+1, rect.position.y + rect.size.y - 2)
	return tree

func populate_tiles() -> void:
	for y in rect.size.y - 2:
		for x in rect.size.x - 2:
			var coord:Vector2i = Vector2i(rect.position.x + 1 + x, rect.position.y + 1 + y)
			var tile:Tile = Tile.create(coord,Tile.Type.FLOOR)
			floors.set(coord,tile)
			tiles.set(coord, tile)
	for tree_location:Vector2i in trees:
		tiles.erase(tree_location)
		floors.erase(tree_location)
	# Create walls now from the tiles adjacent to floors
	for tile:Tile in tiles.values():
		for _coord in get_adjacent_voids(tile.coord):
			if !walls.has(_coord):
				var t:Tile = Tile.create(_coord, Tile.Type.WALL)
				walls.set(_coord,t)
				tiles.set(_coord, t)
