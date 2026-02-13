extends Resource
class_name LevelData

@export var level_seed:int = 0
@export var item_seed:int = 0
@export var combat_seed:int = 0
@export var level_layout_type:LevelOptions.LevelLayoutType = LevelOptions.LevelLayoutType.SIMPLE_ROOM_CORRIDOR
@export var level_layout_options:Resource
@export var num_starting_enemies:int = 7
@export var enemy_pool:EnemyPool
@export var item_pool:ItemPool
@export var feature_pool:FeaturePool
