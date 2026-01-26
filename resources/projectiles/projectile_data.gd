extends Resource
class_name ProjectileData

@export var symbol_list:Dictionary[Vector2i,String] = {
	Vector2i.UP:"|",
	Vector2i(1,-1):"/",
	Vector2i.RIGHT:"—",
	Vector2i(1,1):"\\",
	Vector2i.DOWN:"|",
	Vector2i(-1,1):"/",
	Vector2i.LEFT:"—",
	Vector2i(-1,-1):"\\",
}
@export var color:Color = Color.WHITE
@export var damage:int = 1
