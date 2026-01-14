extends LevelLayout
class_name SimpleRoomCorridorLayout

#rng
#rect
#tiles
var rooms:Dictionary[Vector2i,Room]
var corridors:Dictionary[Vector2i,Corridor]
var options:Options

static func generate(opts:Options = null) -> LevelLayout:
	opts.rng.seed = opts.rng_seed
	var layout:LevelLayout = SimpleRoomCorridorLayout.new()
	if !opts:
		layout.options = Options.new()
	else:
		layout.options = opts
	layout.rng = opts.rng
	layout.rect = Rect2i(opts.offset, opts.size)
	
	layout.make_rooms(opts)
	
	layout.make_corridors()
	layout.populate_tiles()
	return layout

func make_rooms(opts:Options):
	while(rooms.size() < opts.num_rooms.y && opts.tries > 0):
		opts.tries -= 1
		var room:Room = make_room()
		var footprint:Rect2i = room.get_footprint()
		#check whether room goes off screen
		if footprint.position.x + footprint.size.x >      \
		   Global.grid_offset.x + Global.grid_size.x: continue
		if footprint.position.y + footprint.size.y >      \
		   Global.grid_offset.y + Global.grid_size.y: continue
		var overlaps:bool = false
		for rm:Room in rooms.values():
			if rm.rect.intersects(footprint):
				overlaps = true
				break
		if overlaps: continue
		rooms.set(room.rect.position, room)

func make_room() -> Room:
	var width_range:Vector2i = options.room_width
	var height_range:Vector2i = options.room_height
	var x_coord = rng.randi_range(0 + Global.grid_offset.x,Global.grid_size.x + Global.grid_offset.x)
	var y_coord = rng.randi_range(0 + Global.grid_offset.y,Global.grid_size.y + Global.grid_offset.y)
	var x_size = rng.randi_range(width_range.x,width_range.y)
	var y_size = rng.randi_range(height_range.x,height_range.y)
	var _rect:Rect2i = Rect2i(Vector2i(x_coord,y_coord),Vector2i(x_size,y_size))
	var room:Room = Room.create(_rect)
	return room

func make_corridors():
	var triangulator = Delaunay.new(rect)
	var center_to_room:Dictionary[Vector2,Room]
	for room:Room in rooms.values():
		var center:Vector2 = room.rect.get_center()
		center_to_room.set(center, room)
		triangulator.add_point(center)
	var triangles:Array[Delaunay.Triangle] = triangulator.triangulate()
	triangulator.remove_border_triangles(triangles)
	var core_corridors:Array[Delaunay.Edge] = Prim.get_mst_from_triangulation(triangles)
	
	for edge:Delaunay.Edge in core_corridors:
		var room_a:Room = center_to_room[edge.a]
		var room_b:Room = center_to_room[edge.b]
		var corridor = make_corridor(room_a,room_b)
		var key:Vector2i = corridor.get_start() if corridors.has(corridor.get_end()) else corridor.get_end()
		corridors.set(key, corridor)

func make_corridor(room_a:Room, room_b:Room) -> Corridor:
	var room_a_edge_coord:Vector2i = room_a.get_random_edge_coord(rng)
	var room_b_edge_coord:Vector2i = room_b.get_random_edge_coord(rng)
	var corridor_vec:Vector2i = room_b_edge_coord - room_a_edge_coord
	var corridor:Corridor = Corridor.create([])
	# pick x or y at random to choose Elbow bend direction
	var picked_y:bool = true if rng.randi_range(0,1) == 1 else false
	if picked_y:
		var temp:Vector2i = room_a_edge_coord
		room_a_edge_coord = room_b_edge_coord
		room_b_edge_coord = temp
		corridor_vec = -corridor_vec
	for x in range(0,corridor_vec.x + sign(corridor_vec.x), sign(corridor_vec.x)): 
		corridor.add_coord(Vector2i(x + room_a_edge_coord.x, room_a_edge_coord.y))
	for y in range(0,corridor_vec.y + sign(corridor_vec.y), sign(corridor_vec.y)):
		corridor.add_coord(Vector2i(room_b_edge_coord.x, room_a_edge_coord.y + y))
	return corridor

func populate_tiles() -> void:
	for room:Room in rooms.values():
		for x:int in room.rect.size.x:
			for y:int in room.rect.size.y:
				var tile:Tile = Tile.create(Vector2i(room.rect.position.x + x,room.rect.position.y + y), Tile.Type.FLOOR)
				tiles.set(tile.coord,tile)
	for corridor:Corridor in corridors.values():
		for coord in corridor.coords.keys():
			var tile:Tile = Tile.create(coord, Tile.Type.FLOOR)
			tiles.set(tile.coord,tile)
	# Create walls now from the tiles adjacent to floors
	var walls:Dictionary[Vector2i,Vector2i]
	for tile:Tile in tiles.values():
		for empty in get_adjacent_voids(tile.coord):
			walls.set(empty,empty)
	for wall_location:Vector2i in walls:
		var tile:Tile = Tile.create(wall_location, Tile.Type.WALL)
		tiles.set(tile.coord, tile)

func get_adjacent_voids(coord:Vector2i) -> Array[Vector2i]:
	var voids:Array[Vector2i]
	for y in range(-1,2):
		for x in range(-1,2):
			var spot:Vector2i = Vector2i(coord.x + x, coord.y + y)
			if !tiles.has(spot):
				voids.append(spot)
	return voids

func is_corridor_coord(coord:Vector2i):
	for c:Corridor in corridors.values():
		if c.coords.has(coord):
			return true
	return false
	
func is_corridor_end_point(coord:Vector2i):
	for c:Corridor in corridors.values():
		if c.get_end() == coord or c.get_start() == coord:
			return true
	return false
	
func is_room_coord(coord:Vector2i):
	for r:Room in rooms.values():
		if r.has_coord(coord):
			return true
	return false

class Options:
	var tries:int = 1000
	var rng = RandomNumberGenerator.new()
	var rng_seed:int = rng.randi()
	var size:Vector2i = Global.grid_size
	var offset:Vector2i = Global.grid_offset
	var num_rooms:Vector2i = Vector2i(3,10)
	var room_width:Vector2i = Vector2i(3,10)
	var room_height:Vector2i = Vector2i(2,7)
	## 0.0:1.0 - The higher connectivity means more hallways
	## 0.0 will produce only the core hallways.
	var connectivity:float = 0.0
	var hidden_rooms:bool = false
	## chance that a room is lit by torches
	var lit_chance:float = 1.0
	#
