extends Resource
class_name LevelData

@export var level_seed:int = randi()
@export var item_seed:int = randi()
@export var combat_seed:int = randi()
@export var level_layout_type:Level.Options.LevelLayoutType = Level.Options.LevelLayoutType.SIMPLE_ROOM_CORRIDOR
@export var level_layout_options:Resource
@export var num_starting_enemies:int = 7
@export var enemy_pool:EnemyPool
@export var item_pool:ItemPool
@export var feature_pool:FeaturePool
