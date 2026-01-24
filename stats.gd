extends Resource
class_name Stats

## stat_changed(stat_name:String, new_amount:int) -> emits when stats are changed for any reason
signal stat_changed(stat_name:String, new_val:int)

@export var hp:int:
	set(val):
		hp = max(val,0)
		stat_changed.emit("hp", val)
@export var hp_max:int:
	set(val):
		hp_max = max(val,0)
		stat_changed.emit("hp_max", val)
@export var hunger:int:
	set(val):
		hunger = max(val,0)
		stat_changed.emit("hunger", val)
@export var hunger_max:int:
	set(val):
		hunger_max = max(val,0)
		stat_changed.emit("hunger_max", val)
@export var mp:int:
	set(val):
		mp = max(val,0)
		stat_changed.emit("mp", val)
@export var mp_max:int:
	set(val):
		mp_max = max(val,0)
		stat_changed.emit("mp_max", val)
@export var stremf:int:
	set(val):
		stremf = max(val,0)
		stat_changed.emit("stremf", val)
@export var woowoo:int:
	set(val):
		woowoo = max(val,0)
		stat_changed.emit("woowoo", val)
@export var whoosh:int:
	set(val):
		whoosh = max(val,0)
		stat_changed.emit("whoosh", val)
@export var vision_radius:int:
	set(val):
		vision_radius = max(val,0)
		stat_changed.emit("vision_radius", val)

func add(other_stats:Stats) -> Stats:
	hp = hp + other_stats.hp
	hp_max = hp_max + other_stats.hp_max
	hunger = hunger + other_stats.hunger
	hunger_max = hunger_max + other_stats.hunger_max
	mp = mp + other_stats.mp
	mp_max = mp_max + other_stats.mp_max
	stremf = stremf + other_stats.stremf
	woowoo = woowoo + other_stats.woowoo
	whoosh = whoosh + other_stats.whoosh
	vision_radius = vision_radius + other_stats.vision_radius
	return self

func overwrite(other_stats:Stats) -> Stats:
	hp = other_stats.hp
	hp_max = other_stats.hp_max
	hunger = other_stats.hunger
	hunger_max = other_stats.hunger_max
	mp = other_stats.mp
	mp_max = other_stats.mp_max
	stremf = other_stats.stremf
	woowoo = other_stats.woowoo
	whoosh = other_stats.whoosh
	vision_radius = other_stats.vision_radius
	return self
