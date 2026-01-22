extends Node
class_name Level

@export var actor_scenes:Dictionary[String,PackedScene]
@export var items_resources:Dictionary[String,Resource]

var turn_manager:TurnManager
var item_manager:ItemManager
var size:Vector2i
@export var tilemap:TileMapLayer
var layout:LevelLayout
var pathfinder:Pathfinder
var player:Player

func _ready() -> void:
	item_manager = ItemManager.create(self)
	
	player = actor_scenes["Player"].instantiate()
	Global.current_level = self
	generate_level(true)
	turn_manager = TurnManager.new()
	turn_manager.add_actor(player)
	player.teleport(layout.get_random_floor().coord)
	player.started_turn.connect(update_from_players_vision)
	for i in 200:
		var goblin:Enemy = actor_scenes["Goblin"].instantiate()
		goblin.teleport(layout.get_random_floor().coord)
		turn_manager.add_actor(goblin)

	for i in 200:
		item_manager.add_item(ItemManager.ItemName.HEALTH_POTION)
	
	#turn_manager.player = player
	add_child(item_manager)
	add_child(turn_manager)
	update_from_players_vision.call_deferred()
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug_top"):
		generate_level()

func generate_level(seeded:bool = false):
	tilemap.clear()
	var opts:SimpleRoomCorridorLayout.Options = SimpleRoomCorridorLayout.Options.new()
	if seeded:
		opts.rng_seed = 2622252045
	opts.num_rooms = Vector2i(3,40)
	opts.room_height = Vector2i(2,20)
	opts.room_width = Vector2i(2,8)
	layout = SimpleRoomCorridorLayout.generate(opts)
	pathfinder = Pathfinder.new()
	pathfinder.initialize(layout)
	layout.tiles_updated.connect(update_tilemap)
	print(layout.rng.seed)
	for tile:Tile in layout.tiles.values():
		if tile.type == Tile.Type.FLOOR:
			tile.tile_map_atlas_coord = get_random_floor_tile_symbol()
			tilemap.set_cell(
				tile.coord,
			 	0 if tile.visible else 1 if tile.discovered else 2, 
				tile.tile_map_atlas_coord
			)
		if tile.type == Tile.Type.WALL:
			tile.tile_map_atlas_coord = Vector2i(2,2)
			tilemap.set_cell(
				tile.coord,
				0 if tile.visible else 1 if tile.discovered else 2, 
				tile.tile_map_atlas_coord
			)

func update_tilemap(tiles_changed:Dictionary[Vector2i,Tile]):
	for tile:Tile in tiles_changed.values():
		tilemap.set_cell(
			tile.coord,
			0 if tile.visible else 1 if tile.discovered else 3 if tile.type == Tile.Type.DEBUG else 2, 
			tile.tile_map_atlas_coord
		)

func update_from_players_vision(_unused:int = -1):
	layout.compute_fov(player.coord)
	turn_manager.check_visibility()
	item_manager.check_visibility()

func get_random_floor_tile_symbol():
	var floor_sprite_coords:Array[Vector2i] = [Vector2i(6,0), Vector2i(7,0),Vector2i(0,2),Vector2i(1,2),Vector2i(5,2)]
	return floor_sprite_coords[layout.rng.randi_range(0,floor_sprite_coords.size()-1)]

func get_tile(coord:Vector2i) -> Tile:
	if !layout.tiles.has(coord): return null
	return layout.tiles[coord]

func is_adjacent_to_player(coord:Vector2i) -> bool:
	if player.coord.distance_squared_to(coord) < 4.0:
		return true
	return false

func can_see_player(from:Vector2i, vision_radius:int) -> bool:
	return can_see_actor(from,vision_radius,player)

func can_see_actor(from:Vector2i,vision_radius:int, actor:Actor) -> bool:
	if actor.coord.distance_squared_to(from) >= pow(vision_radius,2) + 0.2:
		return false
	var vecs_to_check:Array[Vector2i] =Bresenham.get_line(actor.coord, from)
	for vec:Vector2i in vecs_to_check:
		if layout.tiles.has(vec):
			if layout.tiles[vec].blocks_vision: return false
	return true

func get_actors_in_range(center:Vector2i,radius:int) -> Array[Actor]:
	var result:Array[Actor] = []
	for actor:Actor in turn_manager.actors:
		if center.distance_squared_to(actor.coord) <= radius*radius:
			result.append(actor)
	return result

func is_cell_occupied(coord:Vector2i) -> bool:
	for actor:Actor in turn_manager.actors:
		if coord == actor.coord:
			return true
	return false
