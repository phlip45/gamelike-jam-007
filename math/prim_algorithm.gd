class_name Prim
extends Node

static func get_mst(adjacencies:Dictionary[Vector2i,Dictionary]) -> Array[Delaunay.Edge]:
	var unvisited:Array[Vector2i] = adjacencies.keys()
	var visited:Array[Vector2i]
	var mst:Array[Delaunay.Edge]
	## This priqueue will have unvisited edges that are neighbors
	var priority_queue:Heap = Heap.create(
		func(a:float,b:float): return a <= b,
		func(a:Delaunay.Edge): return a.get_length()
	)	
	
	visited.append(unvisited.pop_back())
	for edge:Delaunay.Edge in adjacencies[visited[0]].values():
		priority_queue.push(edge)
	
	while priority_queue.size() > 0:
		var edge_candidate:Delaunay.Edge = priority_queue.pop()

		var a:Vector2i = Vector2i(edge_candidate.a)
		var b:Vector2i = Vector2i(edge_candidate.b)

		var a_visited:bool = visited.has(a)
		var b_visited:bool = visited.has(b)

		if a_visited == b_visited:
			continue

		var new_point:Vector2i = b if a_visited else a
		#for edge in adjacencies[new_point].values():
			#var ea = Vector2i(edge.a)
			#var eb = Vector2i(edge.b)
#
			#if ea != new_point and eb != new_point:
				#push_error("Edge does not touch its adjacency node: %s" % edge)
		mst.append(edge_candidate)
		visited.append(new_point)
		for edge:Delaunay.Edge in adjacencies[new_point].values():
			priority_queue.push(edge)
		
	return mst

static func get_mst_from_triangulation(triangles:Array[Delaunay.Triangle]) -> Array[Delaunay.Edge]:
	var adjacencies:Dictionary[Vector2i,Dictionary] = Delaunay.get_adjacencies_from_triangulation(triangles)
	return get_mst(adjacencies)
