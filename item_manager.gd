extends Node
class_name ItemManager

enum ItemName{
	NULL, HEALTH_POTION, SWORD
}
const ITEM_MANAGER = preload("uid://cvgdddwbo7wia")

@export var item_resources:Dictionary[ItemName, Item]
var item_husks:Array[ItemHusk]
var level:Level

static func create(_level:Level):
	var manager:ItemManager = ITEM_MANAGER.instantiate()
	manager.level = _level
	return manager

func add_item(item_name:ItemName):
	var item_husk:ItemHusk = ItemHusk.create(item_resources[item_name])
	item_husk.coord = level.layout.get_random_floor().coord
	item_husk.destroyed.connect(remove_item_husk.bind(item_husk),CONNECT_ONE_SHOT)
	item_husks.append(item_husk)
	add_child(item_husk)

func remove_item_husk(item_husk:ItemHusk):
	item_husks.erase(item_husk)
	remove_child(item_husk)

func add_random_item_husk() -> void:
	var keys:Array[ItemName] = item_resources.keys()
	var random_index:int = level.item_rng.randi_range(0,keys.size()-1)
	add_item(keys[random_index])

func get_random_item() -> Item:
	return null

func check_visibility():
	for husk:ItemHusk in item_husks:
		husk.check_visibility()
