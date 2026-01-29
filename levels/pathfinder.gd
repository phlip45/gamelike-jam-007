extends RefCounted
class_name Pathfinder

var astar:AStarGrid2D
var level_layout:LevelLayout

func initialize(layout:LevelLayout):
	astar = AStarGrid2D.new()
	level_layout = layout
	update()

func update():
	astar.clear()
	var rect = level_layout.rect
	rect.position -= Vector2i.ONE
	rect.size += Vector2i.ONE
	astar.region = rect
	astar.cell_size = Global.tile_size
	astar.update()
	for wall in level_layout.tiles.values().filter(func(t:Tile):
		return t.type == Tile.Type.WALL):
		astar.set_point_solid(wall.coord)

func get_path(from:Vector2i,to:Vector2i)-> Array[Vector2i]:
	if !astar.is_in_bounds(from.x,from.y) and !astar.is_in_bounds(to.x, to.y):
		printerr("Tried to get path that wasn't in bounds")
		return []
	var path:Array[Vector2i] = astar.get_id_path(from,to,true)
	return path
