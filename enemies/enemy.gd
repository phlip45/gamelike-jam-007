extends Actor
class_name Enemy

@export var stats:Stats
@export var _ai_script:GDScript
@onready var symbol: RichTextLabel = $Symbol

var ai:AI

@warning_ignore("unused_signal")
signal turn_over(time_spent)

func _ready() -> void:
	ai = _ai_script.create()

## Returns how long the turn took to feed into the queue
func take_turn() -> int:
	var tiles= Global.current_level.layout.tiles
	coord = Global.position_to_coord(global_position)
	if tiles.has(coord):
		var cur_tile:Tile = tiles[coord]
		symbol.visible = cur_tile.visible
	return ai.take_turn(self)

func move():
	# later on this will use A*
	var rand_dir = Vector2(randi_range(-1,1),randi_range(-1,1))
	position += rand_dir * Global.tile_size.x

func take_damage(amount:int) -> void:
	stats.hp -= amount
	print_rich("[color=red]I've been hit for %s damage" % amount)
	if stats.hp <= 0:
		die()
		
func die():
	died.emit()
	queue_free()
