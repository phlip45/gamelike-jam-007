extends CPUParticles2D
class_name BloodSplatter

static func create(_amount, coord:Vector2i, color:Color = Color.RED) -> void:
	var splat:BloodSplatter = load("res://juice/blood_splatter.tscn").instantiate()
	splat.amount = _amount * 3
	if Global.Settings.hyperbole:
		splat.scale_amount_min *= 3
		splat.scale_amount_max *= 3
	splat.global_position = Global.coord_to_position(coord)
	splat.modulate = color
	Global.current_level.add_child(splat)
	splat.finished.connect(splat.queue_free)
	splat.emitting = true
	#var viewport:Viewport = splat.get_viewport()
	#var screen_pos:Vector2 = viewport.get_canvas_transform() * splat.working_position
	#splat.working_position = screen_pos
	#splat.global_position = screen_pos
	#splat.global_position = Vector2( 
		#snappedi(splat.working_position.x,Global.tile_size.x) -8,
		#snappedi(splat.working_position.y, Global.tile_size.y )-2
	#)
