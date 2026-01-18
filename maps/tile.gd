extends RefCounted
class_name Tile

enum Type{
	NULL, WALL, FLOOR, DEBUG
}

var coord:Vector2i
var type:Type
var tile_map_atlas_coord:Vector2i
var discovered:bool = false
var visible:bool = false:
	set(value):
		visible = value
		if value: discovered = value
var blocks_vision:bool = false

static func create(_coord:Vector2i, _type:Type):
	var tile = Tile.new()
	tile.coord = _coord
	tile.type = _type
	if _type == Type.WALL:
		tile.blocks_vision = true
	return tile
