extends RichTextLabel
class_name DamageNumber

var velocity:Vector2
var life:float = 2
var working_position:Vector2

static func create(_amount, coord:Vector2i, color:Color = Color.RED) -> void:
	var dam_num:DamageNumber = load("res://juice/damage_number.tscn").instantiate()
	dam_num.fit_content = true
	dam_num.text = str(_amount)
	dam_num.working_position = Global.coord_to_position(coord + Vector2i.UP)
	dam_num.modulate = color
	dam_num.velocity = Vector2(randf_range(-6,6), randf_range(-6,-1))
	Global.ui.add_child(dam_num)
	var viewport:Viewport = dam_num.get_viewport()
	var screen_pos:Vector2 = viewport.get_canvas_transform() * dam_num.working_position
	dam_num.working_position = screen_pos
	dam_num.global_position = screen_pos
	dam_num.global_position = Vector2( 
		snappedi(dam_num.working_position.x,Global.tile_size.x) -8,
		snappedi(dam_num.working_position.y, Global.tile_size.y )-2
	)

func _process(delta: float) -> void:
	velocity.y += 20*delta
	working_position += velocity
	global_position = Vector2( 
		snappedi(working_position.x,Global.tile_size.x) -8,
		snappedi(working_position.y, Global.tile_size.y )-2
	)
	life -= delta
	if life < 0:
		queue_free()
