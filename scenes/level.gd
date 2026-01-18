extends Node
class_name Level

@onready var turn_manager: TurnManager = $"../TurnManager"

var size:Vector2i
@export var tilemap:TileMapLayer
var layout:LevelLayout

func _ready() -> void:
	Global.current_level = self
	generate_level(true)
	turn_manager.player.finished_turn.connect(update_from_players_vision)
	update_from_players_vision()
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug_top"):
		generate_level()

func generate_level(seeded:bool = false):
	tilemap.clear()
	var opts:SimpleRoomCorridorLayout.Options = SimpleRoomCorridorLayout.Options.new()
	if seeded:
		opts.rng_seed = 2622252015
	opts.num_rooms = Vector2i(3,40)
	opts.room_height = Vector2i(2,20)
	opts.room_width = Vector2i(2,8)
	layout = SimpleRoomCorridorLayout.generate(opts)
	layout.tiles_updated.connect(update_tilemap)
	print(layout.rng.seed)
	for tile:Tile in layout.tiles.values():
		if tile.type == Tile.Type.FLOOR:
			tile.tile_map_atlas_coord = get_random_floor_tile()
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
			0 if tile.visible else 1 if tile.discovered else 2, 
			tile.tile_map_atlas_coord
		)

func update_from_players_vision(_unused:int = -1):
	layout.compute_fov(turn_manager.player.coord)

func get_random_floor_tile():
	var floor_sprite_coords:Array[Vector2i] = [Vector2i(6,0), Vector2i(7,0),Vector2i(0,2),Vector2i(1,2),Vector2i(5,2)]
	return floor_sprite_coords[layout.rng.randi_range(0,floor_sprite_coords.size()-1)]
