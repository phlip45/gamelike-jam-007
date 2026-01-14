extends Object
class_name Room

var rect:Rect2i
var coords:Dictionary[Vector2i,Vector2i]

func get_footprint() -> Rect2i:
	var rec:Rect2i = rect
	rec.position -= Vector2i.ONE
	rec.size += 2 * Vector2i.ONE
	return rec

static func create(_rect:Rect2i) -> Room:
	var room = Room.new()
	room.rect = _rect
	for y in room.rect.size.y:
		for x in room.rect.size.x:
			var coord:Vector2i = Vector2i(room.rect.position.x + x, room.rect.position.y + y)
			room.coords.set(coord,coord)
	return room

func get_random_coord(rng:RandomNumberGenerator) -> Vector2i:
	return Vector2i(
		rect.position.x + rng.randi_range(0,rect.size.x-1),
		rect.position.y + rng.randi_range(0,rect.size.y-1)
	)

func get_random_edge_coord(rng:RandomNumberGenerator) -> Vector2i:
	var vert_horz:Array[Vector2i] = [Vector2i(0,1), Vector2i(1,0)]
	var rand_vec:Vector2i = get_random_coord(rng)
	var mask = vert_horz[rng.randi_range(0,vert_horz.size() - 1)]
	rand_vec = rand_vec * mask
	if mask.x == 0:
		rand_vec.x = rect.position.x if rng.randi_range(0,1) == 0 else rect.end.x - 1
	else:
		rand_vec.y = rect.position.y if rng.randi_range(0,1) == 0 else rect.end.y - 1
	return rand_vec

func has_coord(coord:Vector2i) -> bool:
	return coords.has(coord)

func print():
	print("Room: ", rect)
