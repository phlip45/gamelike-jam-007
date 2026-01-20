extends RefCounted
class_name Bresenham

#From https://deepnight.net/tutorial/bresenham-magic-raycasting-line-of-sight-pathfinding/

static func get_line(vec0:Vector2i, vec1:Vector2i) -> Array[Vector2i]:
	var pts:Array[Vector2i] = []
	var swapXY = fastAbs( vec1.y - vec0.y ) > fastAbs( vec1.x - vec0.x )
	var tmp : int
	if swapXY:
		tmp = vec0.x
		vec0.x = vec0.y
		vec0.y = tmp # swap vec0.x and vec0.y
		tmp = vec1.x
		vec1.x = vec1.y
		vec1.y = tmp # swap vec1.x and vec1.y

	if ( vec0.x > vec1.x ):
		# make sure vec0.x < vec1.x
		tmp = vec0.x
		vec0.x = vec1.x
		vec1.x = tmp
		# swap vec0.x and vec1.x
		tmp = vec0.y
		vec0.y = vec1.y
		vec1.y = tmp
		# swap vec0.y and vec1.y

	var deltax = vec1.x - vec0.x
	var deltay = floor( fastAbs( vec1.y - vec0.y ) )
	var error = floor( deltax / 2.0 )
	var y = vec0.y
	var ystep = 1 if ( vec0.y < vec1.y )  else -1
	if swapXY:
		# Y / X
		for x in range(vec0.x,vec1.x+1):
			pts.append(Vector2i(y,x))
			error -= deltay;
			if error < 0:
				y = y + ystep;
				error = error + deltax;
	else:
		# X / Y
		for x in range(vec0.x,vec1.x+1):
			pts.append(Vector2i(x,y))
			error -= deltay
			if error < 0:
				y = y + ystep
				error = error + deltax
	return pts

static func fastAbs(v:int) -> int:
	return (v ^ (v >> 31)) - (v >> 31)
