extends Node
class_name Level

@onready var turn_manager: TurnManager = $"../TurnManager"

var size:Vector2i
@export var tilemap:TileMapLayer


func _ready() -> void:
	generate_level(true)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug_top"):
		generate_level()

func generate_level(seeded:bool = false):
	tilemap.clear()
	
	#for x in Global.grid_size.x+2:
		#for y in Global.grid_size.y+2:
			#tilemap.set_cell(
					#Vector2i(
						#Global.grid_offset.x + x-1,
						#Global.grid_offset.y + y-1
					#),
				 	#1, 
					#Vector2i(2,3)
				#)
	var opts:SimpleRoomCorridorLayout.Options = SimpleRoomCorridorLayout.Options.new()
	if seeded:
		opts.rng_seed = 2622252014
	opts.num_rooms = Vector2i(3,40)
	opts.room_height = Vector2i(7,13)
	opts.room_width = Vector2i(2,4)
	var layout:SimpleRoomCorridorLayout = SimpleRoomCorridorLayout.generate(opts)
	print(layout.rng.seed)
	for tile:Tile in layout.tiles.values():
		var floor_sprite_coords:Array[Vector2i] = [Vector2i(6,0), Vector2i(7,0),Vector2i(0,2),Vector2i(1,2),Vector2i(5,2)]
		if tile.type == Tile.Type.FLOOR:
			tilemap.set_cell(
				Vector2i(
					tile.coord.x,
					tile.coord.y
				),
			 	1, 
				floor_sprite_coords[layout.rng.randi_range(0,floor_sprite_coords.size()-1)]
			)
		if tile.type == Tile.Type.WALL:
			tilemap.set_cell(
				Vector2i(
					tile.coord.x,
					tile.coord.y
				),
			 	1, 
				Vector2i(2,2)
			)
