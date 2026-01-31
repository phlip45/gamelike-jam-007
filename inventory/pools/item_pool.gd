extends Resource
class_name ItemPool

@export var items:Array[Item]
var total_pool_rarity:float = -1

## between 0 and 1. IE [1.0, 0.2, 0.1] would give a guaranteed drop
## a 20% chance of another drop, and a 10% chance of a 3rd drop. Weights
## are inclusive.
@export var drop_weights:Array[float]

@export var use_guaranteed_drops:bool = false
## These items will always be part of get_death_drops in addition to
## the normal drop_weights if use_guaranteed_drops is checked on. 
## The items here do not need to be part of the normal items pool.
@export var guaranteed_drops:Array[Item]


func get_death_drops(rng:RandomNumberGenerator = RandomNumberGenerator.new()) -> Array[Item]:
	var drops:Array[Item]
	if use_guaranteed_drops:
		drops.append_array(guaranteed_drops)
	for f:float in drop_weights:
		if rng.randf() <= f:
			drops.append(get_rand_item_data(rng))
	return drops

func get_rand_item_data(rng:RandomNumberGenerator) -> Item:
	if total_pool_rarity == -1: calc_total_pool_rarity()
	var roll:float = rng.randf_range(0,total_pool_rarity)
	var chosen_item:Item = items[0]
	for item in items:
		if roll <= item.rarity.value:
			chosen_item = item
			break
		else:
			roll -= item.rarity.value
	return chosen_item.duplicate()

func calc_total_pool_rarity():
	total_pool_rarity = 0
	for data:Item in items:
		total_pool_rarity += data.rarity.value
