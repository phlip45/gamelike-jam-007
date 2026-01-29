extends Node2D

var _seed:int
var rng:RandomNumberGenerator
var level_count:int = 1
var current_level:Level
@export var level_options_lookup:Dictionary[int, LevelOptions]
@export var enemy_pool_lookup:Dictionary[int, EnemyPool]
@export var item_pool_lookup:Dictionary[int, ItemPool]
@export var feature_pool_lookup:Dictionary[int, FeaturePool]
@onready var tilemap: TileMapLayer = $Tilemap

func _ready() -> void:
	if _seed == 0:
		_seed = randi()
	var current_level_options = LevelOptions.new()
	current_level_options.combat_seed = _seed
	current_level_options.item_seed = _seed
	current_level_options.level_seed = _seed
	current_level_options.level_layout_type = LevelOptions.LevelLayoutType.SIMPLE_ROOM_CORRIDOR
	current_level_options.num_starting_enemies = 7
	current_level_options.enemy_pool = enemy_pool_lookup[level_count].duplicate()
	current_level_options.item_pool = item_pool_lookup[level_count].duplicate()
	current_level_options.feature_pool = feature_pool_lookup[level_count].duplicate()
	current_level = Level.create(current_level_options)
	var player:Player = load("res://player/player.tscn").instantiate()
	current_level.player = player
	current_level.tilemap = tilemap
	
	add_child(current_level)
