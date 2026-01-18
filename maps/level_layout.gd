@abstract
extends RefCounted
class_name LevelLayout

var rect:Rect2i
var rng:RandomNumberGenerator
var tiles:Dictionary[Vector2i,Tile]
var previous_visible_tiles:Dictionary[Vector2i,Tile]
var current_visible_tiles:Dictionary[Vector2i,Tile]

signal tiles_updated(changed_tiles:Dictionary[Vector2i,Tile])

@abstract class Options:
	pass

func print():
	prints("Level Layout:",tiles)

## Shadow Casting Stuffs
func collect_visibility_changes(tile:Tile):
	previous_visible_tiles.set(tile.coord,tile)

func get_random_non_wall_tile() -> Tile:
	var found:Tile
	var the_tiles = tiles.values()
	while(!found):
		var tile = the_tiles[rng.randi_range(0, the_tiles.size())]
		found = tile if tile.type!= Tile.Type.WALL else null
	return found

func mark_visible(abs_vec:Vector2i):
	if !tiles.has(abs_vec): return
	var tile:Tile = tiles[abs_vec]
	tile.visible = true
	current_visible_tiles.set(abs_vec,tile)

func is_blocking(abs_vec:Vector2i) -> bool:
	if !tiles.has(abs_vec):return true
	var tile:Tile = tiles[abs_vec]
	return tile.blocks_vision

func compute_fov(origin:Vector2i, _range:int = 99):
	current_visible_tiles.clear()
	mark_visible(origin)
	for i in range(4):
		var quadrant = Quadrant.new(i, origin)
		var reveal:Callable = func(rel_vec:Vector2i):
			var abs_vec:Vector2i = quadrant.transform(rel_vec)
			mark_visible(abs_vec)
		var is_wall:Callable = func(rel_vec:Vector2i):
			if !rel_vec:
				return false
			var abs_vec:Vector2i = quadrant.transform(rel_vec)
			return is_blocking(abs_vec)
		var is_floor:Callable = func(rel_vec:Vector2i):
			if !rel_vec:
				return false
			var abs_vec:Vector2i = quadrant.transform(rel_vec)
			return not is_blocking(abs_vec)
			
		var scan:Callable = func(recursive_callable:Callable, row:Row):
			if row.depth > row.max_depth:
				return
			var prev_rel_vec:Vector2i
			var next_row:Row = null
			for rel_vec:Vector2i in row.get_tiles():
				if is_wall.call(rel_vec) or is_symmetric(row, rel_vec):
					reveal.call(rel_vec)
				if is_wall.call(prev_rel_vec) and is_floor.call(rel_vec):
					row.start_slope = slope(rel_vec)
				if is_floor.call(prev_rel_vec) and is_wall.call(rel_vec):
					next_row = row.next()
					next_row.end_slope = slope(rel_vec)
					recursive_callable.call(recursive_callable,next_row)
				prev_rel_vec = rel_vec
			if is_floor.call(prev_rel_vec):
				recursive_callable.call(recursive_callable,row.next())
			return
		var first_row = Row.new(1, Fraction.new(-1), Fraction.new(1),tiles)

		scan.call(scan,first_row)
		
	var changed_tiles:Dictionary[Vector2i,Tile]
	for key:Vector2i in current_visible_tiles.keys():
		if !previous_visible_tiles.has(key):
			changed_tiles.set(key,current_visible_tiles[key])
	for key:Vector2i in previous_visible_tiles.keys():
		if !current_visible_tiles.has(key):
			changed_tiles.set(key,previous_visible_tiles[key])
			tiles[key].visible = false
	previous_visible_tiles = current_visible_tiles.duplicate()
	current_visible_tiles.clear()
	tiles_updated.emit(changed_tiles)
	

class Quadrant extends RefCounted:
	enum Dir{
		NORTH,EAST,SOUTH,WEST
	}
	var cardinal:Dir
	var origin:Vector2
	func _init(_cardinal, _origin):
		cardinal = _cardinal
		origin = _origin

	func transform(rel_vec:Vector2i):
		@warning_ignore_start("narrowing_conversion")
		if cardinal == Dir.NORTH:
			return Vector2i(origin.x + rel_vec.x, origin.y - rel_vec.y)
		if cardinal == Dir.SOUTH:
			return Vector2i(origin.x + rel_vec.x, origin.y + rel_vec.y)
		if cardinal == Dir.EAST:
			return Vector2i(origin.x + rel_vec.y, origin.y + rel_vec.x)
		if cardinal == Dir.WEST:
			return Vector2i(origin.x - rel_vec.y, origin.y + rel_vec.x)
		@warning_ignore_restore("narrowing_conversion")

class Row extends RefCounted:
	var depth:int
	var start_slope:Fraction
	var end_slope:Fraction
	var main_tiles:Dictionary[Vector2i,Tile]
	var max_depth:int = 7 #Vision range?
	func _init(_depth:int, _start_slope:Fraction, _end_slope:Fraction, ts:Dictionary[Vector2i,Tile]):
		depth = _depth
		start_slope = _start_slope
		end_slope = _end_slope
		main_tiles = ts
	func get_tiles():
		var min_col:int = round_ties_up(depth * start_slope.value)
		var max_col:int = round_ties_down(depth * end_slope.value)
		var rel_vecs:Array[Vector2i]
		for col:int in range(min_col, max_col + 1):
			rel_vecs.append(Vector2i(col,depth))
		return rel_vecs
	
	func round_ties_up(n:float) -> int:
		return floor(n + 0.5)
		
	func round_ties_down(n:float) -> int:
			return ceil(n - 0.5)

	
	func next() -> Row:
		depth += 1
		return Row.new(depth, start_slope, end_slope, main_tiles)

func slope(rel_vec:Vector2i) -> Fraction:
	return Fraction.new(2 * rel_vec.x - 1, 2 * rel_vec.y)
	
func is_symmetric(row:Row, rel_vec:Vector2i) -> bool:
	return (rel_vec.x >= row.depth * row.start_slope.value
		and rel_vec.x <= row.depth * row.end_slope.value)


#func scan_iterative(row:Row) -> void:
	#var rows:Array[Row] = [row]
	#while rows.size() > 0:
		#row = rows.pop_back()
		#var prev_tile:Tile = null
		#for tile in row.tiles():
			#if is_wall(tile) or is_symmetric(row, tile):
				#reveal(tile)
			#if is_wall(prev_tile) and is_floor(tile):
					#row.start_slope = slope(tile)
			#if is_floor(prev_tile) and is_wall(tile):
				#next_row = row.next()
				#next_row.end_slope = slope(tile)
				#rows.append(next_row)
			#prev_tile = tile
		#if is_floor(prev_tile):
				#rows.append(row.next())
