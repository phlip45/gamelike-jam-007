extends RefCounted
class_name Tile

enum Type{
	NULL, WALL, FLOOR
}

var coord:Vector2i
var type:Type
var _base_map_coord:Vector2i
var discovered:bool = false
var visible:bool = false
var blocks_vision:bool = false
var tile_map_coord:Vector2i:
	get: return get_tile_map_coord_from_base()
	set(value):
		_base_map_coord = value

static func create(_coord:Vector2i, _type:Type):
	var tile = Tile.new()
	tile.coord = _coord
	tile.type = _type
	if _type == Type.WALL:
		tile.blocks_vision = true
	return tile

func get_tile_map_coord_from_base():
	return _base_map_coord
