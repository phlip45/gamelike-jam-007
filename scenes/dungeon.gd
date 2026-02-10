extends Node2D

var _seed:int
var rng:RandomNumberGenerator
var level_count:int = 1
var current_level:Level
@export var playlist:DungeonPlaylist
@onready var tilemap: TileMapLayer = $Tilemap
var player:Player

func _ready() -> void:
	
	if _seed == 0:
		_seed = randi()
	player = load("res://player/player.tscn").instantiate()
	current_level = setup_level(level_count)
	add_child(current_level)

func move_to_next_level():
	level_count += 1
	if level_count > playlist.level_options_lookup.size():
		get_tree().change_scene_to_file.call_deferred("res://scenes/win_screen.tscn")
		return
	var next_level:Level = setup_level(level_count)
	player.get_parent().remove_child(player)
	remove_child(current_level)
	current_level.queue_free()
	await get_tree().process_frame
	current_level = next_level
	player.level = current_level
	add_child(next_level)
	
func setup_level(level_num:int) -> Level:
	var level_opts:LevelOptions =  playlist.level_options_lookup[level_num]
	var level:Level = Level.create(level_opts)
	level.level_finished.connect(move_to_next_level, CONNECT_ONE_SHOT)
	level.player = player
	level.tilemap = tilemap
	return level
