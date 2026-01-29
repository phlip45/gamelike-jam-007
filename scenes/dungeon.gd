extends Node2D

var _seed:int
var rng:RandomNumberGenerator
var level_count:int = 1
var current_level:Level
var current_level_options:Level.Options
@export var enemy_pool_lookup:Dictionary[int, EnemyPool]
@export var item_pool_lookup:Dictionary[int, ItemPool]
@export var feature_pool_lookup:Dictionary[int, FeaturePool]

func _ready() -> void:
	if _seed == 0:
		_seed = randi()
	current_level_options = Level.Options.new()
	current_level_options.combat_seed = _seed
	current_level_options.item_seed = _seed
	current_level_options.level_seed = _seed
	current_level_options.level_layout_type = Level.Options.LevelLayoutType.SIMPLE_ROOM_CORRIDOR
	current_level_options.num_starting_enemies = 7
	current_level_options.enemy_pool = enemy_pool_lookup[level_count].duplicate()
	current_level_options.item_pool = item_pool_lookup[level_count].duplicate()
	current_level_options.feature_pool = feature_pool_lookup[level_count].duplicate()
	
