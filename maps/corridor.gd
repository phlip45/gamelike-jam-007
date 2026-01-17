extends RefCounted
class_name Corridor

var coords:Dictionary[Vector2i, Vector2i]

static func create(_coords:Array[Vector2i]) -> Corridor:
	var corridor = Corridor.new()
	for coord:Vector2i in _coords:
		corridor.coords.set(coord,coord)
	return corridor

func add_coord(coord:Vector2i):
	coords.set(coord, coord)

func erase_coord(coord:Vector2i):
	coords.erase(coord)

func get_start() -> Vector2i:
	if coords.size() == 0: 
		printerr("Tried to get start of corridor that is empty")
		return Vector2i(-9999,-9999)
	return coords[coords.keys().front()]
	
func get_end() -> Vector2i:
	if coords.size() == 0: 
		printerr("Tried to get end of corridor that is empty")
		return Vector2i(-9999,-9999)
	return coords[coords.keys().back()]
	
func print():
	prints("Corridor: ", coords)
