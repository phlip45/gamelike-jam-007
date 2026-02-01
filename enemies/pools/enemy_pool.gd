extends Resource
class_name EnemyPool

@export var enemies:Array[EnemyData]
var total_pool_rarity:float = -1

@export var use_guaranteed_spawns:bool = false
## These enemies are guaranteed to spawn on the level and 
## don't count towards the number of spawns included for
## the level.
@export var guaranteed_spawns:Array[EnemyData]

func get_rand_enemy_data(rng:RandomNumberGenerator) -> EnemyData:
	if total_pool_rarity == -1: calc_total_pool_rarity()
	var roll:float = rng.randf_range(0,total_pool_rarity)
	var chosen_enemy:EnemyData = enemies[0]
	for enemy in enemies:
		if roll <= enemy.rarity.value:
			chosen_enemy = enemy
			break
		else:
			roll -= enemy.rarity.value
	return chosen_enemy.duplicate()
	
func calc_total_pool_rarity():
	total_pool_rarity = 0
	for data:EnemyData in enemies:
		total_pool_rarity += data.rarity.value
