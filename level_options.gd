extends Resource
class_name LevelOptions

@export var level_seed:int
@export var item_seed:int
@export var combat_seed:int
@export var level_layout_type:LevelLayoutType = LevelLayoutType.SIMPLE_ROOM_CORRIDOR
@export var level_layout_options:LayoutOptions = SimpleRoomCorridorOptions.new()
@export var num_starting_enemies:int = 7
@export var enemy_pool:EnemyPool
@export var item_pool:ItemPool
@export var feature_pool:FeaturePool

enum LevelLayoutType{
	NULL, SIMPLE_ROOM_CORRIDOR, FOREST
}

func _init() -> void:
	level_seed = randi() if level_seed == 0 else level_seed
	item_seed = randi() if item_seed == 0 else item_seed
	combat_seed = randi() if combat_seed == 0 else combat_seed
