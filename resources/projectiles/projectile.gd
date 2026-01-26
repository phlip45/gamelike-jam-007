extends Node2D
class_name Projectile

@onready var symbol: Label = $Symbol

@export var projectile_data:ProjectileData
var tween:Tween
signal finished

static func create(proj_data:ProjectileData) -> Projectile:
	var proj = Projectile.new()
	proj.projectile_data = proj_data
	var sym:Label = Label.new()
	proj.symbol = sym
	sym.name = "Symbol"
	proj.add_child(sym)
	return proj
	
func fire_projectile(from:Vector2i, to:Vector2i):
	global_position = Global.coord_to_position(from)
	var end = Global.coord_to_position(to)
	symbol.text = projectile_data.symbol_list[vec2_to_dir8(end - global_position)]
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(self,"global_position",end,.25)
	tween.tween_callback(finished.emit)
	tween.tween_callback(queue_free)

func vec2_to_dir8(v:Vector2) -> Vector2i:
	if v == Vector2.ZERO:
		return Vector2i.ZERO

	var angle:float = v.angle()
	var step:float = PI / 4.0
	var snap:float = round(angle / step) * step

	var x:int = int(round(cos(snap)))
	var y:int = int(round(sin(snap)))

	return Vector2i(x, y)
