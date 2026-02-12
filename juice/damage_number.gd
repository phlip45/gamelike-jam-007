extends Control
class_name DamageNumber

var velocity:Vector2
var life:float = 2
var working_position:Vector2
var text:String
@onready var label: RichTextLabel = $DamageNum

static func create(_amount, coord:Vector2i, color:Color = Color.RED) -> void:
	if Global.Settings.extra_juice:
		BloodSplatter.create(_amount,coord,color)
	var scene_to_load:String = "res://juice/damage_number.tscn" if !Global.Settings.hyperbole else "res://juice/damage_number_big.tscn"
	var dam_num:DamageNumber = load(scene_to_load).instantiate()
	dam_num.text = str(_amount) if !Global.Settings.hyperbole else str(_amount*1000 + randi_range(100,999))
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

func _ready() -> void:
	label.text = "[bgcolor=#000]" + text

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
