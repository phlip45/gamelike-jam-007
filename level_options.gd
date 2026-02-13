extends Resource
class_name LevelOptions

@export var level_seed:int
@export var item_seed:int
@export var combat_seed:int
@export var level_layout_type:LevelLayoutType = LevelLayoutType.SIMPLE_ROOM_CORRIDOR
@export var level_layout_options:LayoutOptions = SimpleRoomCorridorOptions.new()
@export var num_starting_enemies:int = 7
@export var num_starting_item:int = 3
@export var enemy_pool:EnemyPool
@export var item_pool:ItemPool
@export var feature_pool:FeaturePool

enum LevelLayoutType{
	NULL, SIMPLE_ROOM_CORRIDOR, FOREST, DRUNKARDS_WALK
}
